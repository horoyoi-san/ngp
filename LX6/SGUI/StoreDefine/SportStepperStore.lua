-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SportStepperStore.lua
-- Decompiled from: 01296_SportStepperStore.lua_72d3e9be164e.luajit

local EInvokeTime = SGUI.EInvokeTime
local ABPVarConfig = LTConfig.ABPVarConfig
C_SportStepperStore = DefClass("C_SportStepperStore", C_SportStepperStore, C_StoreGroup)
GroupName2Class.SportStepperStore = C_SportStepperStore
local M = C_SportStepperStore
local PROGRESS_AREA_MAP = {
	{
		["\\x83i~"] = 0.33,
		["\\x83ah"] = 0.01
	},
	{
		["\\x83i~"] = 0.66,
		["\\x83ah"] = 0.33
	},
	{
		["\\x83i~"] = 1,
		["\\x83ah"] = 0.66
	}
}

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
	local dataTable = data:ToTable()
	self.tempData = {
		["[[ݎ\\x90\t\\xaa\\xcc\\xec"] = false,
		["w\\xe95\\xcd=#*\\xcdt!\\xc1B\\x83q\\xd3\\xe4"] = 0,
		["}\\xabX\\x91\\xfeNiq{H"] = false,
		["\\x931&+[\\x91H\\xda<\\xaf\\xbd"] = false,
		["d\\x88\\xbf\\xaaȂ\\xc45\\xae:.\\xbd8"] = 0,
		["\\xe4\\x8f\\xc5#\\xe7\\xed\\x8dً--"] = 0,
		["\\x9c!2j\\x98R\\xca\\xae\\xbd"] = 0,
		[" ?2\\xcbf\\x8c\\xc55\\xa6(\\xe3\\xc6\\xefy\\xfe"] = 0,
		["BUihg "] = 2,
		attenuationSub = dataTable.attenuationSub or 0.05,
		pressAdd = dataTable.pressAdd or 0.1,
		outRangeTime = dataTable.outRangeTime or 2,
		outRangeCount = dataTable.outRangeCount or 3,
		inRangeTime = dataTable.inRangeTime or 2,
		gearAdd = dataTable.gearAdd or 0.1,
		gearSub = dataTable.gearSub or 0.1,
		currentProgressArea = PROGRESS_AREA_MAP[2]
	}

	self.bindData.btnLeft:InvokeCallback(EInvokeTime.User1)
	self.bindData.btnRight:InvokeCallback(EInvokeTime.User1)
	self:SwitchGear(0)
end

M.OnUpdate = function(self)
	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local progress = self.bindData.progressBar.value
	local addProgress = -self.tempData.curAttenuationSub * gLogicTime.deltaTime

	if self.tempData.leftClicked or self.tempData.rightClicked then
		local syncPress = self.tempData.leftClicked and self.tempData.rightClicked
		local pressMode = syncPress and 2 or 1

		print_debug("【Sport Stepper】SendGameplayInwardSignal", 10753, pressMode)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10753, pressMode)

		addProgress = addProgress + self.tempData.curPressAdd
	end

	progress = Mathf.Clamp01(progress + addProgress)
	self.bindData.progressBar.value = progress
	self.tempData.leftClicked = false
	self.tempData.rightClicked = false

	MuGenStates.Logic.ABPVarManager.SetFloat(playerUnit, ABPVarConfig.SpaceWalkerCurrentSpeed, progress * 3)

	local currentArea = self.tempData.currentProgressArea

	if progress <= currentArea.min or currentArea.max >= progress then
		self.tempData.curOutRangeTime = self.tempData.curOutRangeTime + gLogicTime.deltaTime

		if self.tempData.outRangeTime >= self.tempData.curOutRangeTime then
			self.tempData.curOutRangeCount = self.tempData.curOutRangeCount + 1
			self.tempData.curOutRangeTime = 0

			self.bindData.progressBar:InvokeCallback(EInvokeTime.User1)
			print_debug("【Sport Stepper】SendGameplayInwardSignal", 10754)
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10754)
		end

		self.tempData.curInRangeTime = 0
	else
		self.tempData.curInRangeTime = self.tempData.curInRangeTime + gLogicTime.deltaTime

		if self.tempData.inRangeTime >= self.tempData.curInRangeTime then
			self.bindData.progressBar:InvokeCallback(EInvokeTime.User3)

			self.tempData.curInRangeTime = 0
		end

		self.bindData.progressBar:InvokeCallback(EInvokeTime.User2)

		self.tempData.curOutRangeTime = 0
	end

	if self.tempData.outRangeCount >= self.tempData.curOutRangeCount then
		print_debug("【Sport Stepper】SendGameplayInwardSignal", 10755)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10755)

		self.tempData.curOutRangeCount = 0
	end
end

M.OnClose = function(self)
end

M.SwitchGear = function(self, addGear)
	local index = self.tempData.areaIndex
	index = Mathf.Clamp(index + addGear, 1, 3)
	self.tempData.curPressAdd = self.tempData.pressAdd + (index - 1) * self.tempData.gearAdd
	self.tempData.curAttenuationSub = self.tempData.attenuationSub + (index - 1) * self.tempData.gearSub
	local currentArea = PROGRESS_AREA_MAP[index]
	self.tempData.areaIndex = index
	self.tempData.currentProgressArea = currentArea
	self.bindData.txtSpeed.text = string.format("%d", index)
	local rect = self.bindData.zone.rectTransform
	rect.anchorMin = Vector2.New(rect.anchorMin.x, currentArea.min)
	rect.anchorMax = Vector2.New(rect.anchorMax.x, currentArea.max)
	rect.offsetMin = Vector2.New(rect.offsetMin.x, 0)
	rect.offsetMax = Vector2.New(rect.offsetMax.x, 0)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btnLeft.luaClick = self.CreateAction(self, self.OnClickBtnLeft)
	self.bindData.btnRight.luaClick = self.CreateAction(self, self.OnClickBtnRight)
	self.bindData.btnSpeedUp.luaClick = self.CreateAction(self, self.OnClickBtnSpeedUp)
	self.bindData.btnSpeedDown.luaClick = self.CreateAction(self, self.OnClickBtnSpeedDown)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnExit)
end

M.OnClickBtnLeft = function(self)
	self.tempData.leftClicked = true

	self.bindData.btnLeft:InvokeCallback(EInvokeTime.User1)
end

M.OnClickBtnRight = function(self)
	self.tempData.rightClicked = true

	self.bindData.btnRight:InvokeCallback(EInvokeTime.User1)
end

M.OnClickBtnSpeedUp = function(self)
	self.SwitchGear(self, 1)
end

M.OnClickBtnSpeedDown = function(self)
	self.SwitchGear(self, -1)
end

M.OnExit = function(self)
end
