local M = {}
local vector_l = require'util.vector'

-- local creature = {
--	name = "",
--	color = {r=0, g=0, b=0},
-- 	parts = {
-- 		{
-- 			pos = {x=0, y=0}
-- 			size=0,
-- 			distance=0,
-- 			angle=0
-- 		}
-- 	},
-- 	legs = {
-- 		{
-- 			pos = {x=0, y=0}
-- 			length=0,
-- 			segment=1,
-- 			side=1,	-- or -1
-- 			elbow={x=0,y=0}
-- 		}
-- 	},
-- 	sides = {
-- 		{
-- 			x1=0,
-- 			y1=0,
-- 			x2=0,
-- 			y2=0
-- 		}
-- 	}
-- }

M.create_creature = function(body_plan, position)
	local creature = require'util.copy'(body_plan)

	for i=1, #creature.parts, 1 do
		creature.parts[i].pos = vector_l(position.x, position.y)
		creature.parts[i].angle = 0
	end
	for i=1, #creature.legs, 1 do
		creature.legs[i].pos = vector_l(position.x, position.y)
		creature.legs[i].elbow = position
	end
	creature.sides = {}

	return creature
end

-- TODO: if angle is bigger than allowed angle, rotate
M.update_body_part = function(creature, i, speed, target)
	if target then
		if not speed then speed = 50 end
		local cur = creature.parts[i].pos
		local distance = creature.parts[i].distance
		local angle = creature.parts[i].angle
		local vector = vector_l(target.x, target.y) - cur
		local magnitude = vector.magnitude
		if magnitude > distance then
			cur = vector_l(
				cur.x + vector.x/magnitude*speed,
				cur.y + vector.y/magnitude*speed
			)
			angle = math.atan2(vector.y, vector.x)
		end
		creature.parts[i].pos = cur
		creature.parts[i].angle = angle
	end
	return creature
end

M.update_leg = function(creature, i)
	local leg = creature.legs[i]
	local body_part = creature.parts[leg.segment]
	local shoulder
	local angle = body_part.angle
	-- TODO: could be better? possibly .rotate() function?
	shoulder = body_part.pos + (leg.offset and vector_l(
		leg.offset.x*math.cos(angle) - leg.side*leg.offset.y*math.sin(angle),
		leg.offset.x*math.sin(angle) + leg.side*leg.offset.y*math.cos(angle)
	) or 0)

	local dir_leg = leg.pos - shoulder

	local distance = dir_leg.magnitude
	if distance > leg.length or distance < body_part.size then
		local dir = vector_l(
			math.cos(angle + leg.side*math.pi/6),
			math.sin(angle + leg.side*math.pi/6)
		)
		local magnitude = dir.magnitude
		leg.pos = shoulder + (dir / magnitude) * leg.length
		creature.legs[i] = leg
	end

	local l = math.sqrt(leg.length^2-dir_leg.x^2-dir_leg.y^2)/4
	-- TODO: there has to be a better way to do this
	local elbow = shoulder + dir_leg / 2 +
		vector_l(dir_leg.y, dir_leg.x)/distance*l*leg.side*vector_l(-1, 1)
	creature.legs[i].elbow = elbow

	return creature
end

M.update_sides = function(creature)
	for i=2, #creature.parts, 1 do
		local vector = creature.parts[i].pos - creature.parts[i-1].pos
		local d = vector.magnitude

		local angle = math.acos(math.abs(creature.parts[i].size-creature.parts[i-1].size)/d)

		local vector_left, vector_right
		local angle_l, angle_r
		if creature.parts[i].size <= creature.parts[i-1].size then
			angle_l = angle
			angle_r = 2*math.pi-angle
		else
			angle_l = math.pi-angle
			angle_r = math.pi+angle
		end
		-- TODO: rewrite this
		vector_left = {
			x = (vector.x*math.cos(angle_l) - vector.y*math.sin(angle_l)) / d,
			y = (vector.x*math.sin(angle_l) + vector.y*math.cos(angle_l)) / d
		}
		vector_right= {
			x = (vector.x*math.cos(angle_r) - vector.y*math.sin(angle_r)) / d,
			y = (vector.x*math.sin(angle_r) + vector.y*math.cos(angle_r)) / d
		}
		creature.sides[2*i-2] = {
			x1=creature.parts[i].pos.x + vector_right.x*creature.parts[i].size,
			y1=creature.parts[i].pos.y + vector_right.y*creature.parts[i].size,
			x2=creature.parts[i-1].pos.x + vector_right.x*creature.parts[i-1].size,
			y2=creature.parts[i-1].pos.y + vector_right.y*creature.parts[i-1].size
		}
		creature.sides[2*i-3] = {
			x1=creature.parts[i].pos.x + vector_left.x*creature.parts[i].size,
			y1=creature.parts[i].pos.y + vector_left.y*creature.parts[i].size,
			x2=creature.parts[i-1].pos.x + vector_left.x*creature.parts[i-1].size,
			y2=creature.parts[i-1].pos.y + vector_left.y*creature.parts[i-1].size
		}
	end
	return creature
end

