local NPCShoppingModule = {}

-- Required Modules
local ProductShelfManager = require(script.Parent.ProductShelfManager)

-- Services
local PathfindingService = game:GetService("PathfindingService")
local ChatService = game:GetService("Chat")

local NPCState = {
	IDLE = "Idle",
	ENTERING_STORE = "EnteringStore",
	SELECTING_ITEMS = "SelectingItems",
	MOVING_TO_ITEM = "MovingToItem",
	PURCHASING_ITEM = "PurchasingItem",
	QUEUING = "Queuing",
	AT_CASHIER = "AtCashier",
	LEAVING_STORE = "LeavingStore",
}

local CONFIG = {
	MAX_SHOPPING_ITEMS = 5,
	MAX_PATHFIND_ATTEMPTS = 3,
	QUEUE_WAIT_TIMEOUT = 30,
	CASHIER_INTERACTION_TIMEOUT = 10,
}

local Dependencies = {
	itemStands = nil,
	queue = nil,
	cashiers = nil,
	door = nil,
}

-- Utility Functions
local function safePathfind(npc, targetPosition)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(npc.HumanoidRootPart.Position, targetPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			npc.Humanoid:MoveTo(waypoint.Position)
			npc.Humanoid.MoveToFinished:Wait()
		end
		return true
	else
		warn("Pathfinding failed:", errorMessage)
		return false
	end
end

function NPCShoppingModule.new(npc)
	local self = setmetatable({}, { __index = NPCShoppingModule })

	self.npc = npc
	self.currentState = NPCState.IDLE
	self.shoppingList = {}
	self.remainingItems = {}

	self.isAtCashier = false
	self.currentCashier = nil

	return self
end

function NPCShoppingModule:transitionTo(newState)
	print("Transitioning from", self.currentState, "to", newState)
	self.currentState = newState
end

function NPCShoppingModule:handleEnteringStore()
	if not safePathfind(self.npc, Dependencies.door.HitBox.Position) then
		self:transitionTo(NPCState.IDLE)
		return false
	end

	self:transitionTo(NPCState.SELECTING_ITEMS)
	return true
end

function NPCShoppingModule:handleSelectingItems()
	local availableItems = table.clone(Dependencies.shopItems)
	local itemCount = math.random(1, CONFIG.MAX_SHOPPING_ITEMS)

	self.shoppingList = {}
	for _ = 1, itemCount do
		if #availableItems < 0 then
			break
		end

		local randomIndex = math.random(1, #availableItems)
		table.insert(self.shoppingList, table.remove(availableItems, randomIndex))
	end

	self:transitionTo(NPCState.MOVING_TO_ITEM)
	return true
end

function NPCShoppingModule:handleMovingToItem()
	if #self.shoppingList == 0 then
		self:transitionTo(NPCState.LEAVING_STORE)
		return true
	end

	local currentItem = self.shoppingList[1]
	local itemStands = workspace:WaitForChild("ItemStands")
	if currentItem.Position == 2 then
		currentItem.Position = itemStands:FindFirstChild(currentItem.Name).aviso.Position + Vector3.new(2, 0, 0)
	else
		currentItem.Position = itemStands:FindFirstChild(currentItem.Name).aviso.Position + Vector3.new(-2, 0, 0)
	end
	if not safePathfind(self.npc, currentItem.Position) then
		table.remove(self.shoppingList, 1)
		return false
	end

	self:transitionTo(NPCState.PURCHASING_ITEM)
	return true
end

function NPCShoppingModule:handlePurchasingItem()
	local currentItem = self.shoppingList[1]

	if ProductShelfManager.PurchaseItem(currentItem.Name) then
		table.insert(self.remainingItems, currentItem)
		table.remove(self.shoppingList, 1)
		self:transitionTo(NPCState.MOVING_TO_ITEM)
	else
		ChatService:Chat(self.npc.Head, "Dónde está " .. currentItem.Name .. " 😡")
		table.remove(self.shoppingList, 1)
	end

	return true
end

function NPCShoppingModule:handleLeaving()
	if not Dependencies.cashier1Bool.Value then
		local productSpot1 = workspace:FindFirstChild("productSpot1")
		if productSpot1 then
			Dependencies.cashier1Bool.Value = true
			self.isAtCashier = true
			self.currentCashier = 1

			if safePathfind(self.npc, Dependencies.cashier1.Position) then
				local humanoidRootPart = self.npc:FindFirstChild("HumanoidRootPart")
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
					* (Dependencies.cashier1.CFrame - Dependencies.cashier1.CFrame.Position).Rotation

				self:moveProductsToCashier(productSpot1, 1)

				local dispatch = workspace.Caja:WaitForChild("Despachado")
				if self:waitForDispatch(dispatch, 1) then
					self:clearProductSpot(productSpot1)

					if safePathfind(self.npc, Dependencies.door.HitBox2.Position) then
						Dependencies.cashier1Bool.Value = false
						self.npc:Destroy()
						return true
					end
				else
					self:handleDispatchFailure(productSpot1, 1)
				end
			end
		end
	elseif not Dependencies.cashier2Bool.Value then
		local productSpot2 = workspace:FindFirstChild("productSpot2")
		if productSpot2 then
			Dependencies.cashier2Bool.Value = true
			self.isAtCashier = true
			self.currentCashier = 2

			if safePathfind(self.npc, Dependencies.cashier2.Position) then
				local humanoidRootPart = self.npc:FindFirstChild("HumanoidRootPart")
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
					* (Dependencies.cashier2.CFrame - Dependencies.cashier2.CFrame.Position).Rotation

				self:moveProductsToCashier(productSpot2, 2)

				local dispatch = workspace.Caja2:WaitForChild("Despachado")
				if self:waitForDispatch(dispatch, 2) then
					self:clearProductSpot(productSpot2)

					if safePathfind(self.npc, Dependencies.door.HitBox2.Position) then
						Dependencies.cashier2Bool.Value = false
						self.npc:Destroy()
						return true
					end
				else
					self:handleDispatchFailure(productSpot2, 2)
				end
			end
		end
	end

	return self:handleQueueing()
end

-- Helper Methods
function NPCShoppingModule:moveProductsToCashier(spot, cashierNum)
	local offset = cashierNum == 1 and Vector3.new(0.7, 0, 0) or Vector3.new(-0.7, 0, 0)
	local products = game.ReplicatedStorage.Products

	for i, item in ipairs(self.remainingItems) do
		if spot and spot:IsA("BasePart") then
			spot.Num.Value += 1
			local itemDuplicate = products:WaitForChild(item.Name):Clone()

			if itemDuplicate then
				itemDuplicate.Parent = spot
				itemDuplicate.Position = spot.Position + offset * i
				itemDuplicate.Name = item.Name
			else
				warn("Failed to clone product:", item.Name)
			end
		end
	end
end

function NPCShoppingModule:waitForDispatch(dispatch, cashierNum)
	local maxWaitTime = CONFIG.CASHIER_INTERACTION_TIMEOUT
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

		if not self.npc.Parent then
			if cashierNum == 1 then
				Dependencies.cashier1Bool.Value = false
			else
				Dependencies.cashier2Bool.Value = false
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

function NPCShoppingModule:handleDispatchFailure(productSpot, cashierNum)
	ChatService:Chat(self.npc.Head, "¡Oye, punk! ¡Acelera!")
	task.wait(10)

	self:clearProductSpot(productSpot)

	-- Free cashier spot and remove items from the display
	if cashierNum == 1 then
		Dependencies.cashier1Bool.Value = false

		local dispatch = workspace.Caja:WaitForChild("Despachado")
		local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
		for _, label in ipairs(frame:GetChildren()) do
			if label:IsA("TextLabel") and label.Name ~= "OXXO" then
				label:Destroy()
			end
		end
	else
		Dependencies.cashier2Bool.Value = false

		local dispatch = workspace.Caja2:WaitForChild("Despachado")
		local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
		for _, label in ipairs(frame:GetChildren()) do
			if label:IsA("TextLabel") and label.Name ~= "OXXO" then
				label:Destroy()
			end
		end
	end

	self.npc:Destroy()
end

function NPCShoppingModule:clearProductSpot(productSpot)
	for _, item in ipairs(productSpot:GetChildren()) do
		if item:IsA("BasePart") and item.Name ~= "Num" then
			item:Destroy()
		end
	end
	productSpot.Num.Value = 0
end

function NPCShoppingModule:handleQueueing()
	local booleans = Dependencies.queue.Booleans:GetChildren()
	for _, bool in ipairs(booleans) do
		if not bool.Value then
			local positionNum = bool.Name
			local queuePosition = Dependencies.queue:FindFirstChild(positionNum)

			if queuePosition then
				bool.Value = true

				if safePathfind(self.npc, queuePosition.Position) then
					local humanoidRootPart = self.npc:FindFirstChild("HumanoidRootPart")
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
						* (queuePosition.CFrame - queuePosition.CFrame.Position).Rotation

					while Dependencies.cashier1Bool.Value and Dependencies.cashier2Bool.Value do
						task.wait(2)
						if not self.npc.Parent then
							bool.Value = false
							return false
						end
					end

					bool.Value = false
					return self:handleLeaving()
				else
					bool.Value = false
				end
			end
		end
	end

	if self.npc.Parent then
		self.npc:Destroy()
	end

	return true
end

function NPCShoppingModule:update()
	local stateHandlers = {
		[NPCState.ENTERING_STORE] = self.handleEnteringStore,
		[NPCState.SELECTING_ITEMS] = self.handleSelectingItems,
		[NPCState.MOVING_TO_ITEM] = self.handleMovingToItem,
		[NPCState.PURCHASING_ITEM] = self.handlePurchasingItem,
		[NPCState.LEAVING_STORE] = self.handleLeaving,
	}

	local handler = stateHandlers[self.currentState]
	if handler then
		return handler(self)
	end
end

function NPCShoppingModule.init(npc)
	Dependencies.itemStands = workspace:WaitForChild("ItemStands")
	Dependencies.cashier1 = workspace:WaitForChild("CashierSpot1")
	Dependencies.cashier2 = workspace:WaitForChild("CashierSpot2")
	Dependencies.cashier1Bool = workspace.Bools:WaitForChild("Cashier1")
	Dependencies.cashier2Bool = workspace.Bools:WaitForChild("Cashier2")
	Dependencies.queue = workspace.CheckoutQueue
	Dependencies.door = workspace:WaitForChild("AutoDoor")
	Dependencies.shopItems = {
		{ Name = "Doritos", Position = 2 },
		{ Name = "Carne", Position = 2 },
		{ Name = "Takis", Position = -2 },
		{ Name = "Cereal", Position = -2 },
		{ Name = "Snapple", Position = 2 },
		{ Name = "Oreo", Position = 2 },
		{ Name = "Vaselina", Position = -2 },
		{ Name = "Chips", Position = -2 },
		{ Name = "Desodorante", Position = 2 },
		{ Name = "Galon", Position = 2 },
		{ Name = "Vasitos", Position = -2 },
		{ Name = "Papel", Position = -2 },
	}

	for _, part in ipairs(npc:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "NPCs"
		end
	end

	local stateMachine = NPCShoppingModule.new(npc)
	stateMachine:transitionTo(NPCState.ENTERING_STORE)

	task.spawn(function()
		while npc.Parent do
			stateMachine:update()
			task.wait(0.5)
		end
	end)
end

return NPCShoppingModule
