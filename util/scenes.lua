local M = {}

local last_scene = 'main'
M.load_scene = function(name)
	if name == -1 then
		last_scene, Cur_scene = Cur_scene, last_scene
	else
		last_scene = Cur_scene
		Cur_scene = name
	end

	if not Scenes[Cur_scene].load_ran and Scenes[Cur_scene].load then
		Scenes[Cur_scene].load_ran = true
		Scenes[Cur_scene].load()
	end
end

return M
