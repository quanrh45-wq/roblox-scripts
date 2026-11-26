local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Thay bằng Asset ID ảnh của bạn trên Roblox (ví dụ: "rbxassetid://1234567890")
local BACKGROUND_IMAGE_ID = "rbxassetid://0"

local oldGui = playerGui:FindFirstChild("TrexEggGUI")
if oldGui then
	oldGui:Destroy()
end

local Config = {
	AutoStealEgg = false,
	AutoReturnBase = true,
	SpeedHack = false,
	WalkSpeed = 80,
	MinSpeedReq = 40,      -- Tốc độ yêu cầu tối thiểu để cho phép chạy tới
	MaxTravelSec = 6.0      -- Thời gian chạy tối đa cho phép (giây)
}

local RarityRank = {
	common = 1,
	uncommon = 2,
	rare = 3,
	epic = 4,
	legendary = 5,
	mythic = 6,
	secret = 7,
	cosmic = 8,
	trex = 9,
	divine = 10
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrexEggGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- NÚT TRÒN THU NHỎ
local miniBtn = Instance.new("ImageButton")
miniBtn.Name = "MiniTrexButton"
miniBtn.Size = UDim2.new(0, 58, 0, 58)
miniBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
miniBtn.BackgroundColor3 = Color3.fromRGB(235, 130, 35)
miniBtn.Image = BACKGROUND_IMAGE_ID
miniBtn.ScaleType = Enum.ScaleType.Crop
miniBtn.Active = true
miniBtn.Draggable = true
miniBtn.Visible = false
miniBtn.ZIndex = 20
miniBtn.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(75, 42, 24)
miniStroke.Thickness = 3.5
miniStroke.Parent = miniBtn

-- KHUNG CHÍNH
local mainFrame = Instance.new("Frame")
mainFrame.Name = "TrexMainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 265)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -132)
mainFrame.BackgroundColor3 = Color3.fromRGB(68, 165, 245)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 36, 18)
mainStroke.Thickness = 3.5
mainStroke.Parent = mainFrame

local bgImg = Instance.new("ImageLabel")
bgImg.Size = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image = BACKGROUND_IMAGE_ID
bgImg.ImageTransparency = 0.72
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ZIndex = 3
bgImg.Parent = mainFrame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 14)
bgCorner.Parent = bgImg

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -44, 0, 24)
titleText.Position = UDim2.new(0, 12, 0, 6)
titleText.BackgroundTransparency = 1
titleText.Text = "TREX EGG SMART STEAL"
titleText.TextColor3 = Color3.fromRGB(255, 85, 55)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 17
titleText.ZIndex = 6
titleText.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(20, 20, 20)
titleStroke.Thickness = 2.5
titleStroke.Parent = titleText

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -24, 0, 18)
statusText.Position = UDim2.new(0, 12, 0, 28)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Chờ bật Auto Steal"
statusText.TextColor3 = Color3.fromRGB(115, 255, 115)
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 12
statusText.ZIndex = 6
statusText.Parent = mainFrame

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(15, 45, 15)
statusStroke.Thickness = 2
statusStroke.Parent = statusText

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 35)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.ZIndex = 8
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local function makeInput(yPos, labelStr, defaultVal, widthScale)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(widthScale or 1, -24, 0, 32)
	box.Position = UDim2.new(0, 12, 0, yPos)
	box.BackgroundColor3 = Color3.fromRGB(255, 246, 232)
	box.PlaceholderText = labelStr
	box.PlaceholderColor3 = Color3.fromRGB(115, 85, 65)
	box.Text = tostring(defaultVal)
	box.TextColor3 = Color3.fromRGB(40, 22, 10)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 12
	box.ZIndex = 6
	box.Parent = mainFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = box

	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(75, 42, 24)
	s.Thickness = 2
	s.Parent = box
	return box
end

-- Hàng 1: Speed chạy & Speed tối thiểu yêu cầu
local speedBox = makeInput(52, "WalkSpeed (16-1000)", Config.WalkSpeed, 0.5)
speedBox.Size = UDim2.new(0.5, -16, 0, 32)

