local url = "https://raw.githubusercontent.com/zyros14/BloxfruitsScript/master/BFHub/Main.lua"
local http = game:HttpGet(url)
if not http then error("HTTP request failed - got nil response") end
if #http < 10 then error("HTTP response too short: '" .. tostring(http) .. "'") end
local func, err = loadstring(http)
if not func then
    error("Loadstring failed: " .. tostring(err) .. "\nFirst 100 chars: " .. http:sub(1,100))
end
func()
