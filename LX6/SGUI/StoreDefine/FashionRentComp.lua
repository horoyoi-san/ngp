-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FashionRentComp.lua
-- Decompiled from: 01848_FashionRentComp.lua_cd751e509600.luajit

C_FashionRentComp = DefClass("C_FashionRentComp", C_FashionRentComp, C_StoreGroup)
GroupName2Class.FashionRentComp = C_FashionRentComp
local M = C_FashionRentComp

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isRentMode = false
	self.rentSuitId = nil
	self.rentClickCb = nil
	self.nextClickCb = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.moneyLackCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showNextCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.showFinishCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.showMoneyCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.moneyLackCtrlEnum = nil
	self.showNextCtrlEnum = nil
	self.showFinishCtrlEnum = nil
	self.showMoneyCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.rentClickCb = nil
	self.nextClickCb = nil
end

M.RegisterWidget = function(self)
	self.bindData.rentBtn.luaClick = self.CreateAction(self, self.OnClickRentBtn)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, self.OnClickNextBtn)
end

M.OnClickRentBtn = function(self)
	if self.rentClickCb then
		self.rentClickCb(self.rentSuitId)
	end
end

M.OnClickNextBtn = function(self)
	if self.nextClickCb then
		self.nextClickCb()
	end
end

M.Init = function(self, data)
	if data then
		self.rentClickCb = data.rentClickCb
		self.nextClickCb = data.nextClickCb
	end
end

M.EnterRentMode = function(self, suitId, price, isLack, isLastCharacter)
	self.isRentMode = true
	self.rentSuitId = suitId
	self.bindData.priceText = tostring(price)
	self.bindData.showMoneyCtrl = self.showMoneyCtrlEnum.show
	self.bindData.moneyLackCtrl = isLack and self.moneyLackCtrlEnum._true or self.moneyLackCtrlEnum._false

	if isLastCharacter ~= nil or isLastCharacter then
		self.bindData.showFinishCtrl = self.showFinishCtrlEnum.show
		self.bindData.showNextCtrl = self.showNextCtrlEnum.hide
	else
		self.bindData.showFinishCtrl = self.showFinishCtrlEnum.hide
		self.bindData.showNextCtrl = self.showNextCtrlEnum.show
	end
end

M.ExitRentMode = function(self)
	self.isRentMode = false
	self.rentSuitId = nil
	self.bindData.showFinishCtrl = self.showFinishCtrlEnum.hide
	self.bindData.showNextCtrl = self.showNextCtrlEnum.hide
	self.bindData.showMoneyCtrl = self.showMoneyCtrlEnum.hide
end
