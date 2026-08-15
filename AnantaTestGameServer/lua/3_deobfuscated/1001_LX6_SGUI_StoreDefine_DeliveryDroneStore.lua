C_DeliveryDroneStore = DefClass("C_DeliveryDroneStore", C_DeliveryDroneStore, C_StoreGroup)
GroupName2Class.DeliveryDroneStore = C_DeliveryDroneStore
local M = C_DeliveryDroneStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	local state = gDeliveryTaskManager.TryGetDroneState() or 0
	self.bindData.state = state
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	local state = gDeliveryTaskManager.TryGetDroneState() or 0
	self.bindData.state = state
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
		[gEventConstants.UAV_LOGIC_STATE_CHANGE] = self:CreateAction(self.UAVLoginChange)
	}
end

function M:UAVLoginChange(_, state)
	self.bindData.state = state
end

function M:RegisterWidget()
	return
end
