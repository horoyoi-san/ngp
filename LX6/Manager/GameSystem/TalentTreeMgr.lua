-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\TalentTreeMgr.lua
-- Decompiled from: 02221_TalentTreeMgr.lua_8e458f129d7a.luajit

local TalentConfig = LTConfig.TalentTreeTalentConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
local JobConfig = LTConfig.UrbanJobConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local MessageConfig = LTConfig.MessageConfig
local PopupConfig = LTConfig.PopupConfig
local TalentTreeLevelConfig = LTConfig.TalentTreeLevelConfig
local TalentTreeGamePlayConfig = LTConfig.TalentTreeGamePlayConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local TalentTreeBadgeAdditionExpConfig = LTConfig.TalentTreeBadgeAdditionExpConfig
local RedDotMgr = SGUI.RedDotMgr
local ItemReason = UX.Game.ItemReason
local loginManager = gCS.LoginManager
local StaticProps = {
	LOCK_TYPE = {
		["\\xe22\\xe9\\xee\\x81\\xf9\\x8b/&"] = 5,
		["sUi]O,"] = 2,
		["\\xab5,:v\\x89q\\xd6>\\xa4\\xad"] = 4,
		["\\xa4gd"] = 1,
		["\\x82\\xa20\\xa5f1\\xfd8"] = 3,
		["\\x88\\xbe\\xbfC*\\xfb>"] = 6,
		["T-s^"] = 0
	}
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_TalentTreeMgr = DefClass("C_TalentTreeMgr", C_TalentTreeMgr, nil, StaticProps)
local M = C_TalentTreeMgr

M.Log = function(self, ...)
	print_notice("[C_TalentTreeMgr]", ...)
end

M.ctor = function(self)
	self:Clear()

	self.LOCK_STATE = {
		["0g\\xb2\\xa5\\xa6e"] = 2,
		["p{\\xe0\\x82\\xb1&\\x94+\\xea\\xc3"] = 1,
		["=k\\xa5\\xa7\\xb5d"] = 0
	}
	self.MAX_STATE = {
		["NH~"] = 1,
		["V\r^p"] = 2,
		["k\\x8f\\x8e\\x9c\\x93"] = 0
	}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction(self.OnReloadTalentState))
	gMessageManager:AddMessageListener(gEventConstants.PACK_ITEM_CHANGED, self:CreateAction(self.OnPackItemChanged))
	gMessageManager:AddMessageListener(gEventConstants.MULTIVERSE_CHANGE, self:CreateAction(self.OnReloadTalentState))

	self.TalentTree2TalentDict = {}
	self.jobClass2TalentTreeDict = {}
	self.gameplayId2TalentDict = {}
	self.gameplayId2TreeIdDict = {}

	for i = 0, TalentConfig.count - 1 do
		local cfg = TalentConfig.LoadAt(i)
		local treeIds = cfg.TalentTreeid

		if type(treeIds) == "table" then
			treeIds = {
				treeIds
			}
		end

		for j = 1, #treeIds do
			local treeId = treeIds[j]
			self.TalentTree2TalentDict[treeId] = self.TalentTree2TalentDict[treeId] or {}

			table.insert(self.TalentTree2TalentDict[treeId], cfg.Id)
		end
	end

	for i = 0, TalentTreeConfig.count - 1 do
		local cfg = TalentTreeConfig.LoadAt(i)

		if cfg then
			self.jobClass2TalentTreeDict[cfg.JobClassId] = self.jobClass2TalentTreeDict[cfg.JobClassId] or {}

			table.insert(self.jobClass2TalentTreeDict[cfg.JobClassId], cfg.Id)

			if cfg.GameplayId and cfg.GameplayId == 0 then
				self.gameplayId2TreeIdDict[cfg.GameplayId] = self.gameplayId2TreeIdDict[cfg.GameplayId] or {}

				table.insert(self.gameplayId2TreeIdDict[cfg.GameplayId], cfg.Id)

				local talentIds = self.TalentTree2TalentDict[cfg.Id]

				if talentIds then
					self.gameplayId2TalentDict[cfg.GameplayId] = self.gameplayId2TalentDict[cfg.GameplayId] or {}

					for _, talentId in ipairs(talentIds) do
						table.insert(self.gameplayId2TalentDict[cfg.GameplayId], talentId)
					end
				end
			end
		end
	end

	self.baseKey = PanelRedDotConfig.GetConfig(PanelRedDotConfig.TalentTree).Name
	self.blockReson = {
		[ItemReason.TalentReset] = true
	}

	self:_BuildCostItemIndex()
end

M.OnExit = function(self)
	gNewGuideMgr:NotifySignal(EGuideSignal.TalentTreeClose)
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

M.OnReloadTalentState = function(self)
	if not self.preFrame or self.preFrame == Time.frameCount then
		self.preFrame = Time.frameCount

		self:Log("OnReloadTalentState", "重载天赋状态")
	else
		return
	end

	gRedPointMgr:ClearRedDot(self.baseKey)

	self._cacheDirty = true

	self:CheckHasCanUnLockTalent()
end

M.OnPackItemChanged = function(self, _, eventData)
	if table.isNilOrEmpty(self.costItemId2TreeDict) then
		return
	end

	local changedItemIds = self:_CollectPackChangedItemIds(eventData)
	local affectedTreeIds = {}

	if next(changedItemIds) then
		for itemId in pairs(changedItemIds) do
			local trees = self.costItemId2TreeDict[itemId]

			if trees then
				for treeId in pairs(trees) do
					affectedTreeIds[treeId] = true
				end
			end
		end
	else
		for treeId in pairs(self.treeCostItemDict) do
			affectedTreeIds[treeId] = true
		end
	end

	for treeId in pairs(affectedTreeIds) do
		self:_RefreshSingleTreeRedDot(treeId)
	end
