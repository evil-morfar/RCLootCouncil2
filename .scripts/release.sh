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
# Configuration
# --------------------------------------------------

DRY_RUN=false
VERSION=""

# --------------------------------------------------
# Parse arguments
# --------------------------------------------------

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$arg"
            else
                error "Unexpected argument: $arg"
                exit 1
            fi
            ;;
    esac
done

# --------------------------------------------------
# Run or display commands
# --------------------------------------------------

run() {
    if [[ "$DRY_RUN" == true ]]; then
        printf "${YELLOW}[DRY RUN]${NC} "
        printf '%q ' "$@"
        echo
    else
        "$@"
    fi
}

# --------------------------------------------------
# Initial validation
# --------------------------------------------------

info "Checking working directory..."

if [[ -n "$(git status --porcelain)" ]]; then
    error "Working directory is not clean."
    warn "Commit or stash your changes first."
    if [[ "$DRY_RUN" == true ]]; then
        warn "[DRY RUN] ignored"
    else
        exit 1
    fi
else
    success "Working directory is clean."
fi

ORIGINAL_BRANCH=$(git branch --show-current)

if [[ -z "$ORIGINAL_BRANCH" ]]; then
    error "Not currently on a branch (detached HEAD)."
    exit 1
fi

if [[ "$ORIGINAL_BRANCH" == "master" ]]; then
    error "Cannot deploy from master."
    exit 1
fi

UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || {
    error "Current branch has no upstream configured."
    exit 1
}

info "Source branch: ${ORIGINAL_BRANCH}"
info "Upstream: ${UPSTREAM}"

# --------------------------------------------------
# Version
# --------------------------------------------------

if [[ -z "$VERSION" ]]; then
    read -rp "Enter release version (e.g. 1.2.3 or 1.2.3-beta.1): " VERSION
fi

if [[ -z "$VERSION" ]] || [[ "$VERSION" =~ [[:space:]] ]] || [[ "$VERSION" == -* ]]; then
    error "Invalid version."
    exit 1
fi

TAG="$VERSION"

# --------------------------------------------------
# Tag validation
# --------------------------------------------------

if git show-ref --verify --quiet "refs/tags/$TAG"; then
    error "Tag $TAG already exists locally."
    exit 1
fi

info "Checking remote tag..."

REMOTE_TAG=$(git ls-remote --tags origin "refs/tags/$TAG") || {
    error "Could not check remote tags."
    exit 1
}

if [[ -n "$REMOTE_TAG" ]]; then
    error "Tag $TAG already exists on origin."
    exit 1
fi

success "Tag $TAG is available."

# --------------------------------------------------
# Deployment summary
# --------------------------------------------------

echo ""
info "Deployment summary:"
echo -e "Source branch: ${GREEN}${ORIGINAL_BRANCH}${NC}"
echo -e "Target branch: ${YELLOW}master${NC}"
echo    "Upstream:      ${UPSTREAM}"
echo -e "Tag:           ${RED}${TAG}${NC}"
echo    "Dry run:       ${DRY_RUN}"
echo ""

if [[ "$DRY_RUN" == false ]]; then
    read -rp "Continue? (y/N) " CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        warn "Deployment cancelled."
        exit 0
    fi
fi

# --------------------------------------------------
# Restore original branch on exit
# --------------------------------------------------

restore_branch() {
    local EXIT_CODE=$?

    if [[ "$DRY_RUN" == false ]]; then

        if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
            warn "Aborting unfinished merge..."
            git merge --abort || {
                error "Could not abort merge."
                EXIT_CODE=1
            }
        fi

        if [[ "$(git branch --show-current)" != "$ORIGINAL_BRANCH" ]]; then
            info "Restoring original branch: ${ORIGINAL_BRANCH}"

            git checkout "$ORIGINAL_BRANCH" || {
                error "Could not restore original branch."
                EXIT_CODE=1
            }
        fi
    fi

    exit "$EXIT_CODE"
}

trap restore_branch EXIT

# --------------------------------------------------
# Deployment
# --------------------------------------------------

echo ""

info "Fetching latest changes..."
run git fetch origin
success "Fetch completed."

info "Synchronizing ${ORIGINAL_BRANCH}..."
run git pull --ff-only
success "Source branch synchronized."

info "Switching to master..."
run git checkout master

info "Updating master..."
run git pull --ff-only origin master
success "Master synchronized."

info "Merging ${ORIGINAL_BRANCH} into master..."
run git merge --no-ff "$ORIGINAL_BRANCH" -m "Merge ${ORIGINAL_BRANCH} for release ${TAG}"
success "Merge completed."

info "Pushing master..."
run git push origin master
success "Master pushed."

info "Uploading English localization to CurseForge..."
if [[ "$DRY_RUN" == true ]]; then
    bash .scripts/upload_localization.sh --dry-run --show-curl
    success "Localization dry run completed."
else
    run bash .scripts/upload_localization.sh
    success "Localization uploaded."
fi

info "Creating tag ${TAG}..."
run git tag -a "$TAG" -m "Release ${TAG}"
success "Tag created."

info "Pushing tag ${TAG}..."
run git push origin "$TAG"
success "Tag pushed."

echo ""
success "Deployment of ${TAG} completed successfully!"