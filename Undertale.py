f = open("./Undertale_ascii.txt", "r")
data =  f.readlines()
character = [" ","!",'"',"#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",\
";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~"," "]
character = [[e,""] for e in character]
for c in range(6):  
    for j in range(16):
        k=8
        for i in range (0,16):
            character[(c*16)+i][1] = character[(c*16)+i][1]+ data[(c*16)+j][k-8:k].strip()+"\n"
            k+=8
f.close()
f = open("myfile.txt", "w")
for a in character:
    out = a[0]+":\n"+a[1]
    f.write(out)
f.close()
# https://www.dcode.fr/binary-image