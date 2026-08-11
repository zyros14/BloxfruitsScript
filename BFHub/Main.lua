local url = "https://raw.githubusercontent.com/zyros14/BloxfruitsScript/master/BFHub/Main.lua"
local ok, http = pcall(game.HttpGet, game, url)
if not ok then error("HttpGet failed: " .. tostring(http)) end
if not http or #http < 10 then error("Bad response: " .. type(http) .. " len=" .. (http and #http or 0)) end
local func, err = loadstring(http)
if not func then error("Compile error: " .. tostring(err)) end
pcall(func)
