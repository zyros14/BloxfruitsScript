task.spawn(function()
pcall(function()
if not game:IsLoaded() then game.Loaded:Wait() end

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

local Drawing = Drawing or getgenv().Drawing
local Fonts = {UI=0, System=1, Plex=2, Monospace=3}

local C = {
    BG = Color3.fromRGB(18,18,22), Title = Color3.fromRGB(14,14,18),
    Tab = Color3.fromRGB(20,20,26), ATab = Color3.fromRGB(40,40,55),
    Cont = Color3.fromRGB(22,22,28), Elem = Color3.fromRGB(35,35,45),
    TOff = Color3.fromRGB(60,60,75), TOn = Color3.fromRGB(0,200,100),
    Text = Color3.fromRGB(220,220,230), Acc = Color3.fromRGB(255,170,0),
    Red = Color3.fromRGB(255,80,80), Wht = Color3.fromRGB(255,255,255),
    Gry = Color3.fromRGB(200,200,210),
}

local UI = {Vis=false, Pos=Vector2.new(300,150), Size=Vector2.new(450,320), Drag=false}
local Tabs = {'Farming','Fruits','Teleport','Visuals','Raids','Other'}
local CurTab = 1
local D = {}

local function AD(n, d) D[n] = d; d.Visible = false end

local AF, AM, AR, AS, FEP, FTW, FNT, PEP, CEP = false,false,false,false,false,false,false,false,false
local FarmMode, MasteryType, SelStat = 'Above', 'Melee', 'Melee'
local FH, PH, CH, NF = {},{},{},{}
local NC, FT = nil, nil

pcall(function()
    if not LP:FindFirstChild('Data') then return end
    if not LP.Data.Team or LP.Data.Team.Value == '' then
        CommF_:InvokeServer('SetTeam', 'Pirates')
    end
end)

local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHum() local c = LP.Character; return c and c:FindFirstChildOfClass('Humanoid') end
local function GetHRP() local c = LP.Character; return c and c:FindFirstChild('HumanoidRootPart') end
local function GetLvl() local d = LP:FindFirstChild('Data'); if d and d:FindFirstChild('Level') then return d.Level.Value end; return 1 end
local function IsAlive() local h = GetHum(); return h and h.Health > 0 end
local function MP() return Vector2.new(Mouse.X, Mouse.Y) end
local function InB(P, S, B) return B.X >= P.X and B.X <= P.X+S.X and B.Y >= P.Y and B.Y <= P.Y+S.Y end

local QNN = {Bandit='Bandit',Monkey='Monkey',Pirate='Pirate',['Desert Bandit']='Desert Bandit',['Snow Bandit']='Snow Bandit',Marine='Marine',['Sky Bandit']='Sky Bandit',Prisoner='Prisoner',Gladiator='Gladiator',['Magma Bandit']='Magma Bandit',Fishman='Fishman',['Ice Adventurer']='Ice Adventurer',['Pirate King']='Pirate King',['Snow Mountain']='Snow Mountain',['Death Step']='Cyborg',Cursed='Cursed',['Final Sea']='Marine'}

local function GetQNpc(N)
    local SN = QNN[N] or N
    for _, O in pairs(WS:GetDescendants()) do
        if O:IsA('Model') and O.Name == SN then
            local H = O:FindFirstChildOfClass('Humanoid')
            if H and H.Health > 0 then
                local P = O:FindFirstChild('HumanoidRootPart')
                if P then return O, P end
            end
        end
    end
    return nil, nil
end

local function FindEn(N)
    if WS:FindFirstChild('Enemies') then
        for _, v in pairs(WS.Enemies:GetChildren()) do
            if v.Name == N and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then return v end
        end
    end
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == N and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
            local P = v:FindFirstChild('HumanoidRootPart'); if P then return v end
        end
    end
    return nil
end

local function FindMS(N)
    for _, v in pairs(WS:GetChildren()) do
        if v:IsA('Model') and v.Name == N and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
            local P = v:FindFirstChild('HumanoidRootPart'); if P then return P.CFrame end
        end
    end
    return nil
end

local function EnNC()
    if NC then return end
    NC = RunService.Stepped:Connect(function()
        local c = LP.Character; if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA('BasePart') and v.CanCollide then v.CanCollide = false end
        end
    end)
end
local function DisNC() if NC then NC:Disconnect(); NC = nil end end

local function Tween(CF)
    local P = GetHRP(); if not P then return end
    local Dist = (P.Position - CF.Position).Magnitude; if Dist < 3 then return end
    FT = TS:Create(P, TweenInfo.new(Dist/300, Enum.EasingStyle.Linear), {CFrame = CF}); FT:Play()
end
local function StopT() if FT then FT:Cancel(); FT = nil end end
local function WaitT() if FT then FT.Completed:Wait(); FT = nil end end

local function EquipAny(K)
    local c = LP.Character; local B = LP:FindFirstChild('Backpack')
    if not c or not B then return nil end
    for _, v in pairs(B:GetChildren()) do
        if v:IsA('Tool') and v.Name:lower():find(K:lower()) then
            c.Humanoid:EquipTool(v); return v
        end
    end
    return nil
end

local function Attack(E)
    pcall(function() CommF_:InvokeServer('Attack', E) end)
    pcall(function() VU:CaptureController(); VU:ClickButton1(Vector2.new()) end)
end

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

local MT = {{L=1,N='Bandit'},{L=15,N='Monkey'},{L=30,N='Pirate'},{L=50,N='Desert Bandit'},{L=75,N='Snow Bandit'},{L=100,N='Marine'},{L=150,N='Sky Bandit'},{L=225,N='Prisoner'},{L=300,N='Gladiator'},{L=375,N='Magma Bandit'},{L=450,N='Fishman'},{L=525,N='Ice Adventurer'},{L=600,N='Pirate King'},{L=675,N='Snow Mountain'},{L=750,N='Cyborg'},{L=825,N='Cursed'},{L=900,N='Marine'}}
local function GetMT(Lv) for i=#MT,1,-1 do if Lv>=MT[i].L then return MT[i] end end; return MT[1] end

local Islands = {
    ['Starter Island']=CFrame.new(978,18,1500),['Jungle']=CFrame.new(-1250,18,350),
    ['Pirate Village']=CFrame.new(-1150,18,450),['Desert']=CFrame.new(1100,18,450),
    ['Frozen Village']=CFrame.new(750,18,-1200),['Marine Fortress']=CFrame.new(-4500,30,400),
    ['Skylands']=CFrame.new(-4500,200,400),['Prison']=CFrame.new(4850,18,700),
    ['Colosseum']=CFrame.new(-1300,18,-2800),['Magma Village']=CFrame.new(-5200,18,7500),
    ['Underwater']=CFrame.new(5500,18,300),['Ice Adventure']=CFrame.new(6000,18,8000),
    ['Beautiful Pirate Castle']=CFrame.new(-5000,30,-3000),['Snow Mountain2']=CFrame.new(300,400,-500),
    ['Death Step']=CFrame.new(300,18,-6000),['Cursed Ship']=CFrame.new(900,18,-11000),
    ['Final Sea']=CFrame.new(-6500,20,8500),['Sea of Treats']=CFrame.new(-1500,18,-14000),
}

local function CreateUI()
    AD('BG', Drawing.new('Square')); D.BG.Size=UI.Size; D.BG.Color=C.BG; D.BG.Filled=true
    AD('TB', Drawing.new('Square')); D.TB.Size=Vector2.new(UI.Size.X,28); D.TB.Color=C.Title; D.TB.Filled=true
    AD('TT', Drawing.new('Text')); D.TT.Text='BLOX FRUITS | ZYROS HUB'; D.TT.Color=C.Wht; D.TT.Size=13; D.TT.Font=Fonts.UI; D.TT.Outline=true
    AD('XB', Drawing.new('Text')); D.XB.Text='X'; D.XB.Color=C.Red; D.XB.Size=13; D.XB.Font=Fonts.UI; D.XB.Outline=true
    AD('MB', Drawing.new('Text')); D.MB.Text='-'; D.MB.Color=C.Gry; D.MB.Size=13; D.MB.Font=Fonts.UI; D.MB.Outline=true
    for i,T in ipairs(Tabs) do
        AD('Tab'..i, Drawing.new('Square'))
        D['Tab'..i].Color=(i==CurTab) and C.ATab or C.Tab; D['Tab'..i].Filled=true
        AD('TabT'..i, Drawing.new('Text'))
        D['TabT'..i].Text=T; D['TabT'..i].Color=C.Text; D['TabT'..i].Size=11; D['TabT'..i].Font=Fonts.UI; D['TabT'..i].Outline=true
    end
    AD('SEL', Drawing.new('Square')); D.SEL.Color=C.TOn; D.SEL.Filled=true
    AD('SELT', Drawing.new('Text')); D.SELT.Color=C.Wht; D.SELT.Size=11; D.SELT.Font=Fonts.UI; D.SELT.Outline=true
end

local function UpPos()
    local p=UI.Pos; local s=UI.Size
    D.BG.Position=p; D.TB.Position=p
    D.TT.Position=p+Vector2.new(8,6)
    D.XB.Position=p+Vector2.new(s.X-25,6)
    D.MB.Position=p+Vector2.new(s.X-45,6)
    for i,T in ipairs(Tabs) do
        D['Tab'..i].Position=p+Vector2.new(0,26+(i-1)*30)
        D['Tab'..i].Size=Vector2.new(90,26)
        D['TabT'..i].Position=p+Vector2.new(8,32+(i-1)*30)
    end
end

local function SetAllVis(V) for _,d in pairs(D) do d.Visible=V end end

CreateUI(); UpPos()

print('[ZyrosHub] Loaded! Press RightShift to open UI')

UIS.InputBegan:Connect(function(IP,GP)
    if GP then return end
    if IP.KeyCode==Enum.KeyCode.RightShift then
        UI.Vis=not UI.Vis; SetAllVis(UI.Vis); UpPos()
    end
    if IP.UserInputType==Enum.UserInputType.MouseButton1 and UI.Vis then
        local M=MP()
        for i,T in ipairs(Tabs) do
            local tp=UI.Pos+Vector2.new(0,26+(i-1)*30)
            if InB(Vector2.new(90,26),tp,M) then CurTab=i; break end
        end
        local xp=UI.Pos+Vector2.new(UI.Size.X-25,6)
        if InB(Vector2.new(20,20),xp,M) then
            AF=false;AM=false;AR=false;AS=false;FEP=false;FTW=false;FNT=false;PEP=false;CEP=false
            DisNC();StopT();UI.Vis=false;SetAllVis(false)
        end
        local mp=UI.Pos+Vector2.new(UI.Size.X-45,6)
        if InB(Vector2.new(20,20),mp,M) then UI.Vis=false;SetAllVis(false) end
    end
end)

RunService.RenderStepped:Connect(function()
    if not UI.Vis then return end
    for i,T in ipairs(Tabs) do
        D['Tab'..i].Color=(i==CurTab) and C.ATab or C.Tab
    end
end)

getgenv().ZyrosUnload=function()
    AF=false;AM=false;AR=false;AS=false;FEP=false;FTW=false;FNT=false;PEP=false;CEP=false
    DisNC();StopT()
    for _,H in pairs(FH) do pcall(function() H:Destroy() end) end
    for _,H in pairs(PH) do pcall(function() H:Destroy() end) end
    for _,H in pairs(CH) do pcall(function() H:Destroy() end) end
    UI.Vis=false;SetAllVis(false)
end

task.spawn(function()
    local function AB() pcall(function() CommF_:InvokeServer('Buso') end) end
    AB()
    LP.CharacterAdded:Connect(function() task.wait(1); AB()
        pcall(function() if not LP.Data.Team or LP.Data.Team.Value=='' then CommF_:InvokeServer('SetTeam','Pirates') end end)
    end)
end)

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if AF or AM or FTW or AR then
            pcall(function()
                local c=LP.Character; if not c then return end
                local H=c:FindFirstChildOfClass('Humanoid')
                if H then H.Sit=false end
                local BV=c:FindFirstChild('HasBuso')
                if not BV or not BV.Value then CommF_:InvokeServer('Buso') end
            end)
        end
    end)
end)