end

M._CollectPackChangedItemIds = function(self, eventData)
	local changedItemIds = {}

	if not eventData then
		return changedItemIds
	end

	if eventData.updateDict then
		for itemIdOrUniqueId, templateId in pairs(eventData.updateDict) do
			if templateId ~= true then
				templateId = itemIdOrUniqueId
			end

			if templateId and templateId == 0 then
				changedItemIds[templateId] = true
			end
		end
	end

	if eventData.addList then
		for i = 1, #eventData.addList do
			local item = eventData.addList[i]
			local templateId = item and (item.TemplateId or item.itemId or item.ItemId) or 0

			if templateId == 0 then
				changedItemIds[templateId] = true
			end
		end
	end

	return changedItemIds
end

M._RefreshSingleTreeRedDot = function(self, treeId)
	local treeCfg = TalentTreeConfig.GetConfig(treeId)

	if not treeCfg or not gSystemUnlockMgr:IsUnlockGroup(treeCfg.SystemIdList) or not self:CheckMultiverseMatch(treeCfg) or not self:CheckSpiritIdMatch(treeCfg) then
		return
	end

	local talentDict = self.TalentTree2TalentDict[treeId] or {}
	local gameplayId = treeCfg.GameplayId or 0
	local canUnlock = false
	local talentId = 0

	for k = 1, #talentDict do
		talentId = talentDict[k]

		if gameplayId == 0 then
			canUnlock, _ = self:CheckGameplayTalentCanUnlock(talentId, gameplayId)
		else
			canUnlock, _ = self:CheckTalentCanUnlock(talentId)
		end

		if canUnlock then
			break
		end
	end

	local redKey = self:GetRedDot(treeId)

	RedDotMgr.LuaSetRedDot(canUnlock, redKey)
	self:Log("_RefreshSingleTreeRedDot", treeId, canUnlock, talentId)
end

M.OnSyncSpiritJobTalentPoint = function(self, spiritId, jobClassId, talentPoint, reason)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	self:Log("OnSyncSpiritJobTalentPoint", spiritId, jobClassId, talentPoint, reason)

	local jobId = 0
	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId == 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
		jobId = jobInfo.Job
	end

	local diff = talentPoint - talentInfo.TalentPoint

	if diff <= 0 and self:CheckTalentTreeSystemUnlock() and not self.blockReson[reason] then
		local msg = {
			jobId = jobId,
			agentType = gNpcFavorManager:GetAgentTypeByFightSpiritId(spiritId),
			diff = diff
		}

		gNewPopupManager:PushPopup(PopupConfig.S_TalentPointTopTips, msg)
	end

	talentInfo.TalentPoint = talentPoint

	self:CheckHasCanUnLockTalent()
	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE, {
		spiritId = spiritId,
		jobId = jobId,
		talentPoint = talentPoint
	})
end

M.OnSyncActiveSpiritJobTalent = function(self, spiritId, jobClassId, talentId, layer)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return
	end

	local jobId = 0
	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId == 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
		jobId = jobInfo.Job
	end

	talentInfo.UnlockTalentInfoDict[talentId] = {
		TalentId = talentId,
		Layer = layer
	}

	self:CheckHasCanUnLockTalent()
	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE, {
		spiritId = spiritId,
		jobId = jobId,
		talentId = talentId
	})
end

M.OnStartCurrent = function(self)
	local spirit = gSpiritManager:GetSpirit(gBattleSpiritMgr.currentSpiritTemplateId)

	if not spirit then
		return
	end

	self.cacheJobDict = {
		[0] = true
	}
	self.jobClassId2TalentInfoDict = {
		[0] = spirit.SpiritInfo.TalentInfo
	}
	self.jobClassId2JobIdDict = {}
	local jobClassList = gSpiritJobManager:GetAvailableJobClass()

	for i = 1, #jobClassList do
		local jobClassId = jobClassList[i]
		local jobList = gSpiritJobManager:GetJobListByClassId(jobClassId)

		for j = 1, #jobList do
			local jobId = jobList[j].id
			local jobInfo = spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[jobId]

			if not table.isNilOrEmpty(jobInfo) then
				self.cacheJobDict[jobId] = true
				self.jobClassId2TalentInfoDict[jobClassId] = jobInfo.TalentInfo
				self.jobClassId2JobIdDict[jobClassId] = jobId

				self:cachePreJob(jobId)
			end
		end
	end

	self._cacheDirty = false
end

M.Clear = function(self)
	self.jobClassId2TalentInfoDict = {}
	self.jobClassId2JobIdDict = {}
	self.cacheJobDict = {}
	self.jobTalent = {}
	self.gameplayTalentInfos = {}
	self._cacheDirty = true
	self._redDotCache = {}
end

M.CheckMultiverseMatch = function(self, treeCfg)
	if not treeCfg or not treeCfg.Multiverse or #treeCfg.Multiverse ~= 0 then
		return true
	end

	local curVerse = gMultiverseMgr.curVerseMetaId

	if curVerse ~= 0 then
		return true
	end

	for i = 1, #treeCfg.Multiverse do
		if treeCfg.Multiverse[i] ~= curVerse then
			return true
		end
	end

	return false
end

M.CheckSpiritIdMatch = function(self, treeCfg)
	if not treeCfg or not treeCfg.SpiritId or #treeCfg.SpiritId ~= 0 then
		return true
	end

	local curSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

	if not curSpiritId or curSpiritId ~= 0 then
		return true
	end

	for i = 1, #treeCfg.SpiritId do
		if treeCfg.SpiritId[i] ~= curSpiritId then
			return true
		end
	end

	return false
end

M.cachePreJob = function(self, jobId)
	local cfg = JobConfig.GetConfig(jobId)

	if not cfg then
		return
	end

	self.cacheJobDict[jobId] = true

	return self:cachePreJob(cfg.PreJob)
