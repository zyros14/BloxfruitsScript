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
