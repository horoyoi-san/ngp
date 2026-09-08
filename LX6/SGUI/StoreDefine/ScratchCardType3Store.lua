-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ScratchCardType3Store.lua
-- Decompiled from: 01942_ScratchCardType3Store.lua_6a98dce91c14.luajit

C_ScratchCardType3Store = DefClass("C_ScratchCardType3Store", C_ScratchCardType3Store, C_ScratchCardType1Store)
GroupName2Class.ScratchCardType3Store = C_ScratchCardType3Store
local M = C_ScratchCardType3Store

M.GetMaxReward = function(self)
	return LTConfig.PoiGameConfig.ScratchType2MaxReward
end

M.GetShowCount = function(self)
	return 8
end

M.InitDataList = function(self, args)
	self.gamePlayId = args.gamePlayId
	local result = args.scratchStartResult
	self.serverTotalReward = result.TotalReward
	self.dataList = {}

	for _, cell in ipairs(result.CellDataList) do
		table.insert(self.dataList, {
			numberList = cell.NumberList,
			score = cell.Score
		})
	end
end

M.IsAllSameNumbers = function(self, itemData)
	local first = itemData.numberList[1]

	for _, num in ipairs(itemData.numberList) do
		if num == first then
			return false
		end
	end

	return true
end

M.OnRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	local numberList = data.numberList
	local targetControl = self:GetTargetControl(data, luaIndex)
	self.scratchItemStoreByIndex[luaIndex] = store
	store.isTargetControl = targetControl

	store.list.luaSimpleRenderItem = function(childBtn, childCsIndex)
		local childLuaIndex = childCsIndex + 1
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)
		local number = numberList[childLuaIndex]
		local iconId = self:GetNumberIconId(number)
		childStore.iconId = iconId
		childStore.vxIconId = iconId

		self:TryPlayTargetNumberAni(childStore, store.isTargetControl, luaIndex .. "_" .. childLuaIndex)
	end

	local money = self:GetMoneyDisplayText(data.score)
	store.money = money
	store.vxMoney = money

	store.list:SetSimpleList(#numberList)

	store.round = csIndex

	self:TryPlayTargetAni(store, targetControl, luaIndex)
end

M.IsTargetItem = function(self, data)
	return self.IsAllSameNumbers(self, data)
end

M.GetZoneItemIndex = function(self, zoneIndex)
	local rewardZoneStartIndex = self.GetShowCount(self) * 3

	if zoneIndex >= rewardZoneStartIndex then
		return nil
	end

	return zoneIndex - rewardZoneStartIndex + 1
end

M.PlayTargetAni = function(self, store, aniKey)
	self.PlayScratchTargetAni(self, store.Ani, "S_Vx_ScratchNumber_Template", aniKey)
end

M.TryPlayTargetNumberAni = function(self, store, targetControl, aniKey)
	if targetControl ~= 1 then
		self.PlayScratchTargetAni(self, store.Ani, "S_Vx_ScratchNumber_Template_Number", aniKey)
	end
end

M.GetNumberIconId = function(self, number)
	local count = LTConfig.PoiGameScratchConfig.count

	for i = 0, count - 1 do
		local scratchCfg = LTConfig.PoiGameScratchConfig.LoadAt(i)

		if scratchCfg.GameplayID ~= self.gamePlayId and scratchCfg.Text ~= tostring(number) then
			return scratchCfg.SguiID
		end
	end

	return 0
end

M.GetTotalReward = function(self)
	return self.serverTotalReward
end

M.GetRewardTipsList = function(self)
	return LTConfig.PoiGameConfig.ScratchType3RewardTipsList
end
