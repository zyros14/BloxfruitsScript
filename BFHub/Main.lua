if not game:IsLoaded() then game.Loaded:Wait() end

local function Main()
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local VU = game:GetService('VirtualUser')
local TS = game:GetService('TweenService')
local LP = Players.LocalPlayer
if not LP then return end
local PG = LP:WaitForChild('PlayerGui')
if not PG then return end
local RS = game:GetService('ReplicatedStorage')
local Remotes = RS:WaitForChild('Remotes')
if not Remotes then return end
local CommF_ = Remotes:WaitForChild('CommF_')
if not CommF_ then return end
local WS = game:GetService('Workspace')

-- ============================================================
-- CENTRAL CONFIGURATION
-- ============================================================
local Settings = {
    AutoFarm = false, AutoMastery = false, AutoRaid = false, AutoStats = false,
    FruitESP = false, FruitTween = false, FruitNotify = false,
    PlayerESP = false, ChestESP = false,
    FarmMode = 'Above', MasteryType = 'Melee', StatType = 'Melee',
    AntiAFK = true,
}

-- ============================================================
-- SAFE REMOTE INVOCATION
-- ============================================================
local function SafeInvoke(Remote, ...)
    local args = {...}
    for i, v in ipairs(args) do
        if v == nil then return false end
    end
    local ok, res = pcall(function() return Remote:InvokeServer(...) end)
    return ok
end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHum() local c = LP.Character; return c and c:FindFirstChildOfClass('Humanoid') end
local function GetHRP() local c = LP.Character; return c and c:FindFirstChild('HumanoidRootPart') end
local function GetLvl() local d = LP:FindFirstChild('Data'); if d and d:FindFirstChild('Level') then return d.Level.Value end; return 1 end
local function IsAlive() local h = GetHum(); return h and h.Health > 0 end

-- ============================================================
-- QUEST DATA
-- ============================================================
local Quests = {
    {L=1,N='Bandit',QN='BanditQuest1',QI=1,CF=CFrame.new(978,18,1500),MN='Bandit'},
    {L=15,N='Monkey',QN='MonkeyQuest',QI=1,CF=CFrame.new(-1250,18,350),MN='Monkey'},
    {L=30,N='Pirate',QN='BuggyQuest1',QI=1,CF=CFrame.new(-1150,18,450),MN='Pirate'},
    {L=50,N='Desert Bandit',QN='DesertQuest',QI=1,CF=CFrame.new(1100,18,450),MN='Desert Bandit'},
    {L=75,N='Snow Bandit',QN='SnowQuest',QI=1,CF=CFrame.new(750,18,-1200),MN='Snow Bandit'},
    {L=100,N='Marine',QN='MarineQuest1',QI=1,CF=CFrame.new(-4500,30,400),MN='Marine'},
    {L=150,N='Sky Bandit',QN='SkyQuest',QI=1,CF=CFrame.new(-4500,200,400),MN='Sky Bandit'},
    {L=225,N='Prisoner',QN='PrisonerQuest',QI=1,CF=CFrame.new(4850,18,700),MN='Prisoner'},
    {L=300,N='Gladiator',QN='ColosseumQuest',QI=1,CF=CFrame.new(-1300,18,-2800),MN='Gladiator'},
    {L=375,N='Magma Bandit',QN='MagmaQuest',QI=1,CF=CFrame.new(-5200,18,7500),MN='Magma Bandit'},
    {L=450,N='Fishman',QN='FishmanQuest',QI=1,CF=CFrame.new(5500,18,300),MN='Fishman'},
    {L=525,N='Ice Adventurer',QN='IceQuest',QI=1,CF=CFrame.new(6000,18,8000),MN='Ice Adventurer'},
    {L=600,N='Pirate King',QN='PirateKingQuest',QI=1,CF=CFrame.new(-5000,30,-3000),MN='Pirate King'},
    {L=675,N='Snow Mountain',QN='SkyQuest2',QI=2,CF=CFrame.new(300,400,-500),MN='Snow Mountain'},
    {L=750,N='Death Step',QN='FountainQuest',QI=2,CF=CFrame.new(300,18,-6000),MN='Cyborg'},
    {L=825,N='Cursed',QN='CursedShipQuest',QI=1,CF=CFrame.new(900,18,-11000),MN='Cursed'},
    {L=900,N='Final Sea',QN='MarineQuest3',QI=1,CF=CFrame.new(-6500,20,8500),MN='Marine'},
}
local function CQ(Lv) for i=#Quests,1,-1 do if Lv>=Quests[i].L then return Quests[i] end end; return Quests[1] end

