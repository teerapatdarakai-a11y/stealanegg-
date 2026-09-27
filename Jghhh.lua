-- ============================================================================
-- 👑 STEAL AN EGG: PRIVATE PREMIUM HUB (V46.2 CORE ENGINE RENDER)
-- ============================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local player           = Players.LocalPlayer
task.wait(0.2)

-- 🔥 ระบบค้นหา UI Parent แบบ 3 ชั้นเพื่อแก้ปัญหา UI ไม่ขึ้น (Delta, Hydrogen, Fluxus Fallback)
local uiParent = nil
if gethui then
    local success, res = pcall(gethui)
    if success and res then uiParent = res end
end

if not uiParent then
    local success, res = pcall(function() 
        return CoreGui:FindFirstChildWhichIsA("ScreenGui") and CoreGui 
    end)
    if success and res then uiParent = res end
end

if not uiParent then
    uiParent = player:WaitForChild("PlayerGui", 10)
end

-- ลบ UI เก่าที่ค้างอยู่ป้องกันสคริปต์ซ้อน
if uiParent:FindFirstChild("StealAnEggPremium_UI") then
    uiParent.StealAnEggPremium_UI:Destroy()
end

-- ============================================================================
-- ⚙️ GLOBAL STATES & STYLES
-- ============================================================================
_G.AutoSteal   = false
_G.BypassSpeed = 60
_G.AntiAFK     = true
_G.TomatoMode  = false
_G.NoClip      = false

local THEME = {
    Background = Color3.fromRGB(10, 10, 12),
    Panel      = Color3.fromRGB(15, 15, 18),
    Accent     = Color3.fromRGB(255, 190, 40),
    TextMain   = Color3.fromRGB(245, 245, 250),
    TextDark   = Color3.fromRGB(140, 140, 150),
    Green      = Color3.fromRGB(46, 204, 113),
    Red        = Color3.fromRGB(231, 76, 60),
    Purple     = Color3.fromRGB(155, 89, 182)
}

