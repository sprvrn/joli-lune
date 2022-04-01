System = require "src.systems.system"

class GridCell extends System
	onCreate: (grid,x=0,y=0) =>
		@x = x
		@y = y

		@grid = grid

		@position.x, @position.y = @\getPosition!

	cellId: => @x + (@grid.height * @y)

	coord: => @x, @y

	getPosition: =>
		switch @grid.orientation
			when "orthogonal" then @grid.position.x + (@x - 1) * @grid.cellWidth, @grid.position.y + (@y - 1) * @grid.cellHeight
			when "isometric" then @grid.position.x + ((@x-1) - (@y-1)) * (@grid.cellWidth / 2), @grid.position.y + ((@x-1) + (@y-1)) * (@grid.cellHeight / 2)

	getAdjacentCells: () =>
		cells = {}

		getCell: (x,y) ->
			if @grid\inside x,y
				