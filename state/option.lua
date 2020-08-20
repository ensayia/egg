option = {}

option.color_accent 	= {.43, .40, .41, 1}
option.color_line 		= {.21, .18, .18, 1}
option.color_background = {.23, .20, .21, 1}
option.color_white		= {.90, .90, .90, 1}

option.kb_up			= 'up'
option.kb_down			= 'down'
option.kb_left			= 'left'
option.kb_right			= 'right'
option.kb_home			= 'home'
option.kb_end			= 'end'
option.kb_return		= 'return'
option.kb_space			= 'space'
option.kb_mod			= 'lctrl'
option.kb_escape		= 'escape'
option.kb_new_node		= 'n'
option.kb_save			= 's'
option.kb_delete		= 'delete'
option.kb_edit_node		= 'e'
option.kb_help			= 'f1'
option.kb_option		= 'f2'

function option.draw()
	lg.print('nothing here yet', 32, 78)
end

function option.keypressed(key)
	if key == option.kb_escape then
		sys.state = note
	end
end

function option.textinput()
end
