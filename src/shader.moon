[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]
class Shader
	new: (...) =>
		@onLoad(...)
	onLoad: =>
	load: (shaderPath) => @shader = love.graphics.newShader shadePath
	set: () => love.graphics.setShader self.shader 
	unset: () => love.graphics.setShader!
	update: (dt) =>
	send: (...) => @shader\send ...

return Shader