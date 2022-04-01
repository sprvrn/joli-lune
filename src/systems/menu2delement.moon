[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

MenuElement = require "src.systems.menuelement"

class Menu2dElement extends MenuElement
	__tostring: => return "menu2delement"

	updateElement: (dt,menu) =>
		for n in *@nexts
			if @input\pressed n.key
				if n.element
					menu\setCurrent menu.list[n.element[2]][n.element[1]]
					break
		if @activationKey and @input\pressed @activationKey
			if type(@method)=="function"
				if @entity.soundset
					if @entity.soundset.sources.act 
						@entity.soundset.sources.act\play!
				@method @
				
return Menu2dElement