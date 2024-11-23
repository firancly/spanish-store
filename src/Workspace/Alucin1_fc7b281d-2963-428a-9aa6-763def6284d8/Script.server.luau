local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPC = script.Parent
local itemStands = workspace:WaitForChild("ItemStands")
local queue = workspace.CheckoutQueue
local cashier1 = workspace:WaitForChild("CashierSpot1")
local cashier2 = workspace:WaitForChild("CashierSpot2")
local cashier1Bool = workspace.Bools:WaitForChild("Cashier1")
local cashier2Bool = workspace.Bools:WaitForChild("Cashier2")

local shoppingList = {}
local shopItems = {
	{ Name = "Doritos", Position = itemStands.Doritos.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "BeefJerky", Position = itemStands.BeefJerky.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Takis", Position = itemStands.Takis.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Cereal", Position = itemStands.Cereal.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Juice", Position = itemStands.Juice.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Oreos", Position = itemStands.Oreos.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Vaseline", Position = itemStands.Vaseline.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Chips", Position = itemStands.Chips.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "Deodorant", Position = itemStands.Deodorant.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Gallons", Position = itemStands.Gallons.aviso.Position + Vector3.new(2, 0, 0) },
	{ Name = "Liquor", Position = itemStands.Liquor.aviso.Position + Vector3.new(-2, 0, 0) },
	{ Name = "ToiletPaper", Position = itemStands.ToiletPaper.aviso.Position + Vector3.new(-2, 0, 0) },
}

local door = workspace:WaitForChild("AutoDoor")
for _, part in ipairs(NPC:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CollisionGroup = "NPCs"
	end
end

local function moveToPosition(targetPosition)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(NPC.HumanoidRootPart.Position, targetPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			if not NPC.Parent then
				return
			end -- Check if NPC still exists
			NPC.Humanoid:MoveTo(waypoint.Position)
			NPC.Humanoid.MoveToFinished:Wait()
		end
		return true
	else
		warn("Path computation failed:", errorMessage)
		return false
	end
end

local products = game.ReplicatedStorage:WaitForChild("Products")
local function moveProductsToCashier(spot)
	local offset = Vector3.new(0.7, 0, 0)

	-- Debug print
	print("Moving products to cashier. Shopping list contains:", #shoppingList, "items")
	for i, item in ipairs(shoppingList) do
		print("Item", i, ":", item.Name)
	end

	for i, item in ipairs(shoppingList) do
		if spot and spot:IsA("BasePart") then
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
		else
			warn("Invalid cashier spot")
			break
		end
	end
end

local isAtCashier = false
local currentCashier = nil

local function leaveTheStore()
	if not cashier1Bool.Value then
		local productSpot1 = workspace:FindFirstChild("productSpot1")
		if productSpot1 then
			cashier1Bool.Value = true
			isAtCashier = true
			currentCashier = 1
			if moveToPosition(cashier1.Position) then
				moveProductsToCashier(productSpot1)

				-- Wait for Cashier 1's dispatch
				local dispatch = workspace.Caja:WaitForChild("Despachado")
				while not dispatch.Value do
					task.wait(2)
					if not NPC.Parent then
						return
					end
				end

				if isAtCashier and currentCashier == 1 then
					moveToPosition(door.HitBox2.Position)
					cashier1Bool.Value = false
					NPC:Destroy()
				end
			end
			return
		end
	elseif not cashier2Bool.Value then
		local productSpot2 = workspace:FindFirstChild("productSpot2")
		if productSpot2 then
			cashier2Bool.Value = true
			isAtCashier = true
			currentCashier = 2
			if moveToPosition(cashier2.Position) then
				moveProductsToCashier(productSpot2)

				-- Wait for Cashier 2's dispatch
				local dispatch = workspace.Caja2:WaitForChild("Despachado")
				while not dispatch.Value do
					task.wait(2)
					if not NPC.Parent then
						return
					end
				end

				if isAtCashier and currentCashier == 2 then
					moveToPosition(door.HitBox2.Position)
					cashier2Bool.Value = false
					NPC:Destroy()
				end
			end
			return
		end
	end

	-- If both cashiers are busy, go to queue
	if cashier1Bool.Value and cashier2Bool.Value then
		isAtCashier = false
		currentCashier = nil

		local booleans = queue.Booleans:GetChildren()
		for _, bool in ipairs(booleans) do
			if not bool.Value then
				local positionNum = bool.Name
				local queuePosition = queue:FindFirstChild(positionNum)
				if queuePosition then
					bool.Value = true
					moveToPosition(queuePosition.Position)
					break
				end
			end
		end
	end

	while cashier1Bool.Value and cashier2Bool.Value do
		task.wait(2)
	end

	leaveTheStore()
end

local function shop()
	if not moveToPosition(door.HitBox.Position) then
		warn("Failed to move to door")
		return
	end
	task.wait(0.5)

	-- Random number of items (1-5)
	local itemCount = math.random(1, 5)

	-- Create shopping list
	local availableItems = table.clone(shopItems)
	for _ = 1, itemCount do
		if #availableItems == 0 then
			break
		end
		local randomIndex = math.random(1, #availableItems)
		local selectedItem = availableItems[randomIndex]
		table.insert(shoppingList, selectedItem)
		table.remove(availableItems, randomIndex) -- Remove selected item so it's not picked again
	end

	-- Debug print
	print("NPC shopping list created with", #shoppingList, "items:")
	for i, item in ipairs(shoppingList) do
		print(i, item.Name)
	end

	-- Visit each item location
	for _, item in ipairs(shoppingList) do
		if not moveToPosition(item.Position) then
			warn("Failed to move to item:", item.Name)
			continue
		end
		task.wait(0.5) -- Short delay to simulate picking up item
	end

	if #shoppingList > 0 then
		leaveTheStore()
	else
		warn("Shopping list is empty, NPC leaving store")
		moveToPosition(door.HitBox2.Position)
		NPC:Destroy()
	end
end

shop()