end

M.GetCurrentTalentPoint = function(self, jobClassId)
	local talentInfo = self.jobClassId2TalentInfoDict[jobClassId]

	return talentInfo and talentInfo.TalentPoint or 0
end

M.GetCurrentTalentDict = function(self, jobClassId)
	local talentInfo = self.jobClassId2TalentInfoDict[jobClassId]

	return talentInfo and talentInfo.UnlockTalentInfoDict or {}
end

M.OnSyncGamePlayTalentInfo = function(self, gameplayTalentInfos)
	self.gameplayTalentInfos = gameplayTalentInfos or {}

	self:CheckHasCanUnLockGameplayTalent()
end

M.GetGameplayTalentTreeId = function(self, gameplayId)
	local treeIds = self.gameplayId2TreeIdDict[gameplayId]

	return treeIds and treeIds[1] or 0
end

M.GetGameplayTalentTreeIds = function(self, gameplayId)
	return self.gameplayId2TreeIdDict[gameplayId] or {}
end

M.GetGameplayTalentPoint = function(self, gameplayId)
	local talentInfo = self.gameplayTalentInfos[gameplayId]

	return talentInfo and talentInfo.TalentPoint or 0
end

M.GetGameplayTalentDict = function(self, gameplayId)
	local talentInfo = self.gameplayTalentInfos[gameplayId]

	return talentInfo and talentInfo.UnlockTalentInfoDict or {}
end

M.GetGameplayActiveTalentIds = function(self, gameplayId)
	local talentDict = self:GetGameplayTalentDict(gameplayId)
	local ids = {}

	for talentId in pairs(talentDict) do
		table.insert(ids, talentId)
	end

	return ids
end

M.CheckGameplayPreTalentIsUnLocked = function(self, talentId, gameplayId)
	local cfg = TalentConfig.GetConfig(talentId)
	local talentDict = self:GetGameplayTalentDict(gameplayId)

	for i = 1, #cfg.PreTalentIds do
		local id = cfg.PreTalentIds[i]
		local talentCfg = TalentConfig.GetConfig(id)

		if talentCfg then
			local talentInfo = talentDict[id]

			if talentInfo and talentInfo.Layer <= 0 then
				return true
			end
		end
	end

	return table.isNilOrEmpty(cfg.PreTalentIds)
end

M.CheckGameplayTalentIsLocked = function(self, talentId, gameplayId)
	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return false
	end

	local talentDict = self:GetGameplayTalentDict(gameplayId)
	local talentInfo = talentDict[talentId]

	if table.isNilOrEmpty(talentInfo) then
		return true
	end

	return talentInfo.Layer <= talentCfg.LayerNum
end

M.CheckGameplayTalentCanUnlock = function(self, talentId, gameplayId, skipTalentPoint)
	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		return false, StaticProps.LOCK_TYPE.None
	end

	local isReadyTalent = self:CheckGameplayPreTalentIsUnLocked(talentId, gameplayId)

	if not isReadyTalent then
		return false, StaticProps.LOCK_TYPE.PreTalent
	end

	local isLock = self:CheckGameplayTalentIsLocked(talentId, gameplayId)

	if not isLock then
		return false, StaticProps.LOCK_TYPE.IsUnlock
	end

	local talentPoint = self:GetGameplayTalentPoint(gameplayId)
	local isLackTalentPoint = talentPoint <= cfg.CostPoint

	if talentPoint >= cfg.CostPoint and not skipTalentPoint then
		return false, StaticProps.LOCK_TYPE.TalentPoint
	end

	if not self:_CheckTalentCostItemEnough(cfg, gameplayId) then
		return false, StaticProps.LOCK_TYPE.CostItem
	end

	if not gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.TalentTree) then
		return false, StaticProps.LOCK_TYPE.EventCondition
	end

	return true, isLackTalentPoint and StaticProps.LOCK_TYPE.TalentPoint or StaticProps.LOCK_TYPE.None
end

M.OnSyncGameplayTalentPoint = function(self, gameplayId, talentPoint, reason)
	self:Log("OnSyncGameplayTalentPoint", gameplayId, talentPoint, reason)

	local talentInfo = self.gameplayTalentInfos[gameplayId]

	if not talentInfo then
		talentInfo = {
			["\\xabpv"] = 0,
			["a\\xab\\xb4\\xaa\\xba"] = 1,
			["\\xab5,:v\\x89q\\xd6>\\xa4\\xad"] = 0,
			UnlockTalentInfoDict = {}
		}
		self.gameplayTalentInfos[gameplayId] = talentInfo
	end

	talentInfo.TalentPoint = talentPoint

	self:CheckHasCanUnLockGameplayTalent(gameplayId)
	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_TALENT_CHANGE, {
		gameplayId = gameplayId,
		talentPoint = talentPoint
	})
end

M.OnSyncActiveGameplayTalent = function(self, gameplayId, talentId, layer)
	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return
	end

	self:Log("OnSyncActiveGameplayTalent", gameplayId, talentId, layer)

	local talentInfo = self.gameplayTalentInfos[gameplayId]

	if not talentInfo then
		talentInfo = {
			["\\xabpv"] = 0,
			["a\\xab\\xb4\\xaa\\xba"] = 1,
			["\\xab5,:v\\x89q\\xd6>\\xa4\\xad"] = 0,
			UnlockTalentInfoDict = {}
		}
		self.gameplayTalentInfos[gameplayId] = talentInfo
	end

	talentInfo.UnlockTalentInfoDict[talentId] = {
		TalentId = talentId,
		Layer = layer
	}

	self:CheckHasCanUnLockGameplayTalent(gameplayId)
	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_TALENT_CHANGE, {
		gameplayId = gameplayId,
		talentId = talentId
	})
