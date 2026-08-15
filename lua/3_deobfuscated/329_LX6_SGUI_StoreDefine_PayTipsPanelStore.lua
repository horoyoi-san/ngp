C_PayTipsPanelStore = DefClass("C_PayTipsPanelStore", C_PayTipsPanelStore, C_StoreGroup)
GroupName2Class.PayTipsPanelStore = C_PayTipsPanelStore
local M = C_PayTipsPanelStore

function M:ctor()
	self.payTipsDelay = nil
end

function M:OnShow(panelId, data)
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

function M:OnClose()
	return
end