-- Auto Farm
task.spawn(function()
    while true do
        if AF and IsAlive() then
            EnNC()
            local Lvl=GetLvl()
            local Q=CQ(Lvl)
            local NPC,HRP=GetQNpc(Q.N)
            local function AcceptQuest()
                if NPC and HRP then
                    Tween(HRP.CFrame*CFrame.new(0,0,5));WaitT()
                    pcall(function() CommF_:InvokeServer('SetSpawnPoint') end)
                    pcall(function() CommF_:InvokeServer(Q.QN,Q.QI) end)
                else
                    Tween(Q.CF);WaitT()
                end
                task.wait(1.5)
            end
            local vis=false
            pcall(function()
                local M=LP:WaitForChild('PlayerGui'):FindFirstChild('Main')
                if M then local Q2=M:FindFirstChild('Quest') if Q2 then vis=Q2.Visible end end
            end)
            if not vis then
                AcceptQuest()
            else
                local E=FindEn(Q.MN)
                if E then
                    local EHRP=E:FindFirstChild('HumanoidRootPart')
                    if EHRP then
                        local Off=FarmMode=='Above' and CFrame.new(0,40,0) or FarmMode=='Behind' and CFrame.new(0,0,-5) or CFrame.new(0,-5,0)
                        local A=0
                        while AF and A<100 and IsAlive() do
                            local CE=FindEn(Q.MN)
                            if not CE then break end
                            local H=CE:FindFirstChildOfClass('Humanoid')
                            if not H or H.Health<=0 then break end
                            local CHP=CE:FindFirstChild('HumanoidRootPart')
                            if not CHP then break end
                            Tween(CHP.CFrame*Off)
                            pcall(function() H.PlatformStand=true;H.Sit=true;CHP.CanCollide=false;CHP.Size=Vector3.new(50,50,50) end)
                            Attack(CE)
                            task.wait(0.3);A=A+1
                        end
                    end
                else
                    local SF=FindMS(Q.MN)
                    if SF then Tween(SF);WaitT() end
                end
            end
        else
            DisNC()
        end
        task.wait(0.5)
    end
end)

