-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceArchivePanelStore.lua
-- Decompiled from: 00782_PoliceArchivePanelStore.lua_a65752196c47.luajit

C_PoliceArchivePanelStore = DefClass("C_PoliceArchivePanelStore", C_PoliceArchivePanelStore, C_StoreGroup)
GroupName2Class.PoliceArchivePanelStore = C_PoliceArchivePanelStore
local M = C_PoliceArchivePanelStore
local FakeFileConfig = LTConfig.PoliceFakeFileConfig
local FakeFileState = UX.Game.PoliceFakeFileState
local STATE = {
	["Y.h^"] = 2,
	["V\r^p"] = 3,
	["y\\x9c\\x83\\x8c\\x93"] = 1,
	[")f\\xbd\\xa1\\xa0j"] = 0
}

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
	self.POS_TYPE = {
		["X\rNh"] = 1,
		["YH~"] = 3,
		["`hAYo08="] = 2,
		["T\rS~"] = 0
	}
end

M.HookFakeFileWidget = function(self)
	local BOSS = self.POS_TYPE.BOSS
	local COMPANION = self.POS_TYPE.COMPANION
	local CLUE = self.POS_TYPE.CLUE
	self.posInfo = {
		[0] = {
			posType = BOSS,
			posWidget = self.bindData.boss
		},
		{
			posType = COMPANION,
			posWidget = self.bindData.companion1
		},
		{
			posType = COMPANION,
			posWidget = self.bindData.companion2
		},
		{
			posType = COMPANION,
			posWidget = self.bindData.companion3
		},
		{
			posType = COMPANION,
			posWidget = self.bindData.companion4
		},
		[11] = {
			posType = CLUE,
			posWidget = self.bindData.clue11
		},
		[12] = {
			posType = CLUE,
			posWidget = self.bindData.clue12
		},
		[13] = {
			posType = CLUE,
			posWidget = self.bindData.clue13
		},
		[14] = {
			posType = CLUE,
			posWidget = self.bindData.clue14
		},
		[21] = {
			posType = CLUE,
			posWidget = self.bindData.clue21
		},
		[22] = {
			posType = CLUE,
			posWidget = self.bindData.clue22
		},
		[23] = {
			posType = CLUE,
			posWidget = self.bindData.clue23
		},
		[24] = {
			posType = CLUE,
			posWidget = self.bindData.clue24
		},
		[25] = {
			posType = CLUE,
			posWidget = self.bindData.clue25
		},
		[26] = {
			posType = CLUE,
			posWidget = self.bindData.clue26
		},
		[27] = {
			posType = CLUE,
			posWidget = self.bindData.clue27
		},
		[31] = {
			posType = CLUE,
			posWidget = self.bindData.clue31
		},
		[32] = {
			posType = CLUE,
			posWidget = self.bindData.clue32
		},
		[33] = {
			posType = CLUE,
			posWidget = self.bindData.clue33
		},
		[34] = {
			posType = CLUE,
			posWidget = self.bindData.clue34
		},
		[35] = {
			posType = CLUE,
			posWidget = self.bindData.clue35
		},
		[41] = {
			posType = CLUE,
			posWidget = self.bindData.clue41
		},
		[42] = {
			posType = CLUE,
			posWidget = self.bindData.clue42
		},
		[43] = {
			posType = CLUE,
			posWidget = self.bindData.clue43
		},
		[44] = {
			posType = CLUE,
			posWidget = self.bindData.clue44
		},
		[45] = {
			posType = CLUE,
			posWidget = self.bindData.clue45
		},
		[46] = {
			posType = CLUE,
			posWidget = self.bindData.clue46
		}
	}
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshFakeFileView(self)
end

M.OnClose = function(self)
	self.mainFakeList = nil
	self.leftListData = nil
	self.rightListData = nil
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.POLICE_NEW_FAKE_FILE] = self.CreateAction(self, self.RefreshFakeFileView)
	}
end

M.RegisterWidget = function(self)
	self.bindData.leftList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderLeftListItem)
	self.bindData.rightList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRightListItem)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)

	self.HookFakeFileWidget(self)
end

