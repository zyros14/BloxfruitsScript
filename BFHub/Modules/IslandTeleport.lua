local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Module = {}

local Islands = {
    ["Starter Island"] = CFrame.new(978, 18, 1500),
    ["Jungle"] = CFrame.new(-1250, 18, 350),
    ["Pirate Village"] = CFrame.new(-1150, 18, 450),
    ["Desert"] = CFrame.new(1100, 18, 450),
    ["Frozen Village"] = CFrame.new(750, 18, -1200),
    ["Marine Fortress"] = CFrame.new(-4500, 30, 400),
    ["Skylands"] = CFrame.new(-4500, 200, 400),
    ["Prison"] = CFrame.new(4850, 18, 700),
    ["Colosseum"] = CFrame.new(-1300, 18, -2800),
    ["Magma Village"] = CFrame.new(-5200, 18, 7500),
    ["Underwater"] = CFrame.new(5500, 18, 300),
    ["Ice Adventure"] = CFrame.new(6000, 18, 8000),
    ["Beautiful Pirate Castle"] = CFrame.new(-5000, 30, -3000),
    ["Snow Mountain"] = CFrame.new(300, 400, -500),
    ["Death Step"] = CFrame.new(300, 18, -6000),
    ["Cursed Ship"] = CFrame.new(900, 18, -11000),
    ["Final Sea"] = CFrame.new(-6500, 20, 8500),
    ["Sea of Treats"] = CFrame.new(-1500, 18, -14000),
}

local IslandOrder = {
    "Starter Island", "Jungle", "Pirate Village", "Desert", "Frozen Village",
    "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village",
    "Underwater", "Ice Adventure", "Beautiful Pirate Castle", "Snow Mountain",
    "Death Step", "Cursed Ship", "Final Sea", "Sea of Treats"
}

local function TweenToPos(TargetCFrame)
    local Character = LocalPlayer.Character
    if not Character then return end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local Bf = HRP.Position - TargetCFrame.Position
    local Mag = Bf.Magnitude
    if Mag < 5 then return end
    
    local Speed = 350
    local Tween = TweenService:Create(HRP, TweenInfo.new(Mag / Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    Tween:Play()
    Tween.Completed:Wait()
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
    Label.Text = "Island Teleport"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeDropdown(Tab, "Select Island", IslandOrder[1], IslandOrder, function(Value)
        local Target = Islands[Value]
        if Target then
            TweenToPos(Target)
        end
    end)
end

function Module.Unload()

end

return Module