-- ============================================================
-- MOVEMENT & COMBAT
-- ============================================================
local NC = nil
local function EnNC()
    if NC then return end
    NC = RunService.Stepped:Connect(function()
        pcall(function()
            local c = LP.Character; if not c then return end
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide then v.CanCollide = false end
            end
        end)
    end)
end
local function DisNC()
    if NC then pcall(function() NC:Disconnect() end); NC = nil end
    pcall(function()
        local c = LP.Character; if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then v.CanCollide = true end
        end
    end)
end

local FT = nil
local function TweenTo(CF)
    StopT()
    local P = GetHRP(); if not P then return end
    local Dist = (P.Position - CF.Position).Magnitude; if Dist < 3 then return end
    local ok, tween = pcall(function()
        return TS:Create(P, TweenInfo.new(Dist/250, Enum.EasingStyle.Linear), {CFrame = CF})
    end)
    if ok and tween then FT = tween; tween:Play() end
end
local function StopT() if FT then pcall(function() FT:Cancel() end); FT = nil end end
local function WaitT() if FT then pcall(function() FT.Completed:Wait() end); FT = nil end end

local function EquipAny(K)
    local c = LP.Character; local B = LP:FindFirstChild('Backpack')
    if not c or not B then return nil end
    for _, v in pairs(c:GetChildren()) do
        if v:IsA('Tool') and v.Name:lower():find(K:lower()) then return v end
    end
    for _, v in pairs(B:GetChildren()) do
        if v:IsA('Tool') and v.Name:lower():find(K:lower()) then
            pcall(function() c.Humanoid:EquipTool(v) end); return v
        end
    end
    return nil
end

local function Attack(Target)
    if not Target then return end
    local TargetPart = Target:FindFirstChild('HumanoidRootPart') or Target:FindFirstChildWhichIsA('BasePart')
    if not TargetPart then return end
    SafeInvoke(CommF_, 'Attack', TargetPart)
    pcall(function() VU:CaptureController(); VU:ClickButton1(Vector2.new()) end)
end

local function FindEnemy(N)
    pcall(function()
        local enemiesFolder = WS:FindFirstChild('Enemies')
        if enemiesFolder then
            for _, v in pairs(enemiesFolder:GetChildren()) do
                if v.Name == N and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                    local P = v:FindFirstChild('HumanoidRootPart')
                    if P then return v end
                end
            end
        end
    end)
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == N then
            local H = v:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = v:FindFirstChild('HumanoidRootPart')
                if P then return v end
            end
        end
    end
    return nil
end

local function FindMobSpawn(N)
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == N then
            local H = v:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = v:FindFirstChild('HumanoidRootPart')
                if P then return P.CFrame end
            end
        end
    end
    return nil
end

local function GetQuestNPC(N)
    for _, O in pairs(WS:GetDescendants()) do
        if O:IsA('Model') and O.Name == N then
            local H = O:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = O:FindFirstChild('HumanoidRootPart')
                if P then return O, P end
            end
        end
    end
    return nil, nil
end

local function IsQuestVisible()
    local ok, result = pcall(function()
        local Main = PG:FindFirstChild('Main')
        if not Main then return false end
        local Quest = Main:FindFirstChild('Quest')
        if not Quest then return false end
        return Quest.Visible
    end)
    return ok and result or false
end

-- ============================================================
-- V1 STYLE UI (Roblox GUI instances)
-- ============================================================
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'ZyrosHub'
ScreenGui.Parent = PG
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new('Frame')
MainFrame.Name = 'Main'
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0,600,0,400)
MainFrame.ClipsDescendants = true
Instance.new('UICorner', MainFrame).CornerRadius = UDim.new(0,8)
Instance.new('UIStroke', MainFrame).Color = Color3.fromRGB(40,40,50)

local TitleBar = Instance.new('Frame')
TitleBar.Name = 'TitleBar'
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(14,14,18)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1,0,0,35)
Instance.new('UICorner', TitleBar).CornerRadius = UDim.new(0,8)
local Fix = Instance.new('Frame', TitleBar)
Fix.BackgroundColor3 = Color3.fromRGB(14,14,18)
Fix.BorderSizePixel = 0
Fix.Position = UDim2.new(0,0,1,-10)
Fix.Size = UDim2.new(1,0,0,10)

local TitleLabel = Instance.new('TextLabel', TitleBar)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0,12,0,0)
TitleLabel.Size = UDim2.new(1,-24,1,0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = 'BLOX FRUITS | ZYROS HUB'
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new('TextButton', TitleBar)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1,-60,0,0)
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = 'X'
CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.TextSize = 14

