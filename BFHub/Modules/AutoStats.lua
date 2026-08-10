local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Module = {}
local Running = false

local StatPresets = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}
local SelectedPreset = "Melee"

local function GetPoints()
    local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if Leaderstats then
        local Points = Leaderstats:FindFirstChild("Points") or Leaderstats:FindFirstChild("Stats")
        if Points then return Points.Value end
    end
    return 0
end

local function AddStat(StatName, Amount)
    for i = 1, Amount do
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", StatName, 1)
        end)
        task.wait(0.1)
    end
end

local function AutoStatLoop()
    while Running do
        local Points = GetPoints()
        if Points > 0 then
            AddStat(SelectedPreset, Points)
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

local function MakeDropdown(Parent, Text, Default, Options, Callback)
    local Value = Default
    local Open = false
    
    local Frame = Instance.new("Frame", Parent)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.BorderSizePixel = 0
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(50, 50, 65)
    Stroke.Thickness = 1
    
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
    Btn.Name = "Btn"
    Btn.BackgroundTransparency = 1
    Btn.Position = UDim2.new(1, -30, 0, 0)
    Btn.Size = UDim2.new(0, 30, 0, 32)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = "v"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    Btn.TextSize = 12
    
    local ClickBtn = Instance.new("TextButton", Frame)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Position = UDim2.new(0, 0, 0, 0)
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
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
        
        OptBtn.MouseButton1Click:Connect(function()
            Value = Opt
            Label.Text = Text .. ": " .. Value
            Open = false
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Btn.Text = "v"
            for _, B in pairs(OptBtns) do B.Visible = false end
            if Callback then Callback(Value) end
        end)
        
        table.insert(OptBtns, OptBtn)
    end
    
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

function Module.Init(Tab)
    local Label = Instance.new("TextLabel", Tab)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Font = Enum.Font.GothamBold
    Label.Text = "Auto Stats"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeDropdown(Tab, "Stat Preset", SelectedPreset, StatPresets, function(Value)
        SelectedPreset = Value
    end)
    
    MakeToggle(Tab, "Auto Stats", function(Value)
        Running = Value
        if Value then
            AutoStatLoop()
        end
    end)
end

function Module.Unload()
    Running = false
end

return Module
