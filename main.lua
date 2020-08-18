local utf8 = require ('utf8')
require 'tserial'
random = love.math.random

sys_font_size		= 32
sys_mode 			= 'node_select' -- node_select, node_edit, text_edit
sys_node			= 1
cursor				= 1
sys_depth			= 1
depth_max			= 18
sys_node_spacing	= 20
sys_node_offset		= 32
sys_timer 			= 0
text_cursor			= 0
text_current_line	= 1
sys_status			= 'double tap [esc] to quit'
img_egg				= love.graphics.newImage('egg.png')
sys_countdown		= 0

color_accent 		= {.43, .40, .41, 1}
color_line 			= {.21, .18, .18, 1}
color_background 	= {.23, .20, .21, 1}
color_white			= {.90, .90, .90, 1}

kb_up				= 'up'
kb_down				= 'down'
kb_left				= 'left'
kb_right			= 'right'
kb_home				= 'home'
kb_end				= 'end'
kb_return			= 'return'
kb_space			= 'space'
kb_mod				= 'lctrl'
kb_escape			= 'escape'
kb_new_node			= 'n'
kb_save				= 's'
kb_delete			= 'd'
kb_edit_node		= 'e'

node = {}
node_vis = {}

function save_data()
	local _s = TSerial.pack(node)
	love.filesystem.write('data.lua', _s)
end

if love.filesystem.getInfo('data.lua') then
	node = TSerial.unpack(love.filesystem.read('data.lua'))
else
	love.filesystem.newFile('data.lua')
	node[1] = {
		name = 'Starter Node',
		depth = 0,
		collapsed = false,
		text = {{'H','e','l','l','o',' ','W','o','r','l','d'}}
		}
	local _s = TSerial.pack(node)
	love.filesystem.write('data.lua', _s)
end

