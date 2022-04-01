--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local lg = love.graphics

local Entity = Object:extend()

function Entity:__tostring()
	return "entity:"..self.name
end

function Entity:new(game, name, x, y, z, layer, tag)
	assert(type(name) == "string", "Entity name must be a string (was "..type(name)..")")

	self.game = game

	self.name = name

	self.tag = tag
	self.layer = layer
	self.systems = {}

	self:addSystem("position",x,y,z,r,sx,sy)

	self.pause = false
	self.hide = false

	self.scene = nil
end

function Entity:destroy()
	self.scene:removeEntity(self)
end

function Entity:setPause(pause)
	self.pause = pause

	if pause then
		if functional.contains(self.scene.updatedEntities, self) then
			--print("pause entity", self.name)
			table.remove(self.scene.updatedEntities, table.index_of(self.scene.updatedEntities, self))
		end
	else
	    if not functional.contains(self.scene.updatedEntities, self) then
	        table.insert(self.scene.updatedEntities, self)
	    end
	end
end

function Entity:setHide(hide)
	self.hide = hide

	if hide then
		if functional.contains(self.scene.drawnEntities, self) then
			--print("hide entity", self.name)
			table.remove(self.scene.drawnEntities, table.index_of(self.scene.drawnEntities, self))

			-- todo: better
			if self.renderer then
				for _,render in pairs(self.renderer.list) do
					if render.rendertype == "sprite" then
						render:removeFromBatch()
					end
				end
			end
		end
	else
	    if not functional.contains(self.scene.drawnEntities, self) then
	        table.insert(self.scene.drawnEntities, self)
	    end
	end
end

function Entity:addSystem(name, ...)
	name = string.lower(name)
	local systemObject = self.game:getSystem(name)
	if not systemObject then
	    print("Warning: fail to add <"..name.."> system : does not exists. (entity : "..self.name..")")
	    return nil
	end

	if self[name] then
	    print("Warning: <"..name.."> system is already attached to entity <"..self.name..">")
	    return self[name]
	else
		local newSystem = systemObject(self)
		table.insert(self.systems, newSystem)
		self[name] = newSystem
		newSystem:onCreate(...)
		return newSystem
	end

	--return self
end

function Entity:removeSystem(name)
	name = string.lower(name)
	for k,v in pairs(self.systems) do
		if tostring(v) == name then
		    table.remove(self.systems, table.index_of(self.systems,v))
		    self[name] = nil
		end
	end
end

function Entity:update(dt)
	if self.pause then
	    return
	end
	
	for i=1,#self.systems do
		local system = self.systems[i]
		system:update(dt)
		system:updateCron(dt)
		system:updateTween(dt)
	end

	self:updateshake(dt)
end

function Entity:updateAfter(dt)
	if self.pause then
	    return
	end
	for i=1,#self.systems do
		local system = self.systems[i]
		system:updateAfter(dt)
	end
end

function Entity:draw(filter)
	if self.hide then
	    return
	end

	for i=1,#self.systems do
		local system = self.systems[i]
		system:draw()
	end
end

function Entity:toggle()
	self:setPause(not self.pause)
	self:setHide(not self.hide)
end

function Entity:shake(duration,magnitudex,magnitudey)
	self.shakeduration = duration or 1
	self.magnix = magnitudex or 0
	self.magniy = magnitudey or 0
	self.position:tween(duration,{shakeduration=0},"linear",self)
end

function Entity:updateshake(dt)
	if self.shakeduration and self.shakeduration > 0 then
		self.position.shakex = love.math.random(-self.magnix, self.magnix)
		self.position.shakey = love.math.random(-self.magniy, self.magniy)
	else
		self.position.shakex = 0
		self.position.shakey = 0
	end
end

return Entity