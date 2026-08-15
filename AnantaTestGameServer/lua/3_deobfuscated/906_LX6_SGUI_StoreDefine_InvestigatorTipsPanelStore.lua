local LegendaryInvestigatorConfig = LTConfig.LegendaryInvestigatorConfig
local LegendaryInvestigatorGalleryConfig = LTConfig.LegendaryInvestigatorGalleryConfig
C_InvestigatorTipsPanelStore = DefClass("C_InvestigatorTipsPanelStore", C_InvestigatorTipsPanelStore, C_StoreGroup)
GroupName2Class.InvestigatorTipsPanelStore = C_InvestigatorTipsPanelStore
local M = C_InvestigatorTipsPanelStore

function M:ctor()
	self.areaIndex = 0
	self.id = 0
	self.timer = nil
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	if not data or not data.id then
		print_error("S_INVESTIGATOR_TIPS_PANEL 错误的调用 缺少参数 id")
		self:OnBackBtnClick()

		return
	end

	self.areaIndex = data.areaIndex
	self.id = data.id
	local cfg = LegendaryInvestigatorGalleryConfig.GetConfig(data.id)

	if not cfg then
		print_error("【配置错误】LegendaryInvestigatorGallery表不存在id", data.id)
		self:OnBackBtnClick()

		return
	end

	self.bindData.iconId = cfg.IconId or 0
	self.bindData.nameLabel = cfg.DisasterName or ""
	self.timer = Timer.New(function ()
		gPanelManager:Close(panelId)
	end, LegendaryInvestigatorConfig.TipsShowTime):Start()
end

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_INVESTIGATOR_TIPS_PANEL)
end
