#!/usr/bin/env bash
set -e

CHANGELOG_FILE=${1:-changelog.md}
REPO=${REPO:-"evil-morfar/RCLootCouncil2"}
WEBHOOK=${DISCORD_WEBHOOK:-""}

VERSION=$(awk '/^# / { gsub(/^# /,""); print; exit }' $CHANGELOG_FILE)

if [[ -z "$WEBHOOK" ]]; then
  echo "Error: DISCORD_WEBHOOK must be set"
  exit 1
fi

# --- Construct changelog with issue links ---
CHANGELOG=$(sed -n "3,/^# / {/^# /d; p}" "$CHANGELOG_FILE" |
  awk -v repo="$REPO" '
  {
    while (match($0, /\(#([0-9]+)\)/, m)) {
      issue = m[1]
      link = "([#" issue "](https://github.com/" repo "/pull/" issue "))"
      $0 = substr($0, 1, RSTART-1) link substr($0, RSTART+RLENGTH)
    }
    print
  }
')

# --- Truncate to 4000 chars to be safe (Discord limit 4096) ---
CHANGELOG=$(echo "$CHANGELOG" | head -c 4000)

# --- Escape newlines and quotes for JSON ---
PAYLOAD=$(jq -n \
    --arg version "$VERSION" \
    --arg changelog "$CHANGELOG" \
    --arg repo "$REPO" \
    '{
    username: "Release Bot",
    avatar_url: "https://media.forgecdn.net/avatars/thumbnails/245/403/64/64/637151371641742184.png",
    embeds: [{
        title: ("RCLootCouncil v" + $version),
        description: ("-# A new version of RCLootCouncil is available!\n" + $changelog),
        color: 3816789,
        footer: { text: "GitHub Actions" },
        timestamp: now | strflocaltime("%Y-%m-%dT%H:%M:%SZ"),
        fields: [
            {
                name: "Download",
                value: ("[CurseForge](https://www.curseforge.com/wow/addons/rclootcouncil/files)"
                + " | [Wago](https://addons.wago.io/addons/rclootcouncil/versions)"
                + " | [GitHub](https://github.com/" + $repo + "/releases/latest)"),
                inline: true
            }
        ]
    }]
    }')

# --- Send to Discord ---
curl -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK"