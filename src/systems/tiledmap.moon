[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

lvt = require "libs.lovelytiles"

class TiledMap extends System
	__tostring: => return "tiledmap"

	onCreate: (mapdata,startx,starty,w,h,layers,obj) =>
		@map = lvt.new mapdata,startx,starty,w,h,layers,obj

		@map\foreach "tile", (map,layer,tile,x,y) ->
			@collidables = {}

			if not @entity.scene.world
				@entity.scene\createPhysicWorld!

			px,py = @position\get!
			tileset = tile.tileset

			c = {
				type:"wall",
				solid:true,
				x:(x-1)*tileset.tilewidth+px,
				y:(y-1)*tileset.tileheight+py,
				width:tileset.tilewidth,
				height:tileset.tileheight
			}
			if tile.objectGroup and tile.objectGroup.objects
				for _,o in pairs tile.objectGroup.objects
					if (layer.properties and layer.properties.collidable) or (o.properties and o.properties.collidable)
						c1 = copy c
						c1.x += o.x
						c1.y += o.y
						c1.width = o.width
						c1.height = o.height

						@\addCollidable c1
			else
				if (layer.properties and layer.properties.collidable) or (tile.properties and tile.properties.collidable)
					@\addCollidable c

		scene = @entity.scene
		x,y,z = @position\get!

		l = 0

		if @map.backgroundcolor
			with scene\newEntity "backgroundcolor",x,y,z-.1,"backgroundcolor"
				\addSystem "Renderer","rect",@map.backgroundcolor,"fill",@map.tilewidth * @map.mapWidth,@map.tileheight * @map.mapHeight

		for _,layer in pairs @map.layers
			if layer.type=="tilelayer" or layer.type=="imagelayer"
				with scene\newEntity layer.name,x,y,z+l,layer.name
					\addSystem "tiledmaplayer",layer
				if layer.tiles
					for x,t in pairs layer.tiles
						for y,tile in pairs t
							if tile.data
								if type(tile.data.type)=="string" and tile.data.type=="entity"
									@entity.scene\initPrefab(tile.data.properties.name,tile.data.properties.name,(x-1)*@map.tilewidth,(y-1)*@map.tileheight,z+l,tile,layer.name)
									layer\removeTile x,y
			elseif layer.type == "objectGroup"
				for _,obj in pairs layer.objects
					if obj.type=="entity"
						scene\initPrefab obj.name,obj.name,obj.x+x,obj.y+y,z+l,obj,layer.name
			l += 1

		tw,th = @map.tilewidth,@map.tileheight
		camera = @entity.scene.cameras.main
		screenTileW = @game.settings.canvas.width/tw
		screenTileH = @game.settings.canvas.height/th

		cameraboundx1,cameraboundy1 = (@map.startx-1)*tw,(@map.starty-1)*th
		cameraboundx2,cameraboundy2 = cameraboundx1+(@map.mapWidth-screenTileW)*tw,cameraboundy1+(@map.mapHeight-screenTileH)*th

		camera\setWindow cameraboundx1,cameraboundy1,cameraboundx2,cameraboundy2

	addCollidable: (c) =>
		@entity.scene.world\add c,c.x,c.y,c.width,c.height
		table.insert @collidables,c

return TiledMap