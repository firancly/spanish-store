local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")

local NPC = script.Parent
local itemStands = workspace:WaitForChild("ItemStands")
local queue = workspace.CheckoutQueue
local cashier1 = workspace:WaitForChild("CashierSpot1")
local cashier2 = workspace:WaitForChild("CashierSpot2")
local cashier1Bool = workspace.Bools:WaitForChild("Cashier1")
local cashier2Bool = workspace.Bools:WaitForChild("Cashier2")

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

local function moveToCheckout()
	if cashier1Bool.Value == false then
		moveToPosition(cashier1.Position)
		cashier1Bool.Value = true
	elseif cashier2Bool.Value == false then
		moveToPosition(cashier2.Position)
		cashier2Bool.Value = true
	end
end

local function shop()
	moveToPosition(door.HitBox.Position)
	task.wait(0.5)

	local shoppingList = {}
	local itemCount = math.random(5)

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
end

shop()