end

M.OnSyncGameplayTalentExpAndLevel = function(self, gameplayId, addExp, exp, level)
	self:Log("OnSyncGameplayTalentExpAndLevel", gameplayId, addExp, exp, level)

	local talentInfo = self.gameplayTalentInfos[gameplayId]

	if not talentInfo then
		talentInfo = {
			["\\xabpv"] = 0,
			["a\\xab\\xb4\\xaa\\xba"] = 1,
			["\\xab5,:v\\x89q\\xd6>\\xa4\\xad"] = 0,
			UnlockTalentInfoDict = {}
		}
		self.gameplayTalentInfos[gameplayId] = talentInfo
	end

	talentInfo.Exp = exp
	talentInfo.Level = level

	self:CheckHasCanUnLockGameplayTalent(gameplayId)
	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_TALENT_CHANGE, {
		gameplayId = gameplayId
	})
end

M.AskActiveGameplayTalent = function(self, gameplayId, talentId, callback)
	gClientToGameDelegate:AskActiveGameplayTalentLayer(gameplayId, talentId, 1).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("C_TalentTreeMgr AskActiveGameplayTalent err:", err)

			return
		end

		if callback then
			callback()
		end

		local msg = {
			gameplayId = gameplayId,
			talentId = talentId
		}

		gMessageManager:SendMessage(gEventConstants.GAMEPLAY_TALENT_ACTIVE, msg)
	end
end

M.OnResetGameplayTalentTree = function(self, gameplayId)
	self:Log("OnResetGameplayTalentTree", gameplayId)

	gClientToGameDelegate:AskResetGameplayTalent(gameplayId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.GetGameplayCurrentGraphPath = function(self, gameplayId, treeId)
	treeId = treeId or self:GetGameplayTalentTreeId(gameplayId)
	local cfg = TalentTreeConfig.GetConfig(treeId)

	if not cfg then
		return "", 1, 1
	end

	local talentDict = self:GetGameplayTalentDict(gameplayId)
	local talentCount = table.count(talentDict)

	for i = #cfg.Path, 1, -1 do
		local path = cfg.Path[i]
		local need = cfg.TalentCountNeed[i]

		if need < talentCount then
			return path, i, i ~= #cfg.Path and 0 or cfg.TalentCountNeed[i + 1]
		end
	end

	return "", 1, 1
end

M._IsTarkovGameplay = function(self, gameplayId)
	local cfg = TalentTreeGamePlayConfig.GetConfig(gameplayId)

	if not cfg then
		return false
	end

	return cfg.useTarkovItem
end

M._GetTalentCostItems = function(self, cfg)
	local ret = {}

	if not cfg then
		return ret
	end

	if not table.isNilOrEmpty(cfg.CostItem) then
		for i = 1, #cfg.CostItem do
			table.insert(ret, cfg.CostItem[i])
		end
	end

	if not table.isNilOrEmpty(cfg.CostExtractionShooterItem) then
		for i = 1, #cfg.CostExtractionShooterItem do
			table.insert(ret, cfg.CostExtractionShooterItem[i])
		end
	end

	return ret
end

M.CheckTalentTreeUseTalentPoint = function(self, treeId)
	local talentIds = self.TalentTree2TalentDict[treeId] or {}

	for i = 1, #talentIds do
		local cfg = TalentConfig.GetConfig(talentIds[i])

		if cfg and cfg.CostPoint <= 0 then
			return true
		end
	end

	return false
end

M._BuildCostItemIndex = function(self)
	self.treeCostItemDict = {}
	self.costItemId2TreeDict = {}

	for i = 0, TalentConfig.count - 1 do
		local cfg = TalentConfig.LoadAt(i)
		local treeIds = cfg.TalentTreeid

		if type(treeIds) == "table" then
			treeIds = {
				treeIds
			}
		end

		local costItems = self:_GetTalentCostItems(cfg)

		for j = 1, #costItems do
			local costItem = costItems[j]
			local itemId = costItem and costItem.itemId or 0

			if itemId == 0 then
				for k = 1, #treeIds do
					local treeId = treeIds[k]
					self.treeCostItemDict[treeId] = self.treeCostItemDict[treeId] or {}
					self.treeCostItemDict[treeId][itemId] = true
					self.costItemId2TreeDict[itemId] = self.costItemId2TreeDict[itemId] or {}
					self.costItemId2TreeDict[itemId][treeId] = true
				end
			end
		end
	end
end

M._GetTalentCostCountLabel = function(self, currentNum, needNum)
	if currentNum >= needNum then
		return "#R" .. currentNum .. "#z/" .. needNum
	end

	return currentNum .. "/" .. needNum
end

M._CheckTalentCostItemEnough = function(self, cfg, gameplayId)
	if not cfg then
		return false
	end

	local costItems = self:_GetTalentCostItems(cfg)

	if table.isNilOrEmpty(costItems) then
		return true
	end

	local isTarkov = gameplayId and self:_IsTarkovGameplay(gameplayId)

	for i = 1, #costItems do
		local costItem = costItems[i]
		local itemId = costItem and costItem.itemId or 0

		if itemId == 0 then
			local needNum = costItem.num or 0

			if gCommonItemManager:GetItemNum(itemId, isTarkov) >= needNum then
				return false
			end
		end
	end

	return true
end

M._GetTalentCostItemRenderData = function(self, cfg, gameplayId)
	local ret = {}
	local costItems = self:_GetTalentCostItems(cfg)

	if table.isNilOrEmpty(costItems) then
		return ret
	end

	local isTarkov = gameplayId and self:_IsTarkovGameplay(gameplayId)

	for i = 1, #costItems do
		local costItem = costItems[i]
		local itemId = costItem and costItem.itemId or 0

		if itemId == 0 then
			local needNum = costItem.num or 0
			local currentNum = gCommonItemManager:GetItemNum(itemId, isTarkov)

			table.insert(ret, gCommonItemManager:GetItemRenderData({
				itemId = itemId,
				itemNum = self:_GetTalentCostCountLabel(currentNum, needNum),
				isTarkov = isTarkov
			}))
		end
	end

	return ret
end

M._RefreshTalentConsumeStore = function(self, store, cfg, talentPoint, gameplayId)
	local costItemList = self:_GetTalentCostItemRenderData(cfg, gameplayId)
	local hasCostItem = not table.isNilOrEmpty(costItemList)
	store.isConsume = BOOL2CTL[hasCostItem]

	if hasCostItem then
		store.itemList.luaSimpleRenderItem = function(itemBtn, itemIndex)
			local itemData = costItemList[itemIndex + 1]

			if not itemData then
				return
			end

			gCommonItemManager:OnCommonItemRender(itemBtn, itemIndex, itemData)
		end

		store.itemList:SetSimpleList(#costItemList)
	end

	if cfg.CostPoint <= 0 then
		store.pointList:SetSimpleList(1)
		store.pointList:SetItemLabel(0, self:_GetTalentCostCountLabel(talentPoint, cfg.CostPoint))
	end
end

M._GetTalentLockLabel = function(self, cfg, lockType, jobName, progressParam)
	if lockType ~= StaticProps.LOCK_TYPE.Job then
		return gString.Format(TextScriptTextConfig.GetConfig(89901119).Text, jobName or "")
	elseif lockType ~= StaticProps.LOCK_TYPE.PreTalent then
		return TextScriptTextConfig.GetConfig(89901118).Text
	elseif lockType ~= StaticProps.LOCK_TYPE.IsUnlock then
		return TextScriptTextConfig.GetConfig(89901266).Text
	elseif lockType ~= StaticProps.LOCK_TYPE.TalentPoint then
		return TextScriptTextConfig.GetConfig(89901267).Text
	elseif lockType ~= StaticProps.LOCK_TYPE.CostItem then
		return MessageConfig.GetConfig(65403834).Content
	elseif lockType ~= StaticProps.LOCK_TYPE.EventCondition then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.TalentTree, cfg.Id, progressParam)

		return gString.Format(TextScriptTextConfig.GetConfig(89901338).Text, cfg.MaxProgress - progress)
	end

	return ""
end

M._RefreshTalentToolTipStore = function(self, store, cfg, currentLv, talentPoint, jobName, lockType, canUnLock, closeBtnCb, activeBtnCb, progressParam)
	store.nameLabel = cfg.Name
	store.iconId = cfg.IconId
	local hasLv = cfg.LayerNum >= 1

	store.descList:SetSimpleList(0)

	for i = 1, #cfg.Description do
		local title = cfg.Description[i]
		local isActive = i > currentLv

		if hasLv then
			store.descList:AddSimpleLabel(0, gString.Format(TextScriptTextConfig.GetConfig(89901298).Text, i), i, false, isActive)
		end

		store.descList:AddSimpleLabel(0, title, i, false, isActive)
	end

	store.descList:RefreshList()

	store.hasLv = BOOL2CTL[hasLv]
	store.lvLabel = gString.Format(TextScriptTextConfig.GetConfig(89901299).Text, currentLv, cfg.LayerNum)
	store.jobName = jobName or ""

	self:_RefreshTalentConsumeStore(store, cfg, talentPoint, progressParam)

	store.detailIcon = cfg.DetailIconId
	store.hasImg = BOOL2CTL[cfg.DetailIconId >= 0]
	store.closeBtn.luaClick = closeBtnCb
	store.lockType = lockType
	store.lockLabel = self:_GetTalentLockLabel(cfg, lockType, store.jobName, progressParam)
	store.activeBtn.interactable = canUnLock
	store.activeBtn.luaClick = activeBtnCb

	store.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)

	return store
