local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Module = {}
local Running = false
local Connections = {}

local QuestData = {
    {Level = 1, NPC = "Bandit", Island = "Starter Island", Pos = CFrame.new(978, 18, 1500)},
    {Level = 15, NPC = "Monkey", Island = "Jungle", Pos = CFrame.new(-1250, 18, 350)},
    {Level = 30, NPC = "Pirate", Island = "Pirate Village", Pos = CFrame.new(-1150, 18, 450)},
    {Level = 50, NPC = "Desert Bandit", Island = "Desert", Pos = CFrame.new(1100, 18, 450)},
    {Level = 75, NPC = "Snow Bandit", Island = "Frozen Village", Pos = CFrame.new(750, 18, -1200)},
    {Level = 100, NPC = "Marine", Island = "Marine Fortress", Pos = CFrame.new(-4500, 30, 400)},
    {Level = 150, NPC = "Sky Bandit", Island = "Skylands", Pos = CFrame.new(-4500, 200, 400)},
    {Level = 225, NPC = "Prisoner", Island = "Prison", Pos = CFrame.new(4850, 18, 700)},
    {Level = 300, NPC = "Gladiator", Island = "Colosseum", Pos = CFrame.new(-1300, 18, -2800)},
    {Level = 375, NPC = "Magma Bandit", Island = "Magma Village", Pos = CFrame.new(-5200, 18, 7500)},
    {Level = 450, NPC = "Fishman", Island = "Underwater", Pos = CFrame.new(5500, 18, 300)},
    {Level = 525, NPC = "Ice Adventurer", Island = "Ice Adventure", Pos = CFrame.new(6000, 18, 8000)},
    {Level = 600, NPC = "Pirate King", Island = "Beautiful Pirate Castle", Pos = CFrame.new(-5000, 30, -3000)},
    {Level = 675, NPC = "Snow Mountain", Island = "Snow Mountain", Pos = CFrame.new(300, 400, -500)},
    {Level = 750, NPC = "Death Step", Island = "Death Step", Pos = CFrame.new(300, 18, -6000)},
    {Level = 825, NPC = "Cursed", Island = "Cursed Ship", Pos = CFrame.new(900, 18, -11000)},
    {Level = 900, NPC = "Final Sea", Island = "Final Sea", Pos = CFrame.new(-6500, 20, 8500)},
}

local function GetLevel()
    local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if Leaderstats then
        local Level = Leaderstats:FindFirstChild("Level") or Leaderstats:FindFirstChild("Lvl")
        if Level then return Level.Value end
    end
    return 1
end

local function GetQuestNPC(Data)
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:lower():find(Data.NPC:lower()) then
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
    Character = LocalPlayer.Character
    if not Character then return end
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    local Bf = HumanoidRootPart.Position - CFrame.Position
    local Mag = Bf.Magnitude
    if Mag < 5 then return end
    
    local Speed = 300
    local Tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(Mag / Speed, Enum.EasingStyle.Linear), {CFrame = CFrame})
    Tween:Play()
    Tween.Completed:Wait()
end

local function AttackNPC(NPC)
    Character = LocalPlayer.Character
    if not Character then return false end
    
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool then
        Character:FindFirstChildOfClass("Humanoid"):EquipTool(Tool)
    end
    
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", NPC)
    end)
    return true
end

local function FarmLoop()
    while Running do
        local Level = GetLevel()
        local CurrentQuest = nil
        
        for i = #QuestData, 1, -1 do
            if Level >= QuestData[i].Level then
                CurrentQuest = QuestData[i]
                break
            end
        end
        
        if CurrentQuest then
            local NPC, HRP = GetQuestNPC(CurrentQuest)
            if NPC and HRP then
                TweenTo(HRP.CFrame * CFrame.new(0, 0, 5))
                local Attempts = 0
                while Running and Attempts < 50 do
                    local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
                    if not Humanoid or Humanoid.Health <= 0 then break end
                    AttackNPC(NPC)
                    task.wait(0.5)
                    Attempts = Attempts + 1
                end
            else
                TweenTo(CurrentQuest.Pos)
                task.wait(2)
            end
        end
        
        task.wait(1)
    end
end

function Module.Init(Tab)
    local UI = Tab:GetChildren()[1] and Tab:GetChildren()[1].ClassName == "UIListLayout" and Tab or Tab
    
    local Label1 = Instance.new("TextLabel", UI)
    Label1.BackgroundTransparency = 1
    Label1.Size = UDim2.new(1, 0, 0, 20)
    Label1.Font = Enum.Font.GothamBold
    Label1.Text = "Auto Farm Level"
    Label1.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label1.TextSize = 13
    Label1.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section1 = Instance.new("Frame", UI)
    Section1.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section1.BorderSizePixel = 0
    Section1.Size = UDim2.new(1, 0, 0, 6)
    
    local Toggle1 = Instance.new("Frame", UI)
    Toggle1.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Toggle1.BorderSizePixel = 0
    Toggle1.Size = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", Toggle1).CornerRadius = UDim.new(0, 6)
    local Stroke1 = Instance.new("UIStroke", Toggle1)
    Stroke1.Color = Color3.fromRGB(50, 50, 65)
    Stroke1.Thickness = 1
    
    local Label1_2 = Instance.new("TextLabel", Toggle1)
    Label1_2.BackgroundTransparency = 1
    Label1_2.Position = UDim2.new(0, 10, 0, 0)
    Label1_2.Size = UDim2.new(1, -50, 1, 0)
    Label1_2.Font = Enum.Font.Gotham
    Label1_2.Text = "Auto Farm Level"
    Label1_2.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label1_2.TextSize = 12
    Label1_2.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch1 = Instance.new("Frame", Toggle1)
    Switch1.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Switch1.BorderSizePixel = 0
    Switch1.Position = UDim2.new(1, -38, 0.5, -10)
    Switch1.Size = UDim2.new(0, 28, 0, 20)
    Instance.new("UICorner", Switch1).CornerRadius = UDim.new(0, 10)
    local Circle1 = Instance.new("Frame", Switch1)
    Circle1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle1.BorderSizePixel = 0
    Circle1.Position = UDim2.new(0.05, 0, 0.1, 0)
    Circle1.Size = UDim2.new(0.4, 0, 0.8, 0)
    Instance.new("UICorner", Circle1).CornerRadius = UDim.new(0, 10)
    
    local Btn1 = Instance.new("TextButton", Toggle1)
    Btn1.BackgroundTransparency = 1
    Btn1.Size = UDim2.new(1, 0, 1, 0)
    Btn1.Text = ""
    
    local FarmRunning = false
    Btn1.MouseButton1Click:Connect(function()
        FarmRunning = not FarmRunning
        Running = FarmRunning
        Switch1.BackgroundColor3 = FarmRunning and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
        Circle1.Position = FarmRunning and UDim2.new(0.5, -2, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
        if FarmRunning then
            FarmLoop()
        end
    end)
    
    local Label2 = Instance.new("TextLabel", UI)
    Label2.BackgroundTransparency = 1
    Label2.Size = UDim2.new(1, 0, 0, 16)
    Label2.Font = Enum.Font.Gotham
    Label2.Text = "Quests: 1-900+"
    Label2.TextColor3 = Color3.fromRGB(160, 160, 170)
    Label2.TextSize = 11
    Label2.TextXAlignment = Enum.TextXAlignment.Left
end

function Module.Unload()
    Running = false
end

return Module
