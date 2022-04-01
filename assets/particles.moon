(game) ->
	{
		smoke:{
			colors:{{0.5,0.5,0.5,1}, {0.8,0.8,0.8,1}, {1,1,1,1}},
			lifetime:{1,1.5},
			vx:{'linear',-40,40},
			vy:{'linear',-10,-60},
			size:{'inExpo',5,0},
			rate:10
		},
		text:{
			lifetime:{1,1},
			vx:{'linear',-20,20},
			vy:{'linear',-10,-60},
			text:"some text"
		},
		bunny:{
			colors:{{1,0,1,1}},
			alpha:{'linear',1,0},
			lifetim: {0.5,1},
			vx:{'linear',-50,50},
			vy:{'linear',-50,50},
			sprite:game.assets.sprites.bunny,
			options:{anim:"iddle"},
		}
	}
