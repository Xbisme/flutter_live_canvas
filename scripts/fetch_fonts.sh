#!/usr/bin/env bash
# Fetch the three LiveCanvas brand fonts into assets/fonts/ (MO-002, FR-004).
#
# Fonts must ship bundled — the app must not depend on system fonts or a
# network fetch at runtime (that is why we do NOT use the google_fonts pkg).
#
#   Display : Clash Display  (Fontshare — ITF Free Font License)  400/500/600/700
#   Body/UI : Satoshi        (Fontshare — ITF Free Font License)  400/500/700/900
#   Utility : Space Mono     (Google Fonts — OFL)                 400/700
#
# Re-running is idempotent (overwrites). Commit the resulting .ttf files.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/assets/fonts"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$DEST"

echo "→ Clash Display + Satoshi (Fontshare)"
for slug in clash-display satoshi; do
  curl -sSL -m 60 -o "$TMP/$slug.zip" "https://api.fontshare.com/v2/fonts/download/$slug"
  unzip -qo "$TMP/$slug.zip" -d "$TMP/$slug"
done

# Fontshare static TTFs live under <Family>_Complete/Fonts/WEB/fonts/.
cp "$TMP"/clash-display/*/Fonts/WEB/fonts/ClashDisplay-Regular.ttf  "$DEST/ClashDisplay-Regular.ttf"
cp "$TMP"/clash-display/*/Fonts/WEB/fonts/ClashDisplay-Medium.ttf   "$DEST/ClashDisplay-Medium.ttf"
cp "$TMP"/clash-display/*/Fonts/WEB/fonts/ClashDisplay-Semibold.ttf "$DEST/ClashDisplay-Semibold.ttf"
cp "$TMP"/clash-display/*/Fonts/WEB/fonts/ClashDisplay-Bold.ttf     "$DEST/ClashDisplay-Bold.ttf"

cp "$TMP"/satoshi/*/Fonts/WEB/fonts/Satoshi-Regular.ttf "$DEST/Satoshi-Regular.ttf"
cp "$TMP"/satoshi/*/Fonts/WEB/fonts/Satoshi-Medium.ttf  "$DEST/Satoshi-Medium.ttf"
cp "$TMP"/satoshi/*/Fonts/WEB/fonts/Satoshi-Bold.ttf    "$DEST/Satoshi-Bold.ttf"
cp "$TMP"/satoshi/*/Fonts/WEB/fonts/Satoshi-Black.ttf   "$DEST/Satoshi-Black.ttf"

echo "→ Space Mono (Google Fonts)"
base="https://github.com/google/fonts/raw/main/ofl/spacemono"
curl -sSL -m 60 -o "$DEST/SpaceMono-Regular.ttf" "$base/SpaceMono-Regular.ttf"
curl -sSL -m 60 -o "$DEST/SpaceMono-Bold.ttf"    "$base/SpaceMono-Bold.ttf"

echo "✓ Fonts written to assets/fonts/:"
ls -1 "$DEST"/*.ttf | xargs -n1 basename
