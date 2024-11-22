local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaAseoReal"}
local Cantidad = game.Workspace.Stands.EstanteriaDesodorante:FindFirstChild("CantidadDeso")
local cantidadgal = workspace.Stands:WaitForChild("EstanteriaDesodorante")

local function actualizarContador()
	local contadorGUI = workspace.Stands.EstanteriaDesodorante.aviso10.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgal.CantidadDeso.Value) .. "/36"
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
					Cantidad.Value = 36
					actualizarContador()

			
				end
			end
		end
	end
end)
