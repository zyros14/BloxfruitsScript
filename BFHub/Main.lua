task.spawn(function()
pcall(function()
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local Workspace = game:GetService("Workspace")

local Hub = {}
Hub.Tabs = {}
Hub.CurrentTab = nil
Hub.Connections = {}

pcall(function()
    if not LocalPlayer:FindFirstChild("Data") then return end
    if not LocalPlayer.Data.Team or LocalPlayer.Data.Team.Value == "" then
        CommF_:InvokeServer("SetTeam", "Pirates")
    end
end)

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local Char = GetCharacter()
    return Char and Char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local Char = GetCharacter()
    return Char and Char:FindFirstChild("HumanoidRootPart")
end

local function GetLevel()
    local Data = LocalPlayer:FindFirstChild("Data")
    if Data and Data:FindFirstChild("Level") then
        return Data.Level.Value
    end
    local LS = LocalPlayer:FindFirstChild("leaderstats")
    if LS then
        local L = LS:FindFirstChild("Level") or LS:FindFirstChild("Lvl")
        if L then return L.Value end
    end
    return 1
end

local function IsAlive()
    local H = GetHumanoid()
    return H and H.Health > 0
end

local function IsQuestVisible()
    local Main = PlayerGui:FindFirstChild("Main")
    if Main then
        local Quest = Main:FindFirstChild("Quest")
        if Quest then
            local Container = Quest:FindFirstChild("Container")
            if Container then
                local Title = Container:FindFirstChild("QuestTitle")
                if Title then
                    local TitleText = Title:FindFirstChild("Title")
                    if TitleText then
                        return Quest.Visible, TitleText.Text
                    end
                end
            end
            return Quest.Visible, ""
        end
    end
    return false, ""
end

local function GetQuestNPC(Name)
    for _, Obj in pairs(Workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:lower():find(Name:lower()) then
            local H = Obj:FindFirstChildOfClass("Humanoid")
            if H and H.Health > 0 then
                local HRP = Obj:FindFirstChild("HumanoidRootPart")
                if HRP then return Obj, HRP end
            end
        end
    end
    return nil, nil
end

local function FindEnemy(Name)
    if Workspace:FindFirstChild("Enemies") then
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v.Name == Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                return v
            end
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local HRP = v:FindFirstChild("HumanoidRootPart")
            if HRP then return v end
        end
    end
    return nil
end

local function FindMobSpawn(Name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local HRP = v:FindFirstChild("HumanoidRootPart")
            if HRP then return HRP.CFrame end
        end
    end
    return nil
end

local NoClipConnection = nil
local function EnableNoClip()
    if NoClipConnection then return end
    NoClipConnection = RunService.Stepped:Connect(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end)
end
local function DisableNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
end

local BodyVel = nil
local function EnableSpeed(Speed)
    DisableSpeed()
    local HRP = GetRootPart()
    if not HRP then return end
    BodyVel = Instance.new("BodyVelocity")
    BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVel.Velocity = Vector3.new(0, 0, 0)
    BodyVel.Parent = HRP
end
local function DisableSpeed()
    if BodyVel then
        BodyVel:Destroy()
        BodyVel = nil
    end
end

local FarmTween = nil
local function TweenToPos(CF)
    local HRP = GetRootPart()
    if not HRP then return end
    local Dist = (HRP.Position - CF.Position).Magnitude
    if Dist < 3 then return end
    local Spd = FarmSpeed or 300
    local TI = TweenInfo.new(Dist / Spd, Enum.EasingStyle.Linear)
    FarmTween = TweenService:Create(HRP, TI, {CFrame = CF})
    FarmTween:Play()
    FarmTween.Completed:Wait()
    FarmTween = nil
end
local function StopTween()
    if FarmTween then
        FarmTween:Cancel()
        FarmTween = nil
    end
end

local function EquipTool(Name)
    local Char = GetCharacter()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Char or not Backpack then return end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name == Name or v.Name:lower():find(Name:lower())) then
            Char.Humanoid:EquipTool(v)
            return v
        end
    end
    return nil
end

local function EquipAny(Keyword)
    local Char = GetCharacter()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Char or not Backpack then return end
    for _, v in pairs(Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find(Keyword:lower()) then
            Char.Humanoid:EquipTool(v)
            return v
        end
    end
    return nil
end

local function Attack(Enemy)
    pcall(function()
        CommF_:InvokeServer("Attack", Enemy)
    end)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

local function CheckQuest(Level)
    local Quests = {
        {L=1, N="Bandit", QN="BanditQuest1", QI=1, CF=CFrame.new(978, 18, 1500), MF=CFrame.new(1100, 18, 1500), MN="Bandit"},
        {L=15, N="Monkey", QN="MonkeyQuest", QI=1, CF=CFrame.new(-1250, 18, 350), MF=CFrame.new(-1250, 18, 350), MN="Monkey"},
        {L=30, N="Pirate", QN="BuggyQuest1", QI=1, CF=CFrame.new(-1150, 18, 450), MF=CFrame.new(-1150, 18, 450), MN="Pirate"},
        {L=50, N="Desert Bandit", QN="DesertQuest", QI=1, CF=CFrame.new(1100, 18, 450), MF=CFrame.new(1100, 18, 450), MN="Desert Bandit"},
        {L=75, N="Snow Bandit", QN="SnowQuest", QI=1, CF=CFrame.new(750, 18, -1200), MF=CFrame.new(750, 18, -1200), MN="Snow Bandit"},
        {L=100, N="Marine", QN="MarineQuest1", QI=1, CF=CFrame.new(-4500, 30, 400), MF=CFrame.new(-4500, 30, 400), MN="Marine"},
        {L=150, N="Sky Bandit", QN="SkyQuest", QI=1, CF=CFrame.new(-4500, 200, 400), MF=CFrame.new(-4500, 200, 400), MN="Sky Bandit"},
        {L=225, N="Prisoner", QN="PrisonerQuest", QI=1, CF=CFrame.new(4850, 18, 700), MF=CFrame.new(4850, 18, 700), MN="Prisoner"},
        {L=300, N="Gladiator", QN="ColosseumQuest", QI=1, CF=CFrame.new(-1300, 18, -2800), MF=CFrame.new(-1300, 18, -2800), MN="Gladiator"},
        {L=375, N="Magma Bandit", QN="MagmaQuest", QI=1, CF=CFrame.new(-5200, 18, 7500), MF=CFrame.new(-5200, 18, 7500), MN="Magma Bandit"},
        {L=450, N="Fishman", QN="FishmanQuest", QI=1, CF=CFrame.new(5500, 18, 300), MF=CFrame.new(5500, 18, 300), MN="Fishman"},
        {L=525, N="Ice Adventurer", QN="IceQuest", QI=1, CF=CFrame.new(6000, 18, 8000), MF=CFrame.new(6000, 18, 8000), MN="Ice Adventurer"},
        {L=600, N="Pirate King", QN="PirateKingQuest", QI=1, CF=CFrame.new(-5000, 30, -3000), MF=CFrame.new(-5000, 30, -3000), MN="Pirate King"},
        {L=675, N="Snow Mountain", QN="SkyQuest2", QI=2, CF=CFrame.new(300, 400, -500), MF=CFrame.new(300, 400, -500), MN="Snow Mountain"},
        {L=750, N="Death Step", QN="FountainQuest", QI=2, CF=CFrame.new(300, 18, -6000), MF=CFrame.new(300, 18, -6000), MN="Cyborg"},
        {L=825, N="Cursed", QN="CursedShipQuest", QI=1, CF=CFrame.new(900, 18, -11000), MF=CFrame.new(900, 18, -11000), MN="Cursed"},
        {L=900, N="Final Sea", QN="MarineQuest3", QI=1, CF=CFrame.new(-6500, 20, 8500), MF=CFrame.new(-6500, 20, 8500), MN="Marine"},
    }
    for i = #Quests, 1, -1 do
        if Level >= Quests[i].L then
            return Quests[i]
        end
    end
    return Quests[1]
end

local MasteryTargets = {
    {L=1, N="Bandit"}, {L=15, N="Monkey"}, {L=30, N="Pirate"},
    {L=50, N="Desert Bandit"}, {L=75, N="Snow Bandit"}, {L=100, N="Marine"},
    {L=150, N="Sky Bandit"}, {L=225, N="Prisoner"}, {L=300, N="Gladiator"},
    {L=375, N="Magma Bandit"}, {L=450, N="Fishman"}, {L=525, N="Ice Adventurer"},
    {L=600, N="Pirate King"}, {L=675, N="Snow Mountain"}, {L=750, N="Cyborg"},
    {L=825, N="Cursed"}, {L=900, N="Marine"},
}

local FarmSpeed = 300
local AutoFarm = false
local AutoMastery = false
local AutoRaid = false
local AutoStats = false
local FruitESP = false
local FruitTween = false
local FruitNotify = false
local PlayerESP = false
local ChestESP = false
local SelectedStat = "Melee"
local SelectedWeapon = "Combat"
local FarmMode = "Above"
local MasteryType = "Melee"

local FruitHighlights = {}
local PlayerHighlights = {}
local ChestHighlights = {}
local NotifiedFruits = {}

local function Gethui()
    return PlayerGui
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyrosHub"
ScreenGui.Parent = Gethui()
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 50)

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
local Fix = Instance.new("Frame", TitleBar)
Fix.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Fix.BorderSizePixel = 0
Fix.Position = UDim2.new(0, 0, 1, -10)
Fix.Size = UDim2.new(1, 0, 0, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(1, -24, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BLOX FRUITS | ZYROS HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -60, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 14

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 16

CloseBtn.MouseButton1Click:Connect(function()
    AutoFarm = false
    AutoMastery = false
    AutoRaid = false
    AutoStats = false
    FruitESPRunning = false
    FruitTween = false
    FruitNotify = false
    PlayerESP = false
    ChestESP = false
    DisableNoClip()
    StopTween()
    DisableSpeed()
    if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
    for _, H in pairs(FruitHighlights) do H:Destroy() end
    for _, H in pairs(PlayerHighlights) do H:Destroy() end
    for _, H in pairs(ChestHighlights) do H:Destroy() end
    FruitHighlights = {}
    PlayerHighlights = {}
    ChestHighlights = {}
    ScreenGui:Destroy()
end)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TabContainer.BorderSizePixel = 0
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(0, 120, 1, -35)
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 2)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 125, 0, 40)
ContentFrame.Size = UDim2.new(1, -130, 1, -45)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 6)

local ContentScroll = Instance.new("ScrollingFrame", ContentFrame)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.Position = UDim2.new(0, 8, 0, 8)
ContentScroll.Size = UDim2.new(1, -16, 1, -16)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
ContentScroll.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", ContentScroll).Padding = UDim.new(0, 6)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    ContentFrame.Visible = not Minimized
    TabContainer.Visible = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0, 600, 0, 35)
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        MinBtn.Text = "—"
    end
end)

