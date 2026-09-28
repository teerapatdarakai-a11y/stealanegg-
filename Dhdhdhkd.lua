-- ============================================================================
-- 👑 STEAL AN EGG: FLAWLESS AUTO-FARM (BULLETPROOF EDITION)
-- ============================================================================
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if playerGui and playerGui:FindFirstChild("StealAnEggPro_UI") then
    playerGui.StealAnEggPro_UI:Destroy()
end

_G.AutoSteal = false

-- ป้องกัน AFK แบบสมบูรณ์
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- ============================================================================
-- 🎨 USER INTERFACE
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggPro_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
if playerGui then screenGui.Parent = playerGui end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
titleLabel.Text = " 👑 FLAWLESS AUTO-FARM"
titleLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 60)
monitor.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
monitor.Text = "STATUS: STANDBY"
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 12
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
toggleBtn.Text = "AUTO STEAL: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        toggleBtn.Text = "AUTO STEAL: ACTIVE"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        toggleBtn.Text = "AUTO STEAL: OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        monitor.Text = "STATUS: STANDBY"
    end
end)

-- ============================================================================
-- ⚙️ CORE LOGIC & FUNCTIONS
-- ============================================================================
local RARE_KEYWORDS = {
    "secret", "eternal", "divine", "mythic", "legendary",
    "king snake", "yeti", "cerberus", "kraken", "t-rex", "tralaledon", "stag",
    "ice dragon", "phoenix", "lava dragon", "el maja", "mosasaurus", "oni tiger", "kitsune"
}

local function IsHoldingEgg()
    local char = player.Character
    if not char then return false end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") or child:IsA("Tool") then
            local n = string.lower(child.Name)
            if string.find(n, "egg") or string.find(n, "carrying") then return true end
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
    return spawnLoc and (spawnLoc.Position + Vector3.new(0, 5, 0)) or Vector3.new(0, 50, 0)
end

local function GetBestEgg()
    local bestEgg, bestPrompt, bestName = nil, nil, ""
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
            local parent = prompt.Parent
            local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
            
            if part then
                local txt = string.lower((prompt.ActionText or "") .. " " .. (prompt.ObjectText or ""))
                if not string.find(txt, "sell") and not string.find(txt, "shop") then
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

-- ============================================================================
-- 🔁 MAIN STATE MACHINE LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.1) do
        if not _G.AutoSteal then continue end
        
        pcall(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if IsHoldingEgg() then
                monitor.Text = "STATUS: DELIVERING EGG..."
                local basePos = GetMyBasePosition()
                
                -- วาร์ปเฉพาะเมื่ออยู่ไกลจากฐานเกิน 10 Studs เพื่อกันบั๊ก
                if (hrp.Position - basePos).Magnitude > 10 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 3, 0))
                end
                task.wait(0.5) -- รอให้ระบบของเกมดึงไข่เข้าฐาน
            else
                monitor.Text = "STATUS: SCANNING..."
                local eggPart, prompt, name = GetBestEgg()
                
                if eggPart and prompt and prompt.Enabled then
                    monitor.Text = "STATUS: FOUND " .. name
                    
                    if (hrp.Position - eggPart.Position).Magnitude > 7 then
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        hrp.CFrame = CFrame.new(eggPart.Position + Vector3.new(0, 2.5, 0))
                        task.wait(0.15) -- ให้เวลาเซิร์ฟเวอร์อัปเดตตำแหน่งก่อนส่งคำสั่งกด
                    end
                    
                    if prompt.Enabled then
                        if fireproximityprompt then
                            fireproximityprompt(prompt, 1)
                        else
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            prompt:InputHoldEnd()
                        end
                        task.wait(0.3) -- Cooldown ป้องกันการรัวคำสั่งใส่เซิร์ฟเวอร์
                    end
                end
            end
        end)
    end
end)
