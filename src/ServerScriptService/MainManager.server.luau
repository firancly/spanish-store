local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Configuration
local NPC_SPAWN_FOLDER = ServerStorage:WaitForChild("NPCs")
local SPAWN_LOCATION = workspace:WaitForChild("NPCSpawn")
local MAX_NPCS = 4
local SPAWN_DELAY = 5
local SPAWN_RADIUS = 3

-- Workspace folder to hold active NPCs
local activeNPCs = workspace:WaitForChild("ActiveNPC")

-- Utility function to count current NPCs
local function countNPCs()
	return #activeNPCs:GetChildren()
end

local function spawnNPC()
	local npcModels = NPC_SPAWN_FOLDER:GetChildren()
	if #npcModels == 0 then
		warn("No NPC models found")
	end

	-- Random NPC model
	local selectedModel = npcModels[math.random(1, #npcModels)]:Clone()

	-- Spawn postiion with randomized offset
	local spawnCFrame = SPAWN_LOCATION.CFrame
		* CFrame.new(math.random(-SPAWN_RADIUS, SPAWN_RADIUS), 0, math.random(-SPAWN_RADIUS, SPAWN_RADIUS))

	-- Position the NPC
	selectedModel:PivotTo(spawnCFrame)
	selectedModel.Parent = activeNPCs

	return selectedModel
end

local function manageNPCs()
	while true do
		local currentNPCCount = countNPCs()

		if currentNPCCount < MAX_NPCS then
			spawnNPC()
		end

		task.wait(SPAWN_DELAY)
	end
end

task.spawn(function()
	local currentNPCCount = countNPCs()
	if currentNPCCount < MAX_NPCS then
		spawnNPC()
		task.wait(SPAWN_DELAY)
	end

	manageNPCs()
end)
