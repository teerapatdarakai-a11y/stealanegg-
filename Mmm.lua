-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION V20.8
-- ULTRA MODERN PRESTIGE UI V2 + JET 150 + HOLD E
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager") 
local player = Players.LocalPlayer

task.wait(0.3)
local uiParent = (gethui and gethui()) or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

_G.AutoSteal = false
_G.EggESP = false
_G.PotatoMode = false
_G.Invisibility = false 
_G.WalkSpeed = 150
_G.BaseCFrame = nil

local IgnoreKeywords = {
    "machine", "fuse", "shop", "button", "buy", "npc", "zone", "gate", 
    "teleport", "pad", "leaderboard", "display", "eggop", "egg_op", "fusing"
}

local function IsPremiumEgg(obj)
    if not obj:IsA("BasePart") or obj.Transparency >= 1 then 
        return false 
    end
    
    local nameLower = string.lower(obj.Name)
    for _, keyword in ipairs(IgnoreKeywords) do
        if string.find(nameLower, keyword) then 
            return false 
        end
    end
    
    if obj.Size.X > 8 or obj.Size.Y > 8 or obj.Size.Z > 8 then 
        return false 
    end
    
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
        end
    end)
    return isTarget
end

-- ==========================================
-- PRESTIGE NEON UI GENERATION (V20.8)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggHub_UI"
screenGui.Parent = uiParent
screenGui.IgnoreGuiInset = true

-- หน้าต่างหลัก (Main Window) ดีไซน์กระจกดำหรูหรา
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 360) 
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

