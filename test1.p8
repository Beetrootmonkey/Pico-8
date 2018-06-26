pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--pacman clone
--by beetrootmonkey
p={}
enemies={}
dbm=0
espd=1
pspd=1

-- intersect(point,rect)
function ints(p,r)
  return p.x >= r.x1 and p.x <= r.x2 and p.y >= r.y1 and p.y <= r.y2
end
function ecoll(e1,e2)
  for i=1,3 do
    local p1e1=getec(e1,i)
    local p1e2=getec(e2,0)
    local p2e2=getec(e2,2)
    if ints(p1e1,{x1=p1e2.x,y1=p1e2.y,x2=p2e2.x,y2=p2e2.y}) then
      return true
    end
  end
  return false
end
-- cancornermove(entity,cornerindex,direction)
function ccm(e,i,d)
  local ox=getec(e,i).x+d2dv(d).x
  local oy=getec(e,i).y+d2dv(d).y
  local tpos=p2t(ox,oy)
  local f=not fget(mget(tpos.x, tpos.y),0)
  return f
end

function coll(i,f)
  local tpos=p2t(getec(p,i).x,getec(p,i).y)
  return fget(mget(tpos.x, tpos.y),f)
end

function ccoll(f)
  for i=0,3 do
    if not coll(i,f) then
      return false
    end
  end
  return true
end

function collect()
  if ccoll(1) then
    local pos=p2t(p.x,p.y)
    mset(pos.x,pos.y,0)
    p.sc+=1
    sfx(0,0,0,2)
  end
  if ccoll(2) then
    local pos=p2t(p.x,p.y)
    mset(pos.x,pos.y,0)
    p.sc+=5
    sfx(1,1,0,9)
  end
  if ccoll(3) then
    local pos=p2t(p.x,p.y)
    mset(pos.x,pos.y,0)
    p.sc+=10
  end
end
-- canmoveentity(entity)
function cm(e)
  return cmd(e,e.d)
end
-- canmoveentityindirection(entity,direction)
function cmd(e,d)
  for i=0,3 do
    if not ccm(e,i,d) then
      return false
    end
  end
  return true
end

function p2t(i,j)
  return {x=flr(i/8),y=flr(j/8)}
end

function t2p(i,j)
  return {x=i*8,y=j*8}
end

function d2dv(d)
  local dir = {}
  dir.x=0
  dir.y=0
  if d==0 then dir.x=1 end
  if d==1 then dir.y=1 end
  if d==2 then dir.x=-1 end
  if d==3 then dir.y=-1 end
  return dir
end

function d2pos(x, y, d)
  return {x=x+d2dv(d).x,y=y+d2dv(d).y}
end

function setdir(e,d)
  if cmd(e,d) then e.d=d end
end

-- teleport2tile(entity,x,y)
function tp2t(e,i,j)
  local t=t2p(i,j)
  e.x=t.x
  e.y=t.y
end
-- moveplayer()
function mvp()
  if cm(p) then
    p.x+=d2dv(p.d).x*pspd
    p.y+=d2dv(p.d).y*pspd
    p.a+=0.5
    p.a%=2
  end

  p.x%=129
  p.y%=129
end
-- moveenemy(enemy)
function mve(e)
  if cm(e) then
    e.x+=d2dv(e.d).x*espd
    e.y+=d2dv(e.d).y*espd
    e.a+=0.5
    e.a%=2
  end

  e.x%=128
  e.y%=128
end

