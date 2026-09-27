-- ==========================================
-- STEAL AN EGG: DEFINITIVE EDITION (V ULTIMATE FIXED)
-- HIGH-PERFORMANCE EVENT-DRIVEN ENGINE
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- ล้าง UI เก่าถ้ามีอยู่
local uiParent = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")
if uiParent:FindFirstChild("StealAnEggHub_UI") then
    uiParent.StealAnEggHub_UI:Destroy()
end

-- Global States & Cache Setup
_G.AutoSteal = false
_G.EggESP = false
_G.PotatoMode = false
_G.WalkSpeed = 16
_G.BaseCFrame = nil
_G.CurrentTween = nil
_G.EggCache = {}

local cacheConnection = nil

-- ==========================================
-- UI GENERATION
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggHub_UI"
screenGui.Parent = uiParent
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 330, 0, 290)
mainFrame.Position = UDim2.new(0.5, -165, 0.5, -145)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(88, 101, 242)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
titleLabel.Text = "    ⚡ STEAL AN EGG | ULTIMATE FIXED"
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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end 
            end)
        end
    end)
    trigger.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end 
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

closeBtn.Activated:Connect(function() mainFrame.Visible = false; floatLogo.Visible = true end)
floatLogo.Activated:Connect(function() mainFrame.Visible = true; floatLogo.Visible = false end)

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

local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(0, 205, 0, 36)
speedInput.Position = UDim2.new(0.5, -150, 0, 184)
speedInput.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
speedInput.Text = "16"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.ClearTextOnFocus = false
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

local btnSpeed = Instance.new("TextButton", mainFrame)
btnSpeed.Size = UDim2.new(0, 85, 0, 36)
btnSpeed.Position = UDim2.new(0.5, 65, 0, 184)
btnSpeed.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
btnSpeed.Text = "SET SPEED"
btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.TextSize = 11
Instance.new("UICorner", btnSpeed).CornerRadius = UDim.new(0, 5)

local creditLabel = Instance.new("TextLabel", mainFrame)
creditLabel.Size = UDim2.new(1, 0, 0, 25)
creditLabel.Position = UDim2.new(0, 0, 1, -25)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "STABLE ENGINE V ULTIMATE • ULTRA PERFORMANCE"
creditLabel.TextColor3 = Color3.fromRGB(90, 95, 120)
creditLabel.Font = Enum.Font.GothamMedium
creditLabel.TextSize = 9

-- ==========================================
-- HIGH-PERFORMANCE EGG CACHE LOGIC
-- ==========================================
local function IsValidEgg(obj)
    if not obj or not (obj:IsA("Model") or obj:IsA("BasePart")) then return nil end

    local checkParent = obj
    for i = 1, 3 do
        if checkParent and checkParent ~= game then
            if checkParent:FindFirstChildOfClass("Humanoid") then return nil end
            checkParent = checkParent.Parent
        end
    end

    local name = string.lower(obj.Name)
    if string.find(name, "secret") or string.find(name, "divine") then
        local root = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if root and root.Transparency < 1 and root.Parent ~= nil then
            return root
        end
    end
    return nil
end

local function ApplyESPToObj(eggRoot)
    if not eggRoot or not eggRoot.Parent then return end
    if not eggRoot:FindFirstChild("Egg_Ultimate_ESP_Box") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Egg_Ultimate_ESP_Box"
        box.Size = eggRoot.Size + Vector3.new(0.2, 0.2, 0.2)
        box.Adornee = eggRoot
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Color3 = Color3.fromRGB(255, 0, 128)
        box.Parent = eggRoot
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Egg_Ultimate_ESP_Text"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = eggRoot
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = eggRoot.Parent.Name
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 128)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboard
    end
end

local function UpdateEggCache(obj)
    local name = string.lower(obj.Name)
    if not (string.find(name, "secret") or string.find(name, "divine")) then return end

    task.defer(function()
        local root = IsValidEgg(obj)
        if root and not table.find(_G.EggCache, root) then
            table.insert(_G.EggCache, root)
            if _G.EggESP then ApplyESPToObj(root) end
        end
    end)
end

-- สแกนรอบแรกและสถาปนา Event Listener
table.clear(_G.EggCache)
local initialObjects = workspace:GetDescendants()
for i = 1, #initialObjects do
    local root = IsValidEgg(initialObjects[i])
    if root then table.insert(_G.EggCache, root) end
end

if cacheConnection then cacheConnection:Disconnect() end
cacheConnection = workspace.DescendantAdded:Connect(UpdateEggCache)

