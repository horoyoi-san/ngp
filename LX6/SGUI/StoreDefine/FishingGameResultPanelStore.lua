-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FishingGameResultPanelStore.lua
-- Decompiled from: 01860_FishingGameResultPanelStore.lua_5c58ecba73ba.luajit

C_FishingGameResultPanelStore = DefClass("C_FishingGameResultPanelStore", C_FishingGameResultPanelStore, C_StoreGroup)
GroupName2Class.FishingGameResultPanelStore = C_FishingGameResultPanelStore
local M = C_FishingGameResultPanelStore

M.OnAwake = function(self)
end

M.OnStart = function(self)
	if self.bindData.Button then
		self.bindData.Button.luaClick = self.CreateAction(self, self.OnContinue)
	end
end

M.OnShow = function(self, panelId, data)
	self.SetData(self, data)
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
	if self.btnCoroutine then
		coroutine.stop(self.btnCoroutine)

		self.btnCoroutine = nil
	end

	local mainStoreGroup = gStoreManager:GetStoreGroup("FishingGameMainPanelStore")

	if mainStoreGroup and mainStoreGroup.rootWidget then
		mainStoreGroup.rootWidget.gameObject:SetActive(true)
	end

	if mainStoreGroup and mainStoreGroup.system then
		mainStoreGroup.system:OnResultClosed()
	end
end

M.OnContinue = function(self)
	gPanelManager:Close(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL)
end

M.SetData = function(self, data)
	if data ~= nil then
		return
	end

	local fishData = data.data
	local fishConfig = data.config
	self.bindData.Name.text = FishingGameConfig.GetLanguageContent(fishConfig.name)
	self.bindData.Length.text = string.format(FishingGameConfig.GetLanguageContent(200305), fishData.length)
	local weight = fishData.weight or 0
	self.bindData.Weight.text = string.format(FishingGameConfig.GetLanguageContent(200306), weight)
end
