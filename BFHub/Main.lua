local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
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
    
    Success, Result = pcall(function()
        return CoreGui
    end)
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

local function SafeHttp(Url)
    local Success, Result = pcall(function()
        if syn and syn.request then
            return syn.request({Url = Url, Method = "GET"}).Body
        elseif fluxus and fluxus.request then
            return fluxus.request({Url = Url, Method = "GET"}).Body
        elseif http_request then
            return http_request({Url = Url, Method = "GET"}).Body
        elseif request then
            return request({Url = Url, Method = "GET"}).Body
        else
            return game:HttpGet(Url)
        end
    end)
    if Success then
        return Result
    else
        warn("[ZYROS] HTTP failed: " .. tostring(Result))
        return nil
    end
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

local TabLayout = Create("UIListLayout", {
    Parent = TabContainer,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2)
})

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
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y
}, {
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
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
local function LoadModule(Name, Tab)
    local Url = "https://raw.githubusercontent.com/zyros14/BloxfruitsScript/main/Modules/" .. Name .. ".lua"
    local Result = SafeHttp(Url)
    if Result then
        local Success, Mod = pcall(function()
            return loadstring(Result)()
        end)
        if Success and Mod and Mod.Init then
            Mod.Init(Tab)
            Modules[Name] = Mod
            print("[ZYROS] Loaded: " .. Name)
        else
            warn("[ZYROS] Failed to init: " .. Name)
        end
    end
end

local TabButtons = {}
local FirstTab = true

function Hub:AddTab(Name, Icon)
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
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    FirstTab = false
    
    local TabPage = Create("Frame", {
        Name = Name,
        Parent = ContentScroll,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
    })
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, Btn in pairs(TabButtons) do
            Btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        for _, Tab in pairs(Hub.Tabs) do
            Tab.Visible = false
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabPage.Visible = true
    end)
    
    table.insert(TabButtons, TabBtn)
    Hub.Tabs[Name] = TabPage
    return TabPage
end

function Hub:Toggle()
    ScreenGui.Enabled = not ScreenGui.Enabled
end

function Hub:Destroy()
    for _, Conn in pairs(Hub.Connections) do
        if Conn.Disconnect then Conn:Disconnect() end
    end
    for _, Mod in pairs(Modules) do
        if Mod.Unload then Mod.Unload() end
    end
    ScreenGui:Destroy()
end

local FarmTab = Hub:AddTab("Farming")
local FruitTab = Hub:AddTab("Fruits")
local TeleportTab = Hub:AddTab("Teleport")
local VisualsTab = Hub:AddTab("Visuals")
local RaidTab = Hub:AddTab("Raids")
local OtherTab = Hub:AddTab("Other")

LoadModule("AutoFarm", FarmTab)
LoadModule("AutoMastery", FarmTab)
LoadModule("FruitESP", FruitTab)
LoadModule("FruitTween", FruitTab)
LoadModule("FruitNotifier", FruitTab)
LoadModule("IslandTeleport", TeleportTab)
LoadModule("AutoStats", OtherTab)
LoadModule("PlayerESP", VisualsTab)
LoadModule("ChestESP", VisualsTab)
LoadModule("AutoRaid", RaidTab)
LoadModule("ServerHop", OtherTab)

Hub.Tabs["Farming"].Visible = true

getgenv().ZyrosHubUnload = function()
    Hub:Destroy()
end
