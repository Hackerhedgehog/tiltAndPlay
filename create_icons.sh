#!/bin/bash
# Create minimal valid PNG icons for all densities
# This is a 1x1 blue pixel PNG (minimal valid PNG)

for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    mkdir -p "android/app/src/main/res/mipmap-${density}"
    # Minimal valid 1x1 blue PNG
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\tpHYs\x00\x00\x0b\x13\x00\x00\x0b\x13\x01\x00\x9a\x9c\x18\x00\x00\x00\nIDATx\x9cc\xf8\x00\x00\x00\x01\x00\x01\x00\x00\x00\x00IEND\xaeB`\x82' > "android/app/src/main/res/mipmap-${density}/ic_launcher.png"
    cp "android/app/src/main/res/mipmap-${density}/ic_launcher.png" "android/app/src/main/res/mipmap-${density}/ic_launcher_foreground.png"
    cp "android/app/src/main/res/mipmap-${density}/ic_launcher.png" "android/app/src/main/res/mipmap-${density}/ic_launcher_round.png"
done
echo "Icons created successfully"