end

M.RefreshGameplayTalentToolTip = function(self, toolTip, talentId, gameplayId, closeBtnCb, activeBtnCb)
	local store = gStoreManager:GetStoreGroup("TalentToolTipStore"):GetStoreByWidget(toolTip)

	if not store then
		return nil
	end

	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		print_error("[TalentTreeMgr] RefreshGameplayTalentToolTip talentId not exist: talentId = ", talentId, "gameplayId = ", gameplayId)

		return store
	end

	local canUnLock, lockType = self:CheckGameplayTalentCanUnlock(talentId, gameplayId)
	local talentPoint = self:GetGameplayTalentPoint(gameplayId)
	local talentDict = self:GetGameplayTalentDict(gameplayId)
	local talentInfo = talentDict[talentId]
	local currentLv = talentInfo and talentInfo.Layer or 0

	return self:_RefreshTalentToolTipStore(store, cfg, currentLv, talentPoint, "", lockType, canUnLock, closeBtnCb, activeBtnCb or function ()
		self:AskActiveGameplayTalent(gameplayId, talentId)
	end, gameplayId)
end

M.GetAllTalentTreeTab = function(self, jobClass, gameplayId, jobClassList)
	jobClassList = jobClassList or gSpiritJobManager:GetAvailableJobClass()
	local currentJobClass = jobClass or gSpiritJobManager.GetCurSpiritJobClassId()
	local jobDict = {
		[0] = true
	}

	for i = 1, #jobClassList do
		jobDict[jobClassList[i]] = true
	end

	local ret = {}

	for i = 0, TalentTreeConfig.count - 1 do
		local cfg = TalentTreeConfig.LoadAt(i)
		local rgameplayId = cfg.GameplayId or 0

		if gameplayId then
			if gameplayId ~= rgameplayId then
				table.insert(ret, {
					["\\xda\\xce*\\xe5"] = false,
					id = cfg.Id,
					guideId = cfg.GuideId,
					title = cfg.Name,
					iconId = cfg.IconId,
					gameplayId = rgameplayId
				})
			end
		elseif gSystemUnlockMgr:IsUnlockGroup(cfg.SystemIdList) and self:CheckMultiverseMatch(cfg) and self:CheckSpiritIdMatch(cfg) and cfg.showInGroup then
			if rgameplayId ~= 0 then
				if jobDict[cfg.JobClassId] then
					table.insert(ret, {
						id = cfg.Id,
						current = cfg.JobClassId ~= currentJobClass,
						guideId = cfg.GuideId,
						title = cfg.Name,
						iconId = cfg.IconId
					})
				end
			else
				table.insert(ret, {
					["\\xda\\xce*\\xe5"] = false,
					id = cfg.Id,
					guideId = cfg.GuideId,
					title = cfg.Name,
					iconId = cfg.IconId,
					gameplayId = rgameplayId
				})
			end
		end
	end

	return ret
