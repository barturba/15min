#!/bin/bash

# Icon Generation Script for 15min App
# This script regenerates all PNG icons and favicons from the SVG source
#
# Requirements:
# - rsvg-convert (brew install librsvg)
# - ImageMagick (brew install imagemagick)
#
# Usage: ./scripts/generate_icons.sh

set -e

echo "🎨 Regenerating icons from SVG source..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check dependencies
if ! command -v rsvg-convert &> /dev/null; then
    echo "❌ rsvg-convert not found. Install with: brew install librsvg"
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "❌ ImageMagick not found. Install with: brew install imagemagick"
    exit 1
fi

# Create temp directory for favicon generation
TEMP_DIR="/tmp/icon_generation_$$"
mkdir -p "$TEMP_DIR"

# Generate main PNG icons with transparency
echo "📱 Generating main PNG icons..."
rsvg-convert -h 512 -w 512 --background-color=none public/icon.svg -o public/icon.png
rsvg-convert -h 192 -w 192 --background-color=none public/icon.svg -o public/icon-192.png

# Generate favicon sizes with transparency
echo "🎯 Generating favicon sizes..."
rsvg-convert -h 16 -w 16 --background-color=none public/icon.svg -o "$TEMP_DIR/favicon-16.png"
rsvg-convert -h 32 -w 32 --background-color=none public/icon.svg -o "$TEMP_DIR/favicon-32.png"
rsvg-convert -h 48 -w 48 --background-color=none public/icon.svg -o "$TEMP_DIR/favicon-48.png"

# Combine into favicon.ico with transparency preserved
echo "🔗 Creating favicon.ico..."
magick -background transparent "$TEMP_DIR/favicon-16.png" "$TEMP_DIR/favicon-32.png" "$TEMP_DIR/favicon-48.png" public/favicon.ico

# Cleanup
rm -rf "$TEMP_DIR"

# Verify generation
echo ""
echo "✅ Icon generation complete!"
echo ""
echo "${BLUE}Generated files:${NC}"
echo "  📄 public/icon.png (512x512)"
echo "  📄 public/icon-192.png (192x192)"
echo "  🎯 public/favicon.ico (16x16, 32x32, 48x48)"
echo ""
echo "${GREEN}Features:${NC}"
echo "  🟢 Transparent background"
echo "  🟢 Bright matrix green border: #00ff41"
echo "  🟢 Electric lime clock hand: #39ff14"
echo ""
echo "🎉 All icons regenerated with transparency!"
