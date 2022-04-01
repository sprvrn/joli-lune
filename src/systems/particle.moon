[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class Particle extends System
	__tostring: => return "particle"

	onCreate: (color,exp,particleType,options={}) =>
		@\cron "after", exp, ->
			@entity.scene\removeEntity(@entity)

		@expire = exp

		if type(particleType)=="string"
			@entity\addSystem "Renderer",particleType,options.style or "main",options.width or 100,options.align or "left"
			if color
				@entity.renderer\get().tint = color
		elseif tostring(particleType)=="sprite"
			@entity\addSystem "Renderer",particleType,options.anim,0,0,options.flipx,options.flipy
			if color
				@entity.renderer\get().tint = color
		else
			@entity\addSystem "Renderer","circ",color,"fill",size

		@render = @entity.renderer\get!

	velocityx: (easing,vx1=0,vx2=vx1) =>
		@position\tween @expire,{x:@position.x+love.math.random(vx1,vx2)},easing
	velocityy: (easing,vy1=0,vy2=vy1) =>
		@position\tween @expire,{y:@position.y+love.math.random(vy1,vy2)},easing

	size: (easing,startsize,endsize) =>
		if @render.rendertype == "shape"
			@render.arg1 = startsize
			if endsize
				@\tween @expire,{arg1:endsize},easing,@render
		elseif @render.rendertype=="sprite" or @render.rendertype=="text"
			@position.scalex = startsize
			@position.scaley = startsize
			if endsize
				@position\tween @expire,{scalex:endsize,scaley:endsize},easing

	alpha: (easing,s,e) =>
		if not @render.tint
			@render.tint = {1,1,1,s}
			@render.alpha = s
		else
			@render.tint = {@render.tint[1],@render.tint[2],@render.tint[3],s}
			@render.alpha = s
		if e
			@\tween @expire,{alpha:e},easing,@render

return Particle