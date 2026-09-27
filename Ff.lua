-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION V15
-- STANDARD CORE PREMIUM HUB (100% WORKING)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- ตรวจสอบและทำลาย UI เก่าอย่างปลอดภัยสูงสุด
local uiParent = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- สถิติตัวแปรหลัก (Global States) ป้องกันค่าซ้ำซ้อน
local _G = {
    AutoSteal = false,
    EggESP = false,
    PotatoMode = false,
    WalkSpeed = 16,
    BaseCFrame = nil,
    CurrentTween = nil
}

-- ==========================================
-- UI GENERATION (PREMIUM COMPACT STYLE)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggHub_UI"
screenGui.Parent = uiParent
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 330, 0, 290)
mainFrame.Position = UDim2.new(0.5, -165, 0.5, -145)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(88, 101, 242)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
titleLabel.Text = "    ⚡ STEAL AN EGG | DEFINITIVE V15"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -33, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local floatLogo = Instance.new("TextButton")
floatLogo.Size = UDim2.new(0, 46, 0, 46)
floatLogo.Position = UDim2.new(0, 15, 0.5, -23)
floatLogo.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
floatLogo.Text = "EGG"
floatLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
floatLogo.Font = Enum.Font.GothamBold
floatLogo.TextSize = 11
floatLogo.Visible = false
floatLogo.Active = true
floatLogo.Parent = screenGui
Instance.new("UICorner", floatLogo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", floatLogo).Color = Color3.fromRGB(255, 255, 255)

-- AUTOMATIC DRAG CONTROL
local function ApplyDrag(trigger, target)
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true 
            dragStart = input.Position 
            startPos = target.Position
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end 
            end)
        end
    end)
    trigger.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end 
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
ApplyDrag(titleLabel, mainFrame)
ApplyDrag(floatLogo, floatLogo)

closeBtn.Activated:Connect(function() 
    mainFrame.Visible = false 
    floatLogo.Visible = true 
end)
floatLogo.Activated:Connect(function() 
    mainFrame.Visible = true 
    floatLogo.Visible = false 
end)

