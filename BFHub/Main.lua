local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Hub = {}
Hub.Tabs = {}
Hub.CurrentTab = nil
Hub.Connections = {}

local function Gethui()
    local Success, Result = pcall(function()
        if gethui then return gethui() end
    end)
    if Success and Result then return Result end
    Success, Result = pcall(function()
        if cloneref then return cloneref(CoreGui) end
    end)
    if Success and Result then return Result end
    Success, Result = pcall(function() return CoreGui end)
    if Success and Result then return Result end
    return PlayerGui
end

local function Create(Class, Properties, Children)
    local Inst = Instance.new(Class)
    for Prop, Val in pairs(Properties or {}) do
        Inst[Prop] = Val
    end
    for _, Child in pairs(Children or {}) do
        Child.Parent = Inst
    end
    return Inst
end

local ScreenGui = Create("ScreenGui", {
    Name = "ZyrosHub",
    Parent = Gethui(),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

local MainFrame = Create("Frame", {
    Name = "Main",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -300, 0.5, -200),
    Size = UDim2.new(0, 600, 0, 400),
    ClipsDescendants = true
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Thickness = 1})
})

local TitleBar = Create("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 35)
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
    Create("Frame", {
        Name = "Fix",
        BackgroundColor3 = Color3.fromRGB(14, 14, 18),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })
})

local TitleLabel = Create("TextLabel", {
    Name = "Title",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "BLOX FRUITS | ZYROS HUB",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

local MinimizeBtn = Create("TextButton", {
    Name = "Minimize",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -30, 0, 0),
    Size = UDim2.new(0, 30, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 16
})

local TabContainer = Create("Frame", {
    Name = "Tabs",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 35),
    Size = UDim2.new(0, 120, 1, -35)
})

Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

local ContentFrame = Create("Frame", {
    Name = "Content",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(22, 22, 28),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 125, 0, 40),
    Size = UDim2.new(1, -130, 1, -45)
}, {
    Create("UICorner", {CornerRadius = UDim.new(0, 6)})
})

local ContentScroll = Create("ScrollingFrame", {
    Name = "Scroll",
    Parent = ContentFrame,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 1, -16),
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80),
    AutomaticSize = Enum.AutomaticSize.Y
}, {
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
})

local Minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    ContentFrame.Visible = not Minimized
    TabContainer.Visible = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0, 600, 0, 35)
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        MinimizeBtn.Text = "—"
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

local Modules = {}
local TabButtons = {}
local FirstTab = true

