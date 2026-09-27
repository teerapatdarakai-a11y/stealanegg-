-- ==========================================
-- STEAL AN EGG: V26 ULTIMATE ACCURATE (NO KEY)
-- ACCURATE BASE DETECTION + FIXED DYNAMIC SPEED
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
_G.PotatoMode = false
_G.NoClip = false 
_G.TargetSpeed = 1000       -- สปีดตอนอยู่กลางแมพ
_G.SafeZoneSpeed = 30       -- สปีดตอนเข้าใกล้ Safe Zone / Base
_G.SafeZoneDistance = 45    -- ระยะตรวจจับเซฟโซน (Studs)

local TargetEggPool = {}

-- ฟังก์ชั่นค้นหา Base / Safe Zone ที่แม่นยำของผู้เล่น
local function GetMyBasePosition()
    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
        return nil
    end

    -- 1. ค้นหา Base ที่ระบุชื่อผู้เล่นหรือ UserId
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            if string.find(string.lower(obj.Name), string.lower(player.Name)) or string.find(obj.Name, tostring(player.UserId)) then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then return part.Position end
            end
        end
    end

    -- 2. ค้นหาจุด SpawnLocation ของผู้เล่น
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            return obj.Position
        end
    end

    return nil
end

local function IsTargetEgg(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local nameLower = string.lower(obj.Name)
    if string.find(nameLower, "secret") or string.find(nameLower, "eternal") or string.find(nameLower, "divine") then
        return true
    end

    local found = false
    pcall(function()
        for _, descendant in ipairs(obj:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("StringValue") then
                local val = string.lower(tostring(descendant.Value or descendant.Text))
                if string.find(val, "secret") or string.find(val, "eternal") or string.find(val, "divine") then
                    found = true
                    break
                end
            end
        end
    end)
    return found
end

local function AddEgg(obj)
    if IsTargetEgg(obj) and not table.find(TargetEggPool, obj) then
        table.insert(TargetEggPool, obj)
    end
end

local function RemoveEgg(obj)
    local index = table.find(TargetEggPool, obj)
    if index then table.remove(TargetEggPool, index) end
end

for _, v in ipairs(workspace:GetDescendants()) do
    task.spawn(function() AddEgg(v) end)
end
workspace.DescendantAdded:Connect(AddEgg)
workspace.DescendantRemoving:Connect(RemoveEgg)

local function GetActualPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

-- UI SETUP
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

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255, 215, 0) 
mainStroke.Thickness = 1.5

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 18, 10)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "STEAL AN EGG • V26 VERIFIED & FIXED"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
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
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0

local floatLogo = Instance.new("TextButton", screenGui)
floatLogo.Size = UDim2.new(0, 46, 0, 46)
floatLogo.Position = UDim2.new(0, 20, 0.3, 0)
floatLogo.BackgroundColor3 = Color3.fromRGB(15, 14, 10)
floatLogo.Text = "👑"
floatLogo.TextColor3 = Color3.fromRGB(255, 215, 0)
floatLogo.Font = Enum.Font.GothamBold
floatLogo.TextSize = 18
floatLogo.Visible = false
floatLogo.BorderSizePixel = 0
floatLogo.Active = true

local floatStroke = Instance.new("UIStroke", floatLogo)
floatStroke.Color = Color3.fromRGB(255, 215, 0)
floatStroke.Thickness = 1.5

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
ApplyDrag(floatLogo, floatLogo)

closeBtn.Activated:Connect(function() mainFrame.Visible = false; floatLogo.Visible = true end)
floatLogo.Activated:Connect(function() mainFrame.Visible = true; floatLogo.Visible = false end)

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
    
    local statusIndicator = Instance.new("Frame", container)
    statusIndicator.Size = UDim2.new(0, 10, 0, 10)
    statusIndicator.Position = UDim2.new(1, -22, 0.5, -5)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    statusIndicator.BorderSizePixel = 0
    
    return btn, statusIndicator
end

local btnSteal, indSteal = CreateButton("AUTO ETERNAL STEAL", 60)
local btnESP, indESP = CreateButton("ETERNAL DIVINE ESP (FULL MAP)", 110)
local btnPotato, indPotato = CreateButton("ULTIMATE POTATO MODE (FPS BOOST)", 160)
local btnInvis, indInvis = CreateButton("NO-CLIP WALLPASS (SAFE WALK)", 210) 

local speedContainer = Instance.new("Frame", mainFrame)
speedContainer.Size = UDim2.new(0, 200, 0, 42)
speedContainer.Position = UDim2.new(0.5, -155, 0, 260)
speedContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
speedContainer.BorderSizePixel = 0

local speedInput = Instance.new("TextBox", speedContainer)
speedInput.Size = UDim2.new(1, -20, 1, 0)
speedInput.Position = UDim2.new(0, 10, 0, 0)
speedInput.BackgroundTransparency = 1
speedInput.Text = "1000" 
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.ClearTextOnFocus = false