function turne(e)
  local dirs=getvdb(e)
  if #dirs>0 then
    local r=flr(rnd(#dirs))+1
    e.d=dirs[r]
  else
    e.d=(e.d+2)%4
  end
end
-- getvaliddirections(entity)
function getvd(e)
  local dirs={}
  for d=0,3 do
    if cmd(e,d) then
      dirs[#dirs+1]=d
    end
  end
  return dirs
end
-- getvaliddirectionswithoutback(entity)
function getvdb(e)
  local dirs={}
  for d=0,3 do
    if cmd(e,d) and not (d==(e.d+2)%4) then
      dirs[#dirs+1]=d
    end
  end
  return dirs
end
--
function isvd(e,d)
  local dirs=getvd(e)
  for i=1,#dirs do
    if d==dirs[i] then
      return true
    end
  end
  return false
end
-- canentitygoleft
function cml(e)
  local d=e.d+3%4
  return isvd(e,d)
end
-- canentitygoright
function cmr(e)
  local d=e.d+1%4
  return isvd(e,d)
end
-- canentitygoback
function cmb(e)
  local d=e.d+1%4
  return isvd(e,d)
end

function getec(e,i)
  local c={}
  c[0]={x=e.x,y=e.y}
  c[1]={x=e.x+7,y=e.y}
  c[2]={x=e.x+7,y=e.y+7}
  c[3]={x=e.x,y=e.y+7}
  return c[i]
end

function fill(n,l)
  local diff=l-#tostr(n)
  if diff<=0 then return n end
  local s=""
  for i=1,diff do
    s=s.."0"
  end
  s=s..n
  return s
end

-- randomtile(spriteindex)
function rndt(t)
  local tiles={}
  for j=0,15 do
    for i=0,15 do
      if mget(i,j)==t then
        tiles[#tiles+1]={x=i,y=j}
      end
    end
  end
  local r=flr(rnd(#tiles))+1
  return tiles[r]
end

-- findalltiles(spriteindex)
function fat(t)
  local tiles={}
  for j=0,15 do
    for i=0,15 do
      if mget(i,j)==t then
        tiles[#tiles+1]={x=i,y=j}
      end
    end
  end
  return tiles
end

-- replacealltiles(spriteindex1,spriteindex2)
function rpat(a,b)
  for j=0,15 do
    for i=0,15 do
      if mget(i,j)==a then
        mset(i,j,b)
      end
    end
  end
end

function initplayer()
  local s=rndt(51)
  rpat(51,2)
  tp2t(p,s.x,s.y)
  p.d=0
  p.a=0
  p.sc=0
  p.snd=0
end

function initenemies()
  local tiles=fat(40)
  for i=1,#tiles do
    local e={}
    enemies[#enemies+1]=e
    tp2t(e,tiles[i].x,tiles[i].y)
    e.d=0
    e.a=0
    e.dead=false
  end
  rpat(40,2)
end
-- drawplayer()
function drawp()
  local tpos=p2t(p.x,p.y)
  spr(4+p.d+flr(p.a)*16,p.x,p.y)
  if dbm==1 then
    for j=0,3 do
      local c=7
      if(not ccm(p,j,p.d)) c=8
      pset(getec(p,j).x,getec(p,j).y,c)
    end
  end
end
-- drawenemy(enemy)
function drawe(e)
  local tpos=p2t(e.x,e.y)
  if not e.dead then
    spr(36+e.d+flr(e.a)*16,e.x,e.y)
  else
    spr(1,e.x,e.y)
  end
  if dbm==1 then
    for j=0,3 do
      local c=7
      if (not ccm(e,j,e.d)) c=8
      pset(getec(e,j).x,getec(e,j).y,c)
    end
    local c=7
    if (ecoll(p,e)) c=8
    print(c==8,e.x,e.y-8,c)
  end
end

function _init()
  camera(4,4)
  initplayer()
  initenemies()
end

function _update()
	if btn(➡️) then setdir(p,0) end
  if btn(⬇️) then setdir(p,1) end
  if btn(⬅️) then setdir(p,2) end
  if btn(⬆️) then setdir(p,3) end


  mvp()
  for i=1,#enemies do
    if ecoll(p,enemies[i]) then
      enemies[i].dead=true
    end
    turne(enemies[i])
    mve(enemies[i])
  end
  collect()
end

function _draw()
  cls()
  map(0,0,0,0,20,20)
  for i=1,#enemies do
    drawe(enemies[i])
  end
  drawp()
  print(fill(p.sc,7),18,17,7)

end


__gfx__
0000000000000000000000000000000000aaaa0000aaaa0000aaaa00000000001000000011111111000000000000000000000000000000000000000000000000
000000000000000000000000000000000aaaaaa00aaaaaa00aaaaaa00a7007a01000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000bbbb00aa007070aa0ee0aa070700aaaa0000aa1000000000000000000000000000000000000000000000000000000000000000
00000000000000000009900000bbbb00aa000000aa0ee0aa000000aaaa7007aa1000000000000000000000000000000000000000000000000000000000000000
00000000000000000009900000bbbb00aa000000aa7007aa000000aaaa0000aa1000000000000000000000000000000000000000000000000000000000000000
00000000007007000000000000bbbb00aaee7070aa0000aa0707eeaaaa0ee0aa1000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000aaaaaa00a7007a00aaaaaa00aaaaaa01000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000aaaa000000000000aaaa0000aaaa001000000000000000000000000000000000000000000000000000000000000000
011111100111111111111111111111100000000000aaaa0000000000000000000000000000000001000000000000000000000000000000000000000000000000
100000011000000000000000000000010aaaaa000aaaaaa000aaaaa000a77a000000000000000001000000000000000000000000000000000000000000000000
10000001100000000000000000000001aaaaaaa00aaeeaa00aaaaaaa0aa00aa00000000000000001000000000000000000000000000000000000000000000000
10000001100000000000000000000001aa0070700aaeeaa0070700aa0aa77aa00000000000000001000000000000000000000000000000000000000000000000
10000001100000000000000000000001aaee70700aa77aa00707eeaa0aa00aa00000000000000001000000000000000000000000000000000000000000000000
10000001100000000000000000000001aaaaaaa00aa00aa00aaaaaaa0aaeeaa00000000000000001000000000000000000000000000000000000000000000000
100000011000000000000000000000010aaaaa0000a77a0000aaaaa00aaaaaa00000000000000001000000000000000000000000000000000000000000000000
1000000101111111111111111111111000000000000000000000000000aaaa001111111100000001000000000000000000000000000000000000000000000000
10000001011111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000110000000000000010004330000cccc0000cccc0000cccc0000cccc00005cccc000000000000000000000000000000000000000000000000000000000
100000011000000000000001000400000cccccc00cccccc00cccccc00cccccc0005cccc000000000000000000000000000000000000000000000000000000000
100000011000000000000001008888000cccccc00cccccc00cccccc00cccccc0005cccc000000000000000000000000000000000000000000000000000000000
100000011000000000000001008888000cc7cc700cccccc007cc7cc00cccccc00050000000000000000000000000000000000000000000000000000000000000
100000011000000000000001008888000cccccc00c7cc7c00cccccc00cccccc00050000000000000000000000000000000000000000000000000000000000000
100000011000000000000001008888000cccccc00cccccc00cccccc00cccccc00050000000000000000000000000000000000000000000000000000000000000
100000011000000000000001000000000c0cc0c00c0cc0c00c0cc0c00c0cc0c00000000000000000000000000000000000000000000000000000000000000000
10000001100000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005aaaa000cccc0000cccc0000cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005aaaa00cccccc00cccccc00cccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005aaaa00cccccc00cccccc00cccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005000000cc7cc700cccccc007cc7cc00cccccc00000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005000000cccccc00c7cc7c00cccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000
100000011000000000000001005000000cccccc00cccccc00cccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000
0111111001111111111111100000000000c00c0000c00c0000c00c0000c00c000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000020400000000010100000000000001010101000000000101000000000000010101080000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2112121212121212121302211212121222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2003020202020202020202200202020320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002211212130211220211181302100220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002200202020202200202020202200220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3002311302112202311302111212320230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202022002280202280202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2113022113023112130221121302111222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002022002020202020220020202020220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002113202111212220230022112130220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028020202280202300202282002020220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0812121302112202020211121812121219000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002020202023112130202020202020220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002211213020202020221121302100220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002200202021002211219020202200220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2002300211123202303330021112320220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2003020202020202020202020202020320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3112121212121212121302111212121232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400000153014530145000d5001450021500305000000000000000002f1002f1002e1002e100000000000000000262002620025200242002420000000000000000000000000000000000000000000000000000
00060000015100d5301555004510105301a5500751015530215500170001700017000170001700017000170001700017000170001700017000170001700017000170001700017000170001700017000170001700
001100000ca501ca001ba001ba0014a501aa0019a0019a000ca5016a0016a0015a0014a500ba002aa0016a000ca5018a0009a001aa0014a500ca000ca000ca000ca500ca000ca000ca0014a500ca000ca000ca00
__music__
00 40424344
