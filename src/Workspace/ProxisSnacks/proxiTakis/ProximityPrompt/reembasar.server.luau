local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaSnackReal"}
local CantidadVasos = game.Workspace.Stands.EstanteriaPapitas:FindFirstChild("CantidadPapitas")
local cantidadvasos = workspace.Stands:WaitForChild("EstanteriaPapitas")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.EstanteriaPapitas.aviso3.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadvasos.CantidadPapitas.Value) .. "/15"
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
