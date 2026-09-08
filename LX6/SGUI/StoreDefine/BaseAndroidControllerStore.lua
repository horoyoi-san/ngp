-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaseAndroidControllerStore.lua
-- Decompiled from: 01618_BaseAndroidControllerStore.lua_28007bcf864d.luajit

C_BaseAndroidControllerStore = DefClass("C_BaseAndroidControllerStore", C_BaseAndroidControllerStore, C_StoreGroup)
GroupName2Class.BaseAndroidControllerStore = C_BaseAndroidControllerStore
local M = C_BaseAndroidControllerStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curTab = -1
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.StopActiveGameplay(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ANDROID_CONTROL_SWITCH] = self.CreateAction(self, "OnAndroidControlSwitch")
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnTabRectRender = function(self, index, widget)
	self.curAndroidStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curAndroidStore then
		self.curAndroidStore:OnShow(nil, self.data)
	end
end

M.StartAndroidByType = function(self, androidType, data)
	if androidType ~= nil then
		return
	end

	self.curTab = androidType
	self.data = data
	self.bindData.tabRect.selectedIndex = androidType
end

M.StopAndroidByType = function(self, vehicleType)
	if vehicleType ~= self.curTab then
		self.StopActiveGameplay(self)
	end
end

M.StopActiveGameplay = function(self)
	self.curTab = -1
	self.data = nil

	if self.curAndroidStore then
		self.curAndroidStore:OnClose()
	end

	self.curAndroidStore = nil
	self.bindData.tabRect.selectedIndex = self.curTab
end

M.OnAndroidControlSwitch = function(self, eventId, data)
	local needLoading = data.reason ~= UX.Game.SwitchControlReason.Client or data.reason ~= UX.Game.SwitchControlReason.DesignerLoading or data.reason ~= UX.Game.SwitchControlReason.Distance or data.reason ~= UX.Game.SwitchControlReason.SummonedAgentDead

	if data.type ~= LTConfig.SummonConfig.TypeType.UAV then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot(data.type)
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_FLYER, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_FLYER, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_FLYER, true)
			self:StopAndroidByType(gAndroidType.ROBOT_FLYER)
		end
	elseif data.type ~= LTConfig.SummonConfig.TypeType.SpiderBot then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot(data.type)
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_SPIDER, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_SPIDER, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_SPIDER, true)
			self:StopAndroidByType(gAndroidType.ROBOT_SPIDER)
		end
	elseif data.type ~= LTConfig.SummonConfig.TypeType.Dog then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot(data.type)
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_DOG, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_DOG, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_DOG, true)
			self:StopAndroidByType(gAndroidType.ROBOT_DOG)
		end
	elseif data.type ~= LTConfig.SummonConfig.TypeType.CleanerBot then
		if needLoading then
			gLoadingManager:Quick_ViewFocusChange_Robot(data.type)
		end

		if data.enterOrLeave then
			gCoreHudModeMgr:PushHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_CLEANER, gCoreHudModeMgr.HUD_MODE.ANDROID)
			self:StartAndroidByType(gAndroidType.ROBOT_CLEANER, data)
		else
			gCoreHudModeMgr:PopHudMode("BaseAndroidControl_" .. gAndroidType.ROBOT_CLEANER, true)
			self:StopAndroidByType(gAndroidType.ROBOT_CLEANER)
		end
	end
end
