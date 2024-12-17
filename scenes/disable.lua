local M = {name="disable"}

local disabled = {}
local all_creatures = require'creatures'
local menu
local menuengine = require'util.menuengine'
local scenes = require'util.scenes'
local cur_creature = nil
local cursor = {x=0, y=0}

local function toggle(name)
	local str = ""
	if disabled[name] then
		local c = disabled[name]
		disabled[name] = nil
		table.insert(all_creatures, c)
		str = ": enabled"
	else
		for i, c in pairs(all_creatures) do
			if c.name == name then
				disabled[name] = c
				table.remove(all_creatures, i)
				str = ": disabled"
				break
			end
		end
	end

	menu.entries[menu.cursor].text = name..str
end

M.load = function()
	menu = menuengine.new(0,0)
	menu:addEntry("Back", function()
		New_creatures = require'util.copy'(all_creatures)
		scenes.load_scene(-1)
	end)
	menu:addSep()
	for _, v in pairs(all_creatures) do
		menu:addEntry(v.name..(disabled.name and ": disabled" or ": enabled"), toggle, v.name)
	end
end
M.draw = function()
	menu:draw()
	if cur_creature then
		require'creature'.draw_creature(cur_creature)
	end
end
M.update = function(dt)
	menu:update()
	local name = menu.entries[menu.cursor].args
	if not cur_creature or cur_creature.name ~= name then
		local body_plan = nil
		if disabled.name then
			body_plan = disabled.name
		else
			for _, v in pairs(all_creatures) do
				if v.name == name then
					body_plan = v
				end
			end
		end
		if body_plan then
			cur_creature = require'creature'.create_creature(body_plan, cursor)
		end
	end
	if cur_creature then
		cur_creature = require'creature'.update_creature(cur_creature, {cursor}, dt)
	end
end
M.keypressed = function(key)
	menuengine.keypressed(key)
end
M.mousemoved = function(x, y)
	menuengine.mousemoved(x, y)
	cursor = {x=x, y=y}
end

return M
