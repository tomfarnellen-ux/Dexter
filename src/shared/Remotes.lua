local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAMES = {
	"RollBrainrot",
	"PurchaseLock",
	"StartSteal",
	"CancelSteal",
	"UpdateState",
	"ShowNotification",
	"RollResult",
	"BrainrotPlaced",
	"BrainrotRemoved",
}

local Remotes = {}

local function getFolder()
	if RunService:IsServer() then
		local folder = ReplicatedStorage:FindFirstChild("Remotes")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = ReplicatedStorage
		end
		return folder
	else
		return ReplicatedStorage:WaitForChild("Remotes", 10)
	end
end

function Remotes.Get(name)
	local folder = getFolder()
	local remote = folder:FindFirstChild(name)
	if remote then
		return remote
	end
	if RunService:IsServer() then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		return remote
	end
	return folder:WaitForChild(name, 10)
end

if RunService:IsServer() then
	for _, name in ipairs(REMOTE_NAMES) do
		Remotes.Get(name)
	end
end

return Remotes
