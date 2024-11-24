local ProximityPrompt = script.Parent
local item = script.Parent.Parent
local animationId = "rbxassetid://140361369670309"
local soundId = "rbxassetid://4934272176"

local contadorTextLabels = 0

local cashierSpots = {
	cashier1 = workspace:WaitForChild("CashierPosition"),
	cashier2 = workspace:WaitForChild("CashierPosition2"),
}

local monitorSpots = {
	monitor1 = workspace:WaitForChild("Caja"),
	monitor2 = workspace:WaitForChild("Caja2"),
}

local productSpots = {
	products = workspace:WaitForChild("productSpot1"),
	products2 = workspace:WaitForChild("productSpot2"),
}

local function disableMovement(humanoid)
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function findClosestCashier(item)
	local closestCashier = nil
	local closestDistance = math.huge

	for _, cashier in pairs(cashierSpots) do
		local distance = (cashier.Position - item.Position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestCashier = cashier
		end
	end

	return closestCashier
end

local function findClosestMonitor(item)
	local closestMonitor = nil
	local closestDistance = math.huge

	for _, monitor in pairs(monitorSpots) do
		local distance = (monitor.Pantalla.Position - item.Position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestMonitor = monitor
		end
	end

	return closestMonitor
end

local function findClosestProduct(item)
	local closestProduct = nil
	local closestDistance = math.huge

	for _, product in pairs(productSpots) do
		local distance = (product.Position - item.Position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestProduct = product
		end
	end

	return closestProduct
end

local function activar(jugador)
	if jugador.Team and jugador.Team.Name == "CAJERO" then
		local personaje = jugador.Character
		local humanoid = personaje:FindFirstChildOfClass("Humanoid")
		local closestCashier = findClosestCashier(item)
		local closestMonitor = findClosestMonitor(item)
		local closestProduct = findClosestProduct(item)

		local screen = closestMonitor:WaitForChild("Pantalla")
		local surfaceGui = screen:WaitForChild("SurfaceGui")
		local frame = surfaceGui:WaitForChild("Frame")
		local templateTextLabel = frame:WaitForChild("OXXO")

		if humanoid then
			disableMovement(humanoid)

			-- Stop all the animations
			local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end

			-- Create a new animation
			local animacion = Instance.new("Animation")
			animacion.AnimationId = animationId
			local trackAnimation = animator:LoadAnimation(animacion)

			trackAnimation:Play()

			-- Create a new sound
			local sonido = Instance.new("Sound")
			sonido.SoundId = soundId
			sonido.Parent = personaje.HumanoidRootPart

			-- wait(0.5)
			item.Anchored = false
			item.CanCollide = false

			-- Move the player to cashier position
			jugador.Character.HumanoidRootPart.CFrame = closestCashier.CFrame

			local hand = personaje:FindFirstChild("LeftHand") or personaje:WaitForChild("LeftHand")

			local motor = Instance.new("Motor6D")
			motor.Part0 = hand
			motor.Part1 = item
			motor.C0 = hand.CFrame:Inverse()
			motor.C1 = item.CFrame:Inverse()
			motor.Parent = hand
			wait(0.8)
			sonido:Play()

			item:Destroy()

			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

			if closestProduct then
				local numValue = closestProduct:FindFirstChild("Num")
				if numValue then
					numValue.Value = numValue.Value - 1
				end
			end

			if templateTextLabel then
				local nuevoTextLabel = templateTextLabel:Clone()
				nuevoTextLabel.Name = "TextLabel"
				nuevoTextLabel.Parent = frame

				nuevoTextLabel.Text = "[ + ]" .. item.Name

				nuevoTextLabel.Position = UDim2.new(0, 0, 0, contadorTextLabels * 10)

				contadorTextLabels = contadorTextLabels + 1
			end
		end
	end
end

ProximityPrompt.Triggered:Connect(activar)

-- Detect Position
-- Change text label depending on the position
