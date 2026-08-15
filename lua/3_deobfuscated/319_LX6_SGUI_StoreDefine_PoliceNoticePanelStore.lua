local AgentConfig = LTConfig.AgentConfig
C_PoliceNoticePanelStore = DefClass("C_PoliceNoticePanelStore", C_PoliceNoticePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceNoticePanelStore = C_PoliceNoticePanelStore
local M = C_PoliceNoticePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local REFRESH_SEC = 1

function M:ctor()
	self.mgr = gPoliceJobManager.panelMgr
	self.isMistake = false
	self.lastUpdateTime = 0
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitClick")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self:CreateAction("OnPreRenderContentItem")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnRenderContentItem")
	self.bindData.contentList.onGetTIndex = self:CreateAction("GetSupportTIndex")
end

function M:InitView(data)
	if data then
		self.isMistake = data.isMistake and data.isMistake or false
	end

	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
	gNewGuideMgr:NotifySignal(EGuideSignal.PoliceNoticePanelOnShow)
end

function M:OnUpdate()
	if not self.isInAnim and REFRESH_SEC < gLogicTime.time - self.lastUpdateTime then
		self:RefreshNotice()
	end
end

function M:OnExecuteExitAction()
	self.mgr:CloseCurrentPanel()
end

function M:OnPreRenderContentItem(btn, index)
	local data = self.noticeList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= 0 then
		local info = self.mgr:GetCaseInfo(data.cId)
		local fineList, factor = self.mgr:GetFineList(info.Fines)

		function store.fineList.luaSimpleRenderItem(fineBtn, fineIndex)
			local fineData = fineList[fineIndex + 1]

			if fineData then
				local fineStore = gStoreManager:GetStoreGroup(fineBtn.Store):GetStoreByWidget(fineBtn)

				if fineStore then
					fineStore.title = fineData.label
				end
			end
		end

		store.fineList:SetSimpleList(#fineList)
	end
end

function M:OnRenderContentItem(btn, index)
	local data = self.noticeList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local proficiency, gold = nil

	if data.tIndex == 0 then
		local info = self.mgr:GetViolationInfo(data.cId)
		proficiency, gold = self.mgr:GetAwardByDropId({
			info.Drop
		})
		store.nameLabel = info.Violation
		store.dateLabel = gTimeUtils:DateFormat("%d-%02d-%02d", data.time)
		store.inBanned = BOOL2CTL[data.forceLeave > 0 and true or false]
		store.bannedReason = self.mgr:GetViolationDesc(data.cId)
		store.iconId = info.Icon
		store.RemainTime = gCS.TimeManager.ServerUnixTime < data.forceLeave and self.mgr:GetViolationSimpleDesc(data.forceLeave) or ""
	else
		local info = self.mgr:GetCaseInfo(data.cId)
		local agentCfg = AgentConfig.GetConfig(info.NpcId)

		if not agentCfg then
			return
		end

		proficiency, gold = self.mgr:GetAwardByDropId(info.BonusDrops)
		store.nameLabel = agentCfg.Name
		local fineList, factor = self.mgr:GetFineList(info.Fines)
		store.factor = factor
		store.dateLabel = gTimeUtils:DateFormat("%d-%02d-%02d", info.Time)

		function store.fineList.luaSimpleRenderItem(fineBtn, fineIndex)
			local fineData = fineList[fineIndex + 1]

			if not fineData then
				return
			end

			local fineStore = gStoreManager:GetStoreGroup(fineBtn.Store):GetStoreByWidget(fineBtn)

			if fineStore then
				fineStore.title = fineData.label
			end
		end

		store.fineList:SetSimpleList(#fineList)

		store.showRewardBtn = BOOL2CTL[not info.RewardTaken]

		function store.receiveBtn.luaClick()
			self:OnReciveAawrd(data.cId)
		end
	end

	if proficiency or gold then
		store.awardProficiency, store.showProficiency = self.mgr:GetNumberStr(proficiency)
		store.awardGold, store.showGold = self.mgr:GetNumberStr(gold)
	end
end

function M:OnReciveAawrd(cId)
	self.isInAnim = true

	Timer.New(function ()
		self.isInAnim = false

		self.mgr:AskReceiveCaseAward(cId)
	end, 2.1):Start()
end

function M:RefreshPage()
	if self.bindData.contentList then
		self.lastUpdateTime = gLogicTime.time
		self.noticeList = self.mgr:GetNoticeList(not self.isMistake)

		self.bindData.contentList:SetSimpleList(#self.noticeList)
		self.bindData.contentList:SetNavSelectToTop()

		self.bindData.isEmpty = BOOL2CTL[#self.noticeList <= 0]
	end
end

function M:RefreshNotice()
	self.isInAnim = false
	self.lastUpdateTime = gLogicTime.time

	self.bindData.contentList:RefreshList()
end

function M:GetSupportTIndex(index)
	local data = self.noticeList[index + 1]

	return data.tIndex
end
