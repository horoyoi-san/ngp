-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonBuyNumSliderStore.lua
-- Decompiled from: 01442_CommonBuyNumSliderStore.lua_ec8c523b10db.luajit

C_CommonBuyNumSliderStore = DefClass("C_CommonBuyNumSliderStore", C_CommonBuyNumSliderStore, C_StoreGroup)
GroupName2Class.CommonBuyNumSliderStore = C_CommonBuyNumSliderStore
local M = C_CommonBuyNumSliderStore

M.ctor = function(self, name, id, isSub)
	self.valChangeCallback = nil
	self.data = {}
	self.range = {
		0,
		0
	}
	self.moneyUse = 0
	self.e = math.exp(1)
end

M.OnAwake = function(self)
	self.totalTime = 0
	self.step = 0
	self.bindData.numSlider.luaValueChanged = self.CreateAction(self, "OnBuyNumChange")

	if self.bindData.minusBtn then
		self.bindData.minusBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", -1)
		self.bindData.minusBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	end

	if self.bindData.plusBtn then
		self.bindData.plusBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", 1)
		self.bindData.plusBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	end

	if self.bindData.maxBtn then
		self.bindData.maxBtn.luaClick = self.CreateAction(self, "OnClickToMax")
	end
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.SetData = function(self, param)
	if param.data ~= nil then
		return
	end

	self.valChangeCallback = param.valChangeCallback
	self.range = param.range
	self.data = param.data
	self.price = self.data.price or 0
	self.bindData.numSlider.stepSize = self.data.stepSize and self.data.stepSize or 1
	self.bindData.numSlider.minValue = self.range[1]
	self.bindData.numSlider.value = self.range[1]

	if not string.is_null_or_empty(self.data.formatText) then
		self.bindData.numSlider.formatText = self.data.formatText or "{0}"
	end

	if not table.isNilOrEmpty(self.data) then
		local moneyIcon, _ = gCommonItemManager:GetMoneyIconAndCount(self.data.moneyId)

		if moneyIcon == 0 then
			self.bindData.moneyIcon = moneyIcon
		end
	end

	self.bindData.numSlider.maxValue = self.range[2]
	local isSingle = self.range[2] > self.range[1]
	self.bindData.numSlider.interactable = not isSingle

	if param and param.value then
		self.OnBuyNumChange(self, param.value)
	else
		self.OnBuyNumChange(self, self.range[1])
	end
end

M.CheckMoneyEnough = function(self, moneyCount)
	if not self.data then
		return
	end

	if not moneyCount then
		_, moneyCount = gCommonItemManager:GetMoneyIconAndCount(self.data.moneyId)
	end

	self.bindData.moneyEnough = self.moneyUse < moneyCount and 0 or 1
end

M.ChangeValue = function(self, value)
	self.bindData.numSlider.value = value
end

M.OnUpdateMoneyLabel = function(self)
	self.bindData.moneyNumLabel = self.moneyUse
end

M.OnBuyNumChange = function(self, data)
	data = math.floor(data)

	if not table.isNilOrEmpty(self.data) then
		self.moneyUse = math.floor(data * self.price)

		self.OnUpdateMoneyLabel(self)
		self.CheckMoneyEnough(self)
	end

	if self.valChangeCallback then
		self.valChangeCallback(data)
	end

	local canMinus = self.bindData.numSlider.minValue <= data
	local canPlus = data <= self.bindData.numSlider.maxValue

	if self.bindData.minusBtn then
		self.bindData.minusBtn.interactable = canMinus
	end

	if self.bindData.plusBtn then
		self.bindData.plusBtn.interactable = canPlus
	end

	if not canMinus or not canPlus then
		self.OnEndLongPress(self)
	end
end

M.OnUpdate = function(self)
	self.RefreshStep(self)
end

M.OnBeginLongPress = function(self, step)
	self.step = step
	self.totalTime = 0
	self.bindData.numSlider.value = self.bindData.numSlider.value + self.step
end

M.OnEndLongPress = function(self)
	self.totalTime = 0
	self.step = 0
end

M.RefreshStep = function(self)
	if self.step == 0 then
		self.totalTime = self.totalTime + Time.deltaTime

		if self.totalTime >= 0.5 then
			return
		end

		local step = self.step * self.e^(self.totalTime * 0.2)
		self.bindData.numSlider.value = self.bindData.numSlider.value + step
	end
end

M.OnStepClick = function(self, step)
	self.bindData.numSlider.value = self.bindData.numSlider.value + step
end

M.OnClickToMax = function(self)
	self.bindData.numSlider.value = self.bindData.numSlider.maxValue
end
