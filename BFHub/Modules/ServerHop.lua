local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Module = {}
local PlaceId = 994732206

local function GetServers()
    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"))
    end)
    
    if Success and Result.data then
        return Result.data
    end
    return {}
end

local function HopServer()
    local Servers = GetServers()
    
    for _, Server in pairs(Servers) do
        if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, LocalPlayer)
            return
        end
    end
end

local function MakeButton(Parent, Text, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.BorderSizePixel = 0
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = "  " .. Text
    Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = Color3.fromRGB(50, 50, 65)
    Stroke.Thickness = 1
    
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
    Btn.MouseButton1Click:Connect(function()
        task.spawn(Callback)
    end)
    
    return Btn
end

function Module.Init(Tab)
    local Label = Instance.new("TextLabel", Tab)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Font = Enum.Font.GothamBold
    Label.Text = "Server"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeButton(Tab, "Server Hop", function()
        HopServer()
    end)
    
    MakeButton(Tab, "Rejoin Server", function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)
end

function Module.Unload()

end

return Module
