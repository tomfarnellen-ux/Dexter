local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))

local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local Notifications = {}

function Notifications.new(screenGui)
	local container = Instance.new("Frame")
	container.Name = "Notifications"
	container.Size = UDim2.new(0, 360, 1, 0)
	container.Position = UDim2.new(0.5, 0, 0, 24)
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	local function push(message, color)
		local toast = Instance.new("Frame")
		toast.Size = UDim2.new(1, 0, 0, 48)
		toast.BackgroundColor3 = UIStyle.Panel
		toast.BackgroundTransparency = 0.05
		toast.BorderSizePixel = 0
		toast.Parent = container
		UIStyle.Corner(toast, 12)
		UIStyle.Stroke(toast, color or UIStyle.Accent, 2)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -16, 1, 0)
		label.Position = UDim2.new(0, 8, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextColor3 = color or UIStyle.TextPrimary
		label.TextSize = 18
		label.TextWrapped = true
		label.Text = message
		label.Parent = toast

		task.delay(3, function()
			local tween = TweenService:Create(toast, TweenInfo.new(0.4),
				{ BackgroundTransparency = 1 })
			tween:Play()
			tween.Completed:Wait()
			toast:Destroy()
		end)
	end

	Remotes.Get("ShowNotification").OnClientEvent:Connect(push)
	return { push = push }
end

return Notifications
