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
