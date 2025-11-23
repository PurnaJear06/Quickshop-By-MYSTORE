#!/bin/bash

# Source and destination paths
SOURCE_ICON="/Users/purnajear/Downloads/Project/OuickShop by Mystore/Images/ChatGPT Image May 8, 2025, 01_27_57 AM.png"
OUTPUT_DIR1="/Users/purnajear/Downloads/Project/OuickShop by Mystore/OuickShop by Mystore/Assets.xcassets/AppIcon.appiconset"
OUTPUT_DIR2="/Users/purnajear/Downloads/Project/OuickShop by Mystore/Assets.xcassets/AppIcon.appiconset"
OUTPUT_DIR3="/Users/purnajear/Downloads/Project/OuickShop by Mystore/OuickShop by Mystore/OuickShop by Mystore/Assets.xcassets/AppIcon.appiconset"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Source icon not found: $SOURCE_ICON"
    exit 1
fi

# Check if output directories exist
for DIR in "$OUTPUT_DIR1" "$OUTPUT_DIR2" "$OUTPUT_DIR3"; do
    if [ ! -d "$DIR" ]; then
        echo "Creating directory: $DIR"
        mkdir -p "$DIR"
    fi
done

# Function to create an icon of specified size
create_icon() {
    local size=$1
    local filename=$2
    
    echo "Creating icon: $filename ($size x $size)"
    
    # Create temporary file
    local temp_file="/tmp/temp_icon_$size.png"
    sips -z $size $size "$SOURCE_ICON" --out "$temp_file"
    
    # Copy to all output directories
    for DIR in "$OUTPUT_DIR1" "$OUTPUT_DIR2" "$OUTPUT_DIR3"; do
        cp "$temp_file" "$DIR/$filename"
        echo "Copied to $DIR/$filename"
    done
    
    # Remove temporary file
    rm "$temp_file"
}

# Clean up existing icons
echo "Cleaning existing app icons..."
for DIR in "$OUTPUT_DIR1" "$OUTPUT_DIR2" "$OUTPUT_DIR3"; do
    rm -f "$DIR"/*.png
done

# Generate all icon sizes
echo "Generating app icons..."

# iPhone icons
create_icon 40 "AppIcon-20x20@2x.png"
create_icon 60 "AppIcon-20x20@3x.png"
create_icon 58 "AppIcon-29x29@2x.png"
create_icon 87 "AppIcon-29x29@3x.png"
create_icon 80 "AppIcon-40x40@2x.png"
create_icon 120 "AppIcon-40x40@3x.png"
create_icon 120 "AppIcon-60x60@2x.png"
create_icon 180 "AppIcon-60x60@3x.png"

# iPad icons
create_icon 20 "AppIcon-20x20.png"
create_icon 29 "AppIcon-29x29.png"
create_icon 40 "AppIcon-40x40.png"
create_icon 76 "AppIcon-76x76.png"
create_icon 152 "AppIcon-76x76@2x.png"
create_icon 167 "AppIcon-83.5x83.5@2x.png"

# App Store icon
create_icon 1024 "AppIcon-1024.png"

# Create Contents.json in all directories
for DIR in "$OUTPUT_DIR1" "$OUTPUT_DIR2" "$OUTPUT_DIR3"; do
    if [ ! -f "$DIR/Contents.json" ]; then
        echo "Creating Contents.json in $DIR"
        cp "$OUTPUT_DIR1/Contents.json" "$DIR/Contents.json"
    fi
done

echo "App icons generated successfully!"
echo "Cleaning build directory..."
rm -rf build

echo "Done!" 