local MinBtn = Instance.new('TextButton', TitleBar)
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1,-30,0,0)
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = '—'
MinBtn.TextColor3 = Color3.fromRGB(200,200,200)
MinBtn.TextSize = 16

CloseBtn.MouseButton1Click:Connect(function()
    Settings.AutoFarm=false; Settings.AutoMastery=false; Settings.AutoRaid=false
    Settings.AutoStats=false; Settings.FruitESP=false; Settings.FruitTween=false
    Settings.FruitNotify=false; Settings.PlayerESP=false; Settings.ChestESP=false
    DisNC(); StopT()
    pcall(function() ScreenGui:Destroy() end)
end)

local TabContainer = Instance.new('Frame', MainFrame)
TabContainer.BackgroundColor3 = Color3.fromRGB(14,14,18)
TabContainer.BorderSizePixel = 0
TabContainer.Position = UDim2.new(0,0,0,35)
TabContainer.Size = UDim2.new(0,120,1,-35)
Instance.new('UIListLayout', TabContainer).Padding = UDim.new(0,2)

local ContentFrame = Instance.new('Frame', MainFrame)
ContentFrame.BackgroundColor3 = Color3.fromRGB(22,22,28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0,125,0,40)
ContentFrame.Size = UDim2.new(1,-130,1,-45)
Instance.new('UICorner', ContentFrame).CornerRadius = UDim.new(0,6)

local ContentScroll = Instance.new('ScrollingFrame', ContentFrame)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.Position = UDim2.new(0,8,0,8)
ContentScroll.Size = UDim2.new(1,-16,1,-16)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(60,60,80)
ContentScroll.AutomaticSize = Enum.AutomaticSize.Y
Instance.new('UIListLayout', ContentScroll).Padding = UDim.new(0,6)

local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    ContentFrame.Visible = not Minimized
    TabContainer.Visible = not Minimized
    if Minimized then MainFrame.Size = UDim2.new(0,600,0,35); MinBtn.Text = '+'
    else MainFrame.Size = UDim2.new(0,600,0,400); MinBtn.Text = '—' end
end)

local Dragging, DragInput, DragStart, StartPos
TitleBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = Input.Position; StartPos = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
end)
UIS.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)
RunService.RenderStepped:Connect(function()
    if Dragging and DragInput then
        local Delta = DragInput.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset+Delta.X, StartPos.Y.Scale, StartPos.Y.Offset+Delta.Y)
    end
end)

local TabButtons = {}
local FirstTab = true

local function AddTab(Name)
    local Btn = Instance.new('TextButton', TabContainer)
    Btn.Name = Name
    Btn.BackgroundColor3 = FirstTab and Color3.fromRGB(40,40,55) or Color3.fromRGB(14,14,18)
    Btn.BorderSizePixel = 0
    Btn.Size = UDim2.new(1,-8,0,32)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = '  '..Name
    Btn.TextColor3 = Color3.fromRGB(200,200,210)
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = #TabButtons + 1
    Instance.new('UICorner', Btn).CornerRadius = UDim.new(0,6)
    FirstTab = false
    
    local Page = Instance.new('Frame', ContentScroll)
    Page.Name = Name
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1,0,0,0)
    Page.AutomaticSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Instance.new('UIListLayout', Page).Padding = UDim.new(0,6)
    
    Btn.MouseButton1Click:Connect(function()
        for _, B in pairs(TabButtons) do
            B.BackgroundColor3 = Color3.fromRGB(14,14,18)
            B.TextColor3 = Color3.fromRGB(200,200,210)
        end
        for _, T in pairs(TabButtons) do
            local pg = ContentScroll:FindFirstChild(T.Name)
            if pg then pg.Visible = false end
        end
        Btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        Btn.TextColor3 = Color3.fromRGB(255,255,255)
        Page.Visible = true
    end)
    
    table.insert(TabButtons, Btn)
    return Page
end

