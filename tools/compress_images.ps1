param(
  [int]$MaxDim = 1600,
  [int]$Quality = 82
)

$repo = Split-Path -Parent $PSScriptRoot
$raw = Join-Path $repo "images_raw"
$out = Join-Path $repo "images"

New-Item -ItemType Directory -Force -Path $raw, $out | Out-Null

$files = Get-ChildItem $raw -File -Include *.jpg,*.jpeg,*.png,*.heic,*.webp -ErrorAction SilentlyContinue
if(-not $files){ Write-Host "No files in images_raw"; exit 0 }

foreach($f in $files){
  $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  $safe = ($base.ToLower() -replace "[^a-z0-9_-]+","-").Trim("-")
  if([string]::IsNullOrWhiteSpace($safe)){ $safe = "photo-" + (Get-Date -Format "yyyyMMdd-HHmmss") }

  $dest = Join-Path $out ($safe + ".jpg")
  Write-Host "Compressing $($f.Name) -> images/$($safe).jpg"

  magick "$($f.FullName)" -auto-orient -resize "${MaxDim}x${MaxDim}>" -strip -interlace Plane -sampling-factor 4:2:0 -quality $Quality "$dest"
}

git add "$out"
Write-Host "Done. Images compressed & staged from images_raw to images/"
