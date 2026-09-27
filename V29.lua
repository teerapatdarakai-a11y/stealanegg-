-- ==========================================
-- STEAL AN EGG: V32 (TOMATO FPS MODE 🍅)
-- HIGHEST PRICE TARGETING + NO LAG
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

task.wait(0.2)
local uiParent = (gethui and gethui()) or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- CONFIG SETTINGS
_G.AutoSteal = false
_G.EggESP = false
_G.TomatoMode = false
_G.NoClip = false 
_G.TargetSpeed = 1000       

local botState = "SEARCHING" 

-- ==========================================
-- ค้นหาฐาน (Base)
-- ==========================================
local function GetMyBasePosition()
    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return nil end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Folder")) then
            if not Players:GetPlayerFromCharacter(obj) then
                local nameLower = string.lower(obj.Name)
                local pNameLower = string.lower(player.Name)
                
                if string.find(nameLower, pNameLower) or string.find(obj.Name, tostring(player.UserId)) then
                    local part = obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then return part.Position end
                end
            end
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            if player.Team and obj.TeamColor == player.TeamColor then
                return obj.Position
            end
        end
    end
    return nil
end

local function IsInField(position)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            if (position - obj.Position).Magnitude < 60 then
                return false
            end
        end
    end
    return true
end

-- ==========================================
-- ค้นหาไข่ราคาสูงสุด
-- ==========================================
local function GetHighestPriceEgg()
    local bestEgg = nil
    local highestPrice = -1
    local shortestDist = math.huge
    
    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return nil end
    local hrp = player.Character.HumanoidRootPart

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parentObj = prompt.Parent
            if parentObj then
                local targetPart = parentObj:IsA("BasePart") and parentObj or parentObj:FindFirstChildWhichIsA("BasePart")
                if targetPart and IsInField(targetPart.Position) then
                    
                    local currentPrice = 0
                    
                    for _, v in ipairs(parentObj:GetDescendants()) do
                        if v:IsA("IntValue") or v:IsA("NumberValue") then
                            if v.Value > currentPrice then currentPrice = v.Value end
                        elseif v:IsA("TextLabel") then
                            local cleanText = string.gsub(v.Text, ",", "")
                            local numStr = string.match(cleanText, "%d+")
                            if numStr then
                                local num = tonumber(numStr)
                                if num and num > currentPrice then
                                    currentPrice = num
                                end
                            end
                        end
                    end
                    
                    local dist = (hrp.Position - targetPart.Position).Magnitude
                    
                    if currentPrice > highestPrice then
                        highestPrice = currentPrice
                        shortestDist = dist
                        bestEgg = targetPart
                    elseif currentPrice == highestPrice and dist < shortestDist then
                        shortestDist = dist
                        bestEgg = targetPart
                    end
                end
            end
        end
    end
    return bestEgg
end

-- ==========================================
-- UI SETUP
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggHub_UI"
screenGui.Parent = uiParent
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 360) 
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 18, 10)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "STEAL AN EGG • V32 (TOMATO 🍅)"
titleLabel.TextColor3 = Color3.fromRGB(255, 60, 60) -- เปลี่ยนสีหัวข้อให้เป็นสีแดงมะเขือเทศ
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0

local function ApplyDrag(trigger, target)
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then dragging = false end 
            end)
        end
    end)
    trigger.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end 
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
ApplyDrag(titleBar, mainFrame)

closeBtn.Activated:Connect(function() mainFrame.Visible = false end)

local function CreateButton(text, yPos)
    local container = Instance.new("Frame", mainFrame)
    container.Size = UDim2.new(0, 310, 0, 42)
    container.Position = UDim2.new(0.5, -155, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    container.BorderSizePixel = 0
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local indicator = Instance.new("Frame", container)
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -22, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    
    return btn, indicator
end

local btnSteal, indSteal = CreateButton("AUTO STEAL (SMART BRAKE)", 60)
local btnESP, indESP = CreateButton("EGG ESP", 110)
local btnTomato, indTomato = CreateButton("TOMATO MODE 🍅 (DEL ALL WALLS & COLORS)", 160)
local btnInvis, indInvis = CreateButton("NO-CLIP (SAFE WALK)", 210) 

local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(0, 180, 0, 42)
speedInput.Position = UDim2.new(0.5, -155, 0, 260)
speedInput.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
speedInput.Text = "1000" 
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12

local setSpeedBtn = Instance.new("TextButton", mainFrame)
setSpeedBtn.Size = UDim2.new(0, 120, 0, 42)
setSpeedBtn.Position = UDim2.new(0.5, 35, 0, 260)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 20) 
setSpeedBtn.Text = "SET TOP SPEED"
setSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setSpeedBtn.Font = Enum.Font.GothamBold

local function UpdateUI(state, txt, ind)
    if state then
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        ind.BackgroundColor3 = Color3.fromRGB(40, 220, 40)
    else
        txt.TextColor3 = Color3.fromRGB(150, 150, 160)
        ind.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end