local function FindClosestEggFromCache()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local closest, shortestDistance = nil, math.huge
    for i = #_G.EggCache, 1, -1 do
        local rootPart = _G.EggCache[i]
        if not rootPart or not rootPart.Parent or not rootPart:IsDescendantOf(workspace) then
            table.remove(_G.EggCache, i)
        else
            local dist = (hrp.Position - rootPart.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closest = rootPart
            end
        end
    end
    return closest and closest.Parent, closest
end

-- ==========================================
-- ESP & POTATO ENGINE
-- ==========================================
local function ClearAllESP()
    for i = 1, #_G.EggCache do
        local root = _G.EggCache[i]
        if root then
            local box = root:FindFirstChild("Egg_Ultimate_ESP_Box")
            local text = root:FindFirstChild("Egg_Ultimate_ESP_Text")
            if box then box:Destroy() end
            if text then text:Destroy() end
        end
    end
end

local function ApplyAllESP()
    for i = 1, #_G.EggCache do
        ApplyESPToObj(_G.EggCache[i])
    end
end

local function ClearGameGraphics()
    pcall(function()
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            local item = descendants[i]
            if item:IsA("BasePart") and not item:IsDescendantOf(player.Character) then
                if not IsValidEgg(item) and not IsValidEgg(item.Parent) then
                    item.Material = Enum.Material.SmoothPlastic
                    item.Color = Color3.fromRGB(110, 110, 110)
                    item.CastShadow = false
                end
            elseif item:IsA("Texture") or item:IsA("Decal") then
                item:Destroy()
            end
        end
        Lighting.GlobalShadows = false
    end)
end

-- ==========================================
-- TWEEN ENGINE (SMOOTH & NOCLIP SAFE)
-- ==========================================
local function PremiumTween(targetCFrame, isReturn)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if _G.CurrentTween then _G.CurrentTween:Cancel() end

    local finalCFrame = isReturn and targetCFrame or (targetCFrame + Vector3.new(0, 2, 0))
    local dist = (hrp.Position - finalCFrame.Position).Magnitude
    local dur = dist / 1200
    
    if dur < 0.02 then 
        hrp.CFrame = finalCFrame 
        return 
    end

    hrp.Anchored = true -- ป้องกันฟิสิกส์ตีกันขณะวาร์ป
    _G.CurrentTween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = finalCFrame})
    _G.CurrentTween:Play()
    _G.CurrentTween.Completed:Wait()
    hrp.Anchored = false
end

-- ==========================================
-- BUTTON CONTROLS
-- ==========================================
tglSteal.Activated:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    tglSteal.Text = _G.AutoSteal and "1. AUTO STEAL & RETURN [ON]" or "1. AUTO STEAL & RETURN [OFF]"
    tglSteal.BackgroundColor3 = _G.AutoSteal and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglSteal.TextColor3 = _G.AutoSteal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if _G.AutoSteal then
        if hrp then
            _G.BaseCFrame = hrp.CFrame + Vector3.new(0, 45, 0)
            hrp.CFrame = _G.BaseCFrame
            hrp.Anchored = true
        end
    else
        if _G.CurrentTween then _G.CurrentTween:Cancel() end
        if hrp then hrp.Anchored = false end
    end
end)

tglESP.Activated:Connect(function()
    _G.EggESP = not _G.EggESP
    tglESP.Text = _G.EggESP and "2. ESP SECRET & DIVINE [ON]" or "2. ESP SECRET & DIVINE [OFF]"
    tglESP.BackgroundColor3 = _G.EggESP and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglESP.TextColor3 = _G.EggESP and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    
    if _G.EggESP then ApplyAllESP() else ClearAllESP() end
end)

tglPotato.Activated:Connect(function()
    _G.PotatoMode = not _G.PotatoMode
    tglPotato.Text = _G.PotatoMode and "3. ULTIMATE POTATO MODE [ON]" or "3. ULTIMATE POTATO MODE [OFF]"
    tglPotato.BackgroundColor3 = _G.PotatoMode and Color3.fromRGB(45, 140, 85) or Color3.fromRGB(32, 32, 45)
    tglPotato.TextColor3 = _G.PotatoMode and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 80, 80)
    if _G.PotatoMode then ClearGameGraphics() end
end)

btnSpeed.Activated:Connect(function()
    local extractNum = tonumber(speedInput.Text:match("%d+"))
    if extractNum then
        _G.WalkSpeed = extractNum
        speedInput.Text = tostring(_G.WalkSpeed)
    end
end)

-- ==========================================
-- REAL-TIME BACKGROUND LOOPS
-- ==========================================
-- Noclip & WalkSpeed Control
RunService.Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and _G.WalkSpeed and hum.WalkSpeed ~= _G.WalkSpeed then
                hum.WalkSpeed = _G.WalkSpeed
            end
            
            -- บังคับ Noclip ป้องกันการติดบล็อกกำแพง
            if _G.AutoSteal then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- Main Farm Loop (Auto Steal)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoSteal and _G.BaseCFrame then
            pcall(function()
                local eggModel, eggRoot = FindClosestEggFromCache()
                if eggModel and eggRoot then
                    PremiumTween(eggRoot.CFrame, false)
                    task.wait(0.1)
                    
                    if firetouchinterest then
                        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            firetouchinterest(myRoot, eggRoot, 0)
                            task.wait(0.01)
                            firetouchinterest(myRoot, eggRoot, 1)
                        end
                    end
                    
                    local prompt = eggModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                    task.wait(0.05)
                    
                    PremiumTween(_G.BaseCFrame, true)
                    
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = true end
                end
            end)
        end
    end
end)
