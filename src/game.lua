--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

if pcall(require, "moonscript") then
	moonscript = require "moonscript.base"
	errors = require "moonscript.errors"
end

local Object = require "libs.classic"
local Scene = require "src.scene"
local Sprite = require "src.sprite"
local Shader = require "src.shader"

require "src.errorhandler"

require "libs.TSerial"
require "libs.utils"

require("libs.batteries"):export()

local cargo = require("libs.cargo")
local baton = require ("libs.baton")

Color = require ("libs.hex2color")

local Game = Object:extend()

local lg,lf = love.graphics,love.filesystem

function Game:new()
	lg.setDefaultFilter("nearest", "nearest")

	self:loadSettings()

	self.t = 0

	local moonFileLoader = function(filePath)
		moonFile, err = moonscript.loadfile(filePath)
		if not moonFile then
			err = err:gsub("\n","")
			err = filePath..":"..err
			error(err)
		else
			return moonFile()
		end
	end

	local luaFileLoader = function(filePath)
		if not moonscript then
			return lf.loadfile(filePath)
		end
	end

	self.assets = cargo.init({
		dir = 'assets',
		loaders = {
			png = Sprite,
			moon = moonFileLoader,
			--lua = luaFileLoader
			--glsl = Shader
		}
	})

	self.assets.particles = require("assets.particles")(self)

	self.statetree = self:buildStateTree()

	self.systems = cargo.init({dir='src/systems',loaders={
		moon=moonFileLoader}})
	self.assetssystems = cargo.init({dir='assets/systems',loaders={
		moon=moonFileLoader}})

	self.file = require("src.file")(self.assets.save)

	local prefabs = {}
	for _,p in pairs(self.assets.prefabs()) do
		if type(p) == "table" then
		    for name,method in pairs(p) do
		    	if type(method) == "function" then
		    		if prefabs[name] then
		    		    print("Warning, prefabs loading : " .. name .. " already exists.")
		    		end
		    	    prefabs[name] = method
		    	end
		    end
		end
	end
	self.assets.prefabs = prefabs

	for name,style in pairs(require("assets.fonts.style")) do
		local font = nil
		if style.font and self.assets.fonts[style.font] then
		    font = self.assets.fonts[style.font](style.size or 16)
		end
		self.assets.fonts[name] = {}

		for k,v in pairs(style) do
			self.assets.fonts[name][k] = v
		end

		self.assets.fonts[name].font = font
		self.assets.fonts[name].color = style.color or {1,1,1,1}
	end

	self.defaultfont = love.graphics.getFont()
	--lg.setFont(self.assets.fonts.main.font)

	love.mouse.setVisible(self.settings.mousevisible)

	self.data = {}

	self.scenes = {}

	self.filename = "1" -- ??

	self.tick = require ('libs.tick')
	self.tick.framerate = self.settings.maxfps

	if self.assets.inputs then
	    self.input = baton.new(self.assets.inputs)
	end

	require ("src.love2dcalls")(self)

	self.displaydebug = false
	self.debug = require("src.debug")()
	if self.settings.debug and pcall(require, "nuklear") then
	    self.gui = require("src.gui")(self)
	end

	Icon = require("libs.slog-icon")
	if self.settings.iconimg and self.assets.sprites[self.settings.iconimg] then
	    Icon.configure(self.settings.iconsize, self.assets.sprites[self.settings.iconimg].image)
	end

	self:setWindow()

	self.viewx = 0
	self.viewy = 0
end

function Game:getSystem(name)
	return self.systems[name] or self.assetssystems[name]
end

function Game:newScene(name, ...)
	local newScene = Scene(self, name, ...)
	self.scenes[name] = newScene
	self[name] = newScene
	return newScene
end

function Game:destroyScene(name)
	if self.scenes[name] then
		for _,e in pairs(self.scenes[name].entities) do
			self.scenes[name]:removeEntity(e)
		end
	    self.scenes[name] = nil
	    self[name] = nil
	else
	    print("Warning: attempt to destroy scene <"..name..">, but it does not exist.")
	end
