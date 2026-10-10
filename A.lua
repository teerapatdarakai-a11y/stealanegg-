-- ====================================================================================
-- ⚡ NEXUS // ENTERPRISE-GRADE SCRIPT SUITE (ZERO-GHOST EDITION 17.0 - MOBILE STABLE)
-- ====================================================================================
local NexusCore = {}
NexusCore.Version = "17.0.0-MobileEnterprise"

if _G.NexusMobileEnterprise then
    pcall(function() _G.NexusMobileEnterprise:Destroy() end)
end
_G.NexusMobileEnterprise = NexusCore

-- 1. SERVICE CACHING & SAFE ENVIRONMENT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- 2. CONFIGURATION MATRIX
NexusCore.Config = {
    Global = { ThemeAccent = Color3.fromRGB(0, 255, 170) },
    Combat = {
        AimbotActive = false,
        SilentAimActive = false,
        TeamCheck = true,
        WallCheck = true,
        AimBone = "Head",
        FOVRadius = 260,
        SmoothnessValue = 0.3,
        PredictionScale = 0.14
    },
    Visuals = {
        ESPActive = false,
        BoxRender = true,
        NameRender = true,
        HealthBarRender = true,
        SkeletonRender = true
    },
    Extensions = {
        TriggerBotActive = false,
        HitboxExpanderActive = false,
        HitboxSize = 3.5,
        TargetHUDActive = true
    }
}

local OriginalHitboxSizes = {}

-- 3. INDUSTRIAL UI SUITE (GUARANTEED PLAYERGUI CONTAINER)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("NexusMobileUI17") then
    PlayerGui.NexusMobileUI17:Destroy()
end

local RootScreenGui = Instance.new("ScreenGui")
RootScreenGui.Name = "NexusMobileUI17"
RootScreenGui.ResetOnSpawn = false
RootScreenGui.Parent = PlayerGui

local FloatingBtn = Instance.new("TextButton", RootScreenGui)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
FloatingBtn.Position = UDim2.new(0.04, 0, 0.18, 0)
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = NexusCore.Config.Global.ThemeAccent
FloatingBtn.TextSize = 22
FloatingBtn.Active, FloatingBtn.Draggable = true, true
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(0, 14)

local MainWin = Instance.new("Frame", RootScreenGui)
MainWin.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainWin.Position = UDim2.new(0.22, 0, 0.18, 0)
MainWin.Size = UDim2.new(0, 320, 0, 440)
MainWin.Visible, MainWin.Active, MainWin.Draggable = false, true, true
Instance.new("UICorner", MainWin).CornerRadius = UDim.new(0, 12)

local WinHeader = Instance.new("TextLabel", MainWin)
WinHeader.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
WinHeader.Size = UDim2.new(1, 0, 0, 40)
WinHeader.Font = Enum.Font.GothamBold
WinHeader.Text = "⚡ NEXUS // ZERO-GHOST v17"
WinHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
WinHeader.TextSize = 11
Instance.new("UICorner", WinHeader).CornerRadius = UDim.new(0, 12)

FloatingBtn.MouseButton1Click:Connect(function() MainWin.Visible = not MainWin.Visible end)

local function BuildToggle(name, initialVal, callback)
    local btn = Instance.new("TextButton", MainWin)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    btn.Size = UDim2.new(0.92, 0, 0, 34)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local state = initialVal
    local function updateText()
        btn.Text = name .. " : " .. (state and "[🟢 ON]" else "[🔴 OFF]")
    end
    updateText()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateText()
        callback(state)
    end)
end

local UIList = Instance.new("UIListLayout", MainWin)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

BuildToggle("🎯 Combat Aimbot", NexusCore.Config.Combat.AimbotActive, function(v) NexusCore.Config.Combat.AimbotActive = v end)
BuildToggle("🔫 Auto-TriggerBot", NexusCore.Config.Extensions.TriggerBotActive, function(v) NexusCore.Config.Extensions.TriggerBotActive = v end)
BuildToggle("📦 Hitbox Expander (Safe)", NexusCore.Config.Extensions.HitboxExpanderActive, function(v) 
    NexusCore.Config.Extensions.HitboxExpanderActive = v 
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and OriginalHitboxSizes[root] then root.Size = OriginalHitboxSizes[root] end
        end
    end
end)
BuildToggle("👥 Team Filter Check", NexusCore.Config.Combat.TeamCheck, function(v) NexusCore.Config.Combat.TeamCheck = v end)
BuildToggle("🧱 Wall Occlusion Check", NexusCore.Config.Combat.WallCheck, function(v) NexusCore.Config.Combat.WallCheck = v end)
BuildToggle("👁️ ESP Active", NexusCore.Config.Visuals.ESPActive, function(v) NexusCore.Config.Visuals.ESPActive = v end)
BuildToggle("🦴 Skeleton Matrix ESP", NexusCore.Config.Visuals.SkeletonRender, function(v) NexusCore.Config.Visuals.SkeletonRender = v end)
BuildToggle("🎯 Target Info HUD", NexusCore.Config.Extensions.TargetHUDActive, function(v) NexusCore.Config.Extensions.TargetHUDActive = v end)

