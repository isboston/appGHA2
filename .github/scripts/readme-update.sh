#!/usr/bin/env bash
set -e

WORKFLOW_FILE=".github/workflows/test.yml"
README_FILE="README.md"

# Установка yq, если не установлен
if ! command -v yq &> /dev/null; then
  sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  sudo chmod +x /usr/local/bin/yq
fi

# Получаем список ОС
OS_LIST=$(yq -r '.jobs["update-test"].strategy.matrix.include[].name' "$WORKFLOW_FILE")

# Формируем блок
BLOCK_START="<!-- OS-SUPPORT-LIST-START -->"
BLOCK_END="<!-- OS-SUPPORT-LIST-END -->"

# Формируем содержимое
NEW_BLOCK="$BLOCK_START"$'\n'
while IFS= read -r os; do
  [ -n "$os" ] && NEW_BLOCK="$NEW_BLOCK- $os"$'\n'
done <<< "$OS_LIST"
NEW_BLOCK="$NEW_BLOCK$BLOCK_END"

# Используем временный файл
TMPFILE=$(mktemp)

# Удалим старый блок и запишем новый
awk -v block_start="$BLOCK_START" -v block_end="$BLOCK_END" -v new_block="$NEW_BLOCK" '
BEGIN {in_block=0}
{
  if ($0 ~ block_start) {
    print new_block
    in_block=1
  } else if ($0 ~ block_end) {
    in_block=0
    next
  }
  if (!in_block) print
}' "$README_FILE" > "$TMPFILE"

mv "$TMPFILE" "$README_FILE"