local function MakeToggle(Parent, Text, Callback)
    local F = Instance.new('Frame', Parent)
    F.BackgroundColor3 = Color3.fromRGB(35,35,45)
    F.BorderSizePixel = 0
    F.Size = UDim2.new(1,0,0,32)
    Instance.new('UICorner', F).CornerRadius = UDim.new(0,6)
    local St = Instance.new('UIStroke', F)
    St.Color = Color3.fromRGB(50,50,65); St.Thickness = 1
    local L = Instance.new('TextLabel', F)
    L.BackgroundTransparency = 1
    L.Position = UDim2.new(0,10,0,0)
    L.Size = UDim2.new(1,-50,1,0)
    L.Font = Enum.Font.Gotham; L.Text = Text
    L.TextColor3 = Color3.fromRGB(220,220,230)
    L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left
    local Sw = Instance.new('Frame', F)
    Sw.BackgroundColor3 = Color3.fromRGB(60,60,75)
    Sw.BorderSizePixel = 0
    Sw.Position = UDim2.new(1,-38,0.5,-10)
    Sw.Size = UDim2.new(0,28,0,20)
    Instance.new('UICorner', Sw).CornerRadius = UDim.new(0,10)
    local Ci = Instance.new('Frame', Sw)
    Ci.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Ci.BorderSizePixel = 0
    Ci.Position = UDim2.new(0.05,0,0.1,0)
    Ci.Size = UDim2.new(0.4,0,0.8,0)
    Instance.new('UICorner', Ci).CornerRadius = UDim.new(0,10)
    local B = Instance.new('TextButton', F)
    B.BackgroundTransparency = 1; B.Size = UDim2.new(1,0,1,0); B.Text = ''
    local V = false
    B.MouseButton1Click:Connect(function()
        V = not V
        Sw.BackgroundColor3 = V and Color3.fromRGB(0,200,100) or Color3.fromRGB(60,60,75)
        Ci.Position = V and UDim2.new(0.5,-2,0.1,0) or UDim2.new(0.05,0,0.1,0)
        if Callback then Callback(V) end
    end)
    return F
end

local function MakeButton(Parent, Text, Callback)
    local B = Instance.new('TextButton', Parent)
    B.BackgroundColor3 = Color3.fromRGB(35,35,45)
    B.BorderSizePixel = 0; B.Size = UDim2.new(1,0,0,32)
    B.Font = Enum.Font.Gotham; B.Text = '  '..Text
    B.TextColor3 = Color3.fromRGB(220,220,230)
    B.TextSize = 12; B.TextXAlignment = Enum.TextXAlignment.Left
    B.AutoButtonColor = false
    Instance.new('UICorner', B).CornerRadius = UDim.new(0,6)
    local St = Instance.new('UIStroke', B)
    St.Color = Color3.fromRGB(50,50,65); St.Thickness = 1
    B.MouseEnter:Connect(function() B.BackgroundColor3 = Color3.fromRGB(45,45,60) end)
    B.MouseLeave:Connect(function() B.BackgroundColor3 = Color3.fromRGB(35,35,45) end)
    B.MouseButton1Click:Connect(function() task.spawn(Callback) end)
    return B
end

