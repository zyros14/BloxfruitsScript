-- Universal loader - tries multiple HTTP methods to avoid CoreGui bug
local url = "https://raw.githubusercontent.com/zyros14/BloxfruitsScript/master/BFHub/Main.lua"
local code = nil

-- Try different HTTP methods (avoiding game:HttpGet which triggers CoreGui bug)
local function fetch()
    -- Method 1: http_request (Synapse, Script-Ware, etc)
    if http_request then
        local ok, res = pcall(function()
            return http_request({Url = url, Method = "GET"})
        end)
        if ok and res and res.Body then return res.Body end
    end
    
    -- Method 2: syn.request (Synapse)
    if syn and syn.request then
        local ok, res = pcall(function()
            return syn.request({Url = url, Method = "GET"})
        end)
        if ok and res and res.Body then return res.Body end
    end
    
    -- Method 3: request (most executors)
    if request then
        local ok, res = pcall(function()
            return request({Url = url, Method = "GET"})
        end)
        if ok and res and res.Body then return res.Body end
    end
    
    -- Method 4: http.request
    if http and http.request then
        local ok, res = pcall(function()
            return http.request({Url = url, Method = "GET"})
        end)
        if ok and res and res.Body then return res.Body end
    end
    
    -- Method 5: game:HttpGet (last resort - may trigger CoreGui bug)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and res and #res > 10 then return res end
    
    return nil
end

code = fetch()
if not code then
    error("Failed to fetch script - all HTTP methods failed")
end

local func, err = loadstring(code)
if not func then
    error("Failed to compile: " .. tostring(err))
end

func()
