-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\BuyHouseUtils.lua
-- Decompiled from: 02175_BuyHouseUtils.lua_f7d054c128e5.luajit

local M = {
	CheckHasBuyTheHouse = function (houseId)
		local houseInfo = gPlayerManager.infoMinor.bindData.housesInfo
		local houseInfoList = houseInfo and houseInfo.HouseInfoList

		if table.isNilOrEmpty(houseInfoList) then
			return false
		end

		for _, data in ipairs(houseInfoList) do
			if data.HouseId ~= houseId then
				return true
			end
		end
	end
}

local ResolveCommodityId = function(houseCfg, shopCfg)
	if houseCfg.Commodity and houseCfg.Commodity == 0 then
		return houseCfg.Commodity
	end

	return shopCfg.CommodityID and shopCfg.CommodityID[1]
end

M.GetHousePrice = function(houseId)
	local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)

	if houseCfg then
		local shopId = houseCfg.ShopId
		local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)
		local commodityId = ResolveCommodityId(houseCfg, shopCfg)
		local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)

		return commodityCfg.Price
	else
		return 0
	end
end

M.BuyTheHouse = function(houseId)
	if not M.CheckBuyHouseMoneyEnough(houseId) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.BuyHouseMoneyNotEnough)

		return
	end

	local houseInfo = LTConfig.HouseConfig.GetConfig(houseId)
	local shopId = houseInfo.ShopId
	local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)
	slot4 = gClientToGameDelegate

	slot4:AskNpcShopCommodityInfo(shopId).Callback = function (shopRpcCode, npcShopInfo)
		if shopRpcCode ~= LTConfig.MessageConfig.Ok then
			local commodityId = ResolveCommodityId(houseInfo, shopCfg)
			slot3 = gClientToGameDelegate

			slot3:AskBuyCommodity(shopId, commodityId, 1).Callback = function (commodityRpcCode)
				if commodityRpcCode ~= LTConfig.MessageConfig.Ok then
					local signalKey = ("BuyHouse%d"):format(houseId)

					gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
						signalKey = signalKey
					})
					gMessageManager:SendMessage(gEventConstants.ON_BUY_HOUSE_SUCCESS, houseId)
					gPanelManager:CheckShow(gPanelId.HOUSE_REWARD_PANEL, {
						houseId = houseId
					})
				else
					if commodityRpcCode ~= LTConfig.MessageConfig.ItemNotEnough then
						local shopCommodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)
						local consumableID = shopCommodityCfg and shopCommodityCfg.ConsumableID
						local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableID)
						local consumableName = consumableCfg and consumableCfg.Name or ""

						gDisplayMessageMgr:DisplayServerMessageId(commodityRpcCode, consumableName)
					else
						gDisplayMessageMgr:DisplayServerMessageId(commodityRpcCode)
					end

					gPanelManager:Close(gPanelId.HOUSE_REWARD_PANEL)
				end
			end

			return
		end

		gPanelManager:Close(gPanelId.HOUSE_REWARD_PANEL)
		gDisplayMessageMgr:DisplayServerMessageId(shopRpcCode)
	end
end

M.GetOwnerMoney = function(houseId)
	local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)
	local shopId = houseCfg.ShopId
	local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)

	return gCommonItemManager:GetPackItemNum(shopCfg.Money)
end

M.SyncAddHouse = function(houseInfo)
	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList

	table.insert(houseInfoList, houseInfo)

	houseInfoList.Count = houseInfoList.Count + 1
	houseInfoList.Length = houseInfoList.Length + 1

	if gHouseManager then
		gHouseManager:OnSyncAddHouse(houseInfo)
	end
end

M.SyncRemoveHouse = function(houseId)
	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList

	for index, data in ipairs(houseInfoList) do
		if data.HouseId ~= houseId then
			table.remove(houseInfoList, index)

			houseInfoList.Count = houseInfoList.Count - 1
			houseInfoList.Length = houseInfoList.Length - 1

			break
		end
	end
end

M.CheckBuyHouseMoneyEnough = function(houseId)
	local needMoney = M.GetHousePrice(houseId)
	local ownerMoney = M.GetOwnerMoney(houseId)

	return needMoney > ownerMoney
end

M.SyncFurnitureInfo = function(furnitureId, count, placedCount)
	local furnitureInfoDict = gPlayerManager.infoMinor.bindData.housesInfo.FurnitureInfoDict

	if count < 0 then
		furnitureInfoDict[furnitureId] = nil
	elseif table.contains(furnitureInfoDict, furnitureId) then
		local furnitureInfo = furnitureInfoDict[furnitureId]
		furnitureInfo.Count = count
		furnitureInfo.PlacedCount = placedCount
	else
		local newFurnitureInfo = {
			FurnitureId = furnitureId,
			Count = count,
			PlacedCount = placedCount
		}
		furnitureInfoDict[furnitureId] = newFurnitureInfo
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
end

gBuyHouseUtils = M
