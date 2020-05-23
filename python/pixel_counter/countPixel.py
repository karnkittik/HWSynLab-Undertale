from PIL import Image
myfile = 'messageImage_1590164390395.jpg' #1024*768px
im = Image.open(myfile, 'r') #read image
pix_val = list(im.getdata()) #get all pixels data(R,G,B) into list

def isBlack(RGB): #roughly check black pixel
    (R, G, B) = RGB
    averageRGB = (int(R)+int(G)+int(B))/3 #roughly average
    if averageRGB <= 10: return True # 10 is maximum avergae value that its pixel is still black
    else: return False

position_rgb = dict() #store pair of position and its w/b value
i = 0 #column counter
j = 0 #row counter
position_rgb[0] = list()
for y in range(4,768,8): #get center vertical pixel of each block
    if (y-4) % 128 == 0 and y!=4: #check if it is next character in the next row or not; each char contains 128px height
        j += 1 #next row
        if (j*16) not in position_rgb.keys():
            position_rgb[j*16] = list() #add new pair of position and pixel list which stores w/b
    for x in range(4,1024,8): #get center horizontal pixel of each block 
        if (x-4) % 64 == 0 and x!=4: #check if it is next character in the next column or not; each char contains 64px width
            i += 1 #next column
            if (i + (j*16)) not in position_rgb.keys():
                position_rgb[i + (j*16)] = list() #add new pair of position and pixel list which stores w/b
        if isBlack(pix_val[x + (1024*y)]):
            position_rgb[i + (j*16)].append("1") #add pixel value; black is 1
        else:
            position_rgb[i + (j*16)].append("0") #add pixel value; white is 0
    i = 0 #reset columns counter for the next row

f = open("undertale_ascii.txt", "w+")
for (k,v) in position_rgb.items():
    f.writelines(str(chr(k+32))+':'+"\n")
    for i in range(0,128,8):
        f.writelines("".join(v[i:i+8])+"\n")
f.close()