-- แถบเส้นขอบเรืองแสงไฟนีออนรอบกรอบ (Neon UI Stroke)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(0, 212, 255)
mainStroke.Thickness = 1.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- เอฟเฟกต์ไฟวิ่ง RGB แบบจาง ๆ รอบกรอบ
task.spawn(function()
    while mainFrame and task.wait(0.03) do
        local hue = (tick() % 4) / 4
        mainStroke.Color = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- แถบหัวเรื่องด้านบน (Top Bar)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

-- บล็อกปิดรูมุมล่างของ Title Bar ให้เหลี่ยมกลืนเข้ากับตัวหน้าต่าง
local titlePatch = Instance.new("Frame")
titlePatch.Size = UDim2.new(1, 0, 0, 10)
titlePatch.Position = UDim2.new(0, 0, 1, -10)
titlePatch.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
titlePatch.BorderSizePixel = 0
titlePatch.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "STEAL AN EGG • PRESTIGE V20.8"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- ปุ่มปิดกากบาท (Close Button) ทรงกลมสไตล์ไอแพด
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(1, 0)

-- ปุ่มลอยตอนย่อ (Floating Icon) สุดมินิมอลทรงกลมนีออน
local floatLogo = Instance.new("TextButton")
floatLogo.Size = UDim2.new(0, 50, 0, 50)
floatLogo.Position = UDim2.new(0, 20, 0.3, 0)
floatLogo.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
floatLogo.Text = "⚡"
floatLogo.TextColor3 = Color3.fromRGB(0, 255, 200)
floatLogo.Font = Enum.Font.GothamBold
floatLogo.TextSize = 18
floatLogo.Visible = false
floatLogo.Active = true
floatLogo.Parent = screenGui

local floatCorner = Instance.new("UICorner", floatLogo)
floatCorner.CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", floatLogo)
floatStroke.Color = Color3.fromRGB(0, 255, 200)
floatStroke.Thickness = 1.5

-- ระบบลากหน้าต่าง (Drag Engine)
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

ApplyDrag(titleBar, mainFrame)
ApplyDrag(floatLogo, floatLogo)

closeBtn.Activated:Connect(function() 
    mainFrame.Visible = false 
    floatLogo.Visible = true 
end)

floatLogo.Activated:Connect(function() 
    mainFrame.Visible = true 
    floatLogo.Visible = false 
end)

-- ฟังก์ชันสร้างปุ่มกดแบบ Premium Modern List
local function CreateButton(text, yPos)
    local container = Instance.new("Frame", mainFrame)
    container.Size = UDim2.new(0, 310, 0, 42)
    container.Position = UDim2.new(0.5, -155, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(160, 160, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local statusIndicator = Instance.new("Frame", container)
    statusIndicator.Size = UDim2.new(0, 12, 0, 12)
    statusIndicator.Position = UDim2.new(1, -24, 0.5, -6)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(240, 75, 75)
    Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(1, 0)
    
    local indicatorStroke = Instance.new("UIStroke", statusIndicator)
    indicatorStroke.Color = Color3.fromRGB(0, 0, 0)
    indicatorStroke.Thickness = 1
    
    return btn, statusIndicator
end

local btnSteal, indSteal = CreateButton("AUTO JET STEAL & HOLD (E)", 60)
local btnESP, indESP = CreateButton("ESP SECRET & DIVINE EGG", 110)
local btnPotato, indPotato = CreateButton("ULTIMATE POTATO MODE (FPS BOOST)", 160)
local btnInvis, indInvis = CreateButton("UNDERGROUND GHOST BYPASS", 210) 

-- ช่องกรอกสปีดสไตล์เรียบหรู (Speed Input Field)
local speedContainer = Instance.new("Frame", mainFrame)
speedContainer.Size = UDim2.new(0, 200, 0, 42)
speedContainer.Position = UDim2.new(0.5, -155, 0, 260)
speedContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
speedContainer.BorderSizePixel = 0
Instance.new("UICorner", speedContainer).CornerRadius = UDim.new(0, 6)

local speedInput = Instance.new("TextBox", speedContainer)
speedInput.Size = UDim2.new(1, -20, 1, 0)
speedInput.Position = UDim2.new(0, 10, 0, 0)
speedInput.BackgroundTransparency = 1
speedInput.Text = "150" 
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.ClearTextOnFocus = false

-- ปุ่มส่งความเร็วแบบ Neon Accent
local setSpeedBtn = Instance.new("TextButton", mainFrame)
setSpeedBtn.Size = UDim2.new(0, 100, 0, 42)
setSpeedBtn.Position = UDim2.new(0.5, 55, 0, 260)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
setSpeedBtn.Text = "SET SPEED"
setSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setSpeedBtn.Font = Enum.Font.GothamBold
setSpeedBtn.TextSize = 11
Instance.new("UICorner", setSpeedBtn).CornerRadius = UDim.new(0, 6)

-- ลิขสิทธิ์เครดิตบาร์ด้านล่าง (Footer Status)
local creditsLabel = Instance.new("TextLabel", mainFrame)
creditsLabel.Size = UDim2.new(1, 0, 0, 35)
creditsLabel.Position = UDim2.new(0, 0, 1, -35)
creditsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
creditsLabel.Text = "Status: Operational  |  Theme: Cyber Neon  "
creditsLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
creditsLabel.Font = Enum.Font.GothamMedium
creditsLabel.TextSize = 10

local footerCorner = Instance.new("UICorner", creditsLabel)
footerCorner.CornerRadius = UDim.new(0, 12)

-- ==========================================
-- FUNCTIONALITIES ENGINE IMPLEMENTATION
-- ==========================================
local function UpdateButtonUI(state, textLabel, indicator)
    if state then
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BackgroundColor3 = Color3.fromRGB(75, 240, 75) -- สีเขียวนีออนเปิดใช้งาน
        TweenService:Create(indicator.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 35, 45)}):Play()
    else
        textLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
        indicator.BackgroundColor3 = Color3.fromRGB(240, 75, 75) -- สีแดงปิดใช้งาน
        TweenService:Create(indicator.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
    end
end

-- ระบบจัดการความเร็วทั่วไป
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if _G.WalkSpeed > 16 and not _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.MoveDirection.Magnitude > 0 then
                player.Character.HumanoidRootPart.Velocity = humanoid.MoveDirection * _G.WalkSpeed
            end
        end
    end)
end)

