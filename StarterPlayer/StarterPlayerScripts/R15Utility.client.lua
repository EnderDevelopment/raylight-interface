-- R15Utility.client.lua
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state = {
    panelVisible = true,
    sitting = false,
    spinning = false,
    dwarf = false,
    giantDwarf = false,
    flying = false,
    infiniteJump = false,
}

local character
local humanoid
local rootPart
local originalScales = {}
local spinConnection
local flyConnection
local jumpConnection
local flyVelocity
local flyGyro
local sitConnection

local function getCharacterParts()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    return humanoid ~= nil and rootPart ~= nil
end

local function notify(message)
    local notice = Instance.new("TextLabel")
    notice.Name = "Notice"
    notice.AnchorPoint = Vector2.new(1, 1)
    notice.Position = UDim2.new(1, -20, 1, -20)
    notice.Size = UDim2.fromOffset(260, 40)
    notice.BackgroundColor3 = Color3.fromRGB(35, 35, 47)
    notice.BackgroundTransparency = 0.05
    notice.TextColor3 = Color3.fromRGB(235, 235, 245)
    notice.Font = Enum.Font.GothamMedium
    notice.TextSize = 14
    notice.Text = message
    notice.ZIndex = 20
    notice.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notice

    task.delay(2.2, function()
        if notice.Parent then
            notice:Destroy()
        end
    end)
end

local function isR15()
    return humanoid and humanoid.RigType == Enum.HumanoidRigType.R15
end

local function saveOriginalScales()
    if not isR15() then
        return false
    end

    originalScales = {}
    for _, name in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
        local value = humanoid:FindFirstChild(name)
        if value and value:IsA("NumberValue") then
            originalScales[name] = value.Value
        end
    end
    return true
end

local function setScale(name, value)
    local scale = humanoid and humanoid:FindFirstChild(name)
    if scale and scale:IsA("NumberValue") then
        scale.Value = value
    end
end

local function restoreScale()
    if not isR15() then
        notify("Dwarf sizes require an R15 character")
        return
    end

    for name, value in pairs(originalScales) do
        setScale(name, value)
    end
    state.dwarf = false
    state.giantDwarf = false
end

local function applyDwarf(giant)
    if not isR15() then
        notify("Dwarf sizes require an R15 character")
        return
    end

    if next(originalScales) == nil then
        saveOriginalScales()
    end

    if giant then
        setScale("BodyHeightScale", 1.45)
        setScale("BodyWidthScale", 1.15)
        setScale("BodyDepthScale", 1.15)
        setScale("HeadScale", 1.05)
        state.giantDwarf = true
        state.dwarf = false
        notify("Giant dwarf enabled")
    else
        setScale("BodyHeightScale", 0.55)
        setScale("BodyWidthScale", 0.8)
        setScale("BodyDepthScale", 0.8)
        setScale("HeadScale", 0.85)
        state.dwarf = true
        state.giantDwarf = false
        notify("Dwarf enabled")
    end
end

local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    if rootPart then
        rootPart.AssemblyAngularVelocity = Vector3.zero
    end
    state.spinning = false
end

local function startSpin()
    if not getCharacterParts() then
        return
    end
    stopSpin()
    state.spinning = true
    spinConnection = RunService.Heartbeat:Connect(function()
        if not rootPart or not rootPart.Parent then
            stopSpin()
            return
        end
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 12, 0)
    end)
end

local function setSitting(enabled)
    if not getCharacterParts() then
        return
    end
    state.sitting = enabled
    humanoid.Sit = enabled
    if enabled then
        notify("Cute sit enabled")
    else
        notify("Cute sit disabled")
    end
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
    state.flying = false
end

local function startFly()
    if not getCharacterParts() then
        return
    end
    stopFly()

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "R15UtilityFlyVelocity"
    flyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyVelocity.P = 10000
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = rootPart

    flyGyro = Instance.new("BodyGyro")
    flyGyro.Name = "R15UtilityFlyGyro"
    flyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    flyGyro.P = 10000
    flyGyro.CFrame = rootPart.CFrame
    flyGyro.Parent = rootPart

    humanoid.PlatformStand = true
    state.flying = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not rootPart or not rootPart.Parent or not flyVelocity or not flyGyro then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local direction = Vector3.zero
        if camera then
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= look end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += right end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= right end
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        flyVelocity.Velocity = direction * 55
        flyGyro.CFrame = camera and CFrame.lookAt(rootPart.Position, rootPart.Position + camera.CFrame.LookVector) or rootPart.CFrame
    end)
    notify("Fly enabled: WASD, Space, and Left Ctrl")
end

local function setInfiniteJump(enabled)
    state.infiniteJump = enabled
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
    if enabled then
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            if getCharacterParts() and humanoid.Health > 0 then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("Infinite jump enabled")
    else
        notify("Infinite jump disabled")
    end
end

local function resetCharacterState()
    stopSpin()
    stopFly()
    if sitConnection then
        sitConnection:Disconnect()
        sitConnection = nil
    end
    state.sitting = false
    state.infiniteJump = false
    originalScales = {}
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 61)
    button.AutoButtonColor = false
    button.TextColor3 = Color3.fromRGB(230, 230, 240)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.Text = text
    button.Parent = parent
    createCorner(button, 7)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(65, 65, 88)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 61)
    end)
    button.Activated:Connect(callback)
    return button
end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "R15UtilityUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Position = UDim2.fromOffset(24, 120)
main.Size = UDim2.fromOffset(260, 350)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Parent = screenGui
createCorner(main, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(88, 88, 120)
stroke.Transparency = 0.35
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 44)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "R15 Utility"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 20)
subtitle.Position = UDim2.fromOffset(12, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Rayfield-style character controls"
subtitle.TextColor3 = Color3.fromRGB(155, 155, 180)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(12, 68)
list.Size = UDim2.new(1, -24, 1, -80)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = list

createButton(list, "Cute Sit", function()
    setSitting(not state.sitting)
end)
createButton(list, "Spin", function()
    if state.spinning then stopSpin() else startSpin() end
end)
createButton(list, "Dwarf", function()
    if state.dwarf then restoreScale() else applyDwarf(false) end
end)
createButton(list, "Giant Dwarf", function()
    if state.giantDwarf then restoreScale() else applyDwarf(true) end
end)
createButton(list, "Fly", function()
    if state.flying then stopFly() else startFly() end
end)
createButton(list, "Infinite Jump", function()
    setInfiniteJump(not state.infiniteJump)
end)
createButton(list, "Reset Character Effects", function()
    restoreScale()
    setSitting(false)
    stopSpin()
    stopFly()
    setInfiniteJump(false)
    notify("Character effects reset")
end)

local closeHint = Instance.new("TextLabel")
closeHint.Size = UDim2.new(1, -24, 0, 18)
closeHint.Position = UDim2.new(0, 12, 1, -22)
closeHint.BackgroundTransparency = 1
closeHint.Text = "RightShift: show/hide menu"
closeHint.TextColor3 = Color3.fromRGB(125, 125, 150)
closeHint.Font = Enum.Font.Gotham
closeHint.TextSize = 10
closeHint.Parent = main

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        state.panelVisible = not state.panelVisible
        main.Visible = state.panelVisible
    end
end)

player.CharacterAdded:Connect(function()
    resetCharacterState()
    task.wait(0.25)
    getCharacterParts()
end)

getCharacterParts()
