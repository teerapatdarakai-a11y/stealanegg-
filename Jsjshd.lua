-- ============================================================================
-- 👑 STEAL AN EGG: EXACT RARE HUNTER (SECRET / ETERNAL / DIVINE ONLY)
-- ============================================================================
local Players = game:GetService("Players")
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
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 0, 80)
stroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleLabel.Text = " 👑 EXACT RARE HUNTER (SECRET/ETERNAL/DIVINE)"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 80)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
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
monitor.Text = "STATUS: SCANNING HIGH TIER EGGS..."
monitor.TextColor3 = Color3.fromRGB(200, 200, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 11
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -30, 0, 60)
toggleBtn.Position = UDim2.new(0, 15, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "RARE HUNTER: OFF [CLICK TO START]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 80)
        toggleBtn.Text = "RARE HUNTER: ACTIVE"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        toggleBtn.Text = "RARE HUNTER: OFF [CLICK TO START]"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ============================================================================
-- ⚙️ EXACT DATABASE DETECTOR
-- ============================================================================
local DIVINE_EGGS = { "kitsune" }

local ETERNAL_EGGS = { "ice dragon", "phoenix", "lava dragon", "el maja", "mosasaurus", "oni tiger" }

local SECRET_EGGS = { "king snake", "yeti", "cerberus", "kraken", "t-rex", "tralaledon", "stag" }

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

local function IsHoldingEgg()
    local char = player.Character
    if not char then return false end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") or child:IsA("Tool") or child:IsA("BasePart") then
            local n = string.lower(child.Name)
            if string.find(n, "egg") or string.find(n, "carrying") or string.find(n, "stolen") then
                return true
            end
        end
    end
    
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Motor6D") then
            if desc.Part0 and desc.Part1 then
                local p0Name = string.lower(desc.Part0.Name)
                local p1Name = string.lower(desc.Part1.Name)
                if string.find(p0Name, "egg") or string.find(p1Name, "egg") then
                    return true
                end
            end
        end
    end
    return false
end

local function GetHighTierEggOnly()
    local bestEgg = nil
    local highestPriority = -1
    local bestName = ""

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Parent then
            local parentObj = prompt.Parent
            local targetPart = parentObj:IsA("BasePart") and parentObj or parentObj:FindFirstChildWhichIsA("BasePart")
            
            if targetPart and targetPart:IsDescendantOf(workspace) then
                local name1 = string.lower(parentObj.Name)
                local name2 = parentObj.Parent and string.lower(parentObj.Parent.Name) or ""
                local name3 = parentObj.Parent and parentObj.Parent.Parent and string.lower(parentObj.Parent.Parent.Name) or ""
                local promptText = string.lower(prompt.ActionText or "")
                local objectText = string.lower(prompt.ObjectText or "")
                
                local combined = name1 .. " " .. name2 .. " " .. name3 .. " " .. promptText .. " " .. objectText
                
                local blacklist = {"sell", "shop", "upgrade", "chest", "starter", "reward", "gift", "rebirth", "claim", "spin"}
                local isBlocked = false
                for _, word in ipairs(blacklist) do
                    if string.find(combined, word) then
                        isBlocked = true
                        break
                    end
                end
                
                if not isBlocked then
                    local priority = 0
                    
                    -- Check Divine
                    for _, name in ipairs(DIVINE_EGGS) do
                        if string.find(combined, name) or string.find(combined, "divine") then
                            priority = 3
                            break
                        end
                    end
                    
                    -- Check Eternal
                    if priority == 0 then
                        for _, name in ipairs(ETERNAL_EGGS) do
                            if string.find(combined, name) or string.find(combined, "eternal") then
                                priority = 2
                                break
                            end
                        end
                    end
                    
                    -- Check Secret
                    if priority == 0 then
                        for _, name in ipairs(SECRET_EGGS) do
                            if string.find(combined, name) or string.find(combined, "secret") then
                                priority = 1
                                break
                            end
                        end
                    end
                    
                    if priority > 0 and priority > highestPriority then
                        highestPriority = priority
                        bestEgg = targetPart
                        bestName = parentObj.Name
                    end
                end
            end
        end
    end
    return bestEgg, bestName
end

-- ============================================================================
-- 🔁 MAIN LOOP
-- ============================================================================
task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            local char = player.Character
            if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then return end
            local humanoid = char.Humanoid
            local hrp = char.HumanoidRootPart
            
            if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or humanoid:GetState() == Enum.HumanoidStateType.Physics then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end

            if _G.AutoSteal then
                if not IsHoldingEgg() then
                    local targetEgg, eggName = GetHighTierEggOnly()
                    
                    if targetEgg then
                        monitor.Text = "TARGET FOUND: " .. string.upper(eggName)
                        humanoid:MoveTo(targetEgg.Position)
                        
                        if (hrp.Position - targetEgg.Position).Magnitude <= 12 then
                            local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt") or targetEgg.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    else
                        monitor.Text = "WAITING FOR SECRET / ETERNAL / DIVINE..."
                    end
                else
                    monitor.Text = "STATUS: BRINGING RARE EGG HOME..."
                    local basePos = GetMyBasePosition()
                    if basePos then
                        humanoid:MoveTo(basePos)
                    end
                end
            else
                monitor.Text = "STATUS: READY"
            end
        end)
    end
end)
