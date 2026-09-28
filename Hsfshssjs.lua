-- ============================================================================
-- 👑 STEAL AN EGG: ULTIMATE UX & FILTER EDITION (v5.5 FINAL AUDITED)
-- ============================================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if playerGui and playerGui:FindFirstChild("StealAnEggBypass_UI") then
    playerGui.StealAnEggBypass_UI:Destroy()
end

_G.AutoSteal = false
local currentWalkThread = nil
local eventConnections = {}

-- ============================================================================
-- 🛠️ THREAD & CONNECTION CLEANUP MANAGER
-- ============================================================================
local function StopCurrentWalk()
    if currentWalkThread then
        task.cancel(currentWalkThread)
        currentWalkThread = nil
    end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp then
        humanoid:MoveTo(hrp.Position)
    end
end

local function CleanupAllConnections()
    _G.AutoSteal = false
    StopCurrentWalk()
    for _, conn in ipairs(eventConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(eventConnections)
end

table.insert(eventConnections, player.CharacterAdded:Connect(function()
    StopCurrentWalk()
end))

table.insert(eventConnections, player.CharacterRemoving:Connect(function()
    StopCurrentWalk()
end))

-- ============================================================================
-- 🛡️ SAFE ANTI-AFK SYSTEM
-- ============================================================================
table.insert(eventConnections, player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(math.random(2, 4) / 10)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end))

-- ============================================================================
-- 🎨 USER INTERFACE & PRECISION FLOATING WIDGET (🚀)
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggBypass_UI"
screenGui.ResetOnSpawn = false
if playerGui then screenGui.Parent = playerGui end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 210)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 220, 130)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 42)
titleLabel.BackgroundColor3 = Color3.fromRGB(24, 30, 38)
titleLabel.Text = "   🛡️ STEAL AN EGG: ULTIMATE v5.5"
titleLabel.TextColor3 = Color3.fromRGB(0, 220, 130)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 10)

local minimizeBtn = Instance.new("TextButton", titleLabel)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -66, 0.5, -14)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 12
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local destroyBtn = Instance.new("TextButton", titleLabel)
destroyBtn.Size = UDim2.new(0, 28, 0, 28)
destroyBtn.Position = UDim2.new(1, -34, 0.5, -14)
destroyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
destroyBtn.Text = "✕"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 13
Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0, 6)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -30, 0, 40)
monitor.Position = UDim2.new(0, 15, 0, 55)
monitor.BackgroundColor3 = Color3.fromRGB(26, 34, 44)
monitor.Text = "STATUS: IDLE"
monitor.TextColor3 = Color3.fromRGB(180, 190, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 12
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 8)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 85)
toggleBtn.Position = UDim2.new(0, 15, 0, 108)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 62)
toggleBtn.Text = "START AUTO FARM"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local openWidget = Instance.new("TextButton")
openWidget.Name = "OpenWidget"
openWidget.Size = UDim2.new(0, 50, 0, 50)
openWidget.Position = UDim2.new(0.05, 0, 0.2, 0)
openWidget.BackgroundColor3 = Color3.fromRGB(20, 26, 35)
openWidget.Text = "🚀"
openWidget.TextSize = 26
openWidget.Visible = false
openWidget.Active = true
openWidget.Parent = screenGui

Instance.new("UICorner", openWidget).CornerRadius = UDim.new(1, 0)
local widgetStroke = Instance.new("UIStroke", openWidget)
widgetStroke.Color = Color3.fromRGB(0, 220, 130)
widgetStroke.Thickness = 2.5

local dragging = false
local dragThresholdPassed = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    if delta.Magnitude > 6 then
        dragThresholdPassed = true
        dragging = true
    end
    
    if dragging then
        openWidget.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

table.insert(eventConnections, openWidget.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = openWidget.Position
        dragThresholdPassed = false
        dragging = false

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end))

table.insert(eventConnections, openWidget.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))

table.insert(eventConnections, UserInputService.InputChanged:Connect(function(input)
    if input == dragInput then
        updateInput(input)
    end
end))

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openWidget.Visible = true
end)

destroyBtn.MouseButton1Click:Connect(function()
    CleanupAllConnections()
    screenGui:Destroy()
end)

openWidget.MouseButton1Click:Connect(function()
    if not dragThresholdPassed then
        mainFrame.Visible = true
        openWidget.Visible = false
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        toggleBtn.Text = "AUTO FARM: ACTIVE"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        StopCurrentWalk()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 62)
        toggleBtn.Text = "START AUTO FARM"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        monitor.Text = "STATUS: IDLE"
        monitor.TextColor3 = Color3.fromRGB(180, 190, 200)
    end
end)

-- ============================================================================
-- ⚙️ ADVANCED TARGET FINDER (WITH BLACKLIST)
-- ============================================================================
local RARE_KEYWORDS = {
    "secret", "eternal", "divine", "cosmic", "mutant", "pure",
    "pegasus", "skeleton horse", "world burner", "burner", "centaur", 
    "gargoyle", "jellyfish", "razorfang", "gorilla king", "shark", 
    "kitsune", "oni tiger", "oni", "stag", "dragon", "skeleton warrior", 
    "lunar horse", "mosasaurus", "trex", "t-rex", "tralaledon", 
    "phoenix", "cerberus", "kraken"
}

local IGNORED_KEYWORDS = {
    "sell", "shop", "combine", "craft", "fuse", "hatch", "upgrade", "place", "base", "plot"
}

local cachedPrompt = nil
local lastSearch = 0

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
    return false
end

