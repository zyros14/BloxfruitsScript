if not game:IsLoaded() then game.Loaded:Wait() end
local P=game:GetService('Players') local UIS=game:GetService('UserInputService') local RS=game:GetService('RunService') local TS=game:GetService('TeleportService') local HS=game:GetService('HttpService') local VU=game:GetService('VirtualUser') local TWS=game:GetService('TweenService') local LP=P.LocalPlayer if not LP then return end local R=game:GetService('ReplicatedStorage') local Rem=R:WaitForChild('Remotes') if not Rem then return end local CF=Rem:WaitForChild('CommF_') if not CF then return end local WS=game:GetService('Workspace') local S={AF=false,AM=false,AR=false,AS=false,FEP=false,FTW=false,FNT=false,PEP=false,CEP=false,FM='Above',MT='Melee',ST='Melee'} local function SI(Remote,...)local args={...}for i,v in ipairs(args)do if v==nil then return false end end local ok,res=pcall(function()return Remote:InvokeServer(...)end)return ok end local function GH()local c=LP.Character;return c and c:FindFirstChildOfClass('Humanoid')end local function GP()local c=LP.Character;return c and c:FindFirstChild('HumanoidRootPart')end local function GL()local d=LP:FindFirstChild('Data')if d and d:FindFirstChild('Level')then return d.Level.Value end;return 1 end local function IA()local h=GH()return h and h.Health>0 end local Q={{1,'Bandit','BanditQuest1',1,CFrame.new(978,18,1500),'Bandit'},{15,'Monkey','MonkeyQuest',1,CFrame.new(-1250,18,350),'Monkey'},{30,'Pirate','BuggyQuest1',1,CFrame.new(-1150,18,450),'Pirate'},{50,'Desert Bandit','DesertQuest',1,CFrame.new(1100,18,450),'Desert Bandit'},{75,'Snow Bandit','SnowQuest',1,CFrame.new(750,18,-1200),'Snow Bandit'},{100,'Marine','MarineQuest1',1,CFrame.new(-4500,30,400),'Marine'},{150,'Sky Bandit','SkyQuest',1,CFrame.new(-4500,200,400),'Sky Bandit'},{225,'Prisoner','PrisonerQuest',1,CFrame.new(4850,18,700),'Prisoner'},{300,'Gladiator','ColosseumQuest',1,CFrame.new(-1300,18,-2800),'Gladiator'},{375,'Magma Bandit','MagmaQuest',1,CFrame.new(-5200,18,7500),'Magma Bandit'},{450,'Fishman','FishmanQuest',1,CFrame.new(5500,18,300),'Fishman'},{525,'Ice Adventurer','IceQuest',1,CFrame.new(6000,18,8000),'Ice Adventurer'},{600,'Pirate King','PirateKingQuest',1,CFrame.new(-5000,30,-3000),'Pirate King'},{675,'Snow Mountain','SkyQuest2',2,CFrame.new(300,400,-500),'Snow Mountain'},{750,'Death Step','FountainQuest',2,CFrame.new(300,18,-6000),'Cyborg'},{825,'Cursed','CursedShipQuest',1,CFrame.new(900,18,-11000),'Cursed'},{900,'Final Sea','MarineQuest3',1,CFrame.new(-6500,20,8500),'Marine'}}local function CQ(Lv)for i=#Q,1,-1 do if Lv>=Q[i].1 then return Q[i]end end;return Q[1]end local NC=nil local function EnNC()if NC then return end;NC=RS.Stepped:Connect(function()pcall(function()local c=LP.Character;if not c then return end;for _,v in pairs(c:GetDescendants())do if v:IsA('BasePart')and v.CanCollide then v.CanCollide=false end end end)end)end local function DisNC()if NC then pcall(function()NC:Disconnect()end);NC=nil end end local FT=nil local function Tween(CF)StopT()local P=GP()if not P then return end;local D=(P.Position-CF.Position).Magnitude;if D<3 then return end;local ok,tween=pcall(function()return TWS:Create(P,TweenInfo.new(D/250,Enum.EasingStyle.Linear),{CFrame=CF})end)if ok and tween then FT=tween;tween:Play()end end local function StopT()if FT then pcall(function()FT:Cancel()end);FT=nil end end local function WaitT()if FT then pcall(function()FT.Completed:Wait()end);FT=nil end end local function Equip(K)local c=LP.Character;local B=LP:FindFirstChild('Backpack')if not c or not B then return nil end;for _,v in pairs(c:GetChildren())do if v:IsA('Tool')and v.Name:lower():find(K:lower())then return v end end;for _,v in pairs(B:GetChildren())do if v:IsA('Tool')and v.Name:lower():find(K:lower())then pcall(function()c.Humanoid:EquipTool(v)end);return v end end;return nil end local function Attack(T)if not T then return end;local TP=T:FindFirstChild('HumanoidRootPart')or T:FindFirstChildWhichIsA('BasePart')if not TP then return end;SI(CF,'Attack',TP)pcall(function()VU:CaptureController();VU:ClickButton1(Vector2.new())end)end local function FindE(N)pcall(function()local EF=WS:FindFirstChild('Enemies')if EF then for _,v in pairs(EF:GetChildren())do if v.Name==N and v:FindFirstChild('Humanoid')and v.Humanoid.Health>0 then local P=v:FindFirstChild('HumanoidRootPart')if P then return v end end end end end)for _,v in pairs(WS:GetChildren())do if v:IsA('Model')and v.Name==N then local H=v:FindFirstChildOfClass('Humanoid')if H and H.Health>0 then local P=v:FindFirstChild('HumanoidRootPart')if P then return v end end end end;return nil end local function FindMS(N)for _,v in pairs(WS:GetChildren())do if v:IsA('Model')and v.Name==N then local H=v:FindFirstChildOfClass('Humanoid')if H and H.Health>0 then local P=v:FindFirstChild('HumanoidRootPart')if P then return P.CFrame end end end end;return nil end local function GetQN(N)for _,O in pairs(WS:GetDescendants())do if O:IsA('Model')and O.Name==N then local H=O:FindFirstChildOfClass('Humanoid')if H and H.Health>0 then local P=O:FindFirstChild('HumanoidRootPart')if P then return O,P end end end end;return nil,nil end local function IQV()local ok,result=pcall(function()local M=LP:WaitForChild('PlayerGui'):FindFirstChild('Main')if not M then return false end;local Q=M:FindFirstChild('Quest')if not Q then return false end;return Q.Visible end)return ok and result or false end
local Drawing = Drawing or getgenv().Drawing
local Fonts = {UI=0, System=1, Plex=2, Monospace=3}
local C = {
    BG = Color3.fromRGB(16,16,20), Title = Color3.fromRGB(12,12,16),
    Tab = Color3.fromRGB(24,24,30), ATab = Color3.fromRGB(50,50,65),
    Elem = Color3.fromRGB(32,32,42), TOff = Color3.fromRGB(60,60,75),
    TOn = Color3.fromRGB(0,200,100), Text = Color3.fromRGB(220,220,230),
    Acc = Color3.fromRGB(255,170,0), Red = Color3.fromRGB(255,80,80),
    Wht = Color3.fromRGB(255,255,255), Gry = Color3.fromRGB(180,180,190),
}
local UI = {Vis=false, Pos=Vector2.new(250,120), Size=Vector2.new(420,340), Drag=false}
local Tabs = {'Farm','Fruits','Visuals','Raids','Other'}
local CurTab = 1
local D = {}
local function AD(n, d) D[n] = d; d.Visible = false end
local function MP() return Vector2.new(LP:GetMouse().X, LP:GetMouse().Y) end
local function InB(P, S, B) return B.X >= P.X and B.X <= P.X+S.X and B.Y >= P.Y and B.Y <= P.Y+S.Y end
local function SafeSet(obj, prop, val) pcall(function() obj[prop] = val end) end

