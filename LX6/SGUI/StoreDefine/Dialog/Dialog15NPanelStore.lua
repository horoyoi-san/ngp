-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog15NPanelStore.lua
-- Decompiled from: 01988_Dialog15NPanelStore.lua_9656d0c8e7d9.luajit

C_Dialog15NPanelStore = DefClass("C_Dialog15NPanelStore", C_Dialog15NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog15NPanelStore = C_Dialog15NPanelStore
local M = C_Dialog15NPanelStore
local base = C_Dialog15NPanelStore.base

M.InitDialogComponent = function(self, data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogHint then
		self.InitHint(self, self.bindData.DialogHint, data.DialogHintNpc)
		table.insert(self.activatedComponent, self.DialogComponents.DialogHint)
	end
end

M.InitContent = function(self, widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)
end

M.InitHint = function(self, widget, DialogHintNpc)
	if DialogHintNpc and DialogHintNpc.ModelSlot and DialogHintNpc.ModelSlot.headSlot then
		widget.SetActive(widget, true)
	else
		widget.SetActive(widget, false)

		return
	end

	local updateHint = function()
		local posW = DialogHintNpc.ModelSlot.headSlot.position
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(posW, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local UIPos = gCS.LuaUtils.ScreenPointUI(widget.transform.parent, Vector2.New(x, y))

		widget.transform:SetLocalPositionXY(UIPos.x, UIPos.y)
	end

	table.insert(self.updateFunc, updateHint)
end
