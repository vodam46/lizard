local M = {name='main'}

local creature = require'creature'

local creatures = {}
local targets = {}

New_creatures = require'creatures'

local paused = false
local names = require'util.names'

local function create_creature(pos)
	local new_creature = require'util.copy'(New_creatures[math.random(#New_creatures)])
	new_creature.name = names[math.random(#names)]
	table.insert(creatures, creature.create_creature(
		new_creature,
		pos
	))
	table.insert(targets, {x=math.random(love.graphics.getWidth()), y=math.random(love.graphics.getHeight())})
end

function M.load()
	if #creatures == 0 then
		for _=1, 10, 1 do
			create_creature({
				x=math.random(love.graphics.getWidth()),
				y=math.random(love.graphics.getHeight())
			})
		end
	end
end

function M.draw()
	for i=1, #creatures, 1 do
		creature.draw_creature(creatures[i])
	end
	love.graphics.setColor(208.5/255,3/255,3/255)
	for i=1, #targets, 1 do
		love.graphics.circle("line", targets[i].x, targets[i].y, 10)
	end
	local font_height = love.graphics.getFont():getHeight()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(#creatures), 0, 0)
	love.graphics.print(tostring(love.timer.getFPS()), 0, font_height)
	if paused then love.graphics.print("paused", 0, 2*font_height) end
end

function M.update(dt)
	if not paused then
		for i=1, #creatures, 1 do
			creatures[i] = creature.update_creature(creatures[i], {targets[i]}, dt)
			for j=1, #targets, 1 do
				if (creatures[i].parts[1].pos.x-targets[j].x)^2
					+(creatures[i].parts[1].pos.y-targets[j].y)^2
					<= (creatures[i].parts[1].size+10)^2 then
					targets[j] = {
						x=math.random(love.graphics.getWidth()),
						y=math.random(love.graphics.getHeight())
					}
					break
				end
			end
		end
		-- for i=1, #creatures, 1 do
		-- 	creatures[i] = creature.update_creature(creatures[i], {targets[i]}, dt)
		-- 	if (creatures[i].parts[1].x-targets[i].x)^2
		-- 		+(creatures[i].parts[1].y-targets[i].y)^2
		-- 		<= (creatures[i].parts[1].size+10)^2 then
		-- 		targets[i] = {x=math.random(love.graphics.getWidth()), y=math.random(love.graphics.getHeight())}
		-- 	end
		-- end
	end
end

function M.mousepressed(x, y, button)
	if button == 1 then
		create_creature({x=x, y=y})
	elseif button == 2 then
		table.insert(targets, {x=x, y=y})
	end
end

function M.keypressed(key)
	if key == "space" then
		paused = not paused
	elseif key == "r" then
		creatures = {}
		targets = {}
		init_creatures()
	elseif key == "q" then
		love.event.quit(0)
	elseif key == 'escape' then
		require'util.scenes'.load_scene('ingame-options')
	end
end

return M
