[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

Menu = require "src.systems.menu"

class Menu2d extends Menu
	__tostring: => return "menu2d"
	clickable: =>
		for line in *@list
			for element in *line
				element.entity\addSystem "Collider",element.width,element.height
				element.entity\addSystem "MenuClickable"

	setList: (...) =>
		t = ...
		scene = @entity.scene
		layer = @entity.layer.name

		for y = 1, #t
			line = t[y]
			@list[y] = {}

			nxtY = y+1
			if nxtY > #t
				nxtY = 1
			prvY = y-1
			if prvY < 1
				prvY = #t

			for x = 1, #line
				element = line[x]
				element.activationKey = @activationKey

				nxtX = x+1
				if nxtX > #line
					nxtX = 1
				prvX = x-1
				if prvX < 1
					prvX = #line

				entityElement = scene\newEntity element.label,element.position.x + @position.x,element.position.y + @position.y,element.z, layer
				entityElement\addSystem "Menu2dElement",element,@
				if type(@navkeys)=="table"
					entityElement.menu2delement\add(@navkeys[1],{nxtX,y})
					entityElement.menu2delement\add(@navkeys[2],{prvX,y})
					entityElement.menu2delement\add(@navkeys[3],{x,prvY})
					entityElement.menu2delement\add(@navkeys[4],{x,nxtY})

					@list[y][x] = entityElement.menu2delement

		if #@list>1 and type(@list[1])=="table" and #@list[1]>1
			@\setCurrent @list[1][1]

return Menu2d