-- Auto Mastery
task.spawn(function()
    while true do
        if AM and IsAlive() then
            EnNC()
            local Lvl=GetLvl()
            local Target=GetMT(Lvl)
            if MasteryType=='Sword' then EquipAny('Sword')
            elseif MasteryType=='Gun' then EquipAny('Gun')
            elseif MasteryType=='Blox Fruit' then EquipAny('Fruit')
            else EquipAny('Combat') or EquipAny('Melee') end
            local NPC,HRP=GetQNpc(Target.N)
            if NPC and HRP then
                Tween(HRP.CFrame*CFrame.new(0,30,0));WaitT()
                local A=0
                while AM and A<100 and IsAlive() do
                    local H=NPC:FindFirstChildOfClass('Humanoid')
                    if not H or H.Health<=0 then break end
                    Attack(NPC);task.wait(0.2);A=A+1
                end
            else
                local F=Target.N=='Bandit' and CFrame.new(978,18,1500) or CFrame.new(-1250,18,350)
                Tween(F);WaitT()
            end
        else
            DisNC()
        end
        task.wait(0.5)
    end
end)

-- Fruit ESP
task.spawn(function()
    while true do
        if FEP then
            for _,Obj in pairs(WS:GetChildren()) do
                if (Obj:IsA('Tool') or Obj:IsA('Model')) and Obj.Name:lower():find('fruit') and not FH[Obj] then
                    local H=Instance.new('Highlight')
                    H.FillColor=Color3.fromRGB(255,170,0);H.FillTransparency=0.5
                    H.OutlineColor=Color3.fromRGB(255,255,0);H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    H.Adornee=Obj;H.Parent=WS;FH[Obj]=H
                end
            end
        else
            for _,H in pairs(FH) do pcall(function() H:Destroy() end) end;FH={}
        end
        task.wait(2)
    end
end)

