local MessageConfig = LTConfig.MessageConfig
local AwardActivityConfig = LTConfig.AwardActivityConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local AwardActivityTemplateConfig = LTConfig.AwardActivityTemplateConfig
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local RedDotMgr = SGUI.RedDotMgr
C_AwardActivityManager = DefClass("C_AwardActivityManager", C_AwardActivityManager)
local M = C_AwardActivityManager

function M:ctor()
	self:Clear()

	self.AWARD_STATE = {
		RECEIVED = 2,
		LOCKED = 0,
		UNRECEIVED = 1
	}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
end

function M:OnBeforeSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

function M:Clear()
	self.activityDict = {}
end

function M:CheckHasActivity()
	local systemUnlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.AwardActivity)

	return gGameSwitch.EnableActivity and not table.isNilOrEmpty(self.activityDict) and systemUnlock
end

function M:GetActivityList()
	local ret = {}

	for k, v in pairs(self.activityDict) do
		local cfg = AwardActivityConfig.GetConfig(k)

		if cfg then
			local ele = {
				Order = cfg.Order,
				id = k,
				title = cfg.Title
			}
			ret[#ret + 1] = ele
		end
	end

	table.sort(ret, function (a, b)
		return a.Order < b.Order
	end)

	return ret
end

function M:GetActivityTemplateIndex(activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	return cfg and cfg.TemplateId - 1 or 0
end

function M:GetActivityInfo(activityCfgId)
	return self.activityDict[activityCfgId] or {}
end

function M:GetActivityEndDuration(activityCfgId)
	local activityInfo = self:GetActivityInfo(activityCfgId)

	if table.isNilOrEmpty(activityInfo) or activityInfo.ActivityData.IsOutOfDate then
		return 0
	end

	return activityInfo.BaseActivityInfo.EndTime - gCS.TimeManager.ServerUnixTime
end

function M:OpenActivity()
	if not self:CheckHasActivity() then
		return false
	end

	gPanelManager:CheckShow(gPanelId.ACTIVITY_BASE_PANEL)

	return true
end

function M:GetAwaradList(activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return {}
	end

	local ret = {}

	if cfg.TemplateId == AwardActivityTemplateConfig.SignIn then
		self:GetSignInAwardList(ret, cfg)
	end

	return ret
end

function M:GetFinalSignIn(id)
	local info = self.activityDict[id].ActivityData

	if table.isNilOrEmpty(info.SignInList) then
		return 1
	end

	return #info.SignInList
end

function M:GetSignInAwardList(ret, cfg)
	local info = self.activityDict[cfg.Id].ActivityData
	local signList = info.SignInList
	local rewardList = self.activityDict[cfg.Id].BaseActivityInfo.DisplayReward
	local dropList = self.activityDict[cfg.Id].BaseActivityInfo.Rewards

	if table.isNilOrEmpty(signList) or table.isNilOrEmpty(rewardList) or table.isNilOrEmpty(dropList) then
		return
	end

	for i = 1, #rewardList do
		local signIn = signList[i]
		local state = signIn and self.AWARD_STATE.UNRECEIVED or self.AWARD_STATE.LOCKED

		if signIn and signIn.IsGot then
			state = self.AWARD_STATE.RECEIVED
		end

		local ele = {
			state = state,
			itemId = rewardList[i],
			dropId = dropList[i]
		}
		ret[#ret + 1] = ele
	end
end

function M:RefreshAwardState(activityCfgId, index)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return {}
	end

	if cfg.TemplateId == AwardActivityTemplateConfig.SignIn then
		self:RefreshSignInAwardState(cfg, index)
	end

	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

function M:RefreshSignInAwardState(cfg, index)
	local info = self.activityDict[cfg.Id].ActivityData
	local signIn = info.SignInList[index]

	if not signIn then
		return
	end

	self.activityDict[cfg.Id].ActivityData.SignInList[index].IsGot = true
end

function M:AskTakeReward(activityCfgId, index)
	gClientToGameDelegate:AskTakeAccumulateSignInReward(activityCfgId, index).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshAwardState(activityCfgId, index)
		self:RefreshRedDot(activityCfgId)
	end
end

function M:RefreshRedDot(key)
	if key then
		RedDotMgr.LuaSetRedDot(self:CheckHasNewInfo(key), self:GetRedDot(key))

		return
	end

	for k, v in pairs(self.activityDict) do
		local hasNew = self:CheckHasNewInfo(k)

		RedDotMgr.LuaSetRedDot(hasNew, self:GetRedDot(k))
	end
end

function M:GetRedId(activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)
	local template = cfg and cfg.TemplateId or 0
	local tCfg = AwardActivityTemplateConfig.GetConfig(template)

	return tCfg and tCfg.RedDotKey or 0
end

function M:GetRedDot(activityCfgId)
	local cfg = PanelRedDotConfig.GetConfig(self:GetRedId(activityCfgId))

	if not cfg then
		return ""
	end

	return "Activity/" .. cfg.Name
end

function M:CheckHasNewInfo(activityCfgId)
	if not self.activityDict[activityCfgId] then
		return false
	end

	local baseRed = self.activityDict[activityCfgId].ActivityData.ShowRedPoint

	if baseRed then
		return true
	end

	local rewardList = self:GetAwaradList(activityCfgId)

	for i = 1, #rewardList do
		if rewardList[i].state == self.AWARD_STATE.UNRECEIVED then
			return true
		end
	end

	return false
end

function M:AskCancelRedPoint(activityCfgId)
	if table.isNilOrEmpty(self.activityDict[activityCfgId]) then
		return
	end

	local hasRedPoint = self.activityDict[activityCfgId].ActivityData.ShowRedPoint

	if not hasRedPoint then
		return
	end

	self.activityDict[activityCfgId].ActivityData.ShowRedPoint = false

	gClientToGameDelegate:AskActivityCancelRedPoint(activityCfgId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.activityDict[activityCfgId].ActivityData.ShowRedPoint = true

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshRedDot(activityCfgId)
	end
end

function M:OnSyncAwardActivity(activities)
	for i = 1, #activities do
		self.activityDict[activities[i].ActivityData.CfgId] = activities[i]
	end

	self:RefreshRedDot()
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

function M:OnSyncNewActivity(activity)
	self.activityDict[activity.ActivityData.CfgId] = activity

	self:RefreshRedDot(activity.ActivityData.CfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

function M:OnSyncActivityData(activityData)
	if table.isNilOrEmpty(self.activityDict[activityData.CfgId]) then
		return
	end

	self.activityDict[activityData.CfgId].ActivityData = activityData

	self:RefreshRedDot(activityData.CfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

function M:OnRemoveActivity(activityCfgId)
	self.activityDict[activityCfgId] = nil

	self:RefreshRedDot(activityCfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

gAwardActivityManager = gAwardActivityManager or C_AwardActivityManager.new()