local Dragging, DragInput, DragStart, StartPos
TitleBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPos = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then
        DragInput = Input
    end
end)
UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if Dragging and DragInput then
        local Delta = DragInput.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

local TabButtons = {}
local FirstTab = true

local function AddTab(Name)
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Name = Name
    Btn.BackgroundColor3 = FirstTab and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(14, 14, 18)
    Btn.BorderSizePixel = 0
    Btn.Size = UDim2.new(1, -8, 0, 32)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = "  " .. Name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = #TabButtons + 1
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    FirstTab = false
    
    local Page = Instance.new("Frame", ContentScroll)
    Page.Name = Name
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 0, 0)
    Page.AutomaticSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        for _, B in pairs(TabButtons) do
            B.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            B.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        for _, T in pairs(Hub.Tabs) do T.Visible = false end
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
    end)
    
    table.insert(TabButtons, Btn)
    Hub.Tabs[Name] = Page
    return Page
end

local function MakeToggle(Parent, Text, Callback)
    local F = Instance.new("Frame", Parent)
    F.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    F.BorderSizePixel = 0
    F.Size = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
    local St = Instance.new("UIStroke", F)
    St.Color = Color3.fromRGB(50, 50, 65)
    St.Thickness = 1
    local L = Instance.new("TextLabel", F)
    L.BackgroundTransparency = 1
    L.Position = UDim2.new(0, 10, 0, 0)
    L.Size = UDim2.new(1, -50, 1, 0)
    L.Font = Enum.Font.Gotham
    L.Text = Text
    L.TextColor3 = Color3.fromRGB(220, 220, 230)
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Sw = Instance.new("Frame", F)
    Sw.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Sw.BorderSizePixel = 0
    Sw.Position = UDim2.new(1, -38, 0.5, -10)
    Sw.Size = UDim2.new(0, 28, 0, 20)
    Instance.new("UICorner", Sw).CornerRadius = UDim.new(0, 10)
    local Ci = Instance.new("Frame", Sw)
    Ci.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ci.BorderSizePixel = 0
    Ci.Position = UDim2.new(0.05, 0, 0.1, 0)
    Ci.Size = UDim2.new(0.4, 0, 0.8, 0)
    Instance.new("UICorner", Ci).CornerRadius = UDim.new(0, 10)
    local B = Instance.new("TextButton", F)
    B.BackgroundTransparency = 1
    B.Size = UDim2.new(1, 0, 1, 0)
    B.Text = ""
    local V = false
    B.MouseButton1Click:Connect(function()
        V = not V
        Sw.BackgroundColor3 = V and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
        Ci.Position = V and UDim2.new(0.5, -2, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
        if Callback then Callback(V) end
    end)
    return F
end

local function MakeButton(Parent, Text, Callback)
    local B = Instance.new("TextButton", Parent)
    B.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    B.BorderSizePixel = 0
    B.Size = UDim2.new(1, 0, 0, 32)
    B.Font = Enum.Font.Gotham
    B.Text = "  " .. Text
    B.TextColor3 = Color3.fromRGB(220, 220, 230)
    B.TextSize = 12
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.AutoButtonColor = false
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    local St = Instance.new("UIStroke", B)
    St.Color = Color3.fromRGB(50, 50, 65)
    St.Thickness = 1
    B.MouseEnter:Connect(function() B.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end)
    B.MouseLeave:Connect(function() B.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
    B.MouseButton1Click:Connect(function() task.spawn(Callback) end)
    return B
end

local function MakeDropdown(Parent, Text, Default, Options, Callback)
    local V = Default
    local Frame = Instance.new("Frame", Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local St = Instance.new("UIStroke", Frame)
    St.Color = Color3.fromRGB(50, 50, 65)
    St.Thickness = 1
    local L = Instance.new("TextLabel", Frame)
    L.Name = "Label"
    L.BackgroundTransparency = 1
    L.Position = UDim2.new(0, 10, 0, 0)
    L.Size = UDim2.new(1, -30, 0.5, 0)
    L.Font = Enum.Font.Gotham
    L.Text = Text .. ": " .. V
    L.TextColor3 = Color3.fromRGB(220, 220, 230)
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local B = Instance.new("TextButton", Frame)
    B.BackgroundTransparency = 1
    B.Position = UDim2.new(1, -30, 0, 0)
    B.Size = UDim2.new(0, 30, 0, 32)
    B.Font = Enum.Font.Gotham
    B.Text = "v"
    B.TextColor3 = Color3.fromRGB(200, 200, 210)
    B.TextSize = 12
    local CB = Instance.new("TextButton", Frame)
    CB.BackgroundTransparency = 1
    CB.Size = UDim2.new(1, 0, 0, 32)
    CB.Text = ""
    CB.ZIndex = 2
    local OB = {}
    for i, O in ipairs(Options) do
        local O = Instance.new("TextButton", Frame)
        O.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        O.BorderSizePixel = 0
        O.Position = UDim2.new(0, 4, 0, 32 + ((i - 1) * 28))
        O.Size = UDim2.new(1, -8, 0, 26)
        O.Font = Enum.Font.Gotham
        O.Text = "  " .. O
        O.TextColor3 = Color3.fromRGB(200, 200, 210)
        O.TextSize = 11
        O.TextXAlignment = Enum.TextXAlignment.Left
        O.Visible = false
        O.ZIndex = 3
        Instance.new("UICorner", O).CornerRadius = UDim.new(0, 4)
        O.MouseButton1Click:Connect(function()
            V = Options[i]
            L.Text = Text .. ": " .. V
            Frame.Size = UDim2.new(1, 0, 0, 32)
            B.Text = "v"
            for _, X in pairs(OB) do X.Visible = false end
            if Callback then Callback(V) end
        end)
        table.insert(OB, O)
    end
    local Open = false
    CB.MouseButton1Click:Connect(function()
        Open = not Open
        if Open then
            Frame.Size = UDim2.new(1, 0, 0, 32 + (#Options * 28))
            B.Text = "^"
            for _, X in pairs(OB) do X.Visible = true end
        else
            Frame.Size = UDim2.new(1, 0, 0, 32)
            B.Text = "v"
            for _, X in pairs(OB) do X.Visible = false end
        end
    end)
    return Frame
end

local function Section(Parent)
    local S = Instance.new("Frame", Parent)
    S.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    S.BorderSizePixel = 0
    S.Size = UDim2.new(1, 0, 0, 6)
    return S
end

local function Label(Parent, Text)
    local L = Instance.new("TextLabel", Parent)
    L.BackgroundTransparency = 1
    L.Size = UDim2.new(1, 0, 0, 20)
    L.Font = Enum.Font.GothamBold
    L.Text = Text
    L.TextColor3 = Color3.fromRGB(255, 170, 0)
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    return L
end

local function TLabel(Parent, Text)
    local L = Instance.new("TextLabel", Parent)
    L.BackgroundTransparency = 1
    L.Size = UDim2.new(1, 0, 0, 16)
    L.Font = Enum.Font.Gotham
    L.Text = Text
    L.TextColor3 = Color3.fromRGB(160, 160, 170)
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    return L
end

local FarmTab = AddTab("Farming")
local FruitTab = AddTab("Fruits")
local TeleportTab = AddTab("Teleport")
local VisualsTab = AddTab("Visuals")
local RaidTab = AddTab("Raids")
local OtherTab = AddTab("Other")

Label(FarmTab, "Auto Farm Level")
Section(FarmTab)
MakeDropdown(FarmTab, "Farm Mode", FarmMode, {"Above", "Behind", "Below"}, function(V) FarmMode = V end)
MakeToggle(FarmTab, "Auto Farm Level", function(V)
    AutoFarm = V
    if V then
        EnableNoClip()
        task.spawn(function()
            while AutoFarm do
                local Lvl = GetLevel()
                local Q = CheckQuest(Lvl)
                local NPC, HRP = GetQuestNPC(Q.N)
                local QuestVis, QuestName = IsQuestVisible()
                if not QuestVis then
                    if NPC and HRP then
                        TweenToPos(HRP.CFrame * CFrame.new(0, 0, 5))
                        pcall(function()
                            CommF_:InvokeServer("SetSpawnPoint")
                            CommF_:InvokeServer(Q.QN, Q.QI)
                        end)
                    else
                        TweenToPos(Q.CF)
                    end
                    task.wait(1)
                else
                    local Enemy = FindEnemy(Q.MN)
                    if Enemy then
                        local EHRP = Enemy:FindFirstChild("HumanoidRootPart")
                        if EHRP then
                            local Offset = FarmMode == "Above" and CFrame.new(0, 40, 0) or FarmMode == "Behind" and CFrame.new(0, 0, -5) or CFrame.new(0, -5, 0)
                            TweenToPos(EHRP.CFrame * Offset)
                            local A = 0
                            while AutoFarm and A < 100 do
                                local Hum = Enemy:FindFirstChildOfClass("Humanoid")
                                if not Hum or Hum.Health <= 0 then break end
                                local CurEnemy = FindEnemy(Q.MN)
                                if CurEnemy then
                                    local CHP = CurEnemy:FindFirstChild("HumanoidRootPart")
                                    if CHP then
                                        TweenToPos(CHP.CFrame * Offset)
                                        pcall(function()
                                            CurEnemy.Humanoid.PlatformStand = true
                                            CurEnemy.Humanoid.Sit = true
                                            CurEnemy.HumanoidRootPart.CanCollide = false
                                            CurEnemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        end)
                                        Attack(CurEnemy)
                                    end
                                end
                                task.wait(0.3)
                                A = A + 1
                            end
                        end
                    else
                        local SpawnCF = FindMobSpawn(Q.MN)
                        if SpawnCF then TweenToPos(SpawnCF) end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        DisableNoClip()
        StopTween()
    end
end)
TLabel(FarmTab, "Quests: 1-900+ | Auto-detects level")

Label(FarmTab, "Auto Mastery")
Section(FarmTab)
MakeDropdown(FarmTab, "Mastery Type", MasteryType, {"Melee", "Sword", "Gun", "Blox Fruit"}, function(V)
    MasteryType = V
end)
MakeToggle(FarmTab, "Auto Mastery", function(V)
    AutoMastery = V
    if V then
        EnableNoClip()
        task.spawn(function()
            while AutoMastery do
                local Lvl = GetLevel()
                local Target = MasteryTargets[1]
                for i = #MasteryTargets, 1, -1 do
                    if Lvl >= MasteryTargets[i].L then Target = MasteryTargets[i]; break end
                end
                if MasteryType == "Sword" then
                    EquipAny("Sword")
                elseif MasteryType == "Gun" then
                    EquipAny("Gun")
                elseif MasteryType == "Blox Fruit" then
                    EquipAny("Fruit")
                else
                    EquipAny("Combat") or EquipAny("Melee")
                end
                local NPC, HRP = GetQuestNPC(Target.N)
                if NPC and HRP then
                    TweenToPos(HRP.CFrame * CFrame.new(0, 30, 0))
                    local A = 0
                    while AutoMastery and A < 100 do
                        local Hum = NPC:FindFirstChildOfClass("Humanoid")
                        if not Hum or Hum.Health <= 0 then break end
                        Attack(NPC)
                        task.wait(0.2)
                        A = A + 1
                    end
                else
                    TweenToPos(Target.N == "Bandit" and CFrame.new(978, 18, 1500) or CFrame.new(-1250, 18, 350))
                end
                task.wait(0.5)
            end
        end)
    else
        DisableNoClip()
        StopTween()
    end
end)
TLabel(FarmTab, "Farms mastery for selected weapon type")

local FruitESPRunning = false
Label(FruitTab, "Fruit ESP")
Section(FruitTab)
MakeToggle(FruitTab, "Fruit ESP", function(V)
    FruitESPRunning = V
    if V then
        task.spawn(function()
            while FruitESPRunning do
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if (Obj:IsA("Tool") or Obj:IsA("Model")) and Obj.Name:lower():find("fruit") and not FruitHighlights[Obj] then
                        local H = Instance.new("Highlight")
                        H.FillColor = Color3.fromRGB(255, 170, 0)
                        H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(255, 255, 0)
                        H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj
                        H.Parent = Workspace
                        FruitHighlights[Obj] = H
                    end
                end
                task.wait(2)
            end
        end)
    else
        for _, H in pairs(FruitHighlights) do H:Destroy() end
        FruitHighlights = {}
    end
end)

Label(FruitTab, "Fruit Tween")
Section(FruitTab)
MakeToggle(FruitTab, "Tween to Fruits", function(V)
    FruitTween = V
    if V then
        EnableNoClip()
        task.spawn(function()
            while FruitTween do
                local Closest, MinDist = nil, math.huge
                local Char = GetCharacter()
                if Char then
                    local HRP = Char:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        for _, Obj in pairs(Workspace:GetChildren()) do
                            if Obj:IsA("Tool") and Obj.Name:lower():find("fruit") then
                                local Handle = Obj:FindFirstChild("Handle")
                                if Handle then
                                    local Dist = (HRP.Position - Handle.Position).Magnitude
                                    if Dist < MinDist then MinDist = Dist; Closest = Handle end
                                end
                            end
                        end
                    end
                end
                if Closest then
                    TweenToPos(CFrame.new(Closest.Position + Vector3.new(0, 3, 0)))
                    task.wait(0.5)
                else
                    task.wait(2)
                end
            end
        end)
    else
        DisableNoClip()
        StopTween()
    end
end)
TLabel(FruitTab, "Smooth tween + no-clip to nearest fruit")

Label(FruitTab, "Fruit Notifier")
Section(FruitTab)
MakeToggle(FruitTab, "Fruit Notifier", function(V)
    FruitNotify = V
    if V then
        task.spawn(function()
            while FruitNotify do
                for _, Obj in pairs(Workspace:GetChildren()) do
                    if Obj:IsA("Tool") and Obj.Name:lower():find("fruit") and not NotifiedFruits[Obj] then
                        NotifiedFruits[Obj] = true
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Fruit Spawned!", Text = Obj.Name .. " has spawned!", Duration = 10
                            })
                        end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local IslandOrder = {
    "Starter Island", "Jungle", "Pirate Village", "Desert", "Frozen Village",
    "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village",
    "Underwater", "Ice Adventure", "Beautiful Pirate Castle", "Snow Mountain",
    "Death Step", "Cursed Ship", "Final Sea", "Sea of Treats"
}
local Islands = {
    ["Starter Island"] = CFrame.new(978, 18, 1500), ["Jungle"] = CFrame.new(-1250, 18, 350),
    ["Pirate Village"] = CFrame.new(-1150, 18, 450), ["Desert"] = CFrame.new(1100, 18, 450),
    ["Frozen Village"] = CFrame.new(750, 18, -1200), ["Marine Fortress"] = CFrame.new(-4500, 30, 400),
    ["Skylands"] = CFrame.new(-4500, 200, 400), ["Prison"] = CFrame.new(4850, 18, 700),
    ["Colosseum"] = CFrame.new(-1300, 18, -2800), ["Magma Village"] = CFrame.new(-5200, 18, 7500),
    ["Underwater"] = CFrame.new(5500, 18, 300), ["Ice Adventure"] = CFrame.new(6000, 18, 8000),
    ["Beautiful Pirate Castle"] = CFrame.new(-5000, 30, -3000), ["Snow Mountain"] = CFrame.new(300, 400, -500),
    ["Death Step"] = CFrame.new(300, 18, -6000), ["Cursed Ship"] = CFrame.new(900, 18, -11000),
    ["Final Sea"] = CFrame.new(-6500, 20, 8500), ["Sea of Treats"] = CFrame.new(-1500, 18, -14000),
}
Label(TeleportTab, "Island Teleport")
Section(TeleportTab)
MakeDropdown(TeleportTab, "Select Island", IslandOrder[1], IslandOrder, function(V)
    local T = Islands[V]
    if T then
        EnableNoClip()
        TweenToPos(T)
        task.wait(1)
        DisableNoClip()
    end
end)

Label(VisualsTab, "Player ESP")
Section(VisualsTab)
MakeToggle(VisualsTab, "Player ESP", function(V)
    PlayerESP = V
    if V then
        task.spawn(function()
            for _, P in pairs(Players:GetPlayers()) do
                if P ~= LocalPlayer and not PlayerHighlights[P] then
                    local H = Instance.new("Highlight")
                    H.FillColor = Color3.fromRGB(255, 0, 0)
                    H.FillTransparency = 0.7
                    H.OutlineColor = Color3.fromRGB(255, 100, 100)
                    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    H.Parent = Workspace
                    PlayerHighlights[P] = H
                end
            end
            while PlayerESP do
                for P, H in pairs(PlayerHighlights) do
                    if P.Character then H.Adornee = P.Character else H.Adornee = nil end
                end
                task.wait(0.5)
            end
        end)
    else
        for _, H in pairs(PlayerHighlights) do H:Destroy() end
        PlayerHighlights = {}
    end
end)

Label(VisualsTab, "Chest ESP")
Section(VisualsTab)
MakeToggle(VisualsTab, "Chest ESP", function(V)
    ChestESP = V
    if V then
        task.spawn(function()
            while ChestESP do
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if (Obj:IsA("Model") or Obj:IsA("Part")) and Obj.Name:lower():find("chest") and not ChestHighlights[Obj] then
                        local H = Instance.new("Highlight")
                        H.FillColor = Color3.fromRGB(0, 170, 255)
                        H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(100, 200, 255)
                        H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj
                        H.Parent = Workspace
                        ChestHighlights[Obj] = H
                    end
                end
                task.wait(3)
            end
        end)
    else
        for _, H in pairs(ChestHighlights) do H:Destroy() end
        ChestHighlights = {}
    end
end)

Label(RaidTab, "Auto Raid")
Section(RaidTab)
MakeToggle(RaidTab, "Auto Raid", function(V)
    AutoRaid = V
    if V then
        EnableNoClip()
        task.spawn(function()
            while AutoRaid do
                pcall(function()
                    CommF_:InvokeServer("Awakener", "Check")
                    CommF_:InvokeServer("Awakener", "Awaken")
                end)
                task.wait(2)
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj.Name:lower():find("raid") then
                        local Hum = Obj:FindFirstChildOfClass("Humanoid")
                        if Hum and Hum.Health > 0 then
                            local HRP = Obj:FindFirstChild("HumanoidRootPart")
                            if HRP then
                                TweenToPos(HRP.CFrame * CFrame.new(0, 0, 5))
                                local A = 0
                                while Hum.Health > 0 and A < 50 and AutoRaid do
                                    Attack(Obj)
                                    task.wait(0.3)
                                    A = A + 1
                                end
                            end
                        end
                    end
                end
                task.wait(5)
            end
        end)
    else
        DisableNoClip()
        StopTween()
    end
end)

Label(OtherTab, "Auto Stats")
Section(OtherTab)
MakeDropdown(OtherTab, "Stat Preset", "Melee", {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}, function(V)
    SelectedStat = V
end)
MakeToggle(OtherTab, "Auto Stats", function(V)
    AutoStats = V
    if V then
        task.spawn(function()
            while AutoStats do
                local Data = LocalPlayer:FindFirstChild("Data")
                if Data and Data.Stats and Data.Stats.Points then
                    local P = Data.Stats.Points.Value
                    if P > 0 then
                        pcall(function()
                            CommF_:InvokeServer("AddPoint", SelectedStat, P)
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

Label(OtherTab, "Server")
Section(OtherTab)
MakeButton(OtherTab, "Server Hop", function()
    local PlaceId = game.PlaceId
    local Servers = {}
    local Cursor = ""
    for _ = 1, 5 do
        local S, R = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true&cursor=" .. Cursor))
        end)
        if S and R then
            for _, Server in pairs(R.data or {}) do
                if Server.id and Server.playing and Server.maxPlayers then
                    if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                        table.insert(Servers, Server.id)
                    end
                end
            end
            if R.nextPageCursor then
                Cursor = R.nextPageCursor
            else
                break
            end
        end
        task.wait(0.5)
    end
    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, Servers[math.random(1, #Servers)], LocalPlayer)
    end
end)
MakeButton(OtherTab, "Rejoin Server", function()
    TeleportService:Teleport(994732206, LocalPlayer)
end)

Hub.Tabs["Farming"].Visible = true

pcall(function()
    CommF_:InvokeServer("Buso")
end)

RunService.RenderStepped:Connect(function()
    if AutoFarm or AutoMastery or FruitTween then
        pcall(function()
            local Hum = GetHumanoid()
            if Hum then Hum.Sit = false end
        end)
    end
end)

getgenv().ZyrosHubUnload = function()
    AutoFarm = false
    AutoMastery = false
    AutoRaid = false
    AutoStats = false
    FruitESPRunning = false
    FruitTween = false
    FruitNotify = false
    PlayerESP = false
    ChestESP = false
    DisableNoClip()
    StopTween()
    DisableSpeed()
    for _, H in pairs(FruitHighlights) do H:Destroy() end
    for _, H in pairs(PlayerHighlights) do H:Destroy() end
    for _, H in pairs(ChestHighlights) do H:Destroy() end
    ScreenGui:Destroy()
end
end)
end)
