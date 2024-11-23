local ProximityPrompt = script.Parent
local item = script.Parent.Parent
local animationId = "rbxassetid://140361369670309"
local soundId = "rbxassetid://4934272176"

local cashier = workspace:WaitForChild("Caja")
local pantalla = cashier:WaitForChild("Pantalla")
local surfaceGui = pantalla:WaitForChild("SurfaceGui")
local frame = surfaceGui:WaitForChild("Frame")
local templateTextLabel = frame:WaitForChild("OXXO")

local contadorTextLabels = 0

local function activar(jugador)
	if jugador.Team and jugador.Team.Name == "CAJERO" then
		local personaje = jugador.Character
		local humanoide = personaje:FindFirstChildOfClass("Humanoid")

		if humanoide then
			humanoide.WalkSpeed = 0
			humanoide.JumpPower = 0
			humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

			local animador = humanoide:FindFirstChild("Animator") or humanoide:WaitForChild("Animator")

			for _, track in ipairs(animador:GetPlayingAnimationTracks()) do
				track:Stop()
			end

			local animacion = Instance.new("Animation")
			animacion.AnimationId = animationId
			local pistaAnimacion = animador:LoadAnimation(animacion)

			local sonido = Instance.new("Sound")
			sonido.SoundId = soundId
			sonido.Parent = personaje.HumanoidRootPart

			pistaAnimacion:Play()

			wait(0.5)
			item.Anchored = false
			item.CanCollide = false

			jugador.Character.HumanoidRootPart.CFrame = game.Workspace.CF2.CFrame

			local mano = personaje:FindFirstChild("LeftHand") or personaje:WaitForChild("LeftHand")

			local motor = Instance.new("Motor6D")
			motor.Part0 = mano
			motor.Part1 = item
			motor.C0 = mano.CFrame:Inverse()
			motor.C1 = item.CFrame:Inverse()
			motor.Parent = mano
			wait(0.8)
			sonido:Play()

			pistaAnimacion.Stopped:Wait()
			item:Destroy()

			humanoide.WalkSpeed = 16
			humanoide.JumpPower = 50
			humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

			local productos = workspace:FindFirstChild("productos2")
			if productos then
				local numValue = productos:FindFirstChild("Num")
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
