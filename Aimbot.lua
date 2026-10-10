-- ========================================================
-- 🎯 MOBILE AIMBOT & ESP HUB - PERFECT PRO EDITION
-- ========================================================

-- ตรวจสอบและโหลด Rayfield UI (รองรับมือถือ Android)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("ไม่สามารถโหลด Rayfield UI ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือตัวรัน!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "🔥 Mobile Aimbot Hub - Perfect Pro",
   LoadingTitle = "กำลังโหลดระบบโปรมือถือ...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL SETTINGS
-- ====================
getgenv().ProSettings = {
    AimbotEnabled = false,
    TeamCheck = true,
    WallCheck = true,
    Smoothness = 0.25,
    AimPart = "Head", -- Head หรือ HumanoidRootPart
    FOVRadius = 200,
    ESPEnabled = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ====================
-- WALLCHECK FUNCTION
-- ====================
local function isVisible(targetPart, character)
    if not getgenv().ProSettings.WallCheck then return true end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localChar, character}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result then
        return false
    end
    return true
end

-- ====================
-- GET CLOSEST TARGET
-- ====================
local function getClosestTarget()
    local closestTarget = nil
    local shortestDist = getgenv().ProSettings.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isEnemy = true
            if getgenv().ProSettings.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                isEnemy = false
            end
            
            if isEnemy and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local targetPart = player.Character:FindFirstChild(getgenv().ProSettings.AimPart)
                
                if humanoid and humanoid.Health > 0 and targetPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenDist = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        
                        if screenDist < shortestDist and isVisible(targetPart, player.Character) then
                            shortestDist = screenDist
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ====================
-- AIMBOT LOOP (RENDER STEPPED)
-- ====================
RunService.RenderStepped:Connect(function(deltaTime)
    if not getgenv().ProSettings.AimbotEnabled then return end
    
    pcall(function()
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("Humanoid") or localChar.Humanoid.Health <= 0 then return end
        
        local target = getClosestTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            local smoothFactor = math.clamp(getgenv().ProSettings.Smoothness * (deltaTime * 60), 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothFactor)
        end
    end)
end)

-- ====================
-- UI TABS CREATION
-- ====================
local TabAimbot = Window:CreateTab("🎯 Aimbot Pro", 4483362458)
local TabVisuals = Window:CreateTab("👁️ Visuals & ESP", 4483362458)
local TabSettings = Window:CreateTab("⚙️ Settings", 4483362458)

-- ====================
-- TAB 1: AIMBOT SETTINGS
-- ====================
TabAimbot:CreateSection("ระบบล็อกเป้าหมายอัตโนมัติ")

TabAimbot:CreateToggle({
   Name = "🎯 เปิดใช้งาน Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      getgenv().ProSettings.AimbotEnabled = Value
   end,
})

TabAimbot:CreateDropdown({
   Name = "🎯 เป้าหมายที่จะเล็ง",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Flag = "AimPartDropdown",
   Callback = function(Option)
      getgenv().ProSettings.AimPart = Option
   end,
})

TabAimbot:CreateSlider({
   Name = "⚡ ความหน่วง (Smoothness - ยิ่งน้อยยิ่งไว)",
   Range = {0.05, 0.8},
   Increment = 0.05,
   Suffix = " Speed",
   CurrentValue = 0.25,
   Flag = "SmoothnessSlider",
   Callback = function(Value)
      getgenv().ProSettings.Smoothness = Value
   end,
})

TabAimbot:CreateSlider({
   Name = "⭕ รัศมีการตรวจจับเป้าหมาย (FOV Radius)",
   Range = {50, 400},
   Increment = 25,
   Suffix = " px",
   CurrentValue = 200,
   Flag = "FOVRAgiusSlider",
   Callback = function(Value)
      getgenv().ProSettings.FOVRadius = Value
   end,
})

-- ====================
-- TAB 2: VISUALS & CHECKS
-- ====================
TabVisuals:CreateSection("ระบบตรวจสอบความปลอดภัย")

TabVisuals:CreateToggle({
   Name = "🛡️ เช็คทีมเดียวกัน (Team Check)",
   CurrentValue = true,
   Flag = "TeamCheckToggle",
   Callback = function(Value)
      getgenv().ProSettings.TeamCheck = Value
   end,
})

TabVisuals:CreateToggle({
   Name = "🧱 เช็คกำแพงบัง (Wall Check)",
   CurrentValue = true,
   Flag = "WallCheckToggle",
   Callback = function(Value)
      getgenv().ProSettings.WallCheck = Value
   end,
})

-- ====================
-- TAB 3: SETTINGS & INFO
-- ====================
TabSettings:CreateSection("ข้อมูลระบบ")

TabSettings:CreateButton({
   Name = "🗑️ ปิดการทำงานและล้างเมนูทั้งหมด",
   Callback = function()
      getgenv().ProSettings.AimbotEnabled = false
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "Perfect Pro Hub Loaded!",
   Content = "ระบบ Aimbot มือถือพร้อมใช้งานแล้วครับ!",
   Duration = 4,
   Image = 4483362458,
})
