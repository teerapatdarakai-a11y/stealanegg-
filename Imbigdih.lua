-- ============================================================================
-- 👑 STEAL AN EGG: PRIVATE PREMIUM HUB (ULTIMATE COMPATIBLE VERSION)
-- ============================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ลบ UI เก่าทิ้งทันทีเพื่อกันบัคซ้อน
if playerGui:FindFirstChild("StealAnEggFixed_UI") then
    playerGui.StealAnEggFixed_UI:Destroy()
end

-- ============================================================================
-- ⚙️ CONFIGURATIONS
-- ============================================================================
_G.AutoSteal = false
_G.BypassSpeed = 60
_G.AntiAFK = true
_G.TomatoMode = false
_G.NoClip = false

-- ============================================================================
-- 🎨 SIMPLE & CLEAN UI CREATION (GUARANTEED TO LOAD)
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggFixed_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 300)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- ทำให้ลากหน้าจอได้ง่ายๆ ด้วยระบบพื้นฐาน
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 170, 0)
stroke.Thickness = 2

-- หัวข้อ UI
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleLabel.Text = " 👑 STEAL AN EGG (FIXED UI)"
titleLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 10)

-- ปุ่มปิด/เปิดย่อหน้าจอ
local closeBtn = Instance.new("TextButton", titleLabel)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy() -- ปิดและลบทิ้งไปเลยเพื่อความสะอาด
end)

-- หน้าจอมอนิเตอร์บอกสถานะ
local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 60)
monitor.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
monitor.Text = "STATUS: READY (CLICK TO TOGGLE AUTO)"
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 11
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

-- ปุ่มเปิด-ปิด Auto Steal ขนาดใหญ่ใช้งานง่าย
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "AUTO STEAL: OFF [CLICK TO TURN ON]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        toggleBtn.Text = "AUTO STEAL: ACTIVE [RUNNING]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        toggleBtn.Text = "AUTO STEAL: OFF [CLICK TO TURN ON]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ป้ายเครดิตเล็กๆ ด้านล่าง
local credit = Instance.new("TextLabel", mainFrame)
credit.Size = UDim2.new(1, 0, 0, 30)
credit.Position = UDim2.new(0, 0, 1, -35)
credit.BackgroundTransparency = 1
credit.Text = "V46.2 Lightweight Engine • Safe Mode"
credit.TextColor3 = Color3.fromRGB(100, 100, 110)
credit.Font = Enum.Font.Gotham
credit.TextSize = 10

-- ============================================================================
-- 🛡️ CORE UTILITIES & FUNCTIONS
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
    local bestEgg, highestWeight = nil, -1
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return nil end
    
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Parent then
            local parentObj = prompt.Parent
            local targetPart = parentObj:IsA("BasePart") and parentObj or parentObj:FindFirstChildWhichIsA("BasePart")
            
            if targetPart and targetPart:IsDescendantOf(workspace) then
                local nameLower = string.lower(parentObj.Name)
                local parentNameLower = parentObj.Parent and string.lower(parentObj.Parent.Name) or ""
                
                if string.find(nameLower, "chest") or string.find(nameLower, "shop") then continue end
                
                local weight = 0
                if string.find(nameLower, "eternal") or string.find(parentNameLower, "eternal") then
                    weight = 9000000
                elseif string.find(nameLower, "divine") or string.find(parentNameLower, "divine") then
                    weight = 6000000
                elseif string.find(nameLower, "secret") or string.find(parentNameLower, "secret") then
                    weight = 3000000
                end
                
                if weight > highestWeight then
                    highestWeight = weight
                    bestEgg = targetPart
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
    
    local duration = distance / 1000
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ============================================================================
-- 🔁 MAIN LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = player.Character
            if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
            
            if _G.AutoSteal then
                local holdingEgg = char:FindFirstChild("Egg") or char:FindFirstChild("CarryingEgg")
                
                if not holdingEgg then
                    monitor.Text = "STATUS: SEARCHING GOD EGG..."
                    local targetEgg = GetGodTierEggOnly()
                    if targetEgg then
                        SafeTweenMove(targetEgg.CFrame * CFrame.new(0, 1.5, 0), false)
                        local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt") or targetEgg.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            task.wait(0.05)
                            fireproximityprompt(prompt)
                        end
                    end
                else
                    monitor.Text = "STATUS: BRINGING EGG HOME..."
                    local basePos = GetMyBasePosition()
                    if basePos then
                        SafeTweenMove(CFrame.new(basePos + Vector3.new(0, 4, 0)), true)
                    end
                end
            else
                if monitor.Text ~= "STATUS: READY (CLICK TO TOGGLE AUTO)" then
                    monitor.Text = "STATUS: IDLE"
                end
            end
        end)
    end
end)
