local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Module = {}
local Running = false

local MasteryTargets = {
    {Level = 1, Name = "Bandit", CFrame = CFrame.new(978, 18, 1500)},
    {Level = 15, Name = "Monkey", CFrame = CFrame.new(-1250, 18, 350)},
    {Level = 30, Name = "Pirate", CFrame = CFrame.new(-1150, 18, 450)},
    {Level = 50, Name = "Desert Bandit", CFrame = CFrame.new(1100, 18, 450)},
    {Level = 75, Name = "Snow Bandit", CFrame = CFrame.new(750, 18, -1200)},
    {Level = 100, Name = "Marine", CFrame = CFrame.new(-4500, 30, 400)},
    {Level = 150, Name = "Sky Bandit", CFrame = CFrame.new(-4500, 200, 400)},
    {Level = 225, Name = "Prisoner", CFrame = CFrame.new(4850, 18, 700)},
    {Level = 300, Name = "Gladiator", CFrame = CFrame.new(-1300, 18, -2800)},
}

local function GetLevel()
    local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if Leaderstats then
        local Level = Leaderstats:FindFirstChild("Level") or Leaderstats:FindFirstChild("Lvl")
        if Level then return Level.Value end
    end
    return 1
end

local function FindNPC(Name)
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:lower():find(Name:lower()) then
            local Humanoid = Obj:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local HRP = Obj:FindFirstChild("HumanoidRootPart")
                if HRP then
                    return Obj, HRP
                end
            end
        end
    end
    return nil, nil
end

local function TweenTo(CFrame)
    local Character = LocalPlayer.Character
    if not Character then return end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local Bf = HRP.Position - CFrame.Position
    local Mag = Bf.Magnitude
    if Mag < 5 then return end
    
    local Speed = 300
    local Tween = TweenService:Create(HRP, TweenInfo.new(Mag / Speed, Enum.EasingStyle.Linear), {CFrame = CFrame})
    Tween:Play()
    Tween.Completed:Wait()
end

local function MasteryLoop()
    while Running do
        local Level = GetLevel()
        local Target = MasteryTargets[1]
        
        for i = #MasteryTargets, 1, -1 do
            if Level >= MasteryTargets[i].Level then
                Target = MasteryTargets[i]
                break
            end
        end
        
        local NPC, HRP = FindNPC(Target.Name)
        if NPC and HRP then
            TweenTo(HRP.CFrame * CFrame.new(0, 0, 5))
            local Attempts = 0
            while Running and Attempts < 50 do
                local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
                if not Humanoid or Humanoid.Health <= 0 then break end
                
                local Character = LocalPlayer.Character
                if Character then
                    local Tool = Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Character:FindFirstChildOfClass("Humanoid"):EquipTool(Tool)
                    end
                end
                
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", NPC)
                end)
                task.wait(0.4)
                Attempts = Attempts + 1
            end
        else
            TweenTo(Target.CFrame)
            task.wait(2)
        end
        
        task.wait(1)
    end
end

local function MakeToggle(Parent, Text, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(50, 50, 65)
    Stroke.Thickness = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("Frame", Frame)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Switch.BorderSizePixel = 0
    Switch.Position = UDim2.new(1, -38, 0.5, -10)
    Switch.Size = UDim2.new(0, 28, 0, 20)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 10)
    local Circle = Instance.new("Frame", Switch)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Position = UDim2.new(0.05, 0, 0.1, 0)
    Circle.Size = UDim2.new(0.4, 0, 0.8, 0)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 10)
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = ""
    
    local Value = false
    Btn.MouseButton1Click:Connect(function()
        Value = not Value
        Switch.BackgroundColor3 = Value and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
        Circle.Position = Value and UDim2.new(0.5, -2, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
        if Callback then Callback(Value) end
    end)
    
    return Frame
end

function Module.Init(Tab)
    local Label = Instance.new("TextLabel", Tab)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Font = Enum.Font.GothamBold
    Label.Text = "Auto Mastery"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeToggle(Tab, "Auto Mastery", function(Value)
        Running = Value
        if Value then
            MasteryLoop()
        end
    end)
end

function Module.Unload()
    Running = false
end

return Module
