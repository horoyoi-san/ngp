-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BasketBallOnlineCountdownStore.lua
-- Decompiled from: 01658_BasketBallOnlineCountdownStore.lua_8c9dd02b31c7.luajit

C_BasketBallOnlineCountdownStore = DefClass("C_BasketBallOnlineCountdownStore", C_BasketBallOnlineCountdownStore, C_StoreGroup)
GroupName2Class.BasketBallOnlineCountdownStore = C_BasketBallOnlineCountdownStore
local M = C_BasketBallOnlineCountdownStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.countDownCo = nil
	self.countDownSecond = 0
	self.countDownLeftSecond = 0
	self.countDownTotalSecond = 0
	self.countDownActive = false
	self.originLocalScale = nil
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

M.OnUpdate = function(self)
	if not self.countDownActive then
		return
	end

	self.countDownLeftSecond = math.max(self.countDownLeftSecond - gLogicTime.deltaTime, 0)
	local countDownSecond = math.ceil(self.countDownLeftSecond)

	if self.countDownSecond == countDownSecond then
		self.countDownSecond = countDownSecond

		self.RefreshCountDown(self)
	else
		self.RefreshFillAmount(self)
	end

	if self.countDownLeftSecond < 0 then
		self.countDownActive = false
	end
end

M.OnDestroy = function(self)
	self.StopCountDown(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	data = self:NormalizeShowData(data)

	self:ApplyWorldTransform(data)
	self:StartCountDown(data.countDown or data.countDownSecondNum or data.time or data[1], data.countDownTotalSecond)
end

M.OnClose = function(self)
	self.StopCountDown(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.NormalizeShowData = function(self, data)
	if type(data) ~= "userdata" then
		data = data.ToTable(data)
	end

	if type(data) ~= "table" then
		return data
	end

	return {
		countDown = data
	}
end

M.ApplyWorldTransform = function(self, data)
	local uiPivot = data.uiPivot or data[2]

	if not uiPivot then
		return
	end

	local transform = self.rootGo.transform

	transform:ChangeLayersRecursively(Layer.Default)

	transform.position = uiPivot.position
	transform.rotation = uiPivot.rotation
	self.originLocalScale = self.originLocalScale or transform.localScale
	transform.localScale = Vector3.New(self.originLocalScale.x * uiPivot.localScale.x, self.originLocalScale.y * uiPivot.localScale.y, self.originLocalScale.z * uiPivot.localScale.z)
end

M.StartCountDown = function(self, countDown, countDownTotalSecond)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownLeftSecond = math.max(tonumber(countDown) or 0, 0)
	self.countDownSecond = math.ceil(self.countDownLeftSecond)
	self.countDownTotalSecond = math.max(tonumber(countDownTotalSecond) or self.countDownLeftSecond, 0)
	self.countDownActive = self.countDownSecond >= 0

	self:RefreshCountDown()
end

M.StopCountDown = function(self)
	self.countDownCo = coroutine.stop(self.countDownCo)
	self.countDownActive = false
end

M.RefreshCountDown = function(self)
	self.bindData.countDown = tostring(self.countDownSecond)

	self.RefreshFillAmount(self)
end

M.RefreshFillAmount = function(self)
	local fillAmount = self.countDownTotalSecond <= 0 and self.countDownLeftSecond / self.countDownTotalSecond or 0
	self.bindData.fillAmount = math.min(math.max(fillAmount, 0), 1)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
