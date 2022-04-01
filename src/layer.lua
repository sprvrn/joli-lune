--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local Layer = Object:extend()

local lg = love.graphics

function Layer:__tostring()
	return "layer"
end

function Layer:new(game, name, autobatch, batchusage)
	self.name = name
	self.batches = {}

	self.game = game

	self.autobatch = autobatch or self.game.settings.autobatch

	self.batchusage = "stream"
end

function Layer:getBatch(sprite)
	for i=1,#self.batches do
		if self.batches[i]:getTexture() == sprite.image then
		    return self.batches[i]
		end
	end

	local newbatch = lg.newSpriteBatch(
		sprite.image,
		self.game.settings.batchmaxsprites or 1000,
		sprite.batchusage or self.batchusage
		)
	table.insert(self.batches, newbatch)
	return newbatch
end

return Layer