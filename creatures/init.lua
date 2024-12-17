local creatures = {}

local info = love.filesystem.getInfo("user_creatures", "directory")
if info == nil then
	love.filesystem.createDirectory("user_creatures")
end

for _, file in ipairs(love.filesystem.getDirectoryItems("user_creatures")) do
	local creature = loadstring(love.filesystem.read("user_creatures/"..file))()
	table.insert(creatures, creature)
end

for _, file in ipairs(love.filesystem.getDirectoryItems("/creatures")) do
	if file ~= "init.lua" and file ~= "default.lua" then
		local name = file:match("(.+)%..+$")
		local creature = require("creatures."..name)
		table.insert(creatures, creature)
	end
end

return creatures