function generate_node_vis()
	local vis = {}
	local _space = 0
	local _col_depth = 0
	local _collapsed = false
	for k, v in ipairs(node) do
		v.index = k
		if v.depth <= _col_depth then
			_collapsed = false
		end
		if not _collapsed then
			vis[#vis+1] = node[k]
		end
		if v.collapsed and not _collapsed then
			_col_depth = v.depth
			_collapsed = true
		end
	end
	node_vis = vis
end

generate_node_vis()

-- long ass line I use fucking eveywhere
function _line_length() return #node_vis[cursor].text[text_current_line] end

function love.load()
	fontText = love.graphics.newFont('dejavusansmono.ttf', sys_font_size)
	love.graphics.setFont(fontText)
	love.graphics.setBackgroundColor(color_background)
	love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
	sys_timer = (sys_timer + dt*1.5)%1
	if sys_countdown >= 0 then sys_countdown = sys_countdown - (dt * 4) end
end

function love.draw()
	
	local _a = ''
	if love.window.hasFocus() then
		if sys_timer > 1/8 then _a = '░' end
		if sys_timer > 2/8 then _a = '▒' end
		if sys_timer > 3/8 then _a = '▓' end
		if sys_timer > 4/8 then _a = '█' end
		if sys_timer > 5/8 then _a = '▓' end
		if sys_timer > 6/8 then _a = '▒' end
		if sys_timer > 7/8 then _a = '░' end
	else
		_a = '░'
	end
	for k, v in ipairs(node_vis) do
		if v.collapsed then
			if v.depth > 0 then
				love.graphics.setColor(color_accent)
			else
				love.graphics.setColor(color_accent)
			end
			love.graphics.circle('fill', (sys_node_spacing * v.depth) + sys_node_spacing, ((sys_node_offset * k) - sys_node_offset) + sys_node_offset + 46, 4, 16)
			love.graphics.setColor(color_white)
		end
		love.graphics.print(v.name, (sys_node_spacing * v.depth) + sys_node_spacing + 16, ((sys_node_offset * k) - sys_node_offset) + sys_node_offset + 26)
	end
	love.graphics.setColor(color_accent)
	love.graphics.circle('line', 20, (cursor * sys_node_offset) + 46, 8, 16)
	love.graphics.setColor(color_white)
	local txt = build_text()
	local _len = #node_vis[cursor].text
	for k, v in ipairs(txt) do
		love.graphics.print(v, 630, 58 + ((k-1)*32))
	end
	local cursor_draw = text_cursor * (sys_node_spacing - 1)
	if sys_mode == 'text_edit' then
		love.graphics.print(_a, 630 + cursor_draw, 58 + ((text_current_line-1) * 32))
	end
	if sys_mode == 'node_edit' then
		love.graphics.print(_a, (#node_vis[cursor].name * 19) + (node_vis[cursor].depth * 19) + 38, ((cursor * sys_node_offset) - sys_node_offset) + 60)
	end
	love.graphics.setColor(color_line)
	love.graphics.rectangle('fill', 615, 8, 4,love.graphics.getHeight() - 20)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 46)
	love.graphics.rectangle('fill', 0, love.graphics.getHeight() - 44, love.graphics.getWidth(), 50)
	love.graphics.setColor(color_accent)
	love.graphics.print('egg: '..sys_status, 20, love.graphics.getHeight() - 42)
	love.graphics.draw(img_egg, 4, 4, 0, .3, .3)
	love.graphics.setColor(color_white)
	
end

function love.keypressed(key)
	if sys_mode == 'node_select' then
		if key then node_select(key) end
	elseif sys_mode == 'node_edit' then
		if key then node_edit(key) end
	elseif sys_mode == 'text_edit' then
		if key then text_edit(key) end
	end
end

function love.textinput(t)
	if sys_mode == 'node_edit' then
		node_vis[cursor].name = node_vis[cursor].name .. t
	elseif sys_mode == 'text_edit' then
		table.insert(node_vis[cursor].text[text_current_line], text_cursor + 1, t)
		text_cursor = text_cursor + 1
	end	
end

function node_select(key)
	local ind = node_vis[cursor].index
	local n = node[ind]
	if key == kb_new_node then
		if node_vis[cursor].depth < depth_max then
			if love.keyboard.isDown('lctrl') then
				table.insert(node, sys_node, {name = 'new primary node' , depth = node[sys_node].depth, collapsed = false, text = {{'n','e','w',' ','n','o','d','e'}}})
				sys_status = 'created new primary node'
			else
				table.insert(node, sys_node + 1, {name = 'new subnode', depth = node[sys_node].depth + 1, collapsed = false , text = {{'n','e','w',' ','n','o','d','e'}}})
				sys_status = 'created sub node'
			end
		else
			sys_status = 'maximum node depth reached, cannot create sub node here'
		end
		generate_node_vis()
	elseif key == kb_delete then
		if node[ind + 1] and node[ind + 1].depth <= n.depth then
			table.remove(node, sys_node)
		else
			local _var = #node
			for i = sys_node + 1, #node do
				if node[i].depth > node[sys_node].depth then
					_var = i
				else
					break
				end
			end
			for i = _var, sys_node + 1, -1 do
				table.remove(node, i)
			end
			table.remove(node, sys_node)
		end
		if #node == 0 then table.insert(node, {name = 'New Node'..math.random(100, 999), depth = 0, collapsed = false, text = {{'N','e','w',' ','N','o','d','e'}}}) end
		generate_node_vis()
		cursor = math.min(cursor, #node_vis)
		sys_node = node_vis[cursor].index
		sys_status = 'deleted node'
	elseif key == kb_space then
		if node[ind + 1] and node[ind + 1].depth > n.depth then
			n.collapsed = not n.collapsed
			generate_node_vis()
		end
	elseif key == kb_down then
		cursor = math.min(cursor + 1, #node_vis)
		sys_node = node_vis[cursor].index
		text_cursor = 0
	elseif key == kb_up then
		cursor = math.max(cursor - 1, 1)
		sys_node = node_vis[cursor].index
		text_cursor = 0
	elseif key == kb_return then
		sys_mode = 'text_edit'
	elseif love.keyboard.isDown(kb_mod) and key == kb_edit_node then
		sys_mode = 'node_edit'
	elseif love.keyboard.isDown(kb_mod) and key == kb_save then
		save_data()
		sys_status = 'saved on '..os.date()
	elseif key == kb_escape then
		if sys_countdown > 0 then
			save_data()
			love.event.quit()
		else
			sys_countdown = 1
		end
	end
end

function node_edit(key)
	if key == 'backspace' then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(node_vis[cursor].name, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            node_vis[cursor].name = string.sub(node_vis[cursor].name, 1, byteoffset - 1)
        end
    end
    if key == kb_return then
		sys_mode = 'node_select'
	end
end

function text_edit(key)
	if key == 'backspace' then
		if text_cursor == 0 then
			if _line_length() == 0 then
				if text_current_line > 1 then
					table.remove(node_vis[cursor].text, text_current_line)
					text_current_line = text_current_line - 1
					text_cursor = _line_length()
				end
			end
		else
			if _line_length() > 0 then
				table.remove(node_vis[cursor].text[text_current_line], text_cursor)
				text_cursor = text_cursor - 1
			end
		end
    elseif key == kb_escape then
		sys_mode = 'node_select'
	elseif key == kb_return then
		table.insert(node_vis[cursor].text, text_current_line + 1, {})
		text_current_line = text_current_line + 1
		text_cursor = 0
	elseif key == kb_down then
		if text_current_line < #node_vis[cursor].text then
			text_current_line = text_current_line + 1
			text_cursor = math.min(text_cursor, _line_length())
		end
	elseif key == kb_up then
		if text_current_line > 1 then
			text_current_line = text_current_line -1
			text_cursor = math.min(text_cursor, _line_length())
		end
	elseif key == kb_right then
		if text_cursor < _line_length() then
			text_cursor = text_cursor + 1
		end
	elseif key == kb_left then
		if text_cursor > 0 then
			text_cursor = text_cursor - 1
		end
	elseif key == kb_home then
		text_cursor = 0
	elseif key == kb_end then
		text_cursor = _line_length()
    end
end

function build_text()
	local _t = {}
		for _k, _v in ipairs(node_vis[cursor].text) do
			local _s = ''
			for _l, _w in ipairs(node_vis[cursor].text[_k]) do
				_s = _s .. _w
			end
		table.insert(_t, _s)
		end
	return _t
end
