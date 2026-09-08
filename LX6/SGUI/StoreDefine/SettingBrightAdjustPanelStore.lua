-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingBrightAdjustPanelStore.lua
-- Decompiled from: 00883_SettingBrightAdjustPanelStore.lua_2d8cf90799a5.luajit

local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local GameQualitySettings = LX6.Manager.GameQualitySettings
C_SettingBrightAdjustPanelStore = DefClass("C_SettingBrightAdjustPanelStore", C_SettingBrightAdjustPanelStore, C_StoreGroup)
GroupName2Class.SettingBrightAdjustPanelStore = C_SettingBrightAdjustPanelStore
local M = C_SettingBrightAdjustPanelStore
local STEP = 1
local e = math.exp(1)

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.step = 0
	self.totalTime = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.SetBrightness = function(self, value)
	self.ChangePicsColor(self, value)
	GameQualitySettings.SetDisplayGamma(value)
end

M.GetSavedBrightness = function(self)
	return gameProfile.screenBrightness
end

M.SaveBrightness = function(self, value)
	gameProfile.screenBrightness = value

	ProfileManager.SaveGameProperty()
end

M.ChangePicsColor = function(self, value)
	local visualGamma = 0.4 + 3.6 * value
	local darkLinear = 0.00026
	local darkBright = darkLinear^(1 / visualGamma)
	self.bindData.leftImg.color = Color.New(darkBright, darkBright, darkBright, 1)
	local lightBright = 0.25 + 0.25 * value
	self.bindData.rightImg.color = Color.New(lightBright, lightBright, lightBright, 1)
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
	local brightness = self.GetSavedBrightness(self)

	self.SetBrightness(self, brightness)

	self.bindData.slider.value = brightness * 100
end

M.OnClose = function(self)
	self.SetBrightness(self, self.GetSavedBrightness(self))
end

M.OnUpdate = function(self)
	self.RefreshStep(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, self.OnStepClick, -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, self.OnStepClick, 1)
	self.bindData.leftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, -1)
	self.bindData.leftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	self.bindData.rightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, 1)
	self.bindData.rightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.slider.luaValueChanged = self.CreateAction(self, self.OnSliderValueChanged)
end

M.OnStepClick = function(self, dir)
	self.bindData.slider.value = self.bindData.slider.value + dir * STEP
end

M.OnBeginLongPress = function(self, dir)
	self.step = dir
	self.totalTime = 0
	self.bindData.slider.value = self.bindData.slider.value + dir * STEP
end

M.OnEndLongPress = function(self)
	self.step = 0
	self.totalTime = 0
end

M.RefreshStep = function(self)
	if self.step ~= 0 then
		return
	end

	self.totalTime = self.totalTime + Time.deltaTime

	if self.totalTime >= 0.5 then
		return
	end

	self.bindData.slider.value = self.bindData.slider.value + self.step * STEP * e^(self.totalTime * 0.2)
end

M.OnSliderValueChanged = function(self, value)
	self.SetBrightness(self, value / 100)
end

M.OnClickConfirmBtn = function(self)
	self:SaveBrightness(self.bindData.slider.value / 100)
	gPanelManager:Close(self.m_Id)
end
