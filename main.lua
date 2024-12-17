Scenes = require'scenes'
Cur_scene = 'main-menu'

function love.load()
	math.randomseed(os.time())
	love.window.setFullscreen(true)
	-- TODO: make it look better
	love.graphics.setFont(
		love.graphics.newFont("NotoSansMono.ttf", 20, "mono")
	)
	love.filesystem.setIdentity("lizard")

	if Scenes[Cur_scene].load then
		Scenes[Cur_scene].load()
	end
end

function love.draw()
	if Scenes[Cur_scene].draw then
		Scenes[Cur_scene].draw()
	end
end
function love.update(dt)
	if Scenes[Cur_scene].update then
		Scenes[Cur_scene].update(dt)
	end
end
function love.keypressed(key)
	if Scenes[Cur_scene].keypressed then
		Scenes[Cur_scene].keypressed(key)
	end
end
function love.keyreleased(key)
	if Scenes[Cur_scene].keyreleased then
		Scenes[Cur_scene].keyreleased(key)
	end
end
-- function love.mousemoved(x, y, dx, dy, isTouch)
function love.mousemoved(x, y)
	if Scenes[Cur_scene].mousemoved then
		-- Scenes[Cur_scene].mousemoved(x, y, dx, dy, isTouch)
		Scenes[Cur_scene].mousemoved(x, y)
	end
end
function love.mousepressed(x, y, button)
	if Scenes[Cur_scene].mousepressed then
		Scenes[Cur_scene].mousepressed(x, y, button)
	end
end
function love.textinput(t)
	if Scenes[Cur_scene].textinput then
		Scenes[Cur_scene].textinput(t)
	end
end