end

M.CheckPreTalentIsUnLocked = function(self, talentId, jobClassId)
	local cfg = TalentConfig.GetConfig(talentId)
	local talentDict = self:GetCurrentTalentDict(jobClassId)

	for i = 1, #cfg.PreTalentIds do
		local id = cfg.PreTalentIds[i]
		local talentCfg = TalentConfig.GetConfig(id)

		if talentCfg then
			local talentInfo = talentDict[id]

			if talentInfo and talentInfo.Layer <= 0 then
				return true
			end
		end
	end

	return table.isNilOrEmpty(cfg.PreTalentIds)
end

M.CheckTalentIsLocked = function(self, talentId, jobClassId)
	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return false
	end

	local talentDict = self:GetCurrentTalentDict(jobClassId)
	local talentInfo = talentDict[talentId]

	if table.isNilOrEmpty(talentInfo) then
		return true
	end

	return talentInfo.Layer <= talentCfg.LayerNum
end

M.RefreshTalentToolTip = function(self, toolTip, talentId, jobClassId, closeBtnCb, activeBtnCb)
	local store = gStoreManager:GetStoreGroup("TalentToolTipStore"):GetStoreByWidget(toolTip)

	if not store then
		return nil
	end

	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		print_error("[TalentTreeMgr] RefreshTalentToolTip talentId not exist: talentId = ", talentId, "jobClassId = ", jobClassId)

		return store
	end

	local jCfg = nil

	if jobClassId == 0 then
		jCfg = JobConfig.GetConfig(cfg.JobRequest)

		if not jCfg or jCfg.JobClass == jobClassId then
			return store
		end
	end

	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local canUnLock, lockType = self:CheckTalentCanUnlock(talentId)
	local talentPoint = self:GetCurrentTalentPoint(jobClassId)
	local talentDict = self:GetCurrentTalentDict(jobClassId)
	local talentInfo = talentDict[talentId]
	local currentLv = talentInfo and talentInfo.Layer or 0

	return self:_RefreshTalentToolTipStore(store, cfg, currentLv, talentPoint, jCfg and jCfg.Name or "", lockType, canUnLock, closeBtnCb, activeBtnCb or function ()
		self:AskActiveTalent(spiritId, jobClassId, talentId)
	end, gBattleSpiritMgr.currentSpiritTemplateId)
end

M.GetCurrentGraphPath = function(self, treeId)
	local cfg = TalentTreeConfig.GetConfig(treeId)

	if not cfg then
		return "", 1
	end

	local talentDict = self:GetCurrentTalentDict(cfg.JobClassId)
	local talentCount = table.count(talentDict)

	for i = #cfg.Path, 1, -1 do
		local path = cfg.Path[i]
		local need = cfg.TalentCountNeed[i]

		if need < talentCount then
			return path, i, i ~= #cfg.Path and 0 or cfg.TalentCountNeed[i + 1]
		end
	end

	return "", 1
end

M.AskActiveTalent = function(self, spiritId, jobClassId, talentId, callback)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId

	gClientToGameDelegate:AskActiveSpiritJobTalentLayer(spiritId, jobClassId, talentId, 1).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("C_TalentTreeMgr AskActiveTalent err:", err)

			return
		end

		if callback then
			callback()
		end

		gNewGuideMgr:NotifySignal(EGuideSignal.TalentUnlock, tostring(talentId))

		local msg = {
			spiritId = spiritId,
			jobClassId = jobClassId,
			talentId = talentId
		}

		gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_ACTIVE, msg)
	end
end

M.CheckHasTalentTree = function(self)
	local jobClassList = gSpiritJobManager:GetAvailableJobClass()
	local jobDict = {
		[0] = true
	}

	for i = 1, #jobClassList do
		jobDict[jobClassList[i]] = true
	end

	for i = 0, TalentTreeConfig.count - 1 do
		local cfg = TalentTreeConfig.LoadAt(i)

		if gSystemUnlockMgr:IsUnlockGroup(cfg.SystemIdList) and self:CheckMultiverseMatch(cfg) and self:CheckSpiritIdMatch(cfg) then
			if cfg.GameplayId ~= 0 then
				if jobDict[cfg.JobClassId] then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