local function AddTab(Name)
    local TabBtn = Create("TextButton", {
        Name = Name,
        Parent = TabContainer,
        BackgroundColor3 = FirstTab and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(14, 14, 18),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 32),
        Font = Enum.Font.Gotham,
        Text = "  " .. Name,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #TabButtons + 1
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    FirstTab = false
    
    local TabPage = Create("Frame", {
        Name = Name,
        Parent = ContentScroll,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false
    }, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, Btn in pairs(TabButtons) do
            Btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        for _, Tab in pairs(Hub.Tabs) do Tab.Visible = false end
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabPage.Visible = true
    end)
    
    table.insert(TabButtons, TabBtn)
    Hub.Tabs[Name] = TabPage
    return TabPage
end

local function MakeToggle(Parent, Text, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Create("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    Create("UIStroke", Frame).Color = Color3.fromRGB(50, 50, 65)
    
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
    Create("UICorner", Switch).CornerRadius = UDim.new(0, 10)
    
    local Circle = Instance.new("Frame", Switch)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Position = UDim2.new(0.05, 0, 0.1, 0)
    Circle.Size = UDim2.new(0.4, 0, 0.8, 0)
    Create("UICorner", Circle).CornerRadius = UDim.new(0, 10)
    
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
    Create("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Create("UIStroke", Btn).Color = Color3.fromRGB(50, 50, 65)
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
    Btn.MouseButton1Click:Connect(function() task.spawn(Callback) end)
    return Btn
end

local function MakeDropdown(Parent, Text, Default, Options, Callback)
    local Value = Default
    local Frame = Instance.new("Frame", Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.ClipsDescendants = true
    Create("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    Create("UIStroke", Frame).Color = Color3.fromRGB(50, 50, 65)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Name = "Label"
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -30, 0.5, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = Text .. ": " .. Value
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.BackgroundTransparency = 1
    Btn.Position = UDim2.new(1, -30, 0, 0)
    Btn.Size = UDim2.new(0, 30, 0, 32)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = "v"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    Btn.TextSize = 12
    
    local ClickBtn = Instance.new("TextButton", Frame)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Size = UDim2.new(1, 0, 0, 32)
    ClickBtn.Text = ""
    ClickBtn.ZIndex = 2
    
    local OptBtns = {}
    for i, Opt in ipairs(Options) do
        local OptBtn = Instance.new("TextButton", Frame)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        OptBtn.BorderSizePixel = 0
        OptBtn.Position = UDim2.new(0, 4, 0, 32 + ((i - 1) * 28))
        OptBtn.Size = UDim2.new(1, -8, 0, 26)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.Text = "  " .. Opt
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        OptBtn.TextSize = 11
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.Visible = false
        OptBtn.ZIndex = 3
        Create("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
        OptBtn.MouseButton1Click:Connect(function()
            Value = Opt
            Label.Text = Text .. ": " .. Value
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Btn.Text = "v"
            for _, B in pairs(OptBtns) do B.Visible = false end
            if Callback then Callback(Value) end
        end)
        table.insert(OptBtns, OptBtn)
    end
    
    local Open = false
    ClickBtn.MouseButton1Click:Connect(function()
        Open = not Open
        if Open then
            Frame.Size = UDim2.new(1, 0, 0, 32 + (#Options * 28))
            Btn.Text = "^"
            for _, B in pairs(OptBtns) do B.Visible = true end
        else
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Btn.Text = "v"
            for _, B in pairs(OptBtns) do B.Visible = false end
        end
    end)
    return Frame
end

local function Section(Parent, Text)
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

local function IsFruit(Model)
    if Model:IsA("Model") or Model:IsA("Part") or Model:IsA("MeshPart") then
        local Name = Model.Name:lower()
        if Name:find("fruit") or Name:find("devilfruit") then return true end
        if Model:FindFirstChild("Fruit") or Model:FindFirstChild("Eat") then return true end
    end
    return false
end

local function IsChest(Model)
    if Model:IsA("Model") or Model:IsA("Part") or Model:IsA("MeshPart") then
        local Name = Model.Name:lower()
        if Name:find("chest") or Name:find("treasure") or Name:find("box") then return true end
    end
    return false
end

local function GetLevel()
    local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if Leaderstats then
        local Level = Leaderstats:FindFirstChild("Level") or Leaderstats:FindFirstChild("Lvl")
        if Level then return Level.Value end
    end
    return 1
end

local function TweenToPos(TargetCFrame)
    local Character = LocalPlayer.Character
    if not Character then return end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    local Bf = HRP.Position - TargetCFrame.Position
    local Mag = Bf.Magnitude
    if Mag < 5 then return end
    local Speed = 300
    local Tween = TweenService:Create(HRP, TweenInfo.new(Mag / Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    Tween:Play()
    Tween.Completed:Wait()
end

local function FindNPC(Name)
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name:lower():find(Name:lower()) then
            local Humanoid = Obj:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local HRP = Obj:FindFirstChild("HumanoidRootPart")
                if HRP then return Obj, HRP end
            end
        end
    end
    return nil, nil
end

local function AttackNPC(NPC)
    local Character = LocalPlayer.Character
    if not Character then return end
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool then Character:FindFirstChildOfClass("Humanoid"):EquipTool(Tool) end
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", NPC)
    end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FarmTab = AddTab("Farming")
local FruitTab = AddTab("Fruits")
local TeleportTab = AddTab("Teleport")
local VisualsTab = AddTab("Visuals")
local RaidTab = AddTab("Raids")
local OtherTab = AddTab("Other")

local AutoFarmRunning = false
Label(FarmTab, "Auto Farm Level")
Section(FarmTab)
MakeToggle(FarmTab, "Auto Farm Level", function(V)
    AutoFarmRunning = V
    if V then
        task.spawn(function()
            while AutoFarmRunning do
                local Level = GetLevel()
                local Quest = nil
                local Quests = {
                    {L=1,N="Bandit"},{L=15,N="Monkey"},{L=30,N="Pirate"},{L=50,N="Desert"},
                    {L=75,N="Snow"},{L=100,N="Marine"},{L=150,N="Sky"},{L=225,N="Prisoner"},
                    {L=300,N="Gladiator"},{L=375,N="Magma"},{L=450,N="Fishman"},
                    {L=525,N="Ice"},{L=600,N="Pirate King"},{L=675,N="Snow Mountain"},
                    {L=750,N="Death"},{L=825,N="Cursed"},{L=900,N="Final Sea"}
                }
                for i=#Quests,1,-1 do
                    if Level >= Quests[i].L then Quest = Quests[i]; break end
                end
                if Quest then
                    local NPC, HRP = FindNPC(Quest.N)
                    if NPC and HRP then
                        TweenToPos(HRP.CFrame * CFrame.new(0,0,5))
                        local A = 0
                        while AutoFarmRunning and A < 50 do
                            local Hum = NPC:FindFirstChildOfClass("Humanoid")
                            if not Hum or Hum.Health <= 0 then break end
                            AttackNPC(NPC)
                            task.wait(0.5)
                            A = A + 1
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)
TLabel(FarmTab, "Quests: 1-900+")

local AutoMasteryRunning = false
Label(FarmTab, "Auto Mastery")
Section(FarmTab)
MakeToggle(FarmTab, "Auto Mastery", function(V)
    AutoMasteryRunning = V
    if V then
        task.spawn(function()
            while AutoMasteryRunning do
                local Level = GetLevel()
                local Target = {L=1,N="Bandit"}
                local Targets = {
                    {L=1,N="Bandit"},{L=15,N="Monkey"},{L=30,N="Pirate"},{L=50,N="Desert"},
                    {L=75,N="Snow"},{L=100,N="Marine"},{L=150,N="Sky"},{L=225,N="Prisoner"},
                    {L=300,N="Gladiator"}
                }
                for i=#Targets,1,-1 do
                    if Level >= Targets[i].L then Target = Targets[i]; break end
                end
                local NPC, HRP = FindNPC(Target.N)
                if NPC and HRP then
                    TweenToPos(HRP.CFrame * CFrame.new(0,0,5))
                    local A = 0
                    while AutoMasteryRunning and A < 50 do
                        local Hum = NPC:FindFirstChildOfClass("Humanoid")
                        if not Hum or Hum.Health <= 0 then break end
                        AttackNPC(NPC)
                        task.wait(0.4)
                        A = A + 1
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local FruitESPRunning = false
local FruitHighlights = {}
Label(FruitTab, "Fruit ESP")
Section(FruitTab)
MakeToggle(FruitTab, "Fruit ESP", function(V)
    FruitESPRunning = V
    if V then
        task.spawn(function()
            while FruitESPRunning do
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if IsFruit(Obj) and not FruitHighlights[Obj] then
                        local H = Instance.new("Highlight")
                        H.FillColor = Color3.fromRGB(255, 170, 0)
                        H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(255, 255, 0)
                        H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj
                        H.Parent = workspace
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

local FruitTweenRunning = false
Label(FruitTab, "Fruit Tween")
Section(FruitTab)
MakeToggle(FruitTab, "Tween to Fruits", function(V)
    FruitTweenRunning = V
    if V then
        task.spawn(function()
            while FruitTweenRunning do
                local Closest, MinDist = nil, math.huge
                local Char = LocalPlayer.Character
                if Char then
                    local HRP = Char:FindFirstChild("HumanoidRootPart")
                    if HRP then
                        for _, Obj in pairs(workspace:GetDescendants()) do
                            if IsFruit(Obj) then
                                local Pos = Obj:IsA("Model") and Obj.PrimaryPart and Obj.PrimaryPart.Position or Obj.Position
                                if Pos then
                                    local Dist = (HRP.Position - Pos).Magnitude
                                    if Dist < MinDist then MinDist = Dist; Closest = Obj end
                                end
                            end
                        end
                    end
                end
                if Closest then
                    local Pos = Closest:IsA("Model") and Closest.PrimaryPart and Closest.PrimaryPart.Position or Closest.Position
                    if Pos then TweenToPos(CFrame.new(Pos + Vector3.new(0, 3, 0))) end
                    task.wait(1)
                else
                    task.wait(3)
                end
            end
        end)
    end
end)

local FruitNotifyRunning = false
local NotifiedFruits = {}
Label(FruitTab, "Fruit Notifier")
Section(FruitTab)
MakeToggle(FruitTab, "Fruit Notifier", function(V)
    FruitNotifyRunning = V
    if V then
        task.spawn(function()
            while FruitNotifyRunning do
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if IsFruit(Obj) and not NotifiedFruits[Obj] then
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
    if T then TweenToPos(T) end
end)

local PlayerESPRunning = false
local PlayerHighlights = {}
Label(VisualsTab, "Player ESP")
Section(VisualsTab)
MakeToggle(VisualsTab, "Player ESP", function(V)
    PlayerESPRunning = V
    if V then
        task.spawn(function()
            for _, P in pairs(Players:GetPlayers()) do
                if P ~= LocalPlayer and not PlayerHighlights[P] then
                    local H = Instance.new("Highlight")
                    H.FillColor = Color3.fromRGB(255, 0, 0)
                    H.FillTransparency = 0.7
                    H.OutlineColor = Color3.fromRGB(255, 100, 100)
                    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    H.Parent = workspace
                    PlayerHighlights[P] = H
                end
            end
            while PlayerESPRunning do
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

local ChestESPRunning = false
local ChestHighlights = {}
Label(VisualsTab, "Chest ESP")
Section(VisualsTab)
MakeToggle(VisualsTab, "Chest ESP", function(V)
    ChestESPRunning = V
    if V then
        task.spawn(function()
            while ChestESPRunning do
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if IsChest(Obj) and not ChestHighlights[Obj] then
                        local H = Instance.new("Highlight")
                        H.FillColor = Color3.fromRGB(0, 170, 255)
                        H.FillTransparency = 0.5
                        H.OutlineColor = Color3.fromRGB(100, 200, 255)
                        H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        H.Adornee = Obj
                        H.Parent = workspace
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

local AutoRaidRunning = false
Label(RaidTab, "Auto Raid")
Section(RaidTab)
MakeToggle(RaidTab, "Auto Raid", function(V)
    AutoRaidRunning = V
    if V then
        task.spawn(function()
            while AutoRaidRunning do
                local NPC, HRP = FindNPC("Raid")
                if NPC and HRP then
                    TweenToPos(HRP.CFrame * CFrame.new(0,0,5))
                    task.wait(1)
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Raids", "Start")
                    end)
                end
                task.wait(5)
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj.Name:lower():find("raid") then
                        local Hum = Obj:FindFirstChildOfClass("Humanoid")
                        if Hum and Hum.Health > 0 then
                            local H = Obj:FindFirstChild("HumanoidRootPart")
                            if H then
                                TweenToPos(H.CFrame * CFrame.new(0,0,5))
                                local A = 0
                                while Hum.Health > 0 and A < 50 do
                                    AttackNPC(Obj)
                                    task.wait(0.3)
                                    A = A + 1
                                end
                            end
                        end
                    end
                end
                task.wait(10)
            end
        end)
    end
end)

local AutoStatsRunning = false
local SelectedStat = "Melee"
Label(OtherTab, "Auto Stats")
Section(OtherTab)
MakeDropdown(OtherTab, "Stat Preset", "Melee", {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}, function(V)
    SelectedStat = V
end)
MakeToggle(OtherTab, "Auto Stats", function(V)
    AutoStatsRunning = V
    if V then
        task.spawn(function()
            while AutoStatsRunning do
                local Points = 0
                local LS = LocalPlayer:FindFirstChild("leaderstats")
                if LS then
                    local P = LS:FindFirstChild("Points") or LS:FindFirstChild("Stats")
                    if P then Points = P.Value end
                end
                if Points > 0 then
                    for i = 1, Points do
                        pcall(function()
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", SelectedStat, 1)
                        end)
                        task.wait(0.1)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Label(OtherTab, "Server")
Section(OtherTab)
MakeButton(OtherTab, "Server Hop", function()
    local Servers = {}
    local S, R = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/994732206/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"))
    end)
    if S and R.data then Servers = R.data end
    for _, Server in pairs(Servers) do
        if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(994732206, Server.id, LocalPlayer)
            return
        end
    end
end)
MakeButton(OtherTab, "Rejoin Server", function()
    TeleportService:Teleport(994732206, LocalPlayer)
end)

Hub.Tabs["Farming"].Visible = true

getgenv().ZyrosHubUnload = function()
    AutoFarmRunning = false
    AutoMasteryRunning = false
    FruitESPRunning = false
    FruitTweenRunning = false
    FruitNotifyRunning = false
    PlayerESPRunning = false
    ChestESPRunning = false
    AutoRaidRunning = false
    AutoStatsRunning = false
    for _, H in pairs(FruitHighlights) do H:Destroy() end
    for _, H in pairs(PlayerHighlights) do H:Destroy() end
    for _, H in pairs(ChestHighlights) do H:Destroy() end
    ScreenGui:Destroy()
end