local function CreateUI()
    AD('BG', Drawing.new('Square')); SafeSet(D.BG, 'Size', UI.Size); SafeSet(D.BG, 'Color', C.BG); SafeSet(D.BG, 'Filled', true)
    AD('TB', Drawing.new('Square')); SafeSet(D.TB, 'Size', Vector2.new(UI.Size.X, 28)); SafeSet(D.TB, 'Color', C.Title); SafeSet(D.TB, 'Filled', true)
    AD('TT', Drawing.new('Text')); SafeSet(D.TT, 'Text', 'BLOX FRUITS | ZYROS HUB'); SafeSet(D.TT, 'Color', C.Wht); SafeSet(D.TT, 'Size', 13); SafeSet(D.TT, 'Font', Fonts.UI); SafeSet(D.TT, 'Outline', true)
    AD('XB', Drawing.new('Text')); SafeSet(D.XB, 'Text', 'X'); SafeSet(D.XB, 'Color', C.Red); SafeSet(D.XB, 'Size', 13); SafeSet(D.XB, 'Font', Fonts.UI); SafeSet(D.XB, 'Outline', true)
    AD('MB', Drawing.new('Text')); SafeSet(D.MB, 'Text', '-'); SafeSet(D.MB, 'Color', C.Gry); SafeSet(D.MB, 'Size', 13); SafeSet(D.MB, 'Font', Fonts.UI); SafeSet(D.MB, 'Outline', true)
    for i, T in ipairs(Tabs) do
        AD('TabBG'..i, Drawing.new('Square')); SafeSet(D['TabBG'..i], 'Filled', true)
        AD('TabT'..i, Drawing.new('Text')); SafeSet(D['TabT'..i], 'Text', T); SafeSet(D['TabT'..i], 'Color', C.Text); SafeSet(D['TabT'..i], 'Size', 11); SafeSet(D['TabT'..i], 'Font', Fonts.UI); SafeSet(D['TabT'..i], 'Outline', true)
    end
    AD('SEL', Drawing.new('Square')); SafeSet(D.SEL, 'Color', C.TOn); SafeSet(D.SEL, 'Filled', true)
    AD('SELT', Drawing.new('Text')); SafeSet(D.SELT, 'Color', C.Wht); SafeSet(D.SELT, 'Size', 11); SafeSet(D.SELT, 'Font', Fonts.UI); SafeSet(D.SELT, 'Outline', true)
