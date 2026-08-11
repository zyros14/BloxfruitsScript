--[[
    Zyros Hub - Blox Fruits
    Fixed version addressing all critical issues
]]

task.spawn(function()
pcall(function()
if not game:IsLoaded() then game.Loaded:Wait() end

-- Services
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local VU = game:GetService('VirtualUser')
local TS = game:GetService('TweenService')

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local RS = game:GetService('ReplicatedStorage')
local CommF_ = RS:WaitForChild('Remotes'):WaitForChild('CommF_')
local WS = game:GetService('Workspace')

-- Drawing API (bypasses CoreGui entirely)
local Drawing = Drawing or getgenv().Drawing
local Fonts = {UI=0, System=1, Plex=2, Monospace=3}

-- ============================================================
-- CENTRAL CONFIGURATION (Fix #8: Global Variable Overuse)
-- ============================================================
local Settings = {
    -- Feature toggles
    AutoFarm = false,
    AutoMastery = false,
    AutoRaid = false,
    AutoStats = false,
    FruitESP = false,
    FruitTween = false,
    FruitNotify = false,
    PlayerESP = false,
    ChestESP = false,
    
    -- Options
    FarmMode = 'Above',
    MasteryType = 'Melee',
    StatType = 'Melee',
    SelectedIsland = 'Starter Island',
    
    -- Internal
    AntiAFK = true,
}

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    BG = Color3.fromRGB(16,16,20), Title = Color3.fromRGB(12,12,16),
    Tab = Color3.fromRGB(24,24,30), ATab = Color3.fromRGB(50,50,65),
    Elem = Color3.fromRGB(32,32,42), EHov = Color3.fromRGB(45,45,58),
    TOff = Color3.fromRGB(60,60,75), TOn = Color3.fromRGB(0,200,100),
    Text = Color3.fromRGB(220,220,230), TDim = Color3.fromRGB(150,150,160),
    Acc = Color3.fromRGB(255,170,0), Red = Color3.fromRGB(255,80,80),
    Wht = Color3.fromRGB(255,255,255), Gry = Color3.fromRGB(180,180,190),
    Bdr = Color3.fromRGB(45,45,55), Orange = Color3.fromRGB(255,140,0),
}

-- ============================================================
-- UI STATE (Drawing API)
-- ============================================================
local UI = {
    Vis = false, Pos = Vector2.new(250, 120), Size = Vector2.new(420, 340),
    Drag = false, DragOff = Vector2.new(0,0),
    Minimized = false, PrevSize = Vector2.new(420, 340),
}
local Tabs = {'Farm','Fruits','Teleport','Visuals','Raids','Other'}
local CurTab = 1

-- Clickable UI elements registry
local Elements = {} -- {name={x,y,w,h,type,action}}

local D = {} -- Drawing objects
local function AD(n, d) D[n] = d; d.Visible = false end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHum() local c = LP.Character; return c and c:FindFirstChildOfClass('Humanoid') end
local function GetHRP() local c = LP.Character; return c and c:FindFirstChild('HumanoidRootPart') end
local function GetLvl() local d = LP:FindFirstChild('Data'); if d and d:FindFirstChild('Level') then return d.Level.Value end; return 1 end
local function IsAlive() local h = GetHum(); return h and h.Health > 0 end
local function MP() return Vector2.new(Mouse.X, Mouse.Y) end
local function InB(P, S, B) return B.X >= P.X and B.X <= P.X+S.X and B.Y >= P.Y and B.Y <= P.Y+S.Y end
local function SafeCall(fn, ...) local ok, err = pcall(fn, ...); if not err then return ok else return false end end

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
        local c = LP.Character; if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA('BasePart') and v.CanCollide then v.CanCollide = false end
        end
    end)
end
local function DisNC()
    if NC then NC:Disconnect(); NC = nil end
    -- Re-enable collision on character
    pcall(function()
        local c = LP.Character; if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then v.CanCollide = true end
        end
    end)
end

-- Tween system with proper cancellation
local FT = nil
local function TweenTo(CF)
    StopT() -- Cancel previous tween (Fix #6)
    local P = GetHRP(); if not P then return end
    local Dist = (P.Position - CF.Position).Magnitude
    if Dist < 3 then return end
    local Spd = math.max(Dist / 250, 0.3) -- Dynamic speed, min 0.3s
    FT = TS:Create(P, TweenInfo.new(Spd, Enum.EasingStyle.Linear), {CFrame = CF})
    FT:Play()
end
local function StopT()
    if FT then pcall(function() FT:Cancel() end); FT = nil end
end
local function WaitT()
    if FT then
        local ok = pcall(function() FT.Completed:Wait() end)
        FT = nil
        return ok
    end
    return true
end

-- Wait until close to target (alternative to tween wait)
local function WaitNear(CF, Dist)
    local timeout = tick() + 10
    while tick() < timeout do
        local P = GetHRP(); if not P then return false end
        if (P.Position - CF.Position).Magnitude < (Dist or 5) then return true end
        task.wait(0.1)
    end
    return false
end

local function EquipAny(K)
    local c = LP.Character; local B = LP:FindFirstChild('Backpack')
    if not c or not B then return nil end
    -- Check if already equipped
    for _, v in pairs(c:GetChildren()) do
        if v:IsA('Tool') and v.Name:lower():find(K:lower()) then return v end
    end
    for _, v in pairs(B:GetChildren()) do
        if v:IsA('Tool') and v.Name:lower():find(K:lower()) then
            c.Humanoid:EquipTool(v); return v
        end
    end
    return nil
end

-- Attack with proper target (Fix #4)
local function Attack(Target)
    if not Target then return end
    -- Use HumanoidRootPart as target for more reliable hits
    local TargetPart = Target:FindFirstChild('HumanoidRootPart') or Target:FindFirstChildWhichIsA('BasePart')
    if not TargetPart then return end
    pcall(function() CommF_:InvokeServer('Attack', TargetPart) end)
    pcall(function() VU:CaptureController(); VU:ClickButton1(Vector2.new()) end)
end

-- Find enemy by name (Fix #9: More reliable search)
local function FindEnemy(Name)
    local enemiesFolder = WS:FindFirstChild('Enemies')
    if enemiesFolder then
        for _, v in pairs(enemiesFolder:GetChildren()) do
            if v.Name == Name and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                local P = v:FindFirstChild('HumanoidRootPart')
                if P then return v end
            end
        end
    end
    -- Fallback: search workspace children
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == Name then
            local H = v:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = v:FindFirstChild('HumanoidRootPart')
                if P then return v end
            end
        end
    end
    return nil
end

-- Find mob spawn location
local function FindMobSpawn(Name)
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == Name then
            local H = v:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = v:FindFirstChild('HumanoidRootPart')
                if P then return P.CFrame end
            end
        end
    end
    return nil
end

-- Check if quest is visible (read-only PlayerGui access)
local function IsQuestVisible()
    local ok, result = pcall(function()
        local PG = LP:FindFirstChild('PlayerGui')
        if not PG then return false end
        local Main = PG:FindFirstChild('Main')
        if not Main then return false end
        local Quest = Main:FindFirstChild('Quest')
        if not Quest then return false end
        return Quest.Visible
    end)
    return ok and result or false
end

-- Get quest NPC
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

-- ============================================================
-- ANTI-AFK (Fix #11)
-- ============================================================
task.spawn(function()
    while true do
        if Settings.AntiAFK then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton1(Vector2.new(100, 100))
            end)
        end
        task.wait(60)
    end
end)

-- ============================================================
-- TEAM SETUP
-- ============================================================
task.spawn(function()
    pcall(function()
        if not LP:FindFirstChild('Data') then return end
        if not LP.Data.Team or LP.Data.Team.Value == '' then
            CommF_:InvokeServer('SetTeam', 'Pirates')
        end
    end)
    LP.CharacterAdded:Connect(function()
        task.wait(1.5)
        pcall(function()
            if not LP.Data.Team or LP.Data.Team.Value == '' then
                CommF_:InvokeServer('SetTeam', 'Pirates')
            end
        end)
    end)
end)

-- ============================================================
-- BUSO LOOP
-- ============================================================
task.spawn(function()
    local function ApplyBuso()
        pcall(function() CommF_:InvokeServer('Buso') end)
    end
    task.wait(1); ApplyBuso()
    LP.CharacterAdded:Connect(function() task.wait(2); ApplyBuso() end)
    
    -- Periodic buso re-apply
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
-- DRAWING UI SYSTEM
-- ============================================================
local UIHeight = 0 -- Track content height for scrolling

local function CreateUI()
    -- Main background
    AD('BG', Drawing.new('Square'))
    D.BG.Size = UI.Size; D.BG.Color = C.BG; D.BG.Filled = true
    -- Title bar
    AD('TB', Drawing.new('Square'))
    D.TB.Size = Vector2.new(UI.Size.X, 28); D.TB.Color = C.Title; D.BG.Filled = true
    AD('TB2', Drawing.new('Square'))
    D.TB2.Size = Vector2.new(UI.Size.X, 28); D.TB2.Color = C.Title; D.TB2.Filled = true
    -- Title text
    AD('TT', Drawing.new('Text'))
    D.TT.Text = 'BLOX FRUITS | ZYROS HUB'
    D.TT.Color = C.Wht; D.TT.Size = 13; D.TT.Font = Fonts.UI; D.TT.Outline = true
    -- Close button
    AD('XB', Drawing.new('Text'))
    D.XB.Text = 'X'
    D.XB.Color = C.Red; D.XB.Size = 13; D.XB.Font = Fonts.UI; D.XB.Outline = true
    -- Minimize button
    AD('MB', Drawing.new('Text'))
    D.MB.Text = '-'
    D.MB.Color = C.Gry; D.MB.Size = 13; D.MB.Font = Fonts.UI; D.MB.Outline = true
    -- Tab buttons
    for i, T in ipairs(Tabs) do
        AD('TabBG'..i, Drawing.new('Square'))
        D['TabBG'..i].Filled = true
        AD('TabT'..i, Drawing.new('Text'))
        D['TabT'..i].Text = T
        D['TabT'..i].Color = C.Text; D['TabT'..i].Size = 11
        D['TabT'..i].Font = Fonts.UI; D['TabT'..i].Outline = true
    end
    -- Content area background
    AD('CABG', Drawing.new('Square'))
    D.CABG.Color = C.BG; D.CABG.Filled = true
end

local function UpdatePositions()
    local p = UI.Pos; local s = UI.Size
    -- Main frame
    D.BG.Position = p; D.BG.Size = s
    D.TB.Position = p
    D.TT.Position = p + Vector2.new(8, 6)
    D.XB.Position = p + Vector2.new(s.X - 25, 6)
    D.MB.Position = p + Vector2.new(s.X - 45, 6)
    -- Content area
    D.CABG.Position = p + Vector2.new(95, 28)
    D.CABG.Size = Vector2.new(s.X - 100, s.Y - 32)
    -- Tab buttons
    for i, T in ipairs(Tabs) do
        local ty = 28 + (i - 1) * 30
        D['TabBG'..i].Position = p + Vector2.new(0, ty)
        D['TabBG'..i].Size = Vector2.new(92, 26)
        D['TabT'..i].Position = p + Vector2.new(8, ty + 5)
    end
end

local function SetAllVisible(V)
    for _, d in pairs(D) do d.Visible = V end
end

local function UpdateTabColors()
    for i, T in ipairs(Tabs) do
        D['TabBG'..i].Color = (i == CurTab) and C.ATab or C.Tab
    end
end

-- Create content elements for each tab
local ContentElements = {}

local function RegisterElement(name, x, y, w, h, etype, action)
    table.insert(ContentElements, {
        name = name, x = x, y = y, w = w, h = h,
        type = etype, action = action, value = nil
    })
end

local function BuildContentElements()
    ContentElements = {}
    local baseX = 100 -- Offset for content area
    local baseY = 32
    
    if CurTab == 1 then -- Farm
        RegisterElement('AF', baseX, baseY, 180, 24, 'toggle', function() Settings.AutoFarm = not Settings.AutoFarm end)
        RegisterElement('AM', baseX, baseY + 30, 180, 24, 'toggle', function() Settings.AutoMastery = not Settings.AutoMastery end)
        RegisterElement('FM', baseX, baseY + 60, 180, 24, 'dropdown', function()
            local modes = {'Above','Behind','Below'}
            local idx = table.find(modes, Settings.FarmMode) or 1
            Settings.FarmMode = modes[(idx % #modes) + 1]
        end)
        RegisterElement('MT', baseX, baseY + 90, 180, 24, 'dropdown', function()
            local types = {'Melee','Sword','Gun','Blox Fruit'}
            local idx = table.find(types, Settings.MasteryType) or 1
            Settings.MasteryType = types[(idx % #types) + 1]
        end)
    elseif CurTab == 2 then -- Fruits
        RegisterElement('FEP', baseX, baseY, 180, 24, 'toggle', function() Settings.FruitESP = not Settings.FruitESP end)
        RegisterElement('FTW', baseX, baseY + 30, 180, 24, 'toggle', function() Settings.FruitTween = not Settings.FruitTween end)
        RegisterElement('FNT', baseX, baseY + 60, 180, 24, 'toggle', function() Settings.FruitNotify = not Settings.FruitNotify end)
    elseif CurTab == 3 then -- Teleport
        local islandNames = {'Starter Island','Jungle','Pirate Village','Desert','Frozen Village','Marine Fortress','Skylands','Prison','Colosseum','Magma Village','Underwater','Ice Adventure','Final Sea'}
        for i, name in ipairs(islandNames) do
            RegisterElement('ISL_'..i, baseX, baseY + (i-1)*26, 200, 22, 'button', function()
                Settings.SelectedIsland = name
                -- Teleport to island
                local islands = {
                    ['Starter Island']=CFrame.new(978,18,1500),['Jungle']=CFrame.new(-1250,18,350),
                    ['Pirate Village']=CFrame.new(-1150,18,450),['Desert']=CFrame.new(1100,18,450),
                    ['Frozen Village']=CFrame.new(750,18,-1200),['Marine Fortress']=CFrame.new(-4500,30,400),
                    ['Skylands']=CFrame.new(-4500,200,400),['Prison']=CFrame.new(4850,18,700),
                    ['Colosseum']=CFrame.new(-1300,18,-2800),['Magma Village']=CFrame.new(-5200,18,7500),
                    ['Underwater']=CFrame.new(5500,18,300),['Ice Adventure']=CFrame.new(6000,18,8000),
                    ['Final Sea']=CFrame.new(-6500,20,8500),
                }
                local CF = islands[name]
                if CF then
                    EnNC(); TweenTo(CF); WaitT(); task.wait(1); DisNC()
                end
            end)
        end
    elseif CurTab == 4 then -- Visuals
        RegisterElement('PEP', baseX, baseY, 180, 24, 'toggle', function() Settings.PlayerESP = not Settings.PlayerESP end)
        RegisterElement('CEP', baseX, baseY + 30, 180, 24, 'toggle', function() Settings.ChestESP = not Settings.ChestESP end)
    elseif CurTab == 5 then -- Raids
        RegisterElement('AR', baseX, baseY, 180, 24, 'toggle', function() Settings.AutoRaid = not Settings.AutoRaid end)
    elseif CurTab == 6 then -- Other
        RegisterElement('AS', baseX, baseY, 180, 24, 'toggle', function() Settings.AutoStats = not Settings.AutoStats end)
        RegisterElement('ST', baseX, baseY + 30, 180, 24, 'dropdown', function()
            local stats = {'Melee','Defense','Sword','Gun','Blox Fruit'}
            local idx = table.find(stats, Settings.StatType) or 1
            Settings.StatType = stats[(idx % #stats) + 1]
        end)
        RegisterElement('HOP', baseX, baseY + 60, 180, 24, 'button', function()
            ServerHop()
        end)
        RegisterElement('REJ', baseX, baseY + 90, 180, 24, 'button', function()
            TeleportService:Teleport(994732206, LP)
        end)
    end
end

-- Draw content elements
local function DrawContent()
    -- Remove old content drawings
    for k, v in pairs(D) do
        if k:sub(1,3) == 'CEL' then v:Remove(); D[k] = nil end
    end
    
    for i, elem in ipairs(ContentElements) do
        local px = UI.Pos.X + elem.x
        local py = UI.Pos.Y + elem.y
        
        -- Background
        local bgName = 'CEL_BG_'..i
        if not D[bgName] then
            AD(bgName, Drawing.new('Square'))
            D[bgName].Filled = true
        end
        D[bgName].Position = Vector2.new(px, py)
        D[bgName].Size = Vector2.new(elem.w, elem.h)
        
        -- Determine color based on type and state
        local bgColor = C.Elem
        local textColor = C.Text
        local label = elem.name
        
        if elem.type == 'toggle' then
            local isOn = false
            if elem.name == 'AF' then isOn = Settings.AutoFarm
            elseif elem.name == 'AM' then isOn = Settings.AutoMastery
            elseif elem.name == 'FEP' then isOn = Settings.FruitESP
            elseif elem.name == 'FTW' then isOn = Settings.FruitTween
            elseif elem.name == 'FNT' then isOn = Settings.FruitNotify
            elseif elem.name == 'PEP' then isOn = Settings.PlayerESP
            elseif elem.name == 'CEP' then isOn = Settings.ChestESP
            elseif elem.name == 'AR' then isOn = Settings.AutoRaid
            elseif elem.name == 'AS' then isOn = Settings.AutoStats
            end
            bgColor = isOn and C.TOn or C.TOff
            textColor = C.Wht
            label = elem.name .. ': ' and (isOn and 'ON' or 'OFF')
            -- Simplified label
            local onOff = isOn and 'ON' or 'OFF'
            label = string.format('%-8s [%s]', elem.name, onOff)
        elseif elem.type == 'dropdown' then
            bgColor = C.Elem
            local val = ''
            if elem.name == 'FM' then val = Settings.FarmMode
            elseif elem.name == 'MT' then val = Settings.MasteryType
            elseif elem.name == 'ST' then val = Settings.StatType
            end
            label = string.format('%s: %s', elem.name, val)
        elseif elem.type == 'button' then
            bgColor = C.Acc
            textColor = C.Wht
            if elem.name:sub(1,3) == 'ISL' then
                local idx = tonumber(elem.name:sub(5))
                local names = {'Starter Island','Jungle','Pirate Village','Desert','Frozen Village','Marine Fortress','Skylands','Prison','Colosseum','Magma Village','Underwater','Ice Adventure','Final Sea'}
                label = names[idx] or 'Island'
            elseif elem.name == 'HOP' then label = 'Server Hop'
            elseif elem.name == 'REJ' then label = 'Rejoin'
            end
        end
        
        D[bgName].Color = bgColor
        
        -- Text
        local txtName = 'CEL_TXT_'..i
        if not D[txtName] then
            AD(txtName, Drawing.new('Text'))
            D[txtName].Size = 11; D[txtName].Font = Fonts.UI; D[txtName].Outline = true
        end
        D[txtName].Position = Vector2.new(px + 6, py + 4)
        D[txtName].Text = label
        D[txtName].Color = textColor
    end
end

-- Initialize UI
CreateUI()
UpdatePositions()
SetAllVisible(false)
BuildContentElements()
DrawContent()

print('[ZyrosHub] Loaded! Press RightShift to open UI')

-- ============================================================
-- INPUT HANDLING (Fix #1: UI Interaction)
-- ============================================================
UIS.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    -- Toggle UI with RightShift
    if Input.KeyCode == Enum.KeyCode.RightShift then
        UI.Vis = not UI.Vis
        if UI.Vis then
            SetAllVisible(true)
            UpdatePositions()
            UpdateTabColors()
            BuildContentElements()
            DrawContent()
        else
            SetAllVisible(false)
        end
        return
    end
    
    -- Mouse click handling
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and UI.Vis then
        local M = MP()
        
        -- Tab clicks
        for i, T in ipairs(Tabs) do
            local tp = UI.Pos + Vector2.new(0, 28 + (i-1)*30)
            if InB(Vector2.new(92, 26), tp, M) then
                CurTab = i
                UpdateTabColors()
                BuildContentElements()
                DrawContent()
                return
            end
        end
        
        -- Close button
        local xp = UI.Pos + Vector2.new(UI.Size.X - 25, 6)
        if InB(Vector2.new(20, 20), xp, M) then
            -- Stop all features
            Settings.AutoFarm = false
            Settings.AutoMastery = false
            Settings.AutoRaid = false
            Settings.AutoStats = false
            Settings.FruitESP = false
            Settings.FruitTween = false
            Settings.FruitNotify = false
            Settings.PlayerESP = false
            Settings.ChestESP = false
            DisNC(); StopT()
            UI.Vis = false; SetAllVisible(false)
            return
        end
        
        -- Minimize button
        local mp = UI.Pos + Vector2.new(UI.Size.X - 45, 6)
        if InB(Vector2.new(20, 20), mp, M) then
            UI.Vis = false; SetAllVisible(false)
            return
        end
        
        -- Content element clicks
        for i, elem in ipairs(ContentElements) do
            local ex = UI.Pos.X + elem.x
            local ey = UI.Pos.Y + elem.y
            if InB(Vector2.new(elem.w, elem.h), Vector2.new(ex, ey), M) then
                pcall(elem.action)
                -- Redraw to show updated state
                task.wait(0.05)
                DrawContent()
                return
            end
        end
    end
end)

-- ============================================================
-- UNLOAD FUNCTION
-- ============================================================
getgenv().ZyrosUnload = function()
    Settings.AutoFarm = false; Settings.AutoMastery = false
    Settings.AutoRaid = false; Settings.AutoStats = false
    Settings.FruitESP = false; Settings.FruitTween = false
    Settings.FruitNotify = false; Settings.PlayerESP = false; Settings.ChestESP = false
    DisNC(); StopT()
    -- Clean up ESP
    for _, H in pairs(_G.ZyrosFH or {}) do pcall(function() H:Destroy() end) end
    for _, H in pairs(_G.ZyrosPH or {}) do pcall(function() H:Destroy() end) end
    for _, H in pairs(_G.ZyrosCH or {}) do pcall(function() H:Destroy() end) end
    _G.ZyrosFH = {}; _G.ZyrosPH = {}; _G.ZyrosCH = {}
    UI.Vis = false; SetAllVisible(false)
end

-- ============================================================
-- ESP SYSTEM (Fix #2: Memory Leak Prevention)
-- ============================================================
local FruitHL = {}
local PlayerHL = {}
local ChestHL = {}

-- Cleanup function for dead highlights
local function CleanHL(tbl)
    for obj, hl in pairs(tbl) do
        if not obj or not obj.Parent or (hl and not hl.Parent) then
            pcall(function() if hl then hl:Destroy() end end)
            tbl[obj] = nil
        end
    end
end

-- Fruit ESP
task.spawn(function()
    while true do
        pcall(function()
            if Settings.FruitESP then
                -- Clean up old highlights
                CleanHL(FruitHL)
                -- Add new highlights
                for _, Obj in pairs(WS:GetChildren()) do
                    if not FruitHL[Obj] and (Obj:IsA('Tool') or Obj:IsA('Model')) and Obj.Name:lower():find('fruit') then
                        local H = Instance.new('Highlight')
                        H.FillColor = Color3.fromRGB(255,170,0); H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(255,255,0); H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj; H.Parent = WS
                        FruitHL[Obj] = H
                    end
                end
            else
                for _, H in pairs(FruitHL) do pcall(function() H:Destroy() end) end
                FruitHL = {}
            end
        end)
        task.wait(2)
    end
end)

-- Player ESP
task.spawn(function()
    while true do
        pcall(function()
            if Settings.PlayerESP then
                CleanHL(PlayerHL)
                for _, P in pairs(Players:GetPlayers()) do
                    if P ~= LP and not PlayerHL[P] then
                        local H = Instance.new('Highlight')
                        H.FillColor = Color3.fromRGB(255,0,0); H.FillTransparency = 0.7
                        H.OutlineColor = Color3.fromRGB(255,100,100); H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Parent = WS
                        PlayerHL[P] = H
                    end
                end
                -- Update adornees
                for P, H in pairs(PlayerHL) do
                    if P and P.Character then H.Adornee = P.Character else H.Adornee = nil end
                end
            else
                for _, H in pairs(PlayerHL) do pcall(function() H:Destroy() end) end
                PlayerHL = {}
            end
        end)
        task.wait(1)
    end
end)

-- Chest ESP
task.spawn(function()
    while true do
        pcall(function()
            if Settings.ChestESP then
                CleanHL(ChestHL)
                for _, Obj in pairs(WS:GetChildren()) do
                    if not ChestHL[Obj] and (Obj:IsA('Model') or Obj:IsA('Part')) and Obj.Name:lower():find('chest') then
                        local H = Instance.new('Highlight')
                        H.FillColor = Color3.fromRGB(0,170,255); H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(100,200,255); H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj; H.Parent = WS
                        ChestHL[Obj] = H
                    end
                end
            else
                for _, H in pairs(ChestHL) do pcall(function() H:Destroy() end) end
                ChestHL = {}
            end
        end)
        task.wait(3)
    end
end)

-- Fruit Tween
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
                if Closest then
                    TweenTo(CFrame.new(Closest.Position + Vector3.new(0, 3, 0)))
                    WaitT()
                    task.wait(0.5)
                else
                    task.wait(2)
                end
            else
                DisNC()
            end
        end)
        task.wait(0.5)
    end
end)

-- Fruit Notifier
task.spawn(function()
    local Notified = {}
    while true do
        pcall(function()
            if Settings.FruitNotify then
                for _, Obj in pairs(WS:GetChildren()) do
                    if Obj:IsA('Tool') and Obj.Name:lower():find('fruit') and not Notified[Obj] then
                        Notified[Obj] = true
                        print('[Fruit] ' .. Obj.Name .. ' spawned!')
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ============================================================
-- AUTO FARM (Fix #3: Farming Logic)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoFarm and IsAlive() then
                EnNC()
                local Lvl = GetLvl()
                local Q = CQ(Lvl)
                local NPC, NPCPos = GetQuestNPC(Q.N)
                
                -- Check if quest is already accepted
                if not IsQuestVisible() then
                    -- Accept quest
                    if NPC and NPCPos then
                        TweenTo(NPCPos.CFrame * CFrame.new(0, 0, 5))
                        WaitT()
                        pcall(function() CommF_:InvokeServer('SetSpawnPoint') end)
                        pcall(function() CommF_:InvokeServer(Q.QN, Q.QI) end)
                    else
                        TweenTo(Q.CF)
                        WaitT()
                    end
                    task.wait(1.5)
                else
                    -- Quest active, find enemy
                    local Enemy = FindEnemy(Q.MN)
                    if Enemy then
                        local EHRP = Enemy:FindFirstChild('HumanoidRootPart')
                        if EHRP then
                            local Off = Settings.FarmMode == 'Above' and CFrame.new(0, 40, 0)
                                or Settings.FarmMode == 'Behind' and CFrame.new(0, 0, -5)
                                or CFrame.new(0, -5, 0)
                            
                            -- Attack loop with health check
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
                                    Hum.PlatformStand = true
                                    Hum.Sit = true
                                    CHP.CanCollide = false
                                    CHP.Size = Vector3.new(50, 50, 50)
                                end)
                                Attack(CurEnemy)
                                task.wait(0.3)
                                attempts = attempts + 1
                            end
                        end
                    else
                        -- No enemy found, go to spawn
                        local SpawnCF = FindMobSpawn(Q.MN)
                        if SpawnCF then
                            TweenTo(SpawnCF)
                            WaitT()
                        end
                        task.wait(1)
                    end
                end
            else
                DisNC()
            end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- AUTO MASTERY (Fix #10: Equip Issues)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoMastery and IsAlive() then
                EnNC()
                local Lvl = GetLvl()
                -- Find appropriate target
                local Target = Quests[1]
                for i = #Quests, 1, -1 do
                    if Lvl >= Quests[i].L then Target = Quests[i]; break end
                end
                
                -- Equip weapon (Fix #10: Handle fighting styles)
                if Settings.MasteryType == 'Sword' then
                    EquipAny('Sword')
                elseif Settings.MasteryType == 'Gun' then
                    EquipAny('Gun')
                elseif Settings.MasteryType == 'Blox Fruit' then
                    EquipAny('Fruit')
                else
                    -- Melee: just use combat (no tool needed)
                    EquipAny('Combat') or EquipAny('Melee') or EquipAny('Fighting')
                end
                
                local NPC, HRP = GetQuestNPC(Target.N)
                if NPC and HRP then
                    TweenTo(HRP.CFrame * CFrame.new(0, 30, 0))
                    WaitT()
                    local A = 0
                    while Settings.AutoMastery and A < 100 and IsAlive() do
                        local Hum = NPC:FindFirstChildOfClass('Humanoid')
                        if not Hum or Hum.Health <= 0 then break end
                        Attack(NPC)
                        task.wait(0.2)
                        A = A + 1
                    end
                else
                    local Fallback = Target.N == 'Bandit' and CFrame.new(978, 18, 1500) or CFrame.new(-1250, 18, 350)
                    TweenTo(Fallback)
                    WaitT()
                end
            else
                DisNC()
            end
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
                pcall(function() CommF_:InvokeServer('Awakener', 'Check') end)
                pcall(function() CommF_:InvokeServer('Awakener', 'Awaken') end)
                task.wait(2)
                for _, Obj in pairs(WS:GetChildren()) do
                    if Obj:IsA('Model') and Obj.Name:lower():find('raid') then
                        local Hum = Obj:FindFirstChildOfClass('Humanoid')
                        if Hum and Hum.Health > 0 then
                            local HRP = Obj:FindFirstChild('HumanoidRootPart')
                            if HRP then
                                TweenTo(HRP.CFrame * CFrame.new(0, 0, 5))
                                WaitT()
                                local A = 0
                                while Hum.Health > 0 and A < 50 and Settings.AutoRaid do
                                    Attack(Obj)
                                    task.wait(0.3)
                                    A = A + 1
                                end
                            end
                        end
                    end
                end
            else
                DisNC()
            end
        end)
        task.wait(5)
    end
end)

-- ============================================================
-- AUTO STATS (Fix #4: Correct remote args)
-- ============================================================
task.spawn(function()
    while true do
        pcall(function()
            if Settings.AutoStats then
                local Data = LP:FindFirstChild('Data')
                if Data and Data.Stats and Data.Stats.Points then
                    local P = Data.Stats.Points.Value
                    if P > 0 then
                        -- AddPoint expects stat name and amount (1 point at a time)
                        pcall(function()
                            CommF_:InvokeServer('AddPoint', Settings.StatType, 1)
                        end)
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ============================================================
-- SERVER HOP (Fix #5: Robust implementation)
-- ============================================================
function ServerHop()
    pcall(function()
        local PlaceId = game.PlaceId
        local Servers = {}
        local URL = 'https://games.roblox.com/v1/games/' .. PlaceId .. '/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true'
        
        local S, R = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(URL))
        end)
        
        if S and R and R.data then
            for _, Srv in pairs(R.data) do
                if Srv.id and Srv.playing and Srv.maxPlayers then
                    if Srv.playing < Srv.maxPlayers and Srv.id ~= game.JobId then
                        table.insert(Servers, Srv.id)
                    end
                end
            end
        end
        
        if #Servers > 0 then
            local Target = Servers[math.random(1, #Servers)]
            TeleportService:TeleportToPlaceInstance(PlaceId, Target, LP)
        else
            -- Fallback: rejoin
            TeleportService:Teleport(PlaceId, LP)
        end
    end)
end

end)
end)
