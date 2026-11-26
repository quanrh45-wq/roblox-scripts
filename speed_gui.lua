local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SolixStealEggExactGUI") then
	playerGui.SolixStealEggExactGUI:Destroy()
end

-- CẤU HÌNH Y HỆT ẢNH SOLIX HUB
local Config = {
	AutoFarmEgg = false,
	SmartTween = false,
	DistantEggTarget = false,
	TweenSpeed = 537,
	AutoPlaceEgg = false,
	InstantPlace = false,
	Godmode = false,
	NightFarmSync = false,
	IgnoreFriends = false,
	AutoRecoverEgg = true,

	FarmMinRarity = "None",
	MinEggKg = 0,
	SpawnSniperMinRarity = "Secret",
	SnipeMinRarity = "Cosmic",
	SelectedEgg = "...",
	SelectedRarity = "...",
	SelectedArea = "..."
}

local RarityRank = {
	["..."] = 0,
	["None"] = 0,
	["All"] = 0,
	["Common"] = 1,
	["Uncommon"] = 2,
	["Rare"] = 3,
	["Epic"] = 4,
	["Legendary"] = 5,
	["Mythic"] = 6,
	["Secret"] = 7,
	["Cosmic"] = 8,
	["Trex"] = 9,
	["Divine"] = 10
}

local RarityOptions = {"None", "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Cosmic"}
local SelectRarityOptions = {"...", "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Cosmic"}
local SelectEggOptions = {"...", "Trex Egg", "Dino Egg", "Secret Egg", "Cosmic Egg"}
local SelectAreaOptions = {"...", "Conveyor", "Base", "Arena"}

local myBaseCFrame = nil
local lastStolenEggPos = nil
local isBusyAction = false

task.spawn(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart", 8)
	if root and not myBaseCFrame then
		myBaseCFrame = root.CFrame
	end
end)

local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function isFriendObject(inst)
	if not Config.IgnoreFriends then return false end
	local cur = inst
	for _ = 1, 6 do
		if not cur or cur == Workspace then break end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and player:IsFriendsWith(plr.UserId) then
				local low = string.lower(cur.Name)
				if string.find(low, string.lower(plr.Name), 1, true) or string.find(low, string.lower(plr.DisplayName), 1, true) then
					return true
				end
			end
		end
		cur = cur.Parent
	end
	return false
end

local BlockedKeywords = {
	"treadmill", "machine", "gym", "workout", "exercise", "bench",
	"fence", "wall", "floor", "decor", "shop", "index", "leaderboard", "sign"
}

local function isBlockedProp(inst)
	local cur = inst
	for _ = 1, 5 do
		if not cur or cur == Workspace then break end
		local low = string.lower(cur.Name)
		for _, kw in ipairs(BlockedKeywords) do
			if string.find(low, kw, 1, true) then
				return true
			end
		end
		cur = cur.Parent
	end
	return false
end

local function getBaseTargetPos()
	local pName = string.lower(player.Name)
	local dName = string.lower(player.DisplayName)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local low = string.lower(obj.Name)
			local parentLow = obj.Parent and string.lower(obj.Parent.Name) or ""
			local matchesOwner = string.find(low, pName, 1, true) or string.find(low, dName, 1, true)
				or string.find(parentLow, pName, 1, true) or string.find(parentLow, dName, 1, true)
			if matchesOwner and (string.find(low, "base") or string.find(low, "plot") or string.find(low, "home") or string.find(low, "place") or string.find(low, "pad")) then
				return obj.Position + Vector3.new(0, 3, 0)
			end
		end
	end

	if myBaseCFrame then
		return myBaseCFrame.Position + Vector3.new(0, 2, 0)
	end
	local r = getRoot()
	return r and r.Position
end

-- =========================================================================
-- GIAO DIỆN Y HỆT ẢNH SOLIX HUB
-- =========================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SolixStealEggExactGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Nút mở lại khi thu nhỏ
local reopenBtn = Instance.new("TextButton")
reopenBtn.Name = "ReopenSolix"
reopenBtn.Size = UDim2.new(0, 96, 0, 28)
reopenBtn.Position = UDim2.new(0.03, 0, 0.2, 0)
reopenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
reopenBtn.Text = "solixhub.com"
reopenBtn.TextColor3 = Color3.fromRGB(235, 55, 115)
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.TextSize = 11
reopenBtn.Active = true
reopenBtn.Draggable = true
reopenBtn.Visible = false
reopenBtn.ZIndex = 30
reopenBtn.Parent = screenGui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 6)
reopenCorner.Parent = reopenBtn

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(235, 55, 115)
reopenStroke.Thickness = 1.5
reopenStroke.Parent = reopenBtn

