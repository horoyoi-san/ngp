-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FloatingGuideTextTopStore.lua
-- Decompiled from: 01864_FloatingGuideTextTopStore.lua_22a2034b52db.luajit

C_FloatingGuideTextTopStore = DefClass("C_FloatingGuideTextTopStore", C_FloatingGuideTextTopStore, C_StoreGroup)
GroupName2Class.FloatingGuideTextTopStore = C_FloatingGuideTextTopStore
local M = C_FloatingGuideTextTopStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.areaIndex = data.areaIndex
	self.guideTextData = data.Param.guideTextData
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.bindData.guideTextBase)

	self:RefreshGuideTextList()
end

M.OnClose = function(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshGuideTextList(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshGuideTextList(self)
end

M.RefreshGuideTextList = function(self)
	self.guideTextStore.textComp.forceSyncLoad = true
	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(self.guideTextData)
end
