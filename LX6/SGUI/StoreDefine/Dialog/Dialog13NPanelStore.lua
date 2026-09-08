-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog13NPanelStore.lua
-- Decompiled from: 01985_Dialog13NPanelStore.lua_15198694aa76.luajit

C_Dialog13NPanelStore = DefClass("C_Dialog13NPanelStore", C_Dialog13NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog13NPanelStore = C_Dialog13NPanelStore
local M = C_Dialog13NPanelStore

M.InitDialogComponent = function(self, data)
	self.contentText = self.ConcatLeftNameAndMessage(self, data)

	self.SetMainContent(self)
end

M.OnAttachContentChanged = function(self)
	local finalStr = self.contentText

	if gDialogManager.attachContentText then
		if finalStr then
			finalStr = gDialogManager.attachContentText .. finalStr
		else
			finalStr = gDialogManager.attachContentText
		end
	end

	self.bindData.ContentText.text = finalStr

	self.AdjustAlignmentByLines(self, self.bindData.ContentText, self.bindData.ContentText.text)
end
