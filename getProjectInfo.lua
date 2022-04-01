local s = require "out.assets.settings"

local id = s.identity or "game"
local description = s.description or "game description"
local authors = s.authors or "nobody"
local version = s.version or "0"

local sep = "/"

print(
	id..sep..description..sep..authors..sep..version
)