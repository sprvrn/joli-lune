--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"

local lg = love.graphics

local ShapeRenderer = Render:extend(Render)

local shapefunc = {
	rect = lg.rectangle,
	circ = lg.circle,
	poly = lg.polygon,
	line = lg.line
}

local getArgs = {
	rect = function(mode, x, y, arg1, arg2)
		return mode, x, y, arg1, arg2
	end,
	circ = function(mode, x, y, arg1, arg2)
		return mode, x, y, arg1
	end,
	poly = function(mode, x, y, arg1, arg2)
		return mode, arg1
	end,
	line = function(mode, x, y, arg1, arg2)
		return {arg1[1]+x,arg1[2]+y,arg1[3]+x,arg1[4]+y}
	end,
}

function ShapeRenderer:__tostring()
	return "shaperenderer"
end

function ShapeRenderer:new(game, type, color, mode, arg1, arg2)
	ShapeRenderer.super.new(self)

	self.game = game

	self.rendertype = "shape"

	self.type = type
	self.mode = mode or "fill"
	self.arg1 = arg1
	self.arg2 = arg2
	self.tint = color
	self.linestyle = "rough"
	if type == "line" then
		--self.linestyle = self.mode or "rough"
	end
end

function ShapeRenderer:draw(position, x, y, z, r, sx, sy,ox,oy)
	ShapeRenderer.super.draw(self)
	x, y = self:getPosition(x,y,ox,oy)

	if self.clip then
	    lg.setScissor(position.x+self.clip.x,position.y+self.clip.y,self.clip.width,self.clip.height)
	end

	lg.push()
	
	lg.scale(sx,sy)
	lg.rotate(r)

	lg.setLineStyle(self.linestyle)

	shapefunc[self.type](getArgs[self.type](self.mode, x, y, self.arg1, self.arg2))

	lg.pop()

	if self.tint then
	    lg.setColor(1,1,1,1)
	end

	if self.clip then
	    lg.setScissor()
	end

	if self.shader then
		lg.setShader()
	end
end

function ShapeRenderer:debugLayout(ui)
	ShapeRenderer.super.debugLayout(self,ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label("Type : "..self.type)
	ui:label("Mode : "..self.mode)
	if self.type == "rect" then
	    ui:layoutRow('dynamic', 20, 2)
	    self.arg1 = ui:property("Width", 0, self.arg1, 10000000, 1, 1)
		self.arg2 = ui:property("Height", 0, self.arg2, 10000000, 1, 1)
	end
	if self.type == "circ" then
	    ui:layoutRow('dynamic', 20, 1)
	    self.arg1 = ui:property("Radius", -10000000, self.arg1, 10000000, 1, 1)
	end
end

return ShapeRenderer