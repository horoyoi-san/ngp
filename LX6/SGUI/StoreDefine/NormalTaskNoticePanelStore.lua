-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NormalTaskNoticePanelStore.lua
-- Decompiled from: 02049_NormalTaskNoticePanelStore.lua_63e4eaffb93f.luajit

C_NormalTaskNoticePanelStore = DefClass("C_NormalTaskNoticePanelStore", C_NormalTaskNoticePanelStore, C_CoreHudTaskGuideStore)
GroupName2Class.NormalTaskNoticePanelStore = C_NormalTaskNoticePanelStore
local M = C_NormalTaskNoticePanelStore

M.OnShow = function(self, panelId, data)
	local mainStore = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")

	if not mainStore then
		return
	end

	self.curTaskId = mainStore.curTaskId or 0
	self.curTaskInfo = mainStore.curTaskInfo

	if self.curTaskInfo and mainStore.curType and mainStore.curType > 0 then
		self.OpenTaskPanel(self, mainStore.curType, mainStore.curTypeData)
	end
end
