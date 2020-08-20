help = {}

help.items = {
	-- the spacing between the label and the key here should be spaces
	-- do not use tabs
	[1] = 	'keyboard shortcuts:',
	[2] = 	'',
	[3] = 	'node select:',
	[4] = 	' create new main node:             '..'['..option.kb_mod..']'..'+'..'['..option.kb_new_node..']',
	[5] = 	' create new sub node:              '..'['..option.kb_new_node..']',
	[6] = 	' edit node name:                   '..'['..option.kb_mod..']'..'+'..'['..option.kb_edit_node..']',
	[7] = 	' enter node to edit text:          '..'['..option.kb_return..']',
	[8] = 	' delete node (also subnodes):      '..'['..option.kb_delete..']',
	[9] = 	' collapse node:                    '..'['..option.kb_space..']',
	[10] = 	' navigation:                       '..'['..option.kb_up..']'..'/'..'['..option.kb_down..']',
	[11] = 	' save all data:                    '..'['..option.kb_mod..']'..'+'..'['..option.kb_save..']',
	[12] = 	' exit egg (saves on exit)          '..'['..option.kb_escape..']['..option.kb_escape..']',
	[13] = 	'',
	[14] =	'edit text:',
	[15] =	' text block navigation:            '..'['..option.kb_up..']'..'/'..'['..option.kb_down..']'..'/'..'['..option.kb_left..']'..'/'..'['..option.kb_right..']',
	[16] =	' new line:                         '..'['..option.kb_return..']',
	[17] =	' beginning/end of current line:    '..'['..option.kb_home..']'..'/'..'['..option.kb_end..']',
	[18] = 	' return to node select:            '..'['..option.kb_escape..']',
	[19] = 	'',
	[20] =  'press [esc] to exit this menu',
	
}

local _spacing = 32

function help.draw()
	for i = 1, #help.items do
		lg.print(help.items[i], 32, 56 + ((i - 1) * _spacing))
	end
end

function help.keypressed(key)
	if key == option.kb_escape then
		sys.state = note
	end
end

function help.textinput(t)
end
