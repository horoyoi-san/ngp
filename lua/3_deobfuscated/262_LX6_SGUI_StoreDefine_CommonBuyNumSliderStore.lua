C_CommonBuyNumSliderStore = DefClass("C_CommonBuyNumSliderStore", C_CommonBuyNumSliderStore, C_StoreGroup)
GroupName2Class.CommonBuyNumSliderStore = C_CommonBuyNumSliderStore
local M = C_CommonBuyNumSliderStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor(name, id, isSub)
	self.valChangeCallback = nil
	self.data = {}
	self.range = {
		0,
		0
	}
	self.moneyUse = 0
	self.e = math.exp(1)
end

function M:OnAwake()
	self.totalTime = 0
	self.step = 0
	self.bindData.numSlider.luaValueChanged = self:CreateAction("OnBuyNumChange")
	self.bindData.minusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", -1)
	self.bindData.minusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.plusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnBeginLongPress", 1)
	self.bindData.plusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.maxBtn.luaClick = self:CreateAction("OnClickToMax")
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:SetData(param)
	self.valChangeCallback = param.valChangeCallback
	self.range = param.range
	self.data = param.data
	self.bindData.numSlider.minValue = self.range[1]
	self.bindData.numSlider.value = self.range[1]

	if not table.isNilOrEmpty(self.data) then
		local moneyIcon, _ = gCommonItemManager:GetMoneyIconAndCount(self.data.moneyId)

		if moneyIcon ~= 0 then
			self.bindData.moneyIcon = moneyIcon
		end
	end

	self.bindData.numSlider.maxValue = self.range[2]
	local isSingle = self.range[2] <= self.range[1]
	self.bindData.numSlider.interactable = not isSingle
	self.bindData.available = BOOL2CTL[not isSingle]

	if param and param.value then
		self:OnBuyNumChange(param.value)
	else
		self:OnBuyNumChange(self.range[1])
	end
end

function M:CheckMoneyEnough(moneyCount)
	if not self.data then
		return
	end

	if not moneyCount then
		_, moneyCount = gCommonItemManager:GetMoneyIconAndCount(self.data.moneyId)
	end

	self.bindData.moneyEnough = self.moneyUse <= moneyCount and 0 or 1
end

function M:ChangeValue(value)
	self.bindData.numSlider.value = value
end

function M:OnBuyNumChange(data)
	if not table.isNilOrEmpty(self.data) then
		self.moneyUse = data * self.data.price
		self.bindData.moneyNumLabel = self.moneyUse

		self:CheckMoneyEnough()
	end

	if self.valChangeCallback then
		self.valChangeCallback(data)
	end

	self.bindData.minusBtn.interactable = self.bindData.numSlider.minValue < data
	self.bindData.plusBtn.interactable = data < self.bindData.numSlider.maxValue

	if not self.bindData.minusBtn.interactable or not self.bindData.plusBtn.interactable then
		self:OnEndLongPress()
	end
end

function M:OnUpdate()
	self:RefreshStep()
end

function M:OnBeginLongPress(step)
	self.step = step
	self.totalTime = 0
	self.bindData.numSlider.value = self.bindData.numSlider.value + self.step
end

function M:OnEndLongPress()
	self.totalTime = 0
	self.step = 0
end

function M:RefreshStep()
	if self.step ~= 0 then
		self.totalTime = self.totalTime + Time.deltaTime

		if self.totalTime < 0.5 then
			return
		end

		local step = self.step * self.e^(self.totalTime * 0.2)
		self.bindData.numSlider.value = self.bindData.numSlider.value + step
	end
end

function M:OnStepClick(step)
	self.bindData.numSlider.value = self.bindData.numSlider.value + step
end

function M:OnClickToMax()
	self.bindData.numSlider.value = self.bindData.numSlider.maxValue
end
