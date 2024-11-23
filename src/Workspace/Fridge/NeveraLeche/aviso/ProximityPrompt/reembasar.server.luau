local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaCongeladaReal"}
local CantidadVasos = game.Workspace.Stands.NeveraLeche:FindFirstChild("CantidadLeches")
local cantidadgas = workspace.Stands:WaitForChild("NeveraLeche")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.NeveraLeche.avisoleshe.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgas.CantidadLeches.Value) .. "/12"
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
					CantidadVasos.Value = 12
					actualizarContadorVaso()

			
				end
			end
		end
	end
end)
