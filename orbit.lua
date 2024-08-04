-- fe player orbit made with <3 (first script) by frutiger.areo

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "OrbitGui"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.Visible = true

local textBox = Instance.new("TextBox", mainFrame)
textBox.Size = UDim2.new(0.8, 0, 0.3, 0)
textBox.Position = UDim2.new(0.1, 0, 0.1, 0)
textBox.PlaceholderText = "Enter player's display name"
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local orbitButton = Instance.new("TextButton", mainFrame)
orbitButton.Size = UDim2.new(0.8, 0, 0.3, 0)
orbitButton.Position = UDim2.new(0.1, 0, 0.5, 0)
orbitButton.Text = "Orbit"
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local stopButton = Instance.new("TextButton", mainFrame)
stopButton.Size = UDim2.new(0.8, 0, 0.3, 0)
stopButton.Position = UDim2.new(0.1, 0, 0.8, 0)
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Create the Control Frame
local controlFrame = Instance.new("Frame", screenGui)
controlFrame.Size = UDim2.new(0.1, 0, 0.3, 0)
controlFrame.Position = UDim2.new(0, 0, 0.35, 0)
controlFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlFrame.BackgroundTransparency = 0.5

local openButton = Instance.new("TextButton", controlFrame)
openButton.Size = UDim2.new(1, 0, 0.25, 0)
openButton.Position = UDim2.new(0, 0, 0, 0)
openButton.Text = "Open"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local closeButton = Instance.new("TextButton", controlFrame)
closeButton.Size = UDim2.new(1, 0, 0.25, 0)
closeButton.Position = UDim2.new(0, 0, 0.25, 0)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local destroyButton = Instance.new("TextButton", controlFrame)
destroyButton.Size = UDim2.new(1, 0, 0.25, 0)
destroyButton.Position = UDim2.new(0, 0, 0.5, 0)
destroyButton.Text = "Destroy"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- configurable variables
local orbiting = false
local radius = 10
local heightOffset = 5
local speed = 1
local angle = 0
local updateConnection
local targetPlayer
local targetHumanoidRootPart
local cooldownTime = 3.5

local function playNotificationSound()
    local notifSound = Instance.new("Sound", Workspace)
    notifSound.PlaybackSpeed = 1.5
    notifSound.Volume = 0.15
    notifSound.SoundId = "rbxassetid://170765130"
    notifSound.PlayOnRemove = true
    notifSound:Destroy()
end

local function showNotification(title, text, icon, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = icon,
        Duration = duration,
        Button1 = "Okay"
    })
end

local function startOrbit(targetName)
    targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetHumanoidRootPart = targetPlayer.Character.HumanoidRootPart
        orbiting = true
        updateConnection = RunService.Heartbeat:Connect(function()
            if orbiting and targetHumanoidRootPart then
                local char = player.Character or player.CharacterAdded:Wait()
                local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local targetPosition = targetHumanoidRootPart.Position
                    local fixedY = targetPosition.Y - heightOffset
                    angle = angle + speed
                    local x = math.cos(math.rad(angle)) * radius
                    local z = math.sin(math.rad(angle)) * radius
                    humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(x, fixedY, z), targetPosition)
                end
            end
        end)

        playNotificationSound()
        showNotification("PlayerOrbit", "PlayerOrbit started successfully!", "rbxassetid://505845268", 5)

        targetPlayer.AncestryChanged:Connect(function(_, parent)
            if not parent then
                stopOrbit()
            end
        end)
    else
        showNotification("Error", "Player not found or character is missing HumanoidRootPart.", "rbxassetid://505845268", 5)
    end
end

local function stopOrbit()
    if orbiting then
        orbiting = false
        if updateConnection then
            updateConnection:Disconnect()
        end
        showNotification("PlayerOrbit", "PlayerOrbit stopped.", "rbxassetid://505845268", 5)
    end
end

local function onPlayerReset()
    if orbiting then
        stopOrbit()
        wait(cooldownTime)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            startOrbit(targetPlayer.Name)
        end
    end
end

orbitButton.MouseButton1Click:Connect(function()
    local playerName = textBox.Text
    if playerName ~= "" then
        startOrbit(playerName)
    else
        showNotification("Error", "Please enter a player's display name.", "rbxassetid://505845268", 5)
    end
end)

stopButton.MouseButton1Click:Connect(function()
    stopOrbit()
end)

openButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

player.CharacterAdded:Connect(onPlayerReset)
