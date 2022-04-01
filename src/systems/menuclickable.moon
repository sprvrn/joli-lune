[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class MenuClickable extends System
	__tostring: => return "menuclickable"

	onLeftClick: =>
		element = @entity.menuelement
		if element then element\activate!

	hoverEnter: =>
		if element = @entity.menuelement
			element.menu\setCurrent element

return MenuClickable