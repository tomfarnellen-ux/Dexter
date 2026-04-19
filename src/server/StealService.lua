local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local BrainrotDatabase = require(Shared:WaitForChild("BrainrotDatabase"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PlotService = require(script.Parent:WaitForChild("PlotService"))
local BrainrotService = require(script.Parent:WaitForChild("BrainrotService"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))

local StealService = {}

local activeSteals = {}
local lastStealAt = {}
local notifyRemote = Remotes.Get("ShowNotification")
local placedRemote = Remotes.Get("BrainrotPlaced")
local removedRemote = Remotes.Get("BrainrotRemoved")

local function findPedestalByUid(uid)
	for i = 1, GameConfig.PLOT_COUNT do
		local plot = PlotService.GetPlotByIndex(i)
		if plot then
			for _, pedestal in ipairs(plot.pedestals) do
				if pedestal:GetAttribute("OccupiedBy") == uid then
					return plot, pedestal
				end
			end
		end
	end
	return nil, nil
end

local function notify(player, message, color)
	notifyRemote:FireClient(player, message, color or Color3.fromRGB(255, 230, 140))
end

local function isLocked(plot)
	local until_ = plot.model:GetAttribute("LockedUntil") or 0
	return os.clock() < until_
end

function StealService.PurchaseLock(player)
	local plot = PlotService.GetPlot(player)
	if not plot then return end
	if not EconomyService.SpendCoins(player, GameConfig.LOCK_COST) then
		notify(player, "Not enough coins for a lock!", Color3.fromRGB(255, 120, 120))
		return
	end
	plot.model:SetAttribute("LockedUntil", os.clock() + GameConfig.LOCK_DURATION)
	notify(player, "Plot locked for " .. GameConfig.LOCK_DURATION .. "s!", Color3.fromRGB(120, 220, 255))
end

function StealService.StartSteal(player, targetUid)
	if activeSteals[player] then return end
	local now = os.clock()
	if (now - (lastStealAt[player] or 0)) < GameConfig.STEAL_COOLDOWN then
		notify(player, "Steal cooldown active!", Color3.fromRGB(255, 120, 120))
		return
	end
	local plot, pedestal = findPedestalByUid(targetUid)
	if not plot or not pedestal then return end
	if plot.owner == player.UserId then
		notify(player, "You can't steal from your own plot!", Color3.fromRGB(255, 200, 100))
		return
	end
	if isLocked(plot) then
		notify(player, "That plot is locked!", Color3.fromRGB(255, 120, 120))
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if (root.Position - pedestal.Position).Magnitude > 12 then
		return
	end
	activeSteals[player] = {
		uid = targetUid,
		startedAt = now,
		pedestal = pedestal,
		sourcePlot = plot,
	}
	notify(player, "Stealing... stay close!", Color3.fromRGB(255, 230, 140))

	task.delay(GameConfig.STEAL_HOLD_TIME, function()
		local steal = activeSteals[player]
		if not steal or steal.uid ~= targetUid then return end
		activeSteals[player] = nil
		lastStealAt[player] = os.clock()

		if pedestal:GetAttribute("OccupiedBy") ~= targetUid then return end
		if isLocked(plot) then
			notify(player, "Plot locked mid-steal!", Color3.fromRGB(255, 120, 120))
			return
		end

		local model = BrainrotService.FindModelOnPedestal(pedestal)
		if not model then return end
		local entry = BrainrotDatabase.GetById(model:GetAttribute("BrainrotId"))
		if not entry then return end

		local thiefPlot = PlotService.GetPlot(player)
		if not thiefPlot then
			notify(player, "No plot to place stolen brainrot!", Color3.fromRGB(255, 120, 120))
			return
		end
		local target = PlotService.FindEmptyPedestal(thiefPlot)
		if not target then
			notify(player, "Your plot is full!", Color3.fromRGB(255, 120, 120))
			return
		end

		BrainrotService.Remove(pedestal)
		removedRemote:FireAllClients(plot.index)

		local victimId = plot.owner
		local victim = victimId and Players:GetPlayerByUserId(victimId)
		if victim then
			notify(victim, entry.name .. " was stolen from your plot!", Color3.fromRGB(255, 120, 120))
			EconomyService.PushState(victim)
		end

		BrainrotService.Spawn(entry, target)
		local data = DataService.Get(player)
		if data then
			data.totalStolen = (data.totalStolen or 0) + 1
		end
		placedRemote:FireAllClients(thiefPlot.index)
		notify(player, "Stole " .. entry.name .. "!", Color3.fromRGB(120, 255, 140))
		EconomyService.PushState(player)
	end)
end

function StealService.CancelSteal(player)
	activeSteals[player] = nil
end

Players.PlayerRemoving:Connect(function(player)
	activeSteals[player] = nil
	lastStealAt[player] = nil
end)

return StealService
