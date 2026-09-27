-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION V20.1 (FIXED BYPASS)
-- ANTI-KICK + LEGIT TWEEN + SAFE SPEED + GHOST BYPASS
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- ตรวจสอบและทำลาย UI เก่าอย่างปลอดภัยสูงสุด
local uiParent = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- สถิติตัวแปรหลัก (Global States) - ปรับค่าเริ่มต้นให้ปลอดภัยขึ้น
_G.AutoSteal = false
_G.EggESP = false
_G.PotatoMode = false
_G.Invisibility = false 
_G.WalkSpeed = 24 -- ลดความเร็วเริ่มต้นลงมาที่ 24 (ค่าปลอดภัยไม่โดนเตะ)
_G.BaseCFrame = nil
_G.CurrentTween = nil

-- รายชื่อคำสำคัญที่มักอยู่ใน Group Role ของทีมงานเกม
local StaffKeywords = {"mod", "admin", "staff", "owner", "developer", "creator", "helper"}

-- ==========================================
-- ANTI-AFK BYPASS SYSTEM
-- ==========================================
task.spawn(function()
    player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end)

-- ==========================================
-- ULTRA AUTOMATIC AUTO-REJOIN ENGINE
-- ==========================================
task.spawn(function()
    local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui", 10):WaitForChild("promptOverlay", 10)
    if promptOverlay then
        promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt" then
                local delayTime = math.random(6, 12)
                task.wait(delayTime)
                pcall(function()
                    if #Players:GetPlayers() <= 1 then
                        TeleportService:Teleport(game.PlaceId, player)
                    else
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
                    end
                end)
            end
        end)
    end
end)

-- ==========================================
-- HIGH-SECURE ADMIN / STAFF DETECTOR ENGINE
-- ==========================================
local function HopServerSafe()
    pcall(function()
        _G.AutoSteal = false
        _G.EggESP = false
        if _G.CurrentTween then _G.CurrentTween:Cancel() end
        if uiParent:FindFirstChild("StealAnEggHub_UI") then uiParent.StealAnEggHub_UI:Destroy() end
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    if game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
                        local role = string.lower(p:GetRoleInGroup(game.CreatorId))
                        for _, keyword in ipairs(StaffKeywords) do
                            if string.find(role, keyword) then
                                HopServerSafe()
                                return
                            end
                        end
                    end
                    if game.CreatorType == Enum.CreatorType.User and p.UserId == game.CreatorId then
                        HopServerSafe()
                        return
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- UI GENERATION
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggHub_UI"
screenGui.Parent = uiParent
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 330, 0, 325) 
mainFrame.Position = UDim2.new(0.5, -165, 0.5, -162)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(88, 101, 242)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
titleLabel.Text = "    ⚡ STEAL AN EGG | BYPASS ENGINE V20.1"
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
local tglESP = CreateButton("2. ESP SECRET & DIVINE EGG", 96)
local tglPotato = CreateButton("3. ULTIMATE POTATO MODE", 140)
local tglInvis = CreateButton("4. UNDERGROUND GHOST MOD", 184) 

local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(0, 205, 0, 36)
speedInput.Position = UDim2.new(0.5, -150, 0, 228)
speedInput.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
speedInput.Text = "24" -- เปลี่ยนค่าตั้งต้นให้ปลอดภัย
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.ClearTextOnFocus = false
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

local setSpeedBtn = Instance.new("TextButton", mainFrame)
setSpeedBtn.Size = UDim2.new(0, 85, 0, 36)
setSpeedBtn.Position = UDim2.new(0.5, 65, 0, 228)
setSpeedBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
setSpeedBtn.Text = "SET SPEED"
setSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setSpeedBtn.Font = Enum.Font.GothamBold
setSpeedBtn.TextSize = 11
Instance.new("UICorner", setSpeedBtn).CornerRadius = UDim.new(0, 5)

local creditsLabel = Instance.new("TextLabel", mainFrame)
creditsLabel.Size = UDim2.new(1, 0, 0, 40)
creditsLabel.Position = UDim2.new(0, 0, 1, -40)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Status: Bypass Active | Safe Mode Enabled"
creditsLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.TextSize = 10

-- ==========================================
-- FUNCTIONALITIES ENGINE IMPLEMENTATION
-- ==========================================
local function UpdateButtonState(btn, state, text)
    if state then
        btn.Text = text .. " [ON]"
        btn.TextColor3 = Color3.fromRGB(80, 240, 80)
    else
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.fromRGB(240, 80, 80)
    end
end

