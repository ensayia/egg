note = {}

note.mode 				= 'node_select' -- node_select, node_edit, text_edit
note.current_node		= 1
note.cursor				= 1
note.depth				= 1
note.depth_max			= 18
note.text_cursor		= 0
note.text_current_line	= 1

note.node = {}
note.node_vis = {}

function note.save_data()
	local _s = TSerial.pack(note.node)
	love.filesystem.write('data.lua', _s)
end

if love.filesystem.getInfo('data.lua') then
	note.node = TSerial.unpack(love.filesystem.read('data.lua'))
else
	love.filesystem.newFile('data.lua')
	note.node[1] = {
		name = 'starter node',
		depth = 0,
		collapsed = false,
		text = {{'h','e','l','l','o',' ','w','o','r','l','d'}}
		}
	local _s = TSerial.pack(note.node)
	love.filesystem.write('data.lua', _s)
end

function note.generate_node_vis()
	local vis = {}
	local _space = 0
	local _col_depth = 0
	local _collapsed = false
	for k, v in ipairs(note.node) do
		v.index = k
		if v.depth <= _col_depth then
			_collapsed = false
		end
		if not _collapsed then
			vis[#vis+1] = note.node[k]
		end
		if v.collapsed and not _collapsed then
			_col_depth = v.depth
			_collapsed = true
		end
	end
	note.node_vis = vis
end

note.generate_node_vis()

-- long ass line I use fucking eveywhere
function note._line_length() return #note.node_vis[note.cursor].text[note.text_current_line] end


function note.draw()
	local _a = ''
	if love.window.hasFocus() then
		if sys.timer > 1/8 then _a = '░' end
		if sys.timer > 2/8 then _a = '▒' end
		if sys.timer > 3/8 then _a = '▓' end
		if sys.timer > 4/8 then _a = '█' end
		if sys.timer > 5/8 then _a = '▓' end
		if sys.timer > 6/8 then _a = '▒' end
		if sys.timer > 7/8 then _a = '░' end
	else
		_a = '░'
	end
	for k, v in ipairs(note.node_vis) do
		if note.mode == 'node_edit' and note.node_vis[note.cursor] == v then
			if v.collapsed then
				lg.print(v.name..' +'.._a, sys.font_size * (v.depth + 1), ((sys.font_size * k) - sys.font_size) + sys.font_size)
			else
				lg.print(v.name.._a, sys.font_size * (v.depth + 1), ((sys.font_size * k) - sys.font_size) + sys.font_size)
			end
		else
			if v.collapsed then
				lg.print(v.name..' +', sys.font_size * (v.depth + 1), ((sys.font_size * k) - sys.font_size) + sys.font_size)
			else
				lg.print(v.name, sys.font_size * (v.depth + 1), ((sys.font_size * k) - sys.font_size) + sys.font_size)
			end
		end
		if note.node_vis[note.cursor] == v then
			lg.print('>', 4, ((sys.font_size * k) - sys.font_size) + sys.font_size)
		end
	end
	local txt = note.build_text()
	local _len = #note.node_vis[note.cursor].text
	for k, v in ipairs(txt) do
		lg.print(v, sys.text_block_offset + sys.font_size, k * sys.font_size)
	end
	if note.mode == 'text_edit' then
		local _len = note.cursor_position()
		lg.print(_len.._a, sys.text_block_offset + sys.font_size, note.text_current_line * sys.font_size)
	end
	lg.setColor(option.color_line)
	lg.rectangle('fill', sys.text_block_offset - sys.font_size, 0, sys.font_size, lg.getHeight() - 20)
	lg.setColor(option.color_white)	
end

function note.node_select(key)
	local ind = note.node_vis[note.cursor].index
	local n = note.node[ind]
	if key == option.kb_new_node then
		if note.node_vis[note.cursor].depth < note.depth_max then
			if love.keyboard.isDown('lctrl') then
				table.insert(note.node, note.current_node, {name = 'new primary node' , depth = note.node[note.current_node].depth, collapsed = false, text = {{'n','e','w',' ','n','o','d','e'}}})
				sys.status = 'created new primary node'
			else
				table.insert(note.node, note.current_node + 1, {name = 'new subnode', depth = note.node[note.current_node].depth + 1, collapsed = false , text = {{'n','e','w',' ','n','o','d','e'}}})
				sys.status = 'created sub node'
			end
		else
			sys.status = 'maximum node depth reached, cannot create sub node here'
		end
		note.generate_node_vis()
	elseif key == option.kb_delete then
		if note.node[ind + 1] and note.node[ind + 1].depth <= n.depth then
			table.remove(note.node, note.current_node)
		else
			local _var = #note.node
			for i = note.current_node + 1, #note.node do
				if note.node[i].depth > note.node[note.current_node].depth then
					_var = i
				else
					break
				end
			end
			for i = _var, note.current_node + 1, -1 do
				table.remove(note.node, i)
			end
			table.remove(note.node, note.current_node)
		end
		if #note.node == 0 then table.insert(note.node, {name = 'New Node'..math.random(100, 999), depth = 0, collapsed = false, text = {{'N','e','w',' ','N','o','d','e'}}}) end
		note.generate_node_vis()
		note.cursor = math.min(note.cursor, #note.node_vis)
		note.current_node = note.node_vis[note.cursor].index
		sys.status = 'deleted node'
	elseif key == option.kb_space then
		if note.node[ind + 1] and note.node[ind + 1].depth > n.depth then
			n.collapsed = not n.collapsed
			note.generate_node_vis()
		end
	elseif love.keyboard.isDown(option.kb_mod) and key == option.kb_up then
		if note.node_vis[note.cursor].depth == note.node_vis[note.cursor - 1].depth then
			note.node[note.node_vis[note.cursor - 1].index], note.node[note.node_vis[note.cursor].index] = note.node[note.node_vis[note.cursor].index], note.node[note.node_vis[note.cursor - 1].index]
		end
		note.generate_node_vis()
	elseif love.keyboard.isDown(option.kb_mod) and key == option.kb_down then
		if note.node_vis[note.cursor].depth == note.node_vis[note.cursor + 1].depth then
			note.node[note.node_vis[note.cursor + 1].index], note.node[note.node_vis[note.cursor].index] = note.node[note.node_vis[note.cursor].index], note.node[note.node_vis[note.cursor + 1].index]
		end
		note.generate_node_vis()
	elseif key == option.kb_down then
		note.cursor = math.min(note.cursor + 1, #note.node_vis)
		note.current_node = note.node_vis[note.cursor].index
		note.text_cursor = 0
	elseif key == option.kb_up then
		note.cursor = math.max(note.cursor - 1, 1)
		note.current_node = note.node_vis[note.cursor].index
		note.text_cursor = 0
	elseif key == option.kb_return then
		note.mode = 'text_edit'
	elseif love.keyboard.isDown(option.kb_mod) and key == option.kb_edit_node then
		note.mode = 'node_edit'
	elseif love.keyboard.isDown(option.kb_mod) and key == option.kb_save then
		note.save_data()
		sys.status = 'saved on '..os.date()
	elseif key == option.kb_escape then
		if sys.countdown > 0 then
			note.save_data()
			love.event.quit()
		else
			sys.status = 'tap [esc] again to quit'
			sys.countdown = 1
		end
	elseif key == option.kb_option then
		sys.state = option
	elseif key == option.kb_help then
		sys.state = help
	end
end

function note.node_edit(key)
	if key == 'backspace' then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(note.node_vis[note.cursor].name, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            note.node_vis[note.cursor].name = string.sub(note.node_vis[note.cursor].name, 1, byteoffset - 1)
        end
    end
    if key == option.kb_return then
		note.mode = 'node_select'
	end
end

function note.text_edit(key)
	if key == 'backspace' then
		if note.text_cursor == 0 then
			if note._line_length() == 0 then
				if note.text_current_line > 1 then
					table.remove(note.node_vis[note.cursor].text, note.text_current_line)
					note.text_current_line = note.text_current_line - 1
					note.text_cursor = note._line_length()
				end
			end
		else
			if note._line_length() > 0 then
				table.remove(note.node_vis[note.cursor].text[note.text_current_line], note.text_cursor)
				note.text_cursor = note.text_cursor - 1
			end
		end
    elseif key == option.kb_escape then
		note.mode = 'node_select'
	elseif key == option.kb_return then
		table.insert(note.node_vis[note.cursor].text, note.text_current_line + 1, {})
		note.text_current_line = note.text_current_line + 1
		note.text_cursor = 0
	elseif key == option.kb_down then
		if note.text_current_line < #note.node_vis[note.cursor].text then
			note.text_current_line = note.text_current_line + 1
			note.text_cursor = math.min(note.text_cursor, note._line_length())
		end
	elseif key == option.kb_up then
		if note.text_current_line > 1 then
			note.text_current_line = note.text_current_line -1
			note.text_cursor = math.min(note.text_cursor, note._line_length())
		end
	elseif key == option.kb_right then
		if note.text_cursor < note._line_length() then
			note.text_cursor = note.text_cursor + 1
		end
	elseif key == option.kb_left then
		if note.text_cursor > 0 then
			note.text_cursor = note.text_cursor - 1
		end
	elseif key == option.kb_home then
		note.text_cursor = 0
	elseif key == option.kb_end then
		note.text_cursor = note._line_length()
    end
end

function note.build_text()
	local _t = {}
		for _k, _v in ipairs(note.node_vis[note.cursor].text) do
			local _s = ''
			for _l, _w in ipairs(note.node_vis[note.cursor].text[_k]) do
				_s = _s .. _w
			end
		table.insert(_t, _s)
		end
	return _t
end

function note.keypressed(key)
	if note.mode == 'node_select' then
			if key then note.node_select(key) end
		elseif note.mode == 'node_edit' then
			if key then note.node_edit(key) end
		elseif note.mode == 'text_edit' then
			if key then note.text_edit(key) end
		end
	end

function note.textinput(t)
	if note.mode == 'node_edit' then
		note.node_vis[note.cursor].name = note.node_vis[note.cursor].name .. t
	elseif note.mode == 'text_edit' then
		table.insert(note.node_vis[note.cursor].text[note.text_current_line], note.text_cursor + 1, t)
		note.text_cursor = note.text_cursor + 1
	end	
end

function note.cursor_position()
	local _len = ''
	if note.text_cusor == 0 then
		return ''
	else
		for i = 0, note.text_cursor -1 do
			_len = _len .. ' '
		end
	end
	return _len
end
