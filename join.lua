-- 📦 AutoJoin.lua (Simple Version)
-- Auto select team (Home/Away/Any), auto join after reset, and reset with delay

local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- UI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoJoinGUI"
gui.ResetOnSpawn = false

local function createButton(name, posY, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 160, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = text
    btn.Parent = gui
    return btn
end

local function createTextBox(name, posY, placeholder)
    local box = Instance.new("TextBox")
    box.Name = name
    box.Size = UDim2.new(0, 160, 0, 30)
    box.Position = UDim2.new(0, 20, 0, posY)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.Font = Enum.Font.SourceSans
    box.TextSize = 16
    box.Text = "5"
    box.ClearTextOnFocus = false
    box.Parent = gui
    return box
end

-- UI Elements
local ToggleBtn = createButton("Toggle", 100, "Auto Join: OFF")
local TeamBtn = createButton("Team", 140, "Team: Any")
local DelayBox = createTextBox("DelayBox", 180, "Reset Delay (sec)")

-- State
local enabled = false
local teamChoice = "Any" -- "Any", "Home", "Away"

-- Helpers
local function isLeft(x)
    local width = workspace.CurrentCamera.ViewportSize.X
    return x < width / 2
end

local function waitForInterface()
    local interface
    repeat
        interface = player:FindFirstChild("PlayerGui"):FindFirstChild("Interface")
        task.wait(0.2)
    until interface
    return interface
end

-- Core join logic
local function joinTeam()
    if not enabled then return end

    local interface = waitForInterface()
    local teamGui = interface:WaitForChild("TeamSelection", 10)
    local gameGui = interface:WaitForChild("Game", 10)
    if not teamGui or not gameGui then return end

    teamGui.Visible = true
    while not gameGui.Visible and enabled do
        local buttons = {}
        for _, btn in ipairs(teamGui:GetDescendants()) do
            if btn:IsA("ImageButton") and btn.Visible and btn.AutoButtonColor then
                local left = isLeft(btn.AbsolutePosition.X)
                if teamChoice == "Any"
                or (teamChoice == "Home" and not left)
                or (teamChoice == "Away" and left) then
                    table.insert(buttons, btn)
                end
            end
        end

        if #buttons > 0 then
            local b = buttons[math.random(1, #buttons)]
            local pos = b.AbsolutePosition + b.AbsoluteSize / 2
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end

        task.wait(math.random(5, 10) / 10)
    end

    teamGui.Visible = false

    -- Auto reset after joining
    local delay = tonumber(DelayBox.Text) or 5
    task.delay(delay, function()
        if enabled then
            player.Character:BreakJoints()
        end
    end)
end

-- Trigger after respawn
player.CharacterAdded:Connect(function()
    if enabled then task.delay(1, joinTeam) end
end)

-- UI Logic
ToggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    ToggleBtn.Text = enabled and "Auto Join: ON" or "Auto Join: OFF"
    ToggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
    if enabled and player.Character then joinTeam() end
end)

TeamBtn.MouseButton1Click:Connect(function()
    teamChoice = (teamChoice == "Any") and "Home" or (teamChoice == "Home") and "Away" or "Any"
    TeamBtn.Text = "Team: " .. teamChoice
end)