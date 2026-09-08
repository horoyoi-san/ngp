-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceCaseListPanelStore.lua
-- Decompiled from: 02075_PoliceCaseListPanelStore.lua_405217a362d1.luajit

local AgentConfig = LTConfig.AgentConfig
C_PoliceCaseListPanelStore = DefClass("C_PoliceCaseListPanelStore", C_PoliceCaseListPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceCaseListPanelStore = C_PoliceCaseListPanelStore
local M = C_PoliceCaseListPanelStore
local PoliceConfig = LTConfig.PoliceConfig

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnRenderFineList")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderCaseItem")
end

M.InitView = function(self, data)
	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
end

M.OnRenderCaseItem = function(self, btn, index)
	local data = self.caseInfo[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local castInfo = self.mgr:GetCaseInfo(data.cId)
	local agentCfg = AgentConfig.GetConfig(castInfo.NpcId)

	if not agentCfg then
		return
	end

	if castInfo.IsFakePerson then
		store.fakeCtrl = 1
		store.clueCtrl = castInfo.HasUnlockClue and 1 or 0
	else
		store.fakeCtrl = 0
		store.clueCtrl = 0
	end

	store.stateLabel = self.mgr:GetStateStr(castInfo)
	store.dateLabel = gTimeUtils:DateFormat("%d-%02d-%02d", castInfo.Time)
	store.nameLabel = agentCfg.Name
	local headIcon = agentCfg.HeadIcon
	store.headIcon = headIcon == 0 and headIcon or nil
	local proficiency, gold = self.mgr:GetAwardByDropId(castInfo.BonusDrops)

	if self.mgr:IsTrialSuccess(castInfo) then
		local trialProficiency, trialGold = self.mgr:GetAwardByDropId(castInfo.NoIssuedBonusDrops)
		proficiency = proficiency + trialProficiency
		gold = gold + trialGold
	end

	store.awardProficiency, store.showProficiency = self.mgr:GetNumberStr(proficiency)
	store.awardGold, store.showGold = self.mgr:GetNumberStr(gold)
	store.trialCtrl = self.mgr:CanTrial(castInfo) and 1 or 0
	local caseId = data.cId

	store.trialBtn.luaClick = function()
		self.mgr:GoTrial(caseId, true, false)
	end

	store.trialBtn.redKey = self.mgr:GetTrialRedDotKey(nil, castInfo.Id, false)
	store.trialBtn.guide.guideID = castInfo.NpcId ~= PoliceConfig.TaskTrailHarryAgentid and PoliceConfig.CaseAgentGuideId or ""

	self:OnRenderFineList(btn, index, data)
end

M.OnRenderFineList = function(self, btn, index)
	local data = self.caseInfo[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local castInfo = self.mgr:GetCaseInfo(data.cId)
	local fineList = self.mgr:GetFineList(castInfo)

	local errorRenderFunc = function(errorBtn, errorIndex)
		local errorData = fineList[errorIndex + 1]

		if not errorData then
			return
		end

		errorBtn.title.text = errorData.label
	end

	store.errorList.luaSimpleDynamicRenderItem = errorRenderFunc
	store.errorList.luaSimpleRenderItem = errorRenderFunc

	store.errorList:SetSimpleList(#fineList)

	local resultListData = self.mgr:GetResultList(castInfo)

	local resRenderFunc = function(resultBtn, resultIndex)
		local resultData = resultListData[resultIndex + 1]

		if not resultData then
			return
		end

		resultBtn.title.text = resultData.label
	end

	store.resultList.luaSimpleDynamicRenderItem = resRenderFunc
	store.resultList.luaSimpleRenderItem = resRenderFunc

	store.resultList:SetSimpleList(#resultListData)
end

M.OnExecuteExitAction = function(self)
	self.mgr:CloseCurrentPanel()
end

M.ClearData = function(self)
	self.caseInfo = nil
end

M.RefreshPage = function(self)
	self.caseInfo = self.mgr:GetOrderCaseInfo()

	self.bindData.contentList:SetSimpleList(#self.caseInfo)

	self.bindData.isEmpty = boolToNumber(#self.caseInfo > 0)
end