local minSpeedBox = makeInput(52, "Min Speed Req", Config.MinSpeedReq, 0.5)
minSpeedBox.Position = UDim2.new(0.5, 4, 0, 52)
minSpeedBox.Size = UDim2.new(0.5, -16, 0, 32)

-- Hàng 2: Thời gian chạy tối đa (giây)
local maxSecBox = makeInput(90, "Max Travel Sec (VD: 6)", Config.MaxTravelSec, 1)

-- Hàng 3: Nút Speed & Nút Auto Steal
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.48, -14, 0, 36)
speedBtn.Position = UDim2.new(0, 12, 0, 130)
speedBtn.BackgroundColor3 = Color3.fromRGB(235, 120, 25)
speedBtn.Text = "SPEED: OFF"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Font = Enum.Font.GothamBlack
speedBtn.TextSize = 12
speedBtn.ZIndex = 6
speedBtn.Parent = mainFrame

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 8)
sCorner.Parent = speedBtn

local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(0.52, -14, 0, 36)
stealBtn.Position = UDim2.new(0.48, 2, 0, 130)
stealBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 55)
stealBtn.Text = "AUTO STEAL: OFF"
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.Font = Enum.Font.GothamBlack
stealBtn.TextSize = 12
stealBtn.ZIndex = 6
stealBtn.Parent = mainFrame

local eCorner = Instance.new("UICorner")
eCorner.CornerRadius = UDim.new(0, 8)
eCorner.Parent = stealBtn

-- Hàng 4: Nút Tự trả về Base sau khi lấy trứng
local returnBtn = Instance.new("TextButton")
returnBtn.Size = UDim2.new(1, -24, 0, 34)
returnBtn.Position = UDim2.new(0, 12, 0, 174)
returnBtn.BackgroundColor3 = Color3.fromRGB(115, 62, 32)
returnBtn.Text = "RETURN BASE AFTER STEAL: ON"
returnBtn.TextColor3 = Color3.fromRGB(255, 235, 190)
returnBtn.Font = Enum.Font.GothamBlack
returnBtn.TextSize = 12
returnBtn.ZIndex = 6
returnBtn.Parent = mainFrame

local rCorner = Instance.new("UICorner")
rCorner.CornerRadius = UDim.new(0, 8)
rCorner.Parent = returnBtn

-- Ghi nhớ vị trí Base ban đầu của người chơi nếu không tìm thấy Base riêng
local savedHomeCFrame = nil

local function getRoot()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function syncInputs()
	local w = tonumber(speedBox.Text)
	if w then Config.WalkSpeed = math.clamp(w, 16, 1000) end

	local m = tonumber(minSpeedBox.Text)
	if m then Config.MinSpeedReq = math.max(1, m) end

	local t = tonumber(maxSecBox.Text)
	if t then Config.MaxTravelSec = math.clamp(t, 0.5, 60) end
end

speedBtn.MouseButton1Click:Connect(function()
	syncInputs()
	Config.SpeedHack = not Config.SpeedHack
	if Config.SpeedHack then
		speedBtn.Text = "SPEED: ON (" .. Config.WalkSpeed .. ")"
		speedBtn.BackgroundColor3 = Color3.fromRGB(255, 155, 30)
	else
		speedBtn.Text = "SPEED: OFF"
		speedBtn.BackgroundColor3 = Color3.fromRGB(235, 120, 25)
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = 16 end
	end
end)

returnBtn.MouseButton1Click:Connect(function()
	Config.AutoReturnBase = not Config.AutoReturnBase
	returnBtn.Text = "RETURN BASE AFTER STEAL: " .. (Config.AutoReturnBase and "ON" or "OFF")
	returnBtn.BackgroundColor3 = Config.AutoReturnBase and Color3.fromRGB(115, 62, 32) or Color3.fromRGB(65, 65, 75)
end)