local function GetMyBasePosition()
    for _, folderName in ipairs({"Bases", "Plots", "Islands", "Tycoons"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                local ownerName = base:GetAttribute("Owner") or ""
                if string.find(string.lower(base.Name), string.lower(player.Name)) or tostring(ownerName) == tostring(player.UserId) then
                    if base:FindFirstChild("Core") then return base.Core.Position end
                    if base.PrimaryPart then return base.PrimaryPart.Position end
                    return base:GetPivot().Position
                end
            end
        end
    end
    local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    return spawnLoc and spawnLoc.Position or Vector3.new(0, 5, 0)
end

local function GetTargetEggSafe()
    if tick() - lastSearch < 1.5 and cachedPrompt and cachedPrompt.Parent then
        local part = cachedPrompt.Parent:IsA("BasePart") and cachedPrompt.Parent or cachedPrompt.Parent:FindFirstChildWhichIsA("BasePart")
        if part then return part, cachedPrompt end
    end

    lastSearch = tick()
    local container = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("Spawns") or Workspace

    for _, prompt in ipairs(container:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
            local parent = prompt.Parent
            local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
            
            if part then
                local txt = string.lower((prompt.ActionText or "") .. " " .. (prompt.ObjectText or "") .. " " .. parent.Name)
                
                local isIgnored = false
                for _, ignoreKw in ipairs(IGNORED_KEYWORDS) do
                    if string.find(txt, ignoreKw) then
                        isIgnored = true
                        break
                    end
                end

                if not isIgnored then
                    for _, kw in ipairs(RARE_KEYWORDS) do
                        if string.find(txt, kw) then
                            cachedPrompt = prompt
                            return part, prompt
                        end
                    end
                end
            end
        end
    end
    cachedPrompt = nil
    return nil, nil
end

-- ============================================================================
-- 🚶 NON-HARMONIC VELOCITY PATHFINDING ENGINE
-- ============================================================================
local function SafeWalkToThreaded(targetPos)
    local char = player.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentHeight = 5,
        AgentCanJump = true
    })

    local success, _ = pcall(function()
        path:ComputeAsync(hrp.Position, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not _G.AutoSteal then break end
            if IsHoldingEgg() and targetPos ~= GetMyBasePosition() then break end
            
            local dynamicFreq = 3 + (math.noise(tick() * 0.5, 0, 0) * 2.5)
            local noiseFactor = math.sin(tick() * dynamicFreq) * 0.75
            humanoid.WalkSpeed = 15.6 + noiseFactor + (math.random(-15, 15) / 100)

            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            local timeout = tick()
            while _G.AutoSteal and (hrp.Position - waypoint.Position).Magnitude > 4 do
                task.wait(0.05)
                if tick() - timeout > 2.5 then
                    humanoid.Jump = true
                    break
                end
            end
        end
    else
        humanoid:MoveTo(targetPos)
        local fallback = tick()
        while _G.AutoSteal and (hrp.Position - targetPos).Magnitude > 6 do
            task.wait(0.1)
            if tick() - fallback > 4 then break end
        end
    end

    return (hrp.Position - targetPos).Magnitude <= 7
end

-- ============================================================================
-- 🤝 PING-PROTECTED PROXIMITY INTERACTION
-- ============================================================================
local function InteractServerValidated(prompt)
    if not prompt or not prompt.Parent then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local parentPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
    if not parentPart then return end

    local rawPing = 0.05
    pcall(function()
        local statsItem = Stats.Network:FindFirstChild("ServerStatsItem")
        if statsItem and statsItem:FindFirstChild("Data Ping") then
            rawPing = statsItem["Data Ping"]:GetValue() / 1000
        end
    end)

    local safeDistance = (prompt.MaxActivationDistance or 10) - math.clamp(rawPing * 10, 0.5, 3.0)

    if (hrp.Position - parentPart.Position).Magnitude > safeDistance then return end

    task.wait(math.random(15, 30) / 100)

    local holdTime = prompt.HoldDuration or 0
    pcall(function()
        if holdTime > 0 then
            prompt:InputHoldBegin()
            task.wait(holdTime + (math.random(5, 10) / 100))
            prompt:InputHoldEnd()
        else
            fireproximityprompt(prompt)
        end
    end)
end

-- ============================================================================
-- 🔁 MAIN STATE CONTROLLER (ASYNC WORKER THREADS)
-- ============================================================================
task.spawn(function()
    while screenGui and screenGui.Parent do
        task.wait(0.2)
        
        if _G.AutoSteal and not currentWalkThread then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                currentWalkThread = task.spawn(function()
                    if IsHoldingEgg() then
                        monitor.Text = "STATUS: 🚚 RETURNING TO BASE"
                        monitor.TextColor3 = Color3.fromRGB(100, 200, 255)
                        
                        local basePos = GetMyBasePosition()
                        SafeWalkToThreaded(basePos)
                    else
                        monitor.Text = "STATUS: 🔍 SEARCHING EGG"
                        monitor.TextColor3 = Color3.fromRGB(0, 220, 130)
                        
                        local eggPart, prompt = GetTargetEggSafe()
                        
                        if eggPart and prompt then
                            monitor.Text = "STATUS: 🏃 APPROACHING EGG"
                            monitor.TextColor3 = Color3.fromRGB(255, 200, 80)
                            
                            local reached = SafeWalkToThreaded(eggPart.Position)
                            
                            if reached and _G.AutoSteal and prompt.Enabled then
                                monitor.Text = "STATUS: 🥚 STEALING EGG..."
                                monitor.TextColor3 = Color3.fromRGB(255, 140, 0)
                                
                                InteractServerValidated(prompt)
                                task.wait(math.random(4, 7) / 10)
                            end
                        else
                            monitor.Text = "STATUS: ⏳ NO EGG FOUND"
                            monitor.TextColor3 = Color3.fromRGB(220, 100, 100)
                        end
                    end
                    currentWalkThread = nil
                end)
            end
        end
    end
end)
