-- ============================================================================
-- 👑 STEAL AN EGG: FLAWLESS ANTI-CHEAT BYPASS (SMART WALK EDITION)
-- ============================================================================
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if playerGui and playerGui:FindFirstChild("StealAnEggBypass_UI") then
    playerGui.StealAnEggBypass_UI:Destroy()
end

_G.AutoSteal = false

-- ระบบป้องกัน AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- ============================================================================
-- 🎨 USER INTERFACE
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggBypass_UI"
screenGui.ResetOnSpawn = false
if playerGui then screenGui.Parent = playerGui end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 120)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
titleLabel.Text = " 🛡️ SMART WALK (ANTI-BAC1514)"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
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
    _G.AutoSteal = false
    screenGui:Destroy() 
end)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 60)
monitor.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
monitor.Text = "STATUS: STANDBY"
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 12
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
toggleBtn.Text = "AUTO FARM: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        toggleBtn.Text = "AUTO FARM: ACTIVE"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        toggleBtn.Text = "AUTO FARM: OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        monitor.Text = "STATUS: STANDBY"
    end
end)

-- ============================================================================
-- ⚙️ CORE LOGIC & SAFE MOVEMENT SYSTEM
-- ============================================================================
local RARE_KEYWORDS = {
    -- 🥚 Rarities & Special Eggs
    "secret egg", "eternal egg", "divine egg", "secret", "eternal", "divine",
    
    -- 🐉 Rare Pets & Mythics
    "pegasus", "skeleton horse", "world burner", "centaur", "gargoyle", 
    "pure jellyfish", "razorfang", "gorilla king", "mutant shark", "kitsune", 
    "oni tiger", "stag", "cosmic dragon", "cosmic skeleton warrior", 
    "eternal lunar horse", "mosasaurus", "trex", "t-rex", "tralaledon", 
    "phoenix", "cerberus", "kraken"
}

local function IsHoldingEgg()
    local char = player.Character
    if not char then return false end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") or child:IsA("Tool") then
            local n = string.lower(child.Name)
            if string.find(n, "egg") or string.find(n, "carrying") or string.find(n, "stolen") then 
                return true 
            end
        end
    end
    
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Weld") or desc:IsA("Motor6D") then
            if desc.Part1 and string.find(string.lower(desc.Part1.Name), "egg") then 
                return true 
            end
        end
    end
    return false
end

local function GetMyBasePosition()
    for _, folderName in ipairs({"Bases", "Plots", "Islands", "Tycoons"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                if string.find(string.lower(base.Name), string.lower(player.Name)) or (base:GetAttribute("Owner") == player.UserId) then
                    if base:FindFirstChild("Core") then return base.Core.Position end
                    if base.PrimaryPart then return base.PrimaryPart.Position end
                    return base:GetPivot().Position
                end
            end
        end
    end
    local spawnLoc = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    return spawnLoc and spawnLoc.Position or Vector3.new(0, 5, 0)
end

local function GetBestEgg()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
            local parent = prompt.Parent
            local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
            
            if part then
                local txt = string.lower((prompt.ActionText or "") .. " " .. (prompt.ObjectText or ""))
                if not string.find(txt, "sell") and not string.find(txt, "shop") and not string.find(txt, "claim") then
                    for _, kw in ipairs(RARE_KEYWORDS) do
                        if string.find(txt, kw) then
                            return part, prompt, kw:upper()
                        end
                    end
                end
            end
        end
    end
    return nil, nil, ""
end

-- ฟังก์ชันเคลื่อนที่แบบมนุษย์ ป้องกัน Anti-Cheat 100%
local function SafeWalkTo(targetPos)
    local char = player.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end

    -- เดินเข้าหาเป้าหมาย
    humanoid:MoveTo(targetPos)
    
    local startTime = tick()
    while _G.AutoSteal and (hrp.Position - targetPos).Magnitude > 6 do
        task.wait(0.1)
        
        -- ป้องกันตัวละครติดสิ่งกีดขวางเกิน 8 วินาที
        if tick() - startTime > 8 then
            humanoid.Jump = true
            humanoid:MoveTo(targetPos)
            startTime = tick()
        end
        
        -- ถ้าสถานะเปลี่ยนขณะกำลังเดิน ให้ยกเลิกการเดิน
        if IsHoldingEgg() and targetPos ~= GetMyBasePosition() then
            break
        end
    end
    
    return (hrp.Position - targetPos).Magnitude <= 8
end

-- ============================================================================
-- 🔁 MAIN LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoSteal then continue end
        
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            if IsHoldingEgg() then
                monitor.Text = "STATUS: RETURNING TO BASE..."
                local basePos = GetMyBasePosition()
                SafeWalkTo(basePos)
                task.wait(0.5)
            else
                local eggPart, prompt, name = GetBestEgg()
                if eggPart and prompt and prompt.Enabled then
                    monitor.Text = "STATUS: WALKING TO " .. name
                    
                    local reached = SafeWalkTo(eggPart.Position)
                    
                    if reached and prompt.Enabled and _G.AutoSteal then
                        monitor.Text = "STATUS: STEALING " .. name
                        task.wait(0.2) -- หน่วงเวลาสั้นๆ ก่อนกด
                        
                        if fireproximityprompt then
                            fireproximityprompt(prompt, 0)
                        else
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            prompt:InputHoldEnd()
                        end
                        task.wait(0.5)
                    end
                else
                    monitor.Text = "STATUS: SCANNING..."
                end
            end
        end)
    end
end)
