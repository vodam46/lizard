local function copy(t) -- Makes a deep copy of a table.
	if type(t) ~= 'table' then
		return t
	end

	local new = {}
	for key, value in pairs(t) do
		new[copy(key)] = copy(value)
	end

	return new
end
return copy
