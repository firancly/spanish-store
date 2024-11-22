local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaAseoReal"}
local Cantidad = game.Workspace.Stands.EstanteriaGalones:FindFirstChild("CantidadGalon")
local cantidadgal = workspace.Stands:WaitForChild("EstanteriaGalones")

local function actualizarContador()
	local contadorGUI = workspace.Stands.EstanteriaGalones.aviso9.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgal.CantidadGalon.Value) .. "/20"
	end
end

script.Parent.Triggered:Connect(function(jugador)
	if jugador.Team and jugador.Team.Name == nombreEquipo then
		local personaje = jugador.Character
		if personaje then
			local herramientaEnMano = nil
			for _, nombre in ipairs(nombresHerramienta) do
				herramientaEnMano = personaje:FindFirstChild(nombre)
				if herramientaEnMano then
					break
				end
			end

			if herramientaEnMano then
				herramientaEnMano:Destroy()

				if Cantidad then
					Cantidad.Value = 20
					actualizarContador()

			
				end
			end
		end
	end
end)
