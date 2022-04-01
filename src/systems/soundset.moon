[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

SoundSource = require "src.soundsource"

class SoundSet extends System
	__tostring: => return "soundset"
	onCreate: =>
		@sources = {}

	addSource: (name,sounds,play,loop,intro) =>
		if not sounds
			return
		@sources[name] = SoundSource(sounds, @)
		if play
			@sources[name]\play loop, intro

		return @sources[name]

	get: (name) =>
		return @sources[name]
		
	update: (dt) =>
		for _,source in pairs @sources
			source\update dt

	pause: (dur) =>
		for _,source in pairs @sources
			source\pause dur

	resume: (dur) =>
		for _,source in pairs @sources
			source\resume dur

	onDestroy: =>
		--@\pause!

return SoundSet
