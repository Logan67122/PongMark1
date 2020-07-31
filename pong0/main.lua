WIN_WIDTH = 1200
WIN_HEIGHT = 600

VIR_WIDTH = 400
VIR_HEIGHT = 200

PADDLESPEED = 200

Class = require 'Class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()
	math.randomseed(os.time())

	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong1.0')

	smallfont = love.graphics.newFont('font.ttf', 8)
	scorefont = love.graphics.newFont('font.ttf', 32)

	sound ={
		['paddle_hit'] = love.audio.newSource('hit_paddle.wav', 'static'),
		['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
		['scored'] = love.audio.newSource('score.wav', 'static')
	}

	push:setupScreen(VIR_WIDTH, VIR_HEIGHT, WIN_WIDTH, WIN_HEIGHT, {
		fullscreen = false,
		vsync = true,
		resizable = true
	})

	player1sc = 0
	player2sc = 0

	servingp = math.random(2) == 1 and 1 or 2

	player1 = Paddle(10, 30, 5, 20) 
	player2 = Paddle(VIR_WIDTH - 15, VIR_HEIGHT - 30, 5, 20)

	ball = Ball(VIR_WIDTH / 2 - 2, VIR_HEIGHT / 2 - 2, 5, 5)

	gamestate = 'start'
end

function love.resize(w, h)
	push:resize(w, h)
end


function love.update(dt)
	if gamestate == 'play' then
		if ball:collide(player1) then
			ball.dx = -ball.dx
			ball.x = player1.x + 5
			sound['paddle_hit']:play()
		end
		if ball:collide(player2) then
			ball.dx = -ball.dx
			ball.x = player2.x - 4
			sound['paddle_hit']:play()
 		end

	 	if ball.y <= 0 then
			ball.dy = -ball.dy
			ball.y = 0
			sound['wall_hit']:play()
		elseif ball.y >= VIR_HEIGHT - 4 then
			ball.dy = -ball.dy
			ball.y = VIR_HEIGHT - 4
			sound['wall_hit']:play()
		end

		if ball.x <= 0 then
			player2sc = player2sc + 1
			sound['scored']:play()
			servingp = 1
			ball:reset()
			ball.dx = 200
			gamestate = 'serve'
		elseif ball.x >= VIR_WIDTH - 4 then
			player1sc = player1sc + 1
			sound['scored']:play()
			servingp = 2
			ball:reset()
			ball.dx = -200
			gamestate = 'serve'
		end

		if love.keyboard.isDown('w') then
			player1.dy = -PADDLESPEED
		elseif love.keyboard.isDown('s') then
			player1.dy = PADDLESPEED
		else
			player1.dy = 0
		end

		if love.keyboard.isDown('up') then
			player2.dy = -PADDLESPEED
		elseif love.keyboard.isDown('down') then
			player2.dy = PADDLESPEED
		else
			player2.dy = 0
		end

		if player1sc == 10 or player2sc == 10 then
			gamestate = 'victory'
		end
		ball:update(dt)

		player1:update(dt)
		player2:update(dt)
	end
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'return' or key == 'enter' then
		if gamestate == 'victory' then
			player1sc = 0
			player2sc = 0
			ball:reset()
		end
		gamestate = 'play'
	elseif key == 'r' or key == 'R' then
		ball:reset()
		player1sc = 0
		player2sc = 0
	end
end

function love.draw()
	push:apply('start')
	
	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
	
	love.graphics.setFont(smallfont)
	if gamestate == 'start' then
		love.graphics.printf('Press Enter to play!', 0, 20, VIR_WIDTH, 'center')
	elseif gamestate == 'play' then
		love.graphics.printf('Game in progress!', 0, 20, VIR_WIDTH, 'center')
	elseif gamestate == 'serve' then
		love.graphics.printf('Player '..tostring(servingp)..' press Enter to serve!', 0, 20, VIR_WIDTH, 'center')
	end
	love.graphics.setFont(scorefont)
	love.graphics.print(player1sc, VIR_WIDTH / 2 - 50, VIR_HEIGHT / 3)
	love.graphics.print(player2sc, VIR_WIDTH / 2 + 30, VIR_HEIGHT / 3 )
	
	if gamestate == 'victory' then
		love.graphics.setFont(smallfont)
		love.graphics.printf('player '.. tostring(player1sc == 10 and 1 or 2).. ' won the game! \n Press enter to restart', 0,20, VIR_WIDTH, 'center')
	else
		ball:render()
		displayFPS()
	end


	player1:render()
	player2:render()

	push:apply('end')
end

function displayFPS()
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.setFont(smallfont)
	love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 40, 20)
	love.graphics.setColor(1, 1, 1, 1)
end