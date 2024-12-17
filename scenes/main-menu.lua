local M = {name='main-menu'}

local menuengine = require'util.menuengine'
local menu
local scenes = require'util.scenes'
local target
local creatures

M.load = function()
	menu = menuengine.new(100, 100)
	menu:addEntry("Start", scenes.load_scene, 'main')
	menu:addEntry("Options", scenes.load_scene, 'options')
	menu:addEntry("Editor", scenes.load_scene, 'editor')
	menu:addSep()
	menu:addEntry("Quit", love.event.quit)

	local c = require'creatures'
	creatures = {require'creature'.create_creature(c[math.random(#c)], {x=0,y=0})}
end

M.keypressed = function(key)
	menuengine.keypressed(key)
end

M.update = function(dt)
	menu:update()
	local v = creatures[1].parts[1].pos - require'util.vector'(target.x, target.y)
	-- TODO: fix this - should be vector already
	if require'util.vector'(v.x, v.y).magnitude > 10 then
		creatures[1] = require'creature'.update_creature(creatures[1], {target}, dt)
	end
end

M.mousemoved = function(x, y)
	menuengine.mousemoved(x, y)
	target = {x=x, y=y}
end

M.draw = function()
	menu:draw()
	require'creature'.draw_creature(creatures[1])
end

return M