-- Fruit Tween
task.spawn(function()
    while true do
        if FTW and IsAlive() then
            EnNC()
            local Closest,MinDist=nil,math.huge
            local Char=LP.Character
            if Char then
                local HRP=Char:FindFirstChild('HumanoidRootPart')
                if HRP then
                    for _,Obj in pairs(WS:GetChildren()) do
                        if Obj:IsA('Tool') and Obj.Name:lower():find('fruit') then
                            local Handle=Obj:FindFirstChild('Handle')
                            if Handle then
                                local Dist=(HRP.Position-Handle.Position).Magnitude
                                if Dist<MinDist then MinDist=Dist;Closest=Handle end
                            end
                        end
                    end
                end
            end
            if Closest then Tween(CFrame.new(Closest.Position+Vector3.new(0,3,0)));WaitT();task.wait(0.5)
            else task.wait(2) end
        else
            DisNC()
        end
        task.wait(0.5)
    end
end)

-- Fruit Notifier
task.spawn(function()
    while true do
        if FNT then
            for _,Obj in pairs(WS:GetChildren()) do
                if Obj:IsA('Tool') and Obj.Name:lower():find('fruit') and not NF[Obj] then
                    NF[Obj]=true;print('[Fruit] '..Obj.Name..' spawned!')
                end
            end
        end
        task.wait(1)
    end
end)

