local proximidadPrompt = script.Parent
local parteADestruir = script.Parent.Parent

local function activar(jugador)
	if jugador.Team and jugador.Team.Name == "CAJERO" then
		local personaje = jugador.Character
		local humanoide = personaje:FindFirstChildOfClass("Humanoid")

		if humanoide then

			wait(0.5)
			parteADestruir.Anchored = false
			parteADestruir.CanCollide = false

			jugador.Character.HumanoidRootPart.CFrame = game.Workspace.CF.CFrame

			local mano = personaje:FindFirstChild("LeftHand") or personaje:WaitForChild("LeftHand")

			local motor = Instance.new("Motor6D")
			motor.Part0 = mano
			motor.Part1 = parteADestruir
			motor.C0 = mano.CFrame:Inverse()
			motor.C1 = parteADestruir.CFrame:Inverse()
			motor.Parent = mano
			wait(0.8)

			parteADestruir:Destroy()


			local productos = workspace:FindFirstChild("productos")
			if productos then
				local numValue = productos:FindFirstChild("Num")
				if numValue then
					numValue.Value = numValue.Value - 1
				end
			end


		end
	end
end

proximidadPrompt.Triggered:Connect(activar)
