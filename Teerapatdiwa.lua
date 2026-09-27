-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION V22.2
-- CACHE SCANNER + CUSTOM KEY SYSTEM + TACTICAL RED
-- ==========================================

-- 🔑 [ตั้งค่ารหัสผ่านของคุณเองตรงนี้]
local MY_CUSTOM_KEY = "Teerapat" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager") 
local player = Players.LocalPlayer

task.wait(0.2)
local uiParent = (gethui and gethui()) or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- ==========================================
-- KEY SYSTEM UI (หน้าต่างใส่รหัสผ่าน)
-- ==========================================
local keyScreenGui = Instance.new("ScreenGui")
keyScreenGui.Name = "StealAnEggHub_UI"
keyScreenGui.Parent = uiParent
keyScreenGui.IgnoreGuiInset = true

local keyFrame = Instance.new("Frame", keyScreenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 160)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
keyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
keyFrame.BorderSizePixel = 0
keyFrame.Active = true

local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = Color3.fromRGB(255, 30, 30)
keyStroke.Thickness = 1.5

local keyTitle = Instance.new("TextLabel", keyFrame)
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "SYSTEM AUTHENTICATION"
keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 12

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0, 260, 0, 38)
keyBox.Position = UDim2.new(0.5, -130, 0, 50)
keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderText = "Enter your custom key here..."
keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
keyBox.Font = Enum.Font.GothamMedium
keyBox.TextSize = 11
keyBox.BorderSizePixel = 0
keyBox.ClearTextOnFocus = false

local submitBtn = Instance.new("TextButton", keyFrame)
submitBtn.Size = UDim2.new(0, 260, 0, 35)
submitBtn.Position = UDim2.new(0.5, -130, 0, 105)
submitBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
submitBtn.Text = "UNLOCK HUB"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 11
submitBtn.BorderSizePixel = 0

