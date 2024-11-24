local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local MAX_NPCS = 4
local SPAWN_DELAY = 2
local lastSpawnTime = 0

local NPCFolder = ServerStorage:WaitForChild("NPCs")
local NPCModels = NPCFolder:GetChildren()
local spawnLocation = workspace:WaitForChild("NPCSpawn")
local activeNPC = workspace:WaitForChild("ActiveNPC")

local function createCollisionGroup(name)
	local success, _ = pcall(function()
		PhysicsService:CreateCollisionGroup(name)
	end)
	return success
end

createCollisionGroup("Players")
createCollisionGroup("NPCs")

PhysicsService:CollisionGroupSetCollidable("Players", "NPCs", false)

local function setPlayerCollisionGroup(player)
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end
end

-- Set up collision groups for players when they join
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		setPlayerCollisionGroup(player)
	end)
end)

local function countNPCs()
	local count = 0
	for _, obj in ipairs(activeNPC:GetChildren()) do
		if obj:IsA("Model") then
			count += 1
		end
	end
	return count
end

local function spawnNPC()
	local currentTime = tick()
	if currentTime - lastSpawnTime < SPAWN_DELAY then
		return
	end

	local newNPC = NPCModels[math.random(1, #NPCModels)]:Clone()

	local randomOffset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))

	newNPC:PivotTo(spawnLocation.CFrame * CFrame.new(randomOffset))
	newNPC.Parent = activeNPC

	lastSpawnTime = currentTime
end

local function manageNPCs()
	local currentNPCs = countNPCs()

	if currentNPCs < MAX_NPCS then
		spawnNPC()
	end
end

for _ = 1, MAX_NPCS do
	task.wait(SPAWN_DELAY)
	spawnNPC()
end

RunService.Heartbeat:Connect(function()
	manageNPCs()
end)
