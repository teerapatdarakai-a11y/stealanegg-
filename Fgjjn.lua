-- ============================================================================
-- 👑 STEAL AN EGG: PRIVATE PREMIUM HUB (LEGIT WALK / ANTI-BAN VERSION)
-- ============================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("StealAnEggFixed_UI") then
    playerGui.StealAnEggFixed_UI:Destroy()
end

_G.AutoSteal = false
_G.AntiAFK = true

-- ============================================================================
-- 🎨 UI CREATION
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggFixed_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 260)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 170, 0)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleLabel.Text = " 👑 STEAL AN EGG (LEGIT WALK)"
titleLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 10)

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
    screenGui:Destroy()
end)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 60)
monitor.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
monitor.Text = "STATUS: SAFE LEGIT READY"
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 11
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

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
        toggleBtn.Text = "AUTO STEAL: ACTIVE [WALKING]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        toggleBtn.Text = "AUTO STEAL: OFF [CLICK TO TURN ON]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ============================================================================
-- 🛡️ FILTER & LEGIT MOVEMENT UTILITIES
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
                local promptText = string.lower(prompt.ActionText or "")
                local objectText = string.lower(prompt.ObjectText or "")
                
                -- 🛑 กรองสิ่งของที่ไม่ใช่ไข่ หรือโซนอันตรายออกทั้งหมด
                local blacklist = {"sell", "shop", "upgrade", "chest", "starter", "reward", "gift", "rebirth", "claim", "spin"}
                local isBlocked = false
                
                for _, word in ipairs(blacklist) do
                    if string.find(nameLower, word) or string.find(parentNameLower, word) or string.find(promptText, word) or string.find(objectText, word) then
                        isBlocked = true
                        break
                    end
                end
                
                if isBlocked then continue end
                
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

-- 🚶‍♂️ เปลี่ยนมาใช้ระบบเดินจริง (Humanoid:MoveTo) ป้องกันการโดนแบนความเร็ว
local function LegitWalkTo(targetPosition)
    local char = player.Character
    if not (char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart")) then return end
    
    local humanoid = char.Humanoid
    local hrp = char.HumanoidRootPart
    
    humanoid:MoveTo(targetPosition)
    
    local startTime = tick()
    while (hrp.Position - targetPosition).Magnitude > 5 do
        if not _G.AutoSteal then break end
        if tick() - startTime > 15 then break end -- กันค้างถ้าติดสิ่งกีดขวาง
        task.wait(0.2)
    end
end

-- ============================================================================
-- 🔁 MAIN LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = player.Character
            if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
            
            if _G.AutoSteal then
                local holdingEgg = char:FindFirstChild("Egg") or char:FindFirstChild("CarryingEgg")
                
                if not holdingEgg then
                    monitor.Text = "STATUS: WALKING TO FIND EGG..."
                    local targetEgg = GetGodTierEggOnly()
                    if targetEgg then
                        LegitWalkTo(targetEgg.Position)
                        local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt") or targetEgg.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            task.wait(0.2)
                            fireproximityprompt(prompt)
                        end
                    else
                        monitor.Text = "STATUS: SEARCHING VALID EGGS..."
                    end
                else
                    monitor.Text = "STATUS: WALKING HOME..."
                    local basePos = GetMyBasePosition()
                    if basePos then
                        LegitWalkTo(basePos)
                        task.wait(0.5)
                    end
                end
            else
                monitor.Text = "STATUS: SAFE LEGIT READY"
            end
        end)
    end
end)
