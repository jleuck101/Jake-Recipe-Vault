#!/usr/bin/env bash
set -e

MAXDIM="${1:-1600}"
QUALITY="${2:-82}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW="$REPO_DIR/images_raw"
OUT="$REPO_DIR/images"

mkdir -p "$RAW" "$OUT"

shopt -s nullglob
files=("$RAW"/*.{jpg,jpeg,png,webp,heic,HEIC,JPG,JPEG,PNG,WEBP})

if [ ${#files[@]} -eq 0 ]; then
  echo "No files in images_raw/"
  exit 0
fi

for f in "${files[@]}"; do
  base="$(basename "$f")"
  name="${base%.*}"
  safe="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/^-+//; s/-+$//')"
  if [ -z "$safe" ]; then safe="photo-$(date +%Y%m%d-%H%M%S)"; fi

  dest="$OUT/$safe.jpg"
  echo "Compressing $(basename "$f") -> images/$safe.jpg"
  magick "$f" -auto-orient -resize "${MAXDIM}x${MAXDIM}>" -strip -interlace Plane -sampling-factor 4:2:0 -quality "$QUALITY" "$dest"
done

git -C "$REPO_DIR" add "$OUT"
echo "Done. Images compressed & staged."
