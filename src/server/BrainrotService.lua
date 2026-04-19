local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local BrainrotDatabase = require(Shared:WaitForChild("BrainrotDatabase"))

local BrainrotService = {}

local function buildBrainrotModel(entry)
	local model = Instance.new("Model")
	model.Name = entry.name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(entry.size, entry.size, entry.size)
	body.Material = Enum.Material.Neon
	body.Color = GameConfig.RARITY_COLORS[entry.rarity] or Color3.fromRGB(200, 200, 200)
	body.Anchored = true
	body.CanCollide = false
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.Parent = model
	model.PrimaryPart = body

	local eyes = Instance.new("Decal")
	eyes.Texture = "rbxasset://textures/face.png"
	eyes.Face = Enum.NormalId.Front
	eyes.Parent = body

	local glow = Instance.new("PointLight")
	glow.Brightness = 1.5
	glow.Range = 8
	glow.Color = body.Color
	glow.Parent = body

	local nameGui = Instance.new("BillboardGui")
	nameGui.Size = UDim2.new(6, 0, 2, 0)
	nameGui.StudsOffset = Vector3.new(0, entry.size * 0.8, 0)
	nameGui.AlwaysOnTop = true
	nameGui.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0.6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = entry.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextScaled = true
	nameLabel.Parent = nameGui

	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Size = UDim2.fromScale(1, 0.4)
	incomeLabel.Position = UDim2.fromScale(0, 0.6)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = "$" .. entry.income .. "/s"
	incomeLabel.TextColor3 = GameConfig.RARITY_COLORS[entry.rarity]
	incomeLabel.TextStrokeTransparency = 0
	incomeLabel.Font = Enum.Font.FredokaOne
	incomeLabel.TextScaled = true
	incomeLabel.Parent = nameGui

	return model
end

function BrainrotService.Spawn(entry, pedestal)
	local model = buildBrainrotModel(entry)
	local uid = HttpService:GenerateGUID(false)
	model:SetAttribute("UID", uid)
	model:SetAttribute("BrainrotId", entry.id)
	model:SetAttribute("Income", entry.income)
	model:SetAttribute("Rarity", entry.rarity)

	local attach = pedestal:FindFirstChild("BrainrotAttach")
	local pos = pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2 + entry.size / 2 + 0.5, 0)
	if attach then
		pos = pedestal.Position + attach.Position + Vector3.new(0, entry.size / 2, 0)
	end
	model:PivotTo(CFrame.new(pos))
	model.Parent = pedestal

	pedestal:SetAttribute("OccupiedBy", uid)
	return model, uid
end

function BrainrotService.Remove(pedestal)
	pedestal:SetAttribute("OccupiedBy", nil)
	for _, child in ipairs(pedestal:GetChildren()) do
		if child:IsA("Model") then
			child:Destroy()
		end
	end
end

function BrainrotService.RandomRoll()
	local total = 0
	for _, weight in pairs(GameConfig.RARITY_WEIGHTS) do
		total = total + weight
	end
	local pick = math.random() * total
	local cursor = 0
	local chosenRarity
	for rarity, weight in pairs(GameConfig.RARITY_WEIGHTS) do
		cursor = cursor + weight
		if pick <= cursor then
			chosenRarity = rarity
			break
		end
	end
	local pool = BrainrotDatabase.GetByRarity(chosenRarity)
	if #pool == 0 then
		return BrainrotDatabase.List[1]
	end
	return pool[math.random(1, #pool)]
end

function BrainrotService.FindModelOnPedestal(pedestal)
	for _, child in ipairs(pedestal:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("UID") then
			return child
		end
	end
	return nil
end

return BrainrotService
