C_GuideTemp04Store = DefClass("C_GuideTemp04Store", C_GuideTemp04Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp04Store = C_GuideTemp04Store
local M = C_GuideTemp04Store

function M:OnAwake()
	self:RegisterSingleEvent(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, self:CreateAction(self.OnActiveDeviceChanged))
	self:OnActiveDeviceChanged(nil, gCS.LuaUtils.GetActiveDevice())
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnActiveDeviceChanged(_, device)
	local DeviceType = SGUI.GameDevice

	if device == DeviceType.PlayStation then
		self.bindData.typeCtrl = 1
	elseif device == DeviceType.Xbox then
		self.bindData.typeCtrl = 2
	else
		self.bindData.typeCtrl = 0
	end
end