local function MakeDropdown(Parent, Text, Default, Options, Callback)
    local V = Default
    local Frame = Instance.new('Frame', Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
    Frame.BorderSizePixel = 0; Frame.Size = UDim2.new(1,0,0,32)
    Frame.ClipsDescendants = true
    Instance.new('UICorner', Frame).CornerRadius = UDim.new(0,6)
    local St = Instance.new('UIStroke', Frame)
    St.Color = Color3.fromRGB(50,50,65); St.Thickness = 1
    local L = Instance.new('TextLabel', Frame)
    L.Name = 'Label'; L.BackgroundTransparency = 1
    L.Position = UDim2.new(0,10,0,0); L.Size = UDim2.new(1,-30,0.5,0)
    L.Font = Enum.Font.Gotham; L.Text = Text..': '..V
    L.TextColor3 = Color3.fromRGB(220,220,230); L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local B = Instance.new('TextButton', Frame)
    B.BackgroundTransparency = 1; B.Position = UDim2.new(1,-30,0,0)
    B.Size = UDim2.new(0,30,0,32); B.Font = Enum.Font.Gotham
    B.Text = 'v'; B.TextColor3 = Color3.fromRGB(200,200,210); B.TextSize = 12
    local CB = Instance.new('TextButton', Frame)
    CB.BackgroundTransparency = 1; CB.Size = UDim2.new(1,0,0,32)
    CB.Text = ''; CB.ZIndex = 2
    local OB = {}
    for i, O in ipairs(Options) do
        local OptionBtn = Instance.new('TextButton', Frame)
        OptionBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
        OptionBtn.BorderSizePixel = 0
        OptionBtn.Position = UDim2.new(0,4,0,32+((i-1)*28))
        OptionBtn.Size = UDim2.new(1,-8,0,26)
        OptionBtn.Font = Enum.Font.Gotham; OptionBtn.Text = '  '..O
        OptionBtn.TextColor3 = Color3.fromRGB(200,200,210)
        OptionBtn.TextSize = 11; OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptionBtn.Visible = false; OptionBtn.ZIndex = 3
        Instance.new('UICorner', OptionBtn).CornerRadius = UDim.new(0,4)
        OptionBtn.MouseButton1Click:Connect(function()
            V = Options[i]; L.Text = Text..': '..V
            Frame.Size = UDim2.new(1,0,0,32); B.Text = 'v'
            for _, X in pairs(OB) do X.Visible = false end
            if Callback then Callback(V) end
        end)
        table.insert(OB, OptionBtn)
    end
    local Open = false
    CB.MouseButton1Click:Connect(function()
        Open = not Open
        if Open then
            Frame.Size = UDim2.new(1,0,0,32+(#Options*28)); B.Text = '^'
            for _, X in pairs(OB) do X.Visible = true end
        else
            Frame.Size = UDim2.new(1,0,0,32); B.Text = 'v'
            for _, X in pairs(OB) do X.Visible = false end
        end
    end)
    return Frame
end

local function Section(Parent)
    local S = Instance.new('Frame', Parent)
    S.BackgroundColor3 = Color3.fromRGB(16,16,20)
    S.BorderSizePixel = 0; S.Size = UDim2.new(1,0,0,6)
    return S
end

local function Label(Parent, Text)
    local L = Instance.new('TextLabel', Parent)
    L.BackgroundTransparency = 1; L.Size = UDim2.new(1,0,0,20)
    L.Font = Enum.Font.GothamBold; L.Text = Text
    L.TextColor3 = Color3.fromRGB(255,170,0); L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    return L
end

local function TLabel(Parent, Text)
    local L = Instance.new('TextLabel', Parent)
    L.BackgroundTransparency = 1; L.Size = UDim2.new(1,0,0,16)
    L.Font = Enum.Font.Gotham; L.Text = Text
    L.TextColor3 = Color3.fromRGB(160,160,170); L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    return L
end

-- ============================================================
-- BUILD TABS
-- ============================================================
local FarmTab = AddTab('Farming')
local FruitTab = AddTab('Fruits')
local TeleportTab = AddTab('Teleport')
local VisualsTab = AddTab('Visuals')
local RaidTab = AddTab('Raids')
local OtherTab = AddTab('Other')

-- Farming Tab
Label(FarmTab, 'Auto Farm Level')
Section(FarmTab)
MakeDropdown(FarmTab, 'Farm Mode', Settings.FarmMode, {'Above','Behind','Below'}, function(V) Settings.FarmMode = V end)
MakeToggle(FarmTab, 'Auto Farm Level', function(V) Settings.AutoFarm = V end)
TLabel(FarmTab, 'Quests: 1-900+ | Auto-detects level')

Label(FarmTab, 'Auto Mastery')
Section(FarmTab)
MakeDropdown(FarmTab, 'Mastery Type', Settings.MasteryType, {'Melee','Sword','Gun','Blox Fruit'}, function(V) Settings.MasteryType = V end)
MakeToggle(FarmTab, 'Auto Mastery', function(V) Settings.AutoMastery = V end)
TLabel(FarmTab, 'Farms mastery for selected weapon type')

-- Fruits Tab
Label(FruitTab, 'Fruit ESP')
Section(FruitTab)
MakeToggle(FruitTab, 'Fruit ESP', function(V) Settings.FruitESP = V end)

Label(FruitTab, 'Fruit Tween')
Section(FruitTab)
MakeToggle(FruitTab, 'Tween to Fruits', function(V) Settings.FruitTween = V end)
TLabel(FruitTab, 'Smooth tween + no-clip to nearest fruit')

Label(FruitTab, 'Fruit Notifier')
Section(FruitTab)
MakeToggle(FruitTab, 'Fruit Notifier', function(V) Settings.FruitNotify = V end)

-- Teleport Tab
local IslandOrder = {'Starter Island','Jungle','Pirate Village','Desert','Frozen Village','Marine Fortress','Skylands','Prison','Colosseum','Magma Village','Underwater','Ice Adventure','Beautiful Pirate Castle','Snow Mountain','Death Step','Cursed Ship','Final Sea','Sea of Treats'}
local Islands = {
    ['Starter Island']=CFrame.new(978,18,1500),['Jungle']=CFrame.new(-1250,18,350),
    ['Pirate Village']=CFrame.new(-1150,18,450),['Desert']=CFrame.new(1100,18,450),
    ['Frozen Village']=CFrame.new(750,18,-1200),['Marine Fortress']=CFrame.new(-4500,30,400),
    ['Skylands']=CFrame.new(-4500,200,400),['Prison']=CFrame.new(4850,18,700),
    ['Colosseum']=CFrame.new(-1300,18,-2800),['Magma Village']=CFrame.new(-5200,18,7500),
    ['Underwater']=CFrame.new(5500,18,300),['Ice Adventure']=CFrame.new(6000,18,8000),
    ['Beautiful Pirate Castle']=CFrame.new(-5000,30,-3000),['Snow Mountain']=CFrame.new(300,400,-500),
    ['Death Step']=CFrame.new(300,18,-6000),['Cursed Ship']=CFrame.new(900,18,-11000),
    ['Final Sea']=CFrame.new(-6500,20,8500),['Sea of Treats']=CFrame.new(-1500,18,-14000),
}
Label(TeleportTab, 'Island Teleport')
Section(TeleportTab)
MakeDropdown(TeleportTab, 'Select Island', IslandOrder[1], IslandOrder, function(V)
    local T = Islands[V]
    if T then EnNC(); TweenTo(T); WaitT(); task.wait(1); DisNC() end
end)

-- Visuals Tab
Label(VisualsTab, 'Player ESP')
Section(VisualsTab)
MakeToggle(VisualsTab, 'Player ESP', function(V) Settings.PlayerESP = V end)

Label(VisualsTab, 'Chest ESP')
Section(VisualsTab)
MakeToggle(VisualsTab, 'Chest ESP', function(V) Settings.ChestESP = V end)

-- Raids Tab
Label(RaidTab, 'Auto Raid')
Section(RaidTab)
MakeToggle(RaidTab, 'Auto Raid', function(V) Settings.AutoRaid = V end)

-- Other Tab
Label(OtherTab, 'Auto Stats')
Section(OtherTab)
MakeDropdown(OtherTab, 'Stat Preset', 'Melee', {'Melee','Defense','Sword','Gun','Blox Fruit'}, function(V) Settings.StatType = V end)
MakeToggle(OtherTab, 'Auto Stats', function(V) Settings.AutoStats = V end)

Label(OtherTab, 'Server')
Section(OtherTab)
MakeButton(OtherTab, 'Server Hop', function()
    local PlaceId = game.PlaceId
    local Servers = {}
    local Cursor = ''
    for _ = 1, 5 do
        local S, R = pcall(function()
            return HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceId..'/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true&cursor='..Cursor))
        end)
        if S and R then
            for _, Srv in pairs(R.data or {}) do
                if Srv.id and Srv.playing and Srv.maxPlayers then
                    if Srv.playing < Srv.maxPlayers and Srv.id ~= game.JobId then
                        table.insert(Servers, Srv.id)
                    end
                end
            end
            if R.nextPageCursor then Cursor = R.nextPageCursor else break end
        end
        task.wait(0.5)
    end
    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, Servers[math.random(1,#Servers)], LP)
    end
end)
MakeButton(OtherTab, 'Rejoin Server', function()
    TeleportService:Teleport(994732206, LP)
end)

-- Show first tab
FarmTab.Visible = true

-- ============================================================
-- TEAM SETUP
-- ============================================================
task.spawn(function()
    pcall(function()
        if not LP:FindFirstChild('Data') then return end
        if not LP.Data.Team or LP.Data.Team.Value == '' then
            SafeInvoke(CommF_, 'SetTeam', 'Pirates')
        end
    end)
    LP.CharacterAdded:Connect(function()
        task.wait(1.5)
        pcall(function()
            if not LP.Data.Team or LP.Data.Team.Value == '' then
                SafeInvoke(CommF_, 'SetTeam', 'Pirates')
            end
        end)
    end)
end)

-- ============================================================
-- BUSO LOOP
-- ============================================================
task.spawn(function()
    local function ApplyBuso() SafeInvoke(CommF_, 'Buso') end
    task.wait(1); ApplyBuso()
    LP.CharacterAdded:Connect(function() task.wait(2); ApplyBuso() end)
    while true do
        if Settings.AutoFarm or Settings.AutoMastery or Settings.FruitTween or Settings.AutoRaid then
            pcall(function()
                local c = LP.Character; if not c then return end
                local H = c:FindFirstChildOfClass('Humanoid')
                if H then H.Sit = false end
                local BV = c:FindFirstChild('HasBuso')
                if not BV or not BV.Value then ApplyBuso() end
            end)
        end
        task.wait(3)
    end
end)

-- ============================================================
-- ESP SYSTEM (with cleanup)
-- ============================================================
local FruitHL = {}; local PlayerHL = {}; local ChestHL = {}

local function CleanHL(tbl)
    for obj, hl in pairs(tbl) do
        if not obj or not obj.Parent or (hl and not hl.Parent) then
            pcall(function() if hl then hl:Destroy() end end)
            tbl[obj] = nil
        end
    end
end

task.spawn(function()
    while true do
        pcall(function()
            if Settings.FruitESP then
                CleanHL(FruitHL)
                for _, Obj in pairs(WS:GetChildren()) do
                    if not FruitHL[Obj] and (Obj:IsA('Tool') or Obj:IsA('Model')) and Obj.Name:lower():find('fruit') then
                        local H = Instance.new('Highlight')
                        H.FillColor=Color3.fromRGB(255,170,0); H.FillTransparency=0.5
                        H.OutlineColor=Color3.fromRGB(255,255,0); H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee=Obj; H.Parent=WS; FruitHL[Obj]=H
                    end
                end
            else
                for _, H in pairs(FruitHL) do pcall(function() H:Destroy() end) end; FruitHL={}
            end
        end)
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Settings.PlayerESP then
                CleanHL(PlayerHL)
                for _, P in pairs(Players:GetPlayers()) do
                    if P~=LP and not PlayerHL[P] then
                        local H=Instance.new('Highlight')
                        H.FillColor=Color3.fromRGB(255,0,0); H.FillTransparency=0.7
                        H.OutlineColor=Color3.fromRGB(255,100,100); H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        H.Parent=WS; PlayerHL[P]=H
                    end
                end
                for P, H in pairs(PlayerHL) do
                    if P and P.Character then H.Adornee=P.Character else H.Adornee=nil end
                end
            else
                for _, H in pairs(PlayerHL) do pcall(function() H:Destroy() end) end; PlayerHL={}
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Settings.ChestESP then
                CleanHL(ChestHL)
                for _, Obj in pairs(WS:GetChildren()) do
                    if not ChestHL[Obj] and (Obj:IsA('Model') or Obj:IsA('Part')) and Obj.Name:lower():find('chest') then
                        local H=Instance.new('Highlight')
                        H.FillColor=Color3.fromRGB(0,170,255); H.FillTransparency=0.5
                        H.OutlineColor=Color3.fromRGB(100,200,255); H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee=Obj; H.Parent=WS; ChestHL[Obj]=H
                    end
                end
            else
                for _, H in pairs(ChestHL) do pcall(function() H:Destroy() end) end; ChestHL={}
            end
        end)
        task.wait(3)
    end
end)

-- ============================================================
-- FRUIT TWEEN
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.FruitTween and IsAlive() then
                EnNC()
                local Closest, MinDist = nil, math.huge
                local Char = LP.Character
                if Char then
                    local HRP = Char:FindFirstChild('HumanoidRootPart')
                    if HRP then
                        for _, Obj in pairs(WS:GetChildren()) do
                            if Obj:IsA('Tool') and Obj.Name:lower():find('fruit') then
                                local Handle = Obj:FindFirstChild('Handle')
                                if Handle then
                                    local Dist = (HRP.Position - Handle.Position).Magnitude
                                    if Dist < MinDist then MinDist = Dist; Closest = Handle end
                                end
                            end
                        end
                    end
                end
                if Closest then TweenTo(CFrame.new(Closest.Position+Vector3.new(0,3,0))); WaitT(); task.wait(0.5)
                else task.wait(2) end
            else DisNC() end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- FRUIT NOTIFIER
-- ============================================================
task.spawn(function()
    local Notified = {}
    while true do
        pcall(function()
            if Settings.FruitNotify then
                for _, Obj in pairs(WS:GetChildren()) do
                    if Obj:IsA('Tool') and Obj.Name:lower():find('fruit') and not Notified[Obj] then
                        Notified[Obj]=true; print('[Fruit] '..Obj.Name..' spawned!')
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ============================================================
-- AUTO FARM
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoFarm and IsAlive() then
                EnNC()
                local Lvl = GetLvl()
                local Q = CQ(Lvl)
                local NPC, NPCPos = GetQuestNPC(Q.N)
                if not IsQuestVisible() then
                    if NPC and NPCPos then
                        TweenTo(NPCPos.CFrame * CFrame.new(0,0,5)); WaitT()
                        SafeInvoke(CommF_, 'SetSpawnPoint')
                        SafeInvoke(CommF_, Q.QN, Q.QI)
                    else
                        TweenTo(Q.CF); WaitT()
                    end
                    task.wait(1.5)
                else
                    local Enemy = FindEnemy(Q.MN)
                    if Enemy then
                        local EHRP = Enemy:FindFirstChild('HumanoidRootPart')
                        if EHRP then
                            local Off = Settings.FarmMode=='Above' and CFrame.new(0,40,0)
                                or Settings.FarmMode=='Behind' and CFrame.new(0,0,-5)
                                or CFrame.new(0,-5,0)
                            local attempts = 0
                            while Settings.AutoFarm and attempts < 100 and IsAlive() do
                                local CurEnemy = FindEnemy(Q.MN)
                                if not CurEnemy then break end
                                local Hum = CurEnemy:FindFirstChildOfClass('Humanoid')
                                if not Hum or Hum.Health <= 0 then break end
                                local CHP = CurEnemy:FindFirstChild('HumanoidRootPart')
                                if not CHP then break end
                                TweenTo(CHP.CFrame * Off)
                                pcall(function()
                                    Hum.PlatformStand=true; Hum.Sit=true
                                    CHP.CanCollide=false; CHP.Size=Vector3.new(50,50,50)
                                end)
                                Attack(CurEnemy)
                                task.wait(0.3); attempts = attempts + 1
                            end
                        end
                    else
                        local SpawnCF = FindMobSpawn(Q.MN)
                        if SpawnCF then TweenTo(SpawnCF); WaitT() end
                        task.wait(1)
                    end
                end
            else DisNC() end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- AUTO MASTERY
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoMastery and IsAlive() then
                EnNC()
                local Lvl = GetLvl()
                local Target = Quests[1]
                for i=#Quests,1,-1 do if Lvl>=Quests[i].L then Target=Quests[i]; break end end
                if Settings.MasteryType=='Sword' then EquipAny('Sword')
                elseif Settings.MasteryType=='Gun' then EquipAny('Gun')
                elseif Settings.MasteryType=='Blox Fruit' then EquipAny('Fruit')
                else EquipAny('Combat') or EquipAny('Melee') end
                local NPC, HRP = GetQuestNPC(Target.N)
                if NPC and HRP then
                    TweenTo(HRP.CFrame*CFrame.new(0,30,0)); WaitT()
                    local A = 0
                    while Settings.AutoMastery and A<100 and IsAlive() do
                        local Hum = NPC:FindFirstChildOfClass('Humanoid')
                        if not Hum or Hum.Health<=0 then break end
                        Attack(NPC); task.wait(0.2); A=A+1
                    end
                else
                    local F = Target.N=='Bandit' and CFrame.new(978,18,1500) or CFrame.new(-1250,18,350)
                    TweenTo(F); WaitT()
                end
            else DisNC() end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- AUTO RAID
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoRaid and IsAlive() then
                EnNC()
                SafeInvoke(CommF_, 'Awakener', 'Check')
                SafeInvoke(CommF_, 'Awakener', 'Awaken')
                task.wait(2)
                for _, Obj in pairs(WS:GetChildren()) do
                    if Obj:IsA('Model') and Obj.Name:lower():find('raid') then
                        local Hum = Obj:FindFirstChildOfClass('Humanoid')
                        if Hum and Hum.Health>0 then
                            local HRP = Obj:FindFirstChild('HumanoidRootPart')
                            if HRP then
                                TweenTo(HRP.CFrame*CFrame.new(0,0,5)); WaitT()
                                local A = 0
                                while Hum.Health>0 and A<50 and Settings.AutoRaid do
                                    Attack(Obj); task.wait(0.3); A=A+1
                                end
                            end
                        end
                    end
                end
            else DisNC() end
        end)
        task.wait(5)
    end
end)

-- ============================================================
-- AUTO STATS
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoStats then
                local Data = LP:FindFirstChild('Data')
                if Data and Data.Stats and Data.Stats.Points then
                    local P = Data.Stats.Points.Value
                    if P > 0 then SafeInvoke(CommF_, 'AddPoint', Settings.StatType, 1) end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- UNLOAD
-- ============================================================
getgenv().ZyrosUnload = function()
    Settings.AutoFarm=false; Settings.AutoMastery=false; Settings.AutoRaid=false
    Settings.AutoStats=false; Settings.FruitESP=false; Settings.FruitTween=false
    Settings.FruitNotify=false; Settings.PlayerESP=false; Settings.ChestESP=false
    DisNC(); StopT()
    for _, H in pairs(FruitHL) do pcall(function() H:Destroy() end) end
    for _, H in pairs(PlayerHL) do pcall(function() H:Destroy() end) end
    for _, H in pairs(ChestHL) do pcall(function() H:Destroy() end) end
    pcall(function() ScreenGui:Destroy() end)
end

-- Initial buso
pcall(function() SafeInvoke(CommF_, 'Buso') end)

end

-- Run
local ok, err = pcall(Main)
if not ok then
    warn('[ZyrosHub] Error:', err)
end
