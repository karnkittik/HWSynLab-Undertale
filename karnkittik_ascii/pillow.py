from PIL import Image
img = "karnkittik_ascii/IMG_2514.JPG"
img = Image.open(img);
f = open("karnkittik_ascii/myfile2.txt", "w")
for y in range(0,img.height,8):
    count = ""
    for x in range(0,img.width,8):
        pixel = img.getpixel((x, y))
        if pixel <= (100,100,100):
            count += "1"  
        else:
            count += "0"
        # count += str(pixel)
    count += "\n"
    f.write(count)
f.close()