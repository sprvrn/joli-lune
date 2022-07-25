[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

cron = require "libs.cron"
tween = require "libs.tween"

class System
	new: (entity) =>
		@entity = entity
		@game = entity.game
		@assets = entity.game.assets
		@settings = entity.game.settings
		@input = entity.game.input
		@position = entity.position

		@tweens = {}
		@crons = {}
	-- callbacks
	onCreate: =>
	update: (dt) =>
	updateAfter: (dt) =>
	draw: =>
	onDestroy: =>
	onRightClick: =>
	onLeftClick: =>
	onLeftClickHold: =>
	onLeftClickUp: =>
	onMiddleClick: =>
	onDoubleClick: =>
	hover: =>
	hoverEnter: =>
	hoverQuit: =>
	onStay: (other) =>
	onEnter: (other) =>
	onLeave: (other) =>
	onDragInit: (x,y) =>
	onDragDrop: (x,y) =>
	-- end callbacks

	updateCron: (dt) =>
		for cron in *@crons
			if cron and cron\update dt 
				table.remove @crons, table.index_of(@crons,cron)

	updateTween: (dt) =>
		for tween in *@tweens
			if tween and tween\update dt
				table.remove @tweens, table.index_of(@tweens,tween)

	cron: (type, delay, callback, ...) =>
		call = cron.after
		if type == "every"
			call = cron.every
		c = call delay,callback,...
		table.insert @crons, c 
		return c

	tween: (duration, target, easing="linear", subject=@) =>
		t = tween.new duration, subject, target, easing
		table.insert @tweens, t 
		return t

	debugLayout: (ui,tab=@) =>
		for k,v in pairs tab
			if k~="position" and k ~="entity" and k~="game" and k~="input" and k~="assets" and k~="settings" and k~="tweens" and k~="crons"
				t = type v
				if t=="number"
					ui\layoutRow 'dynamic', 20, 2
					@[k] = ui\property k,-10000000,tab[k],10000000,1,1
				elseif t=="string"
					ui\layoutRow 'dynamic', 25, 2
					ui\label(k)
					ui\edit('field',{value:tab[k]})
				elseif t=="table"
					if ui\treePush 'node',k.." #"..#v.." "..tostring(v)
						@\debugLayout(ui,v)
						ui\treePop!
				elseif t=="boolean"
					ui\layoutRow 'dynamic',20,1
					tab[k] = ui\checkbox(k, tab[k])
				else
					ui\layoutRow 'dynamic',20,2
					ui\label(k)
					ui\label(tostring(v))
return System