-- ฟังก์ชันเปิดหน้าต่างหลักเมื่อใส่ Key ถูกต้อง
local function LoadMainHub()
    keyScreenGui:Destroy()

    -- สถิติตัวแปรหลัก (Global States)
    _G.AutoSteal = false
    _G.EggESP = false
    _G.PotatoMode = false
    _G.NoClip = false 
    _G.WalkSpeed = 65 
    _G.BaseCFrame = nil

    local PremiumEggPool = {}
    local IgnoreKeywords = {
        "machine", "fuse", "shop", "button", "buy", "npc", "zone", "gate", 
        "teleport", "pad", "leaderboard", "display", "eggop", "egg_op", "fusing"
    }

    local function IsPremiumEgg(obj)
        if not obj:IsA("BasePart") or obj.Transparency >= 1 then return false end
        local nameLower = string.lower(obj.Name)
        for _, keyword in ipairs(IgnoreKeywords) do
            if string.find(nameLower, keyword) then return false end
        end
        if obj.Size.X > 8 or obj.Size.Y > 8 or obj.Size.Z > 8 then return false end
        
        if string.find(nameLower, "egg") and (string.find(nameLower, "secret") or string.find(nameLower, "divine") or string.find(nameLower, "cosmic") or string.find(nameLower, "eternal") or string.find(nameLower, "gargoyle")) then
            return true
        end
        
        local isTarget = false
        pcall(function()
            if string.find(nameLower, "egg") then
                for _, child in ipairs(obj.Parent:GetDescendants()) do
                    if child:IsA("StringValue") and (string.find(string.lower(child.Value), "secret") or string.find(string.lower(child.Value), "divine")) then
                        isTarget = true
                        break
                    end
                end
                for attrName, attrValue in pairs(obj.Parent:GetAttributes()) do
                    if string.find(string.lower(tostring(attrValue)), "secret") or string.find(string.lower(tostring(attrValue)), "divine") then
                        isTarget = true
                        break
                    end
                end
            end
        end)
        return isTarget
    end

    local function AddEggToPool(obj)
        if IsPremiumEgg(obj) and not table.find(PremiumEggPool, obj) then
            table.insert(PremiumEggPool, obj)
        end
    end

    local function RemoveEggFromPool(obj)
        local index = table.find(PremiumEggPool, obj)
        if index then
            table.remove(PremiumEggPool, index)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        task.spawn(AddEggToPool, obj)
    end

    workspace.DescendantAdded:Connect(AddEggToPool)
    workspace.DescendantRemoving:Connect(RemoveEggFromPool)

    local function InteractWithEgg(eggObj)
        pcall(function()
            local prompt = eggObj:FindFirstChildOfClass("ProximityPrompt") or eggObj.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt:InputHoldBegin()
                task.wait(3.5)
                prompt:InputHoldEnd()
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(3.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
    end

    -- SHARP TACTICAL RED UI GENERATION
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
    mainStroke.Color = Color3.fromRGB(255, 30, 30) 
    mainStroke.Thickness = 1.5

    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 14, 14)
    titleBar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "STEAL AN EGG • V22.2 CUSTOM KEY"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    floatLogo.BackgroundColor3 = Color3.fromRGB(15, 12, 12)
    floatLogo.Text = "⚡"
    floatLogo.TextColor3 = Color3.fromRGB(255, 40, 40)
    floatLogo.Font = Enum.Font.GothamBold
    floatLogo.TextSize = 18
    floatLogo.Visible = false
    floatLogo.BorderSizePixel = 0
    floatLogo.Active = true

    local floatStroke = Instance.new("UIStroke", floatLogo)
    floatStroke.Color = Color3.fromRGB(255, 40, 40)
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

    local btnSteal, indSteal = CreateButton("ADAPTIVE CACHE AUTO STEAL", 60)
    local btnESP, indESP = CreateButton("ZERO-LAG PREMIUM EGG ESP", 110)
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
    speedInput.Text = "65" 
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.Font = Enum.Font.GothamBold
    speedInput.TextSize = 12
    speedInput.ClearTextOnFocus = false

    local setSpeedBtn = Instance.new("TextButton", mainFrame)
    setSpeedBtn.Size = UDim2.new(0, 100, 0, 42)
    setSpeedBtn.Position = UDim2.new(0.5, 55, 0, 260)
    setSpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35) 
    setSpeedBtn.Text = "SET SPEED"
    setSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setSpeedBtn.Font = Enum.Font.GothamBold
    setSpeedBtn.TextSize = 11
    setSpeedBtn.BorderSizePixel = 0

    local creditsLabel = Instance.new("TextLabel", mainFrame)
    creditsLabel.Size = UDim2.new(1, 0, 0, 35)
    creditsLabel.Position = UDim2.new(0, 0, 1, -35)
    creditsLabel.BackgroundColor3 = Color3.fromRGB(16, 14, 14)
    creditsLabel.Text = "Status: Unlocked | Cache Active | CPU 0%"
    creditsLabel.TextColor3 = Color3.fromRGB(110, 90, 90)
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

    task.spawn(function()
        RunService.Heartbeat:Connect(function()
            if _G.WalkSpeed > 16 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid.MoveDirection.Magnitude > 0 then
                    player.Character.HumanoidRootPart.Velocity = Vector3.new(humanoid.MoveDirection.X * _G.WalkSpeed, player.Character.HumanoidRootPart.Velocity.Y, humanoid.MoveDirection.Z * _G.WalkSpeed)
                end
            end
        end)
    end)

    task.spawn(function()
        RunService.Stepped:Connect(function()
            if _G.NoClip and player.Character then
                for _, v in ipairs(player.Character:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            if _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                pcall(function()
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = player.Character.HumanoidRootPart
                    local safeZone = workspace:FindFirstChild("ReturnArea") or workspace:FindFirstChild("Sell") or workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Base")
                    if safeZone then _G.BaseCFrame = safeZone.CFrame end
                    
                    for _, obj in ipairs(PremiumEggPool) do
                        if _G.AutoSteal and obj and obj.Parent then
                            while _G.AutoSteal and obj.Parent and (hrp.Position - obj.Position).Magnitude > 4 do
                                RunService.Heartbeat:Wait()
                                humanoid:MoveTo(obj.Position)
                            end
                            if _G.AutoSteal and obj.Parent then
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                InteractWithEgg(obj)
                                task.wait(0.1)
                            end
                            if _G.BaseCFrame and _G.AutoSteal then
                                while _G.AutoSteal and (_G.BaseCFrame.Position - hrp.Position).Magnitude > 6 do
                                    RunService.Heartbeat:Wait()
                                    humanoid:MoveTo(_G.BaseCFrame.Position)
                                end
                            end
                            task.wait(0.1)
                            break
                        end
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
                    for _, obj in ipairs(PremiumEggPool) do
                        if obj and obj.Parent and not obj:FindFirstChild("ESP_Box") then
                            pcall(function()
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "ESP_Box"
                                box.Size = obj.Size + Vector3.new(0.4, 0.4, 0.4)
                                box.AlwaysOnTop = true
                                box.ZIndex = 5
                                box.Color3 = Color3.fromRGB(255, 30, 30)
                                box.Adornee = obj
                                box.Parent = obj
                                table.insert(espBoxes, box)
                            end)
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
        if num then _G.WalkSpeed = num end
    end)
end

-- ตรวจสอบรหัสผ่านเมื่อกดปุ่ม Unlock
submitBtn.Activated:Connect(function()
    if keyBox.Text == MY_CUSTOM_KEY then
        LoadMainHub()
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "❌ Wrong Key! Try again..."
        task.wait(1)
        keyBox.PlaceholderText = "Enter your custom key here..."
    end
end)
