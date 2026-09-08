-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SportAppDatePanelStore.lua
-- Decompiled from: 01293_SportAppDatePanelStore.lua_5ead0dc5e29d.luajit

C_SportAppDatePanelStore = DefClass("C_SportAppDatePanelStore", C_SportAppDatePanelStore, C_StoreGroup)
GroupName2Class.SportAppDatePanelStore = C_SportAppDatePanelStore
local M = C_SportAppDatePanelStore
local FunplayConfig = LTConfig.FunplayHudConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.closeCb = nil
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
	self:InitDefaultText()
	self:InitDataText(data)

	self.closeCb = data and data.callback or nil
end

M.OnClose = function(self)
	if self.closeCb then
		self.closeCb()
	end

	self.closeCb = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.InitDefaultText = function(self)
	self.bindData.appTitleText = FunplayConfig.AppTitleText
	self.bindData.generalTitleText = FunplayConfig.GeneralTitleText
	self.bindData.generalTypeText = FunplayConfig.GeneralTypeText
	self.bindData.firstTitleText = FunplayConfig.FirstTitleText
	self.bindData.secondTitleText = FunplayConfig.SecondTitleText
	self.bindData.thirdTitleText = FunplayConfig.ThirdTitleText
	self.bindData.fourthTitleText = FunplayConfig.FourthTitleText
	self.bindData.firstTypeText = FunplayConfig.BadgeTypeText
	self.bindData.secondLeftTypeText = FunplayConfig.BadgeTypeText
	self.bindData.secondRightTypeText = FunplayConfig.BadgeTypeText
	self.bindData.fourthTypeText = FunplayConfig.BeatTypeText
end

M.InitDataText = function(self, data)
	self.bindData.generalNumText = data and data.generalNum or 0
	self.bindData.firstNumText = data and data.firstNum or 0
	self.bindData.secondLeftNumText = data and data.secondLeftNum or 0
	self.bindData.secondRightNumText = data and data.secondRightNum or 0
	self.bindData.thirdNumText = data and data.thirdNum or 0
	self.bindData.thirdTypeText = data and data.thirdType or 0
	self.bindData.fourthNumText = data and data.fourthNum or 0
end
