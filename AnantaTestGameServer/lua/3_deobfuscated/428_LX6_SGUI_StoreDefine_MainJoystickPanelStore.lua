C_MainJoystickPanelStore = DefClass("C_MainJoystickPanelStore", C_MainJoystickPanelStore, C_StoreGroup)
GroupName2Class.MainJoystickPanelStore = C_MainJoystickPanelStore
local M = C_MainJoystickPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.throwMoveAnim = "s_vx_Joystick_red"
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
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
		[gEventConstants.ON_JOYSTICK_ANIM] = self:CreateAction("PlayThrowMoveAni")
	}
end

function M:RegisterWidget()
	return
end

function M:PlayThrowMoveAni(eventId, enable)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if enable then
		gBattleMgr:CommonPlayAniTool(self.bindData.clickAni, self.throwMoveAnim, 0, 1)
	else
		gBattleMgr:CommonStopAniTool(self.bindData.clickAni, self.throwMoveAnim)
	end
end