M.CheckTalentCanUnlock = function(self, talentId, skipTalentPoint)
	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		return false, StaticProps.LOCK_TYPE.None
	end

	local jobCfg = JobConfig.GetConfig(cfg.JobRequest)

	if cfg.JobRequest == 0 and not jobCfg then
		return false, StaticProps.LOCK_TYPE.None
	end

	local isReadyJob = self.cacheJobDict[cfg.JobRequest] or false

	if not isReadyJob then
		return false, StaticProps.LOCK_TYPE.Job
	end

	local jobClassId = jobCfg and jobCfg.JobClass or 0
	local isReadyTalent = self:CheckPreTalentIsUnLocked(talentId, jobClassId)

	if not isReadyTalent then
		return false, StaticProps.LOCK_TYPE.PreTalent
	end

	local isLock = self:CheckTalentIsLocked(talentId, jobClassId)

	if not isLock then
		return false, StaticProps.LOCK_TYPE.IsUnlock
	end

	local talentPoint = self:GetCurrentTalentPoint(jobClassId)
	local isLackTalentPoint = talentPoint <= cfg.CostPoint

	if talentPoint >= cfg.CostPoint and not skipTalentPoint then
		return false, StaticProps.LOCK_TYPE.TalentPoint
	end

	if not self:_CheckTalentCostItemEnough(cfg) then
		return false, StaticProps.LOCK_TYPE.CostItem
	end

	if not gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.TalentTree) then
		return false, StaticProps.LOCK_TYPE.EventCondition
	end

	return true, isLackTalentPoint and StaticProps.LOCK_TYPE.TalentPoint or StaticProps.LOCK_TYPE.None
end

M.CheckTalentCostItemEnough = function(self, talentId, gameplayId)
	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		return false
	end

	return self:_CheckTalentCostItemEnough(cfg, gameplayId)
end

M.CheckHasCanUnLockTalent = function(self, skipGameplay)
	if self._cacheDirty then
		self:OnStartCurrent()
	end

	local jobClassList = gSpiritJobManager:GetAvailableJobClass()

	table.insert(jobClassList, 0)

	for i = 1, #jobClassList do
		local jobClass = jobClassList[i]
		local treeDict = self.jobClass2TalentTreeDict[jobClass] or {}

		for j = 1, #treeDict do
			local treeId = self.jobClass2TalentTreeDict[jobClass][j]
			local treeCfg = TalentTreeConfig.GetConfig(treeId)

			if treeCfg and treeCfg.GameplayId ~= 0 and gSystemUnlockMgr:IsUnlockGroup(treeCfg.SystemIdList) and self:CheckMultiverseMatch(treeCfg) and self:CheckSpiritIdMatch(treeCfg) then
				local talentDict = self.TalentTree2TalentDict[treeId] or {}
				local canUnlock = false
				local talentId = 0

				for k = 1, #talentDict do
					talentId = talentDict[k]
					canUnlock, _ = self:CheckTalentCanUnlock(talentId)

					if canUnlock then
						break
					end
				end

				local redKey = self:GetRedDot(treeId)

				RedDotMgr.LuaSetRedDot(canUnlock, redKey)
				self:Log("CheckHasCanUnLockTalent", treeId, canUnlock, talentId, redKey)
			end
		end
	end

	if not skipGameplay then
		self:CheckHasCanUnLockGameplayTalent()
	end
end

M.CheckHasCanUnLockGameplayTalent = function(self, gameplayId)
	slot2 = pairs
	slot4 = self.gameplayId2TalentDict or {}

	for currentGameplayId, talentDict in slot2(slot4) do
		if not gameplayId or currentGameplayId ~= gameplayId then
			local treeIds = self:GetGameplayTalentTreeIds(currentGameplayId)

			for _, treeId in ipairs(treeIds) do
				local treeCfg = TalentTreeConfig.GetConfig(treeId)

				if treeCfg and gSystemUnlockMgr:IsUnlockGroup(treeCfg.SystemIdList) and self:CheckMultiverseMatch(treeCfg) and self:CheckSpiritIdMatch(treeCfg) then
					local canUnlock = false
					local talentId = 0

					for i = 1, #talentDict do
						talentId = talentDict[i]
						canUnlock, _ = self:CheckGameplayTalentCanUnlock(talentId, currentGameplayId)

						if canUnlock then
							break
						end
					end

					local redKey = self:GetRedDot(treeId)

					RedDotMgr.LuaSetRedDot(canUnlock, redKey)
					self:Log("CheckHasCanUnLockGameplayTalent", treeId, currentGameplayId, canUnlock, talentId)
				end
			end
		end
	end
end

M.CheckTalentTreeSystemUnlock = function(self)
	return gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.TalentTree)
end

M.GetCurrentActiveTalentIds = function(self, jobClassId)
	local talentDict = self:GetCurrentTalentDict(jobClassId)
	local ids = {}

	for talentId in pairs(talentDict) do
		table.insert(ids, talentId)
	end

	return ids
end

M.GetCurrentActiveTalentCount = function(self, jobClassId)
	return self:GetSpiritActiveTalent(nil, jobClassId)
end

M.GetSpiritActiveTalent = function(self, spiritId, jobClassId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return 0
	end

	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId == 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
	end

	local totalCount = 0

	for k, v in pairs(talentInfo.UnlockTalentInfoDict) do
		totalCount = totalCount + v.Layer
	end

	return totalCount
end

M.OnSyncSpiritTalentExpAndLevel = function(self, spiritId, addExp, exp, level, notify)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	self:Log("OnSyncSpiritTalentExpAndLevel", spiritId, addExp, exp, level)

	local talentInfo = spirit.SpiritInfo.TalentInfo

	if notify and addExp == 0 and self:CheckTalentTreeSystemUnlock() then
		local msg = {
			spiritId = spiritId,
			diff = addExp,
			exp = exp,
			level = level
		}

		gNewPopupManager:PushPopup(PopupConfig.AgentTalentExpTip, msg)
	end

	talentInfo.Exp = exp
	talentInfo.Level = level

	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE)
end

M.Test = function(self)
	local exp, _, level = self:GetCurrentExpInfo(15020992)
	local msg = {
		["\\xb8\\xa1\\xb9c*\\xd77"] = 15020992,
		["~+{]"] = 0,
		exp = exp,
		level = level
	}

	gNewPopupManager:PushPopup(PopupConfig.AgentTalentExpTip, msg)
