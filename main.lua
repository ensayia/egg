utf8 = require ('utf8')
require 'lib.tserial'
random = love.math.random

require 'state.option'
require 'state.note'
require 'state.help'

lg = love.graphics	-- used everywhere, so we'll make it global

sys = {}

sys.status			= '[f1]: help, [f2]: options, [esc]: back, [esc][esc]: quit'
sys.font_size		= 32
sys.timer 			= 0
sys.egg				= lg.newImage('img/egg.png')
sys.countdown		= 0
sys.font 			= lg.newFont('font/dejavusansmono.ttf', sys.font_size)

-- using a global variable to change a global namespace, this is quite dangerous!
sys.state			= note -- or option, or help

function love.load()
	lg.setFont(sys.font)
	lg.setBackgroundColor(option.color_background)
	love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
	sys.timer = (sys.timer + dt*1.5)%1
	if sys.countdown >= 0 then
		sys.countdown = sys.countdown - (dt * 2)
	else
		sys.status = '[f1]: help, [f2]: options, [esc]: back, [esc][esc]: quit'
	end
end


function love.draw()
	sys.state.draw()
	
	lg.setColor(option.color_line)
	lg.rectangle('fill', 0, 0, lg.getWidth(), 46)
	lg.rectangle('fill', 0, lg.getHeight() - 44, lg.getWidth(), 50)
	lg.setColor(option.color_accent)
	lg.print('egg: '..sys.status, 20, lg.getHeight() - 42)
	lg.draw(sys.egg, 4, 4, 0, .3, .3)
	lg.setColor(option.color_white)
end

function love.keypressed(key) sys.state.keypressed(key) end

function love.textinput(t) sys.state.textinput(t) end
