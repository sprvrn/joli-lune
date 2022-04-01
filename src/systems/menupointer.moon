[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class MenuPointer extends System
	__tostring: => return "menupointer"
	onCreate: (ox=0,oy=0) =>
		@offsetx, @offsety = ox, oy

	setPosition: (element) =>
		@position.x = element.position.x + @offsetx
		@position.y = element.position.y + @offsety

return MenuPointer