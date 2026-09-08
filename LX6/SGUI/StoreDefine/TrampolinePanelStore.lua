-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TrampolinePanelStore.lua
-- Decompiled from: 01168_TrampolinePanelStore.lua_278145134070.luajit

C_TrampolinePanelStore = DefClass("C_TrampolinePanelStore", C_TrampolinePanelStore, C_StoreGroup)
GroupName2Class.TrampolinePanelStore = C_TrampolinePanelStore
local M = C_TrampolinePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.resultEnum = {
		["\\xacib"] = 0,
		["T-s^"] = 3,
		["j\\xbc\\xa7\\xae\\xa2"] = 1,
		["\\xe9\\xde'\\xe5"] = 2
	}
	self.showButtonEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
	self.showProgressEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.resultEnum = nil
	self.showButtonEnum = nil
	self.showProgressEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.bindData.signalAction = self:CreateAction("OnReceiveSignal")

	gMessageManager:AddMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.bindData.signalAction)
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
	local dataTable = data:ToTable()
	self.tempData = {
		["o\\x89\\xb9\\xb1դ\\xf5)\\xac,\\x86;"] = false,
		["&,&\\xe1p\\x8c\\xc4 \\xa9=\\xf2\\xc6\\xefy\\xfe"] = 0,
		["\\x9c!2j\\x92F\\xcb2\\xb9\\xaa"] = 0,
		["\\xf3\\x95\\xed!\\xf4\\xf9\\x9bً--"] = 0,
		["\\x91;\\xec\\xaeG\t\\xd2O\\xc6\\xfb\"^S\\xc4\\xb5\\xc6"] = 0,
		["\\xe2\\x9c\\xe9\\xc2\\xf8\\x89\\xf9\\x8b/&"] = 0.8,
		["\\x96:6t\\x91s\\xd89\\xad\\xbc"] = false,
		["lw\\xa2G^\\xb7\\xe1T^ssI"] = false,
		data = dataTable,
		timeoutProgress = dataTable.timeoutProgress or 0,
		attenuationTime = dataTable.attenuationTime or 0,
		totalAttenuationTime = dataTable.attenuationTime or 0,
		duration = dataTable.time
	}
	self.bindData.progress.value = 0

	self:HideAnim()
end

M.OnUpdate = function(self)
	local checkPressUp = self.tempData.data.checkPressUp or false
	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local deltY = playerUnit.LocalPosition.y - self.tempData.data.groundPosY
	local inFillRange = deltY <= self.tempData.data.height

	if self.tempData.inFillRange == inFillRange then
		self.tempData.inFillRange = inFillRange

		print_debug("UIShowOrHide SendGameplayInwardSignal", inFillRange and 1820 or 1821, 0, deltY)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, inFillRange and 1820 or 1821, 0)
	end

	if checkPressUp then
		self.bindData.showButton = 1
	else
		self.bindData.showButton = inFillRange and 1 or 0
	end

	if self.tempData.data.showUI and self.tempData.effectDuration >= gLogicTime.time - self.tempData.effectStartTime then
		if inFillRange then
			self.bindData.showProgress = 1
		else
			self.HideAnim(self)

			self.bindData.showProgress = 0
			self.bindData.progress.value = 0
		end
	end

	if checkPressUp and inFillRange and not self.tempData.hasInitPressTime and self.tempData.canPressTime then
		self.tempData.totalPressTime = gLogicTime.time
		self.tempData.startAttenuationTime = gLogicTime.time
		self.tempData.hasInitPressTime = true
		self.tempData.pressTime = gLogicTime.time

		print_debug("OnPress SendGameplayInwardSignal", 1818, 0)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 1818, 0)
	end

	if not inFillRange or not self.tempData.pressTime then
		return
	end

	local progress = (gLogicTime.time - self.tempData.pressTime) / self.tempData.duration
	self.tempData.curProgress = Mathf.Clamp01(progress)
	self.bindData.progress.value = self.tempData.curProgress

	if progress >= 1 then
		return
	end

	progress = Mathf.Clamp01(progress)

	if checkPressUp and self.tempData.startAttenuationTime <= 0 and gLogicTime.time - self.tempData.startAttenuationTime >= self.tempData.totalAttenuationTime then
		return
	end

	self.SetAnim(self, progress, true)
	print_debug("PressFull SendGameplayInwardSignal", 1816, progress, self.tempData.duration, self.tempData.totalAttenuationTime)
	gCS.LuaUtils.SetPressPer(playerUnit, progress)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 1816, progress)
	self.ReleaseClearTempData(self)
end

M.SetAnim = function(self, progress, force)
	local result = 3

	if not force then
		if progress > 0.8 then
			result = 2
		else
			result = 1
		end
	else
		result = 0
	end

	self.bindData.progress.value = progress
	self.bindData.result = result

	if result ~= 1 then
		self.bindData.effectProgress.fillAmount = progress
	end

	self.tempData.effectStartTime = gLogicTime.time
end

M.HideAnim = function(self)
	self.bindData.result = 3
end

M.OnClose = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.bindData.signalAction)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btn.luaPress = self.CreateAction(self, "OnPress")
	self.bindData.btn.luaRelease = self.CreateAction(self, "OnRelease")
end

M.OnReceiveSignal = function(self, _, data)
	local signal = data.GetCfgId(data)

	if signal ~= 5305 then
		local checkPressUp = self.tempData.data.checkPressUp
		local progress = self.tempData.curProgress

		if checkPressUp and self.tempData.startAttenuationTime <= 0 and self.tempData.totalAttenuationTime < gLogicTime.time - self.tempData.startAttenuationTime then
			progress = self.tempData.timeoutProgress
		end

		self.SetAnim(self, progress)
		print_debug("OnReceiveSignal SendGameplayInwardSignal", 1816, progress, self.tempData.duration, self.tempData.totalAttenuationTime)
		gCS.LuaUtils.SetPressPer(gCS.MyPlayerManager.PlayerUnit, progress)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 1816, progress)
		self.ReleaseClearTempData(self)
	end
end

M.OnPress = function(self)
	if self.tempData.data.checkPressUp then
		local handle = self.tempData.data.timeAnimHandle

		if handle then
			local playerUnit = gCS.MyPlayerManager.PlayerUnit
			local ySpeed = playerUnit:GetYVelocity(true)
			ySpeed = Mathf.Abs(ySpeed)
			local value = handle:DynamicInvoke(ySpeed)
			self.tempData.duration = value or 1
		end

		self.tempData.totalAttenuationTime = self.tempData.data.attenuationTime + self.tempData.duration
		self.tempData.canPressTime = true
	else
		self.tempData.duration = self.tempData.data.time
		self.tempData.pressTime = gLogicTime.time

		print_debug("OnPress SendGameplayInwardSignal", 1818, 0)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 1818, 0)
	end
end

M.OnRelease = function(self)
	if not self.tempData.pressTime then
		return
	end

	local progress = self.tempData.curProgress

	self.SetAnim(self, progress)
	print_debug("OnRelease total pressTime SendGameplayInwardSignal", 1816, gLogicTime.time - self.tempData.totalPressTime)
	print_debug("OnRelease SendGameplayInwardSignal", 1816, progress)
	gCS.LuaUtils.SetPressPer(gCS.MyPlayerManager.PlayerUnit, progress)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 1816, progress)
	self.ReleaseClearTempData(self)
end

M.ReleaseClearTempData = function(self)
	self.tempData.startAttenuationTime = 0
	self.tempData.canPressTime = false
	self.tempData.pressTime = nil
	self.tempData.hasInitPressTime = false
	self.tempData.curProgress = 0
end
