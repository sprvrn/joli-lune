[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class Menu extends System
	__tostring: => return "menu"

	onCreate: =>
		@list = {}
		@pointer = nil
		@current = nil

	setList: (...) =>
		t = {...}
		scene = @entity.scene
		layer = @entity.layer.name
		for i = 1,#t
			@\addElement t[i]

		if #@list>=1
			@\setCurrent @list[1]

	setKeys: (navkeys,activationKey) =>
		@activationKey = activationKey
		@navkeys = navkeys

	addElement: (element, ...) =>
		scene = @entity.scene
		layer = @entity.layer.name

		element.activationKey = @activationKey

		entityElement = scene\newEntity element.label or "menu_element_entity",element.position.x + @position.x,element.position.y + @position.y,element.z, layer
		entityElement\addSystem "MenuElement",element,@

		if @isClickable then entityElement.menuelement\clickable @clickableSystem, ...

		element.systems = element.systems or {}

		if element.systems
			for system in *element.systems
				entityElement\addSystem system, entityElement.menuelement, ...

		table.insert @list, entityElement.menuelement

		@\setNexts!

		return entityElement.menuelement

	setPointer: (ox=0,oy=0,...) =>
		scene = @entity.scene
		layer = @entity.layer.name

		entitypointer = scene\newEntity "pointer",@position.x,@position.y,@position.z-1,layer
		entitypointer\addSystem "MenuPointer", ox, oy
		@pointer = entitypointer.menupointer

		args = {...}
		if #args > 0 
			entitypointer\addSystem "Renderer", ...  
		
	clickable: (system="MenuClickable") =>
		@isClickable = true
		@clickableSystem = system

		for element in *@list
			element\clickable system

	setCurrent: (element) =>
		if not @current
			return

		if @current.entity.renderer
			if render = @current.entity.renderer\get!
				if render.rendertype == "text"
					render\setStyle @current.style

		if type(@current.onquit) == "function"
			@current.onenter(@current)

		@current = element

		if type(@current.onenter) == "function"
			@current.onenter(@current)

		if @pointer
			@pointer\setPosition(@current)

		if @current.entity.soundset
			if @current.entity.soundset.sources.nav
				@current.entity.soundset.sources.nav\play!

		if @current.entity.renderer
			if render = @current.entity.renderer\get!
				if render.rendertype == "text"
					render\setStyle @current.hoverstyle or @current.style or "main"

	update: (dt) =>
		if tostring(@current) == "menuelement" or tostring(@current) == "menu2delement"
			@current\updateElement dt,@

    onDestroy: => @\remove!

	remove: =>
		if @pointer
			@entity.scene\removeEntity @pointer.entity
		for _,e in pairs @list
			@entity.scene\removeEntity e.entity

	setNexts: =>
		if @navkeys
			for k,element in pairs @list
				element.nexts = {}

				prv = if k-1 < 1 then #@list else k-1
				nxt = if k+1 > #@list then 1 else k+1

				element\add(@navkeys[1],nxt)
				element\add(@navkeys[2],prv)

return Menu


		
