-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NightRunPanelStore.lua
-- Decompiled from: 00930_NightRunPanelStore.lua_999714cb6a84.luajit

C_NightRunPanelStore = DefClass("C_NightRunPanelStore", C_NightRunPanelStore, C_StoreGroup)
GroupName2Class.NightRunPanelStore = C_NightRunPanelStore
local M = C_NightRunPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RefreshRunData = function(self, data)
	if not data then
		return
	end

	self.bindData.safeFillAmount = (data.safeMax - data.safeMin) * 0.5

	if self.bindData.safeTransform then
		self.bindData.safeTransform.localEulerAngles = Vector3.New(0, 0, -180 * data.safeMin)
	end

	if self.bindData.cursorTransform then
		self.bindData.cursorTransform.localEulerAngles = Vector3.New(0, 0, -180 * data.breath)
	end

	self.bindData.dangerFillAmount = data.danger

	self.SetSpeedBtnEnable(self, not data.levelLocked)
end

M.SetSpeedBtnEnable = function(self, enable)
	if self.speedBtnEnable ~= enable then
		return
	end

	self.speedBtnEnable = enable

	if self.bindData.speedUpBtn then
		self.bindData.speedUpBtn.interactable = enable
	end

	if self.bindData.speedDownBtn then
		self.bindData.speedDownBtn.interactable = enable
	end
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaLongPress = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.breathBtn.luaBeginLongPress = self.CreateAction(self, self.OnPressBreathBtn)
	self.bindData.breathBtn.luaEndLongPress = self.CreateAction(self, self.OnReleaseBreathBtn)
	self.bindData.speedUpBtn.luaClick = self.CreateAction(self, self.OnClickSpeedUpBtn)
	self.bindData.speedDownBtn.luaClick = self.CreateAction(self, self.OnClickSpeedDownBtn)
	self.bindData.greetBtn.luaClick = self.CreateAction(self, self.OnClickGreetBtn)
end

M.OnClickCloseBtn = function(self)
	gNightRunManager:StopPlay(false)
end

M.OnPressBreathBtn = function(self)
	gNightRunManager:SetBreathHolding(true)
end

M.OnReleaseBreathBtn = function(self)
	gNightRunManager:SetBreathHolding(false)
end

M.OnClickSpeedUpBtn = function(self)
	gNightRunManager:OnClickSpeedUp()
end

M.OnClickSpeedDownBtn = function(self)
	gNightRunManager:OnClickSpeedDown()
end

M.OnClickGreetBtn = function(self)
	gNightRunManager:OnClickGreet()
end
