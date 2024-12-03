local ProductShelfManager = {}

local SHELF_CONFIG = {
	["Carne"] = {
		maxQuantity = 12,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Cereal"] = {
		maxQuantity = 12,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Doritos"] = {
		maxQuantity = 10,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Takis"] = {
		maxQuantity = 15,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Vaselina"] = {
		maxQuantity = 25,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Chips"] = {
		maxQuantity = 20,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Snapple"] = {
		maxQuantity = 10,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Oreo"] = {
		maxQuantity = 12,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Galon"] = {
		maxQuantity = 20,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Desodorante"] = {
		maxQuantity = 36,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Papel"] = {
		maxQuantity = 20,
		restockThreshold = 5,
		currentQuantity = 1,
	},
	["Vasitos"] = {
		maxQuantity = 24,
		restockThreshold = 5,
		currentQuantity = 1,
	},
}

function ProductShelfManager.UpdateTextLabel(productName)
	local product = SHELF_CONFIG[productName]

	if not product then
		return
	end

	local itemStands = workspace:WaitForChild("ItemStands")
	local stand = itemStands:WaitForChild(productName)
	local textLabel = stand:FindFirstChild("aviso"):FindFirstChild("SurfaceGui"):FindFirstChild("TextLabel")

	textLabel.Text = product.currentQuantity .. "/" .. product.maxQuantity
end

function ProductShelfManager.CanPurchase(productName)
	local product = SHELF_CONFIG[productName]

	if not product then
		return false
	end

	return product.currentQuantity > 0
end

function ProductShelfManager.PurchaseItem(productName)
	local product = SHELF_CONFIG[productName]

	if ProductShelfManager.CanPurchase(productName) then
		product.currentQuantity -= 1
		ProductShelfManager.UpdateTextLabel(productName)
		return true
	end

	return false
end

function ProductShelfManager.RestockShelf(productName)
	local product = SHELF_CONFIG[productName]

	if product then
		product.currentQuantity = product.maxQuantity
		ProductShelfManager.UpdateTextLabel(productName)
		return true
	end

	return false
end

return ProductShelfManager
