C_CommonCounterStore = DefClass("C_CommonCounterStore", C_CommonCounterStore, C_StoreGroup)
GroupName2Class.CommonCounterStore = C_CommonCounterStore
local M = C_CommonCounterStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local E = math.exp(1)

function M:ctor(name, id, isSub)
	self.valChangeCallback = nil
	self.range = {
		0,
		0
	}
	self.val = 0
end

function M:OnAwake()
	self.totalTime = 0
	self.step = 0
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnBuyNumChange")
	self.bindData.inputField.luaEndEdit = self:CreateAction("OnEndEdit")
	self.bindData.minusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnMinusBeginLongPress")
	self.bindData.minusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.plusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnPlusBeginLongPress")
	self.bindData.plusBtn.luaEndLongPress = self:CreateAction("OnEndLongPress")
	self.bindData.maxBtn.luaClick = self:CreateAction("OnClickToMax")
end

function M:SetData(param)
	self.valChangeCallback = param.valChangeCallback

	if not param.range or #param.range ~= 2 then
		self.range = {
			0,
			0
		}
	else
		self.range = param.range
	end

	self.stepInterval = param.stepInterval or 1
	self.bindData.inputField.digitalMin = self.range[1]
	self.bindData.inputField.digitalMax = self.range[2]
	self.bindData.inputField.text = self.range[1]
	local isSingle = self.range[2] <= self.range[1]
	self.bindData.inputField.interactable = not isSingle
	self.bindData.available = BOOL2CTL[not isSingle]
	local targetValue = param.targetValue

	if targetValue then
		self:ChangeValue(targetValue)
	else
		self:OnBuyNumChange(targetValue)
	end
end

function M:CheckValue(value, notUseStep)
	if value == nil then
		return 0
	end

	local interval = self.stepInterval or 1

	if not notUseStep then
		value = math.floor(value / interval) * interval
	end

	value = math.max(self.range[1], math.min(value, self.range[2]))

	return value
end

function M:ChangeValue(value)
	value = self:CheckValue(value)
	self.bindData.inputField.text = value

	return value
end

function M:OnBuyNumChange(data)
	local val = tonumber(data)
	self.val = self:CheckValue(val, true)

	if val == nil or val ~= self.val then
		self.bindData.inputField.text = self.val

		return
	end

	if self.valChangeCallback then
		self.valChangeCallback(self.val, self.data)
	end

	self.bindData.plusBtn.interactable = self.val < self.range[2]
	self.bindData.minusBtn.interactable = self.range[1] < self.val
end

function M:OnEndEdit()
	self:ChangeValue(self.val)
end

function M:OnUpdate()
	self:RefreshStep()
end

function M:OnBeginLongPress(step)
	self.step = step
	self.totalTime = 0
	self.val = self.val + step

	self:ChangeValue(self.val)
end

function M:OnEndLongPress()
	self.totalTime = 0
	self.step = 0
end

function M:RefreshStep()
	if self.step ~= 0 then
		if self.step < 0 and self.val <= self.range[1] or self.step > 0 and self.range[2] <= self.val then
			self:OnEndLongPress()

			return
		end

		self.totalTime = self.totalTime + Time.deltaTime

		if self.totalTime < 0.5 then
			return
		end

		local step = self.step * E^(self.totalTime * 0.2)
		self.val = self.val + step

		self:ChangeValue(self.val)
	end
end

function M:OnStepClick(step)
	self.val = self.val + step

	self:ChangeValue(self.val)
end

function M:OnMinusClick()
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnStepClick(step)
end

function M:OnPlusClick()
	local step = self.stepInterval or 1

	self:OnStepClick(step)
end

function M:OnMinusBeginLongPress()
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnBeginLongPress(step)
end

function M:OnPlusBeginLongPress()
	local step = self.stepInterval or 1

	self:OnBeginLongPress(step)
end

function M:OnClickToMax()
	self.val = self.range[2]

	self:ChangeValue(self.val)
end

function M:GetCurrentVal()
	return self.val
end