local UnloadBtn = Instance.new("TextButton", MainWin)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
UnloadBtn.Size = UDim2.new(0.92, 0, 0, 34)
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.Text = "❌ UNLOAD & PURGE SYSTEM"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.TextSize = 11
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 8)

UnloadBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if NexusCore.FOVCircle then pcall(function() NexusCore.FOVCircle:Remove() end) end
        if NexusCore.TargetHUDText then pcall(function() NexusCore.TargetHUDText:Remove() end) end
        
        for root, origSize in pairs(OriginalHitboxSizes) do
            if root and root.Parent then root.Size = origSize end
        end
        table.clear(OriginalHitboxSizes)

        for _, bundle in pairs(NexusCore.VisualsManager.ActiveDrawings) do
            pcall(function()
                if bundle.BoxOutline then bundle.BoxOutline:Remove() end
                if bundle.BoxMain then bundle.BoxMain:Remove() end
                if bundle.NameLabel then bundle.NameLabel:Remove() end
                if bundle.HealthBg then bundle.HealthBg:Remove() end
                if bundle.HealthMain then bundle.HealthMain:Remove() end
                if bundle.SkeletonBones then
                    for _, l in ipairs(bundle.SkeletonBones) do pcall(function() l:Remove() end) end
                end
            end)
        end
        _G.NexusMobileEnterprise = nil
        RootScreenGui:Destroy()
    end)
end)

-- 4. BALLISTICS & PREDICTION ENGINE
local BallisticsEngine = {}
NexusCore.Ballistics = BallisticsEngine

function BallisticsEngine:ValidateVisibility(targetPart, localChar)
    if not NexusCore.Config.Combat.WallCheck then return true end
    if not Camera or not targetPart then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {localChar, Camera}
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local result = Workspace:Raycast(origin, targetPart.Position - origin, rayParams)
    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

function BallisticsEngine:FindOptimalTarget(playersService, localPlayer)
    if not Camera then return nil end
    local config = NexusCore.Config.Combat
    local bestPart = nil
    local shortestDist = config.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local localChar = localPlayer.Character
    
    for _, p in ipairs(playersService:GetPlayers()) do
        if p ~= localPlayer then
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local targetPart = char:FindFirstChild(config.AimBone)
                if hum and hum.Health > 0 and targetPart then
                    local teamValid = not (config.TeamCheck and p.Team and p.Team == localPlayer.Team)
                    if teamValid and self:ValidateVisibility(targetPart, localChar) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

function BallisticsEngine:ComputePredictionVector(targetPart)
    local config = NexusCore.Config.Combat
    if not targetPart or not targetPart.Parent then return Vector3.zero end
    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if config.PredictionScale > 0 and root then
        return targetPart.Position + (root.Velocity * config.PredictionScale)
    end
    return targetPart.Position
end

-- 5. ESP & SKELETON MANAGER
local ESPManager = { ActiveDrawings = {} }
NexusCore.VisualsManager = ESPManager

local BoneConnectionsR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

function ESPManager:RegisterPlayer(player)
    if player == LocalPlayer then return end
    local bundle = {
        BoxOutline = Drawing.new("Square"), BoxMain = Drawing.new("Square"),
        NameLabel = Drawing.new("Text"), HealthBg = Drawing.new("Line"), HealthMain = Drawing.new("Line"),
        SkeletonBones = {}
    }
    bundle.BoxMain.Visible, bundle.BoxMain.Thickness, bundle.BoxMain.Filled = false, 1.2, false
    bundle.BoxMain.Color = Color3.fromRGB(0, 255, 170)
    bundle.BoxOutline.Visible, bundle.BoxOutline.Thickness, bundle.BoxOutline.Filled = false, 2.2, false
    bundle.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    bundle.NameLabel.Visible, bundle.NameLabel.Size, bundle.NameLabel.Center, bundle.NameLabel.Outline = false, 13, true, true
    bundle.HealthBg.Visible, bundle.HealthBg.Thickness = false, 3.5
    bundle.HealthMain.Visible, bundle.HealthMain.Thickness = false, 2.0
    
    for _ in ipairs(BoneConnectionsR15) do
        local line = Drawing.new("Line")
        line.Visible = false; line.Thickness = 1.0; line.Color = Color3.fromRGB(0, 240, 255)
        table.insert(bundle.SkeletonBones, line)
    end
    self.ActiveDrawings[player] = bundle
