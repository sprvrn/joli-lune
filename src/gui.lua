--[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

local nuklear = require "nuklear"
local Object = require "libs.classic"

local GUI = Object:extend()

function GUI:new(game)
	self.ui = nuklear.newUI()

	self.stats = love.graphics.getStats()

	self.game = game
end

function displayfield(ui,k,v)
	if k=="entity" or k== "position" or k=="scene" then
	    return
	end
	if type(v) == "table" then
	    if ui:treePush('node',k) then
	        for k,v in pairs(v) do
	        	ui:layoutRow('dynamic', 10, 1)
				ui:label(k.." : "..tostring(v))
	        end
	        ui:treePop()
	    end
	else
		ui:layoutRow('dynamic', 10, 1)
		ui:label(k.." : "..tostring(v))
	end
end

function GUI:update(dt)
	local ui = self.ui

	local game = self.game
	
	ui:frameBegin()
	if ui:windowBegin('Debug', 200, 0, 400, game.settings.canvas.height*game.settings.canvas.scale, 'title', 'movable', 'scrollbar') then
		--ui:groupBegin("debugwindow",'title','border') 
			ui:layoutRow('dynamic', 20, 1)
			ui:label('Fps : '..tostring(love.timer.getFPS()))
			ui:layoutRow('dynamic', 20, 2)
			ui:label("State")
			if game.current_state then
			    ui:label(game.current_state.name)
			end

			if ui:treePush('node',"Stats") then
				for k,v in pairs(self.stats) do
					ui:layoutRow('dynamic', 20, 2)
					ui:label(k)
					ui:label(tostring(v))
				end
				ui:treePop()
			end
			
			for _,scene in pairs(game.scenes) do
				if ui:treePush('tab',scene.name) then
					ui:layoutRow('dynamic', 20, 2)	
					scene.pause = ui:checkbox("Pause", scene.pause)
					scene.hide = ui:checkbox("Hide", scene.hide)
					for name,c in pairs(scene.cameras) do
						c:debugLayout(ui)
					end
					ui:label("Entity ( #"..tostring(#scene.entities)..")")
					for _,e in pairs(scene.entities) do
						if ui:treePush('node',e.name) then
							ui:layoutRow('dynamic', 15, 2)
							ui:label("tag : " .. tostring(e.tag))
							if e.layer then
								ui:label("layer : " .. tostring(e.layer.name))
							end
							ui:layoutRow('dynamic', 20, 2)
							e.pause = ui:checkbox("Pause", e.pause)
							e.hide = ui:checkbox("Hide", e.hide)
							--ui:layoutRow('dynamic', 20, 2)
							--ui:label("cron # " .. tostring(#e.crons))
							--ui:label("tween # " .. tostring(#e.tweens))
							--ui:layoutRow('dynamic', 20, 1)
							for _,c in pairs(e.systems) do
								--ui:layoutRow('dynamic', 175, 1)
								if ui:treePush('tab',tostring(c.__class.__name)) then
								--if ui:groupBegin(tostring(c), 'title','border','scrollbar') then
									c:debugLayout(ui)
									--ui:groupEnd()
									ui:treePop()
								end
							end
							ui:treePop()
						end
					end
					ui:treePop()
				end
			end
			--ui:groupEnd()
		--end
	end



	ui:windowEnd()
	ui:frameEnd()
end


function GUI:draw()
	love.graphics.setShader()
	self.stats = love.graphics.getStats()
	self.ui:draw()
end

return GUI