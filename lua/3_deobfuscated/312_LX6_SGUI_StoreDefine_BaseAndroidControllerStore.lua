C_BaseAndroidControllerStore = DefClass("C_BaseAndroidControllerStore", C_BaseAndroidControllerStore, C_StoreGroup)
GroupName2Class.BaseAndroidControllerStore = C_BaseAndroidControllerStore
local M = C_BaseAndroidControllerStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.curTab = -1
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
	self:StopActiveGameplay()
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ANDROID_CONTROL_SWITCH] = self:CreateAction("OnAndroidControlSwitch")
	}
end

function M:RegisterWidget()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
end

function M:OnTabRectRender(index, widget)
	self.curAndroidStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curAndroidStore then
		self.curAndroidStore:OnShow(nil, self.data)
	end
end

function M:StartAndroidByType(androidType, data)
	if androidType == nil then
		return
	end

	self.curTab = androidType
	self.data = data
	self.bindData.tabRect.selectedIndex = androidType
end

function M:StopAndroidByType(vehicleType)
	if vehicleType == self.curTab then
		self:StopActiveGameplay()
	end
end

function M:StopActiveGameplay()
	self.curTab = -1
	self.data = nil

	if self.curAndroidStore then
		self.curAndroidStore:OnClose()
	end

	self.curAndroidStore = nil
	self.bindData.tabRect.selectedIndex = self.curTab
end

function M:OnAndroidControlSwitch(eventId, data)
	local needLoading = data.reason == UX.Game.SwitchControlReason.Client or data.reason == UX.Game.SwitchControlReason.DesignerLoading or data.reason == UX.Game.SwitchControlReason.Distance or data.reason == UX.Game.SwitchControlReason.Death

	if data.type == LTConfig.SummonConfig.TypeType.UAV then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot()
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_FLYER, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_FLYER, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_FLYER, true)
			self:StopAndroidByType(gAndroidType.ROBOT_FLYER)
		end
	elseif data.type == LTConfig.SummonConfig.TypeType.SpiderBot then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot()
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_SPIDER, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_SPIDER, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_SPIDER, true)
			self:StopAndroidByType(gAndroidType.ROBOT_SPIDER)
		end
	elseif data.type == LTConfig.SummonConfig.TypeType.Dog then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot()
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_DOG, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_DOG, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_DOG, true)
			self:StopAndroidByType(gAndroidType.ROBOT_DOG)
		end
	elseif data.type == LTConfig.SummonConfig.TypeType.Closestool then
		-- Nothing
	end
end