-- [จุดแก้ไขใหญ่] เปลี่ยนระบบความเร็วแบบยืดหยุ่น ป้องกันการโดนเตะ (CFrame Step Bypass)
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            -- ไม่แก้ค่า WalkSpeed ตรงๆ ของ Humanoid เพื่อเลี่ยง Anti-cheat ตรวจจับค่าตัวแปร
            if humanoid.MoveDirection.Magnitude > 0 then
                local hrp = player.Character.HumanoidRootPart
                -- คำนวณการเลื่อนตำแหน่งทีละนิดตามค่าความเร็วที่กำหนดแบบเนียนๆ
                local extraMove = humanoid.MoveDirection * (_G.WalkSpeed - 16) * RunService.Heartbeat:Wait()
                hrp.CFrame = hrp.CFrame + extraMove
            end
        end
    end)
end)

-- [จุดแก้ไขใหญ่] ระบบ Auto Steal แบบ Safe-Legit เดินเก็บแบบธรรมชาติไม่วาร์ปหักดิบ
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoSteal and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local base = workspace:FindFirstChild(player.Name .. "Base") or workspace:FindFirstChild("ReturnArea") or workspace:FindFirstChild("SpawnLocation")
                if base and not _G.BaseCFrame then 
                    _G.BaseCFrame = base.CFrame 
                end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if _G.AutoSteal and string.find(string.lower(obj.Name), "egg") and obj:IsA("BasePart") and obj.Transparency < 1 then
                        local hrp = player.Character.HumanoidRootPart
                        local dist = (hrp.Position - obj.Position).Magnitude
                        
                        -- จำกัดระยะการตรวจจับ ไม่ให้วาร์ปข้ามแมพไกลเกินไปในทีเดียว (ตัวต้นเหตุของการโดนเตะ)
                        if dist < 300 then
                            -- ใช้ระบบเดินตรง (CFrame Lerp) สลับเพื่อความปลอดภัยสูง
                            while _G.AutoSteal and (hrp.Position - obj.Position).Magnitude > 4 do
                                task.wait()
                                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(obj.Position.X, obj.Position.Y, obj.Position.Z)) * CFrame.new(0, 0, -(_G.WalkSpeed/10))
                            end
                            
                            task.wait(0.3) -- หน่วงเวลาเสมือนคนเก็บจริง
                            
                            -- เดินกลับฐานส่งไข่
                            if _G.BaseCFrame and _G.AutoSteal then
                                while _G.AutoSteal and (hrp.Position - _G.BaseCFrame.Position).Magnitude > 5 do
                                    task.wait()
                                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(_G.BaseCFrame.Position.X, hrp.Position.Y, _G.BaseCFrame.Position.Z)) * CFrame.new(0, 0, -(_G.WalkSpeed/10))
                                end
                            end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

tglSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    UpdateButtonState(tglSteal, _G.AutoSteal, "1. AUTO STEAL & RETURN")
end)

-- 2. ระบบ ESP (ส่องพิกัดแบบปลอดภัย)
local espBoxes = {}
tglESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    UpdateButtonState(tglESP, _G.EggESP, "2. ESP SECRET & DIVINE EGG")
    
    if not _G.EggESP then
        for _, box in ipairs(espBoxes) do 
            pcall(function() box:Destroy() end) 
        end
        table.clear(espBoxes)
    else
        task.spawn(function()
            while _G.EggESP do
                task.wait(2)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "egg") and not obj:FindFirstChild("ESP_Box") then
                        pcall(function()
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "ESP_Box"
                            box.Size = obj.Size + Vector3.new(0.1, 0.1, 0.1)
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Color3 = Color3.fromRGB(255, 170, 0)
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

-- 3. ระบบ Potato Mode
tglPotato.Activated:Connect(function()
    _G.PotatoMode = not _G.PotatoMode
    UpdateButtonState(tglPotato, _G.PotatoMode, "3. ULTIMATE POTATO MODE")
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

-- 4. ระบบ Underground Ghost Mod (ปรับแต่งค่า Y ให้เนียนขึ้นป้องกัน Void Kick)
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

tglInvis.Activated:Connect(function()
    _G.Invisibility = not _G.Invisibility
    UpdateButtonState(tglInvis, _G.Invisibility, "4. UNDERGROUND GHOST MOD")
    pcall(function()
        local hrp = player.Character.HumanoidRootPart
        if _G.Invisibility then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -8, 0) -- ปรับลงไปแค่ 8 บล็อก (ถ้าลึกเกินไปเกมจะเตะเพราะตกแมพ)
        else
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 8, 0)
        end
    end)
end)

-- ระบบควบคุมปุ่มความเร็ว
setSpeedBtn.Activated:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then
        if num > 60 then 
            num = 60 
        end -- ล็อกความเร็วสูงสุดไว้ที่ 60 ป้องกันเซิร์ฟเวอร์ดีดออก
        _G.WalkSpeed = num
    end
end)
