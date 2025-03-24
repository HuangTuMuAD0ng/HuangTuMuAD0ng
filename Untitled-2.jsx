local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Đường dẫn file config
local configFilePath = "order_config.json"

-- Tạo GUI Chính
local MainScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ServerTimeLabel = Instance.new("TextLabel")
local OrderLabel = Instance.new("TextLabel")
local PlayerNameLabel = Instance.new("TextLabel")
local ClearButton = Instance.new("TextButton")
local UICornerMain = Instance.new("UICorner")
local LogoImage = Instance.new("ImageLabel") -- Thêm logo

-- GUI chính
MainScreenGui.Parent = player:WaitForChild("PlayerGui")
MainScreenGui.Enabled = true

-- MainFrame (nền đen mờ, nhỏ gọn, sát mép trên màn hình)
MainFrame.Size = UDim2.new(0, 400, 0, 80) -- Kích thước nhỏ
MainFrame.Position = UDim2.new(0.5, -200, 0, 10) -- Sát mép trên màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Nền đen
MainFrame.BackgroundTransparency = 0.4 -- Độ mờ
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainScreenGui

UICornerMain.CornerRadius = UDim.new(0, 10) -- Bo góc
UICornerMain.Parent = MainFrame

-- Thêm logo bên phải GUI chính
LogoImage.Size = UDim2.new(0, 40, 0, 40) -- Kích thước nhỏ hơn
LogoImage.Position = UDim2.new(1, -50, 0.5, -20) -- Canh bên phải, giữa chiều dọc
LogoImage.BackgroundTransparency = 1 -- Không có nền
LogoImage.Image = "rbxassetid://6031094677" -- Asset ID của logo
LogoImage.Parent = MainFrame

-- Bộ đếm thời gian chạy script
ServerTimeLabel.Text = "Thời gian chạy: 00:00"
ServerTimeLabel.Size = UDim2.new(1, -50, 0.2, 0)
ServerTimeLabel.Position = UDim2.new(0, 0, 0.1, 0)
ServerTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerTimeLabel.Font = Enum.Font.Roboto
ServerTimeLabel.TextScaled = true
ServerTimeLabel.BackgroundTransparency = 1
ServerTimeLabel.Parent = MainFrame

local injectStartTime = os.time()
spawn(function()
    while true do
        local elapsedTime = os.time() - injectStartTime
        local minutes = math.floor(elapsedTime / 60)
        local seconds = elapsedTime % 60
        ServerTimeLabel.Text = string.format("Thời gian chạy: %02d:%02d", minutes, seconds)
        wait(1)
    end
end)

-- Hiển thị đơn hàng
OrderLabel.Text = "Đơn hàng: [Trống]"
OrderLabel.Size = UDim2.new(1, -50, 0.2, 0) -- Điều chỉnh kích thước để tránh đè lên logo
OrderLabel.Position = UDim2.new(0, 0, 0.35, 0)
OrderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OrderLabel.Font = Enum.Font.Roboto
OrderLabel.TextScaled = true
OrderLabel.BackgroundTransparency = 1
OrderLabel.Parent = MainFrame

-- Hiển thị tên người chơi (ẩn 4 ký tự cuối)
local username = player.Name
local visibleUsername = string.sub(username, 1, #username - 4) .. "****"
PlayerNameLabel.Text = "Tên người chơi: " .. visibleUsername
PlayerNameLabel.Size = UDim2.new(1, -50, 0.2, 0) -- Điều chỉnh để tránh logo
PlayerNameLabel.Position = UDim2.new(0, 0, 0.6, 0)
PlayerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerNameLabel.Font = Enum.Font.Roboto
PlayerNameLabel.TextScaled = true
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Parent = MainFrame

-- Nút xóa đơn hàng (15% kích thước UI, nằm góc dưới bên phải)
ClearButton.Size = UDim2.new(0.15, 0, 0.4, 0) -- 15% kích thước UI (chiều rộng)
ClearButton.Position = UDim2.new(0.85, 0, 0.6, 0) -- Góc dưới cùng bên phải
ClearButton.Text = "Xóa"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.TextScaled = true
ClearButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ClearButton.Parent = MainFrame

ClearButton.MouseButton1Click:Connect(function()
    if isfile(configFilePath) then
        delfile(configFilePath)
    end
    OrderLabel.Text = "Đơn hàng: [Trống]"
end)

-- Load đơn hàng từ file config hoặc hiển thị UI nhập liệu
if isfile(configFilePath) then
    local configContent = readfile(configFilePath)
    local configData = HttpService:JSONDecode(configContent)
    if configData.order then
        OrderLabel.Text = "Đơn hàng: " .. configData.order
    end
else
    -- Tạo UI nhập đơn hàng
    local InputFrame = Instance.new("Frame")
    local OrderInputBox = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local UICornerInput = Instance.new("UICorner")

    InputFrame.Size = UDim2.new(0, 350, 0, 60)
    InputFrame.Position = UDim2.new(0.5, -175, 0.7, 0)
    InputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    InputFrame.BackgroundTransparency = 0.5
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = MainScreenGui

    UICornerInput.CornerRadius = UDim.new(0, 10)
    UICornerInput.Parent = InputFrame

    OrderInputBox.Size = UDim2.new(0.7, 0, 0.8, 0)
    OrderInputBox.Position = UDim2.new(0.05, 0, 0.1, 0)
    OrderInputBox.PlaceholderText = "Nhập đơn hàng..."
    OrderInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    OrderInputBox.Font = Enum.Font.Roboto
    OrderInputBox.TextScaled = true
    OrderInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OrderInputBox.Parent = InputFrame

    SubmitButton.Size = UDim2.new(0.2, 0, 0.8, 0)
    SubmitButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    SubmitButton.Text = "Xác nhận"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.TextScaled = true
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 128, 0)
    SubmitButton.Parent = InputFrame

    SubmitButton.MouseButton1Click:Connect(function()
        local newOrder = OrderInputBox.Text
        if newOrder ~= "" then
            OrderLabel.Text = "Đơn hàng: " .. newOrder
            writefile(configFilePath, HttpService:JSONEncode({ order = newOrder }))
            InputFrame:Destroy()
        end
    end)
end