-- Khung chính
local mainHub = Instance.new("Frame")
mainHub.Name = "SolixMainHub"
mainHub.Size = UDim2.new(0, 630, 0, 330)
mainHub.Position = UDim2.new(0.5, -315, 0.5, -165)
mainHub.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
mainHub.BorderSizePixel = 0
mainHub.Active = true
mainHub.Draggable = true
mainHub.ZIndex = 2
mainHub.Parent = screenGui

local hubCorner = Instance.new("UICorner")
hubCorner.CornerRadius = UDim.new(0, 6)
hubCorner.Parent = mainHub

local hubStroke = Instance.new("UIStroke")
hubStroke.Color = Color3.fromRGB(40, 40, 48)
hubStroke.Thickness = 1.5
hubStroke.Parent = mainHub

-- Top Bar: solixhub.com | Search.. | X
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BorderSizePixel = 0
topBar.ZIndex = 5
topBar.Parent = mainHub

local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, 20, 1, 0)
logoIcon.Position = UDim2.new(0, 10, 0, 0)
logoIcon.BackgroundTransparency = 1
logoIcon.Text = "S"
logoIcon.TextColor3 = Color3.fromRGB(235, 55, 115)
logoIcon.Font = Enum.Font.GothamBlack
logoIcon.TextSize = 14
logoIcon.ZIndex = 6
logoIcon.Parent = topBar

local brandLbl = Instance.new("TextLabel")
brandLbl.Size = UDim2.new(0, 105, 1, 0)
brandLbl.Position = UDim2.new(0, 30, 0, 0)
brandLbl.BackgroundTransparency = 1
brandLbl.Text = "solixhub.com"
brandLbl.TextColor3 = Color3.fromRGB(235, 235, 242)
brandLbl.TextXAlignment = Enum.TextXAlignment.Left
brandLbl.Font = Enum.Font.GothamBold
brandLbl.TextSize = 12
brandLbl.ZIndex = 6
brandLbl.Parent = topBar

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(0, 250, 0, 22)
searchBar.Position = UDim2.new(0, 148, 0.5, -11)
searchBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
searchBar.PlaceholderText = "Search.."
searchBar.PlaceholderColor3 = Color3.fromRGB(125, 125, 138)
searchBar.Text = ""
searchBar.TextColor3 = Color3.fromRGB(235, 235, 242)
searchBar.TextXAlignment = Enum.TextXAlignment.Left
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 11
searchBar.ClearTextOnFocus = false
searchBar.ZIndex = 6
searchBar.Parent = topBar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingLeft = UDim.new(0, 10)
sbPad.Parent = searchBar

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 4)
sbCorner.Parent = searchBar

local xCloseBtn = Instance.new("TextButton")
xCloseBtn.Size = UDim2.new(0, 26, 0, 26)
xCloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
xCloseBtn.BackgroundTransparency = 1
xCloseBtn.Text = "X"
xCloseBtn.TextColor3 = Color3.fromRGB(195, 195, 205)
xCloseBtn.Font = Enum.Font.GothamBold
xCloseBtn.TextSize = 13
xCloseBtn.ZIndex = 6
xCloseBtn.Parent = topBar

-- Sidebar trái
local leftNav = Instance.new("Frame")
leftNav.Size = UDim2.new(0, 134, 1, -68)
leftNav.Position = UDim2.new(0, 0, 0, 34)
leftNav.BackgroundColor3 = Color3.fromRGB(19, 19, 23)
leftNav.BorderSizePixel = 0
leftNav.ZIndex = 5
leftNav.Parent = mainHub

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 2)
navList.Parent = leftNav

local navPad = Instance.new("UIPadding")
navPad.PaddingTop = UDim.new(0, 6)
navPad.PaddingLeft = UDim.new(0, 6)
navPad.PaddingRight = UDim.new(0, 6)
navPad.Parent = leftNav

-- Footer trái: solixhub / Steal An Egg
local leftFooter = Instance.new("Frame")
leftFooter.Size = UDim2.new(0, 134, 0, 34)
leftFooter.Position = UDim2.new(0, 0, 1, -34)
leftFooter.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
leftFooter.BorderSizePixel = 0
leftFooter.ZIndex = 7
leftFooter.Parent = mainHub

