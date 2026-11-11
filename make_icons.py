from PIL import Image
import os
src='arrowpuzzle/assets/icon.png'
sizes={'mipmap-mdpi':48,'mipmap-hdpi':72,'mipmap-xhdpi':96,'mipmap-xxhdpi':144,'mipmap-xxxhdpi':192}
for k,v in sizes.items():
    d=f'arrowpuzzle/android/app/src/main/res/{k}'
    os.makedirs(d, exist_ok=True)
    Image.open(src).resize((v,v)).save(f'{d}/ic_launcher.png')
print('icons done')
