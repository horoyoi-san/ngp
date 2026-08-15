C_Dialog15NPanelStore = DefClass("C_Dialog15NPanelStore", C_Dialog15NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog15NPanelStore = C_Dialog15NPanelStore
local M = C_Dialog15NPanelStore
local base = C_Dialog15NPanelStore.base

function M:InitDialogComponent(data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogHint then
		self:InitHint(self.bindData.DialogHint, data.DialogHintNpc)
		table.insert(self.activatedComponent, self.DialogComponents.DialogHint)
	end
end

function M:InitContent(widget, content)
	base.InitContent(self, widget, content)
	base.InitFreeContent(self, widget)
end

function M:InitHint(widget, DialogHintNpc)
	if DialogHintNpc and DialogHintNpc.ModelSlot and DialogHintNpc.ModelSlot.headSlot then
		widget:SetActive(true)
	else
		widget:SetActive(false)

		return
	end

	local function updateHint()
		local posW = DialogHintNpc.ModelSlot.headSlot.position
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(posW, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local UIPos = gCS.LuaUtils.ScreenPointUI(widget.transform.parent, Vector2.New(x, y))

		widget.transform:SetLocalPositionXY(UIPos.x, UIPos.y)
	end

	table.insert(self.updateFunc, updateHint)
end