end

local function UpdatePositions()
    local p = UI.Pos; local s = UI.Size
    SafeSet(D.BG, 'Position', p)
    SafeSet(D.TB, 'Position', p)
    SafeSet(D.TT, 'Position', p + Vector2.new(8, 6))
    SafeSet(D.XB, 'Position', p + Vector2.new(s.X-25, 6))
    SafeSet(D.MB, 'Position', p + Vector2.new(s.X-45, 6))
    for i, T in ipairs(Tabs) do
        local ty = 28 + (i-1) * 30
        SafeSet(D['TabBG'..i], 'Position', p + Vector2.new(0, ty))
        SafeSet(D['TabBG'..i], 'Size', Vector2.new(92, 26))
        SafeSet(D['TabT'..i], 'Position', p + Vector2.new(8, ty+5))
    end
end

local function SetAllVisible(V)
    for _, d in pairs(D) do SafeSet(d, 'Visible', V) end
end

local function UpdateTabColors()
    for i, T in ipairs(Tabs) do
        SafeSet(D['TabBG'..i], 'Color', (i == CurTab) and C.ATab or C.Tab)
    end
end

local ContentElements = {}

local function BuildContent()
    ContentElements = {}
    local baseX = 100; local baseY = 32
    if CurTab == 1 then
        table.insert(ContentElements, {name='AF', x=baseX, y=baseY, w=180, h=24, type='toggle', action=function() S.AF = not S.AF end})
        table.insert(ContentElements, {name='AM', x=baseX, y=baseY+30, w=180, h=24, type='toggle', action=function() S.AM = not S.AM end})
        table.insert(ContentElements, {name='FM', x=baseX, y=baseY+60, w=180, h=24, type='dropdown', action=function() local modes={'Above','Behind','Below'} local idx=table.find(modes,S.FM) or 1 S.FM=modes[(idx%#modes)+1] end})
        table.insert(ContentElements, {name='MT', x=baseX, y=baseY+90, w=180, h=24, type='dropdown', action=function() local types={'Melee','Sword','Gun','Blox Fruit'} local idx=table.find(types,S.MT) or 1 S.MT=types[(idx%#types)+1] end})
    elseif CurTab == 2 then
        table.insert(ContentElements, {name='FEP', x=baseX, y=baseY, w=180, h=24, type='toggle', action=function() S.FEP = not S.FEP end})
        table.insert(ContentElements, {name='FTW', x=baseX, y=baseY+30, w=180, h=24, type='toggle', action=function() S.FTW = not S.FTW end})
        table.insert(ContentElements, {name='FNT', x=baseX, y=baseY+60, w=180, h=24, type='toggle', action=function() S.FNT = not S.FNT end})
    elseif CurTab == 3 then
        table.insert(ContentElements, {name='PEP', x=baseX, y=baseY, w=180, h=24, type='toggle', action=function() S.PEP = not S.PEP end})
        table.insert(ContentElements, {name='CEP', x=baseX, y=baseY+30, w=180, h=24, type='toggle', action=function() S.CEP = not S.CEP end})
    elseif CurTab == 4 then
        table.insert(ContentElements, {name='AR', x=baseX, y=baseY, w=180, h=24, type='toggle', action=function() S.AR = not S.AR end})
    elseif CurTab == 5 then
        table.insert(ContentElements, {name='AS', x=baseX, y=baseY, w=180, h=24, type='toggle', action=function() S.AS = not S.AS end})
        table.insert(ContentElements, {name='HOP', x=baseX, y=baseY+30, w=180, h=24, type='button', action=function() local PI=game.PlaceId local Sv={} local URL='https://games.roblox.com/v1/games/'..PI..'/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true' local S2,R2=pcall(function()return HS:JSONDecode(game:HttpGet(URL))end) if S2 and R2 and R2.data then for _,Srv in pairs(R2.data)do if Srv.id and Srv.playing and Srv.maxPlayers then if Srv.playing<Srv.maxPlayers and Srv.id~=game.JobId then table.insert(Sv,Srv.id)end end end end if #Sv>0 then TS:TeleportToPlaceInstance(PI,Sv[math.random(1,#Sv)],LP)end end, label='Server Hop'})
        table.insert(ContentElements, {name='REJ', x=baseX, y=baseY+60, w=180, h=24, type='button', action=function() TS:Teleport(994732206,LP)end, label='Rejoin'})
    end
end

local function DrawContent()
    for k, v in pairs(D) do if k:sub(1,3) == 'CEL' then pcall(function() v:Remove() end); D[k] = nil end end
    for i, elem in ipairs(ContentElements) do
        local px = UI.Pos.X + elem.x; local py = UI.Pos.Y + elem.y
        local bgName = 'CEL_BG_'..i
        AD(bgName, Drawing.new('Square'))
        SafeSet(D[bgName], 'Position', Vector2.new(px, py))
        SafeSet(D[bgName], 'Size', Vector2.new(elem.w, elem.h))
        SafeSet(D[bgName], 'Filled', true)
        local bgColor = C.Elem; local textColor = C.Text; local label = elem.name
        if elem.type == 'toggle' then
            local isOn = false
            if elem.name == 'AF' then isOn = S.AF
            elseif elem.name == 'AM' then isOn = S.AM
            elseif elem.name == 'FEP' then isOn = S.FEP
            elseif elem.name == 'FTW' then isOn = S.FTW
            elseif elem.name == 'FNT' then isOn = S.FNT
            elseif elem.name == 'PEP' then isOn = S.PEP
            elseif elem.name == 'CEP' then isOn = S.CEP
            elseif elem.name == 'AR' then isOn = S.AR
            elseif elem.name == 'AS' then isOn = S.AS
            end
            bgColor = isOn and C.TOn or C.TOff; textColor = C.Wht
            local onOff = isOn and 'ON' or 'OFF'
            label = string.format('%-8s [%s]', elem.name, onOff)
        elseif elem.type == 'dropdown' then
            local val = ''
            if elem.name == 'FM' then val = S.FM
            elseif elem.name == 'MT' then val = S.MT
            end
            label = string.format('%s: %s', elem.name, val)
        elseif elem.type == 'button' then
            bgColor = C.Acc; textColor = C.Wht
            label = elem.label or elem.name
        end
        SafeSet(D[bgName], 'Color', bgColor)
        local txtName = 'CEL_TXT_'..i
        AD(txtName, Drawing.new('Text'))
        SafeSet(D[txtName], 'Position', Vector2.new(px+6, py+4))
        SafeSet(D[txtName], 'Text', label)
        SafeSet(D[txtName], 'Color', textColor)
        SafeSet(D[txtName], 'Size', 11)
        SafeSet(D[txtName], 'Font', Fonts.UI)
        SafeSet(D[txtName], 'Outline', true)
    end
end

CreateUI()
UpdatePositions()
SetAllVisible(false)
BuildContent()
DrawContent()

UIS.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.RightShift then
        UI.Vis = not UI.Vis
        if UI.Vis then SetAllVisible(true); UpdatePositions(); UpdateTabColors(); BuildContent(); DrawContent()
        else SetAllVisible(false) end
        return
    end
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and UI.Vis then
        local M = MP()
        for i, T in ipairs(Tabs) do
            local tp = UI.Pos + Vector2.new(0, 28 + (i-1)*30)
            if InB(Vector2.new(92, 26), tp, M) then CurTab = i; UpdateTabColors(); BuildContent(); DrawContent(); return end
        end
        local xp = UI.Pos + Vector2.new(UI.Size.X-25, 6)
        if InB(Vector2.new(20, 20), xp, M) then S.AF=false;S.AM=false;S.AR=false;S.AS=false;S.FEP=false;S.FTW=false;S.FNT=false;S.PEP=false;S.CEP=false;DisNC();StopT();UI.Vis=false;SetAllVisible(false); return end
        local mp = UI.Pos + Vector2.new(UI.Size.X-45, 6)
        if InB(Vector2.new(20, 20), mp, M) then UI.Vis=false;SetAllVisible(false); return end
        for i, elem in ipairs(ContentElements) do
            local ex = UI.Pos.X + elem.x; local ey = UI.Pos.Y + elem.y
            if InB(Vector2.new(elem.w, elem.h), Vector2.new(ex, ey), M) then pcall(elem.action); task.wait(0.05); DrawContent(); return end
        end
    end
end)

RS.RenderStepped:Connect(function()
    if UI.Vis then UpdateTabColors() end
end)

task.spawn(function()
    while true do
        if S.AF or S.AM or S.FTW or S.AR then
            pcall(function()
                local c=LP.Character; if not c then return end
                local H=c:FindFirstChildOfClass('Humanoid')
                if H then H.Sit=false end
                local BV=c:FindFirstChild('HasBuso')
                if not BV or not BV.Value then SI(CF,'Buso') end
            end)
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if S.AF and IA() then
                EnNC()
                local Lv=GL()
                local Q2=CQ(Lv)
                local NPC,NP=GetQN(Q2[2])
                if not IQV() then
                    if NPC and NP then
                        Tween(NP.CFrame*CFrame.new(0,0,5))
                        WaitT()
                        SI(CF,'SetSpawnPoint')
                        SI(CF,Q2[3],Q2[4])
                    else
                        Tween(Q2[5])
                        WaitT()
                    end
                    task.wait(1.5)
                else
                    local E=FindE(Q2[6])
                    if E then
                        local EHRP=E:FindFirstChild('HumanoidRootPart')
                        if EHRP then
                            local Off=S.FM=='Above' and CFrame.new(0,40,0) or S.FM=='Behind' and CFrame.new(0,0,-5) or CFrame.new(0,-5,0)
                            local A=0
                            while S.AF and A<100 and IA() do
                                local CE=FindE(Q2[6])
                                if not CE then break end
                                local H=CE:FindFirstChildOfClass('Humanoid')
                                if not H or H.Health<=0 then break end
                                local CHP=CE:FindFirstChild('HumanoidRootPart')
                                if not CHP then break end
                                Tween(CHP.CFrame*Off)
                                pcall(function()
                                    H.PlatformStand=true
                                    H.Sit=true
                                    CHP.CanCollide=false
                                end)
                                Attack(CE)
                                task.wait(0.3)
                                A=A+1
                            end
                        end
                    else
                        local SF=FindMS(Q2[6])
                        if SF then Tween(SF) WaitT() end
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

task.spawn(function()
    while true do
        pcall(function()
            if S.AM and IA() then
                EnNC()
                local Lv=GL()
                local T=Q[1]
                for i=#Q,1,-1 do if Lv>=Q[i].1 then T=Q[i]; break end end
                if S.MT=='Sword' then Equip('Sword')
                elseif S.MT=='Gun' then Equip('Gun')
                elseif S.MT=='Blox Fruit' then Equip('Fruit')
                else Equip('Combat') or Equip('Melee') end
                local NPC,HRP=GetQN(T[2])
                if NPC and HRP then
                    Tween(HRP.CFrame*CFrame.new(0,30,0))
                    WaitT()
                    local A=0
                    while S.AM and A<100 and IA() do
                        local H=NPC:FindFirstChildOfClass('Humanoid')
                        if not H or H.Health<=0 then break end
                        Attack(NPC)
                        task.wait(0.2)
                        A=A+1
                    end
                else
                    local F=T[2]=='Bandit' and CFrame.new(978,18,1500) or CFrame.new(-1250,18,350)
                    Tween(F)
                    WaitT()
                end
            else
                DisNC()
            end
        end)
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if S.FTW and IA() then
                EnNC()
                local C2,MD=nil,math.huge
                local Ch=LP.Character
                if Ch then
                    local HRP=Ch:FindFirstChild('HumanoidRootPart')
                    if HRP then
                        for _,O in pairs(WS:GetChildren()) do
                            if O:IsA('Tool') and O.Name:lower():find('fruit') then
                                local H=O:FindFirstChild('Handle')
                                if H then
                                    local D=(HRP.Position-H.Position).Magnitude
                                    if D<MD then MD=D; C2=H end
                                end
                            end
                        end
                    end
                end
                if C2 then Tween(CFrame.new(C2.Position+Vector3.new(0,3,0))) WaitT() task.wait(0.5)
                else task.wait(2) end
            else DisNC() end
        end)
        task.wait(0.5)
    end
end)

task.spawn(function()
    local N={}
    while true do
        pcall(function()
            if S.FNT then
                for _,O in pairs(WS:GetChildren()) do
                    if O:IsA('Tool') and O.Name:lower():find('fruit') and not N[O] then
                        N[O]=true
                        print('[Fruit] '..O.Name..' spawned!')
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if S.AR and IA() then
                EnNC()
                SI(CF,'Awakener','Check')
                SI(CF,'Awakener','Awaken')
                task.wait(2)
                for _,O in pairs(WS:GetChildren()) do
                    if O:IsA('Model') and O.Name:lower():find('raid') then
                        local H=O:FindFirstChildOfClass('Humanoid')
                        if H and H.Health>0 then
                            local HRP=O:FindFirstChild('HumanoidRootPart')
                            if HRP then
                                Tween(HRP.CFrame*CFrame.new(0,0,5))
                                WaitT()
                                local A=0
                                while H.Health>0 and A<50 and S.AR do
                                    Attack(O)
                                    task.wait(0.3)
                                    A=A+1
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

task.spawn(function()
    while true do
        pcall(function()
            if S.AS then
                local D=LP:FindFirstChild('Data')
                if D and D.Stats and D.Stats.Points then
                    local P=D.Stats.Points.Value
                    if P>0 then SI(CF,'AddPoint',S.ST,1) end
                end
            end
        end)
        task.wait(0.5)
    end
end)

pcall(function() SI(CF,'Buso') end)
