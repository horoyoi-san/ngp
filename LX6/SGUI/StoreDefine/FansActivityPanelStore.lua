-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FansActivityPanelStore.lua
-- Decompiled from: 01850_FansActivityPanelStore.lua_d7942e0085fd.luajit

local AwardActivityConfig = LTConfig.AwardActivityConfig
C_FansActivityPanelStore = DefClass("C_FansActivityPanelStore", C_FansActivityPanelStore, C_StoreGroup)
GroupName2Class.FansActivityPanelStore = C_FansActivityPanelStore
local M = C_FansActivityPanelStore
local FANS_GOAL_BG_PATH_FORMAT = "Assets/Res/SGUI/Texture/Activity/Texture/Texture/%s.png"
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gAwardActivityManager
	self.itemMgr = gCommonItemManager
end

M.DefineAllVariables = function(self)
	self.activityId = 0
	self.cfg = nil
	self.rewardList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.countdownCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.stateCtrlEnum = {
		["\\xd8\\xd82\\xf4"] = 1,
		["r#k^"] = 2,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.specialCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.countdownCtrlEnum = nil
	self.stateCtrlEnum = nil
	self.specialCtrlEnum = nil
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

M.OnShow = function(self, panelId, activityId)
	self.m_Id = panelId
	self.activityId = activityId
	self.cfg = AwardActivityConfig.GetConfig(activityId)

	self.RefreshPage(self)
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
		self.bindData.countdown:Play(duration)
	end

	self.bindData.titleText = self.cfg.Title
	self.bindData.descText = self.cfg.Desc
	self.bindData.bgImageId = self.cfg.BgImage
	local currentFans = self.mgr:GetLevelLandmarkProgress()
	self.bindData.fansText = self:_FormatFansText(currentFans)
	self.rewardList = self.mgr:GetLevelLandmarkList(self.activityId)

	self.bindData.rewardList:SetSimpleList(#self.rewardList)
end

M.OnRenderRewardItem = function(self, btn, index)
	local info = self.rewardList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if not store or not info then
		return
	end

	store.stateCtrl = self:_GetRowStateCtrl(info)
	store.fansCntText = info.goalValue
	store.fansSpecCntText = gString.Format("%dW", info.goalValue)
	local isLast = index + 1 ~= #self.rewardList
	store.specialCtrl = BOOL2CTL[isLast]
	store.fansGoalImagePath = FANS_GOAL_BG_PATH_FORMAT:format(info.goalValue)
	local drops = self.itemMgr:GetSingleSortedListRenderData(info.dropId, true)

	if table.isNilOrEmpty(drops) or not store.item then
		return
	end

	local itemData = drops[1]
	itemData.IsOwned = info.isGot

	self.itemMgr:OnCommonItemRender(store.item, 0, itemData)
end

M.OnClickRewardItem = function(self, btn, index)
	local info = self.rewardList[index + 1]

	if not info then
		return
	end

	if info.isFinish and not info.isGot then
		self.mgr:AskTakeReward(self.activityId, info.id)

		return
	end
end

M._FormatFansText = function(self, value)
	return gString.Format("%.1f", value or 0)
end

M._GetRowStateCtrl = function(self, info)
	if info.isGot then
		return self.stateCtrlEnum.have
	end

	if info.isFinish then
		return self.stateCtrlEnum.achieve
	end

	return self.stateCtrlEnum.normal
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self.CreateAction(self, self.RefreshPage),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, self.RefreshPage)
	}
end

M.RegisterWidget = function(self)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	self.bindData.rewardList.luaSimpleClick = self.CreateAction(self, self.OnClickRewardItem)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
end

M.OnBackBtnClick = function(self)
	if self.parent then
		self.parent:OnBackBtnClick()
	end
end
