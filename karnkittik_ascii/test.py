from PIL import Image
img = "/Users/karnkittik/Desktop/HWSynLab-Undertale/IMG_2514.JPG"
img = Image.open(img);
count = ""
for y in range(img.height):
    for x in range(img.width):
        pixel = img.getpixel((x, y))
        if pixel <= 100:
            count += "1"  
        else:
            count += "0"
    count += "\n"
print(count)