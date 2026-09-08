-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PayTipsPanelStore.lua
-- Decompiled from: 01084_PayTipsPanelStore.lua_8bbac21c1a32.luajit

C_PayTipsPanelStore = DefClass("C_PayTipsPanelStore", C_PayTipsPanelStore, C_StoreGroup)
GroupName2Class.PayTipsPanelStore = C_PayTipsPanelStore
local M = C_PayTipsPanelStore

M.ctor = function(self)
	self.payTipsDelay = nil
end

M.OnShow = function(self, panelId, data)
	local params = data.Param
	self.areaIndex = data.areaIndex

	if self.payTipsDelay then
		self.payTipsDelay:Stop()

		self.payTipsDelay = nil
	end

	self.bindData.companyLogo = params.logoId
	self.bindData.value = params.value
	local nameCfg = LTConfig.TextCommonTextConfig.GetConfig(params.textId)
	self.bindData.companyName = nameCfg and nameCfg.Text or "#获取数据失败 id=" .. params.textId
	self.bindData.MoneyEnoughCtrl = params.moneyEnough and 0 or 1
	self.payTipsDelay = Timer.New(function ()
		gPanelManager:Close(gPanelId.S_PAY_TIPS_PANEL)
	end, 3):Start()
end

M.OnClose = function(self)
end
