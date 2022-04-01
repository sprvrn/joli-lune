--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"
local Camera = require "src.camera"
local Entity = require "src.entity"
local Layer = require "src.layer"

local bump = require "libs.bump"

local lg = love.graphics

local Scene = Entity:extend()

local sortByZ = function(a,b)
	return a.position.z < b.position.z
end
local sortByName = function(a,b)
	return a.name < b.name
end

function Scene:new(game, name, layers)
	Scene.super.new(self, game, name)

	self.cameras = {}

	self.entities = {}
	self.updatedEntities = {}
	self.drawnEntities = {}

	self.layers = {}
	local layers = layers or {}
	for i=1,#layers do
		table.insert(self.layers, Layer(self.game, layers[i]))
	end

	self.world = nil

	self:addCamera("main",0,0,
		self.game.settings.canvas.width,
		self.game.settings.canvas.height,
		0,
		self.game.settings.canvas.scale)
	self.cameras.main:resizeToWindow()
end

function Scene:destroy()
	self.game:destroyScene(self.name)
end

function Scene:newEntity(name, ...)
	local newEntity = Entity(self.game, name, ...)
	newEntity.scene = self
	if newEntity.layer then
		newEntity.layer = self:getLayer(newEntity.layer)
	end

	if self[name] then
		local i = 1
		while true do
			local newname = name.."("..i..")"
			if not self[newname] then
			    name = newname
			    newEntity.name = name
			    break
			end
			i = i + 1
		end
	end

	table.insert(self.entities, newEntity)


	newEntity:setPause(false)
	newEntity:setHide(false)

	--table.sort(self.entities, sortByName)
	--table.sort(self.entities, sortByZ)

	--table.sort(self.updatedEntities, sortByName)
	--table.sort(self.drawnEntities, sortByZ)

	table.sort(self.updatedEntities, sortByName)
	table.sort(self.drawnEntities, sortByZ)

	self[name] = newEntity
	return newEntity
end

function Scene:initPrefab(prefabname, ...)
	local prefabcall = self.game.assets.prefabs[prefabname]
	if type(prefabcall) == "function" then
		return prefabcall(self, ...)
	else
		print("Warning : <"..prefabname.."> prefab does not exists.")
	end
end

function Scene:getLayer(layer)
	for i=1,#self.layers do
		if self.layers[i].name == layer then
			return self.layers[i]
		end
	end
end

function Scene:setLayerOption(name, options)
	local layer = self:getLayer(name)
	for label,val in pairs(options) do
		layer[label] = val
	end
end

function Scene:setLayers(layers)
	self.layers = {}
	local layers = layers or {}
	for i=1,#layers do
		local layer = layers[i]
		table.insert(self.layers, Layer(layer.name,layer.autobatch))
	end
end

function Scene:getEntityByName(name)
	for _,e in pairs(self.entities) do
		if name == e.name then
			return e
		end
	end
end

function Scene:getByTag(tag)
	local r = {}
	for i = 1, #self.entities do
		local e = self.entities[i]
		if tag == e.tag then
			table.insert(r, e)
		end
	end
	return r
end

function Scene:getByLayer(name)
	local r = {}
	for i=1,#self.drawnEntities do
		local e = self.drawnEntities[i]
		if e.layer then
			if name == e.layer.name then
				table.insert(r, e)
			end
		end
	end
	return r
end

function Scene:removeEntity(entity)
	if entity and entity.scene == self then
	    if not self[entity.name] then
	    	print("Warning trying to delete "..entity.name.." entity. Not in the entity list of this scene", self.name)
	        return
	    end
	else
		--print("Warning : trying to delete "..entity.." entity. failed")
	end

	if entity then
		for _,c in pairs(entity.systems) do
			c:onDestroy()
		end

	    self[entity.name] = nil
		table.remove(self.entities, table.index_of(self.entities,entity))
		if functional.contains(self.updatedEntities, entity) then
		    table.remove(self.updatedEntities, table.index_of(self.updatedEntities,entity))
		end
		if functional.contains(self.drawnEntities, entity) then
			table.remove(self.drawnEntities, table.index_of(self.drawnEntities,entity))
		end
	end
end

function Scene:addCamera(name,...)
	self.cameras[name] = Camera(self,name,...)
end

function Scene:mainCamera()
	return self.cameras.main
end

function Scene:createPhysicWorld()
	if self.world == nil then
		self.world = bump.newWorld()
	end
end

