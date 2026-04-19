local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local HUD = {}
HUD.__index = HUD

local function makeStatCard(parent, title)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 200, 0, 60)
	card.BackgroundColor3 = UIStyle.Panel
	card.BorderSizePixel = 0
	card.Parent = parent
	UIStyle.Corner(card, 14)
	UIStyle.Stroke(card, UIStyle.PrimaryDark, 2)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -16, 0, 18)
	titleLabel.Position = UDim2.new(0, 12, 0, 6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextColor3 = UIStyle.TextMuted
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.TextSize = 14
	titleLabel.Parent = card

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -16, 0, 28)
	valueLabel.Position = UDim2.new(0, 12, 0, 24)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.FredokaOne
	valueLabel.TextColor3 = UIStyle.TextPrimary
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextSize = 24
	valueLabel.Text = "0"
	valueLabel.Parent = card

	return valueLabel
end

function HUD.new(screenGui)
	local self = setmetatable({}, HUD)

	local container = Instance.new("Frame")
	container.Name = "HUD"
	container.Size = UDim2.new(0, 220, 0, 200)
	container.Position = UDim2.new(0, 16, 0, 16)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	self.coinsLabel = makeStatCard(container, "COINS")
	self.incomeLabel = makeStatCard(container, "INCOME / SEC")
	self.stolenLabel = makeStatCard(container, "TOTAL STOLEN")

	return self
end

function HUD:Update(state)
	if not state then return end
	self.coinsLabel.Text = "$" .. UIStyle.FormatCoins(state.coins)
	self.incomeLabel.Text = "$" .. UIStyle.FormatCoins(state.income) .. "/s"
	self.stolenLabel.Text = tostring(state.totalStolen or 0)
end

return HUD
