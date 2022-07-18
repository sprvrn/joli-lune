[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

class State
	new: (game, name, options={}) =>
		@_name = name

		@game = game
		@assets = game.assets
		@settings = game.settings
		@input = game.input

		@nextState = options.next or {}

	-- callbacks
	onEnter: =>
	onExit: =>
	update: (dt) =>
	draw: =>
	-- end callbacks

	next: (nextStateNum=1, ...) =>
		if #@nextState == 0
			print "Warning, no next state specified from", @_name
			return
		@game\stateActivation @nextState[1], ...

return State