[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

import graphics from love

class TiledMapLayer extends System
	__tostring: => return "tiledmaplayer"

	onCreate: (layer) => @layer = layer

	update: (dt) => @layer\update dt

	draw: =>
		x,y = @position\get!
		graphics.push!
		graphics.translate x, y
		@layer\draw!
		graphics.pop!
		
return TiledMapLayer