-- ระบบล็อกเจ็ต 150 + กด E ค้างชาร์จเก็บไข่พรีเมียม
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local safeZone = workspace:FindFirstChild("ReturnArea") or workspace:FindFirstChild("Sell") or workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Base")
                if safeZone then 
                    _G.BaseCFrame = safeZone.CFrame 
                end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if _G.AutoSteal and IsPremiumEgg(obj) and obj.Parent then
                        local hrp = player.Character.HumanoidRootPart
                        while _G.AutoSteal and obj.Parent and (hrp.Position - obj.Position).Magnitude > 3 do
                            RunService.Heartbeat:Wait()
                            local direction = (obj.Position - hrp.Position).Unit
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.CFrame = hrp.CFrame + (direction * (150 * 0.04)) -- บังคับความเร็วคงที่ 150 บล็อก
                        end
                        
                        if _G.AutoSteal and obj.Parent then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            local duration = 3.5
                            local elapsed = 0
                            while elapsed < duration and _G.AutoSteal and obj.Parent do
                                RunService.Heartbeat:Wait()
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                elapsed = elapsed + RunService.Heartbeat:Wait()
                            end
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                        end
                        
                        if _G.BaseCFrame and _G.AutoSteal then
                            while _G.AutoSteal and (_G.BaseCFrame.Position - hrp.Position).Magnitude > 5 do
                                RunService.Heartbeat:Wait()
                                local direction = (_G.BaseCFrame.Position - hrp.Position).Unit
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.CFrame = hrp.CFrame + (direction * (150 * 0.04))
                            end
                        end
                        task.wait(0.3)
                        break
                    end
                end
            end)
        end
    end
end)

btnSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if not _G.AutoSteal then 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) 
    end
    UpdateButtonUI(_G.AutoSteal, btnSteal, indSteal)
end)

-- ระบบส่องกล่องไข่แรร์พรีเมียมสีชมพูนีออน
local espBoxes = {}
btnESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    UpdateButtonUI(_G.EggESP, btnESP, indESP)
    
    if not _G.EggESP then
        for _, box in ipairs(espBoxes) do 
            pcall(function() box:Destroy() end) 
        end
        table.clear(espBoxes)
    else
        task.spawn(function()
            while _G.EggESP do
                task.wait(1)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if IsPremiumEgg(obj) and not obj:FindFirstChild("ESP_Box") then
                        pcall(function()
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "ESP_Box"
                            box.Size = obj.Size + Vector3.new(0.4, 0.4, 0.4)
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Color3 = Color3.fromRGB(255, 0, 150)
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

-- ระบบเพิ่มความเร็ว FPS Boost (Potato Mode)
btnPotato.Activated:Connect(function()
    _G.PotatoMode = not _G.PotatoMode
    UpdateButtonUI(_G.PotatoMode, btnPotato, indPotato)
    pcall(function()
        if _G.PotatoMode then
            Lighting.GlobalShadows = false
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then 
                    v.Transparency = 1 
                end
            end
        else
            Lighting.GlobalShadows = true
        end
    end)
end)

-- ระบบล่องหนมุดดินหลบคนดู
RunService.Stepped:Connect(function()
    if _G.Invisibility and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            for _, v in ipairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") then 
                    v.CanCollide = false 
                end
            end
        end)
    end
end)

btnInvis.Activated:Connect(function()
    _G.Invisibility = not _G.Invisibility
    UpdateButtonUI(_G.Invisibility, btnInvis, indInvis)
    pcall(function()
        local hrp = player.Character.HumanoidRootPart
        if _G.Invisibility then 
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -6, 0)
        else 
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 6, 0) 
        end
    end)
end)

setSpeedBtn.Activated:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then 
        _G.WalkSpeed = num 
    end
end)
