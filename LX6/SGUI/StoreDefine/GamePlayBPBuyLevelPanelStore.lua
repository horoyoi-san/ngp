-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GamePlayBPBuyLevelPanelStore.lua
-- Decompiled from: 01738_GamePlayBPBuyLevelPanelStore.lua_560236d0e502.luajit

local BattlePassGoodsConfig = LTConfig.BattlePassGoodsConfig
local MessageConfig = LTConfig.MessageConfig
local TextConfig = LTConfig.TextConfig
C_GamePlayBPBuyLevelPanelStore = DefClass("C_GamePlayBPBuyLevelPanelStore", C_GamePlayBPBuyLevelPanelStore, C_StoreGroup)
GroupName2Class.GamePlayBPBuyLevelPanelStore = C_GamePlayBPBuyLevelPanelStore
local M = C_GamePlayBPBuyLevelPanelStore

M.ctor = function(self)
	self.bpId = nil
	self.bpData = nil
	self.curBuyLevelNum = 1
	self.normalRewardList = {}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.buyLevelTypeCtrlEnum = {
		["A\\x9f\\x8b\\xd3"] = 2,
		["A\\x9f\\x8b\\xd3"] = 0,
		["\\xed\\xcc*\\xf4"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.buyLevelTypeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, bpId)
	self.bpId = bpId

	if not self.bpId then
		return
	end

	self.bpData = gBattlePassMgr:GetBattlePassData(self.bpId)

	if not self.bpData then
		return
	end

	self.RefreshAll(self)
end

M.OnClose = function(self)
	self.bpData = nil
	self.normalRewardList = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GAMEPLAY_BP_PROGRESS] = self.CreateAction(self, "OnGamePlayBPProgress"),
		[gEventConstants.GAMEPLAY_BP_INFO_SYNC] = self.CreateAction(self, "OnGamePlayBPInfoSync")
	}
end

M.OnGamePlayBPProgress = function(self, data)
	if not data or data.bpId == self.bpId then
		return
	end

	self.bpData = gBattlePassMgr:GetBattlePassData(self.bpId)

	self:RefreshAll()
end

M.OnGamePlayBPInfoSync = function(self, data)
	if not data or data.bpId == self.bpId then
		return
	end

	self.bpData = gBattlePassMgr:GetBattlePassData(self.bpId)

	self:RefreshAll()
end

M.RegisterWidget = function(self)
	self.bindData.buyLevelBtn.luaClick = self.CreateAction(self, "OnClickBuyLevelBtn")
	self.bindData.normalRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderNormalRewardListItem")
	self.bindData.advanceRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderAdvanceRewardListItem")
end

M.RefreshAll = function(self)
	if not self.bpData then
		return
	end

	if self.bpData.maxLevel < self.bpData.level then
		self.bindData.buyLevelBtn.interactable = false

		return
	end

	self.SubGroup.CommonBuyNumSliderStore:SetData({
		range = {
			1,
			math.max(self.bpData.maxLevel - self.bpData.level, 1)
		},
		data = {
			moneyId = self.bpData.buyLevelCurrencyId,
			price = self.bpData.buyLevelCurrencyNum
		},
		valChangeCallback = self:CreateAction("OnBuyLevelChange")
	})

	self.bindData.buyLevelBtn.interactable = true
end

M.OnBuyLevelChange = function(self, data)
	if not self.bpData then
		return
	end

	if data <= self.bpData.maxLevel - self.bpData.level then
		return
	end

	self.curBuyLevelNum = data
	self.normalRewardList = self:GetBuyLevelDisplayRewards(self.bpData.level, self.bpData.level + data)

	self.bindData.normalRewardList:SetSimpleList(#self.normalRewardList)
	self.bindData.advanceRewardList:SetSimpleList(0)

	self.bindData.oldLevelText = tostring(self.bpData.level)
	self.bindData.newLevelText = tostring(self.bpData.level + data)
	local needPayMoney = data * self.bpData.buyLevelCurrencyNum
	local playerMoney = gCommonItemManager:GetPackItemNum(self.bpData.buyLevelCurrencyId)

	if playerMoney >= needPayMoney then
		self.bindData.buyLevelText = gString.Format(TextConfig.GetConfig(73976023).Text, needPayMoney)
	else
		self.bindData.buyLevelText = gString.Format(TextConfig.GetConfig(73976024).Text, needPayMoney)
	end
end

M.OnClickBuyLevelBtn = function(self)
	if not self.bpId or not self.bpData then
		return
	end

	local buyNum = self.curBuyLevelNum or 1
	local totalPrice = buyNum * self.bpData.buyLevelCurrencyNum

	local doAskBuy = function(onComplete)
		gClientToGameDelegate:AskBuyBattlePassLevels(self.bpId, buyNum).Callback = function (err, data)
			if err ~= MessageConfig.Ok then
				if onComplete then
					onComplete(true)
				end
			else
				print_warn("[GamePlayBP] Buy level failed, err =", err)

				if onComplete then
					onComplete(false)
				end
			end
		end
	end

	gMallManager:TryBuyWithMoneyCheck(totalPrice, self.bpData.buyLevelCurrencyId, function ()
		doAskBuy(nil)
	end, {
		retryFunc = doAskBuy
	})
end

M.OnSimpleRenderNormalRewardListItem = function(self, btn, index)
	if not self.normalRewardList or not self.normalRewardList[index + 1] then
		return
	end

	local itemInfo = self.normalRewardList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not itemInfo then
		return
	end

	if not itemInfo.itemId then
		return
	end

	local goodsInfo = BattlePassGoodsConfig.GetConfig(itemInfo.itemId)

	if not goodsInfo then
		return
	end

	store.goodsNum = self:ExtractNum(itemInfo.num)
	store.qualityCtrl = gBattlePassMgr:GetGoodTypeInfo(goodsInfo.Type, goodsInfo.BindId)
	store.itemIcon = goodsInfo.icon or 0
end

M.OnSimpleRenderAdvanceRewardListItem = function(self, btn, index)
end

M.GetBuyLevelDisplayRewards = function(self, levelStart, levelEnd)
	if not self.bpData then
		return {}
	end

	if levelEnd >= levelStart then
		return {}
	end

	local maxLevel = self.bpData.maxLevel

	if maxLevel >= levelEnd then
		levelEnd = maxLevel
	end

	local startSnapshot = self.bpData.rewardsCache[levelStart] or {}
	local endSnapshot = self.bpData.rewardsCache[levelEnd] or {}
	local resultDict = {}

	for tType, endTypeMap in pairs(endSnapshot) do
		local startTypeMap = startSnapshot[tType] or {}

		for id, endCount in pairs(endTypeMap) do
			local startCount = startTypeMap[id] or 0
			local delta = endCount - startCount

			if delta <= 0 then
				if not resultDict[id] then
					resultDict[id] = {
						["\\x80}k"] = 0,
						itemId = id
					}
				end

				resultDict[id].num = resultDict[id].num + delta
			end
		end
	end

	local resultList = {}

	for _, item in pairs(resultDict) do
		table.insert(resultList, item)
	end

	table.sort(resultList, function (a, b)
		return a.itemId <= b.itemId
	end)

	return resultList
end

M.ExtractNum = function(self, num)
	if num > 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num > 1000 then
		return string.format("%.1fK", num / 1000)
	end

	return num
end
