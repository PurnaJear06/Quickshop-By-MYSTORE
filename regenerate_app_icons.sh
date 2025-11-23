#!/bin/bash

# Source and destination paths
SOURCE_ICON="/Users/purnajear/Downloads/Project/OuickShop by Mystore/Images/ChatGPT Image May 8, 2025, 01_27_57 AM.png"
OUTPUT_DIR="/Users/purnajear/Downloads/Project/OuickShop by Mystore/OuickShop by Mystore/Assets.xcassets/AppIcon.appiconset"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Source icon not found: $SOURCE_ICON"
    exit 1
fi

# Check if output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Output directory not found: $OUTPUT_DIR"
    exit 1
fi

# Function to create an icon of specified size
create_icon() {
    local size=$1
    local output_path=$2
    
    echo "Creating icon: $output_path ($size x $size)"
    sips -Z $size "$SOURCE_ICON" --out "$output_path"
}

# Clean up existing icons
echo "Cleaning existing app icons..."
find "$OUTPUT_DIR" -name "*.png" -type f -delete

echo "Generating all required app icon sizes..."

# iPhone icons
create_icon 40 "$OUTPUT_DIR/AppIcon-20x20@2x.png"
create_icon 60 "$OUTPUT_DIR/AppIcon-20x20@3x.png"
create_icon 58 "$OUTPUT_DIR/AppIcon-29x29@2x.png"
create_icon 87 "$OUTPUT_DIR/AppIcon-29x29@3x.png"
create_icon 80 "$OUTPUT_DIR/AppIcon-40x40@2x.png"
create_icon 120 "$OUTPUT_DIR/AppIcon-40x40@3x.png"
create_icon 120 "$OUTPUT_DIR/AppIcon-60x60@2x.png"
create_icon 180 "$OUTPUT_DIR/AppIcon-60x60@3x.png"

# iPad icons
create_icon 20 "$OUTPUT_DIR/AppIcon-20x20.png"
create_icon 29 "$OUTPUT_DIR/AppIcon-29x29.png"
create_icon 40 "$OUTPUT_DIR/AppIcon-40x40.png"
create_icon 76 "$OUTPUT_DIR/AppIcon-76x76.png"
create_icon 152 "$OUTPUT_DIR/AppIcon-76x76@2x.png"
create_icon 167 "$OUTPUT_DIR/AppIcon-83.5x83.5@2x.png"

# App Store icon
create_icon 1024 "$OUTPUT_DIR/AppIcon-1024.png"

echo "App icons generation complete!" 