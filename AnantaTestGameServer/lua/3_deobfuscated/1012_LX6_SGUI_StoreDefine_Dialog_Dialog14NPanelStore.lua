C_Dialog14NPanelStore = DefClass("C_Dialog14NPanelStore", C_Dialog14NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog14NPanelStore = C_Dialog14NPanelStore
local M = C_Dialog14NPanelStore
local base = C_Dialog14NPanelStore.base

function M:InitDialogComponent(data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogPicture then
		self:InitPicture(self.bindData.DialogPicture, data.Pictures)
		table.insert(self.activatedComponent, self.DialogComponents.DialogPicture)
	end
end

function M:InitContent(widget, data)
	base.InitContent(self, widget, data)
	base.InitTitleAndShowNext(self, widget, data)
end