-- UI BUTTON CREATOR FUNCTION (PREMIUM LOOK)
local function CreateButton(text, yPos)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 300, 0, 36)
    btn.Position = UDim2.new(0.5, -150, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(240, 80, 80)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local tglSteal = CreateButton("1. AUTO STEAL & RETURN", 52)
local tglESP = CreateButton("2. ESP SECRET EGG", 96)
local tglPotato = CreateButton("3. ULTIMATE POTATO MODE", 140)

-- SPEED PANEL COMPONENTS
local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(0, 205, 0, 36)
speedInput.Position = UDim2.new(0.5, -150, 0, 184)
speedInput.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
speedInput.Text = "16"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.ClearTextOnFocus = false
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

local btnSpeed = Instance.new("TextButton", mainFrame)
btnSpeed.Size = UDim2.new(0, 85, 0, 36)
btnSpeed.Position = UDim2.new(0.5, 65, 0, 184)
btnSpeed.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
btnSpeed.Text = "SET SPEED"
btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.TextSize = 11
Instance.new("UICorner", btnSpeed).CornerRadius = UDim.new(0, 5)

local creditLabel = Instance.new("TextLabel", mainFrame)
creditLabel.Size = UDim2.new(1, 0, 0, 25)
creditLabel.Position = UDim2.new(0, 0, 1, -25)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "STABLE ENGINE V15 • CODENAME GLOBAL"
creditLabel.TextColor3 = Color3.fromRGB(90, 95, 120)
creditLabel.Font = Enum.Font.GothamMedium
creditLabel.TextSize = 9

-- ==========================================
-- HIGH-PERFORMANCE FILTERS & SCANNER
-- ==========================================
local function IsValidEgg(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    local name = string.lower(obj.Name)
    if string.find(name, "secret") or string.find(name, "divine") or string.find(name, "mythic") or string.find(name, "egg") then
        local root = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if root and root.Transparency < 1 then
            return root
        end
    end
    return nil
end

local function FindClosestEgg()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local closest, shortestDistance = nil, math.huge
    local allObjects = workspace:GetDescendants()
    for i = 1, #allObjects do
        local rootPart = IsValidEgg(allObjects[i])
        if rootPart then
            local dist = (hrp.Position - rootPart.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closest = allObjects[i]
            end
        end
    end
    return closest, IsValidEgg(closest)
end

local function PremiumTween(targetCFrame)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if _G.CurrentTween then _G.CurrentTween:Cancel() end

    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local dur = dist / 160
    
    if dur < 0.03 then 
        hrp.CFrame = targetCFrame 
        return 
    end

    _G.CurrentTween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    _G.CurrentTween:Play()
    _G.CurrentTween.Completed:Wait()
end

-- ==========================================
-- PREMIUM POTATO MODE ENGINE (NO-LAG)
-- ==========================================
local function ClearGameGraphics()
    pcall(function()
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            local item = descendants[i]
            if item:IsA("BasePart") and not item:IsDescendantOf(player.Character) then
                if not IsValidEgg(item) and not IsValidEgg(item.Parent) then
                    item.Material = Enum.Material.SmoothPlastic
                    item.Color = Color3.fromRGB(110, 110, 110)
                    item.CastShadow = false
                    if item:IsA("MeshPart") then 
                        item.TextureID = "" 
                    end
                end
            elseif item:IsA("Texture") or item:IsA("Decal") then
                item:Destroy()
            elseif item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Sparkles") then
                item.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)
end

-- ==========================================
-- CORE FUNCTIONAL CONNECTIONS (.ACTIVATED ONLY)
-- ==========================================
tglSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    tglSteal.Text = _G.AutoSteal and "1. AUTO STEAL & RETURN [ON]" or "1. AUTO STEAL & RETURN [OFF]"
    tglSteal.BackgroundColor3 = _G.AutoSteal and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglSteal.TextColor3 = _G.AutoSteal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    
    if _G.AutoSteal then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            _G.BaseCFrame = char.HumanoidRootPart.CFrame
        end
    else
        if _G.CurrentTween then 
            _G.CurrentTween:Cancel() 
        end
    end
end)

tglESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    tglESP.Text = _G.EggESP and "2. ESP SECRET EGG [ON]" or "2. ESP SECRET EGG [OFF]"
    tglESP.BackgroundColor3 = _G.EggESP and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglESP.TextColor3 = _G.EggESP and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    
    if not _G.EggESP then
        local items = workspace:GetDescendants()
        for i = 1, #items do
            if items[i]:IsA("Highlight") and items[i].Name == "Egg_Premium_ESP" then
                items[i]:Destroy()
            end
        end
    end
end)

tglPotato.Activated:Connect(function()
    _G.PotatoMode = not _G.PotatoMode
    tglPotato.Text = _G.PotatoMode and "3. ULTIMATE POTATO MODE [ON]" or "3. ULTIMATE POTATO MODE [OFF]"
    tglPotato.BackgroundColor3 = _G.PotatoMode and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglPotato.TextColor3 = _G.PotatoMode and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    
    if _G.PotatoMode then 
        ClearGameGraphics() 
    end
end)

btnSpeed.Activated:Connect(function()
    local extractNum = tonumber(speedInput.Text:gsub("%D", ""))
    if extractNum then
        _G.WalkSpeed = extractNum
        speedInput.Text = tostring(_G.WalkSpeed)
    end
end)

-- ==========================================
-- PREMIUM INDEPENDENT BACKGROUND LOOPS
-- ==========================================

-- ลูปที่ 1: จัดการความเร็ว WalkSpeed และเคลียร์กราฟิกซ้ำ
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= _G.WalkSpeed and not _G.AutoSteal then
                hum.WalkSpeed = _G.WalkSpeed
            end
            if _G.PotatoMode then 
                ClearGameGraphics() 
            end
        end)
    end
end)

-- ลูปที่ 2: ระบบฟาร์มอัตโนมัติคุณภาพสูง (Auto Steal Premium Engine)
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.AutoSteal and _G.BaseCFrame then
            pcall(function()
                local eggModel, eggRoot = FindClosestEgg()
                if eggModel and eggRoot then
                    -- ขั้นตอนที่ 1: เคลื่อนที่ไปที่เป้าหมาย
                    PremiumTween(eggRoot.CFrame)
                    task.wait(0.08)
                    
                    -- ขั้นตอนที่ 2: จำลองการชน (Touch Interaction)
                    if firetouchinterest then
                        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            firetouchinterest(myRoot, eggRoot, 0)
                            task.wait(0.02)
                            firetouchinterest(myRoot, eggRoot, 1)
                        end
                    end
                    
                    -- ขั้นตอนที่ 3: กระตุ้นสวิตช์ปุ่มกด (Proximity Prompt)
                    local prompt = eggModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                    task.wait(0.08)
                    
                    -- ขั้นตอนที่ 4: เคลื่อนที่กลับฐานส่งของอย่างนุ่มนวล
                    PremiumTween(_G.BaseCFrame)
                end
            end)
        end
    end
end)

-- ลูปที่ 3: ระบบ ESP เคลื่อนไหวอิสระ (ไม่ดึง Frame Rate)
task.spawn(function()
    while true do
        task.wait(2.5)
        if _G.EggESP then
            pcall(function()
                local allObjects = workspace:GetDescendants()
                for i = 1, #allObjects do
                    local eggRoot = IsValidEgg(allObjects[i])
                    if eggRoot and not eggRoot:FindFirstChild("Egg_Premium_ESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "Egg_Premium_ESP"
                        highlight.FillColor = Color3.fromRGB(124, 58, 237) -- ออร่าสีม่วงพรีเมียม
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.35
                        highlight.OutlineTransparency = 0.1
                        highlight.Parent = eggRoot
                    end
                end
            end)
        end
    end
end)