-- ============================================================================
-- 🛡️ CORE UTILITIES (SMART DETECTIONS)
-- ============================================================================
player.Idled:Connect(function()
    if _G.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local function GetMyBasePosition()
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return nil end
    
    for _, folderName in ipairs({"Bases", "Plots", "Islands", "PlayerBases"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                if string.find(string.lower(base.Name), string.lower(player.Name)) or (base:GetAttribute("Owner") == player.UserId) then
                    if base:IsA("Model") and base.PrimaryPart then 
                        return base.PrimaryPart.Position
                    elseif base:FindFirstChild("Core") then 
                        return base.Core.Position
                    elseif base:IsA("BasePart") then 
                        return base.Position 
                    end
                end
            end
        end
    end
    
    local spawnLoc = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    return spawnLoc and (spawnLoc.Position + Vector3.new(0, 3, 0)) or Vector3.new(0, 10, 0)
end

local function GetGodTierEggOnly()
    local bestEgg, highestWeight, shortestDist = nil, -1, math.huge
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return nil end
    
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Parent then
            local parentObj = prompt.Parent
            local targetPart = parentObj:IsA("BasePart") and parentObj or parentObj:FindFirstChildWhichIsA("BasePart")
            
            if targetPart and targetPart:IsDescendantOf(workspace) then
                local nameLower = string.lower(parentObj.Name)
                local parentNameLower = parentObj.Parent and string.lower(parentObj.Parent.Name) or ""
                
                if string.find(nameLower, "chest") or string.find(nameLower, "shop") or string.find(nameLower, "reward") then 
                    continue 
                end
                
                local weight = 0
                if string.find(nameLower, "eternal") or string.find(parentNameLower, "eternal") then
                    weight = 9000000
                elseif string.find(nameLower, "divine") or string.find(parentNameLower, "divine") then
                    weight = 6000000
                elseif string.find(nameLower, "secret") or string.find(parentNameLower, "secret") then
                    weight = 3000000
                end
                
                if weight == 0 then continue end
                
                local comboName = nameLower .. "_" .. parentNameLower
                if string.find(comboName, "void") or string.find(comboName, "galaxy") or string.find(comboName, "cyber") or string.find(comboName, "omega") then
                    weight = weight + 500000
                elseif string.find(comboName, "hell") or string.find(comboName, "inferno") or string.find(comboName, "magma") or string.find(comboName, "shadow") then
                    weight = weight + 300000
                elseif string.find(comboName, "crystal") or string.find(comboName, "desert") or string.find(comboName, "ocean") then
                    weight = weight + 100000
                end
                
                local dist = (char.HumanoidRootPart.Position - targetPart.Position).Magnitude
                if weight > highestWeight then
                    highestWeight = weight
                    shortestDist  = dist
                    bestEgg       = targetPart
                elseif weight == highestWeight and dist < shortestDist then
                    shortestDist  = dist
                    bestEgg       = targetPart
                end
            end
        end
    end
    return bestEgg
end

local function SafeTweenMove(targetCFrame, isReturning)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance < 4 then 
        hrp.CFrame = targetCFrame 
        return 
    end
    
    _G.NoClip = true
    
    if isReturning then
        local basePos = targetCFrame.Position
        if distance > 75 then
            local dashDistance = distance - 75
            local dashDuration = dashDistance / 1000
            local dashTarget = hrp.Position + (basePos - hrp.Position).Unit * dashDistance
            
            local tween1 = TweenService:Create(hrp, TweenInfo.new(dashDuration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(dashTarget)})
            tween1:Play()
            tween1.Completed:Wait()
        end
        
        local remainingDistance = (hrp.Position - basePos).Magnitude
        if remainingDistance > 0 then
            local brakeDuration = remainingDistance / 85
            local tween2 = TweenService:Create(hrp, TweenInfo.new(brakeDuration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            tween2:Play()
            tween2.Completed:Wait()
        end
    else
        local duration = distance / 1000
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
    
    _G.NoClip = false
end

-- ============================================================================
-- 🎨 ULTIMATE PREMIUM INTERFACE (UI) WITH ABSOLUTE VISIBILITY RESET
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggPremium_UI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999 -- ดันให้อยู่เลเยอร์หน้าสุดของจอ
screenGui.Parent = uiParent

-- หน้าต่างหลัก (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContent"
mainFrame.Size = UDim2.new(0, 380, 0, 420)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
mainFrame.BackgroundColor3 = THEME.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = THEME.Accent
mainStroke.Thickness = 1.5

-- ปุ่มโลโก้ย่อหน้าต่าง (Floating Logo Button)
local logoBtn = Instance.new("TextButton")
logoBtn.Name = "LogoToggle"
logoBtn.Size = UDim2.new(0, 50, 0, 50)
logoBtn.Position = UDim2.new(0, 20, 0, 100) -- หลบ UI ซ้ายบนของมือถือ
logoBtn.BackgroundColor3 = THEME.Panel
logoBtn.Text = "👑"
logoBtn.TextColor3 = THEME.Accent
logoBtn.Font = Enum.Font.GothamBold
logoBtn.TextSize = 24
logoBtn.Visible = false
logoBtn.BorderSizePixel = 0
logoBtn.Parent = screenGui

Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(0, 25)
local logoStroke = Instance.new("UIStroke", logoBtn)
logoStroke.Color = THEME.Accent
logoStroke.Thickness = 1.5

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = THEME.Panel
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "👑 STEAL AN EGG V46.2 • PRO HUB"
title.TextColor3 = THEME.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มกากบาท
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
closeBtn.Text = "×"
closeBtn.TextColor3 = THEME.TextMain
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", closeBtn).Color = THEME.Red

-- แอนิเมชันย่อหน้าต่าง
closeBtn.MouseButton1Click:Connect(function()
    local tweenMain = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
    tweenMain:Play()
    tweenMain.Completed:Wait()
    
    mainFrame.Visible = false
    logoBtn.Visible = true
    logoBtn.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(logoBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end)

logoBtn.MouseButton1Click:Connect(function()
    local tweenLogo = TweenService:Create(logoBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tweenLogo:Play()
    tweenLogo.Completed:Wait()
    
    logoBtn.Visible = false
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 0, 420), Position = UDim2.new(0.5, -190, 0.5, -210)}):Play()
end)

-- หน้าจอมอนิเตอร์บอกสถานะ
local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -40, 0, 30)
monitor.Position = UDim2.new(0, 20, 0, 70)
monitor.BackgroundColor3 = THEME.Panel
monitor.Text = "SYSTEM STATUS: IDLE"
monitor.TextColor3 = THEME.TextDark
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 11
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -40, 1, -160)
container.Position = UDim2.new(0, 20, 0, 115)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 2
container.CanvasSize = UDim2.new(0, 0, 0, 300)

local layout = Instance.new("UIListLayout", container)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)

-- ส่วนสร้าง Elements ปุ่มเปิด-ปิด
local function CreatePremiumToggle(name, configKey, callback)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = THEME.Panel
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = THEME.TextMain
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 50, 0, 24)
    switch.Position = UDim2.new(1, -65, 0.5, -12)
    switch.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 12)
    
    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 9)
    
    local function updateVisuals(state)
        local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and THEME.Accent or Color3.fromRGB(150, 150, 150)
        local targetBg = state and Color3.fromRGB(40, 35, 20) or Color3.fromRGB(30, 30, 35)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    end
    
    switch.MouseButton1Click:Connect(function()
        _G[configKey] = not _G[configKey]
        updateVisuals(_G[configKey])
        if callback then callback(_G[configKey]) end
    end)
    
    updateVisuals(_G[configKey])
