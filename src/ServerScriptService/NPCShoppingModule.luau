-- NPCShoppingModule.lua
local NPCShoppingModule = {}

-- Services
local PathfindingService = game:GetService("PathfindingService")
local ChatService = game:GetService("Chat")

-- References that will be set when initializing an NPC
local itemStands = workspace:WaitForChild("ItemStands")
local queue = workspace.CheckoutQueue
local cashier1 = workspace:WaitForChild("CashierSpot1")
local cashier2 = workspace:WaitForChild("CashierSpot2")
local cashier1Bool = workspace.Bools:WaitForChild("Cashier1")
local cashier2Bool = workspace.Bools:WaitForChild("Cashier2")
local door = workspace:WaitForChild("AutoDoor")

-- Shop items configuration
local shopItems = {
	{ Name = "Doritos", Position = itemStands.Doritos.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Carne", Position = itemStands.Carne.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Takis", Position = itemStands.Takis.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Cereal", Position = itemStands.Cereal.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Snapple", Position = itemStands.Snapple.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Oreo", Position = itemStands.Oreo.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Vaselina", Position = itemStands.Vaselina.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Chips", Position = itemStands.Chips.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Desodorante", Position = itemStands.Desodorante.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Galon", Position = itemStands.Galon.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Vasitos", Position = itemStands.Vasitos.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Papel", Position = itemStands.Papel.aviso.Position + Vector3.new(-2, 0, 0) },
}

-- Local variables that will be unique to each NPC
local function createNPCState()
	return {
		shoppingList = {},
		isAtCashier = false,
		currentCashier = nil,
		npcModel = nil,
	}
end

-- Helper functions
local function moveToPosition(npcState, targetPosition)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	local success, errorMessage = pcall(function()
		-- Fixed: Use npcState.npcModel.HumanoidRootPart.Position instead of npcState.npc
		path:ComputeAsync(npcState.npcModel.HumanoidRootPart.Position, targetPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()

		local closestPlayer = nil
		local closestDistance = math.huge

		for _, player in ipairs(game.Players:GetPlayers()) do
			if player.Character then
				local distance = (
					player.Character.HumanoidRootPart.Position - npcState.npcModel.HumanoidRootPart.Position
				).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = player
					print(closestPlayer)
				end
			end
		end

		for _, waypoint in ipairs(waypoints) do
			if not npcState.npcModel.Parent then
				return
			end

			npcState.npcModel.Humanoid:MoveTo(waypoint.Position)
			npcState.npcModel.Humanoid.MoveToFinished:Wait()
		end
		return true
	else
		warn("Path computation failed:", errorMessage)
		return false
	end
end

local function moveProductsToCashier(npcState, spot, num)
	local offset = Vector3.new(0.7, 0, 0)
	local offset2 = Vector3.new(-0.7, 0, 0)
	local products = game.ReplicatedStorage:WaitForChild("Products")

	print("Moving products to cashier. Shopping list contains:", #npcState.shoppingList, "items")

	for i, item in ipairs(npcState.shoppingList) do
		if spot and spot:IsA("BasePart") and num == 1 then
			spot.Num.Value += 1
			local itemDuplicate = products:WaitForChild(item.Name):Clone()

			if itemDuplicate then
				itemDuplicate.Parent = spot
				itemDuplicate.Position = spot.Position + offset * i
				itemDuplicate.Name = item.Name
				print("Created item at checkout:", item.Name)
			else
				warn("Failed to clone product:", item.Name)
			end
		elseif spot and spot:IsA("BasePart") and num == 2 then
			spot.Num.Value += 1
			local itemDuplicate = products:WaitForChild(item.Name):Clone()

			if itemDuplicate then
				itemDuplicate.Parent = spot
				itemDuplicate.Position = spot.Position + offset2 * i
				itemDuplicate.Name = item.Name
				print("Created item at checkout:", item.Name)
			else
				warn("Failed to clone product:", item.Name)
			end
		else
			warn("Invalid cashier spot")
			break
		end
	end
end

local function leaveTheStore(npcState)
	local maxAttempts = 3

	local function attemptPathfinding(position, attempts)
		for _ = 1, attempts do
			if moveToPosition(npcState, position) then
				return true
			end
			task.wait(0.5)
		end
		return false
	end

	local function waitForDispatch(dispatch, cashierNum)
		local maxWaitTime = 30
		local startTime = tick()

		dispatch.Value = false
		local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
		for _, label in ipairs(frame:GetChildren()) do
			if label:IsA("TextLabel") and label.Name ~= "OXXO" then
				label:Destroy()
			end
		end

		while not dispatch.Value do
			task.wait(1)

			if not npcState.npcModel.Parent then
				if cashierNum == 1 then
					cashier1Bool.Value = false
				else
					cashier2Bool.Value = false
				end
				return false
			end

			if tick() - startTime > maxWaitTime then
				warn("Dispatch wait timeout for cashier", cashierNum)
				return false
			end
		end

		return true
	end

	local function tryQueue()
		npcState.isAtCashier = false
		npcState.currentCashier = nil

		local booleans = queue.Booleans:GetChildren()
		for _, bool in ipairs(booleans) do
			if not bool.Value then
				local positionNum = bool.Name
				local queuePosition = queue:FindFirstChild(positionNum)
				if queuePosition then
					bool.Value = true

					if attemptPathfinding(queuePosition.Position, maxAttempts) then
						while cashier1Bool.Value and cashier2Bool.Value do
							task.wait(2)
							if not npcState.npcModel.Parent then
								bool.Value = false
								return
							end
						end
						bool.Value = false
						leaveTheStore(npcState)
						return
					else
						bool.Value = false
					end
				end
			end
		end

		if not npcState.npcModel.Parent then
			return
		end
		npcState.npcModel:Destroy()
	end

	-- Try Cashier 1
	if not cashier1Bool.Value then
		local productSpot1 = workspace:FindFirstChild("productSpot1")
		if productSpot1 then
			cashier1Bool.Value = true
			npcState.isAtCashier = true
			npcState.currentCashier = 1

			if attemptPathfinding(cashier1.Position, maxAttempts) then
				moveProductsToCashier(npcState, productSpot1, 1)

				local dispatch = workspace.Caja:WaitForChild("Despachado")
				if waitForDispatch(dispatch, 1) then
					if npcState.isAtCashier and npcState.currentCashier == 1 then
						for _, item in ipairs(productSpot1:GetChildren()) do
							if item:IsA("BasePart") and item.Name ~= "Num" then
								item:Destroy()
							end
						end
						productSpot1.Num.Value = 0

						if attemptPathfinding(door.HitBox2.Position, maxAttempts) then
							cashier1Bool.Value = false
							npcState.npcModel:Destroy()
						end
					end
				else
					ChatService:Chat(npcState.npcModel.Head, "¡Oye, punk! ¡Acelera!")
					task.wait(10)

					for _, item in ipairs(productSpot1:GetChildren()) do
						if item:IsA("BasePart") and item.Name ~= "Num" then
							item:Destroy()
						end
					end
					productSpot1.Num.Value = 0
					cashier1Bool.Value = false
					npcState.npcModel:Destroy()
				end
			else
				cashier1Bool.Value = false
				tryQueue()
			end
			return
		end
	end

	-- Try Cashier 2
	if not cashier2Bool.Value then
		local productSpot2 = workspace:FindFirstChild("productSpot2")
		if productSpot2 then
			cashier2Bool.Value = true
			npcState.isAtCashier = true
			npcState.currentCashier = 2

			if attemptPathfinding(cashier2.Position, maxAttempts) then
				moveProductsToCashier(npcState, productSpot2, 2)

				local dispatch = workspace.Caja2:WaitForChild("Despachado")
				if waitForDispatch(dispatch, 2) then
					if npcState.isAtCashier and npcState.currentCashier == 2 then
						for _, item in ipairs(productSpot2:GetChildren()) do
							if item:IsA("BasePart") and item.Name ~= "Num" then
								item:Destroy()
							end
						end
						productSpot2.Num.Value = 0

						if attemptPathfinding(door.HitBox2.Position, maxAttempts) then
							cashier2Bool.Value = false
							npcState.npcModel:Destroy()
						end
					end
				else
					ChatService:Chat(npcState.npcModel.Head, "¡Oye, punk! ¡Acelera!")
					task.wait(10)

					for _, item in ipairs(productSpot2:GetChildren()) do
						if item:IsA("BasePart") and item.Name ~= "Num" then
							item:Destroy()
						end
					end
					productSpot2.Num.Value = 0
					cashier2Bool.Value = false
					npcState.npcModel:Destroy()
				end
			else
				cashier2Bool.Value = false
				tryQueue()
			end
			return
		end
	end

	if cashier1Bool.Value and cashier2Bool.Value then
		tryQueue()
	end
end

local function shop(npcState)
	if not moveToPosition(npcState, door.HitBox.Position) then
		warn("Failed to move to door")
		return
	end
	task.wait(0.5)

	local itemCount = math.random(1, 5)

	local availableItems = table.clone(shopItems)
	for _ = 1, itemCount do
		if #availableItems == 0 then
			break
		end
		local randomIndex = math.random(1, #availableItems)
		local selectedItem = availableItems[randomIndex]
		table.insert(npcState.shoppingList, selectedItem)
		table.remove(availableItems, randomIndex)
	end

	print("NPC shopping list created with", #npcState.shoppingList, "items:")
	for i, item in ipairs(npcState.shoppingList) do
		print(i, item.Name)
	end

	for _, item in ipairs(npcState.shoppingList) do
		if not moveToPosition(npcState, item.Position) then
			warn("Failed to move to item:", item.Name)
			continue
		end
		task.wait(0.5)
	end

	if #npcState.shoppingList > 0 then
		leaveTheStore(npcState)
	else
		warn("Shopping list is empty, NPC leaving store")
		moveToPosition(npcState, door.HitBox2.Position)
		npcState.npcModel:Destroy()
	end
end

function NPCShoppingModule.init(npc)
	-- Collision groups
	for _, part in ipairs(npc:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "NPCs"
		end
	end

	-- Create state for this NPC instance
	local npcState = createNPCState()
	npcState.npcModel = npc

	shop(npcState)
end

return NPCShoppingModule
