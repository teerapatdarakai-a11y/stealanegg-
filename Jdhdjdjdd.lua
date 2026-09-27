-- ============================================================================
-- 👑 STEAL AN EGG: PATHFINDING AUTO (NO WALL STUCK)
-- ============================================================================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("StealAnEggFixed_UI") then
    playerGui.StealAnEggFixed_UI:Destroy()
end

_G.AutoSteal = false

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
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleLabel.Text = " 👑 STEAL AN EGG (SMART PATHFINDING)"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
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
    screenGui:Destroy()
end)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 60)
monitor.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
monitor.Text = "STATUS: READY"
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 11
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "AUTO STEAL: OFF [CLICK TO START]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        toggleBtn.Text = "AUTO STEAL: SMART MODE ON"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        toggleBtn.Text = "AUTO STEAL: OFF [CLICK TO START]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ============================================================================
-- ⚙️ SMART NAVIGATION (คำนวณเดินหลบกำแพง)
-- ============================================================================
local function SmartWalkTo(targetPos)
    local char = player.Character
    if not (char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart")) then return end
    local humanoid = char.Humanoid
    local hrp = char.HumanoidRootPart

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })

    pcall(function()
        path:ComputeAsync(hrp.Position, targetPos)
        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in ipairs(waypoints) do
                if not _G.AutoSteal then break end
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                humanoid:MoveTo(waypoint.Position)
                local timeout = 0
                while (hrp.Position - waypoint.Position).Magnitude > 4 and timeout < 15 do
                    task.wait(0.1)
                    timeout = timeout + 1
                end
            end
        else
            humanoid:MoveTo(targetPos)
        end
    end)
end

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

local function GetNearestEgg()
    local nearestEgg = nil
    local minDistance = math.huge
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return nil end
    local hrp = char.HumanoidRootPart

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Parent then
            local parentObj = prompt.Parent
            local targetPart = parentObj:IsA("BasePart") and parentObj or parentObj:FindFirstChildWhichIsA("BasePart")
            
            if targetPart and targetPart:IsDescendantOf(workspace) then
                local nameLower = string.lower(parentObj.Name)
                local parentNameLower = parentObj.Parent and string.lower(parentObj.Parent.Name) or ""
                local promptText = string.lower(prompt.ActionText or "")
                
                local blacklist = {"sell", "shop", "upgrade", "chest", "starter", "reward", "gift", "rebirth", "claim", "spin"}
                local isBlocked = false
                for _, word in ipairs(blacklist) do
                    if string.find(nameLower, word) or string.find(parentNameLower, word) or string.find(promptText, word) then
                        isBlocked = true
                        break
                    end
                end
                
                if isBlocked then continue end
                
                local dist = (hrp.Position - targetPart.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    nearestEgg = targetPart
                end
            end
        end
    end
    return nearestEgg
end

-- ============================================================================
-- 🔁 MAIN LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = player.Character
            if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then return end
            
            if _G.AutoSteal then
                local holdingEgg = char:FindFirstChild("Egg") or char:FindFirstChild("CarryingEgg")
                
                if not holdingEgg then
                    monitor.Text = "STATUS: NAVIGATING TO EGG..."
                    local targetEgg = GetNearestEgg()
                    if targetEgg then
                        SmartWalkTo(targetEgg.Position)
                        
                        if (char.HumanoidRootPart.Position - targetEgg.Position).Magnitude < 10 then
                            local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt") or targetEgg.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                pcall(function()
                                    fireproximityprompt(prompt, 0)
                                end)
                            end
                        end
                    end
                else
                    monitor.Text = "STATUS: NAVIGATING TO BASE..."
                    local basePos = GetMyBasePosition()
                    if basePos then
                        SmartWalkTo(basePos)
                    end
                end
            else
                monitor.Text = "STATUS: READY"
            end
        end)
    end
end)
