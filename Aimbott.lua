-- ========================================================
-- 🧪 DIRECT TEST SCRIPT (รันตรง เช็กระบบตัวรันมือถือ)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

print("=== เริ่มทดสอบสคริปต์บนตัวรันมือถือ ===")

-- ทดสอบระบบ Infinite Jump แบบเบสิกที่สุด (ใช้ State ของ Humanoid โดยตรง)
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            print("Infinite Jump ทำงาน!")
        end
    end)
end)

-- ทดสอบระบบ Aimbot แบบรันตรง (ล็อกหัวเป้าหมายที่อยู่ใกล้ที่สุดทันทีเมื่อรันสคริปต์)
RunService.RenderStepped:Connect(function()
    pcall(function()
        local closestTarget = nil
        local shortestDist = 300 -- รัศมีบนจอ
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetPart = player.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                if targetPart and humanoid and humanoid.Health > 0 then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end

        -- ถ้าเจอเป้าหมาย ให้หันกล้องไปหาทันที
        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end)
end)

print("รันสคริปต์ทดสอบสำเร็จ! ลองมองหาผู้เล่นอื่นดูครับ")
