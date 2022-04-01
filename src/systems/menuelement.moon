[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class MenuElement extends System
	__tostring: => return "menuelement"

	onCreate: (data, menu) =>
		@menu = menu

		@nexts = {}

		for property,value in pairs data
			@[property] = value

		@width = @width or 1
		@height = @height or 1

		@entity\addSystem "Renderer"

		if type(data.renderers) == "table"
			with @entity.renderer
				for i, renderer in pairs data.renderers
					\add "menu_element_" .. i, unpack(renderer)

		if data.sprite
			@entity.renderer\add "menu_element_sprite", data.sprite, data.anim

		if type(@label) == "string"
			@entity.renderer\add "menu_element_text", @label, data.style, data.width, data.align

		with @entity\addSystem "SoundSet"
			if data.navsound
				\addSource "nav", data.navsound
			if data.actsound
				\addSource "act", data.actsound

	add: (key, element) => table.insert @nexts,{:key, :element}

	remove: =>
		table.remove @menu.list, table.index_of @menu.list, @
		@entity\destroy!
		@menu\setNexts!

	activate: =>
		if type(@method)=="function"
			if @entity.soundset
				if @entity.soundset.sources.act 
					@entity.soundset.sources.act\play!
			@method @

	updateElement: (dt,menu) =>
		for n in *@nexts
			if @input\pressed n.key
				if n.element
					menu\setCurrent menu.list[n.element]
					break
		if @activationKey and @input\pressed @activationKey
			@\activate!

	clickable: (system) =>
		with @entity
			\addSystem "Collider",@width,@height
			\addSystem system


return MenuElement