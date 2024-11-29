local ServerScriptService = game:GetService("ServerScriptService")
local ProductShelfManager = require(ServerScriptService.ProductShelfManager)

script.Parent.Triggered:Connect(function(player)
	-- Add check for teams
	ProductShelfManager.RestockShelf("Doritos")
	warn("RESTOCKED DORITOS")
end)