end

function Game:loadSettings()
	if lf.getInfo("settings.sav") then
		self.settings = TSerial.unpack(lf.read("settings.sav"))
	else
	    self.settings = require "assets.settings"
	    self.settings.window.width = self.settings.canvas.width * self.settings.canvas.scale
		self.settings.window.height = self.settings.canvas.height * self.settings.canvas.scale
	end

	love.filesystem.setIdentity(self.settings.identity)
end

function Game:writeSettings(newW,newH)
	self.settings.window.width = newW
	self.settings.window.height = newH
	lf.write("settings.sav",TSerial.pack(self.settings))
end

function Game:setWindow()
	local settings = copy(self.settings).window

	settings.width = nil
	settings.height = nil
	settings.title = nil
	settings.icon = nil

	love.window.setMode(
		self.settings.window.width or lg.getWidth(),
		self.settings.window.height or lg.getHeight(),
		settings)
	love.window.setTitle(self.settings.window.title)
	love.window.setIcon(love.image.newImageData(self.settings.window.icon))
end

function Game:buildStateTree()
	local r = {}
	for name,options in pairs(require('assets.states.statetree')) do
		r[name] = {
			stateFile = self.assets.states[name],
			name = name,
			pause = false,
			hide = false,
			options = options
		}
	end
	return r
end

function Game:state()
	return self.current_state
end

function Game:isState(stateName)
	return self.current_state.name == stateName
end

function Game:states()
	return self.statetree
end

function Game:isState(name)
	if self.current_state.name == name then
		return true
	end
	return false
end

function Game:stateUpdate()

end

function Game:stateDraw(state,t)
	if not state.hide then
		table.insert(t, state.object)
	end
	    
	if state.parent then
	    t = self:stateDraw(state.parent,t)
	end
	return t
end

function Game:init()
	local startGame = function()
		self.splash = nil
		if self.settings.firststate then
			self:stateActivation(self.settings.firststate)
		else
			for name,state in pairs(self.statetree) do
				self:stateActivation(name)
				break
			end
		end
	end
	
	if self.settings.lovesplash then
	    self.splash = require("libs.o-ten-one")(self.settings.lovesplashconfig)
	    self.splash.onDone = startGame
	else
	    startGame()
	end
end

function Game:stateActivation(name, ...)
	assert(type(name)=="string",name)
	local state = self:state()
	if state then
		state.object:onExit()
		state.object = nil
	end
	if self.statetree[name] then
		self.current_state = self.statetree[name]
		self.current_state.object = self.current_state.stateFile(self, name, self.current_state.options)
		self.current_state.object:onEnter(...)
	end
end

function Game:stateQuit()
	self.current_state.object:onExit()
	self.current_state.object = nil

	if self.current_state.parent then
		self.current_state = self.current_state.parent
		self.current_state.skipnext = true
	else
	    self.current_state = nil
	end
end

function Game:update(dt)
	self.input:update()

	if self.splash then
	    self.splash:update(dt)
	    return
	end
	
	if self.settings.debug and self.input:pressed("displaydebug") then
	    self.displaydebug = not self.displaydebug
	end

	if self.input:pressed("screenshot") then
	    lg.captureScreenshot(os.time() .. ".png")
	end

	local state = self:state()
	if state then
		state.object:update(dt)
	end

	self.debug:update(dt)

	if self.gui and self.displaydebug then
	    self.gui:update(dt)
	end

	self.t = self.t + dt
end

function Game:draw()
	if self.splash then
	    self.splash:draw()
	    return
	end
	local state = self:state()
	if state then
		state.object:draw()
	else
		lg.setBackgroundColor(0.3, 0.3, 0.35, 1)
		lg.setColor(.9,.9,.9,1)
	    lg.print("joli-lune ("..require("src.jolilune")._VERSION..") framework for love2d (no game detected)",10,10)
		lg.setColor(1,1,1,1)
	end

	if self.displaydebug then
		if self.gui then
			self.gui:draw()
		end
		
		self.debug:draw()
	end
end

return Game