-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameTipsViewPanelStore.lua
-- Decompiled from: 00849_PetGameTipsViewPanelStore.lua_b0d7d12703e6.luajit

C_PetGameTipsViewPanelStore = DefClass("C_PetGameTipsViewPanelStore", C_PetGameTipsViewPanelStore, C_StoreGroup)
GroupName2Class.PetGameTipsViewPanelStore = C_PetGameTipsViewPanelStore
local M = C_PetGameTipsViewPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.returnPanel = data.returnPanel

	if data.content then
		self.bindData.shopTipsText.text = data.content
	end

	self.BindSystemBtn(self)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.ShowTips = function(self, content)
	self.bindData.shopTipsText.text = content
end

M.BindSystemBtn = function(self)
	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnDismiss,
		OnConfirmBtnClick = self.OnDismiss,
		OnCancleBtnClick = self.OnDismiss,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	if self.parentPanel and self.panelId then
		self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
	end
end

M.OnDismiss = function(self)
	local returnPanel = self.returnPanel

	self.parentPanel:CloseChildPanel(self.panelId)

	if returnPanel then
		self.parentPanel:OpenChildPanel(returnPanel)
	end
end
