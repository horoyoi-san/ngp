local AgentConfig = LTConfig.AgentConfig
C_PoliceCaseListPanelStore = DefClass("C_PoliceCaseListPanelStore", C_PoliceCaseListPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceCaseListPanelStore = C_PoliceCaseListPanelStore
local M = C_PoliceCaseListPanelStore

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitClick")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self:CreateAction("OnRenderFineList")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnRenderCaseItem")
end

function M:InitView(data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

function M:OnRenderCaseItem(btn, index)
	local data = self.caseInfo[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local castInfo = self.mgr:GetCaseInfo(data.cId)
	local agentCfg = AgentConfig.GetConfig(castInfo.NpcId)

	if not agentCfg then
		return
	end

	store.dateLabel = gTimeUtils:DateFormat("%d-%02d-%02d", castInfo.Time)
	store.nameLabel = agentCfg.Name
	store.stateLabel = self.mgr:GetStateStr(castInfo)
	local headIcon = agentCfg.HeadIcon
	store.headIcon = headIcon ~= 0 and headIcon or nil
	local proficiency, gold = self.mgr:GetAwardByDropId(castInfo.BonusDrops)
	store.awardProficiency, store.showProficiency = self.mgr:GetNumberStr(proficiency)
	store.awardGold, store.showGold = self.mgr:GetNumberStr(gold)

	self:OnRenderFineList(btn, index, data)
end

function M:OnRenderFineList(btn, index)
	local data = self.caseInfo[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local castInfo = self.mgr:GetCaseInfo(data.cId)
	local fines = castInfo.Fines
	local fineList, _ = self.mgr:GetFineList(fines)

	store.errorList:SetSimpleList(#fineList)

	function store.errorList.luaSimpleRenderItem(errorBtn, errorIndex)
		local errorData = fineList[errorIndex + 1]

		if not errorData then
			return
		end

		local errorStore = self:GetStoreByWidget(errorBtn)

		if not errorStore then
			return
		end

		errorStore.title = errorData.label
	end

	local resultListData = self.mgr:GetResultList(castInfo)

	store.resultList:SetSimpleList(#resultListData)

	function store.resultList.luaSimpleRenderItem(resultBtn, resultIndex)
		local resultData = resultListData[resultIndex + 1]

		if not resultData then
			return
		end

		local resultStore = self:GetStoreByWidget(resultBtn)

		if not resultStore then
			return
		end

		resultStore.title = resultData.label
	end
end

function M:OnExecuteExitAction()
	self.mgr:CloseCurrentPanel()
end

function M:ClearData()
	self.caseInfo = nil
end

function M:RefreshPage()
	self.caseInfo = self.mgr:GetOrderCaseInfo()

	self.bindData.contentList:SetSimpleList(#self.caseInfo)

	self.bindData.isEmpty = boolToNumber(#self.caseInfo <= 0)
end