-- ==========================================
-- ระบบสปีด & เบรก 4 ระดับ
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character.HumanoidRootPart
                local basePos = GetMyBasePosition()

                if basePos then
                    local dist = (hrp.Position - basePos).Magnitude
                    
                    if dist <= 20 then
                        hum.WalkSpeed = 50      
                    elseif dist <= 40 then
                        hum.WalkSpeed = 100     
                    elseif dist <= 60 then
                        hum.WalkSpeed = 300     
                    elseif dist <= 80 then
                        hum.WalkSpeed = 500     
                    else
                        hum.WalkSpeed = _G.TargetSpeed 
                    end
                else
                    hum.WalkSpeed = _G.TargetSpeed
                end
            end
        end)
    end
end)

-- NO-CLIP
RunService.Stepped:Connect(function()
    if _G.NoClip and player.Character then
        pcall(function()
            for _, v in ipairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
            end
        end)
    end
end)

-- ==========================================
-- ระบบ Auto Steal วิ่งไป-วิ่งกลับแบบล็อกเป้าหมาย 
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character.HumanoidRootPart
                local basePos = GetMyBasePosition()

                if botState == "SEARCHING" then
                    local targetEgg = GetHighestPriceEgg()
                    if targetEgg and targetEgg.Parent then
                        hum:MoveTo(targetEgg.Position)
                        
                        if (hrp.Position - targetEgg.Position).Magnitude <= 7 then
                            local prompt = targetEgg:FindFirstChildOfClass("ProximityPrompt") or targetEgg.Parent:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then 
                                fireproximityprompt(prompt) 
                                task.wait(0.3)
                                botState = "RETURNING" 
                            end
                        end
                    end
                elseif botState == "RETURNING" and basePos then
                    hum:MoveTo(basePos)
                    if (hrp.Position - basePos).Magnitude <= 15 then
                        task.wait(0.5) 
                        botState = "SEARCHING" 
                    end
                end
            end)
        end
    end
end)

-- ปุ่มต่างๆ
btnSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    botState = "SEARCHING"
    UpdateUI(_G.AutoSteal, btnSteal, indSteal)
end)

btnESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    UpdateUI(_G.EggESP, btnESP, indESP)
end)

-- ==========================================
-- โหมดมะเขือเทศ (ลบกำแพง ลบสี ลบเงา) 🍅
-- ==========================================
btnTomato.Activated:Connect(function()
    _G.TomatoMode = not _G.TomatoMode
    UpdateUI(_G.TomatoMode, btnTomato, indTomato)
    
    pcall(function()
        if _G.TomatoMode then
            -- ปิดแสงเงาทั้งหมด
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000 
            Lighting.Brightness = 1
            
            for _, v in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("BasePart") then
                        -- ทำให้ไม่มีลวดลาย
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow = false
                        
                        -- เช็กว่าเป็นไข่หรือฐานเกิดไหม (ห้ามลบเด็ดขาด)
                        local isEggOrSpawn = (v.Parent and v.Parent:FindFirstChildOfClass("ProximityPrompt")) or v:IsA("SpawnLocation")
                        
                        -- เช็กว่าเป็น "พื้น" หรือไม่ (วัดจากขนาดแกน X หรือ Z ที่ใหญ่กว่า 50 หรือชื่อตรงๆ)
                        local isFloor = (v.Size.X > 50 and v.Size.Z > 50) or string.find(string.lower(v.Name), "floor") or string.find(string.lower(v.Name), "baseplate")
                        
                        if not isEggOrSpawn and not isFloor then
                            -- ถ้าไม่ใช่พื้นและไม่ใช่ไข่ -> ทำให้ล่องหนและเดินทะลุได้ (ลบกำแพง)
                            v.Transparency = 1
                            if v.Name ~= "HumanoidRootPart" then
                                v.CanCollide = false
                            end
                        else
                            -- ถ้าเป็นพื้น หรือเป็นไข่ -> ลบสีออกให้เป็นสีเทาล้วนๆ
                            if not isEggOrSpawn then
                                v.Color = Color3.fromRGB(150, 150, 150)
                            end
                            v.Transparency = 0
                        end
                        
                    -- ลบรูปภาพ เอฟเฟกต์ และลวดลายตามพื้นออกทั้งหมด
                    elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v:Destroy()
                    end
                end)
            end
        else
            -- ถ้ากดปิด Tomato Mode ให้เปิดแสงกลับมา (พวกกำแพงต้องรอเกมโหลดใหม่ถึงจะกลับมา)
            Lighting.GlobalShadows = true
        end
    end)
end)

btnInvis.Activated:Connect(function()
    _G.NoClip = not _G.NoClip
    UpdateUI(_G.NoClip, btnInvis, indInvis)
end)

setSpeedBtn.Activated:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then _G.TargetSpeed = num end
end)
