C_FullscreenReadingPanelStore = DefClass("C_FullscreenReadingPanelStore", C_FullscreenReadingPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.FullscreenReadingPanelStore = C_FullscreenReadingPanelStore
local M = C_FullscreenReadingPanelStore

function M:ctor()
	self.contentInit = false
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.ClosePanel)
	self.bindData.scrollRect.luaInitContent = self:CreateAction(self.OnInitContent)
end

function M:InitOnShow(data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	self.cfg = cfg
	self.bindData.title = cfg.Title
	self.bindData.subtitle = cfg.Subtitle

	if gClientUtils.NotNil(self.bindData.scrollRect.content) then
		self:OnInitContent(self.bindData.scrollRect.content)
	end
end

function M:OnInitContent(content)
	if self.contentInit or self.cfg == nil then
		return
	end

	local cfg = self.cfg
	self.contentInit = true
	local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if cfg.Image and cfg.Image > 0 then
		contentStore.hasImageCtrl = 0
		contentStore.image = cfg.Image
	else
		contentStore.hasImageCtrl = 1
	end

	if not string.is_null_or_empty(cfg.Quote) then
		contentStore.hasQuoteCtrl = 0
		contentStore.quote = cfg.Quote
	else
		contentStore.hasQuoteCtrl = 1
	end

	contentStore.content = cfg.Content
end

function M:ClearOnClose()
	self.contentInit = false
	self.cfg = nil
end
