-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceNoticePanelStore.lua
-- Decompiled from: 02072_PoliceNoticePanelStore.lua_a1a24a3d71e2.luajit

local AgentConfig = LTConfig.AgentConfig
C_PoliceNoticePanelStore = DefClass("C_PoliceNoticePanelStore", C_PoliceNoticePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PoliceNoticePanelStore = C_PoliceNoticePanelStore
local M = C_PoliceNoticePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local REFRESH_SEC = 1

M.ctor = function(self)
	self.mgr = gPoliceJobManager.panelMgr
	self.isMistake = false
	self.lastUpdateTime = 0
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnPreRenderContentItem")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderContentItem")
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, "GetSupportTIndex")
end

M.InitView = function(self, data)
	if data then
		self.isMistake = data.isMistake and data.isMistake or false
	end

	self.mgr:RenderCurrentSpirit(self.bindData.avatar)
	gNewGuideMgr:NotifySignal(EGuideSignal.PoliceNoticePanelOnShow)
end

M.OnUpdate = function(self)
	if not self.isInAnim and REFRESH_SEC >= gLogicTime.time - self.lastUpdateTime then
		self.RefreshNotice(self)
	end
end

M.OnExecuteExitAction = function(self)
	self.mgr:CloseCurrentPanel()
end

M.OnPreRenderContentItem = function(self, btn, index)
	local data = self.noticeList[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	if data.tIndex == 0 then
		local info = self.mgr:GetCaseInfo(data.cId)
		local fineList = self.mgr:GetFineList(info)

		store.fineList.luaSimpleRenderItem = function(fineBtn, fineIndex)
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

M.OnRenderContentItem = function(self, btn, index)
	local data = self.noticeList[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local proficiency, gold = nil

	if data.tIndex ~= 0 then
		local info = self.mgr:GetViolationInfo(data.cId)
		proficiency, gold = self.mgr:GetAwardByDropId({
			info.Drop
		})
		store.nameLabel = info.Violation
		store.dateLabel = gTimeUtils:DateFormat("%d-%02d-%02d", data.time)
		store.inBanned = BOOL2CTL[data.forceLeave <= 0 and true or false]
		store.bannedReason = self.mgr:GetViolationDesc(data.cId)
		store.iconId = info.Icon
		store.RemainTime = gCS.TimeManager.ServerUnixTime >= data.forceLeave and self.mgr:GetViolationSimpleDesc(data.forceLeave) or ""
	else
		local info = self.mgr:GetCaseInfo(data.cId)
		local agentCfg = AgentConfig.GetConfig(info.NpcId)

		if not agentCfg then
			return
		end

		proficiency, gold = self.mgr:GetAwardByDropId(info.BonusDrops)
		store.nameLabel = agentCfg.Name
		local fineList = self.mgr:GetFineList(info)

		if info.IsFakePerson then
			store.factor = 1
			store.fakeCtrl = 1
			store.clueCtrl = info.HasUnlockClue and 1 or 0
		else
			store.factor = 0
			store.fakeCtrl = 0
			store.clueCtrl = 0
		end

		slot10 = gTimeUtils
		store.dateLabel = slot10:DateFormat("%d-%02d-%02d", info.Time)

		store.fineList.luaSimpleRenderItem = function(fineBtn, fineIndex)
			local fineData = fineList[fineIndex + 1]

			if not fineData then
				return
			end

			local fineStore = gStoreManager:GetStoreGroup(fineBtn.Store):GetStoreByWidget(fineBtn)

			if fineStore then
				fineStore.title = fineData.label
			end
		end

		slot10 = store.fineList

		slot10:SetSimpleList(#fineList)

		store.showRewardBtn = BOOL2CTL[not info.RewardTaken]

		store.receiveBtn.luaClick = function()
			self:OnReciveAawrd(data.cId)
		end
	end

	if proficiency or gold then
		store.awardProficiency, store.showProficiency = self.mgr:GetNumberStr(proficiency)
		store.awardGold, store.showGold = self.mgr:GetNumberStr(gold)
	end
end

M.OnReciveAawrd = function(self, cId)
	self.isInAnim = true

	Timer.New(function ()
		self.isInAnim = false

		self.mgr:AskReceiveCaseAward(cId)
	end, 2.1):Start()
end

M.RefreshPage = function(self)
	if self.bindData.contentList then
		self.lastUpdateTime = gLogicTime.time
		self.noticeList = self.mgr:GetNoticeList(not self.isMistake)

		self.bindData.contentList:SetSimpleList(#self.noticeList)
		self.bindData.contentList:SetNavSelectToTop()

		self.bindData.isEmpty = BOOL2CTL[#self.noticeList > 0]
	end
end

M.RefreshNotice = function(self)
	self.isInAnim = false
	self.lastUpdateTime = gLogicTime.time

	self.bindData.contentList:RefreshList()
end

M.GetSupportTIndex = function(self, index)
	local data = self.noticeList[index + 1]

	return data.tIndex
end
