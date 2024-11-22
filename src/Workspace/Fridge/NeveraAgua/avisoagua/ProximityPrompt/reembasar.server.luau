local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaCongeladaReal"}
local CantidadVasos = game.Workspace.Stands.NeveraAgua:FindFirstChild("CantidadAgua")
local cantidadgas = workspace.Stands:WaitForChild("NeveraAgua")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.NeveraAgua.avisoagua.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgas.CantidadAgua.Value) .. "/15"
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
					CantidadVasos.Value = 15
					actualizarContadorVaso()

			
				end
			end
		end
	end
end)