end

local function CreatePremiumSlider(name, min, max, configKey)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundColor3 = THEME.Panel
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -100, 0, 30)
    titleLabel.Position = UDim2.new(0, 15, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = THEME.TextMain
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 80, 0, 30)
    valueLabel.Position = UDim2.new(1, -95, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(_G[configKey]) .. " Studs/s"
    valueLabel.TextColor3 = THEME.Accent
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local slideBar = Instance.new("TextButton", frame)
    slideBar.Size = UDim2.new(1, -30, 0, 6)
    slideBar.Position = UDim2.new(0, 15, 0, 42)
    slideBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    slideBar.Text = ""
    Instance.new("UICorner", slideBar).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame", slideBar)
    fill.Size = UDim2.new((_G[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local handle = Instance.new("Frame", slideBar)
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new((_G[configKey] - min) / (max - min), -7, 0.5, -7)
    handle.BackgroundColor3 = THEME.TextMain
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", handle).Color = THEME.Accent
    
    local isSliding = false
    local function updateSlider(input)
        local posX = math.clamp((input.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (posX * (max - min)))
        _G[configKey] = val
        valueLabel.Text = tostring(val) .. " Studs/s"
        fill.Size = UDim2.new(posX, 0, 1, 0)
        handle.Position = UDim2.new(posX, -7, 0.5, -7)
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isSliding = true 
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isSliding = false 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then 
            updateSlider(input) 
        end
    end)
end

CreatePremiumToggle("1. Auto Steal (Highest God)", "AutoSteal")
CreatePremiumSlider("2. Custom Speed UI (Manual Only)", 16, 1000, "BypassSpeed")
CreatePremiumToggle("3. Anti-AFK Method", "AntiAFK")
CreatePremiumToggle("4. Tomato Mode (No Lag)", "TomatoMode", function(state)
    if state then
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    else
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
    end
end)

-- ระบบลากหน้าต่างเมนู (Drag UI)
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true 
        dragStart = input.Position 
        startPos = mainFrame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then 
        dragInput = input 
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
        dragging = false 
    end
end)

-- ============================================================================
-- 🔁 MAIN EXECUTOR LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = player.Character
            if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
            
            if _G.NoClip or _G.AutoSteal then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
            end
            
            if _G.AutoSteal then
                local holdingEgg = char:FindFirstChild("Egg") or char:FindFirstChild("CarryingEgg") or player.PlayerGui:FindFirstChild("EggStealedUI")
                
                if not holdingEgg then
                    monitor.Text = "🔍 ANALYZING HIGHEST VALUED EGG..."
                    monitor.TextColor3 = THEME.Purple
                    
                    local targetEgg = GetGodTierEggOnly()
                    if targetEgg then
                        monitor.Text = "🚀 RUSH TO EGG (SPEED 1000): " .. string.upper(targetEgg.Name)
                        m
