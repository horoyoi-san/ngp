-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\JoyStickStore.lua
-- Decompiled from: 01770_JoyStickStore.lua_f94617962462.luajit

C_JoyStickStore = DefClass("C_JoyStickStore", C_JoyStickStore, C_StoreGroup)
GroupName2Class.JoyStickStore = C_JoyStickStore
local M = C_JoyStickStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.throwMoveAnim = "s_vx_Joystick_red"
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

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_JOYSTICK_ANIM] = self.CreateAction(self, "PlayThrowMoveAni")
	}
end

M.RegisterWidget = function(self)
end

M.PlayThrowMoveAni = function(self, eventId, enable)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if enable then
		gBattleMgr:CommonPlayAniTool(self.bindData.clickAni, self.throwMoveAnim, 0, 1)
	else
		gBattleMgr:CommonStopAniTool(self.bindData.clickAni, self.throwMoveAnim)
	end
end