local fTitle = Instance.new("TextLabel")
fTitle.Size = UDim2.new(1, -12, 0, 15)
fTitle.Position = UDim2.new(0, 10, 0, 3)
fTitle.BackgroundTransparency = 1
fTitle.Text = "solixhub"
fTitle.TextColor3 = Color3.fromRGB(235, 55, 115)
fTitle.TextXAlignment = Enum.TextXAlignment.Left
fTitle.Font = Enum.Font.GothamBold
fTitle.TextSize = 11
fTitle.ZIndex = 8
fTitle.Parent = leftFooter

local fSub = Instance.new("TextLabel")
fSub.Size = UDim2.new(1, -12, 0, 14)
fSub.Position = UDim2.new(0, 10, 0, 17)
fSub.BackgroundTransparency = 1
fSub.Text = "Steal An Egg"
fSub.TextColor3 = Color3.fromRGB(150, 150, 165)
fSub.TextXAlignment = Enum.TextXAlignment.Left
fSub.Font = Enum.Font.Gotham
fSub.TextSize = 10
fSub.ZIndex = 8
fSub.Parent = leftFooter

-- Vùng nội dung chính
local rightWorkspace = Instance.new("Frame")
rightWorkspace.Size = UDim2.new(1, -134, 1, -34)
rightWorkspace.Position = UDim2.new(0, 134, 0, 34)
rightWorkspace.BackgroundTransparency = 1
rightWorkspace.ZIndex = 5
rightWorkspace.Parent = mainHub

-- Sub-tabs: Farm | Economy | Combat | Programs
local subTabsFrame = Instance.new("Frame")
subTabsFrame.Size = UDim2.new(1, -16, 0, 26)
subTabsFrame.Position = UDim2.new(0, 10, 0, 4)
subTabsFrame.BackgroundTransparency = 1
subTabsFrame.ZIndex = 6
subTabsFrame.Parent = rightWorkspace

local subTabsLayout = Instance.new("UIListLayout")
subTabsLayout.FillDirection = Enum.FillDirection.Horizontal
subTabsLayout.Padding = UDim.new(0, 20)
subTabsLayout.Parent = subTabsFrame

local subTabBtns = {}
local activeSubTab = "Farm"

for _, sName in ipairs({"Farm", "Economy", "Combat", "Programs"}) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = sName
	btn.TextColor3 = (sName == activeSubTab) and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(130, 130, 145)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = (sName == activeSubTab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.ZIndex = 7
	btn.Parent = subTabsFrame
	subTabBtns[sName] = btn

	btn.MouseButton1Click:Connect(function()
		activeSubTab = sName
		for k, b in pairs(subTabBtns) do
			local on = (k == sName)
			b.TextColor3 = on and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(130, 130, 145)
			b.Font = on and Enum.Font.GothamBold or Enum.Font.GothamMedium
		end
	end)
end

-- Khung 2 cột trong Main
local twoColHolder = Instance.new("Frame")
twoColHolder.Size = UDim2.new(1, -12, 1, -34)
twoColHolder.Position = UDim2.new(0, 6, 0, 30)
twoColHolder.BackgroundTransparency = 1
twoColHolder.ZIndex = 6
twoColHolder.Parent = rightWorkspace

local leftScroll = Instance.new("ScrollingFrame")
leftScroll.Size = UDim2.new(0.53, -4, 1, -2)
leftScroll.Position = UDim2.new(0, 2, 0, 0)
leftScroll.BackgroundColor3 = Color3.fromRGB(21, 21, 26)
leftScroll.BorderSizePixel = 0
leftScroll.ScrollBarThickness = 3
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 360)
leftScroll.ZIndex = 7
leftScroll.Parent = twoColHolder

local lsCorner = Instance.new("UICorner")
lsCorner.CornerRadius = UDim.new(0, 6)
lsCorner.Parent = leftScroll

local lsList = Instance.new("UIListLayout")
lsList.Padding = UDim.new(0, 4)
lsList.Parent = leftScroll

local lsPad = Instance.new("UIPadding")
lsPad.PaddingTop = UDim.new(0, 6)
lsPad.PaddingLeft = UDim.new(0, 8)
lsPad.PaddingRight = UDim.new(0, 8)
lsPad.Parent = leftScroll

