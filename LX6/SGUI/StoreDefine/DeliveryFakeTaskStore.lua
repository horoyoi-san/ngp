-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryFakeTaskStore.lua
-- Decompiled from: 01873_DeliveryFakeTaskStore.lua_46588e4b7b34.luajit

C_DeliveryFakeTaskStore = DefClass("C_DeliveryFakeTaskStore", C_DeliveryFakeTaskStore, C_StoreGroup)
GroupName2Class.DeliveryFakeTaskStore = C_DeliveryFakeTaskStore
local M = C_DeliveryFakeTaskStore
local UberSimConfig = LTConfig.UberSimConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.FAKE_DELIVERY_INTEGRITY] = self.CreateAction(self, self.ChangeIntegrity),
		[gEventConstants.FAKE_DELIVERY_END] = self.CreateAction(self, self.CloseFakePanel)
	}

	self.InitConfig(self)
end

M.CloseFakePanel = function(self)
	gPanelManager:Close(gPanelId.S_DELIVERY_FAKE_TASK_PANEL)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.FakeDeliveryEnd, {
		["__ȩ\\xad\\xb7\n\\xe0\\xec"] = 28002351,
		content = string.format(UberSimConfig.PopupSubTitle, UberSimConfig.TruckGuideContent),
		mainTitle = UberSimConfig.PopupMainTitle
	})
end

M.InitConfig = function(self)
	self.IntactSectionDescription = UberSimConfig.IntactSectionDescription
end

M.ChangeIntegrity = function(self, _, data)
	self.integrity = Mathf.Clamp(self.integrity + data.integrity, 0, 100)

	self.UpdateIntegrityText(self)
end

M.UpdateIntegrityText = function(self)
	for index, v in ipairs(self.IntactSectionDescription) do
		if v.min < self.integrity and self.integrity < v.max then
			self.bindData.cargoState = index

			return
		end
	end
end

M.OnUpdate = function(self)
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

M.OnShow = function(self, panelId, data)
	self.integrity = 98
	self.time = gCS.TimeManager.ServerUnixTime

	self.UpdateIntegrityText(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