end

M.GetCurrentExpInfo = function(self, spiritId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return 0, 0, 0
	end

	local talentInfo = spirit.SpiritInfo.TalentInfo
	local cfg = TalentTreeLevelConfig.GetConfig(talentInfo.Level)

	if not cfg or talentInfo.Level ~= TalentTreeLevelConfig.count then
		return 0, 0, talentInfo.Level
	end

	return talentInfo.Exp, cfg.Exp, talentInfo.Level
end

M.CanLevelUp = function(self)
	local _, _, currentLevel = self:GetCurrentExpInfo()
	local nextLevel = currentLevel + 1
	local nextCfg = TalentTreeLevelConfig.GetConfig(nextLevel)
	local currentCfg = TalentTreeLevelConfig.GetConfig(currentLevel)

	if not nextCfg then
		return self.MAX_STATE.TRUE, 0
	end

	if not currentCfg then
		return self.MAX_STATE.TRUE, 0
	end

	if currentCfg.Fan < gPlayerManager.infoMinor.bindData.fan123 then
		return self.MAX_STATE.FALSE, 0
	end

	return self.MAX_STATE.LOCK, currentCfg.Fan
end

M.GetExperienceMaterials = function(self)
	local list = {}

	for i = 0, ConsumableConfig.count - 1 do
		local cfg = ConsumableConfig.LoadAt(i)

		if cfg and (cfg.TalentExp or 0) <= 0 then
			table.insert(list, {
				templateId = cfg.Id,
				exp = cfg.TalentExp,
				ownCount = gCommonItemManager:GetItemNum(cfg.Id) or 0
			})
		end
	end

	return list
end

M.GetMaterialExpValue = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	return cfg and cfg.TalentExp or 0
end

M.CalcPreviewExpGain = function(self, itemId, count)
	if not count or count < 0 then
		return 0
	end

	return self:GetMaterialExpValue(itemId) * count
end

M.HasEnoughMaterial = function(self, itemId, count)
	return count > (gCommonItemManager:GetItemNum(itemId) or 0)
end

M.RequestAddSpiritTalentExp = function(self, spiritId, items, callback)
	self:Log("RequestAddSpiritTalentExp", spiritId, items)

	local requests = {}
	slot5 = ipairs
	slot7 = items or {}

	for _, it in slot5(slot7) do
		if it.count and it.count <= 0 then
			local need = it.count
			local packItems = gCommonItemManager:GetPackItemsByTemplateId(it.templateId)
			slot12 = ipairs
			slot14 = packItems or {}

			for _, packItem in slot12(slot14) do
				if need < 0 then
					break
				end

				local uid = packItem.UniqueId
				local have = packItem.Count

				if uid and have and have <= 0 then
					local useCount = need >= have and need or have
					requests[uid] = (requests[uid] or 0) + useCount
					need = need - useCount
				end
			end
		end
	end

	if not next(requests) then
		if callback then
			callback(MessageConfig.Ok)
		end

		return
	end

	if not gClientToGameDelegate.AskBatchUseItems then
		if callback then
			callback(MessageConfig.Ok)
		end

		return
	end

	gClientToGameDelegate:AskBatchUseItems(requests).Callback = function (err)
		if callback then
			callback(err)
		end
	end
end

M.OpenTalentExpPanel = function(self, spiritId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId

	gPanelManager:CheckShow(gPanelId.TALENT_EXP_PANEL, {
		spiritId = spiritId
	})
end

M.IsBadgeActive = function(self, spiritId, badgeId)
	if spiritId and spiritId == 0 then
		local spirit = gSpiritManager:GetSpirit(spiritId)

		if spirit then
			local badges = spirit.SpiritInfo.InfoBadge.Badges
			local badge = badges and badges[badgeId]

			if badge and badge.Active then
				return true
			end
		end
	end

	local globalBadges = gPlayerManager.infoMinor.bindData.Badges
	local badge = globalBadges and globalBadges[badgeId]

	return badge and badge.Active or false
end

M.CalcSpiritTalentExpAddition = function(self, spiritId, changeExp)
	if changeExp ~= 0 then
		return 0
	end

	if spiritId and spiritId == 0 and gBattleSpiritMgr.currentSpiritTemplateId == spiritId then
		return changeExp
	end

	if not TalentTreeBadgeAdditionExpConfig or TalentTreeBadgeAdditionExpConfig.count ~= 0 then
		return changeExp
	end

	local addRate = 0

	for i = 0, TalentTreeBadgeAdditionExpConfig.count - 1 do
		local cfg = TalentTreeBadgeAdditionExpConfig.LoadAt(i)

		if cfg and cfg.BadgeIds then
			for j = 1, #cfg.BadgeIds do
				if self:IsBadgeActive(spiritId, cfg.BadgeIds[j]) then
					addRate = addRate + (cfg.AddRate or 0)

					break
				end
			end
		end
	end

	if addRate ~= 0 then
		return changeExp
	end

	local result = math.floor(changeExp * (1 + addRate))

	return result
end

M.OnResetTalentTree = function(self, jobClassId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	self:Log("OnResetTalentTree", spiritId, jobClassId)
	gDisplayMessageMgr:ShowMessage(MessageConfig.TalentTreeResetConfirm, function ()
		gClientToGameDelegate:AskResetSpiritJobTalent(spiritId, jobClassId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end)
end

M.GetRedDot = function(self, treeId)
	local cfg = TalentTreeConfig.GetConfig(treeId)

	if not cfg then
		return ""
	end

	local redCfg = PanelRedDotConfig.GetConfig(cfg.RedDotId)

	return ("%s/%s"):format(self.baseKey, redCfg.Name)
end

gTalentTreeMgr = gTalentTreeMgr or C_TalentTreeMgr.new()