end

function ESPManager:PurgePlayer(player)
    local bundle = self.ActiveDrawings[player]
    if bundle then
        pcall(function()
            if bundle.BoxOutline then bundle.BoxOutline:Remove() end
            if bundle.BoxMain then bundle.BoxMain:Remove() end
            if bundle.NameLabel then bundle.NameLabel:Remove() end
            if bundle.HealthBg then bundle.HealthBg:Remove() end
            if bundle.HealthMain then bundle.HealthMain:Remove() end
            if bundle.SkeletonBones then
                for _, l in ipairs(bundle.SkeletonBones) do pcall(function() l:Remove() end) end
            end
        end)
        self.ActiveDrawings[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do ESPManager:RegisterPlayer(p) end
Players.PlayerAdded:Connect(function(p) ESPManager:RegisterPlayer(p) end)
Players.PlayerRemoving:Connect(function(p) ESPManager:PurgePlayer(p) end)

-- 6. EXECUTION RUNTIME & PIPELINE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Filled = false; FOVCircle.Color = NexusCore.Config.Global.ThemeAccent
NexusCore.FOVCircle = FOVCircle

local TargetHUDText = Drawing.new("Text")
TargetHUDText.Visible = false; TargetHUDText.Size = 14; TargetHUDText.Center = false; TargetHUDText.Outline = true
TargetHUDText.Color = Color3.fromRGB(0, 255, 200)
NexusCore.TargetHUDText = TargetHUDText

RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        if not Camera then return end
        
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = NexusCore.Config.Combat.FOVRadius
        FOVCircle.Visible = NexusCore.Config.Combat.AimbotActive

        TargetHUDText.Position = Vector2.new(Camera.ViewportSize.X / 2 - 80, (Camera.ViewportSize.Y / 2) + 60)

        -- TriggerBot Logic
        if NexusCore.Config.Extensions.TriggerBotActive then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if target and target.Parent then
                local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                if targetPlayer and targetPlayer ~= LocalPlayer then
                    local isTeam = NexusCore.Config.Combat.TeamCheck and targetPlayer.Team and targetPlayer.Team == LocalPlayer.Team
                    if not isTeam then
                        local hum = target.Parent:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then pcall(function() tool:Activate() end) end
                        end
                    end
                end
            end
        end

        -- Hitbox Expander Logic
        if NexusCore.Config.Extensions.HitboxExpanderActive then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local isTeam = NexusCore.Config.Combat.TeamCheck and p.Team and p.Team == LocalPlayer.Team
                        if not isTeam then
                            if not OriginalHitboxSizes[root] then OriginalHitboxSizes[root] = root.Size end
                            root.Size = Vector3.new(NexusCore.Config.Extensions.HitboxSize, NexusCore.Config.Extensions.HitboxSize, NexusCore.Config.Extensions.HitboxSize)
                            root.Transparency = 0.8
                        end
                    end
                end
            end
        end

        -- Aimbot Pipeline
        local combatCfg = NexusCore.Config.Combat
        if combatCfg.AimbotActive then
            local localChar = LocalPlayer.Character
            local localHum = localChar and localChar:FindFirstChildOfClass("Humanoid")
            if localHum and localHum.Health > 0 then
                local optimalPart = BallisticsEngine:FindOptimalTarget(Players, LocalPlayer)
                if optimalPart then
                    local predictedCoords = BallisticsEngine:ComputePredictionVector(optimalPart)
                    local calculatedCFrame = CFrame.new(Camera.CFrame.Position, predictedCoords)
                    local lerpSpeed = math.clamp(combatCfg.SmoothnessValue * (dt * 60), 0.05, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(calculatedCFrame, lerpSpeed)
                end
            end
        end

        -- Target HUD Logic
        if NexusCore.Config.Extensions.TargetHUDActive and combatCfg.AimbotActive then
            local optimalPart = BallisticsEngine:FindOptimalTarget(Players, LocalPlayer)
            if optimalPart and optimalPart.Parent then
                local targetPlayer = Players:GetPlayerFromCharacter(optimalPart.Parent)
                local targetHum = optimalPart.Parent:FindFirstChildOfClass("Humanoid")
                if targetPlayer and targetHum and targetHum.Health > 0 then
                    local dist = math.floor((optimalPart.Position - Camera.CFrame.Position).Magnitude)
                    local hp = math.floor((targetHum.Health / targetHum.MaxHealth) * 100)
                    TargetHUDText.Visible = true
                    TargetHUDText.Text = string.format("🎯 TARGET: %s | HP: %d%% | DIST: %dm", targetPlayer.Name, hp, dist)
                else
                    TargetHUDText.Visible = false
                end
            else
                TargetHUDText.Visible = false
            end
        else
            TargetHUDText.Visible = false
        end

        -- ESP, Health Bar & Skeleton Render Pipeline (Zero-Ghost Pre-Cleaning Logic)
        local visualsCfg = NexusCore.Config.Visuals
        for p, bundle in pairs(ESPManager.ActiveDrawings) do
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            local shouldHideAll = true
            
            if visualsCfg.ESPActive and char and root and hum and hum.Health > 0 then
                local isTeamMate = (combatCfg.TeamCheck and p.Team and p.Team == LocalPlayer.Team)
                if not isTeamMate then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local head = char:FindFirstChild("Head")
                        if head then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            
                            if height > 0 and height < 5000 then
                                local width = height / 2
                                local topLeft = Vector2.new(pos.X - width / 2, headPos.Y)
                                
                                shouldHideAll = false

                                -- Box Render
                                if visualsCfg.BoxRender and bundle.BoxOutline and bundle.BoxMain then
                                    bundle.BoxOutline.Visible = true; bundle.BoxOutline.Size = Vector2.new(width, height); bundle.BoxOutline.Position = topLeft
                                    bundle.BoxMain.Visible = true; bundle.BoxMain.Size = Vector2.new(width, height); bundle.BoxMain.Position = topLeft
                                else
                                    if bundle.BoxMain then bundle.BoxMain.Visible = false end
                                    if bundle.BoxOutline then bundle.BoxOutline.Visible = false end
                                end
                                
                                -- Name Render
                                if visualsCfg.NameRender and bundle.NameLabel then
                                    bundle.NameLabel.Visible = true
                                    bundle.NameLabel.Text = p.Name
                                    bundle.NameLabel.Position = Vector2.new(pos.X, headPos.Y - 18)
                                else
                                    if bundle.NameLabel then bundle.NameLabel.Visible = false end
                                end
                                
                                -- Health Bar Render
                                if visualsCfg.HealthBarRender and bundle.HealthBg and bundle.HealthMain then
                                    local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    local barHeight = height * ratio
                                    
                                    bundle.HealthBg.Visible = true
                                    bundle.HealthBg.From = Vector2.new(topLeft.X - 6, topLeft.Y + height)
                                    bundle.HealthBg.To = Vector2.new(topLeft.X - 6, topLeft.Y)
                                    
                                    bundle.HealthMain.Visible = true
                                    bundle.HealthMain.Color = Color3.fromRGB(255 - (ratio * 255), ratio * 255, 0)
                                    bundle.HealthMain.From = Vector2.new(topLeft.X - 6, topLeft.Y + height)
                                    bundle.HealthMain.To = Vector2.new(topLeft.X - 6, topLeft.Y + (height - barHeight))
                                else
                                    if bundle.HealthBg then bundle.HealthBg.Visible = false end
                                    if bundle.HealthMain then bundle.HealthMain.Visible = false end
                                end

                                -- Skeleton Render
                                if visualsCfg.SkeletonRender and bundle.SkeletonBones then
                                    for index, bonePair in ipairs(BoneConnectionsR15) do
                                        local partA = char:FindFirstChild(bonePair[1])
                                        local partB = char:FindFirstChild(bonePair[2])
                                        local lineObj = bundle.SkeletonBones[index]
                                        
                                        if partA and partB and lineObj then
                                            local pA, onA = Camera:WorldToViewportPoint(partA.Position)
                                            local pB, onB = Camera:WorldToViewportPoint(partB.Position)
                                            if onA or onB then
                                                lineObj.Visible = true
                                                lineObj.From = Vector2.new(pA.X, pA.Y)
                                                lineObj.To = Vector2.new(pB.X, pB.Y)
                                            else
                                                lineObj.Visible = false
                                            end
                                        else
                                            if lineObj then lineObj.Visible = false end
                                        end
                                    end
                                else
                                    if bundle.SkeletonBones then for _, l in ipairs(bundle.SkeletonBones) do l.Visible = false end end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Zero-Ghost Pre/Post Cleaning
            if shouldHideAll then
                if bundle.BoxMain then bundle.BoxMain.Visible = false end
                if bundle.BoxOutline then bundle.BoxOutline.Visible = false end
                if bundle.NameLabel then bundle.NameLabel.Visible = false end
                if bundle.HealthBg then bundle.HealthBg.Visible = false end
                if bundle.HealthMain then bundle.HealthMain.Visible = false end
                if bundle.SkeletonBones then
                    for _, l in ipairs(bundle.SkeletonBones) do l.Visible = false end
                end
            end
        end
    end)
end)

print("💎 NEXUS ZERO-GHOST v17 (MOBILE STABLE) // SUCCESSFULLY LOADED.")