M.update_creature = function(creature, targets, dt)
	local current_target = targets[1]
	if current_target then
		local cur_distance = (creature.parts[1].pos - current_target).magnitude
		for i=2, #targets, 1 do
			local check_distance = (creature.parts[1].pos - targets[i].pos).magnitude
			if check_distance <= cur_distance then
				current_target = targets[i]
				cur_distance = check_distance
			end
		end
	else
		current_target = creature.parts[1].pos
	end

	creature = M.update_body_part(creature, 1, dt*500, current_target)
	for i=2, #creature.parts, 1 do
		creature = M.update_body_part(creature, i, dt*500, creature.parts[i-1].pos)
	end
	for i=1, #creature.legs, 1 do
		creature = M.update_leg(creature, i)
	end
	creature = M.update_sides(creature)

	return creature
end

M.draw_creature = function(creature)
	if creature then
		local color = creature.color
		love.graphics.setColor(color.r/255, color.g/255, color.b/255)
		for i=1, #creature.parts, 1 do
			love.graphics.circle("line", creature.parts[i].pos.x, creature.parts[i].pos.y, creature.parts[i].size)
		end

		for i=1, #creature.sides, 1 do
			love.graphics.line(
				creature.sides[i].x1,
				creature.sides[i].y1,
				creature.sides[i].x2,
				creature.sides[i].y2
			)
		end

		for i=1, #creature.legs, 1 do
			local leg = creature.legs[i]
			local angle = creature.parts[creature.legs[i].segment].angle
			if leg.offset then
				love.graphics.line(
					creature.parts[creature.legs[i].segment].pos.x + (leg.offset.x*math.cos(angle) - leg.side*leg.offset.y*math.sin(angle)),
					creature.parts[creature.legs[i].segment].pos.y + (leg.offset.x*math.sin(angle) + leg.side*leg.offset.y*math.cos(angle)),
					creature.legs[i].elbow.x,
					creature.legs[i].elbow.y,
					creature.legs[i].pos.x,
					creature.legs[i].pos.y
				)
			else
				love.graphics.line(
					creature.parts[creature.legs[i].segment].pos.x,
					creature.parts[creature.legs[i].segment].pos.y,
					creature.legs[i].elbow.x,
					creature.legs[i].elbow.y,
					creature.legs[i].pos.x,
					creature.legs[i].pos.y
				)
			end
		end

		love.graphics.print(
			creature.name,
			creature.parts[1].pos.x-love.graphics.getFont():getWidth(creature.name)/2,
			creature.parts[1].pos.y-creature.parts[1].size-love.graphics.getFont():getHeight()
		)
	end
end

M.draw_bodyplan = function(bodyplan, position)
	love.graphics.setColor(
		bodyplan.color.r/255,
		bodyplan.color.g/255,
		bodyplan.color.b/255
	)
	local body_part_positions = {}
	local offset = 0
	for _, part in ipairs(bodyplan.parts) do
		offset = offset + part.distance
		table.insert(body_part_positions, position + vector_l(offset, 0))
	end

	for i, part in ipairs(bodyplan.parts) do
		love.graphics.circle(
			"line",
			body_part_positions[i].x,
			body_part_positions[i].y,
			part.size
		)
	end
	for _, leg in ipairs(bodyplan.legs) do
		love.graphics.line(
		body_part_positions[leg.segment].x-leg.offset.x,
		body_part_positions[leg.segment].y+leg.offset.y * leg.side,
		body_part_positions[leg.segment].x-leg.offset.x,
		body_part_positions[leg.segment].y+leg.offset.y * leg.side + leg.length * leg.side
		)
	end
	for i=2, #bodyplan.parts, 1 do
		local vector = body_part_positions[i] - body_part_positions[i-1]
		local d = vector.magnitude

		local angle = math.acos(math.abs(bodyplan.parts[i].size-bodyplan.parts[i-1].size)/d)

		local vector_left, vector_right
		local angle_l, angle_r
		if bodyplan.parts[i].size <= bodyplan.parts[i-1].size then
			angle_l = angle
			angle_r = 2*math.pi-angle
		else
			angle_l = math.pi-angle
			angle_r = math.pi+angle
		end
		vector_left = {
			x = (vector.x*math.cos(angle_l) - vector.y*math.sin(angle_l)) / d,
			y = (vector.x*math.sin(angle_l) + vector.y*math.cos(angle_l)) / d
		}
		vector_right= {
			x = (vector.x*math.cos(angle_r) - vector.y*math.sin(angle_r)) / d,
			y = (vector.x*math.sin(angle_r) + vector.y*math.cos(angle_r)) / d
		}
		love.graphics.line(
			body_part_positions[i].x + vector_right.x*bodyplan.parts[i].size,
			body_part_positions[i].y + vector_right.y*bodyplan.parts[i].size,
			body_part_positions[i-1].x + vector_right.x*bodyplan.parts[i-1].size,
			body_part_positions[i-1].y + vector_right.y*bodyplan.parts[i-1].size
		)
		love.graphics.line(
			body_part_positions[i].x + vector_left.x*bodyplan.parts[i].size,
			body_part_positions[i].y + vector_left.y*bodyplan.parts[i].size,
			body_part_positions[i-1].x + vector_left.x*bodyplan.parts[i-1].size,
			body_part_positions[i-1].y + vector_left.y*bodyplan.parts[i-1].size
		)
	end


end

return M