RunService.Heartbeat:Connect(function()
	if Config.SpeedHack then
		local hum = getHumanoid()
		if hum and hum.WalkSpeed ~= Config.WalkSpeed then
			hum.WalkSpeed = Config.WalkSpeed
		end
	end
end)

-- TÍNH ĐIỂM ĐỘ XỊN CỦA TRỨNG
local function getEggRarityScore(obj)
	local bestRank = 1
	local bonusValue = 0

	local function scanText(txt)
		if type(txt) ~= "string" then return end
		local low = string.lower(txt)
		for key, rank in pairs(RarityRank) do
			if string.find(low, key, 1, true) then
				if rank > bestRank then bestRank = rank end
			end
		end
		-- Bắt số kiểu 89,121 hoặc 500k / 10m nếu có
		for numStr in string.gmatch(low, "[%d%.]+") do
			local n = tonumber(numStr)
			if n then
				if string.find(low, "sp") or string.find(low, "t") or string.find(low, "b") then
					bonusValue = math.max(bonusValue, math.log10(n + 10) * 8)
				elseif string.find(low, "m") then
					bonusValue = math.max(bonusValue, math.log10(n + 10) * 5)
				elseif string.find(low, "k") then
					bonusValue = math.max(bonusValue, math.log10(n + 10) * 3)
				else
					bonusValue = math.max(bonusValue, math.log10(n + 10))
				end
			end
		end
	end

	scanText(obj.Name)
	if obj.Parent then scanText(obj.Parent.Name) end

	for _, attrVal in pairs(obj:GetAttributes()) do
		if type(attrVal) == "string" then
			scanText(attrVal)
		elseif type(attrVal) == "number" then
			bonusValue = bonusValue + math.log10(math.abs(attrVal) + 10)
		end
	end

	for _, child in ipairs(obj:GetDescendants()) do
		if child:IsA("StringValue") then
			scanText(child.Value)
		elseif child:IsA("NumberValue") or child:IsA("IntValue") then
			bonusValue = bonusValue + math.log10(math.abs(child.Value) + 10)
		elseif child:IsA("TextLabel") then
			scanText(child.Text)
		end
	end

	return (bestRank * 100) + bonusValue
end

local function findBestReachableEgg()
	local root = getRoot()
	local hum = getHumanoid()
	if not root or not hum then return nil, "Thiếu nhân vật" end

	local currentSpeed = hum.WalkSpeed
	if currentSpeed < Config.MinSpeedReq then
		return nil, "Tốc độ " .. math.floor(currentSpeed) .. " < Req " .. Config.MinSpeedReq
	end

	local bestEgg = nil
	local bestScore = -math.huge
	local skippedFar = 0

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "egg") and obj.Position.Y > -50 then
			-- Tránh chọn mấy part nhỏ/phụ nếu model có part chính lớn hơn
			local dist = (obj.Position - root.Position).Magnitude
			if dist > 2 then
				local estimatedSec = dist / math.max(currentSpeed, 1)
				if estimatedSec <= Config.MaxTravelSec then
					-- Ưu tiên trứng xịn nhất, trừ nhẹ theo thời gian chạy
					local score = getEggRarityScore(obj) - (estimatedSec * 12)
					if score > bestScore then
						bestScore = score
						bestEgg = obj
					end
				else
					skippedFar += 1
				end
			end
		end
	end

	if not bestEgg then
		if skippedFar > 0 then
			return nil, "Bỏ qua " .. skippedFar .. " trứng do chạy quá " .. Config.MaxTravelSec .. "s"
		end
		return nil, "Không thấy trứng phù hợp"
	end

	return bestEgg, "OK"
end

