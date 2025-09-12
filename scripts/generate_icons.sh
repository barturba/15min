#!/bin/bash

# Icon Generation Script for 15min App
# This script regenerates all PNG icons and favicons from the SVG source
#
# Requirements:
# - rsvg-convert (brew install librsvg)
# - ImageMagick (brew install imagemagick)
#
# Usage: ./scripts/generate_icons.sh

set -euo pipefail

echo "🎨 Regenerating icons from SVG source..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBLIC_DIR="$REPO_ROOT/public"
SRC_SVG="$PUBLIC_DIR/icon.svg"

# Check dependencies
if ! command -v rsvg-convert &> /dev/null; then
    echo "❌ rsvg-convert not found. Install with: brew install librsvg"
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "❌ ImageMagick not found. Install with: brew install imagemagick"
    exit 1
fi

# Validate source
if [[ ! -f "$SRC_SVG" ]]; then
    echo "❌ Source SVG not found at $SRC_SVG"
    exit 1
fi

# Create temp directory for favicon generation
TEMP_DIR="/tmp/icon_generation_$$"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Generate main PNG icons with transparency
echo "📱 Generating main PNG icons..."
rsvg-convert -h 512 -w 512 --background-color=none "$SRC_SVG" -o "$PUBLIC_DIR/icon.png"
rsvg-convert -h 192 -w 192 --background-color=none "$SRC_SVG" -o "$PUBLIC_DIR/icon-192.png"

# Generate favicon sizes with transparency
echo "🎯 Generating favicon sizes..."
rsvg-convert -h 16 -w 16 --background-color=none "$SRC_SVG" -o "$TEMP_DIR/favicon-16.png"
rsvg-convert -h 32 -w 32 --background-color=none "$SRC_SVG" -o "$TEMP_DIR/favicon-32.png"
rsvg-convert -h 48 -w 48 --background-color=none "$SRC_SVG" -o "$TEMP_DIR/favicon-48.png"

# Combine into favicon.ico with transparency preserved
echo "🔗 Creating favicon.ico..."
magick -background transparent "$TEMP_DIR/favicon-16.png" "$TEMP_DIR/favicon-32.png" "$TEMP_DIR/favicon-48.png" "$PUBLIC_DIR/favicon.ico"

# Verify generation
echo ""
echo "✅ Icon generation complete!"
echo ""
echo "${BLUE}Generated files:${NC}"
echo "  📄 $PUBLIC_DIR/icon.png (512x512)"
echo "  📄 $PUBLIC_DIR/icon-192.png (192x192)"
echo "  🎯 $PUBLIC_DIR/favicon.ico (16x16, 32x32, 48x48)"
echo ""
echo "${GREEN}Features:${NC}"
echo "  🟢 Transparent background"
echo "  🟢 Bright matrix green border: #00ff41"
echo "  🟢 Electric lime clock hand: #39ff14"
echo ""
echo "🎉 All icons regenerated with transparency!"