function Scene:addCollider(item)
	self:createPhysicWorld()
	self.world:add(item, item.x, item.y, item.w, item.h)
end

function Scene:update(dt)
	Scene.super.update(self,dt)

	if self.pause then
		return
	end

	for _,camera in pairs(self.cameras) do
		camera:update(dt)

		if self.world and self.game.settings.mouse then
			local mx, my = camera:mousePosition()
			if mx and my then
				if self.drawingTopCamera then
					mx, my = mx + camera.x, my + camera.y
				end
				local items, len = self.world:queryPoint(mx, my, function(item)
					if tostring(item) == "collider" then
						return true
					end
				end)

				for i=1,len do
					local item = items[i]
					item.mousehover = true
				end
				if type(items) == "table" and len > 0 then
				    --items[len].mousehover = true
				end
				
				-- todo : focus on top item only
			end
		end
	end

	--table.sort(self.entities, sortByName)
	--table.sort(self.entities, sortByZ)
	--

	--table.sort(self.updatedEntities, sortByName)
	--table.sort(self.drawnEntities, sortByZ)

	table.sort(self.updatedEntities, sortByName)
	table.sort(self.drawnEntities, sortByZ)

	for i=1,#self.updatedEntities do
		local entity = self.updatedEntities[i]
		if entity then
			entity:update(dt)
			if entity.collider then
			    entity.collider.mousehover = false
			end
		end
	end

	for i=1,#self.updatedEntities do
		local entity = self.updatedEntities[i]
		if entity then
			entity:updateAfter(dt)
		end
	end
end

function Scene:draw(layers, mode)
	if self.hide then
		return
	end

	mode = mode or "include"
	if type(layers) == "string" then
		layers = {layers}
	end

	for i=1,#self.layers do
		local layer = self.layers[i]

		if  (layers ~= nil and mode == "include" and functional.contains(layers,layer)) or
			(layers ~= nil and mode == "exclude" and not functional.contains(layers,layer)) or
			layers == nil then

			local entities = self:getByLayer(layer.name)
			for e=1,#entities do
				local entity = entities[e]
				if entity then
					entity:draw()
				end
			end

			for b=1,#layer.batches do
				lg.draw(layer.batches[b], 0, 0)
			end
		end
	end
end

function Scene:drawOnCamera(...)
	local camera = self.cameras.main

	camera:set()
	self:draw(...)
	camera:unset()
	camera:draw()
end

function Scene:drawentities(tags,mode)
	if self.hide then
		return
	end
	mode = mode or "incl"
	if type(tags) == "string" then
		tags = {tags}
	end
	for i=1,#self.drawnEntities do
		local entity = self.drawnEntities[i]
		if entity then
			if  (tags ~= nil and mode == "incl" and functional.contains(tags,entity.tag)) or
				(tags ~= nil and mode == "excl" and not functional.contains(tags,entity.tag)) or
				tags == nil then

				entity:draw()
			end
		end
	end
end

function Scene:particle(system,x,y,z,layer,tag,functionOption)
	local rate = system.rate or 1

	for i=1,rate do
		local rndcolor = nil
		if system.colors then
			rndcolor = system.colors[math.floor(love.math.random(1,#system.colors))]
		end
		local particle = self:addParticle(x,y,z,
			rndcolor,
			system.size,
			love.math.random(system.lifetime[1],system.lifetime[2]),
			system.text or system.sprite,system.options)

		particle.entity.tag = tag
		particle.entity.layer = self:getLayer(layer)
		particle:velocityx(system.vx[1],system.vx[2],system.vx[3])
		particle:velocityy(system.vy[1],system.vy[2],system.vy[3])

		if system.size then
			particle:size(system.size[1],system.size[2],system.size[3])
		end
		if system.alpha then
			particle:alpha(system.alpha[1],system.alpha[2],system.alpha[3])
		end
		if system.collider then
			particle.entity:addSystem("Collider",10,10)
		end

		if type(functionOption) == "function" then
			functionOption(particle)
		end
	end
end

function Scene:addParticle(x,y,z,color,size,exp,type,options)
	local particle = self:newEntity("particle_entity",x,y,z)
		:addSystem("Particle",color or {1,1,1,1},exp or 1,type,options)

	return particle
end

function Scene:setPause(pause)
	self.pause = pause
	for _,e in pairs(self.entities) do
		local set = e:getSystem("SoundSet")
		if set then
			if pause then
				set:pause()
			else
				set:resume()
			end
		end
	end
end

return Scene