local function triggerPromptNear(part)
	if not part then return end
	for _, v in ipairs(part:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			fireproximityprompt(v)
			return
		end
	end
	if part.Parent then
		for _, v in ipairs(part.Parent:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				fireproximityprompt(v)
				return
			end
		end
	end
end

local function findBasePosition()
	local root = getRoot()
	local pName = string.lower(player.Name)
	local dName = string.lower(player.DisplayName)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local low = string.lower(obj.Name)
			local hasOwner = string.find(low, pName, 1, true) or string.find(low, dName, 1, true)
			if hasOwner and (string.find(low, "base") or string.find(low, "plot") or string.find(low, "home") or string.find(low, "place")) then
				return obj.Position + Vector3.new(0, 3.5, 0)
			end
		end
	end

	if savedHomeCFrame then
		return savedHomeCFrame.Position + Vector3.new(0, 1, 0)
	end
	return root and root.Position
end

-- CHẠY BẰNG HUMANOID:MoveTo VÀ KIỂM TRA TỐC ĐỘ/THỜI GIAN
local function runToPositionWithCheck(targetPos, label)
	local root = getRoot()
	local hum = getHumanoid()
	if not root or not hum or not targetPos then return false end

	syncInputs()
	if hum.WalkSpeed < Config.MinSpeedReq then
		statusText.Text = "Dừng: Speed < " .. Config.MinSpeedReq
		return false
	end

	local dist = (targetPos - root.Position).Magnitude
	local expectedSec = dist / math.max(hum.WalkSpeed, 1)
	if expectedSec > Config.MaxTravelSec then
		statusText.Text = "Bỏ qua (" .. label .. "): cần " .. string.format("%.1fs", expectedSec)
		return false
	end

	statusText.Text = label .. " (" .. string.format("%.1fs", expectedSec) .. ")"
	local elapsed = 0
	local reached = false

	local conn
	conn = hum.MoveToFinished:Connect(function(ok)
		reached = ok
	end)

	while Config.AutoStealEgg and elapsed < Config.MaxTravelSec do
		root = getRoot()
		hum = getHumanoid()
		if not root or not hum then break end

		-- Nếu giữa đường tốc độ bị tụt dưới mức yêu cầu thì dừng chạy ngay
		if hum.WalkSpeed < Config.MinSpeedReq then
			statusText.Text = "Tụt speed dưới mức yêu cầu -> Dừng"
			break
		end

		if (targetPos - root.Position).Magnitude <= 4.5 or reached then
			if conn then conn:Disconnect() end
			return true
		end

		hum:MoveTo(targetPos)
		local dt = task.wait(0.15)
		elapsed += dt
	end

	if conn then conn:Disconnect() end
	return (getRoot() and (targetPos - getRoot().Position).Magnitude <= 5) or false
end

local busyStealing = false

stealBtn.MouseButton1Click:Connect(function()
	syncInputs()
	local root = getRoot()
	if root and not savedHomeCFrame then
		savedHomeCFrame = root.CFrame
	end

	Config.AutoStealEgg = not Config.AutoStealEgg
	if Config.AutoStealEgg then
		stealBtn.Text = "AUTO STEAL: ON"
		stealBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 75)
		statusText.Text = "Status: Đang tìm trứng xịn..."
	else
		stealBtn.Text = "AUTO STEAL: OFF"
		stealBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 55)
		statusText.Text = "Status: Đã tắt Auto Steal"
	end
end)

task.spawn(function()
	while true do
		task.wait(0.3)
		if Config.AutoStealEgg and not busyStealing then
			busyStealing = true
			local eggPart, reason = findBestReachableEgg()
			if eggPart then
				local okReach = runToPositionWithCheck(eggPart.Position + Vector3.new(0, 1.5, 0), "Chạy lấy trứng xịn")
				if okReach and Config.AutoStealEgg then
					statusText.Text = "Đang nhặt trứng..."
					for _ = 1, 4 do
						triggerPromptNear(eggPart)
						task.wait(0.15)
					end

					if Config.AutoReturnBase and Config.AutoStealEgg then
						local basePos = findBasePosition()
						runToPositionWithCheck(basePos, "Chạy về Base")
					end
				end
			else
				statusText.Text = reason
			end
			busyStealing = false
		end
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
	miniBtn.Visible = false
	mainFrame.Visible = true
end)
