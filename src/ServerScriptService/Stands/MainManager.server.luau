local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local npcsFolder1 = StarterGui:WaitForChild("NPCs")
local npcsFolder2 = StarterGui:WaitForChild("NPCs2")
local puntoDeInicio1 = workspace:WaitForChild("PuntoDeInicio")
local puntoDeInicio2 = workspace:WaitForChild("PuntoDeInicio2")

local TIEMPO_DUPLICACION = 2
local MAX_NPCS = 3

local function calcularNPCsRestantes(puntoDeInicio)
	return math.max(0, MAX_NPCS - #puntoDeInicio:GetChildren())
end

local function obtenerNPCsAleatorios(npcs, cantidad)
	local seleccionados = {}
	local indicesUsados = {}
	while #seleccionados < cantidad and #seleccionados < #npcs do
		local indice = math.random(1, #npcs)
		if not indicesUsados[indice] then
			table.insert(seleccionados, npcs[indice])
			indicesUsados[indice] = true
		end
	end
	return seleccionados
end

local function duplicarNPC(npc, destino)
	local nuevoNPC = npc:Clone()
	nuevoNPC.Parent = destino
end

if npcsFolder1 and npcsFolder2 and puntoDeInicio1 and puntoDeInicio2 then
	local tiempoAcumulado = 0

	RunService.Heartbeat:Connect(function(deltaTime)
		tiempoAcumulado += deltaTime
		if tiempoAcumulado >= TIEMPO_DUPLICACION then
			tiempoAcumulado = 0

			local cantidadRestante1 = calcularNPCsRestantes(puntoDeInicio1)
			if cantidadRestante1 > 0 then
				local npcsAleatorios1 = obtenerNPCsAleatorios(npcsFolder1:GetChildren(), cantidadRestante1)
				for _, npc in ipairs(npcsAleatorios1) do
					duplicarNPC(npc, puntoDeInicio1)
				end
			end

			local cantidadRestante2 = calcularNPCsRestantes(puntoDeInicio2)
			if cantidadRestante2 > 0 then
				local npcsAleatorios2 = obtenerNPCsAleatorios(npcsFolder2:GetChildren(), cantidadRestante2)
				for _, npc in ipairs(npcsAleatorios2) do
					duplicarNPC(npc, puntoDeInicio2)
				end
			end
		end
	end)
else
	warn("Alguna de las carpetas o puntos de inicio no se encontraron, deteniendo duplicación.")
end
