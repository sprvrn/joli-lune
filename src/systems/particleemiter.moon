[[
joli-lune
small framework for love2d
MIT License (see licence file)
]]

System = require "src.systems.system"

class ParticleEmiter extends System
	__tostring: => return "particleemiter"
	onCreate: (system,mode,delay) =>
		@systems = {}
		if system
			@\addSystem(system, mode, delay)

	addSystem: (system,mode="every",delay=1) =>
		time = nil

		emitfunc= ->
			@\emit system

		if mode == "every"
			timer = @\cron mode,delay,emitfunc
		elseif mode == "once"
			emitfunc!

		table.insert @systems, {:system,:mode,:delay,:timer}

	emit: (sys=@systems[1]) =>

		x,y,z = @position\get!
		@entity.scene\particle sys,x,y,z,@entity.layer.name

return ParticleEmiter