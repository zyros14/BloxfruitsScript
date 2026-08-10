local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Module = {}
local Running = false
local ChestHighlights = {}

local function IsChest(Model)
    if Model:IsA("Model") or Model:IsA("Part") or Model:IsA("MeshPart") then
        local Name = Model.Name:lower()
        if Name:find("chest") or Name:find("treasure") or Name:find("box") then
            return true
        end
    end
    return false
end

local function AddChestESP(Model)
    if ChestHighlights[Model] then return end
    
    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = Color3.fromRGB(0, 170, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineColor = Color3.fromRGB(100, 200, 255)
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Adornee = Model
    Highlight.Parent = workspace
    
    ChestHighlights[Model] = Highlight
end

local function ChestLoop()
    while Running do
        for _, Obj in pairs(workspace:GetDescendants()) do
            if IsChest(Obj) then
                AddChestESP(Obj)
            end
        end
        task.wait(3)
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
    Label.Text = "Chest ESP"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeToggle(Tab, "Chest ESP", function(Value)
        Running = Value
        if Value then
            ChestLoop()
        else
            for Model, Highlight in pairs(ChestHighlights) do
                if Highlight then Highlight:Destroy() end
            end
            ChestHighlights = {}
        end
    end)
end

function Module.Unload()
    Running = false
    for Model, Highlight in pairs(ChestHighlights) do
        if Highlight then Highlight:Destroy() end
    end
end

return Module
