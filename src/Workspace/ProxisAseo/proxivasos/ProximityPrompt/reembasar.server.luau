local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaAseoReal"}
local CantidadVasos = game.Workspace.Stands.EstanteriaVasos:FindFirstChild("CantidadVasos")
local cantidadvasos = workspace.Stands:WaitForChild("EstanteriaVasos")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.EstanteriaVasos.aviso7.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadvasos.CantidadVasos.Value) .. "/24"
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

				if CantidadVasos then
					CantidadVasos.Value = 24
					actualizarContadorVaso()

			
				end
			end
		end
	end
end)
