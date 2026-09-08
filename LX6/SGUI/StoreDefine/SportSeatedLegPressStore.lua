-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SportSeatedLegPressStore.lua
-- Decompiled from: 01295_SportSeatedLegPressStore.lua_aaa68c9911c8.luajit

local EInvokeTime = SGUI.EInvokeTime
C_SportSeatedLegPressStore = DefClass("C_SportSeatedLegPressStore", C_SportSeatedLegPressStore, C_StoreGroup)
GroupName2Class.SportSeatedLegPressStore = C_SportSeatedLegPressStore
local M = C_SportSeatedLegPressStore
local DEFAULT_RANGE_AREA = {
	["\\x83i~"] = 0.7,
	["\\x83ah"] = 0.5
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
		["\\x9c!2\ry\\x93F\\xdc\\xa5\\xaa"] = 0,
		["\\xf4\\x8e\\xfe!\\xf4\\xf9\\x9bً--"] = 0,
		["\\xa8\\xa4\\x98z;\\xfb7"] = 0,
		["~\\xa0\\xe5|\\xb9[%+i\\x82\\xf10\\xd7\\xf3"] = 0,
		["@R~Jj*="] = 0,
		speed = dataTable.speed or 0.25,
		attenuationRate = dataTable.attenuationRate or 0.1,
		rangePos = dataTable.rangePos or 0.6,
		rangeGreatArea = dataTable.rangeGreatArea or 0.1,
		rangeGoodArea = dataTable.rangeGoodArea or 0.2,
		attenuationArea = dataTable.attenuationArea or 0.05,
		greatAddMaxCount = dataTable.greatAddMaxCount or 5,
		curRangeGreatArea = {
			["\\x83i~"] = 0,
			["\\x83ah"] = 0
		},
		curRangeGoodArea = {
			["\\x83i~"] = 0,
			["\\x83ah"] = 0
		},
		optimalRange = DEFAULT_RANGE_AREA,
		CDTime = dataTable.CDTime or 1,
		inputHandle = dataTable.inputHandle
	}

	self:HitState(0)
end

M.OnUpdate = function(self)
	if self.tempData.curCDTime > 0 then
		self.tempData.curCDTime = self.tempData.curCDTime - gLogicTime.deltaTime
	end

	local progress = self.bindData.progressBar.value

	if self.tempData.startPressTime <= 0 then
		progress = progress + gLogicTime.deltaTime * self.tempData.curSpeed
	else
		progress = progress - self.tempData.curSpeed * gLogicTime.deltaTime
	end

	progress = Mathf.Clamp01(progress)
	self.bindData.progressBar.value = progress

	if self.tempData.inputHandle then
		self.tempData.inputHandle:DynamicInvoke(progress)
	end

	if progress > 1 then
		self.OnEndLongPress(self)
	end
end

M.HitState = function(self, state)
	local greatCount = self.tempData.curGreatAddMaxCount + state
	greatCount = Mathf.Clamp(greatCount, 0, self.tempData.greatAddMaxCount)
	self.tempData.curSpeed = self.tempData.speed * (1 - greatCount * self.tempData.attenuationRate)
	self.tempData.curGreatAddMaxCount = greatCount
	local greatRange = self.tempData.rangeGreatArea * (1 - greatCount * self.tempData.attenuationArea)
	self.tempData.curRangeGreatArea.min = self.tempData.rangePos - greatRange / 2
	self.tempData.curRangeGreatArea.max = self.tempData.rangePos + greatRange / 2
	local goodRange = self.tempData.rangeGoodArea * (1 - greatCount * self.tempData.attenuationArea)
	self.tempData.curRangeGoodArea.min = self.tempData.rangePos - goodRange / 2
	self.tempData.curRangeGoodArea.max = self.tempData.rangePos + goodRange / 2
	local greatRect = self.bindData.zoneGreat.rectTransform
	local greatArea = self.tempData.curRangeGreatArea
	greatRect.anchorMin = Vector2.New(greatRect.anchorMin.x, greatArea.min)
	greatRect.anchorMax = Vector2.New(greatRect.anchorMax.x, greatArea.max)
	greatRect.offsetMin = Vector2.New(greatRect.offsetMin.x, 0)
	greatRect.offsetMax = Vector2.New(greatRect.offsetMax.x, 0)
	local goodRect = self.bindData.zoneGood.rectTransform
	local goodArea = self.tempData.curRangeGoodArea
	goodRect.anchorMin = Vector2.New(goodRect.anchorMin.x, goodArea.min)
	goodRect.anchorMax = Vector2.New(goodRect.anchorMax.x, goodArea.max)
	goodRect.offsetMin = Vector2.New(goodRect.offsetMin.x, 0)
	goodRect.offsetMax = Vector2.New(goodRect.offsetMax.x, 0)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btnSpace.luaBeginLongPress = self.CreateAction(self, self.OnBeginLongPress)
	self.bindData.btnSpace.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnExit)
end

M.OnBeginLongPress = function(self)
	if self.tempData.curCDTime <= 0 then
		return
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	self.tempData.startPressTime = gLogicTime.time

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10743)
end

M.OnEndLongPress = function(self)
	if self.tempData.startPressTime ~= 0 then
		return
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local progress = self.bindData.progressBar.value
	local greatRange = self.tempData.curRangeGreatArea
	local goodRange = self.tempData.curRangeGoodArea

	if goodRange.max >= progress then
		print_debug("【Sport Seated Leg Press】SendGameplayInwardSignal", 10746)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10746)
		self.HitState(self, -1)
	elseif progress >= goodRange.min then
		print_debug("【Sport Seated Leg Press】SendGameplayInwardSignal", 10744)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10744)
		self.HitState(self, -1)
	else
		print_debug("【Sport Seated Leg Press】SendGameplayInwardSignal", 10745)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, 10745)
		self.HitState(self, 1)
	end

	if goodRange.min < progress and progress < goodRange.max and greatRange.min < progress and progress < greatRange.max then
		-- Nothing
	end

	self.tempData.startPressTime = 0
	self.tempData.curCDTime = self.tempData.CDTime
end

M.OnExit = function(self)
end
