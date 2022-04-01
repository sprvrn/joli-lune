[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class Position extends System
	__tostring: => return "position"
	onCreate: (x=0,y=0,z=0,r=0,sx=1,sy=1,ox=0,oy=0) =>
		@x,@y,@z,@r,@scalex,@scaley,@originx,@originy=x,y,z,r,sx,sy,ox,oy
	
	get: => @x+@originx+(@shakex or 0),@y+@originy+(@shakey or 0),@z,@r,@scalex,@scaley
	
	scale: (x=1,y=x) => @scalex,@scaley = x,y

	move: (x,y) =>
		collider = @entity.collider
		oldx,oldy = x,y
		if collider
			x,y = collider\move(x,y)
		@x,@y = x, y
		if oldx ~= @x and oldy ~= @y
			return true
		else
			return false

return Position