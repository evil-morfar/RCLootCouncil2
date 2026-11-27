#!/usr/bin/env bash

set -Eeuo pipefail

# --------------------------------------------------
# Colors and logging
# --------------------------------------------------

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

info() {
    echo -e "${BLUE}ℹ $*${NC}"
}

success() {
    echo -e "${GREEN}✔ $*${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $*${NC}"
}

error() {
    echo -e "${RED}✖ $*${NC}" >&2
}

# --------------------------------------------------
# Configuration and arguments
# --------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DRY_RUN=false
SHOW_PAYLOAD=false
SHOW_CURL=false
DEFAULT_PROJECT_ID=39928

usage() {
    echo "Usage: $0 [options] [project-id] [localization-file]" >&2
    echo "  --dry-run          Build the request without uploading it" >&2
    echo "  --show-payload     Print the JSON payload before the request" >&2
    echo "  --show-curl        Print the curl command (API token redacted)" >&2
    echo "  project-id         Numeric CurseForge project ID (default: $DEFAULT_PROJECT_ID)" >&2
    echo "  localization-file  English translations to import (default: Locale/enUS.lua)" >&2
}

POSITIONAL=()
while (($#)); do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --show-payload)
            SHOW_PAYLOAD=true
            ;;
        --show-curl)
            SHOW_CURL=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            while (($#)); do
                POSITIONAL+=("$1")
                shift
            done
            break
            ;;
        -*)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            ;;
    esac
    shift
done

if ((${#POSITIONAL[@]} > 2)); then
    error "Too many positional arguments."
    usage
    exit 1
fi

PROJECT_ID="${POSITIONAL[0]:-$DEFAULT_PROJECT_ID}"
LOCALIZATION_FILE="${POSITIONAL[1]:-$REPO_ROOT/Locale/enUS.lua}"

if [[ -z "$PROJECT_ID" ]] || [[ "$PROJECT_ID" == -* ]] || [[ ! "$PROJECT_ID" =~ ^[0-9]+$ ]]; then
    error "A numeric CurseForge project ID is required."
    usage
    exit 1
fi

if [[ "$LOCALIZATION_FILE" != /* ]]; then
    LOCALIZATION_FILE="$REPO_ROOT/$LOCALIZATION_FILE"
fi

if [[ ! -f "$LOCALIZATION_FILE" ]]; then
    error "Localization file not found: $LOCALIZATION_FILE"
    exit 1
fi

# --------------------------------------------------
# Load API token
# --------------------------------------------------

if [[ -f "$SCRIPT_DIR/.env" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/.env"
fi

if [[ "$DRY_RUN" == false && -z "${CF_API_KEY:-}" ]]; then
    error "CF_API_KEY is not set in $SCRIPT_DIR/.env."
    exit 1
fi

for command in curl jq; do
    if ! command -v "$command" >/dev/null 2>&1; then
        error "Required command not found: $command"
        exit 1
    fi
done

if command -v lua5.1 >/dev/null 2>&1; then
    LUA_COMMAND=lua5.1
elif command -v lua >/dev/null 2>&1; then
    LUA_COMMAND=lua
else
    error "A Lua interpreter is required to parse the localization file."
    exit 1
fi

# --------------------------------------------------
# Build and submit request
# --------------------------------------------------

ENDPOINT="https://wow.curseforge.com/api/projects/$PROJECT_ID/localization/import"
LOCALIZATIONS_TEMP=$(mktemp)
METADATA_TEMP=$(mktemp)
PAYLOAD_TEMP=$(mktemp)
cleanup() {
    rm -f -- "$LOCALIZATIONS_TEMP" "$METADATA_TEMP" "$PAYLOAD_TEMP"
}
trap cleanup EXIT

DATA_START=$(awk '
    {
        line = $0
        sub(/^[[:space:]]*/, "", line)
        if (substr(line, 1, 2) == "L." || substr(line, 1, 2) == "L[") {
            print NR
            exit
        }
    }
' "$LOCALIZATION_FILE")
if [[ -z "$DATA_START" ]]; then
    error "No localization entries found in $LOCALIZATION_FILE."
    exit 1
fi

"$LUA_COMMAND" - "$LOCALIZATION_FILE" > "$LOCALIZATIONS_TEMP" <<'LUA'
local translations = {}

LibStub = function()
    return {
        NewLocale = function()
            return translations
        end
    }
end

local chunk, err = loadfile(arg[1])
assert(chunk, err)
chunk()

local keys = {}
for key, value in pairs(translations) do
    if type(key) ~= "string" then
        error("Localization keys must be strings.")
    end
    if value == true then
        value = key
    end
    if type(value) ~= "string" then
        error("Unsupported localization value for key: " .. key)
    end
    translations[key] = value
    keys[#keys + 1] = key
end

table.sort(keys)
for _, key in ipairs(keys) do
    print("L[" .. string.format("%q", key) .. "] = " .. string.format("%q", translations[key]))
end
LUA

if [[ ! -s "$LOCALIZATIONS_TEMP" ]]; then
    error "No localization entries found in $LOCALIZATION_FILE."
    exit 1
fi

jq -nc '{language: "enUS", "missing-phrase-handling": "DoNothing"}' > "$METADATA_TEMP"
jq -n \
    --argjson metadata "$(cat "$METADATA_TEMP")" \
    --rawfile localizations "$LOCALIZATIONS_TEMP" \
    '{
        metadata: $metadata,
        localizations: $localizations
    }' > "$PAYLOAD_TEMP"

CURL_ARGS=(
    --fail-with-body
    --silent
    --show-error
    --request POST
    --header "X-Api-Token: ${CF_API_KEY:-}"
    --form-string "metadata=$(cat "$METADATA_TEMP")"
    --form "localizations=<$LOCALIZATIONS_TEMP"
    "$ENDPOINT"
)

show_curl_command() {
    printf 'curl \\\n'
    printf '  --fail-with-body --silent --show-error \\\n'
    printf '  --request POST \\\n'
    printf '  --header "X-Api-Token: <redacted>" \\\n'
    printf '  --form-string %q \\\n' "metadata=$(cat "$METADATA_TEMP")"
    printf '  --form %q \\\n' "localizations=<$LOCALIZATIONS_TEMP"
    printf '  %q\n' "$ENDPOINT"
}

info "Localization file: $LOCALIZATION_FILE"
info "Locale: enUS"
info "CurseForge project: $PROJECT_ID"
info "Localization data starts at line $DATA_START."

if [[ "$SHOW_PAYLOAD" == true ]]; then
    info "JSON payload:"
    jq . "$PAYLOAD_TEMP"
fi

if [[ "$SHOW_CURL" == true ]]; then
    info "Curl command (API token redacted):"
    show_curl_command
fi

if [[ "$DRY_RUN" == true ]]; then
    warn "Dry run; no request sent."
    exit 0
fi

info "Uploading localization..."
if ! RESPONSE=$(curl "${CURL_ARGS[@]}"); then
    error "Localization upload failed."
    if [[ -n "$RESPONSE" ]]; then
        printf '%s\n' "$RESPONSE" >&2
    fi
    exit 1
fi

success "Localization upload completed."
exit 0