local rightScroll = Instance.new("ScrollingFrame")
rightScroll.Size = UDim2.new(0.47, -4, 1, -2)
rightScroll.Position = UDim2.new(0.53, 4, 0, 0)
rightScroll.BackgroundColor3 = Color3.fromRGB(21, 21, 26)
rightScroll.BorderSizePixel = 0
rightScroll.ScrollBarThickness = 3
rightScroll.CanvasSize = UDim2.new(0, 0, 0, 360)
rightScroll.ZIndex = 7
rightScroll.Parent = twoColHolder

local rsCorner = Instance.new("UICorner")
rsCorner.CornerRadius = UDim.new(0, 6)
rsCorner.Parent = rightScroll

local rsList = Instance.new("UIListLayout")
rsList.Padding = UDim.new(0, 5)
rsList.Parent = rightScroll

local rsPad = Instance.new("UIPadding")
rsPad.PaddingTop = UDim.new(0, 6)
rsPad.PaddingLeft = UDim.new(0, 8)
rsPad.PaddingRight = UDim.new(0, 8)
rsPad.Parent = rightScroll

-- Điều hướng Sidebar
local navItems = {"Manager", "Main", "Prediction", "Misc", "Visuals", "Webhook", "Settings"}
local navButtons = {}

for _, name in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 26)
	btn.BackgroundColor3 = (name == "Main") and Color3.fromRGB(36, 20, 30) or Color3.fromRGB(19, 19, 23)
	btn.BorderSizePixel = 0
	btn.Text = "   " .. name
	btn.TextColor3 = (name == "Main") and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(150, 150, 165)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = (name == "Main") and Enum.Font.GothamBold or Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.ZIndex = 6
	btn.Parent = leftNav

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = btn

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Size = UDim2.new(0, 2, 0.72, 0)
	bar.Position = UDim2.new(0, 0, 0.14, 0)
	bar.BackgroundColor3 = Color3.fromRGB(235, 55, 115)
	bar.BorderSizePixel = 0
	bar.Visible = (name == "Main")
	bar.ZIndex = 7
	bar.Parent = btn

	navButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		for k, b in pairs(navButtons) do
			local active = (k == name)
			b.BackgroundColor3 = active and Color3.fromRGB(36, 20, 30) or Color3.fromRGB(19, 19, 23)
			b.TextColor3 = active and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(150, 150, 165)
			b.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
			local ind = b:FindFirstChild("Bar")
			if ind then ind.Visible = active end
		end
	end)
end

-- Header Auto Farm Egg (có mũi tên đỏ/hồng bên phải)
local farmHeader = Instance.new("Frame")
farmHeader.Size = UDim2.new(1, 0, 0, 22)
farmHeader.BackgroundTransparency = 1
farmHeader.ZIndex = 8
farmHeader.Parent = leftScroll

local farmTitleLbl = Instance.new("TextLabel")
farmTitleLbl.Size = UDim2.new(0.8, 0, 1, 0)
farmTitleLbl.BackgroundTransparency = 1
farmTitleLbl.Text = "Auto Farm Egg"
farmTitleLbl.TextColor3 = Color3.fromRGB(242, 242, 248)
farmTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
farmTitleLbl.Font = Enum.Font.GothamBold
farmTitleLbl.TextSize = 12
farmTitleLbl.ZIndex = 9
farmTitleLbl.Parent = farmHeader

local farmArrowLbl = Instance.new("TextLabel")
farmArrowLbl.Size = UDim2.new(0.2, 0, 1, 0)
farmArrowLbl.Position = UDim2.new(0.8, 0, 0, 0)
farmArrowLbl.BackgroundTransparency = 1
farmArrowLbl.Text = "v"
farmArrowLbl.TextColor3 = Color3.fromRGB(235, 55, 115)
farmArrowLbl.TextXAlignment = Enum.TextXAlignment.Right
farmArrowLbl.Font = Enum.Font.GothamBold
farmArrowLbl.TextSize = 12
farmArrowLbl.ZIndex = 9
farmArrowLbl.Parent = farmHeader

local searchableList = {}
local toggleSetters = {}

