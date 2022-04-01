--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"
local Text = require "libs.slog-text"

local lg = love.graphics

local TextRenderer = Render:extend(Render)

function TextRenderer:__tostring()
	return "textrenderer"
end

function TextRenderer:new(game,text,style,width,align,ox,oy,settings)
	TextRenderer.super.new(self, nil, ox, oy)

	self.game = game

	self.rendertype = "text"

	style = style or "main"

	self.text = tostring(text)
	self.previoustxt = self.text

	self.width = width or 100
	self.style = game.assets.fonts[style] or game.assets.fonts.main
	self.tint = self.style.color or {1,1,1,1}

	self.align = align or "left"
	
	self.settings = settings or {}

	if self.settings.print_speed and self.settings.print_speed > 0 then
	    self.showall = false
	else
	    self.showall = true
	end

	self:setStyle(style)

	self.textbox = Text.new(self.align, self.settings)

	Text.configure.icon_table("Icon")

	self:changeText(self.text)
end

function TextRenderer:setStyle(name)
	name = name or "main"
	--assert(type(name) == "string")
	self.style = self.game.assets.fonts[name]

	self.settings.font = self.style.font
	self.settings.color = self.style.color

	local tags = ""

	local addTag = function(param, tag)
		tag = tag or param
		
		if self.style[param] then
			if type(self.style[param] == "table") then
				self.style[param] = self.style[param]
			end
		    tags = tags .. string.format("[%s=%s]", tag, self.style[param])
		end
	end
	
	addTag("shadow", "dropshadow")
	addTag("shadowcolor")
	addTag("shake")
	addTag("spin")
	addTag("swing")
	addTag("raindrop")
	addTag("bounce")
	addTag("blink")
	addTag("rainbow")

	self.settings.adjust_line_height = self.style.adjust_line_height or 0

	self.settings.autotags = tags

	self.textbox = Text.new(self.align, self.settings)

	self:changeText(self.text)
end

function TextRenderer:draw(position, x, y, z, r, sx, sy, ox, oy)
	TextRenderer.super.draw(self)

	x,y = self:getPosition(x,y,ox,oy)
	
	if self.style.font then
	    lg.setFont(self.style.font)
	end

	if self.clip then
	    lg.setScissor(position.x+self.clip.x,position.y+self.clip.y,self.clip.width,self.clip.height)
	end
	
	lg.push()
	lg.scale(sx, sy)

	self.textbox:draw(x,y)
	
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

function TextRenderer:changeText(txt)
	txt = tostring(txt)

	self.text = txt
	self.previoustxt = txt

	if self.game.settings.iconimg and self.game.assets.sprites[self.game.settings.iconimg] then
	    for name,anim in pairs(self.game.assets.sprites[self.game.settings.iconimg].anims) do
	    	local n = string.upper(name)
	    	self.text = string.gsub(self.text, string.upper(name), tostring(anim.id))
	    end
	end

	self.textbox:send(self.text, self.width, self.showall)
end

function TextRenderer:update(dt)
	self.textbox:update(dt)
	if self.previoustxt ~= self.text then
		self:changeText(self.text)
	end
end

return TextRenderer