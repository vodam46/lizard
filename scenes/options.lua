local M = {name='options'}

local menuengine = require'util.menuengine'
local menu
local util = require'util.scenes'

M.load = function()
	menu = menuengine.new(100, 100)
	menu:addEntry("Main menu", util.load_scene, 'main-menu')
	menu:addEntry("Disable creatures", util.load_scene, 'disable')
	menu:addEntry("Toggle fullscreen", function()
		love.window.setFullscreen(not love.window.getFullscreen())
	end)
end

M.keypressed = function(key)
	menuengine.keypressed(key)
end

M.update = function()
	menu:update()
end

M.mousemoved = function(x, y)
	menuengine.mousemoved(x, y)
end

M.draw = function()
	menu:draw()
end

return M
