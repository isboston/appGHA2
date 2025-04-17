#!/usr/bin/env bash
set -e
WORKFLOW_FILE=".github/workflows/test.yml"
README_FILE="README.md"
if ! command -v yq &> /dev/null; then
  sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  sudo chmod +x /usr/local/bin/yq
fi
OS_LIST=$(yq -r '.jobs["update-test"].strategy.matrix.include[].name' "$WORKFLOW_FILE")
NEW_OS_BLOCK=""
while IFS= read -r os; do
  [ -n "$os" ] && NEW_OS_BLOCK="$NEW_OS_BLOCK- $os"$'\n'
done <<< "$OS_LIST"
TMPFILE=$(mktemp)
printf '%s\n' "<!-- OS-SUPPORT-LIST-START -->" "$NEW_OS_BLOCK" "<!-- OS-SUPPORT-LIST-END -->" > "$TMPFILE"
sed -i '/<!-- OS-SUPPORT-LIST-START -->/,/<!-- OS-SUPPORT-LIST-END -->/{
r '"$TMPFILE"'
d
}' "$README_FILE"
rm "$TMPFILE"

