[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class Parallax extends System
	__tostring: => return "parallax"

	onCreate: (camera,speedX=1,speedY=1, ...) =>
		if not @entity.renderer
			@entity\addSystem "Renderer"

		with @entity.renderer
			\add "topleft", ...
			\add "topright", ...
			\add "bottomleft", ...
			\add "bottomright", ...
		
		@width = @entity.renderer\get("topleft").sprite.size.w
		@height = @entity.renderer\get("topleft").sprite.size.h

		@camera = camera

		@speedX = speedX
		@speedY = speedY

		@lockX = false
		@lockY = false

	updateAfter: (dt) =>
		if @camera
			x,y = @camera.x, @camera.y
			if not @lockX
				x /= @speedX
			else
				x = 0
			if not @lockY
				y /= @speedY
			else
				y = 0
			@\setPosition x,y

	setPosition: (x, y) =>
		xm, ym = x % @width, y % @height
		left, top = -xm, -ym

		topleftx, toplefty = left, top
		toprightx, toprighty = topleftx + @width, toplefty
		bottomleftx, bottomlefty = topleftx, toplefty + @height
		bottomrightx, bottomrighty = toprightx, bottomlefty

		topleftx, toprightx, bottomleftx, bottomrightx = topleftx+@camera.x, toprightx+@camera.x, bottomleftx+@camera.x, bottomrightx+@camera.x
		toplefty, toprighty, bottomlefty, bottomrighty = toplefty+@camera.y, toprighty+@camera.y, bottomlefty+@camera.y, bottomrighty+@camera.y

		with @entity.renderer
			\get("topleft")\setOffset(topleftx,toplefty)
			\get("topright")\setOffset(toprightx,toprighty)
			\get("bottomleft")\setOffset(bottomleftx,bottomlefty)
			\get("bottomright")\setOffset(bottomrightx,bottomrighty)

return Parallax



