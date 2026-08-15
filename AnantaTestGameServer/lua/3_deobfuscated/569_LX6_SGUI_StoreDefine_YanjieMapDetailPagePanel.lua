C_YanjieMapDetailPagePanel = DefClass("C_YanjieMapDetailPagePanel", C_YanjieMapDetailPagePanel, C_YanjieNewDetailPagePanel)
GroupName2Class.YanjieMapDetailPagePanel = C_YanjieMapDetailPagePanel
local M = C_YanjieMapDetailPagePanel

function M:OnShow(_, args)
	M.base.ShowPanel(self, args)
end

function M:OnExecuteExitAction()
	gPanelManager:Close(self.m_Id)
end
