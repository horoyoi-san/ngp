-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefRadar.lua
-- Decompiled from: 01423_ChefRadar.lua_1adf93f36085.luajit

local ChefConfig = LTConfig.ChefConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local Num2Layout = {
	{
		1
	},
	{
		1,
		4
	},
	{
		1,
		3,
		5
	},
	{
		2,
		3,
		5,
		6
	},
	{
		1,
		2,
		3,
		5,
		6
	},
	{
		1,
		2,
		3,
		4,
		5,
		6
	}
}
C_ChefRadar = DefClass("C_ChefRadar", C_ChefRadar, C_StoreGroup)
GroupName2Class.ChefRadar = C_ChefRadar
local M = C_ChefRadar

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.dim2Slot = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showNumCtrlEnum = {
		["\\x9ai"] = 1,
		["|+k^"] = 4,
		["Y\\xa6\\xb0\\xaa\\xb3"] = 2,
		["\\x81fc"] = 0,
		["|-hI"] = 3,
		["\\x9da~"] = 5
	}
	self.standardCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showNumCtrlEnum = nil
	self.standardCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
end

M._IsPrepare = function(self, recipeId)
	return ChefRecipeConfig.GetConfig(recipeId).PrepareType ~= ChefRecipeConfig.PrepareTypeType.Prepare
end

local ClampAndScale = function(d, value)
	value = value or 0
	local maxValue = ChefConfig.RecipeExpectedMaxValue[d]

	if not maxValue or maxValue < 0 then
		return value, value
	end

	if maxValue >= value then
		value = maxValue
	end

	return value / maxValue * 100, value
end

M._ParseLayout = function(self, recipeId)
	local initList = ChefRecipeConfig.GetConfig(recipeId).RecipeExpectedValue

	if not initList or not next(initList) then
		print_error("该菜谱没有六维！ recipeId = " .. recipeId)

		return nil, , 0
	end

	local validDims = {}
	local expected = {}

	for d = 1, 6 do
		if initList[d] and initList[d] > 0 then
			table.insert(validDims, d)

			expected[d] = initList[d]
		end
	end

	local numNum = #validDims
	local layout = Num2Layout[numNum]

	if not layout then
		print_error("该菜谱有效六维数量非法！ recipeId = " .. recipeId .. ", numNum = " .. numNum)

		return nil, , 0
	end

	local dim2Slot = {}

	for k = 1, numNum do
		dim2Slot[validDims[k]] = layout[k]
	end

	return dim2Slot, expected, numNum
end

M._ResetAllSlots = function(self)
	for s = 1, 6 do
		self.bindData.radar:SetVertexValue(s - 1, 0)
		self.bindData.standardRadar:SetVertexValue(s - 1, 0)
		self.bindData["lock" .. s].gameObject:SetActive(false)

		self.bindData["titleText" .. s].text = ""
		self.bindData["numText" .. s].text = ""
	end
end

M.GenerateHideMask = function(self, recipeId, unlockedIndices)
	local cfg = ChefRecipeConfig.GetConfig(recipeId)

	if cfg and cfg.ExceptValueUnlock then
		return 0
	end

	local mask = 63

	if unlockedIndices then
		for _, idx in ipairs(unlockedIndices) do
			mask = bit.band(mask, bit.bnot(bit.lshift(1, idx)))
		end
	end

	return mask
end

M.InitCompareMode = function(self, recipeId, hideMask)
	if self._IsPrepare(self, recipeId) then
		return
	end

	local dim2Slot, expected, numNum = self._ParseLayout(self, recipeId)

	if not dim2Slot then
		return
	end

	self.dim2Slot = dim2Slot
	self.bindData.showNumCtrl = numNum - 1
	self.bindData.standardCtrl = self.standardCtrlEnum._true

	self._ResetAllSlots(self)

	local names = ChefConfig.RecipeExpectedValueName

	for d = 1, 6 do
		local s = dim2Slot[d]

		if s then
			self.bindData["titleText" .. s].text = names[d]

			if bit.band(hideMask, bit.lshift(1, d - 1)) == 0 then
				self.bindData["lock" .. s].gameObject:SetActive(true)
			else
				local vertex = ClampAndScale(d, expected[d])

				self.bindData.standardRadar:SetVertexValue(s - 1, vertex)
			end

			self.bindData["numText" .. s].text = 0
		end
	end
end

M.InitRevealMode = function(self, recipeId, hideMask)
	if self._IsPrepare(self, recipeId) then
		return
	end

	local dim2Slot, expected, numNum = self._ParseLayout(self, recipeId)

	if not dim2Slot then
		return
	end

	self.dim2Slot = dim2Slot
	self.bindData.showNumCtrl = numNum - 1
	self.bindData.standardCtrl = self.standardCtrlEnum._false

	self._ResetAllSlots(self)

	local names = ChefConfig.RecipeExpectedValueName

	for d = 1, 6 do
		local s = dim2Slot[d]

		if s then
			self.bindData["titleText" .. s].text = names[d]

			if bit.band(hideMask, bit.lshift(1, d - 1)) == 0 then
				self.bindData["lock" .. s].gameObject:SetActive(true)

				self.bindData["numText" .. s].text = "?"
			else
				local vertex, shown = ClampAndScale(d, expected[d])

				self.bindData.radar:SetVertexValue(s - 1, vertex)

				self.bindData["numText" .. s].text = math.ceil(shown)
			end
		end
	end
end

M.SetRadarValue = function(self, v1, v2, v3, v4, v5, v6)
	if not self.dim2Slot then
		return
	end

	local values = {
		v1,
		v2,
		v3,
		v4,
		v5,
		v6
	}

	for d = 1, 6 do
		local s = self.dim2Slot[d]

		if s then
			local vertex, shown = ClampAndScale(d, values[d])

			self.bindData.radar:SetVertexValue(s - 1, vertex)

			self.bindData["numText" .. s].text = math.ceil(shown)
		end
	end
end
