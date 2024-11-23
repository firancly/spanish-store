local proximidadPrompt = script.Parent
local parteADestruir = script.Parent.Parent
local idAnimacion = "rbxassetid://140361369670309"
local idSonido = "rbxassetid://4934272176"

local caja = workspace:WaitForChild("Caja2")
local pantalla = caja:WaitForChild("Pantalla")
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
			animacion.AnimationId = idAnimacion
			local pistaAnimacion = animador:LoadAnimation(animacion)

			local sonido = Instance.new("Sound")
			sonido.SoundId = idSonido
			sonido.Parent = personaje.HumanoidRootPart

			pistaAnimacion:Play()

			wait(0.5)
			parteADestruir.Anchored = false
			parteADestruir.CanCollide = false

			jugador.Character.HumanoidRootPart.CFrame = game.Workspace.CF2.CFrame

			local mano = personaje:FindFirstChild("LeftHand") or personaje:WaitForChild("LeftHand")

			local motor = Instance.new("Motor6D")
			motor.Part0 = mano
			motor.Part1 = parteADestruir
			motor.C0 = mano.CFrame:Inverse()
			motor.C1 = parteADestruir.CFrame:Inverse()
			motor.Parent = mano
			wait(0.8)
			sonido:Play()

			pistaAnimacion.Stopped:Wait()
			parteADestruir:Destroy()


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

				nuevoTextLabel.Text = "[ + ]" .. parteADestruir.Name  

				nuevoTextLabel.Position = UDim2.new(0, 0, 0, contadorTextLabels * 	10)  

				contadorTextLabels = contadorTextLabels + 1
			end

		end
	end
end

proximidadPrompt.Triggered:Connect(activar)