M.OnBackBtnClick = function(self)
	if not self.CloseOtherTooltip(self) then
		gPanelManager:Close(self.m_Id)
	end
end

M.RefreshFakeFileView = function(self)
	if not self.mainFakeList then
		self.mainFakeList = {}
	end

	if #self.mainFakeList ~= 0 then
		self.mainFakeList, self.childFileIdMap = self.mgr:GetMainFakeList()
	end

	local curInfo = self.mgr:GetCurrentFakeFileInfo()
	local tid = gSpiritManager:GetCurFirstSpiritTid()

	for i = 1, #self.mainFakeList do
		local cfg = FakeFileConfig.GetConfig(self.mainFakeList[i])
		local posInfo = self.posInfo[cfg.Pos]

		if posInfo then
			if posInfo.posType ~= self.POS_TYPE.BOSS then
				self.RefreshBoss(self, posInfo.posWidget, cfg, curInfo, tid)
			elseif posInfo.posType ~= self.POS_TYPE.COMPANION then
				self.RefreshCompanion(self, posInfo.posWidget, cfg, curInfo, tid)
			elseif posInfo.posType ~= self.POS_TYPE.CLUE then
				self.RefreshClue(self, posInfo.posWidget, cfg, curInfo, tid)
			end
		else
			print_error("@liuyibing：Police FakeFile Id can not map to widget pos! FakeFile id: " .. tostring(self.mainFakeList[i]) .. " desired pos: " .. tostring(cfg.Pos))
		end
	end

	self.leftListData, self.rightListData = self.mgr:GetNormalLeftAndRightFakeList()

	self.bindData.leftList:SetSimpleList(#self.leftListData)
	self.bindData.rightList:SetSimpleList(#self.rightListData)

	local systemUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.PoliceFake)
	self.bindData.densityCtrl = systemUnlock and 0 or 2
end

M.RefreshBoss = function(self, widget, cfg, info, spiritTid)
	local store = self.GetStoreByWidget(self, widget)

	if store then
		local isUnlock = false
		local canTraceTask = false
		local submitTask = false
		local acceptTask = false
		store.num = ""
		local infoState = self.mgr:GetFakeInfoState(cfg.Id, info)

		if infoState and infoState <= 0 then
			isUnlock = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.Unlock)
			canTraceTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.CanTraceTask)
			submitTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.SubmitTask)
			acceptTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.AcceptTask)

			if submitTask then
				store.state = STATE.UNLOCK
			elseif canTraceTask and not acceptTask then
				store.state = STATE.TRACE
			else
				store.state = STATE.Clue
			end
		else
			store.state = STATE.LOCK
		end

		self:RenderAgentInfoInternal(cfg.AgentId, store)

		store.traceBtn.luaClick = self:CreateActionWithArgs("AskPoliceFakeFileAcceptEvent", cfg.Id, self.mgr)
		widget.luaRenderTooltip = self:CreateActionWithArgs(self.RenderClueTooltip, cfg.Id)
		local RewardTaken = infoState and gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.RewardTaken)
		local hasReward = isUnlock and not RewardTaken
		local canTrace = false

		if not hasReward then
			canTrace = infoState and canTraceTask and not acceptTask and not submitTask
		end

		local redDotKey = self.mgr:GetArchiveRedKey(spiritTid, hasReward, canTrace, false, cfg.Id)
		widget.redKey = redDotKey
	end
end

M.RefreshCompanion = function(self, widget, cfg, info, spiritTid)
	local store = self.GetStoreByWidget(self, widget)

	if store then
		local clueId = cfg.Id
		store.num = string.format("%s%03d", cfg.Group, 0)
		local Unlock = false
		local canTraceTask = false
		local submitTask = false
		local acceptTask = false
		local infoState = self.mgr:GetFakeInfoState(clueId, info)

		if infoState and infoState <= 0 then
			Unlock = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.Unlock)
			canTraceTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.CanTraceTask)
			submitTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.SubmitTask)
			acceptTask = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.AcceptTask)

			if submitTask then
				store.state = STATE.UNLOCK
			elseif canTraceTask and not acceptTask then
				store.state = STATE.TRACE
			else
				store.state = STATE.Clue
			end
		else
			store.state = STATE.LOCK
		end

		self:RenderAgentInfoInternal(cfg.AgentId, store)

		store.traceBtn.luaClick = self:CreateActionWithArgs("AskPoliceFakeFileAcceptEvent", cfg.Id, self.mgr)
		widget.luaRenderTooltip = self:CreateActionWithArgs(self.RenderClueTooltip, clueId)
		local RewardTaken = infoState and gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.RewardTaken)
		local hasReward = Unlock and not RewardTaken
		local canTrace = false

		if not hasReward then
			canTrace = infoState and canTraceTask and not acceptTask and not submitTask
		end

		local redDotKey = self.mgr:GetArchiveRedKey(spiritTid, hasReward, canTrace, false, cfg.Id)
		widget.redKey = redDotKey
	end
