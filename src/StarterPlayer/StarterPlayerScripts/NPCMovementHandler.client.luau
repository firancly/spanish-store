local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NPCEvents = ReplicatedStorage:WaitForChild("NPCEvents")
local StartNPCMovement = NPCEvents:WaitForChild("StartNPCMovement")

-- Movement settings
local MOVEMENT_SPEED = 16
local TURN_SPEED = 0.1
local WAYPOINT_THRESHOLD = 2

local activeNPCs = {}

local function moveNPCToWaypoint(npc, waypoint, dt)
	local humanoid = npc:WaitForChild("Humanoid")
	local rootPart = npc:WaitForChild("HumanoidRootPart")

	-- Calculate direction to target
	local direction = (waypoint.Position - rootPart.Position) * Vector3.new(1, 0, 1)
	local distance = direction.Magnitude

	if distance < WAYPOINT_THRESHOLD then
		return true
	end

	-- Normalize direction
	direction = direction.Unit

	-- Smoothly rotate NPC
	local currentRotation = rootPart.CFrame.LookVector
	local targetRotation = direction
	local newRotation = currentRotation:Lerp(targetRotation, TURN_SPEED)

	-- Set walking animation speed based on actual movement
	humanoid.WalkSpeed = MOVEMENT_SPEED

	-- Move the NPC
	rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + newRotation)
	humanoid:MoveTo(waypoint.Position)

	return false
end

StartNPCMovement.OnClientEvent:Connect(function(npc, waypoints, targetPosition)
	-- Store NPC movement data
	activeNPCs[npc] = {
		waypoints = waypoints,
		currentWaypoint = 1,
		targetPosition = targetPosition
	}

	-- Initialize movement state
	local humanoid = npc:WaitForChild("Humanoid")
	humanoid.WalkSpeed = MOVEMENT_SPEED
end)

-- Handle NPC movement in RunService
RunService.Heartbeat:Connect(function(dt)
	for npc, data in pairs(activeNPCs) do
		if npc.Parent and data.currentWaypoint <= #data.waypoints then
			local waypoint = data.waypoints[data.currentWaypoint]

			-- Move NPC towards current waypoint
			local reachedWaypoint = moveNPCToWaypoint(npc, waypoint, dt)

			if reachedWaypoint then
				data.currentWaypoint += 1

				-- Check if we've reached the final waypoint
				if data.currentWaypoint > #data.waypoints then
					activeNPCs[npc] = nil
				end
			end
		else
			-- Clean up if NPC is destroyed or reached destination
			activeNPCs[npc] = nil
		end
	end
end)