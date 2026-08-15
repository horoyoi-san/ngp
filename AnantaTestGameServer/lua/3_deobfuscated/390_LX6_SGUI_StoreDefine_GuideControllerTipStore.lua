C_GuideControllerTipStore = DefClass("C_GuideControllerTipStore", C_GuideControllerTipStore, C_StoreGroup)
GroupName2Class.GuideControllerTipStore = C_GuideControllerTipStore
local M = C_GuideControllerTipStore

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
	return
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
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if not data then
		print_error("GuideControllerTipStore OnShow data is nil")

		return
	end

	local isXbox = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.Xbox
	self.bindData.deviceCtrl = isXbox and 0 or 1

	self:SetControllerTabIndex(data.controllerTabIndex or 0)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	local isXbox = device == SGUI.GameDevice.Xbox
	self.bindData.deviceCtrl = isXbox and 0 or 1
end

function M:GenMessageEvents()
	return
end

function M:SetControllerTabIndex(index)
	self.bindData.normalTabIndex = index
	self.bindData.dualSenseTabIndex = index
end

function M:RegisterWidget()
	return
end