local setSpeedBtn = Instance.new("TextButton", mainFrame)
setSpeedBtn.Size = UDim2.new(0, 100, 0, 42)
setSpeedBtn.Position = UDim2.new(0.5, 55, 0, 260)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 20) 
setSpeedBtn.Text = "SET SPEED"
setSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setSpeedBtn.Font = Enum.Font.GothamBold
setSpeedBtn.TextSize = 11
setSpeedBtn.BorderSizePixel = 0

local creditsLabel = Instance.new("TextLabel", mainFrame)
creditsLabel.Size = UDim2.new(1, 0, 0, 35)
creditsLabel.Position = UDim2.new(0, 0, 1, -35)
creditsLabel.BackgroundColor3 = Color3.fromRGB(16, 15, 10)
creditsLabel.Text = "Verified No-Key | Dynamic SafeZone Speed Active"
creditsLabel.TextColor3 = Color3.fromRGB(200, 180, 100)
creditsLabel.Font = Enum.Font.GothamMedium
creditsLabel.TextSize = 10
creditsLabel.BorderSizePixel = 0

local function UpdateButtonUI(state, textLabel, indicator)
    if state then
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BackgroundColor3 = Color3.fromRGB(40, 220, 40)
        TweenService:Create(indicator.Parent, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 24, 24)}):Play()
    else
        textLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        indicator.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        TweenService:Create(indicator.Parent, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
    end
end

-- SYSTEM: ตรวจจับระยะห่าง Safe Zone และคุม WalkSpeed
RunService.RenderStepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character.HumanoidRootPart
            local basePos = GetMyBasePosition()

            if basePos then
                local dist = (hrp.Position - basePos).Magnitude
                if dist <= _G.SafeZoneDistance then
                    hum.WalkSpeed = _G.SafeZoneSpeed
                else
                    hum.WalkSpeed = _G.TargetSpeed
                end
            else
                hum.WalkSpeed = _G.TargetSpeed
            end
        end
    end)
end)

-- SYSTEM: NO-CLIP แบบปลอดภัย (ปิดการชนกำแพง แต่ไม่ตกโลก)
RunService.Stepped:Connect(function()
    if _G.NoClip and player.Character then
        pcall(function()
            for _, v in ipairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                end
            end
        end)
    end
end)

-- AUTO STEAL LOGIC
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function()
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character.HumanoidRootPart
                
                local nearestTarget = nil
                local shortestDist = math.huge

                for _, obj in ipairs(TargetEggPool) do
                    if obj and obj.Parent then
                        local part = GetActualPart(obj)
                        if part then
                            local dist = (hrp.Position - part.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                nearestTarget = part
                            end
                        end
                    end
                end

                if nearestTarget then
                    while _G.AutoSteal and nearestTarget.Parent and (hrp.Position - nearestTarget.Position).Magnitude > 4 do
                        RunService.Heartbeat:Wait()
                        humanoid:MoveTo(nearestTarget.Position)
                    end
                    pcall(function()
                        local prompt = nearestTarget:FindFirstChildOfClass("ProximityPrompt") or nearestTarget.Parent:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
end)

btnSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    UpdateButtonUI(_G.AutoSteal, btnSteal, indSteal)
end)

local espBoxes = {}
btnESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    UpdateButtonUI(_G.EggESP, btnESP, indESP)
    if not _G.EggESP then
        for _, box in ipairs(espBoxes) do pcall(function() box:Destroy() end) end
        table.clear(espBoxes)
    else
        task.spawn(function()
            while _G.EggESP do
                task.wait(1)
                for _, obj in ipairs(TargetEggPool) do
                    if obj and obj.Parent then
                        local targetPart = GetActualPart(obj)
                        if targetPart and not targetPart:FindFirstChild("EternalESP_Box") then
                            pcall(function()
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "EternalESP_Box"
                                box.Size = targetPart.Size + Vector3.new(1.2, 1.2, 1.2)
                                box.AlwaysOnTop = true
                                box.ZIndex = 10
                                box.Color3 = Color3.fromRGB(255, 215, 0)
                                box.Adornee = targetPart
                                box.Parent = targetPart
                                table.insert(espBoxes, box)
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

btnPotato.Activated:Connect(function()
    _G.PotatoMode = not _G.PotatoMode
    UpdateButtonUI(_G.PotatoMode, btnPotato, indPotato)
    pcall(function()
        if _G.PotatoMode then
            Lighting.GlobalShadows = false
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            end
        else
            Lighting.GlobalShadows = true
        end
    end)
end)

btnInvis.Activated:Connect(function()
    _G.NoClip = not _G.NoClip
    UpdateButtonUI(_G.NoClip, btnInvis, indInvis)
end)

setSpeedBtn.Activated:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then 
        _G.TargetSpeed = num 
    end
end)