end

M.RefreshClue = function(self, widget, cfg, info, spiritTid)
	local store = self.GetStoreByWidget(self, widget)

	if store then
		local clueId = cfg.Id
		local isUnlock = self.mgr:CheckFakeInfoState(clueId, FakeFileState.Unlock, info)
		store.state = isUnlock and STATE.UNLOCK or STATE.LOCK
		local index = self.mgr:GetMapAgentIndex(clueId)

		if isUnlock then
			if cfg.Source ~= FakeFileConfig.SourceType.BranceTask then
				store.num = cfg.Label
			else
				store.num = string.format("%s%03d", cfg.Group, index or 0)
			end
		end

		local agentId = cfg.AgentId

		if (not agentId or agentId ~= 0) and index and index <= 0 then
			local historyInfo = info.HistoryClueAgentInfoList[index]
			agentId = historyInfo and historyInfo.AgentId or 0
		end

		self:RenderAgentInfoInternal(agentId, store)

		widget.luaRenderTooltip = self:CreateActionWithArgs(self.RenderClueTooltip, clueId)
		local hasReward = isUnlock and not self.mgr:CheckFakeInfoState(cfg.Id, FakeFileState.RewardTaken, info)
		local redDotKey = self.mgr:GetArchiveRedKey(spiritTid, hasReward, false, false, cfg.Id)
		widget.redKey = redDotKey
	end
end

M.RenderAgentInfoInternal = function(self, agentId, store)
	local agentInfo = self.mgr:GetAgentInfo(agentId)

	if table.isNilOrEmpty(agentInfo) then
		return
	end

	store.headIcon = agentInfo.icon
end

