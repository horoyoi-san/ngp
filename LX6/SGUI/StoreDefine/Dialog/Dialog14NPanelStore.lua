-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog14NPanelStore.lua
-- Decompiled from: 01986_Dialog14NPanelStore.lua_4805bae813c8.luajit

C_Dialog14NPanelStore = DefClass("C_Dialog14NPanelStore", C_Dialog14NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog14NPanelStore = C_Dialog14NPanelStore
local M = C_Dialog14NPanelStore
local base = C_Dialog14NPanelStore.base

M.InitDialogComponent = function(self, data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogPicture then
		self.InitPicture(self, self.bindData.DialogPicture, data.Pictures)
		table.insert(self.activatedComponent, self.DialogComponents.DialogPicture)
	end
end

M.InitContent = function(self, widget, data)
	base.InitContent(self, widget, data)
	base.InitTitleAndShowNext(self, widget, data)
end
