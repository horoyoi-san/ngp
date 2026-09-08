-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTrialResultPanelStore.lua
-- Decompiled from: 00794_PoliceTrialResultPanelStore.lua_cbb50e9b5be1.luajit

C_PoliceTrialResultPanelStore = DefClass("C_PoliceTrialResultPanelStore", C_PoliceTrialResultPanelStore, C_StoreGroup)
GroupName2Class.PoliceTrialResultPanelStore = C_PoliceTrialResultPanelStore
local M = C_PoliceTrialResultPanelStore
local PoliceCaseInterrogationState = UX.Game.PoliceCaseInterrogationState
local PoliceFineConfig = LTConfig.PoliceFineConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.resultCtrlEnum = {
		["\\xec"] = 1,
		["\\xfe"] = 0,
		["\\xee"] = 2,
		["\\xe9"] = 3
	}
	self.archiveCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.TEMPLATE_INDEX = {
		["NEo"] = 0,
		["y\\x87\\x96\\x83\\x93"] = 1,
		[".m\\xa6\\xaf\\xb1e"] = 2
	}
	self.TITLE_TYPE = {
		[".m\\xa6\\xaf\\xb1e"] = 2,
		["\\xbcMU"] = 1,
		["\\S~"] = 0
	}
	self.mgr = gPoliceJobManager.panelMgr
end

M.ClearAllEnumsAutoGen = function(self)
	self.resultCtrlEnum = nil
	self.archiveCtrlEnum = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitPoliceTrialResult(self, data.settlement, data.summary)
end

M.OnClose = function(self)
	self.rewardItemList = nil
	self.listData = nil
end

M.OnLanguageChange = function(self, lang)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, "OnClickNextBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
end

