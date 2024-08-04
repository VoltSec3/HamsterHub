-- revolve around player made with <3 by frutiger.areo

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = playerGui:FindFirstChild("CustomUI")

if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomUI"
    screenGui.Parent = playerGui
end

local frame = screenGui:FindFirstChild("MainFrame")
if not frame then
    frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.Parent = screenGui
end

local targetTextBox = frame:FindFirstChild("TargetTextBox")
if not targetTextBox then
    targetTextBox = Instance.new("TextBox")
    targetTextBox.Name = "TargetTextBox"
    targetTextBox.Size = UDim2.new(1, -20, 0, 40)
    targetTextBox.Position = UDim2.new(0, 10, 0, 10)
    targetTextBox.PlaceholderText = "Enter target username"
    targetTextBox.Parent = frame
end

local startButton = frame:FindFirstChild("StartButton")
if not startButton then
    startButton = Instance.new("TextButton")
    startButton.Name = "StartButton"
    startButton.Size = UDim2.new(1, -20, 0, 40)
    startButton.Position = UDim2.new(0, 10, 0, 60)
    startButton.Text = "Start"
    startButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    startButton.Parent = frame
end

local stopButton = frame:FindFirstChild("StopButton")
if not stopButton then
    stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(1, -20, 0, 40)
    stopButton.Position = UDim2.new(0, 10, 0, 110)
    stopButton.Text = "Stop"
    stopButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    stopButton.Parent = frame
end

local isDragging = false
local dragStart = Vector2.new()
local startPos = UDim2.new()

local function updatePosition(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updatePosition(input)
    end
end)

local targetPlayerName = nil
local connection = nil

local function rotateAndSpin(targetPlayer)
    local radius = 10
    local speed = 10
    local spinSpeed = 20

    local function addSpin()
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        for _, v in pairs(rootPart:GetChildren()) do
            if v.Name == "Spinning" then
                v:Destroy()
            end
        end

        local spin = Instance.new("BodyAngularVelocity")
        spin.Name = "Spinning"
        spin.Parent = rootPart
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
    end

    addSpin()

    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            local angle = tick() * speed
            local x = targetPosition.X + radius * math.cos(angle)
            local z = targetPosition.Z + radius * math.sin(angle)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, targetPosition.Y, z)
            else
                connection:Disconnect()
            end
        else
            connection:Disconnect()
        end
    end)
    LocalPlayer.CharacterRemoving:Connect(function()
        stopSpinning()
    end)
end

local function startSpinning()
    targetPlayerName = targetTextBox.Text
    if targetPlayerName and targetPlayerName ~= "" then
        local targetPlayer = Players:FindFirstChild(targetPlayerName)
        if targetPlayer then
            rotateAndSpin(targetPlayer)
        else
            warn("Target player not found")
        end
    else
        warn("Please enter a valid target username")
    end
end

local function stopSpinning()
    if connection then
        connection:Disconnect()
    end
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end
startButton.MouseButton1Click:Connect(startSpinning)
stopButton.MouseButton1Click:Connect(stopSpinning)
