[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

SpriteRenderer = require "src.spriterenderer"
ShapeRenderer = require "src.shaperenderer"
TextRenderer = require "src.textrenderer"
BatchRenderer = require "src.batchrenderer"

import graphics from love

class Renderer extends System
	__tostring: => return "renderer"
	
	onCreate: (...) =>
		@list = {}
		@order = {}

		if #{...} > 0
			@\add "default", ...
	
	add: (name, ...) =>
		args = {...}
		if not functional.contains @order,name then table.insert @order,name

		if tostring(args[1]) == "sprite"
			@list[name] = SpriteRenderer @game, ...
		elseif type(args[1]) == "string"
			if args[1]=="rect" or args[1]=="circ" or args[1]=="line"
				@list[name] = ShapeRenderer @game, ...
			else
				@list[name] = TextRenderer @game, ...

		return @list[name]
	setCanvas: (width,height) =>
		@canvas = graphics.newCanvas(width,height)
		@\updateCanvas!

	remove: (name) =>
		render = @list[name]
		if render and render.rendertype == "sprite"
			render\removeFromBatch!
			
		@list[name] = nil
		table.remove_value @order, name

	removeCanvas: =>
		@canvas = nil

	updateCanvas: =>
		if @canvas
			graphics.setCanvas @canvas
			graphics.clear!

			x,y,z,r,sx,sy=@position\get!

			x-=@position.x
			y-=@position.y

			@\drawAllRenderer x,y,z,r,sx,sy 

			graphics.setCanvas!

	get: (name="default") => @list[name]

	setOrder: (...) => @order = {...}

	setOrderPosition: (name,new) =>
		table.insert(self.order, new, table.remove(self.order, table.index_of(self.order,name)))

	getDimensions: =>

	draw: (ox=0,oy=0) =>
		x,y,z,r,sx,sy=@position\get!
		x += ox
		y += oy

		if @canvas
			graphics.draw @canvas,x,y,r,sx,sy
		else
			@\drawAllRenderer x,y,z,r,sx,sy

	drawAllRenderer: (x,y,z,r,sx,sy) =>
		for o in *@order
			render = @list[o]
			if render and not render.hide
				render\draw @position, x,y,z,r,sx,sy

	update: (dt) =>
		for o in *@order
			render = @list[o]
			if render
				render\update dt

	onDestroy: =>
		for _,r in pairs @list
			if r.rendertype == "sprite"
				r\removeFromBatch!
