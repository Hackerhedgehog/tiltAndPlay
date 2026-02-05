#!/usr/bin/env python3
import os
import base64

# Minimal valid 1x1 blue PNG (base64 encoded)
PNG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
PNG_DATA = base64.b64decode(PNG_BASE64)

# Create icons for all densities
densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']
icon_names = ['ic_launcher.png', 'ic_launcher_foreground.png', 'ic_launcher_round.png']

for density in densities:
    dir_path = f'android/app/src/main/res/mipmap-{density}'
    os.makedirs(dir_path, exist_ok=True)
    
    for icon_name in icon_names:
        file_path = os.path.join(dir_path, icon_name)
        with open(file_path, 'wb') as f:
            f.write(PNG_DATA)
        print(f'Created: {file_path}')

print('All icons created successfully!')
