--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"
local anim8 = require "libs.anim8"

local lg = love.graphics

local SpriteRenderer = Render:extend()

function SpriteRenderer:__tostring()
	return "spriterenderer"
end

function SpriteRenderer:new(game, sprite, anim, ox, oy, sx, sy, flipx, flipy)
	SpriteRenderer.super.new(self)

	self.game = game

	self.sprite = copy(sprite)

	self.rendertype = "sprite"

	self.animToPlay = anim

	self.ox = ox or 0
	self.oy = oy or 0

	self.flipx = flipx or false
	self.flipy = flipy or false

	self.scalex = sx or 1
	self.scaley = sy or 1

	if self.sprite.anims then
		for name, anim in pairs(self.sprite.anims) do
			self.sprite.anims[name] = {
				frame_ct = anim.frame_ct,
				a8 = anim8.newAnimation(self.sprite.grid(anim.range, anim.row), anim.duration or 1)
			}
		end
	end
end

function SpriteRenderer:draw(position, x, y, z, r, sx, sy, ox, oy, kx, ky)
	SpriteRenderer.super.draw(self)

	--local x, y, z, r, sx, sy = position:get()
	x,y = self:getPosition(x,y,ox,oy)

	if self.scalex > 1 then
	    sx = sx + self.scalex
	end
	if self.scaley > 1 then
	    sy = sy + self.scaley
	end

	if self.flipx then
		local osx = sx
	    sx = sx - sx * 2
	    x = x + self.sprite.size.w * osx
	end

	if self.flipy then
		local osy = sy
	    sy = sy - sy * 2
	    y = y + self.sprite.size.h * osy
	end

	if self.clip then
		local camera = position.entity.scene.cameras.main
		local camx, camy = camera.x, camera.y

		local x, y = 
			position.x + self.clip.x - camx + self.ox,
			position.y + self.clip.y - camy + self.oy

	    lg.setScissor(x, y ,self.clip.width, self.clip.height)
	end

	if self.animToPlay then
		local anim = self.sprite.anims[self.animToPlay] 
		if anim then
			if not position.entity.layer or not position.entity.layer.autobatch then
				anim.a8:draw(self.sprite.image, x, y, r, sx, sy, position.originx, position.originy, kx, ky)
			else
				if not self.batch then
				    self.batch = position.entity.layer:getBatch(self.sprite)
				end

				if self.tint then
				    self.batch:setColor(self.tint)
				end
				
				if not self.batchId then
				    self.batchId = self.batch:add(anim.a8:getFrameInfo(x, y, r, sx, sy, position.originx, position.originy, kx, ky))
				else
				    self.batch:set(self.batchId,anim.a8:getFrameInfo(x, y, r, sx, sy, position.originx, position.originy, kx, ky))
				end
				
				if self.tint then
				    self.batch:setColor(1,1,1,1)
				end
			end
		else
			print("Warning: trying to draw anim <"..self.animToPlay.."> of sprite <"..self.sprite.name.."> : doesnt exists.")
		end
	else
		lg.draw(self.sprite.image, x, y, r, sx, sy, position.originx, position.originy, kx, ky)
	end

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

function SpriteRenderer:update(dt)
	if self.animToPlay then
		local anim = self.sprite.anims[self.animToPlay] 
		if anim then
			anim.a8:update(dt)
		end
	end
end

function SpriteRenderer:removeFromBatch()
	if self.batch and self.batchId then
		self.batch:set(self.batchId, 0, 0, 0, 0, 0)
	end
end

function SpriteRenderer:spriteChanged(quad,x,y,r,sx,sy,ox,oy,kx,ky)
	local p = {quad,x,y,r,sx,sy,kx,ky}
	if type(self.lastPos) == "table" then
	    for i=1,#self.lastPos do
	    	if self.lastPos[i] ~= p[i] then
	    	    return false
	    	end
	    end
	end
	return true
end

function SpriteRenderer:playAnim(name, t, dur)
	local anim = self.sprite.anims[name]

	if anim ~= nil then
		if dur == nil then
			dur = anim.a8.totalDuration
		else
			anim.a8.totalDuration = dur / anim.frame_ct
		end

		anim.a8.status = "playing"
		if t == "once" then
			anim.a8.onLoop = 'pauseAtEnd'
		end

		self.animToPlay = name
	end
end

function SpriteRenderer:setAnim(name, t, dur)
	local anim = self.sprite.anims[name]
	
	if anim ~= nil then
		self:playAnim(name, t, dur)

		anim.a8:gotoFrame(1)
	end
end

function SpriteRenderer:setHide(hide)
	self.hide = hide

	if hide then
		self:removeFromBatch()
	end
end

function SpriteRenderer:debugLayout(ui)
	SpriteRenderer.super.debugLayout(self,ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label("Animation : "..tostring(self.animToPlay))
	self.sprite:debugLayout(ui)
end

return SpriteRenderer