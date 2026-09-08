-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GamePlayBPRewardsPanelStore.lua
-- Decompiled from: 01739_GamePlayBPRewardsPanelStore.lua_8adcc0bf68a0.luajit

local BattlePassConfig = LTConfig.BattlePassConfig
local BattlePassGoodsConfig = LTConfig.BattlePassGoodsConfig
local GoodsType = LTConfig.BattlePassGoodsConfig.TypeType
local BattlePassType = UX.Game.BattlePassType
local MessageConfig = LTConfig.MessageConfig
local TagsConfig = LTConfig.ConsumableTagsConfig
local bit = require("bit")
C_GamePlayBPRewardsPanelStore = DefClass("C_GamePlayBPRewardsPanelStore", C_GamePlayBPRewardsPanelStore, C_StoreGroup)
GroupName2Class.GamePlayBPRewardsPanelStore = C_GamePlayBPRewardsPanelStore
local M = C_GamePlayBPRewardsPanelStore

M.ctor = function(self)
	self.bpId = nil
	self.bpData = nil
	self.curMainReward = nil
	self.curMainRewardNum = 1
	self.offsetIndex = 3
	self.mainItemToolTipStore = nil
	self.curGrandPrizeLevel = 0
end

M.DefineAllVariables = function(self)
	self.goodsTypeToIndex = {
		[GoodsType.Fashion] = 2,
		[GoodsType.Vehicle] = 1,
		[GoodsType.Money] = 2,
		[GoodsType.Big] = 2
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.mainItemTypeCtrlEnum = {
		["\\x9ezi"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.mainItemQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.mainItemImageCtrlEnum = {
		["I\\xbc\\xa7\\xbc\\xa5"] = 2,
		["\\x8dit"] = 1,
		s6xV = 0,
		["MH~dO3?"] = 3
	}
	self.openToolTipCtrlEnum = {
		["K\\xaf\\xb1\\xa3\\xb3"] = 0,
		["n7o^"] = 1
	}
	self.showTimeCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.mainItemTypeCtrlEnum = nil
	self.mainItemQualityCtrlEnum = nil
	self.mainItemImageCtrlEnum = nil
	self.openToolTipCtrlEnum = nil
	self.showTimeCtrlEnum = nil
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
	self:RegisterMessageEvents(self.msgEvents)

	self.mainItemToolTipStore = gStoreManager:GetStoreGroup("BattlePassToolTipTemplate"):GetStoreByWidget(self.bindData.mainItemToolTip)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.mainItemToolTipStore = nil
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
	self.bindData.openTooltipBtn.luaClick = self.CreateAction(self, "OnClickOpenTooltipBtn")
	self.bindData.mainItemToolTip.luaClick = self.CreateAction(self, "OnClickMainItemToolTip")
	self.bindData.toolTipCloseBtn.luaClick = self.CreateAction(self, "OnClickToolTipCloseBtn")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItemListItem")
end

M.OnClickOpenTooltipBtn = function(self)
	self.bindData.openToolTipCtrl = self.bindData.openToolTipCtrl == 1 and 1 or 0

	self:OnRefreshMainTooltip()
end

M.OnClickMainItemToolTip = function(self)
	self.bindData.openToolTipCtrl = self.bindData.openToolTipCtrl == 1 and 1 or 0

	self:OnRefreshMainTooltip()
end

M.OnClickToolTipCloseBtn = function(self)
	if self.bindData.openToolTipCtrl ~= 1 then
		self.bindData.openToolTipCtrl = 0
	end
end

M.OnRefreshMainTooltip = function(self)
	if self.mainItemToolTipStore and self.bindData.openToolTipCtrl ~= 1 and self.curMainReward then
		local rewardInfo = BattlePassGoodsConfig.GetConfig(self.curMainReward)

		if not rewardInfo then
			return
		end

		local tagCfg = TagsConfig.GetConfig(rewardInfo.tagid)
		self.mainItemToolTipStore.descText = gBattlePassMgr:GetGoodsDesc(self.curMainReward)
		self.mainItemToolTipStore.typeCtrl = (rewardInfo.Type ~= GoodsType.Vehicle or rewardInfo.Type ~= GoodsType.Fashion) and 1 or 2
		self.mainItemToolTipStore.numText = self.curMainRewardNum
		self.mainItemToolTipStore.icon = rewardInfo.icon

		if tagCfg then
			self.mainItemToolTipStore.title = tagCfg.TagName
		end
	end
end

M.OnClickSwitchToBuyLevelTab = function(self)
	if self.parentStore then
		self.parentStore:SwitchPage(1)
	end
end

M.RefreshAll = function(self)
	if not self.bpData then
		return
	end

	self.RefreshLevelInfo(self)
	self.RefreshRewardList(self)
	self.RefreshMainReward(self)
end

M.RefreshLevelInfo = function(self)
	local levelStore = self.GetStoreByWidget(self, self.bindData.rewardLevel)

	if not levelStore or not self.bpData then
		return
	end

	levelStore.buyLevelBtn.luaClick = self.CreateAction(self, "OnClickSwitchToBuyLevelTab")
	levelStore.levelNum = tostring(self.bpData.level)
	local nextLevel = self.bpData.level + 1

	if not self.bpData.rewardMap[nextLevel] then
		nextLevel = self.bpData.level
	end

	local showExp = self.bpData.exp

	if self.bpData.level == 0 and self.bpData.rewardMap[self.bpData.level] then
		showExp = self.bpData.exp - self.bpData.rewardMap[self.bpData.level].exp
	end

	local maxExp = 1

	if self.bpData.rewardMap[nextLevel] and self.bpData.rewardMap[self.bpData.level] then
		maxExp = self.bpData.rewardMap[nextLevel].exp - self.bpData.rewardMap[self.bpData.level].exp
	end

	levelStore.expNum = showExp .. "/" .. maxExp
	levelStore.expFill.normalizedValue = math.min(showExp / math.max(maxExp, 1), 1)

	if self.bpData.curWeekMaxExp and self.bpData.curWeekMaxExp <= 0 then
		levelStore.showWeekExp = true
		levelStore.weekExpNum = self.bpData.weeklyExp .. "/" .. self.bpData.curWeekMaxExp
	else
		levelStore.showWeekExp = false
	end
end

M.RefreshRewardList = function(self)
	if not self.bpData then
		return
	end

	self.bindData.itemList:SetSimpleList(#self.bpData.curRewards)

	local goIndex = math.max(self.bpData.level - self.offsetIndex, 0)

	self.bindData.itemList:GoToIndex(goIndex, true)

	local cfg = BattlePassConfig.GetConfig(self.bpId)

	if cfg then
		self.bindData.bpTitle = cfg.BPTitle or ""
	end

	if self.bpData.isPermanent then
		self.bindData.showTimeCtrl = self.showTimeCtrlEnum._false
	else
		self.bindData.showTimeCtrl = self.showTimeCtrlEnum._true

		if cfg and cfg.endTime then
			local endUnixTime = gTimeUtils:GetUnixTime(cfg.endTime.year or 0, cfg.endTime.month or 0, cfg.endTime.day or 0, cfg.endTime.hour or 0, cfg.endTime.minute or 0, cfg.endTime.second or 0)

			self.bindData.countDown:Play(endUnixTime - gCS.TimeManager.ServerUnixTime)
		end
	end

	self.SetGrandPrizeInfo(self, self.bpData.level, true)
end

M.RefreshMainReward = function(self)
	if not self.bpData then
		return
	end

	local showReward = self.GetFirstUnclaimedReward(self)

	if not showReward then
		return
	end

	local goodsInfo = BattlePassGoodsConfig.GetConfig(showReward.id)

	if not goodsInfo then
		return
	end

	self.bindData.mainItemTitle = gBattlePassMgr:GetGoodsName(goodsInfo.Id)
	self.bindData.mainItemQualityCtrl = showReward.quality or 0
	self.bindData.mainItemImageCtrl = self.goodsTypeToIndex[goodsInfo.Type] or 2

	if goodsInfo.Type ~= GoodsType.Vehicle then
		self.bindData.carImage = goodsInfo.baseImage
	else
		self.bindData.dressImage = goodsInfo.baseImage
	end

	self.curMainReward = showReward.id
	self.curMainRewardNum = showReward.num
end

M.GetFirstUnclaimedReward = function(self)
	if not self.bpData then
		return nil
	end

	local levelData = self.bpData.rewardMap[self.bpData.level]
	local needShowReward = nil

	if levelData then
		local targetType = levelData.claimState

		for _, v in ipairs(levelData.rewards) do
			if targetType < v.type then
				needShowReward = v

				break
			end
		end
	end

	if not needShowReward and self.bpData.rewardMap[self.bpData.level + 1] then
		needShowReward = self.bpData.rewardMap[self.bpData.level + 1].rewards[1]
	elseif self.bpData.level ~= self.bpData.maxLevel and self.bpData.rewardMap[self.bpData.level] then
		needShowReward = self.bpData.rewardMap[self.bpData.level].rewards[1]
	end

	return needShowReward
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local level = index + 1

	if not self.bpData or not self.bpData.rewardMap[level] then
		return
	end

	local data = self.bpData.rewardMap[level]

	if not data or not data.rewards then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.levelNum = level
	store.itemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderRewardItem", data)

	store.itemList:SetSimpleList(#data.rewards)

	for i = 1, #data.rewards do
		store.itemList:SetItemId(i - 1, level .. i)
	end

	self.SetGrandPrizeInfo(self, level, false)
end

M.OnDynamicRenderItemListItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not store.itemList then
		return
	end

	if not self.bpData or not self.bpData.rewardMap[csIndex + 1] then
		return
	end

	local rewardNum = self.bpData.rewardMap[csIndex + 1].rewards
	store.itemList.rectTransform.sizeDelta = Vector2.New(156 * (#rewardNum or 1) - 11 * (#rewardNum - 1), store.itemList.rectTransform.sizeDelta.y)
end

M.OnSimpleRenderRewardItem = function(self, data, btn, index)
	if not data or not data.rewards or not data.rewards[index + 1] then
		return
	end

	local itemInfo = data.rewards[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not itemInfo then
		return
	end

	store.claimCtrl = self.GetClaimState(self, data.claimState)
	store.goodsNum = self.ExtractNum(self, itemInfo.num)
	store.advanceCtrl = 0

	if not itemInfo.id then
		return
	end

	local goodsInfo = BattlePassGoodsConfig.GetConfig(itemInfo.id)

	if not goodsInfo then
		return
	end

	store.itemIcon = goodsInfo.icon or 0
	store.qualityCtrl = itemInfo.quality or 0
	local canGetReward = store.claimCtrl ~= 0 and data.level > self.bpData.level
	local rewardInfo = {
		level = data.level,
		canGetReward = canGetReward,
		icon = goodsInfo.icon,
		baseImage = goodsInfo.baseImage,
		name = gBattlePassMgr:GetGoodsName(goodsInfo.Id),
		quality = itemInfo.quality,
		mainItemType = goodsInfo.Type,
		id = goodsInfo.Id,
		num = itemInfo.num
	}
	store.getRewardBtn.luaClick = self:CreateActionWithArgs("OnTryGetReward", rewardInfo)
end

M.OnTryGetReward = function(self, data)
	if not data then
		return
	end

	self.bindData.mainItemTitle = gBattlePassMgr:GetGoodsName(data.id)
	self.bindData.mainItemQualityCtrl = data.quality or 0
	self.bindData.mainItemImageCtrl = self.goodsTypeToIndex[data.mainItemType] or 2

	if data.mainItemType ~= GoodsType.Vehicle then
		self.bindData.carImage = data.baseImage
	else
		self.bindData.dressImage = data.baseImage
	end

	self.curMainReward = data.id
	self.curMainRewardNum = data.num

	self.OnRefreshMainTooltip(self)

	if data.canGetReward then
		self.AskClaimAllReward(self)
	end
end

M.AskClaimAllReward = function(self)
	if not self.bpId then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskClaimAllBattlePassReward(self.bpId).Callback = function (err, data)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnSimpleRenderGrandPrizeItem = function(self, btn, index)
	self.OnSimpleRenderRewardItem(self, self.bpData.rewardMap[self.curGrandPrizeLevel], btn, index)
end

M.GetGrandPrizeLevel = function(self, curLevel)
	local success, min, max = self.bindData.itemList:TryGetVisualRange(0, 0)

	if success then
		curLevel = max + 1
	end

	local grandPrizeLevelList = BattlePassConfig.GrandPrizeLevel

	if not grandPrizeLevelList then
		return nil
	end

	for _, level in ipairs(grandPrizeLevelList) do
		if curLevel < level then
			return level
		end
	end

	return nil
end

M.SetGrandPrizeInfo = function(self, curLevel, isForce)
	local newGrandPrize = self.GetGrandPrizeLevel(self, curLevel)

	if self.curGrandPrizeLevel ~= newGrandPrize and not isForce then
		return
	end

	self.curGrandPrizeLevel = newGrandPrize
	local store = gStoreManager:GetStoreGroup(self.bindData.grandPrizeBtn.Store):GetStoreByWidget(self.bindData.grandPrizeBtn)

	if not store then
		return
	end

	store.levelNum = self.curGrandPrizeLevel
	store.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGrandPrizeItem")

	if self.bpData.curRewards[self.curGrandPrizeLevel] then
		store.itemList:SetSimpleList(#self.bpData.curRewards[self.curGrandPrizeLevel].rewards)
	else
		store.itemList:SetSimpleList(0)
	end
end

M.GetClaimState = function(self, claimState)
	if bit.lshift(1, BattlePassType.Free) < claimState then
		return 1
	end

	return 0
end

M.ExtractNum = function(self, num)
	if num > 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num > 1000 then
		return string.format("%.1fK", num / 1000)
	end

	return num
end
