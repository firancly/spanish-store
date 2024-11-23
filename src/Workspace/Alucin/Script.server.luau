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

	path:ComputeAsync(NPC.HumanoidRootPart.Position, targetPosition)
	print("Path Status: " .. tostring(path.Status))

	if path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			NPC.Humanoid:MoveTo(waypoint.Position)
			NPC.Humanoid.MoveToFinished:Wait()
		end
	end
end

local products = game.ReplicatedStorage:WaitForChild("Products")
local function moveProductsToCashier(spot) -- counter spot
	local offset = Vector3.new(1, 0, 0)
	local itemCounter = 0

	-- Remove when interacted with them
	-- Press confirm to finish transaction

	for _, item in ipairs(shoppingList) do
		itemCounter += 1
		spot.Num.Value += 1
		local itemDuplicate = products:WaitForChild(item.Name):Clone()

		itemDuplicate.Parent = spot
		itemDuplicate.Position = spot.Position + offset * itemCounter
		itemDuplicate.Name = item.Name
	end
end

local function moveToCheckout()
	if cashier1Bool.Value == false then
		local productSpot1 = workspace:FindFirstChild("productSpot1")
		moveToPosition(cashier1.Position)
		cashier1Bool.Value = true
		moveProductsToCashier(productSpot1)
	elseif cashier2Bool.Value == false then
		local productSpot2 = workspace:FindFirstChild("productSpot2")
		moveToPosition(cashier2.Position)
		cashier2Bool.Value = true
		moveProductsToCashier(productSpot2)
	end
end

local function shop()
	moveToPosition(door.HitBox.Position)
	task.wait(0.5)

	local itemCount = math.random(2) -- Max products npc can buy

	for _ = 1, itemCount do
		local randomItem = shopItems[math.random(1, #shopItems)]
		table.insert(shoppingList, randomItem)
	end

	print(shoppingList)

	for _, item in pairs(shoppingList) do
		moveToPosition(item.Position)
		print(item.Name)
		shoppingList[item] = nil
		task.wait(3)
	end
	print(shoppingList)
	moveToCheckout()

	print("moved to checkout")
end

shop()

local dispatch = game.Workspace.Caja:WaitForChild("Despachado")

while dispatch.Value == false do
	print("waiting")
	task.wait(2)
end

if dispatch.Value == true then
	print("Going to exit")
	moveToPosition(door.HitBox2.Position)
	NPC:Destroy()
end

for _, item in shoppingList do
	print(item.Name)
end
