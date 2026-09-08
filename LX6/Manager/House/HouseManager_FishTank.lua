-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseManager_FishTank.lua
-- Decompiled from: 00752_HouseManager_FishTank.lua_ae84a59b493b.luajit

local M = C_HouseManager

M.GetFishTankTransformByGadgetId = function(self, gadgetId)
	local placedId = gHouseGadgetManager and gHouseGadgetManager:GetPlacedIdByGadgetId(gadgetId) or nil

	if not placedId then
		return nil
	end

	local furnitureGo = gFurnitureUIDManager and gFurnitureUIDManager.uid2FurnitureGoDict and gFurnitureUIDManager.uid2FurnitureGoDict[placedId] or nil

	if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
		return furnitureGo.transform
	end

	return nil
end

M.GetFishTemplateIdByUniqueId = function(self, uniqueId)
	local fishingInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.FishingInfo or nil

	if not fishingInfo then
		return 0
	end

	local fishUniqueId = gFurnitureUtils and gFurnitureUtils:ConvertServerUidToNumber(uniqueId) or uniqueId
	local fishInfo = fishingInfo.OrnamentalFishDict and (fishingInfo.OrnamentalFishDict[fishUniqueId] or fishingInfo.OrnamentalFishDict[uniqueId]) or nil
	fishInfo = fishInfo or fishingInfo.ConsumableFishDict and (fishingInfo.ConsumableFishDict[fishUniqueId] or fishingInfo.ConsumableFishDict[uniqueId]) or nil

	return fishInfo and fishInfo.TemplateId or 0
end

M.CreateAquariumFish = function(self, aquariumId, fishUniqueId, slotId)
	if not aquariumId or aquariumId ~= 0 or not fishUniqueId or not slotId then
		return
	end

	gCS.LuaUtils.CreateAquariumFish(aquariumId, fishUniqueId, tonumber(slotId) or 0)
end

M.RecycleAquariumFish = function(self, fishUniqueId)
	if not fishUniqueId then
		return
	end

	gCS.LuaUtils.RecycleAquariumFish(fishUniqueId)
end

M.CreateAquariumFishesForPlacedIds = function(self, houseId, placedIdList)
	if not houseId or not placedIdList then
		return
	end

	for _, placedId in ipairs(placedIdList) do
		self.CreateAquariumFishesByPlacedId(self, houseId, placedId)
	end
end

M.CreateAquariumFishesByPlacedId = function(self, houseId, placedId)
	local gadgetId = gHouseGadgetManager and gHouseGadgetManager:GetGadgetInstanceId(placedId) or nil

	if not gadgetId then
		return
	end

	local gadgetData = self:GetFurnitureGadgetData(houseId, placedId)
	local slotFish = gadgetData and gadgetData.FishTank and gadgetData.FishTank.SlotFish or nil

	if not slotFish then
		return
	end

	for slotId, fishInfo in pairs(slotFish) do
		if fishInfo and fishInfo.UniqueId then
			self.CreateAquariumFish(self, gadgetId, fishInfo.UniqueId, slotId)
		end
	end
end

M.ClearAllAquariumFishes = function(self)
	gCS.LuaUtils.ClearAllAquariumFishes()
end

M.SetAquariumFishesHouseEditState = function(self, inEditState)
	gCS.LuaUtils.SetHouseEditState(inEditState ~= true)
end

M.CreateAquariumFishesForHouse = function(self, houseId)
	if not houseId or houseId ~= 0 then
		return
	end

	local placedIdList = {}
	slot3 = pairs
	slot5 = gHouseGadgetManager and gHouseGadgetManager.placedId2GadgetIdMap or {}

	for placedId, _ in slot3(slot5) do
		if gFurnitureUIDManager:GetFurnitureHouseId(placedId) ~= houseId then
			table.insert(placedIdList, placedId)
		end
	end

	self.CreateAquariumFishesForPlacedIds(self, houseId, placedIdList)
end
