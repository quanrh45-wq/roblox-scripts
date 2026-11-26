local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Xóa GUI cũ nếu lỡ chạy đè nhiều lần
if playerGui:FindFirstChild("SpeedScriptGUI") then
	playerGui.SpeedScriptGUI:Destroy()
end

-- Thay dãy số này bằng Asset ID ảnh của bạn trên Roblox (ví dụ: "rbxassetid://1234567890")
local BACKGROUND_IMAGE_ID = "rbxassetid://0"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedScriptGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- 1. KHUNG CHÍNH (FRAME)
local mainFrame = Instance.new("FrameBắt được bệnh ngay rồi! Nhìn ảnh chụp thì khung chính và nút **X** đỏ vẫn lên bình thường, chỉ bị đen xì toàn bộ ruột bên trong[cite: 8] — đây là lỗi đè lớp hiển thị (`ZIndex`) trong Roblox UI.

Cụ thể là cái lớp phủ tối `darkOverlay` của tao đang để `ZIndex = 2` (hoặc trên một số máy/executor, `ZIndexBehavior` mặc định khiến `darkOverlay` đè lên trên cả ô nhập số, nút `START`, nút `STOP` và tô đen đặc toàn bộ khung).

### Bản code đã fix lỗi đen xì
Tao đã gỡ hẳn lớp `darkOverlay` gây che nút và nâng `ZIndex = 10` cho toàn bộ ô nhập số, nút `START`, `STOP`, `X` để luôn nổi lên trên cùng. Mày copy đè toàn bộ đoạn dưới đây vào file `speed_gui.lua` trên GitHub:

```lua
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Thay dãy số này bằng Asset ID ảnh của bạn trên Roblox (ví dụ: "rbxassetid://1234567890")
local BACKGROUND_IMAGE_ID = "rbxassetid://0"

-- Xóa bản GUI cũ nếu chạy lại script để tránh chồng đè
local oldGui = playerGui:FindFirstChild("SpeedScriptGUI")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedScriptGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- 1. KHUNG CHÍNH (FRAME)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 180)
mainFrame.Position = UDim2.new(0.5, -120, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.Color = Color3.fromRGB(0, 0, 0)
mainStroke.Parent = mainFrame

-- Ảnh nền khung chính (chỉ hiện khi có Asset ID khác 0)
local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundImage"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = BACKGROUND_IMAGE_ID
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 2
bgImage.Parent = mainFrame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 12)
bgCorner.Parent = bgImage

-- 2. NÚT HÌNH TRÒN THU NHỎ (HIỆN KHI BẤM DẤU X)
local miniCircleButton = Instance.new("ImageButton")
miniCircleButton.Name = "MiniCircleButton"
miniCircleButton.Size = UDim2.new(0, 56, 0, 56)
miniCircleButton.Position = UDim2.new(0.5, -28, 0.4, -28)
miniCircleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
miniCircleButton.Image = BACKGROUND_IMAGE_ID
miniCircleButton.ScaleType = Enum.ScaleType.Crop
miniCircleButton.BorderSizePixel = 0
miniCircleButton.Active = true
miniCircleButton.Draggable = true
miniCircleButton.Visible = false
miniCircleButton.ZIndex = 10
miniCircleButton.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniCircleButton

local miniStroke = Instance.new("UIStroke")
miniStroke.Thickness = 3
miniStroke.Color = Color3.fromRGB(160, 60, 255)
miniStroke.Parent = miniCircleButton

-- 3. NÚT ĐÓNG / THU NHỎ ("X")
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -14, 0, -14)
closeButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 70, 70)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0
closeButton.ZIndex = 15
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 2
closeStroke.Color = Color3.fromRGB(255, 70, 70)
closeStroke.Parent = closeButton

-- 4. Ô NHẬP TỐC ĐỘ
local textBox = Instance.new("TextBox")
textBox.Name = "SpeedInput"
textBox.Size = UDim2.new(0, 200, 0, 45)
textBox.Position = UDim2.new(0.5, -100, 0, 22)
textBox.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
textBox.BorderSizePixel = 0
textBox.PlaceholderText = "Nhập speed (16-1000)"
textBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.Font = Enum.Font.SourceSansBold
textBox.TextSize = 18
textBox.ZIndex = 10
textBox.Parent = mainFrame

local textCorner = Instance.new("UICorner")
textCorner.CornerRadius = UDim.new(0, 8)
textCorner.Parent = textBox

local textStroke = Instance.new("UIStroke")
textStroke.Thickness = 2
textStroke.Color = Color3.fromRGB(0, 0, 0)
textStroke.Parent = textBox

-- 5. NÚT START
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0, 95, 0, 42)
startButton.Position = UDim2.new(0, 20, 0, 112)
startButton.BackgroundColor3 = Color3.fromRGB(20, 165, 65)
startButton.Text = "START"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 18
startButton.BorderSizePixel = 0
startButton.ZIndex = 10
startButton.Parent = mainFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startButton

local startStroke = Instance.new("UIStroke")
startStroke.Thickness = 2
startStroke.Color = Color3.fromRGB(0, 0, 0)
startStroke.Parent = startButton

-- 6. NÚT STOP
local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 95, 0, 42)
stopButton.Position = UDim2.new(1, -115, 0, 112)
stopButton.BackgroundColor3 = Color3.fromRGB(210, 35, 35)
stopButton.Text = "STOP"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 18
stopButton.BorderSizePixel = 0
stopButton.ZIndex = 10
stopButton.Parent = mainFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

local stopStroke = Instance.new("UIStroke")
stopStroke.Thickness = 2
stopStroke.Color = Color3.fromRGB(0, 0, 0)
stopStroke.Parent = stopButton

-- LOGIC TỐC ĐỘ & THU NHỎ / MỞ LẠI
local originalSpeed = 16
local isSpeedEnabled = false

local function setWalkSpeed(speed)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

startButton.MouseButton1Click:Connect(function()
	local value = tonumber(textBox.Text)
	if value then
		if value < 16 then value = 16 end
		if value > 1000 then value = 1000 end
		isSpeedEnabled = true
		setWalkSpeed(value)
	else
		textBox.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
		task.wait(0.2)
		textBox.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	end
end)

stopButton.MouseButton1Click:Connect(function()
	isSpeedEnabled = false
	setWalkSpeed(originalSpeed)
end)

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	if isSpeedEnabled then
		local value = tonumber(textBox.Text) or originalSpeed
		setWalkSpeed(value)
	else
		setWalkSpeed(originalSpeed)
	end
end)

-- Bấm X -> Ẩn bảng chính, hiện nút hình tròn
closeButton.MouseButton1Click:Connect(function()
	miniCircleButton.Position = UDim2.new(
		mainFrame.Position.X.Scale,
		mainFrame.Position.X.Offset + (mainFrame.Size.X.Offset / 2) - 28,
		mainFrame.Position.Y.Scale,
		mainFrame.Position.Y.Offset + (mainFrame.Size.Y.Offset / 2) - 28
	)
	mainFrame.Visible = false
	miniCircleButton.Visible = true
end)

-- Bấm nút hình tròn -> Mở lại bảng chính
miniCircleButton.MouseButton1Click:Connect(function()
	miniCircleButton.Visible = false
	mainFrame.Visible = true
end)