-- Player ESP
task.spawn(function()
    while true do
        if PEP then
            for _,P in pairs(Players:GetPlayers()) do
                if P~=LP and not PH[P] then
                    local H=Instance.new('Highlight')
                    H.FillColor=Color3.fromRGB(255,0,0);H.FillTransparency=0.7
                    H.OutlineColor=Color3.fromRGB(255,100,100);H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    H.Parent=WS;PH[P]=H
                end
            end
            for P,H in pairs(PH) do
                if P and P.Character then H.Adornee=P.Character else H.Adornee=nil end
            end
        else
            for _,H in pairs(PH) do pcall(function() H:Destroy() end) end;PH={}
        end
        task.wait(0.5)
    end
end)

-- Chest ESP
task.spawn(function()
    while true do
        if CEP then
            for _,Obj in pairs(WS:GetChildren()) do
                if (Obj:IsA('Model') or Obj:IsA('Part')) and Obj.Name:lower():find('chest') and not CH[Obj] then
                    local H=Instance.new('Highlight')
                    H.FillColor=Color3.fromRGB(0,170,255);H.FillTransparency=0.5
                    H.OutlineColor=Color3.fromRGB(100,200,255);H.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    H.Adornee=Obj;H.Parent=WS;CH[Obj]=H
                end
            end
        else
            for _,H in pairs(CH) do pcall(function() H:Destroy() end) end;CH={}
        end
        task.wait(3)
    end
end)

-- Auto Raid
task.spawn(function()
    while true do
        if AR and IsAlive() then
            EnNC()
            pcall(function() CommF_:InvokeServer('Awakener','Check') end)
            pcall(function() CommF_:InvokeServer('Awakener','Awaken') end)
            task.wait(2)
            for _,Obj in pairs(WS:GetChildren()) do
                if Obj:IsA('Model') and Obj.Name:lower():find('raid') then
                    local Hum=Obj:FindFirstChildOfClass('Humanoid')
                    if Hum and Hum.Health>0 then
                        local HRP=Obj:FindFirstChild('HumanoidRootPart')
                        if HRP then
                            Tween(HRP.CFrame*CFrame.new(0,0,5));WaitT()
                            local A=0
                            while Hum.Health>0 and A<50 and AR do
                                Attack(Obj);task.wait(0.3);A=A+1
                            end
                        end
                    end
                end
            end
        else
            DisNC()
        end
        task.wait(5)
    end
end)

-- Auto Stats
task.spawn(function()
    while true do
        if AS then
            local Data=LP:FindFirstChild('Data')
            if Data and Data.Stats and Data.Stats.Points then
                local P=Data.Stats.Points.Value
                if P>0 then pcall(function() CommF_:InvokeServer('AddPoint',SelStat,P) end) end
            end
        end
        task.wait(0.5)
    end
end)

-- Server Hop
local function ServerHop()
    local PlaceId=game.PlaceId
    local Servers={}
    local Cursor=''
    for _=1,5 do
        local S,R=pcall(function()
            return HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceId..'/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true&cursor='..Cursor))
        end)
        if S and R then
            for _,Srv in pairs(R.data or {}) do
                if Srv.id and Srv.playing and Srv.maxPlayers then
                    if Srv.playing<Srv.maxPlayers and Srv.id~=game.JobId then
                        table.insert(Servers,Srv.id)
                    end
                end
            end
            if R.nextPageCursor then Cursor=R.nextPageCursor else break end
        end
        task.wait(0.5)
    end
    if #Servers>0 then
        TeleportService:TeleportToPlaceInstance(PlaceId,Servers[math.random(1,#Servers)],LP)
    end
end

end)
end)
