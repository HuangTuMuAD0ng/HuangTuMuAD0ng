-- 📦 AutoJoin.lua (Fixed loop: Home -> reset -> Away -> wait match end -> reset -> repeat)
-- DelayBox: thời gian đợi trận đấu kết thúc sau khi vào Away

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

local ToggleBtn = createButton("Toggle", 100, "Auto Join: OFF")
local TeamBtn = createButton("Team", 140, "Team: Any")
local SwitchBtn = createButton("Switch", 180, "Auto Switch: OFF") -- giữ nguyên nếu sau này cần mở rộng
local DelayBox = createTextBox("DelayBox", 220, "Match End Delay (sec)")

-- State
local enabled = false
local currentTeam = nil -- "Home" / "Away" / nil

-- Helpers
local function isLeft(x)
    local width = workspace.CurrentCamera.ViewportSize.X
    return x < width / 2
end

local function waitForInterface()
    local interface
    repeat
        interface = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Interface")
        task.wait(0.2)
    until interface or not enabled
    return interface
end

-- Chọn team cụ thể: "Home" hoặc "Away"
local function pickTeam(target)
    if not enabled then return false end
    local interface = waitForInterface()
    if not interface then return false end
    local teamGui = interface:WaitForChild("TeamSelection", 10)
    local gameGui = interface:WaitForChild("Game", 10)
    if not teamGui or not gameGui then return false end

    teamGui.Visible = true

    while not gameGui.Visible and enabled do
        local candidates = {}
        for _, btn in ipairs(teamGui:GetDescendants()) do
            if btn:IsA("ImageButton") and btn.Visible and btn.AutoButtonColor then
                local left = isLeft(btn.AbsolutePosition.X)
                if (target == "Home" and not left) or (target == "Away" and left) then
                    table.insert(candidates, {btn = btn, isLeft = left})
                end
            end
        end

        if #candidates > 0 then
            local pick = candidates[math.random(1, #candidates)]
            local b = pick.btn
            local pos = b.AbsolutePosition + b.AbsoluteSize / 2
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)

            if pick.isLeft then
                currentTeam = "Away"
            else
                currentTeam = "Home"
            end
            TeamBtn.Text = "Team: " .. currentTeam
        end

        task.wait(math.random(5, 10) / 10)
    end

    teamGui.Visible = false
    return gameGui.Visible
end

-- Một vòng: Home -> reset -> Away -> chờ -> reset
local function doCycle()
    -- 1. Vào Home
    pickTeam("Home")
    if not enabled then return end

    -- 2. Reset để về chọn team
    wait(2)
    if player.Character then
        player.Character:BreakJoints()
    end

    -- đợi respawn + interface ổn định
    repeat task.wait(0.2) until player.Character or not enabled
    task.wait(1)
    if not enabled then return end

    -- 3. Vào Away
    pickTeam("Away")
    if not enabled then return end

    -- 4. Chờ trận đấu kết thúc theo delay (DelayBox)
    local waitTime = tonumber(DelayBox.Text) or 5
    task.wait(waitTime)
    if not enabled then return end

    -- 5. Reset để quay về Home (bắt đầu chu trình lại)
    wait(2)
    if player.Character then
        player.Character:BreakJoints()
    end

    -- chuẩn bị cho vòng sau
    repeat task.wait(0.2) until player.Character or not enabled
    task.wait(1)
end

-- Vòng lặp chính
local function mainLoop()
    while enabled do
        doCycle()
        task.wait(0.5)
    end
end

-- UI Logic
ToggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    ToggleBtn.Text = enabled and "Auto Join: ON" or "Auto Join: OFF"
    ToggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
    if enabled then
        currentTeam = nil
        task.spawn(mainLoop)
    end
end)

TeamBtn.MouseButton1Click:Connect(function()
    -- override thủ công nếu muốn: đổi giữa Home/Away/Any
    if currentTeam == "Home" then
        currentTeam = "Away"
    elseif currentTeam == "Away" then
        currentTeam = "Home"
    else
        currentTeam = "Home"
    end
    TeamBtn.Text = "Team: " .. currentTeam
end)

SwitchBtn.MouseButton1Click:Connect(function()
    -- hiện tại không ảnh hưởng flow chính, giữ để mở rộng
    local on = SwitchBtn.Text:find("ON")
    if on then
        SwitchBtn.Text = "Auto Switch: OFF"
        SwitchBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    else
        SwitchBtn.Text = "Auto Switch: ON"
        SwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

-- Bỏ đi auto trigger từ CharacterAdded để khỏi xung đột (nếu muốn giữ thì phải guard lại)
