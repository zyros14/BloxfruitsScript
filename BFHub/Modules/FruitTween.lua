local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Module = {}
local Running = false

local function IsFruit(Model)
    if Model:IsA("Model") or Model:IsA("Part") or Model:IsA("MeshPart") then
        local Name = Model.Name:lower()
        if Name:find("fruit") or Name:find("devilfruit") then
            return true
        end
        if Model:FindFirstChild("Fruit") or Model:FindFirstChild("Eat") then
            return true
        end
    end
    return false
end

local function GetClosestFruit()
    local Closest = nil
    local MinDist = math.huge
    local Character = LocalPlayer.Character
    if not Character then return nil, 0 end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil, 0 end
    
    for _, Obj in pairs(workspace:GetDescendants()) do
        if IsFruit(Obj) then
            local Pos = Obj:IsA("Model") and Obj.PrimaryPart and Obj.PrimaryPart.Position or Obj.Position
            if Pos then
                local Dist = (HRP.Position - Pos).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Closest = Obj
                end
            end
        end
    end
    
    return Closest, MinDist
end

local function TweenToFruit(Target)
    local Pos = Target:IsA("Model") and Target.PrimaryPart and Target.PrimaryPart.Position or Target.Position
    if not Pos then return end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local CFrame = CFrame.new(Pos + Vector3.new(0, 3, 0))
    local Bf = HRP.Position - CFrame.Position
    local Mag = Bf.Magnitude
    if Mag < 5 then return end
    
    local Speed = 400
    local Tween = TweenService:Create(HRP, TweenInfo.new(Mag / Speed, Enum.EasingStyle.Linear), {CFrame = CFrame})
    Tween:Play()
    Tween.Completed:Wait()
end

local function TweenLoop()
    while Running do
        local Closest, Dist = GetClosestFruit()
        if Closest then
            TweenToFruit(Closest)
            task.wait(1)
        else
            task.wait(3)
        end
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
    Label.Text = "Fruit Tween"
    Label.TextColor3 = Color3.fromRGB(255, 170, 0)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Section = Instance.new("Frame", Tab)
    Section.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 6)
    
    MakeToggle(Tab, "Tween to Fruits", function(Value)
        Running = Value
        if Value then
            TweenLoop()
        end
    end)
end

function Module.Unload()
    Running = false
end

return Module
