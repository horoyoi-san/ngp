-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonInfo\FullscreenReadingPanelStore.lua
-- Decompiled from: 01979_FullscreenReadingPanelStore.lua_be8d7a6287a6.luajit

C_FullscreenReadingPanelStore = DefClass("C_FullscreenReadingPanelStore", C_FullscreenReadingPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.FullscreenReadingPanelStore = C_FullscreenReadingPanelStore
local M = C_FullscreenReadingPanelStore

M.ctor = function(self)
	self.contentInit = false
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.scrollRect.luaInitContent = self.CreateAction(self, self.OnInitContent)
end

M.InitOnShow = function(self, data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	self.cfg = cfg
	self.bindData.title = cfg.Title
	self.bindData.subtitle = cfg.Subtitle

	if gClientUtils.NotNil(self.bindData.scrollRect.content) then
		self.OnInitContent(self, self.bindData.scrollRect.content)
	end
end

M.OnInitContent = function(self, content)
	if self.contentInit or self.cfg ~= nil then
		return
	end

	local cfg = self.cfg
	self.contentInit = true
	local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if cfg.Image and cfg.Image <= 0 then
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

M.ClearOnClose = function(self)
	self.contentInit = false
	self.cfg = nil
end
