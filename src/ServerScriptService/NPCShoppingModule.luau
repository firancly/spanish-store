-- NPCShoppingModule: Manages NPC shopping behavior in the store.
local NPCShoppingModule = {}

-- Required Modules
local ProductShelfManager = require(script.Parent.ProductShelfManager)

-- Services
local PathfindingService = game:GetService("PathfindingService")
local ChatService = game:GetService("Chat")

-- Define NPC States for different shopping stages
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

-- Configuration Settings for NPC Shopping Behavior
local CONFIG = {
	MAX_SHOPPING_ITEMS = 5,
	MAX_PATHFIND_ATTEMPTS = 3,
	QUEUE_WAIT_TIMEOUT = 30,
	CASHIER_INTERACTION_TIMEOUT = 10,
}

-- Dependencies for accessing in-game objects
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
		for _, waypoint in waypoints do
			npc.Humanoid:MoveTo(waypoint.Position)
			npc.Humanoid.MoveToFinished:Wait()
		end
		return true
	else
		warn("Pathfinding failed:", errorMessage)
		return false
	end
end

-- Create a new NPC shopping instance
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

-- Transition the NPC to a new state
function NPCShoppingModule:transitionTo(newState)
	-- print("Transitioning from", self.currentState, "to", newState)
	self.currentState = newState
end

-- Handle NPC entering the store
function NPCShoppingModule:handleEnteringStore()
	if not safePathfind(self.npc, Dependencies.door.HitBox.Position) then
		self:transitionTo(NPCState.IDLE)
		return false
	end

	self:transitionTo(NPCState.SELECTING_ITEMS)
	return true
end

-- NPC selects random items to purchase
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

