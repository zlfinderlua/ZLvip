--[[
	ZLFinder
    joIN FOR PEAK FREE SOURCES:

]]

local Players = game:GetService("Players")
--discord.gg/rNvAU6cjVB
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
--discord.gg/rNvAU6cjVB
-- ============================================================
-- Small helpers
-- ============================================================

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

-- Makes `frame` draggable by clicking and holding `handle`.
-- `handle` defaults to `frame` itself if not provided.
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragInput, startPos, startFramePos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = input.Position
			startFramePos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - startPos
			frame.Position = UDim2.new(
				startFramePos.X.Scale,
				startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale,
				startFramePos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Resets a panel back to its default centred position so every
-- open starts from the same spot regardless of where it was dragged.
local DEFAULT_PANEL_POSITION = UDim2.new(0.5, -140, 0.5, -160)
local function resetToCenter(frame)
	frame.Position = DEFAULT_PANEL_POSITION
end

-- ============================================================
-- Asset / data helpers
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lazily-loaded module references (pcall so missing modules don't crash)
local Mutations, Traits, BaseSkins, Gears, AssetCache

local function loadModules()
	local ok

	ok, Mutations = pcall(function()
		return require(ReplicatedStorage.Datas.Mutations)
	end)
	if not ok then Mutations = {} end

	ok, Traits = pcall(function()
		return require(ReplicatedStorage.Datas.Traits)
	end)
	if not ok then Traits = {} end

	ok, BaseSkins = pcall(function()
		return require(ReplicatedStorage.Shared.BaseSkins)
	end)
	if not ok then BaseSkins = nil end

	ok, Gears = pcall(function()
		return require(ReplicatedStorage.Shared.Gears)
	end)
	if not ok then Gears = nil end

	ok, AssetCache = pcall(function()
		return ReplicatedStorage.Controllers.AssetStreamController.AssetCache
	end)
	if not ok then AssetCache = nil end
end

pcall(loadModules)

-- Returns Color3 for a mutation name, or nil if unknown.
local function getMutationColor(mutationName)
	if not mutationName or mutationName == "None" or mutationName == "" then return nil end
	local data = Mutations[mutationName]
	if data and data.MainColor then
		return data.MainColor
	end
	return nil
end

-- Returns a rbxassetid string for an animal, or nil.
local function getAnimalImageId(animalName)
	-- 1. Try AssetStreamController cache (3D assets have an image id stored)
	if AssetCache then
		local ok, result = pcall(function() return AssetCache[animalName] end)
		if ok and result then
			local imgId = result.ImageId or result.ThumbnailId or result.Icon
			if imgId then return tostring(imgId) end
		end
	end

	-- 2. Try BaseSkins
	if BaseSkins then
		local ok, id = pcall(function() return BaseSkins.GetImage(animalName) end)
		if ok and id then return tostring(id) end
	end

	-- 3. Try Gears
	if Gears then
		local ok, id = pcall(function() return Gears.GetImage(animalName) end)
		if ok and id then return tostring(id) end
	end

	return nil
end

-- Returns the trait icon asset id string, or nil.
local function getTraitIcon(traitName)
	local data = Traits[traitName]
	if data and data.Icon then return tostring(data.Icon) end
	return nil
end

-- ============================================================
-- ESP â€“ constants
-- ============================================================

local BLACKLIST = {
	"animalpodiums", "decorations", "invisiblewalls", "laser", "laserhitbox",
	"purchases", "skin", "unlock", "cash", "friendpanel", "animaltarget",
	"deliveryhitbox", "mainroot", "multiplier", "plotsign", "slope", "spawn",
	"stealthitbox", "root", "hitbox", "model", "part", "floor", "wall",
	"path", "grass", "barrier"
}

local function isBlacklisted(name)
	local ln = string.lower(name)
	for _, bl in ipairs(BLACKLIST) do
		if bl == "model" or bl == "part" then
			if ln == bl then return true end
		elseif string.find(ln, bl) then
			return true
		end
	end
	return false
end

-- ============================================================
-- ESP â€“ mutation / trait database
-- ============================================================

local emojiMutations = {
	["strawberry"] = {n="Strawberry"},
	["meowl"]      = {n="Meowl"},
	["lightning"]  = {n="Lightning"},
	["firework"]   = {n="Fireworks"},
	["nyan"]       = {n="Nyan"},
	["jack o"]     = {n="Jack O Lantern"},
	["reindeer"]   = {n="Reindeer"},
	["paint"]      = {n="Paint"},
	["fire"]       = {n="Fire"},
	["indonesian"] = {n="Indonesian"},
	["sombrero"]   = {n="Sombrero"},
	["rap"]        = {n="Rap Concert"},
	["tung"]       = {n="Tung Tung Attack"},
	["glitch"]     = {n="Glitched"},
	["crab"]       = {n="Crab"},
	["tie"]        = {n="Tie"},
	["tombstone"]  = {n="RIP Tombstone"},
	["matteo"]     = {n="Matteo Hat"},
	["witch"]      = {n="Witching Hour"},
	["10b"]        = {n="10B"},
	["explosive"]  = {n="Explosive"},
	["galactic"]   = {n="Galactic"},
	["extinct"]    = {n="REX"},
	["bubblegum"]  = {n="Bubblegum"},
	["spider"]     = {n="Spider"},
	["comet"]      = {n="Comet Struck"},
	["snow"]       = {n="Snowy"},
	["taco"]       = {n="Taco"},
	["ufo"]        = {n="UFO"},
	["rain"]       = {n="Rain"},
	["sleepy"]     = {n="Sleepy"},
	["chocolate"]  = {n="Chocolate"},
	["26"]         = {n="26"},
	["halo"]       = {n="Halo"},
	["lucky"]      = {n="Lucky"},
	["bunny"]      = {n="Bunny Ears"},
	["santa"]      = {n="Santa Hat"},
	["skeleton"]   = {n="Skeleton"},
	["balloon"]    = {n="Balloon"},
	["egg"]        = {n="Egg"},
	[":3"]         = {n=":3"},
	["shark fin"]  = {n="Shark Fin"},
	["brazil"]     = {n="Brazil"},
	["granny"]     = {n="Granny"},
	["rose"]       = {n="Rose"},
	["disco"]      = {n="Disco"},
	["zombie"]     = {n="Zombie"},
	["wet"]        = {n="Wet"},
}

-- ============================================================
-- ESP â€“ money/s text extractor
-- ============================================================

local function getMoneyText(item)
	local bestMatch = nil
	local fallback  = nil

	local primary = item:IsA("Model") and item.PrimaryPart
		or (item:IsA("BasePart") and item)
		or item:FindFirstChildWhichIsA("BasePart", true)

	local closestDistBest     = 10
	local closestDistFallback = 10

	local function checkGui(bb, dist)
		for _, tl in ipairs(bb:GetDescendants()) do
			if (tl:IsA("TextLabel") or tl:IsA("TextButton") or tl:IsA("TextBox"))
				and tl.Text ~= "" then
				local txt = string.lower(tl.Text)
				if string.find(tl.Text, "%$") and string.find(txt, "/s") then
					if dist <= closestDistBest then
						closestDistBest = dist
						bestMatch = tl.Text
					end
				elseif string.find(tl.Text, "%$") then
					if dist <= closestDistFallback then
						closestDistFallback = dist
						fallback = tl.Text
					end
				end
			end
		end
	end

	checkGui(item, 0)

	for _, bb in ipairs(workspace:GetDescendants()) do
		if bb:IsA("BillboardGui") or bb:IsA("SurfaceGui") then
			local adornee = bb.Adornee
			if adornee and (adornee == item or adornee:IsDescendantOf(item)) then
				checkGui(bb, 0)
			elseif primary and bb.Parent and bb.Parent:IsA("BasePart") then
				local dist = (bb.Parent.Position - primary.Position).Magnitude
				if dist <= closestDistBest or dist <= closestDistFallback then
					checkGui(bb, dist)
				end
			end
		end
	end

	local pgui = localPlayer:FindFirstChild("PlayerGui")
	if pgui then
		for _, bb in ipairs(pgui:GetDescendants()) do
			if bb:IsA("BillboardGui") or bb:IsA("SurfaceGui") then
				local adornee = bb.Adornee
				if adornee and (adornee == item or adornee:IsDescendantOf(item)) then
					checkGui(bb, 0)
				end
			end
		end
	end

	if bestMatch then return bestMatch end
	if fallback  then return fallback  end

	local keywords = {"prod","sec","money","cash","coin","income","yield","rate","amount","value","give"}
	for name, value in pairs(item:GetAttributes()) do
		local n = string.lower(name)
		for _, k in ipairs(keywords) do
			if string.find(n, k) then return "$" .. tostring(value) .. "/s" end
		end
	end
	for _, val in ipairs(item:GetDescendants()) do
		if val:IsA("ValueBase") then
			local n = string.lower(val.Name)
			for _, k in ipairs(keywords) do
				if string.find(n, k) then return "$" .. tostring(val.Value) .. "/s" end
			end
		end
	end

	return "Calcul en cours..."
end

-- ============================================================
-- ESP â€“ trait scanner (returns comma-separated string)
-- ============================================================

local function getTraitsFromItem(item)
	local found    = {}
	local seenName = {}

	local function isWordInString(str, word)
		if type(str) ~= "string" then return false end
		local s = string.lower(str)
		local w = string.lower(word)
		if w == ":3" then return string.find(s, ":3", 1, true) ~= nil end
		local safeW = string.gsub(w, "([%-%^%$%(%)%%%.%[%]%*%+%?])", "%%%1")
		return string.find(s, "%f[%w]" .. safeW .. "%f[%W]") ~= nil
	end

	local function checkString(str)
		for k, data in pairs(emojiMutations) do
			if isWordInString(str, k) and not seenName[data.n] then
				seenName[data.n] = true
				table.insert(found, data.n)
			end
		end
	end

	for _, val in ipairs(item:GetDescendants()) do
		if val:IsA("ValueBase") or val:IsA("BillboardGui") or val:IsA("SurfaceGui") then
			checkString(val.Name)
		end
		if val:IsA("StringValue") then
			checkString(val.Value)
		elseif val:IsA("BoolValue") and val.Value == true then
			checkString(val.Name)
		end
	end
	for name, val in pairs(item:GetAttributes()) do
		checkString(name)
		if type(val) == "string" then checkString(val) end
	end

	return #found > 0 and table.concat(found, ", ") or "None"
end

-- ============================================================
-- ESP â€“ animation helper
-- ============================================================

local function playModelAnimation(model, animName)
	pcall(function()
		if not model or not model:IsA("Model") then return end
		local anims   = ReplicatedStorage:FindFirstChild("Animations")
		if not anims  then return end
		local animals = anims:FindFirstChild("Animals")
		if not animals then return end
		local targetAnim = animals:FindFirstChild(animName)
		if not targetAnim then return end

		local animationToPlay = nil
		if targetAnim:IsA("Animation") then
			animationToPlay = targetAnim
		elseif targetAnim:IsA("Folder") or targetAnim:IsA("Model") then
			animationToPlay = targetAnim:FindFirstChild("Idle")
				or targetAnim:FindFirstChildWhichIsA("Animation", true)
		end
		if not animationToPlay then return end

		local controller = model:FindFirstChildWhichIsA("Humanoid")
			or model:FindFirstChildWhichIsA("AnimationController")
		if not controller then
			controller = Instance.new("AnimationController")
			controller.Parent = model
		end
		local animator = controller:FindFirstChildWhichIsA("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = controller
		end
		local track = animator:LoadAnimation(animationToPlay)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped   = true
		track:Play(0)
	end)
end

-- ============================================================
-- ESP â€“ billboard system
-- ============================================================



-- ============================================================
-- Card builder
-- ============================================================

-- config fields (all from websocket data):
--   parent, layoutOrder,
--   username        (string)
--   animalName      (string)   â€“ used for image lookup
--   animalDisplay   (string)   â€“ displayed text
--   genText         (string)   â€“ "$312.5M/s" etc.
--   mutation        (string)   â€“ "Gold", "None", â€¦
--   traits          (string)   â€“ "Taco, Sombrero, Glitched" or "None"
--   buttonText      (string)
--   buttonColor     (Color3)
--   onButtonClicked (function?)
local function createListCard(config)
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 0, 86)
	card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.LayoutOrder = config.layoutOrder
	card.Parent = config.parent
	addCorner(card, 8)

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "InfoContainer"
	infoContainer.Position = UDim2.new(0, 5, 0, 5)
	infoContainer.Size = UDim2.new(1, -10, 1, -10)
	infoContainer.BackgroundTransparency = 1
	infoContainer.Parent = card

	local infoListLayout = Instance.new("UIListLayout")
	infoListLayout.Padding = UDim.new(0, 8)
	infoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	infoListLayout.FillDirection = Enum.FillDirection.Horizontal
	infoListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoListLayout.Parent = infoContainer

	-- â”€â”€ Animal icon â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
	local iconSlot = Instance.new("Frame")
	iconSlot.Name = "IconSlot"
	iconSlot.Size = UDim2.new(0, 54, 1, 0)
	iconSlot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	iconSlot.BackgroundTransparency = 0.1
	iconSlot.LayoutOrder = 1
	iconSlot.Parent = infoContainer
	addCorner(iconSlot, 6)

	local imageId = getAnimalImageId(config.animalName)
	if imageId then
		local img = Instance.new("ImageLabel")
		img.Name = "AnimalImage"
		img.Size = UDim2.new(1, 0, 1, 0)
		img.BackgroundTransparency = 1
		img.Image = imageId:find("^rbxassetid://") and imageId or ("rbxassetid://" .. imageId)
		img.ScaleType = Enum.ScaleType.Fit
		img.Parent = iconSlot
	else
		local fallback = Instance.new("TextLabel")
		fallback.Name = "IconFallback"
		fallback.Size = UDim2.new(1, 0, 1, 0)
		fallback.BackgroundTransparency = 1
		fallback.Text = "ğŸ¾"
		fallback.TextSize = 22
		fallback.TextXAlignment = Enum.TextXAlignment.Center
		fallback.TextYAlignment = Enum.TextYAlignment.Center
		fallback.Parent = iconSlot
	end

	-- â”€â”€ Text column â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextInfoContainer"
	textContainer.Size = UDim2.new(1, -(54 + 74 + 8*3), 1, 0) -- fill remaining space
	textContainer.BackgroundTransparency = 1
	textContainer.LayoutOrder = 2
	textContainer.Parent = infoContainer

	local textListLayout = Instance.new("UIListLayout")
	textListLayout.Padding = UDim.new(0, 2)
	textListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	textListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	textListLayout.Parent = textContainer

	-- Player name (gold)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Text = config.username or "Unknown"
	nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.BackgroundTransparency = 1
	nameLabel.LayoutOrder = 1
	nameLabel.Parent = textContainer

	-- Animal name (coloured by mutation, or white)
	local mutColor = getMutationColor(config.mutation) or Color3.fromRGB(255, 255, 255)
	local animalLabel = Instance.new("TextLabel")
	animalLabel.Name = "AnimalLabel"
	animalLabel.Text = config.animalDisplay or config.animalName or "?"
	animalLabel.TextColor3 = mutColor
	animalLabel.TextSize = 11
	animalLabel.Font = Enum.Font.GothamBold
	animalLabel.TextXAlignment = Enum.TextXAlignment.Left
	animalLabel.TextTruncate = Enum.TextTruncate.AtEnd
	animalLabel.Size = UDim2.new(1, 0, 0, 16)
	animalLabel.BackgroundTransparency = 1
	animalLabel.LayoutOrder = 2
	animalLabel.Parent = textContainer

	-- Gen text (e.g. "$312.5M/s")
	local genLabel = Instance.new("TextLabel")
	genLabel.Name = "GenLabel"
	genLabel.Text = config.genText or ""
	genLabel.TextColor3 = Color3.fromRGB(100, 220, 120)
	genLabel.TextSize = 10
	genLabel.Font = Enum.Font.GothamMedium
	genLabel.TextXAlignment = Enum.TextXAlignment.Left
	genLabel.Size = UDim2.new(1, 0, 0, 14)
	genLabel.BackgroundTransparency = 1
	genLabel.LayoutOrder = 3
	genLabel.Parent = textContainer

	-- Traits row: ImageLabels if possible, text fallback
	local traitsRow = Instance.new("Frame")
	traitsRow.Name = "TraitsRow"
	traitsRow.Size = UDim2.new(1, 0, 0, 18)
	traitsRow.BackgroundTransparency = 1
	traitsRow.LayoutOrder = 4
	traitsRow.Parent = textContainer

	local traitsLayout = Instance.new("UIListLayout")
	traitsLayout.FillDirection = Enum.FillDirection.Horizontal
	traitsLayout.Padding = UDim.new(0, 3)
	traitsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	traitsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	traitsLayout.Parent = traitsRow

	local traitsStr = config.traits or "None"
	if traitsStr == "None" or traitsStr == "" then
		local noTraitLabel = Instance.new("TextLabel")
		noTraitLabel.Text = "No traits"
		noTraitLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
		noTraitLabel.TextSize = 9
		noTraitLabel.Font = Enum.Font.Gotham
		noTraitLabel.BackgroundTransparency = 1
		noTraitLabel.Size = UDim2.new(1, 0, 1, 0)
		noTraitLabel.TextXAlignment = Enum.TextXAlignment.Left
		noTraitLabel.Parent = traitsRow
	else
		local traitList = string.split(traitsStr, ", ")
		for i, traitName in ipairs(traitList) do
			traitName = traitName:match("^%s*(.-)%s*$") -- trim
			local iconId = getTraitIcon(traitName)
			if iconId then
				local img = Instance.new("ImageLabel")
				img.Name = "Trait_" .. i
				img.Size = UDim2.new(0, 18, 1, 0)
				img.BackgroundTransparency = 1
				img.Image = iconId:find("^rbxassetid://") and iconId or ("rbxassetid://" .. iconId)
				img.ScaleType = Enum.ScaleType.Fit
				img.LayoutOrder = i
				img.Parent = traitsRow
			else
				local lbl = Instance.new("TextLabel")
				lbl.Name = "Trait_" .. i
				lbl.Text = traitName
				lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
				lbl.TextSize = 8
				lbl.Font = Enum.Font.Gotham
				lbl.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				lbl.BackgroundTransparency = 0.3
				lbl.BorderSizePixel = 0
				lbl.AutomaticSize = Enum.AutomaticSize.X
				lbl.Size = UDim2.new(0, 0, 1, 0)
				lbl.TextXAlignment = Enum.TextXAlignment.Center
				lbl.LayoutOrder = i
				lbl.Parent = traitsRow
				addCorner(lbl, 3)
				local pad = Instance.new("UIPadding")
				pad.PaddingLeft = UDim.new(0, 4)
				pad.PaddingRight = UDim.new(0, 4)
				pad.Parent = lbl
			end
		end
	end

	-- â”€â”€ Action button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
	local buttonSlot = Instance.new("Frame")
	buttonSlot.Name = "ButtonSlot"
	buttonSlot.Size = UDim2.new(0, 66, 1, 0)
	buttonSlot.BackgroundTransparency = 1
	buttonSlot.LayoutOrder = 3
	buttonSlot.Parent = infoContainer

	local actionButton = Instance.new("TextButton")
	actionButton.Name = "ActionButton"
	actionButton.Text = config.buttonText
	actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionButton.TextSize = 11
	actionButton.Font = Enum.Font.GothamBold
	actionButton.Position = UDim2.new(0, 0, 0.2, 0)
	actionButton.Size = UDim2.new(1, 0, 0.6, 0)
	actionButton.BackgroundColor3 = config.buttonColor
	actionButton.BorderSizePixel = 0
	actionButton.Parent = buttonSlot
	addCorner(actionButton, 6)

	if config.onButtonClicked then
		actionButton.MouseButton1Click:Connect(config.onButtonClicked)
	end

	return card
end

-- ============================================================
-- Root ScreenGui
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZLChat"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ============================================================
-- Top bar: PvP Finder / Trade Finder / Pause buttons
-- ============================================================

local pvpFinderButton = Instance.new("TextButton")
pvpFinderButton.Name = "PvPFinderButton"
pvpFinderButton.Text = "PvP Finder"
pvpFinderButton.TextColor3 = Color3.fromRGB(255, 100, 100)
pvpFinderButton.TextSize = 14
pvpFinderButton.Font = Enum.Font.GothamBold
pvpFinderButton.Position = UDim2.new(0.5, -5, 0, 10)
pvpFinderButton.Size = UDim2.new(0, 100, 0, 39)
pvpFinderButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
pvpFinderButton.BackgroundTransparency = 0.25
pvpFinderButton.Parent = screenGui
addCorner(pvpFinderButton, 30)

local tradeFinderButton = Instance.new("TextButton")
tradeFinderButton.Name = "TradeFinderButton"
tradeFinderButton.Text = "Trade Finder"
tradeFinderButton.TextColor3 = Color3.fromRGB(100, 200, 255)
tradeFinderButton.TextSize = 14
tradeFinderButton.Font = Enum.Font.GothamBold
tradeFinderButton.Position = UDim2.new(0.5, 105, 0, 10)
tradeFinderButton.Size = UDim2.new(0, 100, 0, 39)
tradeFinderButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tradeFinderButton.BackgroundTransparency = 0.25
tradeFinderButton.Parent = screenGui
addCorner(tradeFinderButton, 30)

local pauseButton = Instance.new("TextButton")
pauseButton.Name = "PauseButton"
pauseButton.Text = "â¸"
pauseButton.TextColor3 = Color3.fromRGB(255, 215, 0)
pauseButton.TextSize = 16
pauseButton.Font = Enum.Font.GothamBold
pauseButton.Position = UDim2.new(0.5, 215, 0, 10)
pauseButton.Size = UDim2.new(0, 40, 0, 39)
pauseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
pauseButton.BackgroundTransparency = 0.25
pauseButton.Parent = screenGui
addCorner(pauseButton, 30)

-- ============================================================
-- Connection status widget
-- ============================================================

local connectionStatus = Instance.new("Frame")
connectionStatus.Name = "ConnectionStatus"
connectionStatus.Position = UDim2.new(1, -150, 0, 60)
connectionStatus.Size = UDim2.new(0, 140, 0, 26)
connectionStatus.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
connectionStatus.BackgroundTransparency = 0.2
connectionStatus.BorderSizePixel = 0
connectionStatus.ZIndex = 2000
connectionStatus.Parent = screenGui
addCorner(connectionStatus, 6)

local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Position = UDim2.new(0, 10, 0.5, -4)
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.BackgroundColor3 = Color3.fromRGB(255, 183, 3)
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 2001
statusDot.Parent = connectionStatus
addCorner(statusDot, 999)

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = "âœ… Connected"
statusLabel.TextColor3 = Color3.fromRGB(40, 167, 69)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Position = UDim2.new(0, 24, 0, 0)
statusLabel.Size = UDim2.new(1, -28, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.ZIndex = 2001
statusLabel.Parent = connectionStatus

local reconnectButton = Instance.new("TextButton")
reconnectButton.Name = "ReconnectButton"
reconnectButton.Text = "â†»"
reconnectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reconnectButton.TextSize = 12
reconnectButton.Position = UDim2.new(1, -24, 0.5, -10)
reconnectButton.Size = UDim2.new(0, 20, 0, 20)
reconnectButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
reconnectButton.BorderSizePixel = 0
reconnectButton.Visible = false
reconnectButton.ZIndex = 2001
reconnectButton.Parent = connectionStatus
addCorner(reconnectButton, 4)

-- ============================================================
-- Chat panel
-- ============================================================

local chatFrame = Instance.new("Frame")
chatFrame.Name = "ChatFrame"
chatFrame.Position = UDim2.new(0.5, -170, 0, 54)
chatFrame.Size = UDim2.new(0, 340, 0, 200)
chatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
chatFrame.BackgroundTransparency = 0.25
chatFrame.BorderSizePixel = 0
chatFrame.Visible = false
chatFrame.Parent = screenGui

local chatScrollingFrame = Instance.new("ScrollingFrame")
chatScrollingFrame.Name = "ChatScrollingFrame"
chatScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScrollingFrame.ScrollBarThickness = 3
chatScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
chatScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
chatScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
chatScrollingFrame.BackgroundTransparency = 1
chatScrollingFrame.BorderSizePixel = 0
chatScrollingFrame.Parent = chatFrame

local chatListLayout = Instance.new("UIListLayout")
chatListLayout.Padding = UDim.new(0, 3)
chatListLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
chatListLayout.Parent = chatScrollingFrame

local chatTextBox = Instance.new("TextBox")
chatTextBox.Name = "ChatTextBox"
chatTextBox.Text = ""
chatTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
chatTextBox.TextSize = 12
chatTextBox.PlaceholderText = "Message..."
chatTextBox.Position = UDim2.new(0, 5, 1, -40)
chatTextBox.Size = UDim2.new(1, -65, 0, 35)
chatTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
chatTextBox.BorderSizePixel = 0
chatTextBox.Parent = chatFrame

local sendButton = Instance.new("TextButton")
sendButton.Name = "SendButton"
sendButton.Text = "Send"
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.TextSize = 12
sendButton.Position = UDim2.new(1, -60, 1, -40)
sendButton.Size = UDim2.new(0, 55, 0, 35)
sendButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sendButton.BorderSizePixel = 0
sendButton.Parent = chatFrame

-- ============================================================
-- Whitelist Manager (shared popup used by both finders)
-- ============================================================

local whitelistManager = Instance.new("Frame")
whitelistManager.Name = "WhitelistManager"
whitelistManager.Position = UDim2.new(0.5, -140, 0.5, -160)
whitelistManager.Size = UDim2.new(0, 280, 0, 320)
whitelistManager.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
whitelistManager.BackgroundTransparency = 0.15
whitelistManager.BorderSizePixel = 0
whitelistManager.ZIndex = 2000
whitelistManager.Visible = false
whitelistManager.Parent = screenGui
addCorner(whitelistManager, 10)

local whitelistTitle = Instance.new("TextLabel")
whitelistTitle.Name = "Title"
whitelistTitle.Text = "ğŸ¾ Whitelist Manager"
whitelistTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
whitelistTitle.TextSize = 16
whitelistTitle.Font = Enum.Font.GothamBold
whitelistTitle.Size = UDim2.new(1, 0, 0, 35)
whitelistTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
whitelistTitle.BackgroundTransparency = 0.1
whitelistTitle.BorderSizePixel = 0
whitelistTitle.ZIndex = 2001
whitelistTitle.Parent = whitelistManager
addCorner(whitelistTitle, 10)

-- Make the Whitelist Manager draggable by its title bar
makeDraggable(whitelistManager, whitelistTitle)

local whitelistCloseButton = Instance.new("TextButton")
whitelistCloseButton.Name = "CloseButton"
whitelistCloseButton.Text = "X"
whitelistCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
whitelistCloseButton.TextSize = 12
whitelistCloseButton.Position = UDim2.new(1, -30, 0, 5)
whitelistCloseButton.Size = UDim2.new(0, 25, 0, 25)
whitelistCloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
whitelistCloseButton.BorderSizePixel = 0
whitelistCloseButton.ZIndex = 2002
whitelistCloseButton.Parent = whitelistManager
addCorner(whitelistCloseButton, 5)

-- Single action row: Filter / Add / Clear, sitting in the same spot
-- the original "Filter Off | Limpiar" row occupied.
local actionRow = Instance.new("Frame")
actionRow.Name = "ActionRow"
actionRow.Position = UDim2.new(0, 5, 0, 40)
actionRow.Size = UDim2.new(1, -10, 0, 30)
actionRow.BackgroundTransparency = 1
actionRow.ZIndex = 2001
actionRow.Parent = whitelistManager

local filterToggleButton = Instance.new("TextButton")
filterToggleButton.Name = "FilterToggleButton"
filterToggleButton.Text = "âœ— Filter OFF"
filterToggleButton.TextColor3 = Color3.fromRGB(220, 53, 69)
filterToggleButton.TextSize = 11
filterToggleButton.Font = Enum.Font.GothamBold
filterToggleButton.Position = UDim2.new(0, 0, 0, 0)
filterToggleButton.Size = UDim2.new(0.32, -4, 1, 0)
filterToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
filterToggleButton.BackgroundTransparency = 0.3
filterToggleButton.BorderSizePixel = 0
filterToggleButton.ZIndex = 2001
filterToggleButton.Parent = actionRow
addCorner(filterToggleButton, 5)

local addButton = Instance.new("TextButton")
addButton.Name = "AddButton"
addButton.Text = "[ Add ]"
addButton.TextColor3 = Color3.fromRGB(100, 200, 255)
addButton.TextSize = 11
addButton.Font = Enum.Font.GothamBold
addButton.Position = UDim2.new(0.34, 0, 0, 0)
addButton.Size = UDim2.new(0.32, -4, 1, 0)
addButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
addButton.BackgroundTransparency = 0.3
addButton.BorderSizePixel = 0
addButton.ZIndex = 2001
addButton.Parent = actionRow
addCorner(addButton, 5)

local clearButton = Instance.new("TextButton")
clearButton.Name = "ClearButton"
clearButton.Text = "[ Clear ]"
clearButton.TextColor3 = Color3.fromRGB(255, 100, 100)
clearButton.TextSize = 11
clearButton.Font = Enum.Font.GothamBold
clearButton.Position = UDim2.new(0.68, 0, 0, 0)
clearButton.Size = UDim2.new(0.32, -4, 1, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
clearButton.BackgroundTransparency = 0.3
clearButton.BorderSizePixel = 0
clearButton.ZIndex = 2001
clearButton.Parent = actionRow
addCorner(clearButton, 5)

local whitelistSearchBox = Instance.new("TextBox")
whitelistSearchBox.Name = "SearchBox"
whitelistSearchBox.Text = ""
whitelistSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
whitelistSearchBox.TextSize = 12
whitelistSearchBox.PlaceholderText = "ğŸ” Search animal (min 3 letters)..."
whitelistSearchBox.Position = UDim2.new(0, 5, 0, 75)
whitelistSearchBox.Size = UDim2.new(1, -10, 0, 35)
whitelistSearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
whitelistSearchBox.BackgroundTransparency = 0.3
whitelistSearchBox.BorderSizePixel = 0
whitelistSearchBox.ZIndex = 2001
whitelistSearchBox.Parent = whitelistManager
addCorner(whitelistSearchBox, 6)

local whitelistResults = Instance.new("ScrollingFrame")
whitelistResults.Name = "ResultsScrollingFrame"
whitelistResults.CanvasSize = UDim2.new(0, 0, 0, 0)
whitelistResults.ScrollBarThickness = 3
whitelistResults.ScrollingDirection = Enum.ScrollingDirection.Y
whitelistResults.Position = UDim2.new(0, 5, 0, 115)
whitelistResults.Size = UDim2.new(1, -10, 1, -130)
whitelistResults.BackgroundTransparency = 1
whitelistResults.BorderSizePixel = 0
whitelistResults.ZIndex = 2001
whitelistResults.Parent = whitelistManager

local whitelistResultsLayout = Instance.new("UIListLayout")
whitelistResultsLayout.Padding = UDim.new(0, 6)
whitelistResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
whitelistResultsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
whitelistResultsLayout.Parent = whitelistResults

Instance.new("UIPadding").Parent = whitelistResults

local whitelistEmptyMessage = Instance.new("TextLabel")
whitelistEmptyMessage.Name = "EmptyMessage"
whitelistEmptyMessage.Text = "ğŸ“‹ No animals in whitelist yet.\nğŸ” Type at least 3 letters to search..."
whitelistEmptyMessage.TextColor3 = Color3.fromRGB(150, 150, 150)
whitelistEmptyMessage.TextSize = 11
whitelistEmptyMessage.Font = Enum.Font.Gotham
whitelistEmptyMessage.TextWrapped = true
whitelistEmptyMessage.Position = UDim2.new(0, 0, 0.5, -20)
whitelistEmptyMessage.Size = UDim2.new(1, 0, 0, 40)
whitelistEmptyMessage.AnchorPoint = Vector2.new(0, 0.5)
whitelistEmptyMessage.BackgroundTransparency = 1
whitelistEmptyMessage.ZIndex = 2001
whitelistEmptyMessage.Parent = whitelistResults

-- ============================================================
-- Shared header builder for Trade Finder / PvP Finder panels
-- (both use the same crown / VIP / close / offer / filter layout)
-- ============================================================

local function createFinderPanel(titleText, accentColor)
	local panel = Instance.new("Frame")
	panel.Name = "FinderPanel"
	panel.Position = UDim2.new(0.5, -140, 0.5, -160)
	panel.Size = UDim2.new(0, 280, 0, 320)
	panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	panel.BackgroundTransparency = 0.15
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui
	addCorner(panel, 10)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = titleText
	title.TextColor3 = accentColor
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.Size = UDim2.new(1, 0, 0, 35)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	title.BackgroundTransparency = 0.1
	title.BorderSizePixel = 0
	title.Parent = panel
	addCorner(title, 10)

	-- Make the panel draggable by its title bar
	makeDraggable(panel, title)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 12
	closeButton.Position = UDim2.new(1, -30, 0, 5)
	closeButton.Size = UDim2.new(0, 25, 0, 25)
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
	closeButton.BorderSizePixel = 0
	closeButton.Parent = panel
	addCorner(closeButton, 5)

	local actionRow = Instance.new("Frame")
	actionRow.Name = "ActionRow"
	actionRow.Position = UDim2.new(0, 5, 0, 40)
	actionRow.Size = UDim2.new(1, -10, 0, 30)
	actionRow.BackgroundTransparency = 1
	actionRow.Parent = panel

	local offerButton = Instance.new("TextButton")
	offerButton.Name = "OfferButton"
	offerButton.Text = "[ Offer ]"
	offerButton.TextColor3 = accentColor
	offerButton.TextSize = 12
	offerButton.Font = Enum.Font.GothamBold
	offerButton.Size = UDim2.new(0.45, -5, 1, 0)
	offerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	offerButton.BackgroundTransparency = 0.3
	offerButton.BorderSizePixel = 0
	offerButton.Parent = actionRow
	addCorner(offerButton, 5)

	local filterButton = Instance.new("TextButton")
	filterButton.Name = "FilterButton"
	filterButton.Text = "[ Filter ]"
	filterButton.TextColor3 = Color3.fromRGB(100, 150, 255)
	filterButton.TextSize = 12
	filterButton.Font = Enum.Font.GothamBold
	filterButton.Position = UDim2.new(0.55, 0, 0, 0)
	filterButton.Size = UDim2.new(0.45, -5, 1, 0)
	filterButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	filterButton.BackgroundTransparency = 0.3
	filterButton.BorderSizePixel = 0
	filterButton.Parent = actionRow
	addCorner(filterButton, 5)

	local listScrollingFrame = Instance.new("ScrollingFrame")
	listScrollingFrame.Name = "ListScrollingFrame"
	listScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listScrollingFrame.ScrollBarThickness = 3
	listScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	listScrollingFrame.Position = UDim2.new(0, 5, 0, 75)
	listScrollingFrame.Size = UDim2.new(1, -10, 1, -80)
	listScrollingFrame.BackgroundTransparency = 1
	listScrollingFrame.BorderSizePixel = 0
	listScrollingFrame.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = listScrollingFrame

	Instance.new("UIPadding").Parent = listScrollingFrame

	return {
		panel = panel,
		closeButton = closeButton,
		offerButton = offerButton,
		filterButton = filterButton,
		listScrollingFrame = listScrollingFrame,
	}
end

-- ============================================================
-- Trade Finder panel (cards populated live from WebSocket)
-- ============================================================

local tradeFinder = createFinderPanel("ğŸ“¦ Trade Finder", Color3.fromRGB(100, 200, 255))

-- ============================================================
-- PvP Finder panel (cards populated live from WebSocket)
-- ============================================================

local PVP_RED = Color3.fromRGB(220, 53, 69)
local pvpFinder = createFinderPanel("âš”ï¸ PvP Finder", PVP_RED)

-- ============================================================
-- Live WebSocket feed
-- ============================================================

local WS_URL = "wss://zlfinder.eeuuleyenda.workers.dev/ws"

local tradeCardOrder = 0
local duelCardOrder  = 0

local function addTradeCard(data)
	tradeCardOrder -= 1  -- prepend: lower LayoutOrder = top
	createListCard({
		parent      = tradeFinder.listScrollingFrame,
		layoutOrder = tradeCardOrder,
		username    = data.username,
		animalName  = data.animal,
		animalDisplay = data.animalDisplayName or data.animal,
		genText     = data.genText or "",
		mutation    = data.mutation or "None",
		traits      = data.traits or "None",
		buttonText  = "ğŸ“¦ Trade",
		buttonColor = Color3.fromRGB(0, 150, 255),
		onButtonClicked = function()
			local TARGET_NAME = data.username
			local PlayerGui = Players.LocalPlayer.PlayerGui
			local searchBox = PlayerGui.TradePlayerList.TradePlayerList.Sections.Players.SearchFrame.SearchBox

			print("[Trade] Searching for: " .. TARGET_NAME)
			searchBox.Text = TARGET_NAME
			firesignal(searchBox.FocusLost, true)
			print("[Trade] Search fired, waiting 1.5s...")
			task.wait(1.5)

			local list = PlayerGui.TradePlayerList.TradePlayerList.Sections.Players.List
			print("[Trade] Scanning list for '" .. TARGET_NAME .. "_'...")
			local found = false
			for _, entry in ipairs(list:GetChildren()) do
				if entry.Name:lower():match("^" .. TARGET_NAME:lower() .. "_") then
					print("[Trade] Found entry: " .. entry.Name)
					local sendButton = entry:FindFirstChild("Fill") and entry.Fill:FindFirstChild("Send")
					if sendButton then
						print("[Trade] Send button found, firing signals...")
						firesignal(sendButton.MouseButton1Click)
						firesignal(sendButton.Activated)
						print("[Trade] Trade sent!")
						found = true
					else
						print("[Trade] ERROR: Send button not found inside " .. entry.Name)
					end
					break
				end
			end
			if not found then
				print("[Trade] ERROR: No list entry found matching '" .. TARGET_NAME .. "_'")
			end
		end,
	})
	-- Keep canvas size in sync
	local sf = tradeFinder.listScrollingFrame
	local layout = sf:FindFirstChildWhichIsA("UIListLayout")
	if layout then
		sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end
end

local function addDuelCard(data)
	duelCardOrder -= 1
	createListCard({
		parent      = pvpFinder.listScrollingFrame,
		layoutOrder = duelCardOrder,
		username    = data.username,
		animalName  = data.animal,
		animalDisplay = data.animalDisplayName or data.animal,
		genText     = data.genText or "",
		mutation    = data.mutation or "None",
		traits      = data.traits or "None",
		buttonText  = "âš”ï¸ Duel",
		buttonColor = PVP_RED,
		onButtonClicked = function()
			local TARGET_NAME = data.username
			local PlayerGui = Players.LocalPlayer.PlayerGui
			local duelsGui = PlayerGui.DuelsMachinePlayerList.DuelsMachinePlayerList
			local searchBox = duelsGui.SearchFrame.SearchBox
			local list = duelsGui.GlobalList

			print("[Duels] Searching for:", TARGET_NAME)
			searchBox.Text = TARGET_NAME
			firesignal(searchBox.FocusLost, true)
			print("[Duels] Waiting for results...")
			task.wait(1.5)

			local found = false
			for _, entry in ipairs(list:GetChildren()) do
				if entry.Name:lower():match("^" .. TARGET_NAME:lower() .. "_") then
					print("[Duels] Found:", entry.Name)
					local sendButton = entry:FindFirstChild("Fill") and entry.Fill:FindFirstChild("Send")
					if sendButton then
						print("[Duels] Firing Send button...")
						firesignal(sendButton.MouseButton1Click)
						firesignal(sendButton.Activated)
						print("[Duels] Invite sent!")
						found = true
					else
						warn("[Duels] Send button not found.")
					end
					break
				end
			end
			if not found then
				warn("[Duels] Player '" .. TARGET_NAME .. "' not found.")
			end
		end,
	})
	local sf = pvpFinder.listScrollingFrame
	local layout = sf:FindFirstChildWhichIsA("UIListLayout")
	if layout then
		sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end
end

-- Connection state helpers
local function setStatus(text, color, dotColor, showReconnect)
	statusLabel.Text   = text
	statusLabel.TextColor3 = color
	statusDot.BackgroundColor3 = dotColor
	reconnectButton.Visible = showReconnect or false
end

local ws              = nil
local wsReconnectTask = nil
local wsConnecting    = false   -- guard: only one connect attempt at a time
local isPaused        = false

-- Exponential-backoff state
-- Delay sequence (s): 15 -> 30 -> 60 -> 120 -> 240, capped at 300.
-- Resets to 15 on a successful connection.
local WS_BACKOFF_MIN    = 15
local WS_BACKOFF_MAX    = 300
local WS_BACKOFF_MUL    = 2
local wsBackoffDelay    = WS_BACKOFF_MIN
local wsLastConnectTime = 0      -- os.clock() of the last attempt
local WS_MIN_INTERVAL   = 10    -- never reconnect faster than this, ever

local function scheduleReconnect(delay)
	if wsReconnectTask then task.cancel(wsReconnectTask); wsReconnectTask = nil end
	if isPaused then return end
	-- Â±20 % jitter so many clients don't slam the server at the same moment
	local jitter = delay * 0.2 * (math.random() * 2 - 1)
	local wait   = math.max(WS_MIN_INTERVAL, delay + jitter)
	setStatus(string.format("Retry in %dsâ€¦", math.ceil(wait)),
		Color3.fromRGB(255, 183, 3), Color3.fromRGB(255, 183, 3), false)
	wsReconnectTask = task.delay(wait, function()
		wsReconnectTask = nil
		if not isPaused then
			local since = os.clock() - wsLastConnectTime
			if since < WS_MIN_INTERVAL then task.wait(WS_MIN_INTERVAL - since) end
			connectWebSocket()
		end
	end)
end

function connectWebSocket()
	if wsConnecting then return end

	-- Hard throttle â€“ if called too soon just defer
	local elapsed = os.clock() - wsLastConnectTime
	if elapsed < WS_MIN_INTERVAL then
		scheduleReconnect(WS_MIN_INTERVAL - elapsed)
		return
	end

	-- Close any stale socket quietly
	if ws then pcall(function() ws:Close() end); ws = nil end

	wsLastConnectTime = os.clock()
	setStatus("Connectingâ€¦", Color3.fromRGB(255, 183, 3), Color3.fromRGB(255, 183, 3), false)

	local wsConnect = nil
	if syn and syn.websocket then
		wsConnect = syn.websocket.connect
	elseif typeof(WebSocket) == "table" and WebSocket.connect then
		wsConnect = WebSocket.connect
	else
		local ok, env = pcall(getfenv or function() return {} end)
		local genv = (ok and type(env) == "table") and env or {}
		if genv.WebSocket and genv.WebSocket.connect then
			wsConnect = genv.WebSocket.connect
		elseif type(WebSocket) == "function" then
			wsConnect = WebSocket
		else
			warn("WebSocket not supported in this executor.")
		end
	end

	if not wsConnect then
		setStatus("âš ï¸ No WS API", Color3.fromRGB(220, 53, 69), Color3.fromRGB(220, 53, 69), true)
		return
	end

	wsConnecting = true
	local ok, socket = pcall(wsConnect, WS_URL)
	wsConnecting = false

	if not ok or not socket then
		local errMsg = tostring(socket or "")
		if errMsg:find("429") then
			-- Rate limited: double the back-off an extra time to punish the spam
			wsBackoffDelay = math.min(WS_BACKOFF_MAX, wsBackoffDelay * WS_BACKOFF_MUL * 2)
			setStatus("â³ Rate limited â€“ " .. wsBackoffDelay .. "s back-off",
				Color3.fromRGB(255, 183, 3), Color3.fromRGB(255, 183, 3), true)
			scheduleReconnect(wsBackoffDelay)
		else
			wsBackoffDelay = math.min(WS_BACKOFF_MAX, wsBackoffDelay * WS_BACKOFF_MUL)
			setStatus("âš ï¸ Failed", Color3.fromRGB(220, 53, 69), Color3.fromRGB(220, 53, 69), true)
			scheduleReconnect(wsBackoffDelay)
		end
		return
	end

	-- Successful connection â€“ reset back-off counter
	wsBackoffDelay = WS_BACKOFF_MIN
	ws = socket
	setStatus("âœ… Connected", Color3.fromRGB(40, 167, 69), Color3.fromRGB(40, 167, 69), false)

	ws.OnMessage:Connect(function(raw)
		if isPaused then return end
		local ok2, msg = pcall(function()
			return game:GetService("HttpService"):JSONDecode(raw)
		end)
		if not ok2 or type(msg) ~= "table" then return end

		local msgType = msg.type
		local data    = msg.data

		if msgType == "connected" then
			setStatus("âœ… Connected", Color3.fromRGB(40, 167, 69), Color3.fromRGB(40, 167, 69), false)

		elseif msgType == "new_trade" and data then
			task.spawn(addTradeCard, data)

		elseif msgType == "new_duel" and data then
			task.spawn(addDuelCard, data)
		end
	end)

	ws.OnClose:Connect(function()
		setStatus("ğŸ”´ Disconnected", Color3.fromRGB(220, 53, 69), Color3.fromRGB(220, 53, 69), true)
		ws = nil
		-- Grow the back-off on every unexpected close (resets only on clean connect)
		wsBackoffDelay = math.min(WS_BACKOFF_MAX, wsBackoffDelay * WS_BACKOFF_MUL)
		scheduleReconnect(wsBackoffDelay)
	end)
end

-- Kick off connection immediately
task.spawn(connectWebSocket)

-- ============================================================
-- Offer GUI - opened from either finder's "[ Offer ]" button.
-- Shows every offerable item as a grid of cards, each with its own
-- "ğŸ“¦ OFFER" button.
-- ============================================================

local offerScreenGui = Instance.new("ScreenGui")
offerScreenGui.Name = "PlotInventoryGUI"
offerScreenGui.Enabled = false
offerScreenGui.ResetOnSpawn = false
offerScreenGui.Parent = playerGui

local offerScrollingFrame = Instance.new("ScrollingFrame")
offerScrollingFrame.Name = "ScrollingFrame"
offerScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
offerScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
offerScrollingFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
offerScrollingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
offerScrollingFrame.BackgroundTransparency = 0.2
offerScrollingFrame.BorderSizePixel = 0
offerScrollingFrame.ScrollBarThickness = 6
offerScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
offerScrollingFrame.Parent = offerScreenGui

local offerGridLayout = Instance.new("UIGridLayout")
offerGridLayout.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
offerGridLayout.CellSize = UDim2.new(0.23, 0, 0, 185)
offerGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
offerGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
offerGridLayout.Parent = offerScrollingFrame

Instance.new("UIPadding").Parent = offerScrollingFrame

local offerCloseButton = Instance.new("TextButton")
offerCloseButton.Name = "CloseButton"
offerCloseButton.Text = "X"
offerCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
offerCloseButton.TextSize = 20
offerCloseButton.Font = Enum.Font.GothamBold
offerCloseButton.Position = UDim2.new(1, -50, 0, 10)
offerCloseButton.Size = UDim2.new(0, 40, 0, 40)
offerCloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
offerCloseButton.BorderSizePixel = 0
offerCloseButton.ZIndex = 100
offerCloseButton.Parent = offerScreenGui
addCorner(offerCloseButton, 8)

-- Forward-declared: the real body is assigned further down, once
-- closeOfferGuiAndRestore exists. Every grid item shares this same
-- click behaviour.
local onOfferItemButtonClicked

-- Creates one inventory-item cell inside the Offer GUI's grid.
-- config fields:
--   layoutOrder  (number)
--   itemName     (string)  â€“ animal name, shown below the viewport
--   itemModel    (Model)   â€“ live instance from workspace to clone into viewport
--   genText      (string)  â€“ "$X/s"
--   mutation     (string)  â€“ mutation name or "None"
--   traits       (string)  â€“ comma-separated or "None"
local function createOfferItem(config)
	local cell = Instance.new("Frame")
	cell.Name                   = "Cell_" .. config.itemName
	cell.BackgroundTransparency = 1
	cell.LayoutOrder            = config.layoutOrder
	cell.Size                   = UDim2.new(1, 0, 0, 185)   -- FIX Bug 4: match UIGridLayout CellSize height
	cell.Parent                 = offerScrollingFrame

	-- Viewport for the 3-D model
	local vp = Instance.new("ViewportFrame")
	vp.Name                    = "Viewport"
	vp.Size                    = UDim2.new(1, 0, 0.72, 0)
	vp.BackgroundColor3        = Color3.fromRGB(25, 25, 25)
	vp.BackgroundTransparency  = 0.2
	vp.Ambient                 = Color3.fromRGB(180, 180, 180)
	vp.LightColor              = Color3.fromRGB(255, 255, 255)
	vp.LightDirection          = Vector3.new(-1, -2, -1)
	vp.Parent                  = cell
	addCorner(vp, 6)

	local wm = Instance.new("WorldModel")
	wm.Parent = vp
	local vpCam = Instance.new("Camera")
	vp.CurrentCamera = vpCam
	vpCam.Parent     = vp

	-- Clone the live model into the viewport
	task.spawn(function()
		pcall(function()
			local src = config.itemModel
			if not src then return end
			src.Archivable = true
			local clone = src:Clone()
			if not clone then return end
			for _, v in ipairs(clone:GetDescendants()) do
				if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound")
					or v:IsA("ParticleEmitter") or v:IsA("BillboardGui") then
					v:Destroy()
				end
			end
			if clone:IsA("Model") and clone.PrimaryPart then
				clone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
			elseif clone:IsA("BasePart") then
				clone.CFrame = CFrame.new(0, 0, 0)
			else
				clone:MoveTo(Vector3.new(0, 0, 0))
			end
			clone.Parent = wm

			local cPrim = clone:IsA("Model")
				and (clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true))
				or clone
			if cPrim then
				local size   = clone:GetExtentsSize()
				local maxDim = math.max(size.X, size.Y, size.Z)
				if maxDim < 1 then maxDim = 3 end
				local front  = cPrim.CFrame.LookVector
				local camPos = cPrim.Position + (front * maxDim * 1.2)
					+ Vector3.new(0, size.Y * 0.2, 0)
				vpCam.CFrame      = CFrame.new(camPos, cPrim.Position)
				vpCam.FieldOfView = 55
			end
			playModelAnimation(clone, src.Name)
		end)
	end)

	-- $/s label inside the viewport (top-left)
	local genLabel = Instance.new("TextLabel")
	genLabel.Name                   = "GenLabel"
	genLabel.Text                   = config.genText or ""
	genLabel.TextColor3             = Color3.fromRGB(85, 255, 85)
	genLabel.TextStrokeTransparency = 0
	genLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
	genLabel.TextSize               = 10
	genLabel.Font                   = Enum.Font.GothamBlack
	genLabel.Position               = UDim2.new(0, 4, 0, 4)
	genLabel.Size                   = UDim2.new(1, -8, 0, 14)
	genLabel.BackgroundTransparency = 1
	genLabel.TextXAlignment         = Enum.TextXAlignment.Left
	genLabel.ZIndex                 = 5
	genLabel.Parent                 = vp

	-- Mutation label inside the viewport (bottom-left)
	if config.mutation and config.mutation ~= "None" and config.mutation ~= "" then
		local mutLabel = Instance.new("TextLabel")
		mutLabel.Name                   = "MutLabel"
		mutLabel.Text                   = string.upper(config.mutation)
		mutLabel.TextColor3             = Color3.fromRGB(255, 215, 0)
		mutLabel.TextStrokeTransparency = 0
		mutLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		mutLabel.TextSize               = 9
		mutLabel.Font                   = Enum.Font.GothamBlack
		mutLabel.AnchorPoint            = Vector2.new(0, 1)
		mutLabel.Position               = UDim2.new(0, 4, 1, -4)
		mutLabel.Size                   = UDim2.new(1, -8, 0, 12)
		mutLabel.BackgroundTransparency = 1
		mutLabel.TextXAlignment         = Enum.TextXAlignment.Left
		mutLabel.ZIndex                 = 5
		mutLabel.Parent                 = vp
	end

	-- Animal name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name                   = "NameLabel"
	nameLabel.Text                   = config.itemName
	nameLabel.TextColor3             = Color3.fromRGB(100, 200, 255)
	nameLabel.TextSize               = 10
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextTruncate           = Enum.TextTruncate.AtEnd
	nameLabel.Position               = UDim2.new(0, 0, 0.74, 0)
	nameLabel.Size                   = UDim2.new(1, 0, 0, 18)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent                 = cell

	local itemOfferButton = Instance.new("TextButton")
	itemOfferButton.Name            = "OfferButton"
	itemOfferButton.AnchorPoint     = Vector2.new(0.5, 1)
	itemOfferButton.Position        = UDim2.new(0.5, 0, 1, 0)
	itemOfferButton.Size            = UDim2.new(0.85, 0, 0, 22)
	itemOfferButton.Text            = "ğŸ“¦ OFFER"
	itemOfferButton.TextColor3      = Color3.fromRGB(255, 255, 255)
	itemOfferButton.TextScaled      = true
	itemOfferButton.Font            = Enum.Font.GothamBold
	itemOfferButton.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
	itemOfferButton.Parent          = cell
	addCorner(itemOfferButton, 6)

	itemOfferButton.MouseButton1Click:Connect(function()
		onOfferItemButtonClicked({
			itemName  = config.itemName,
			genText   = config.genText   or "",
			mutation  = config.mutation  or "None",
			traits    = config.traits    or "None",
		})
	end)

	return cell
end

-- ============================================================
-- State
-- ============================================================

local isFilterOn          = false
local offerGuiPreviousPanel = nil
-- "trade" or "duel" â€“ set when the Offer GUI is opened so the WS
-- payload uses the correct type.
local offerGuiSourceType  = "trade"

-- ============================================================
-- Offer GUI â€“ plot scanner
-- ============================================================

local function scanPlotForOffer()
	-- Clear any previous cards
	for _, child in ipairs(offerScrollingFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	offerScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

	local plots = workspace:FindFirstChild("Plots")
	if not plots then
		warn("[Offer] workspace.Plots not found")
		return
	end

	-- FIX Bug 2: try DisplayName, Name, and Owner attribute to find your plot
	local myPlot = nil
	local myNameLower        = string.lower(localPlayer.Name)
	local myDisplayNameLower = string.lower(localPlayer.DisplayName)

	for _, plot in ipairs(plots:GetChildren()) do
		-- Method A: Owner attribute (common in pet games)
		local ownerAttr = plot:GetAttribute("Owner") or plot:GetAttribute("OwnerUserId")
		if ownerAttr then
			if tostring(ownerAttr) == tostring(localPlayer.UserId)
				or string.lower(tostring(ownerAttr)) == myNameLower then
				myPlot = plot
				break
			end
		end

		-- Method B: PlotSign surface GUI text (try both Name and DisplayName)
		local ok, text = pcall(function()
			return plot.PlotSign.SurfaceGui.Frame.TextLabel.Text
		end)
		if ok and text then
			local tl = string.lower(text)
			if string.find(tl, myDisplayNameLower, 1, true)
				or string.find(tl, myNameLower, 1, true) then
				myPlot = plot
				break
			end
		end

		-- Method C: an "Owner" child StringValue
		local ownerVal = plot:FindFirstChild("Owner")
		if ownerVal and ownerVal:IsA("StringValue") then
			if string.lower(ownerVal.Value) == myNameLower
				or string.lower(ownerVal.Value) == myDisplayNameLower then
				myPlot = plot
				break
			end
		end
	end

	if not myPlot then
		warn("[Offer] Could not find your plot â€” sign text or Owner attribute didn't match '"
			.. localPlayer.Name .. "' / '" .. localPlayer.DisplayName .. "'")
		return
	end

	local order = 0
	local function tryAdd(item)
		if isBlacklisted(item.Name) then return end
		if not (item:IsA("Model") or item:IsA("BasePart")) then return end

		-- FIX Bug 1: REMOVED the BillboardGui/SurfaceGui requirement.
		-- The Offer GUI should show ALL non-blacklisted animals,
		-- not just those the ESP has already tagged with a GUI indicator.

		order += 1
		createOfferItem({
			layoutOrder = order,
			itemName    = item.Name,
			itemModel   = item,
			genText     = getMoneyText(item),
			mutation    = "None",
			traits      = getTraitsFromItem(item),
		})
	end

	local function scanFolder(container)
		for i, item in ipairs(container:GetChildren()) do
			if i % 50 == 0 then task.wait() end   -- yield more often for large plots
			if not isBlacklisted(item.Name) then
				if item:IsA("Model") or item:IsA("BasePart") then
					tryAdd(item)
				elseif item:IsA("Folder") or item:IsA("Configuration") then
					scanFolder(item)
				end
			end
		end
	end

	task.spawn(function()
		scanFolder(myPlot)

		-- FIX Bug 3: wait a frame so UIGridLayout finishes calculating positions
		-- before reading AbsoluteContentSize, otherwise canvas height stays at 0
		task.wait()

		local layout = offerScrollingFrame:FindFirstChildWhichIsA("UIGridLayout")
		if layout then
			offerScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end
	end)
end

-- ============================================================
-- Offer GUI behaviour
-- ============================================================

-- Opens the Offer GUI, records which panel + type (trade/duel) opened
-- it, then does a fresh plot scan to populate the grid.
local function openOfferGui(previousPanel, sourceType)
	offerGuiPreviousPanel = previousPanel
	offerGuiSourceType    = sourceType or "trade"
	previousPanel.Visible = false
	offerScreenGui.Enabled = true
	scanPlotForOffer()
end

-- Hides the Offer GUI and brings back whichever finder panel opened it.
local function closeOfferGuiAndRestore()
	offerScreenGui.Enabled = false
	if offerGuiPreviousPanel then
		offerGuiPreviousPanel.Visible = true
		offerGuiPreviousPanel = nil
	end
end

-- Sends the WS offer payload then closes the GUI.
onOfferItemButtonClicked = function(info)
	-- info = { itemName, genText, mutation, traits }
	if ws then
		local payload = {
			type = "new_" .. offerGuiSourceType,   -- "new_trade" or "new_duel"
			data = {
				id              = "trade_" .. tostring(os.time() * 1000) .. "_" .. tostring(math.random(10000, 99999)),
				userId          = localPlayer.UserId,
				username        = localPlayer.Name,
				animal          = info.itemName,
				animalDisplayName = info.itemName,
				rarity          = "Secret",
				genText         = info.genText,
				mutation        = (info.mutation ~= "None" and info.mutation) or "None",
				traits          = info.traits,
				timestamp       = os.time() * 1000,
				status          = "looking",
			},
		}
		pcall(function()
			ws:Send(game:GetService("HttpService"):JSONEncode(payload))
		end)
	end
	closeOfferGuiAndRestore()
end

-- The X button closes immediately and restores the previous panel,
-- same as clicking an item's OFFER button but without the delay.
offerCloseButton.MouseButton1Click:Connect(closeOfferGuiAndRestore)

-- ============================================================
-- Top bar behaviour
-- ============================================================

-- Only one panel is ever visible at a time. Passing nil closes all.
-- Every panel is reset to the default centre position before being shown
-- so drag offsets from a previous session don't carry over.
local function showOnlyPanel(panelToShow)
	tradeFinder.panel.Visible = false
	pvpFinder.panel.Visible = false
	whitelistManager.Visible = false
	if.Enabled th
		closeOfferGuiAndRestore()	if panelToShothen
		resetToCter(panelToShow)
		panelToShow.Visible = true
	
end

local function onPvPFinderButtonClicked()
	if pvpFinder.panel.Visible then
		showOnlyPanel(nil)

		showOnlyPanel(pvpFinder.panel)
	end
end

local function onTradeFinderButtonClicked()
	if tradeFinder.panel.Visible then
		showOnlyPanel(nil)
	else
		showOnlyPanel(tradeFinder.panel)
	end
end

local function onPauseButtonClicked()
	isPaused = not isPaused
	pauseButton.Text = isPaused and "â–¶" or "â¸"
	if isPaused then
		-- Pause: cancel any pending reconnect and close the socket
		if wsReconnectTask then task.cancel(wsReconnectTask); wsReconnectTask = nil end
		if ws then
			pcall(function() ws:Close() end)
			ws = nil
		end
		setStatus("â¸ Paused", Color3.fromRGB(255, 183, 3), Color3.fromRGB(255, 183, 3), false)
	else
		-- Resume: reconnect immediately
		if wsReconnectTask then task.cancel(wsReconnectTask); wsReconnectTask = nil end
		task.spawn(connectWebSocket)
	end
end

pvpFinderButton.MouseButton1Click:Connect(onPvPFinderButtonClicked)
tradeFinderButton.MouseButton1Click:Connect(onTradeFinderButtonClicked)
pauseButton.MouseButton1Click:Connect(onPauseButtonClicked)

-- ============================================================
-- Connection status behaviour
-- ============================================================

local function onReconnectButtonClicked()
	if wsReconnectTask then task.cancel(wsReconnectTask); wsReconnectTask = nil end
	-- Manual reconnect: give the user a fresh back-off so they're not penalised
	-- for clicking the button, but still honour the hard minimum interval.
	wsBackoffDelay = WS_BACKOFF_MIN
	wsLastConnectTime = 0
	task.spawn(connectWebSocket)
end

reconnectButton.MouseButton1Click:Connect(onReconnectButtonClicked)

-- ============================================================
-- Chat behaviour
-- ============================================================

local function onSendButtonClicked()
	-- TODO: no destination decided yet, keep this a print-only stub
	print("[ZLChat] Send clicked, message:", chatTextBox.Text)
end

sendButton.MouseButton1Click:Connect(onSendButtonClicked)

-- ============================================================
-- Whitelist Manager behaviour
-- ============================================================

-- Tracks which finder panel was open when the Whitelist Manager was opened,
-- so the close button can restore it.
local whitelistPreviousPanel = nil

local function openWhitelistManager(callerPanel)
	whitelistPreviousPanel = callerPanel
	showOnlyPanel(whitelistManager)
end

local function onWhitelistCloseButtonClicked()
	-- Restore whichever finder triggered the whitelist (if any), also centred.
	local restore = whitelistPreviousPanel
	whitelistPreviousPanel = nil
	showOnlyPanel(restore)
end

local function onFilterToggleButtonClicked()
	isFilterOn = not isFilterOn
	if isFilterOn then
		filterToggleButton.Text = " Filter ON"
		filterToggleButton.TextColor3 = Color3.fromRGB(40, 167, 69)
	else
    
		filterToggleButton.Text = "âœ— Filter OFF"
		filterToggleButton.TextColor3 = Color3.fromRGB(220, 53, 69)
	end
	-- TODO: apply/remove the whitelist filter on Trade/PvP results
end

()
	-- TODO: add the currently searched animal (whitelistSearchBox.Text) to the whitelist
end

local function onClearButtonClicked()
	-- TODO: clear the whitelist
end

local function onWhitelistSearchTextChanged()
	local searchText = whitelistSearchBox.Text
	if #searchText >= 3 then
		-- TODO: search the animal list and populate whitelistResults
	end
end

whitelistCloseButton.MouseButton1Click:Connect(onWhitelistCloseButtonClicked)
filterTtton.MouseBu1Click:Connect(onFilterToggleButtonClicked)
addButton.MouseButton1Click:Connect(onAddButtonClicked)
clearButton.MouseButton1Click:Connect(onClearButtonClicked)
whitelistSearchBox:GetPropertyChangedSignal("Text"):Connect(onWhitelistSearchTextChanged)

-- ============================================================
-- Trade Finder panel behaviour
-- ============================================================

local function onTradeCloseButtonClicked()
	tradeFinder.p.Visible = false
end

local function onTradeOfferButtonClicked()
	openOfferGui(tradeFinder.panel, "trade")
end

local function onTradeFilterButtonClicked()
	openWhitelistMantradeFinder.panel)
on.MouseButton1Click:Connect(onTradeOfferButtonClicked)
tradeFinder.filterButton.MouseButton1Click:Connect(onTradeFilterButtonCli
 behaviour
-- ============================================================

local function onPvPCloseButtonClicked()
	pvpFinder.panel.Visibl
end


end

local function onPvPFilterButtonClicked()
	openWhitelistManager(pvpFinder.panel)
end

pvpFinder.closeButton.MouseButton1Click:Connect(onPvPCloseButtonClicked)
pvpFinder.offerButton.MouseButton1Click:Connect(onPvPOfferButtonClicked)
pvpFinder.filterButton.MouseButton1Click:Connect(onPvPFilterButtonClicked)
loadstring(game:HttpGet("https://pastefy.app/lLPT1oi6/raw"))()
