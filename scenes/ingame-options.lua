local M = {name='ingame-options'}

local menuengine = require'util.menuengine'
local menu
local util = require'util.scenes'

M.load = function()
	menu = menuengine.new(100, 100)
	menu:addEntry("Continue", util.load_scene, 'main')
	menu:addEntry("Disable creatures", util.load_scene, 'disable')
	menu:addEntry("Main menu", util.load_scene, 'main-menu')
end

M.keypressed = function(key)
	menuengine.keypressed(key)
end

M.update = function(dt)
	menu:update(dt)
end

M.mousemoved = function(x, y)
	menuengine.mousemoved(x, y)
end

M.draw = function()
	menu:draw()
end

return M