M.OnClickNextBtn = function(self)
	gPanelManager:Close(gPanelId.POLICE_TRIAL_RESULT_PANEL)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.TEMPLATE_INDEX.TITLE then
		store.title = data.title
	elseif data.tIndex ~= self.TEMPLATE_INDEX.TEXT then
		store.title = data.content
	elseif data.tIndex ~= self.TEMPLATE_INDEX.REWARD then
		local caseInfo = self.mgr:GetCaseInfo(self.caseId)
		local drops = {}

		if caseInfo.NoIssuedBonusDrops.Count <= 0 then
			for i = 1, caseInfo.NoIssuedBonusDrops.Count do
				table.insert(drops, {
					["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
					["N\\xa1\\xb7\\xa1\\xa2"] = 1,
					dropId = caseInfo.NoIssuedBonusDrops[i]
				})
			end
		end

		local awardList = gCommonItemManager:GetItemSortedListByDropList(drops, true)
		self.rewardItemList = {}

		for j = 1, #awardList do
			local view = {
				["\\xf0\\xc8;\n!\\xf5"] = false,
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				itemId = awardList[j].Id,
				itemNum = awardList[j].Count
			}

			table.insert(self.rewardItemList, gCommonItemManager:GetItemRenderData(view))
		end

		store.list.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
			local award = self.rewardItemList[rewardIndex + 1]

			gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, award)
		end

		store.list:SetSimpleList(#self.rewardItemList)
	end
end

M.OnGetListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.InitPoliceTrialResult = function(self, settlement, summary)
	self.state = settlement.State
	self.caseId = settlement.CaseId

	if settlement.State ~= PoliceCaseInterrogationState.GreatSuccess then
		self.bindData.resultCtrl = self.resultCtrlEnum.S
	elseif settlement.State ~= PoliceCaseInterrogationState.Success then
		self.bindData.resultCtrl = self.resultCtrlEnum.A
	elseif settlement.State ~= PoliceCaseInterrogationState.CanInterrogate then
		self.bindData.resultCtrl = self.resultCtrlEnum.C
	elseif settlement.State ~= PoliceCaseInterrogationState.Failed then
		self.bindData.resultCtrl = self.resultCtrlEnum.D
	end

	self.GetListData(self, summary)
	self.RefreshFakeFile(self)
end

M.RefreshFakeFile = function(self)
	local caseInfo = self.mgr:GetCaseInfo(self.caseId)
	local unlock = caseInfo.HasUnlockClue
	self.bindData.archiveCtrl = unlock and self.archiveCtrlEnum._true or self.archiveCtrlEnum._false

	if unlock then
		local store = gStoreManager:GetStoreGroup(self.bindData.avatar.Store):GetStoreByWidget(self.bindData.avatar)

		if not store then
			return
		end

		local agentInfo = self.mgr:GetAgentInfo(caseInfo.NpcId)

		if table.isNilOrEmpty(agentInfo) then
			return
		end

		store.headIcon = agentInfo.icon

		self.bindData.avatar.luaRenderTooltip = function(btn, popIns, index)
			local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

			if not popStore then
				return
			end

			local popCaseInfo = self.mgr:GetCaseInfo(self.caseId)
			local popAgentInfo = self.mgr:GetAgentInfo(popCaseInfo.NpcId)
			local clueAgentInfo, clueId = self.mgr:GetPresentGotClueInfo(popCaseInfo.NpcId)

			if table.isNilOrEmpty(popAgentInfo) or not clueAgentInfo then
				return
			end

			local clueCfg = clueId and LTConfig.PoliceFakeFileConfig.GetConfig(clueId)
			popStore.nameLabel = popAgentInfo.name
			popStore.descLabel = clueCfg and clueCfg.ClueDesc or ""
			popStore.date = gTimeUtils:DateFormat("%d-%02d-%02d", clueAgentInfo.ProvideClueTime)
			popStore.lockCtrl = 0
			popStore.btnCtrl = 0
			popStore.UnlockCtrl = 0
			popStore.rewardCtrl = 0
			popStore.clueCtrl = 0
			popStore.numCtrl = 0
		end
	end
end

M.GetListData = function(self, summary)
	self.listData = {}
	local caseInfo = self.mgr:GetCaseInfo(self.caseId)

	if summary then
		table.insert(self.listData, {
			tIndex = self.TEMPLATE_INDEX.TEXT,
			content = summary
		})
	end

	self:InsertFines(caseInfo)
	self:InsertResult(caseInfo)
	self:InsertReward()
	self.bindData.list:SetSimpleList(#self.listData)
end

M.InsertFines = function(self, caseInfo)
	if (self.state ~= PoliceCaseInterrogationState.GreatSuccess or self.state ~= PoliceCaseInterrogationState.Success) and caseInfo and (caseInfo.Fines.Count >= 0 or caseInfo.NoCheckCrimeList.Count <= 0) then
		table.insert(self.listData, {
			tIndex = self.TEMPLATE_INDEX.TITLE,
			type = self.TITLE_TYPE.FINE,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901441).Text
		})

		local content = nil

		if caseInfo.Fines.Count <= 0 then
			for i = 1, caseInfo.Fines.Count do
				local fineId = caseInfo.Fines[i]
				local fineCfg = PoliceFineConfig.GetConfig(fineId)

				if fineCfg and fineCfg.Factor > 3 then
					if content then
						content = string.format("%s %s", content, fineCfg.Title)
					else
						content = fineCfg.Title
					end
				end
			end
		end

		if caseInfo.NoCheckCrimeList.Count <= 0 then
			for i = 1, caseInfo.NoCheckCrimeList.Count do
				local fineId = caseInfo.NoCheckCrimeList[i]
				local fineCfg = PoliceFineConfig.GetConfig(fineId)

				if fineCfg and fineCfg.Factor > 3 then
					if content then
						content = string.format("%s %s", content, fineCfg.Title)
					else
						content = fineCfg.Title
					end
				end
			end
		end

		table.insert(self.listData, {
			tIndex = self.TEMPLATE_INDEX.TEXT,
			content = content
		})
	end
end

M.InsertResult = function(self, caseInfo)
	table.insert(self.listData, {
		tIndex = self.TEMPLATE_INDEX.TITLE,
		type = self.TITLE_TYPE.RES,
		title = LTConfig.TextScriptTextConfig.GetConfig(89901438).Text
	})

	local content = nil
	local res = self.mgr:GetResultList(caseInfo)

	if #res then
		for i = 1, #res do
			if content then
				content = string.format("%s %s", content, res[i].label)
			else
				content = res[i].label
			end
		end
	end

	table.insert(self.listData, {
		tIndex = self.TEMPLATE_INDEX.TEXT,
		content = content
	})
end

M.InsertReward = function(self)
	if self.state ~= PoliceCaseInterrogationState.GreatSuccess or self.state ~= PoliceCaseInterrogationState.Success then
		table.insert(self.listData, {
			tIndex = self.TEMPLATE_INDEX.TITLE,
			type = self.TITLE_TYPE.REWARD,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901439).Text
		})
		table.insert(self.listData, {
			tIndex = self.TEMPLATE_INDEX.REWARD
		})
	end
end