M.OnRenderLeftListItem = function(self, btn, index)
	local data = self.leftListData[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	self.CommonRenderSideClueItem(self, btn, store, data)
end

M.OnRenderRightListItem = function(self, btn, index)
	local data = self.rightListData[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	self.CommonRenderSideClueItem(self, btn, store, data)
end

M.CommonRenderSideClueItem = function(self, btn, store, data)
	if data.agentId <= 0 then
		store.state = STATE.UNLOCK
		local index = data.index
		local cfg = FakeFileConfig.GetConfig(data.nearId)
		local group = cfg and cfg.Group
		store.num = string.format("%s%03d", group or "", index or 0)

		self:RenderAgentInfoInternal(data.agentId, store)

		local redDotKey = self.mgr:GetArchiveSideRedDotKey(self.mgr.tid, index)
		btn.redKey = redDotKey
	else
		store.state = STATE.LOCK
	end

	btn.luaRenderTooltip = self.CreateActionWithArgs(self, self.RenderAgentTooltip, data)
end

M.RenderClueTooltip = function(self, clueId, btn, popIns, index)
	local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

	if not popStore then
		return
	end

	local clueCfg = FakeFileConfig.GetConfig(clueId)
	local info = self.mgr:GetCurrentFakeFileInfo()
	local infoState = self.mgr:GetFakeInfoState(clueId, info)
	local name, date, desc = nil
	local rewardToken = false
	local unlock = false

	if infoState and infoState <= 0 then
		unlock = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.Unlock)
		rewardToken = gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.RewardTaken)

		if unlock then
			popStore.lockCtrl = unlock and 0 or 1
			popStore.UnlockCtrl = unlock and 0 or 1
			local unlockTime = self.mgr:GetFakeInfoDate(clueId, info)
			date = unlockTime and gTimeUtils:DateFormat("%d-%02d-%02d", unlockTime) or ""
			local agentId = clueCfg.AgentId
			local agentIndex = self.mgr:GetMapAgentIndex(clueId)

			if (not agentId or agentId ~= 0) and agentIndex and agentIndex <= 0 then
				local clueAgentInfo = info.HistoryClueAgentInfoList[agentIndex]
				agentId = clueAgentInfo.AgentId
			end

			name = self:GetAgentName(agentId)
			local showIndex = self.mgr:GetMapAgentIndex(clueId)

			if string.is_null_or_empty(clueCfg.Group) then
				popStore.numCtrl = 0
				popStore.numText = ""
			else
				popStore.numCtrl = 1

				if clueCfg.Source ~= FakeFileConfig.SourceType.BranceTask then
					popStore.numText = clueCfg.Label
				else
					popStore.numText = string.format("%s%03d", clueCfg.Group, showIndex or 0)
				end
			end

			if string.is_null_or_empty(clueCfg.Desc) then
				desc = clueCfg.ClueDesc or ""
			else
				desc = clueCfg.Desc
			end

			if agentIndex and agentIndex <= 0 and info.HistoryClueAgentInfoList[agentIndex] and not info.HistoryClueAgentInfoList[agentIndex].IsRead then
				self.mgr:AskReadPoliceFakeClueAgentInfoList({
					agentIndex - 1
				})
			end
		end

		popStore.btnCtrl = 0

		if clueCfg.TaskEventId and clueCfg.TaskEventId <= 0 and gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.CanTraceTask) and not gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.AcceptTask) and not gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.SubmitTask) then
			popStore.btnCtrl = 1
			popStore.traceBtn.luaClick = self.CreateActionWithArgs(self, "AskPoliceFakeFileAcceptEvent", clueId, self.mgr)
		end

		popStore.takeRewardCtrl = 0

		if clueCfg.Drop and clueCfg.Drop <= 0 and gPoliceJobManager.cs:ContainPoliceFakeFileState(infoState, FakeFileState.Unlock) and not rewardToken then
			popStore.takeRewardCtrl = 1
			popStore.takeRewardBtn.luaClick = self.CreateActionWithArgs(self, "AskPoliceFakeFileTakeReward", {
				fakeFileId = clueId,
				btn = btn
			}, self.mgr)
		end
	end

	if not unlock then
		popStore.lockCtrl = 1
		popStore.numCtrl = 0

		if string.is_null_or_empty(clueCfg.UnlockWayText) then
			popStore.UnlockCtrl = 0
		else
			popStore.UnlockCtrl = 1
			popStore.unlockText = clueCfg.UnlockWayText or ""
		end

		if clueCfg.CanTrack and clueCfg.HyperLink <= 0 then
			popStore.btnCtrl = 1
			popStore.traceBtn.luaClick = self.CreateActionWithArgs(self, self.ClueTraceHyperLinkClick, clueId)
		end
	end

	popStore.nameLabel = name or ""
	popStore.date = date or ""
	popStore.descLabel = desc or ""

	if clueCfg.Drop and clueCfg.Drop <= 0 and self.RenderRewardList(self, clueCfg.Drop, popStore.rewardList, rewardToken) then
		popStore.rewardCtrl = 1
	else
		popStore.rewardCtrl = 0
	end

	local child = self.childFileIdMap[clueId]
	popStore.clueCtrl = 0

	if child and #child <= 0 then
		local unlockChildren = self.GetAllUnlockClueId(self, clueId, info)

		if unlockChildren and #unlockChildren <= 0 then
			local allClueComplete = self:IsAllChildClueUnlocked(clueId)
			popStore.clueCompleteCtrl = allClueComplete and 1 or 0
			popStore.clueCtrl = 1
			popStore.clueList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderPopupClueItem, unlockChildren)

			popStore.clueList:SetSimpleList(#unlockChildren)
		end
	end

	self.CloseOtherTooltip(self, btn)
end

M.CloseOtherTooltip = function(self, curWidget)
	local closed = false

	for k, v in pairs(self.posInfo) do
		local btn = v.posWidget

		if btn == curWidget and btn.isTooltipOpen then
			closed = true

			btn.CloseTooltip(btn)
		end
	end

	local allLeftBtn = self.bindData.leftList.items:ToTable()

	if #allLeftBtn <= 0 then
		for i = 1, #allLeftBtn do
			local btn = allLeftBtn[i]

			if btn == curWidget and btn.isTooltipOpen then
				closed = true

				btn.CloseTooltip(btn)
			end
		end
	end

	local allRightBtn = self.bindData.rightList.items:ToTable()

	if #allRightBtn <= 0 then
		for i = 1, #allRightBtn do
			local btn = allRightBtn[i]

			if btn == curWidget and btn.isTooltipOpen then
				closed = true

				btn.CloseTooltip(btn)
			end
		end
	end

	return closed
end

M.IsAllChildClueUnlocked = function(self, id, info)
	local child = self.childFileIdMap[id]

	if child and #child <= 0 then
		for i = 1, #child do
			if not self.mgr:CheckFakeInfoState(child[i], FakeFileState.Unlock, info) then
				return false
			end
		end

		return true
	end

	return false
end

M.GetAllUnlockClueId = function(self, clueId, info)
	local child = self.childFileIdMap[clueId]

	if not child or #child ~= 0 then
		return nil
	end

	local ret = {}

	for i = 1, #child do
		if self.mgr:CheckFakeInfoState(child[i], FakeFileState.Unlock, info) then
			table.insert(ret, child[i])
		end
	end

	return ret
end

M.OnRenderPopupClueItem = function(self, child, btn, index)
	local data = child and child[index + 1]

	if not data or data ~= 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local clueCfg = FakeFileConfig.GetConfig(data)
	store.des = clueCfg.ClueDesc
end

M.RenderAgentTooltip = function(self, data, btn, popIns, index)
	local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

	if not popStore then
		return
	end

	if data.agentId <= 0 then
		popStore.lockCtrl = 0
		popStore.numCtrl = 1
		local agentIndex = data.index
		local cfg = FakeFileConfig.GetConfig(data.nearId)
		local group = cfg and cfg.Group
		popStore.numText = string.format("%s%03d", group or "", agentIndex or 0)
		local name = self:GetAgentName(data.agentId)
		popStore.nameLabel = name or ""
		popStore.UnlockCtrl = 0
		popStore.date = data.provideClueTime and gTimeUtils:DateFormat("%d-%02d-%02d", data.provideClueTime) or ""

		if agentIndex and agentIndex <= 0 then
			self.mgr:AskReadPoliceFakeClueAgentInfoList({
				agentIndex - 1
			})
		end
	else
		popStore.lockCtrl = 1
		popStore.numCtrl = 0
		popStore.numText = ""
		popStore.UnlockCtrl = 1
		popStore.unlockText = LTConfig.PoliceConfig.FakeFileUnlockWayText
	end

	popStore.descLabel = ""
	popStore.rewardCtrl = 0
	popStore.clueCtrl = 0

	self.CloseOtherTooltip(self, btn)
end

M.ClueTraceHyperLinkClick = function(self, clueId)
	local config = FakeFileConfig.GetConfig(clueId)

	if config and config.CanTrack and config.HyperLink <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(config.HyperLink, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end
	end
end

M.GetAgentName = function(self, agentId)
	if not agentId or agentId ~= 0 then
		return
	end

	local agentInfo = self.mgr:GetAgentInfo(agentId)

	if table.isNilOrEmpty(agentInfo) then
		return
	end

	return agentInfo.name
end

M.RenderRewardList = function(self, dropId, dropList, rewardToken)
	local dropListParam = {}

	table.insert(dropListParam, {
		dropId = dropId
	})

	local simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)

	if not table.isNilOrEmpty(simpleDropRewards) then
		if rewardToken then
			for i = 1, #simpleDropRewards do
				simpleDropRewards[i].IsOwned = true
			end
		end

		dropList.SetSimpleList(dropList, #simpleDropRewards)

		dropList.luaSimpleRenderItem = function(item, index)
			gCommonItemManager:OnCommonItemRender(item, index, simpleDropRewards[index + 1])
		end

		return true
	end

	return false
end
