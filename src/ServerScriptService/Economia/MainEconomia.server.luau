local DataStoreService = game:GetService("DataStoreService")
local sueldoDataStore = DataStoreService:GetDataStore("SueldoDataStore")
local oxxoDataStore = DataStoreService:GetDataStore("OxxoDataStore")


local function cargarDatosJugador(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local sueldo = Instance.new("IntValue")
	sueldo.Name = "Sueldo"
	sueldo.Value = 0
	sueldo.Parent = leaderstats

	local success, savedSueldo = pcall(function()
		return sueldoDataStore:GetAsync(player.UserId)
	end)
	if success and savedSueldo then
		sueldo.Value = savedSueldo
	end
end

local function guardarDatosJugador(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local sueldo = leaderstats:FindFirstChild("Sueldo")
		if sueldo then
			pcall(function()
				sueldoDataStore:SetAsync(player.UserId, sueldo.Value)
			end)
		end
	end
end

game.Players.PlayerAdded:Connect(cargarDatosJugador)

game.Players.PlayerRemoving:Connect(function(player)
	guardarDatosJugador(player)
end)


