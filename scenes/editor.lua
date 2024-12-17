local M = {name='editor'}

local scene = require'util.scenes'
local vector_l = require'util.vector'
local position = vector_l(0)
local screen_size

local menuengine = require'util.menuengine'
local menu

local creature = require'creature'
local edited_creature
local creature_string
--[
-- TODO:
-- select color
--]

local edit_mode -- part, leg, part-size, leg-size
local cur_leg

local renaming = false
local ask_if_rewrite = false
local file_name

local function save_creature()
	love.filesystem.remove(file_name)
	local ok, msg = love.filesystem.write(file_name, creature_string)
	if not ok then print(msg) end
end

M.load = function()
	menu = menuengine.new(100, 100)
	menu:addEntry("Main menu", scene.load_scene, 'main-menu')
	menu:addSep()
	menu:addEntry("Change mode - ", function()
		if edit_mode == 'part' then
			edit_mode = 'leg'
		elseif edit_mode == 'leg' then
			edit_mode = 'part'
		end
	end)
	menu:addEntry("Rename", function() renaming = true end)
	menu:addEntry("Save", function()
		creature_string = "return " .. require'inspect'(edited_creature)
		file_name = "user_creatures/"..edited_creature.name..".lua"

		if love.filesystem.getInfo(file_name, "file") ~= nil
			and not ask_if_rewrite then
			ask_if_rewrite = true
		else
			ask_if_rewrite = false
			save_creature()
		end
	end)
	menu:addEntry("New", function()
		edited_creature = require'util.copy'(require'creatures.default')
		table.insert(edited_creature.parts, {distance=0, size=0})
		edit_mode = 'part-size'
	end)

	edited_creature = require'util.copy'(require'creatures.default')
	table.insert(edited_creature.parts, {distance=0, size=0})
	edit_mode = 'part-size'
end

M.keypressed = function(key)
	if renaming then
		if key == 'backspace' then
			local byteoffset = require'utf8'.offset(edited_creature.name, -1)
			if byteoffset then
				edited_creature.name = string.sub(edited_creature.name, 1, byteoffset-1)
			end
		elseif key == 'return' then
			renaming = false
			return
		end
	end

	menuengine.keypressed(key)
end

M.mousepressed = function(x, y)
	if x > 450  and not ask_if_rewrite then
		if edit_mode == 'part' then
			local distance = 0
			for i = 1, #edited_creature.parts do
				distance = distance + edited_creature.parts[i].distance
			end
			local new_dist = (
				screen_size/2
				+ vector_l(distance, 0)
				- vector_l(x, y)
			).magnitude
			table.insert(edited_creature.parts, {
				distance=new_dist,
				size=0
			})
			edit_mode = 'part-size'

		elseif edit_mode == 'part-size' then
			edit_mode = 'part'


		elseif edit_mode == 'leg' then
			local distance = 0
			for i = 1, #edited_creature.parts do
				distance = distance + edited_creature.parts[i].distance
			end
			local offset = (
				vector_l(x, y)
				- screen_size/2
				- vector_l(distance, 0)
			)
			cur_leg = {
				offset=offset,
				segment=#edited_creature.parts,
				length=0
			}
			edit_mode = 'leg-size'

		elseif edit_mode == 'leg-size' then
			for side=-1, 1, 2 do
				table.insert(edited_creature.legs, {
					offset={
						x=-cur_leg.offset.x,
						y=-cur_leg.offset.y
					},
					segment=cur_leg.segment,
					length=cur_leg.length,
					side=side
				})
			end

			cur_leg = nil
			edit_mode = 'leg'
		end
	end
end

M.update = function(dt)
	menu:update(dt)
	if menu.entries[3].text ~= "Change mode - "..edit_mode then
		menu.entries[3].text = "Change mode - "..edit_mode
	end

	if edit_mode == 'part' then
	elseif edit_mode == 'part-size' then
		local distance = 0
		for i = 1, #edited_creature.parts do
			distance = distance + edited_creature.parts[i].distance
		end

		edited_creature.parts[#edited_creature.parts].size =
		(
			screen_size/2 + vector_l(distance, 0) -position
		).magnitude
	elseif edit_mode == 'leg' then
	elseif edit_mode == 'leg-size' then
		local distance = 0
		for i = 1, #edited_creature.parts do
			distance = distance + edited_creature.parts[i].distance
		end

		cur_leg.length = (
			screen_size/2
			+ vector_l(distance, 0)
			+ cur_leg.offset
			- position
		).magnitude
	end

end

M.mousemoved = function(x, y)
	menuengine.mousemoved(x, y)
	position.x, position.y = x, y
end

M.draw = function()
	screen_size = vector_l(love.graphics.getDimensions())
	menu:draw()
	creature.draw_bodyplan(
		edited_creature,
		screen_size / 2
	)
	if cur_leg ~= nil then
		local distance = 0
		for i = 1, #edited_creature.parts do
			distance = distance + edited_creature.parts[i].distance
		end

		love.graphics.line(
			screen_size.x / 2 + distance + cur_leg.offset.x,
			screen_size.y / 2 + cur_leg.offset.y,
			screen_size.x / 2 + distance + cur_leg.offset.x,
			screen_size.y / 2 + cur_leg.offset.y - cur_leg.length
		)
		love.graphics.line(
			screen_size.x / 2 + distance + cur_leg.offset.x,
			screen_size.y / 2 - cur_leg.offset.y,
			screen_size.x / 2 + distance + cur_leg.offset.x,
			screen_size.y / 2 - cur_leg.offset.y + cur_leg.length
		)
	end

	love.graphics.line(
		450,
		0,
		450,
		love.graphics.getHeight()
	)

	if renaming then
		love.graphics.print(edited_creature.name, 0, 0)
	end

	if ask_if_rewrite then
		love.graphics.print("This file already exists, rewrite?", 0, love.graphics.getFont():getHeight())
		love.graphics.print("(press Save again)", 0, love.graphics.getFont():getHeight()*2)
	end
end

M.textinput = function(t)
	if renaming then
		edited_creature.name = edited_creature.name..t
	end
end

return M
