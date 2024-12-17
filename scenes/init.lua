local scenes = {}

for _, file in ipairs(love.filesystem.getDirectoryItems("/scenes")) do
	if file ~= "init.lua" then
		local module = require("scenes."..file:match("(.+)%..+$"))
		if module.name then
			scenes[module.name] = module
		end
	end
end

return scenes
