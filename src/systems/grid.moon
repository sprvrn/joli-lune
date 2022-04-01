finder = require "libs.pathfinding"

System = require "src.systems.system"

class Grid extends System
	onCreate: (orientation, width, height=width, cellW=8, cellH=8) =>
		@orientation = orientation

		@width = width
		@height = height

		@cellWidth = cellW
		@cellHeight = cellH

		@cells = {}

	cellId: (x,y) => x + (@height * y)

	inside: (x,y) => x >= 1 and x <= @width and y >= 1 and y <= @height

	init: (defaultLayer=@entity.layer, cellSystem="GridCell", ...) =>
		z = 1
		cellArgs = {...}
				
		functional.generate_2d @width, @height, (x,y) ->
			cellEntityName = string.format "%s_cell_%d_%d", @entity.name, x, y

			@cells[@\cellId x,y] = with @entity.scene\newEntity cellEntityName, 0, 0, z, defaultLayer
				\addSystem cellSystem, @, x, y, unpack cellArgs

			z += 1


	getCell: (x,y) => if @\inside x,y then @cells[@cellId x,y]

	foreachCell: (func) => func cell for _,cell in pairs @cells

	getOnePath: (start, goal, isWalkableFunc, getCostFunc, searchDirectionMode="normal") =>
		getDistance: (cell1, cell2) => math.abs(node1.x - node2.x) + math.abs(node1.y - node2.y)
		getAdj = (cell) ->
			cells = {}

			checkCell = (x,y) ->
				thisCell = @\getCell x,y
				if @\inside(x,y) and isWalkableFunc thisCell
					table.insert cells, thisCell

			checkCell x-1,y
			checkCell x+1,y
			checkCell x,y-1
			checkCell x,y+1

			if searchDirectionMode == "diagonal"
				checkCell x-1,y-1
				checkCell x+1,y+1
				checkCell x+1,y-1
				checkCell x-1,y+1

			return cells


		finder "one", start, goal, getAdj, getCostFunc, getDistance

	getManyPath: (start, goals, isWalkableFunc, getCostFunc, searchDirectionMode="normal") =>
		getAdj = (cell) ->
			cells = {}

			checkCell = (x,y) ->
				thisCell = @\getCell x,y
				if @\inside(x,y) and isWalkableFunc thisCell
					table.insert cells, thisCell

			x,y = cell.tile.x, cell.tile.y

			checkCell x-1,y
			checkCell x+1,y
			checkCell x,y-1
			checkCell x,y+1

			if searchDirectionMode == "diagonal"
				checkCell x-1,y-1
				checkCell x+1,y+1
				checkCell x+1,y-1
				checkCell x-1,y+1

			return cells


		finder "many", start, goals, getAdj, getCostFunc
