local function number_to_vector(n)
	if type(n) == 'number' then
		local v = {x=n, y=n}
		setmetatable(v, Vector_metatable)
		return v
	end
	return n
end

Vector_metatable = {
	-- TODO: if one of the arguments is a number, convert that number to a vector
	__add = function(a, b)
		b = number_to_vector(b)
		local v = {x=a.x+b.x, y=a.y+b.y}
		setmetatable(v, Vector_metatable)
		return v
	end,
	__sub = function(a, b)
		b = number_to_vector(b)
		local v = {x=a.x-b.x, y=a.y-b.y}
		setmetatable(v, Vector_metatable)
		return v
	end,
	__mul = function(a, b)
		b = number_to_vector(b)
		local v = {x=a.x*b.x, y=a.y*b.y}
		setmetatable(v, Vector_metatable)
		return v
	end,
	__div = function(a, b)
		b = number_to_vector(b)
		local v = {x=a.x/b.x, y=a.y/b.y}
		setmetatable(v, Vector_metatable)
		return v
	end,
	__index = function(t, key)
		if key=="magnitude" then
			return math.sqrt(t.x^2 + t.y^2)
		end
	end
	-- TODO: rotate function?
}

return function(x, y)
	if x == nil then
		x = 1
	end
	if y == nil then
		y = x
	end
	local vector = {x=x, y=y}
	setmetatable(vector, Vector_metatable)
	return vector
end
