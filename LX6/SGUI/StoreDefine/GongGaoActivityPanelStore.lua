-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GongGaoActivityPanelStore.lua
-- Decompiled from: 01752_GongGaoActivityPanelStore.lua_a6c46bd8bdd5.luajit

local AwardActivityConfig = LTConfig.AwardActivityConfig
C_GongGaoActivityPanelStore = DefClass("C_GongGaoActivityPanelStore", C_GongGaoActivityPanelStore, C_StoreGroup)
GroupName2Class.GongGaoActivityPanelStore = C_GongGaoActivityPanelStore
local M = C_GongGaoActivityPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.finishCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.countdownCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.rewardCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.lockCtrlEnum = nil
	self.finishCtrlEnum = nil
	self.countdownCtrlEnum = nil
	self.rewardCtrlEnum = nil
end

M.OnAwake = function(self)
	self.mgr = gAwardActivityManager
	self.activityId = 0
	self.cfg = nil
	self.noticeParam = nil
	self.itemList = {}
	self.hyperCallBack = nil
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardListItem)
	self.bindData.gotoBtn.luaClick = self.CreateAction(self, self.OnClickGotoBtn)
	self.bindData.countDown.luaFinished = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self.CreateAction(self, self.RefreshPage)
	}
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

M.OnShow = function(self, panelId, activityId)
	self.m_Id = panelId
	self.activityId = activityId
	self.cfg = AwardActivityConfig.GetConfig(activityId)
	self.noticeCfg = self.mgr:GetNoticeConfig(activityId)

	self:RefreshPage()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.RefreshPage = function(self)
	if not self.cfg then
		return
	end

	local isPermanent = self.mgr:CheckIsPermanentActivity(self.activityId)
	local duration = self.mgr:GetActivityEndDuration(self.activityId)

	if not isPermanent and duration < 0 and self.m_Id then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.countdownCtrl = isPermanent and self.countdownCtrlEnum._false or self.countdownCtrlEnum._true

	if not isPermanent then
		self.bindData.countDown:Play(duration)
	end

	self.bindData.titleText = self.cfg.Title
	self.bindData.descText = self.cfg.Desc
	self.bindData.bgImageId = self.cfg.BgImage
	self.itemList = {}

	if self.noticeCfg and self.noticeCfg.IsShowAward then
		self.itemList = self.mgr:GetNoticeAwardList(self.activityId)
		self.bindData.rewardCtrl = self.noticeCfg.IsShowAward and self.rewardCtrlEnum.show or self.rewardCtrlEnum.hide
	end

	self.bindData.rewardList:SetSimpleList(#self.itemList)

	self.bindData.finishCtrl = BOOL2CTL[self.mgr:IsNoticeUnlocked(self.activityId)]

	self:RefreshGotoBtn()
end

M.RefreshGotoBtn = function(self)
	self.hyperCallback = nil
	local hyperLinkId = self.noticeCfg and self.noticeCfg.hyperlink or 0
	local unlockText = self.noticeCfg and self.noticeCfg.UnLockText or ""

	if hyperLinkId < 0 then
		self.bindData.lockCtrl = self.lockCtrlEnum.hide
		self.bindData.lockText = unlockText

		return
	end

	local hyperInfo = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId)

	if hyperInfo and hyperInfo.state ~= 2 then
		self.bindData.lockCtrl = self.lockCtrlEnum.show
		self.hyperCallback = hyperInfo.callback
	else
		self.bindData.lockCtrl = self.lockCtrlEnum.hide
		self.bindData.lockText = unlockText
	end
end

M.OnRenderRewardListItem = function(self, btn, index)
	local itemId = self.itemList[index + 1]

	if not itemId then
		return
	end

	local showData = gCommonItemManager:GetItemRenderData({
		itemId = itemId,
		IsOwned = self.mgr:IsNoticeUnlocked(self.activityId)
	})

	gCommonItemManager:OnCommonItemRender(btn, index, showData)
end

M.OnClickGotoBtn = function(self)
	if not self.hyperCallback then
		return
	end

	self.hyperCallback()
end

M.OnBackBtnClick = function(self)
	if self.parent then
		self.parent:OnBackBtnClick()
	end
end
