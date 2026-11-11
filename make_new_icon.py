from PIL import Image, ImageDraw
W=1024
img=Image.new("RGB",(W,W),(28,10,62))
draw=ImageDraw.Draw(img,"RGBA")
draw.rounded_rectangle([15,15,W-15,W-15],radius=45,fill=(38,18,85))
grid_left=45; grid_top=45; gap=14; cell=(W-grid_left*2-gap*3)//4
pattern=[[('down',False),('right',False),('right',False),('right',True)],[('up',False),('up',False),('right',False),('up',False)],[('left',True),('up',False),('up',False),('down',False)],[('right',False),('left',False),('up',False),('right',True)]]
def thin(cx,cy,d):
 col=(255,255,255); w=7; s=32; hs=18
 if d=='down':
  draw.line([(cx,cy-s),(cx,cy+s)],fill=col,width=w)
  draw.line([(cx,cy+s),(cx-hs,cy+s-hs)],fill=col,width=w)
  draw.line([(cx,cy+s),(cx+hs,cy+s-hs)],fill=col,width=w)
 elif d=='up':
  draw.line([(cx,cy+s),(cx,cy-s)],fill=col,width=w)
  draw.line([(cx,cy-s),(cx-hs,cy-s+hs)],fill=col,width=w)
  draw.line([(cx,cy-s),(cx+hs,cy-s+hs)],fill=col,width=w)
 elif d=='right':
  draw.line([(cx-s,cy),(cx+s,cy)],fill=col,width=w)
  draw.line([(cx+s,cy),(cx+s-hs,cy-hs)],fill=col,width=w)
  draw.line([(cx+s,cy),(cx+s-hs,cy+hs)],fill=col,width=w)
 else:
  draw.line([(cx+s,cy),(cx-s,cy)],fill=col,width=w)
  draw.line([(cx-s,cy),(cx-s+hs,cy-hs)],fill=col,width=w)
  draw.line([(cx-s,cy),(cx-s+hs,cy+hs)],fill=col,width=w)
for r in range(4):
 for c in range(4):
  x0=grid_left+c*(cell+gap); y0=grid_top+r*(cell+gap); x1=x0+cell; y1=y0+cell
  dirc,green=pattern[r][c]
  base=(52,168,80) if green else (255,190,0)
  draw.rounded_rectangle([x0,y0,x1,y1],radius=22,fill=base)
  if green:
   draw.rounded_rectangle([x0,y0,x1,y1],radius=22,outline=(255,255,255),width=4)
  thin((x0+x1)//2,(y0+y1)//2,dirc)
mask=Image.new("L",(W,W),0)
ImageDraw.Draw(mask).rounded_rectangle([0,0,W,W],radius=200,fill=255)
img.putalpha(mask)
bg=Image.new("RGB",(W,W),(28,10,62))
bg.paste(img,mask=img.split()[3])
bg.save("arrowpuzzle/assets/icon.png")
print("thin arrow icon ok")
