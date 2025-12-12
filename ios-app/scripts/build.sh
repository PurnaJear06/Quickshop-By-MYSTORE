#!/bin/bash

# Create build directory
mkdir -p build

# Compile all Swift files in one go
swiftc -emit-executable \
  -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  -target arm64-apple-ios16.0-simulator \
  -L $(xcrun --show-sdk-platform-path)/Developer/Library/Frameworks \
  -F $(xcrun --show-sdk-platform-path)/Developer/Library/Frameworks \
  -I $(xcrun --show-sdk-platform-path)/Developer/Library/Frameworks \
  -L $(xcrun --show-sdk-path --sdk iphonesimulator)/System/Library/Frameworks \
  -F $(xcrun --show-sdk-path --sdk iphonesimulator)/System/Library/Frameworks \
  -I $(xcrun --show-sdk-path --sdk iphonesimulator)/System/Library/Frameworks \
  $(find "OuickShop by Mystore" -name "*.swift") \
  -o build/OuickShopApp

echo "Build completed in build/OuickShopApp"