-- NPC moves to item locations and attempts to purchase
function NPCShoppingModule:handleMovingToItem()
	warn(#self.shoppingList)
	if #self.shoppingList == 0 then
		-- Leave if cart is empty
		if #self.remainingItems < 1 then
			safePathfind(self.npc, Dependencies.door.HitBox2.Position)
			self.npc:Destroy()
		end
		-- Move to checkout
		self:transitionTo(NPCState.LEAVING_STORE)
		return true
	end

	local currentItem = self.shoppingList[1]
	local itemStands = workspace:WaitForChild("ItemStands")
	local itemStand = itemStands:FindFirstChild(currentItem.Name)

	if not itemStand then
		warn("Item stand not found for:", currentItem.Name)
		table.remove(self.shoppingList, 1)
		return false
	end

	local offsetX = currentItem.Position > 0 and 2 or -2
	local targetPosition = itemStand.aviso.Position + Vector3.new(offsetX, 0, 0)

	if not safePathfind(self.npc, targetPosition) then
		table.remove(self.shoppingList, 1)
		return false
	end

	self:transitionTo(NPCState.PURCHASING_ITEM)
	return true
end

-- NPC attempts to purchase the item
function NPCShoppingModule:handlePurchasingItem()
	local currentItem = self.shoppingList[1]

	if ProductShelfManager.PurchaseItem(currentItem.Name) then
		table.insert(self.remainingItems, currentItem)
		table.remove(self.shoppingList, 1)
		self:transitionTo(NPCState.MOVING_TO_ITEM)
	else
		ChatService:Chat(self.npc.Head, "Dónde está " .. currentItem.Name .. " 😡")
		table.remove(self.shoppingList, 1)
		self:transitionTo(NPCState.MOVING_TO_ITEM)
	end

	return true
end

-- NPC leaves the store after checkout or failed shopping
function NPCShoppingModule:handleLeaving()
	-- Attempt to process at first cashier
	if not Dependencies.cashier1Bool.Value then
		local productSpot1 = workspace:FindFirstChild("productSpot1")
		if not productSpot1 then
			return self:handleQueueing()
		end

		Dependencies.cashier1Bool.Value = true
		self.isAtCashier = true
		self.currentCashier = 1

		if
			not self:processCashier(productSpot1, Dependencies.cashier1, workspace.Caja:WaitForChild("Despachado"), 1)
		then
			return self:handleQueueing()
		end

	-- Attempt to process at second cashier
	elseif not Dependencies.cashier2Bool.Value then
		local productSpot2 = workspace:FindFirstChild("productSpot2")
		if not productSpot2 then
			return self:handleQueueing()
		end

		Dependencies.cashier2Bool.Value = true
		self.isAtCashier = true
		self.currentCashier = 2

		if
			not self:processCashier(productSpot2, Dependencies.cashier2, workspace.Caja2:WaitForChild("Despachado"), 2)
		then
			return self:handleQueueing()
		end
	end

	return self:handleQueueing()
end

-- Process cashier interactions
function NPCShoppingModule:processCashier(productSpot, cashier, dispatch, cashierNumber)
	if not safePathfind(self.npc, cashier.Position) then
		return false
	end

	-- Adjust NPC's orientation at cashier
	local humanoidRootPart = self.npc:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
		* (cashier.CFrame - cashier.CFrame.Position).Rotation

	self:moveProductsToCashier(productSpot, cashierNumber)

	if not self:waitForDispatch(dispatch, cashierNumber) then
		self:handleDispatchFailure(productSpot, cashierNumber)
		return false
	end

	self:clearProductSpot(productSpot)

	if not safePathfind(self.npc, Dependencies.door.HitBox2.Position) then
		return false
	end

	-- Reset cashier availability and destroy NPC
	if cashierNumber == 1 then
		Dependencies.cashier1Bool.Value = false
	else
		Dependencies.cashier2Bool.Value = false
	end

	self.npc:Destroy()
	return true
end

-- Helper Methods
-- Move products from NPC inventory to the counter
function NPCShoppingModule:moveProductsToCashier(spot, cashierNum)
	local offset = cashierNum == 1 and Vector3.new(0.7, 0, 0) or Vector3.new(-0.7, 0, 0)
	local products = game.ReplicatedStorage.Products

	for i, item in self.remainingItems do
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

-- Wait for the NPC to be dispatched, ensuring a smooth checkout process
function NPCShoppingModule:waitForDispatch(dispatch, cashierNum)
	local maxWaitTime = CONFIG.CASHIER_INTERACTION_TIMEOUT
	local startTime = tick()

	dispatch.Value = false
	local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
	for _, label in frame:GetChildren() do
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

-- Handle NPC failure to complete dispatch due to timeout or other issues
function NPCShoppingModule:handleDispatchFailure(productSpot, cashierNum)
	ChatService:Chat(self.npc.Head, "¡Oye, punk! ¡Acelera!")
	task.wait(10)

	self:clearProductSpot(productSpot)

	-- Free cashier spot and remove items from the display
	if cashierNum == 1 then
		Dependencies.cashier1Bool.Value = false

		local dispatch = workspace.Caja:WaitForChild("Despachado")
		local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
		for _, label in frame:GetChildren() do
			if label:IsA("TextLabel") and label.Name ~= "OXXO" then
				label:Destroy()
			end
		end
	else
		Dependencies.cashier2Bool.Value = false

		local dispatch = workspace.Caja2:WaitForChild("Despachado")
		local frame = dispatch.Parent.Pantalla.SurfaceGui.Frame
		for _, label in frame:GetChildren() do
			if label:IsA("TextLabel") and label.Name ~= "OXXO" then
				label:Destroy()
			end
		end
	end

	self.npc:Destroy()
end

-- Clear all products from the checkout spot after transaction or failure
function NPCShoppingModule:clearProductSpot(productSpot)
	for _, item in productSpot:GetChildren() do
		if item:IsA("BasePart") and item.Name ~= "Num" then
			item:Destroy()
		end
	end
	productSpot.Num.Value = 0
end

-- Manage NPC queueing system to avoid multiple NPCs occupying the same spot
function NPCShoppingModule:handleQueueing()
	local booleans = Dependencies.queue.Booleans:GetChildren()
	for _, bool in booleans do
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

-- Update NPC behavior based on its current state
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

	for _, part in npc:GetDescendants() do
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
