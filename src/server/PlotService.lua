local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local PlotService = {}

local plots = {}
local plotsFolder

local function buildPlot(index)
	local origin = Vector3.new((index - 1) * (GameConfig.PLOT_SIZE.X + GameConfig.PLOT_SPACING), 5, 0)

	local model = Instance.new("Model")
	model.Name = "Plot_" .. index
	model.Parent = plotsFolder

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = GameConfig.PLOT_SIZE
	floor.Anchored = true
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(90, 180, 255)
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.Position = origin
	floor.Parent = model

	local sign = Instance.new("Part")
	sign.Name = "Sign"
	sign.Size = Vector3.new(14, 5, 1)
	sign.Anchored = true
	sign.CanCollide = false
	sign.Material = Enum.Material.Neon
	sign.Color = Color3.fromRGB(255, 255, 255)
	sign.Position = origin + Vector3.new(0, 6, -GameConfig.PLOT_SIZE.Z / 2 + 0.5)
	sign.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(14, 0, 5, 0)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.fromRGB(30, 30, 60)
	label.Text = "UNCLAIMED PLOT"
	label.Parent = billboard

	local spawnPad = Instance.new("Part")
	spawnPad.Name = "Spawn"
	spawnPad.Size = Vector3.new(6, 1, 6)
	spawnPad.Anchored = true
	spawnPad.Material = Enum.Material.Neon
	spawnPad.Color = Color3.fromRGB(120, 220, 120)
	spawnPad.Position = origin + Vector3.new(-GameConfig.PLOT_SIZE.X / 2 + 5, 1, 0)
	spawnPad.Parent = model

	local pedestals = {}
	local startX = -GameConfig.PLOT_SIZE.X / 2 + 18
	for i = 1, GameConfig.PEDESTALS_PER_PLOT do
		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal_" .. i
		pedestal.Size = Vector3.new(6, 2, 6)
		pedestal.Anchored = true
		pedestal.Material = Enum.Material.Marble
		pedestal.Color = Color3.fromRGB(230, 230, 240)
		pedestal.Position = origin + Vector3.new(startX + (i - 1) * GameConfig.PEDESTAL_SPACING, 1.5, 0)
		pedestal.Parent = model

		local attach = Instance.new("Attachment")
		attach.Name = "BrainrotAttach"
		attach.Position = Vector3.new(0, 1, 0)
		attach.Parent = pedestal

		local slotNumber = Instance.new("BillboardGui")
		slotNumber.Size = UDim2.new(3, 0, 1, 0)
		slotNumber.StudsOffset = Vector3.new(0, 1.2, 0)
		slotNumber.Parent = pedestal
		local slotLabel = Instance.new("TextLabel")
		slotLabel.BackgroundTransparency = 1
		slotLabel.Size = UDim2.fromScale(1, 1)
		slotLabel.Font = Enum.Font.FredokaOne
		slotLabel.TextColor3 = Color3.fromRGB(70, 70, 90)
		slotLabel.TextStrokeTransparency = 0.4
		slotLabel.TextScaled = true
		slotLabel.Text = "SLOT " .. i
		slotLabel.Parent = slotNumber

		pedestals[i] = pedestal
	end

	return {
		index = index,
		origin = origin,
		model = model,
		sign = label,
		spawn = spawnPad,
		pedestals = pedestals,
		owner = nil,
	}
end

function PlotService.Init()
	plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = Workspace

	for i = 1, GameConfig.PLOT_COUNT do
		plots[i] = buildPlot(i)
	end
end

function PlotService.AssignPlot(player)
	for _, plot in ipairs(plots) do
		if not plot.owner then
			plot.owner = player.UserId
			plot.sign.Text = player.DisplayName .. "'s Base"
			return plot
		end
	end
	return nil
end

function PlotService.ReleasePlot(player)
	for _, plot in ipairs(plots) do
		if plot.owner == player.UserId then
			plot.owner = nil
			plot.sign.Text = "UNCLAIMED PLOT"
			return plot
		end
	end
	return nil
end

function PlotService.GetPlot(player)
	for _, plot in ipairs(plots) do
		if plot.owner == player.UserId then
			return plot
		end
	end
	return nil
end

function PlotService.GetPlotByIndex(index)
	return plots[index]
end

function PlotService.FindEmptyPedestal(plot)
	for _, pedestal in ipairs(plot.pedestals) do
		if not pedestal:GetAttribute("OccupiedBy") then
			return pedestal
		end
	end
	return nil
end

return PlotService
