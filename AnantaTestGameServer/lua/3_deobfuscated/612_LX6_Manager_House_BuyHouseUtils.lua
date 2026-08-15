local M = {
	CheckHasBuyTheHouse = function (houseId)
		local houseInfo = gPlayerManager.infoMinor.bindData.housesInfo
		local houseInfoList = houseInfo and houseInfo.HouseInfoList

		if table.isNilOrEmpty(houseInfoList) then
			return false
		end

		for _, data in ipairs(houseInfoList) do
			if data.HouseId == houseId then
				return true
			end
		end
	end,
	GetHousePrice = function (houseId)
		local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)

		if houseCfg then
			local shopId = houseCfg.ShopId
			local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)
			local commodityId = shopCfg.CommodityID[1]
			local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)

			return commodityCfg.Price
		else
			return 0
		end
	end,
	BuyTheHouse = function (houseId)
		local houseInfo = LTConfig.HouseConfig.GetConfig(houseId)
		local shopId = houseInfo.ShopId
		local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)

		gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (shopRpcCode, npcShopInfo)
			if shopRpcCode == LTConfig.MessageConfig.Ok then
				local commodityId = shopCfg.CommodityID[1]

				gClientToGameDelegate:AskBuyCommodity(commodityId, 1).Callback = function (commodityRpcCode)
					if commodityRpcCode == LTConfig.MessageConfig.Ok then
						local signalKey = ("BuyHouse%d"):format(houseId)

						gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
							signalKey = signalKey
						})
						gMessageManager:SendMessage(gEventConstants.ON_BUY_HOUSE_SUCCESS, houseId)
					else
						gDisplayMessageMgr:DisplayServerMessageId(commodityRpcCode)
					end
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(shopRpcCode)
			end
		end
	end,
	GetOwnerMoney = function (houseId)
		local houseCfg = LTConfig.HouseConfig.GetConfig(houseId)
		local shopId = houseCfg.ShopId
		local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)

		return gPlayerItemManager:GetPackItemNum(shopCfg.Money)
	end,
	SyncAddHouse = function (houseInfo)
		local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList

		table.insert(houseInfoList, houseInfo)

		houseInfoList.Count = houseInfoList.Count + 1
		houseInfoList.Length = houseInfoList.Length + 1
	end,
	SyncRemoveHouse = function (houseId)
		local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList

		for index, data in ipairs(houseInfoList) do
			if data.HouseId == houseId then
				table.remove(houseInfoList, index)

				houseInfoList.Count = houseInfoList.Count - 1
				houseInfoList.Length = houseInfoList.Length - 1

				break
			end
		end
	end
}

function M.CheckBuyHouseMoneyEnough(houseId)
	local needMoney = M.GetHousePrice(houseId)
	local ownerMoney = M.GetOwnerMoney(houseId)

	return needMoney <= ownerMoney
end

function M.SyncFurnitureInfo(furnitureId, count, placedCount)
	local furnitureInfoDict = gPlayerManager.infoMinor.bindData.housesInfo.FurnitureInfoDict

	if count <= 0 then
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
