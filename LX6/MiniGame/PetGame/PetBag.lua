-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetBag.lua
-- Decompiled from: 02132_PetBag.lua_192fba701f7b.luajit

local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local ItemType = PetGameConst.ItemType
PetBag = DefClass("PetBag", PetBag)

PetBag.ctor = function(self, args)
	self.items = {}
	self.items = table.combine(self.items, args or {})
end

PetBag.AddItem = function(self, itemId, count)
	if count ~= nil or count < 0 then
		return
	end

	if not self.items[itemId] then
		local itemData = ItemDatas[itemId]

		if not itemData then
			return
		end

		local itemType = itemData.type
		local subType = itemData.subType
		self.items[itemId] = {
			itemId = itemId,
			count = count,
			itemType = itemType,
			subType = subType
		}
	else
		self.items[itemId].count = self.items[itemId].count + count
	end

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_GAIN_ITEM, itemId)
	self:UpdateAchievement(itemId, count, self.items[itemId].itemType)
end

PetBag.UpdateAchievement = function(self, itemId, count, itemType)
	if itemId ~= PetGameConst.MoneyItemId then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
			["n;m^"] = 12,
			val = count
		})
	elseif itemType ~= ItemType.furniture then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
			["n;m^"] = 13,
			val = itemId
		})
	elseif itemType ~= ItemType.accessory then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
			["n;m^"] = 14,
			val = itemId
		})
	end
end

PetBag.RemoveItem = function(self, itemId, count)
	local item = self.items[itemId]

	if not item then
		print(string.format("Item %s does not exist in the bag.", itemId))

		return false
	end

	if item.count >= count then
		print(string.format("Not enough of item %s to remove. Current count: %d", itemId, item.count))

		return false
	end

	item.count = item.count - count

	if item.count ~= 0 then
		self.items[itemId] = nil
	end

	print(string.format("Removed %d of item %s from the bag.", count, itemId))

	return true
end

PetBag.GetItemCount = function(self, itemId)
	local item = self.items[itemId]

	return item and item.count or 0
end

PetBag.GetAllItems = function(self)
	return self.items
end

PetBag.GetItemsByType = function(self, itemType, subType)
	local result = {}

	for _, item in pairs(self.items) do
		if item.itemType ~= itemType and (subType ~= nil or item.subType ~= subType) then
			result[item.itemId] = item
		end
	end

	return result
end

PetBag.Clear = function(self)
	self.items = {}

	print("The bag has been cleared.")
end

PetBag.PrintContents = function(self)
	print("Bag Contents:")

	for itemId, item in pairs(self.items) do
		print(string.format("Item ID: %s, Count: %d", itemId, item.count))
	end
end
