-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION V20.2 (SUPER SAFE INJECT)
-- REMOVED AUTO-DETECTORS + HIDDEN UI + DELAYED BOOT
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- [จุดแก้เตะ 1] ใช้ระบบหน่วงเวลาโหลดสคริปต์ (Delayed Boot) ป้องกันเซิร์ฟเวอร์สแกนเจอตอนฉีดโค้ด
task.wait(2)

-- ทำลาย UI เก่าออกไปก่อน
local uiParent = (gethui and gethui()) or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- สถิติตัวแปรหลัก (ปิดระบบรันอัตโนมัติทุกชนิด)
_G.AutoSteal = false
_G.EggESP = false
_G.PotatoMode = false
_G.Invisibility = false 
_G.WalkSpeed = 16 -- เริ่มต้นที่ความเร็วปกติของเกม (16) เพื่อความปลอดภัยสูงสุด
_G.BaseCFrame = nil

-- *ตัดระบบ Auto-Rejoin, Anti-AFK และ Admin Detector ที่แอบทำงานเบื้องหลังออกทั้งหมด*
-- เนื่องจากเป็นจุดหลักที่ทำให้ระบบ Anti-Cheat ของเกมสแกนเจอและเตะออกทันที

-- ==========================================
-- UI GENERATION (ปรับโครงสร้างให้อ่านค่าจากหน่วยความจำต่ำลง)
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
titleLabel.Text = "    ⚡ STEAL AN EGG | BYPASS ENGINE V20.2"
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
speedInput.Text = "16" -- เริ่มต้นที่ความเร็วปกติ (16)
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
creditsLabel.Text = "Status: Stealth Inject | Pure Manual Control"
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

-- [จุดแก้เตะ 2] ระบบ Speed แบบนิ่มนวลที่สุด (ทำงานเฉพาะตอนกดเดินและไม่แก้โมเดลโดยตรง)
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if _G.WalkSpeed > 16 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.MoveDirection.Magnitude > 0 then
                local hrp = player.Character.HumanoidRootPart
                local extraMove = humanoid.MoveDirection * (_G.WalkSpeed - 16) * RunService.Heartbeat:Wait()
                hrp.CFrame = hrp.CFrame + extraMove
            end
        end
    end)
end)

-- [จุดแก้เตะ 3] ระบบ Auto Steal แบบหน่วงเวลาสูง ค่อยๆ เดินทีละก้าว ไม่วาร์ป
task.spawn(function()
    while true do
        task.wait(0.8) -- เพิ่มเวลาสแกนให้ช้าลง เพื่อหลบการดักจับของเซิร์ฟเวอร์
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
                        
                        -- คัดเลือกเฉพาะไข่ที่อยู่ใกล้ตัวในระยะ 150 บล็อกเท่านั้น เพื่อกันระบบกันวาร์ปเตะออก
                        if dist < 150 then 
                            while _G.AutoSteal and (hrp.Position - obj.Position).Magnitude > 5 do
                                task.wait(0.02)
                                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(obj.Position.X, obj.Position.Y, obj.Position.Z)) * CFrame.new(0, 0, -1.5)
                            end
                            task.wait(0.5) -- หน่วงเวลาตอนเก็บให้เหมือนคนจริงเล่น
                            
                            -- ค่อยๆ สไลด์เดินกลับฐาน
                            if _G.BaseCFrame and _G.AutoSteal then
                                while _G.AutoSteal and (hrp.Position - _G.BaseCFrame.Position).Magnitude > 6 do
                                    task.wait(0.02)
                                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(_G.BaseCFrame.Position.X, hrp.Position.Y, _G.BaseCFrame.Position.Z)) * CFrame.new(0, 0, -1.5)
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

-- 2. ระบบ ESP (ตรวจจับแบบจำกัดความถี่)
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
                task.wait(3) -- สแกนทุกๆ 3 วินาที (ลดภาระเน็ตเวิร์ก ป้องกันโดนเตะ)
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

-- 4. ระบบ Underground Ghost Mod (ปิดถาวรถ้าโดนเตะง่าย หรือเปิดสไลด์พื้นบางๆ)
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
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -5, 0) -- ลดระดับลงไปแค่ 5 บล็อกพอให้หัวมิดพื้น
        else
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 0)
        end
    end)
end)

-- ปุ่มตั้งค่าความเร็ว
setSpeedBtn.Activated:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then
        if num > 35 then 
            num = 35 
        end -- ล็อกเพดานความเร็วแบบปลอดภัยสุดๆ ไว้ที่ 35
        _G.WalkSpeed = num
    end
end)
