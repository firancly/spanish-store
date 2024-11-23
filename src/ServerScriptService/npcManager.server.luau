local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local npcsFolder1 = ServerStorage:WaitForChild("NPCs")
local spawnpoint = workspace:WaitForChild("PuntoDeInicio")
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

if npcsFolder1 and spawnpoint then
	local tiempoAcumulado = 0

	RunService.Heartbeat:Connect(function(deltaTime)
		tiempoAcumulado += deltaTime
		if tiempoAcumulado >= TIEMPO_DUPLICACION then
			tiempoAcumulado = 0

			local cantidadRestante1 = calcularNPCsRestantes(spawnpoint)
			if cantidadRestante1 > 0 then
				local npcsAleatorios1 = obtenerNPCsAleatorios(npcsFolder1:GetChildren(), cantidadRestante1)
				for _, npc in ipairs(npcsAleatorios1) do
					duplicarNPC(npc, spawnpoint)
				end
			end
		end
	end)
else
	warn("Alguna de las carpetas o puntos de inicio no se encontraron, deteniendo duplicación.")
end
