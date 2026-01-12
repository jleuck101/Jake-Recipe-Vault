#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

./tools/compress_images.sh

# stage other changes (optional)
git add index.html recipes.json sw.js 2>/dev/null || true

echo
git status
echo

read -r -p "Commit message (blank = 'Add/update recipe photos'): " MSG
if [ -z "$MSG" ]; then MSG="Add/update recipe photos"; fi

git commit -m "$MSG" || { echo "Nothing to commit."; exit 0; }
git push

echo
echo "Done!"
