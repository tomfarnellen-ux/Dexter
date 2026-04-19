local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local ShopUI = {}
ShopUI.__index = ShopUI

local function makeButton(text, color, parent)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 56)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.FredokaOne
	btn.TextColor3 = UIStyle.TextPrimary
	btn.TextSize = 22
	btn.AutoButtonColor = true
	btn.Parent = parent
	UIStyle.Corner(btn, 14)
	UIStyle.Stroke(btn, Color3.new(0, 0, 0), 2)
	return btn
end

function ShopUI.new(screenGui)
	local self = setmetatable({}, ShopUI)

	local toggle = Instance.new("TextButton")
	toggle.Name = "ShopToggle"
	toggle.Size = UDim2.new(0, 170, 0, 56)
	toggle.Position = UDim2.new(1, -186, 1, -72)
	toggle.AnchorPoint = Vector2.new(0, 0)
	toggle.BackgroundColor3 = UIStyle.Primary
	toggle.Text = "SHOP"
	toggle.Font = Enum.Font.FredokaOne
	toggle.TextColor3 = UIStyle.TextPrimary
	toggle.TextSize = 24
	toggle.BorderSizePixel = 0
	toggle.Parent = screenGui
	UIStyle.Corner(toggle, 16)
	UIStyle.Stroke(toggle, Color3.new(0, 0, 0), 2)

	local panel = Instance.new("Frame")
	panel.Name = "ShopPanel"
	panel.Size = UDim2.new(0, 380, 0, 440)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = UIStyle.Panel
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui
	UIStyle.Corner(panel, 20)
	UIStyle.Stroke(panel, UIStyle.PrimaryDark, 3)
	UIStyle.Padding(panel, 16)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "BRAINROT SHOP"
	title.Font = Enum.Font.FredokaOne
	title.TextColor3 = UIStyle.Accent
	title.TextSize = 28
	title.Parent = panel

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 36, 0, 36)
	close.Position = UDim2.new(1, -36, 0, 0)
	close.AnchorPoint = Vector2.new(0, 0)
	close.Text = "X"
	close.Font = Enum.Font.FredokaOne
	close.TextColor3 = UIStyle.TextPrimary
	close.BackgroundColor3 = UIStyle.Danger
	close.TextSize = 20
	close.BorderSizePixel = 0
	close.Parent = panel
	UIStyle.Corner(close, 10)

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 1, -48)
	body.Position = UDim2.new(0, 0, 0, 48)
	body.BackgroundTransparency = 1
	body.Parent = panel
	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, 10)
	bodyLayout.Parent = body

	local rollDisplay = Instance.new("Frame")
	rollDisplay.Size = UDim2.new(1, 0, 0, 140)
	rollDisplay.BackgroundColor3 = UIStyle.PanelLight
	rollDisplay.BorderSizePixel = 0
	rollDisplay.Parent = body
	UIStyle.Corner(rollDisplay, 14)

	local rollLabel = Instance.new("TextLabel")
	rollLabel.Size = UDim2.new(1, -20, 0, 40)
	rollLabel.Position = UDim2.new(0, 10, 0, 8)
	rollLabel.BackgroundTransparency = 1
	rollLabel.Text = "Roll to reveal!"
	rollLabel.Font = Enum.Font.FredokaOne
	rollLabel.TextColor3 = UIStyle.TextPrimary
	rollLabel.TextSize = 22
	rollLabel.Parent = rollDisplay

	local rollRarity = Instance.new("TextLabel")
	rollRarity.Size = UDim2.new(1, -20, 0, 30)
	rollRarity.Position = UDim2.new(0, 10, 0, 50)
	rollRarity.BackgroundTransparency = 1
	rollRarity.Text = ""
	rollRarity.Font = Enum.Font.FredokaOne
	rollRarity.TextColor3 = UIStyle.TextMuted
	rollRarity.TextSize = 18
	rollRarity.Parent = rollDisplay

	local rollIncome = Instance.new("TextLabel")
	rollIncome.Size = UDim2.new(1, -20, 0, 30)
	rollIncome.Position = UDim2.new(0, 10, 0, 82)
	rollIncome.BackgroundTransparency = 1
	rollIncome.Text = ""
	rollIncome.Font = Enum.Font.FredokaOne
	rollIncome.TextColor3 = UIStyle.Accent
	rollIncome.TextSize = 18
	rollIncome.Parent = rollDisplay

	local rollBtn = makeButton("ROLL  ($" .. GameConfig.ROLL_COST .. ")", UIStyle.Primary, body)
	local lockBtn = makeButton("BUY LOCK ($" .. GameConfig.LOCK_COST .. ")", UIStyle.Success, body)
	lockBtn.TextColor3 = Color3.fromRGB(20, 40, 20)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0, 48)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.GothamMedium
	info.TextColor3 = UIStyle.TextMuted
	info.TextSize = 14
	info.TextWrapped = true
	info.Text = "Brainrots go on empty pedestals.\nLock protects your plot for "
		.. GameConfig.LOCK_DURATION .. "s."
	info.Parent = body

	toggle.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)
	close.Activated:Connect(function()
		panel.Visible = false
	end)
	rollBtn.Activated:Connect(function()
		Remotes.Get("RollBrainrot"):FireServer()
	end)
	lockBtn.Activated:Connect(function()
		Remotes.Get("PurchaseLock"):FireServer()
	end)

	Remotes.Get("RollResult").OnClientEvent:Connect(function(result)
		rollLabel.Text = "Got: " .. result.name
		rollRarity.Text = result.rarity .. " rarity"
		rollRarity.TextColor3 = GameConfig.RARITY_COLORS[result.rarity] or UIStyle.TextMuted
		rollIncome.Text = "$" .. result.income .. " per second"
		local flash = Instance.new("Frame")
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = GameConfig.RARITY_COLORS[result.rarity] or UIStyle.Accent
		flash.BackgroundTransparency = 0.5
		flash.BorderSizePixel = 0
		flash.Parent = rollDisplay
		UIStyle.Corner(flash, 14)
		TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
		task.delay(0.7, function()
			flash:Destroy()
		end)
	end)

	self.panel = panel
	return self
end

return ShopUI
