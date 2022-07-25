[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

lg = love.graphics

class Collider extends System
	__tostring: => return "collider"
	onCreate: (w=1,h=w,solid,ox=0,oy=0) =>
		@ox,@oy = ox,oy

		@\updatePosition!

		@w,@h = w,h
		@solid = solid

		if not @entity.scene.world
			@entity.scene\createPhysicWorld!
		@entity.scene\addCollider(@)

		@collide = {up:nil,down:nil,left:nil,right:nil}
		@hidecollider = true
		@mousehover = false
		@doubleclick = false
		@prevFrameCol = {}

		@dragable = false

	move: (x,y) =>
		ax, ay, cols, len = @entity.scene.world\move @,x,y,(item,other)->
			if other.solid
				return "slide"
			return "cross"
		@collide = {up:nil,down:nil,left:nil,right:nil}
		if len ~= 0
			for i = 1, len
				c = cols[i]
				if c.normal.y == -1
					@collide.down = c.other
				if c.normal.y == 1
					@collide.up = c.other
				if c.normal.x == -1
					@collide.right = c.other
				if c.normal.x == 1
					@collide.left = c.other

		return ax, ay

	updatePosition: =>
		@x = @position.x + @ox
		@y = @position.y + @oy

	onDestroy: =>
		@entity.scene.world\remove(@)

	update: (dt) =>
		@\updatePosition!

		world = @entity.scene.world

		if not world\hasItem(@)
			return

		world\update @,@x,@y,@w,@h

		if @draged
			mx, my = @entity.scene.cameras.main\mousePosition!
			@position\move mx - (@w / 2),my - (@h / 2)


		systems = @entity.systems
		if @mousehover
			if not @lastframehover
				for _,c in pairs systems
					c\hoverEnter!
				@lastframehover=true
			for _,c in pairs systems
				c\hover!

			if @game.input\pressed "leftclick"
				if @doubleclick
					for _,c in pairs systems
						c\onDoubleClick!
				for _,c in pairs systems
					c\onLeftClick!
					@doubleclick=true
					@\cron "after",.2,()->@doubleclick=false
					if @dragable
						@draged = true
						c\onDragInit @x, @y
			if @game.input\pressed "rightclick"
				for _,c in pairs systems
					c\onRightClick!
					if @draged
						@draged = false
						c\onDragDrop @x, @y
			if @game.input\pressed "middleclick"
				for _,c in pairs systems
					c\onMiddleClick!
			if @game.input\down "leftclick"
				for _,c in pairs systems
					c\onLeftClickHold!
			if @game.input\released "leftclick"
				for _,c in pairs systems
					c\onLeftClickUp!
					if @draged
						c\onDragDrop @x, @y
				if @draged then @draged = false

		if not @mousehover
			if @lastframehover
				for _,c in pairs systems
					c\hoverQuit!
			@lastframehover = false

		if not world\hasItem @
			return

		colWith = {}
		x,y,w,h = world\getRect(@)
		items,tlen = world\queryRect(x,y,w,h)

		for i = 1, tlen
			item = items[i].entity
			if item and @entity~=item
				if not functional.contains @prevFrameCol,item
					for _,c in pairs systems
						c\onEnter item
					if not functional.contains @prevFrameCol,item
						table.insert @prevFrameCol,item
				for _,c in pairs systems
					c\onStay item
				table.insert colWith, item
		for _,prevState in pairs @prevFrameCol
			if not functional.contains colWith,prevState
				for _,c in pairs systems
					c\onLeave prevState
				table.remove @prevFrameCol, table.index_of(self.prevFrameCol,prevState)

	setDragAndDrop: (bounds) =>
		@dragable = true

	draw: =>
		if @hidecollider
			return

		world = @entity.scene.world

		if not world\hasItem @
			return
		x,y,w,h = world\getRect @
		lg.setLineStyle "rough"
		lg.setColor 0,1,0,1 
		lg.rectangle "line",x,y,w,h
		lg.setColor 1,1,1,1 

return Collider
