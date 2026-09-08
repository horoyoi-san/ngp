-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryDronePanelStore.lua
-- Decompiled from: 01950_DeliveryDronePanelStore.lua_8fa6ba9bfa9e.luajit

C_DeliveryDronePanelStore = DefClass("C_DeliveryDronePanelStore", C_DeliveryDronePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryDronePanelStore = C_DeliveryDronePanelStore
local M = C_DeliveryDronePanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.callDroneButton.luaClick = self.CreateAction(self, "OnCallDroneButtonClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.supportConfig = args.supportConfig
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.SUMMON_STATE_SWITCH] = self.CreateAction(self, self.RefreshDroneView),
		[gEventConstants.UAV_LOGIC_STATE_CHANGE] = self.CreateAction(self, self.RefreshDroneState)
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatarWidget, self.rootGo)
	self.RefreshDroneView(self)
end

M.RefreshDroneView = function(self)
	self.bindData.callBtnState = gDeliveryTaskManager.CheckHasDroneAgent() and 1 or 0

	self:RefreshDroneState()
end

M.RefreshDroneState = function(self)
	self.bindData.droneState = gDeliveryTaskManager.TryGetDroneState() or 0
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

M.OnCallDroneButtonClick = function(self)
	gDeliveryTaskManager.DoDroneSupport(self.supportConfig.functionId)
	self.RefreshDroneView(self)
end
