local nombreEquipo = "EMPAQUETADOR"  
local nombresHerramienta = {"CajaCongeladaReal"}
local CantidadVasos = game.Workspace.Stands.NeveraPrime:FindFirstChild("CantidadPrime")
local cantidadgas = workspace.Stands:WaitForChild("NeveraPrime")

local function actualizarContadorVaso()
	local contadorGUI = workspace.Stands.NeveraPrime.aviso8.SurfaceGui.TextLabel  
	if contadorGUI then
		contadorGUI.Text = tostring(cantidadgas.CantidadPrime.Value) .. "/36"
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
					CantidadVasos.Value = 36
					actualizarContadorVaso()

			
				end
			end
		end
	end
end)
