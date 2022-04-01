--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local lg = love.graphics

local Renderer = Object:extend()

function Renderer:__tostring()
	return "renderer"
end

function Renderer:new(tint, ox , oy)
	self.tint = tint or {1,1,1,1}
	--self.alpha = self.tint[4] or 1

	self.ox = ox or 0
	self.oy = oy or 0

	self.shader = nil

	self.hide = false
end

function Renderer:draw()
	if self.hide then
	    return
	end
	if self.tint then
		if self.alpha then
		    self.tint[4] = self.alpha
		end
	    lg.setColor(self.tint)
	end
	if self.shader then
	    self.shader:set()
	else
	    lg.setShader()
	end
end

function Renderer:update(dt)
end

function Renderer:setOffset(ox,oy)
	if ox then
	    self.ox = ox
	end
	if oy then
	    self.oy = oy
	end

	return self
end

function Renderer:setClip(x,y,w,h)
	self.clip = {x=x,y=y,width=w,height=h}

	return self
end

function Renderer:setShader(shader, ...)

	self.shader = shader(...)

	return self.shader
end

function Renderer:setHide(hide)
	self.hide = hide
end

function Renderer:getPosition(x,y,ox,oy)
	return x+(ox or self.ox),y+(oy or self.oy)
end

return Renderer