local function makeExactToggle(labelText, initialValue, onToggle)
	local row = Instance.new("Frame")
	row.Name = labelText
	row.Size = UDim2.new(1, 0, 0, 23)
	row.BackgroundTransparency = 1
	row.ZIndex = 8
	row.Parent = leftScroll

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.76, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = initialValue and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(205, 205, 218)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = initialValue and Enum.Font.GothamBold or Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.ZIndex = 9
	lbl.Parent = row

	local pill = Instance.new("TextButton")
	pill.Size = UDim2.new(0, 32, 0, 16)
	pill.Position = UDim2.new(1, -34, 0.5, -8)
	pill.BackgroundColor3 = initialValue and Color3.fromRGB(235, 55, 115) or Color3.fromRGB(52, 52, 62)
	pill.Text = ""
	pill.ZIndex = 9
	pill.Parent = row

	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(1, 0)
	pc.Parent = pill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = initialValue and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 10
	knob.Parent = pill

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local currentState = initialValue

	local function applyVisual(st)
		currentState = st
		pill.BackgroundColor3 = st and Color3.fromRGB(235, 55, 115) or Color3.fromRGB(52, 52, 62)
		lbl.TextColor3 = st and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(205, 205, 218)
		lbl.Font = st and Enum.Font.GothamBold or Enum.Font.Gotham
		knob:TweenPosition(
			st and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.12,
			true
		)
	end

	pill.MouseButton1Click:Connect(function()
		applyVisual(not currentState)
		onToggle(currentState)
	end)

	toggleSetters[labelText] = function(st)
		applyVisual(st)
		onToggle(st)
	end

	table.insert(searchableList, row)
	return row
end

-- Tạo các toggle đúng thứ tự ảnh
makeExactToggle("Auto Farm Egg", Config.AutoFarmEgg, function(v)
	Config.AutoFarmEgg = v
	local r = getRoot()
	if v and r and not myBaseCFrame then
		myBaseCFrame = r.CFrame
	end
end)

makeExactToggle("Smart Tween", Config.SmartTween, function(v)
	Config.SmartTween = v
end)

makeExactToggle("Distant Egg Target", Config.DistantEggTarget, function(v)
	Config.DistantEggTarget = v
end)

-- Thanh trượt Tween Speed: 537 studs/s (y hệt ảnh)
local speedSliderRow = Instance.new("Frame")
speedSliderRow.Name = "Tween Speed"
speedSliderRow.Size = UDim2.new(1, 0, 0, 22)
speedSliderRow.BackgroundTransparency = 1
speedSliderRow.ZIndex = 8
speedSliderRow.Parent = leftScroll
table.insert(searchableList, speedSliderRow)

local barBtn = Instance.new("TextButton")
barBtn.Size = UDim2.new(0.67, 0, 0, 17)
barBtn.Position = UDim2.new(0, 0, 0.5, -8)
barBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
barBtn.Text = ""
barBtn.AutoButtonColor = false
barBtn.ZIndex = 9
barBtn.Parent = speedSliderRow

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 4)
barCorner.Parent = barBtn

local fillBar = Instance.new("Frame")
fillBar.Size = UDim2.new(Config.TweenSpeed / 1000, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(235, 55, 115)
fillBar.BorderSizePixel = 0
fillBar.ZIndex = 10
fillBar.Parent = barBtn

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 4)
fillCorner.Parent = fillBar

local barLbl = Instance.new("TextLabel")
barLbl.Size = UDim2.new(1, -6, 1, 0)
barLbl.Position = UDim2.new(0, 6, 0, 0)
barLbl.BackgroundTransparency = 1
barLbl.Text = "Tween Speed: " .. Config.TweenSpeed .. " studs/s"
barLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
barLbl.TextXAlignment = Enum.TextXAlignment.Left
barLbl.Font = Enum.Font.GothamBold
barLbl.TextSize = 10
barLbl.ZIndex = 11
barLbl.Parent = barBtn

local sideSpeedLbl = Instance.new("TextLabel")
sideSpeedLbl.Size = UDim2.new(0.32, 0, 1, 0)
sideSpeedLbl.Position = UDim2.new(0.68, 0, 0, 0)
sideSpeedLbl.BackgroundTransparency = 1
sideSpeedLbl.Text = Config.TweenSpeed .. " studs/s"
sideSpeedLbl.TextColor3 = Color3.fromRGB(205, 205, 218)
sideSpeedLbl.TextXAlignment = Enum.TextXAlignment.Right
sideSpeedLbl.Font = Enum.Font.Gotham
sideSpeedLbl.TextSize = 10
sideSpeedLbl.ZIndex = 9
sideSpeedLbl.Parent = speedSliderRow

local sliding = false
local function setTweenSpeedFromPos(xPos)
	local rat
