C_ComputerDeleteToolTips = DefClass("C_ComputerDeleteToolTips", C_ComputerDeleteToolTips, C_StoreGroup)
GroupName2Class.ComputerDeleteToolTips = C_ComputerDeleteToolTips
local M = C_ComputerDeleteToolTips

function M:OnAwake()
	self.bindData.button.luaClick = self:CreateAction("OnDeleteClick")
end

function M:OnDeleteClick()
	if self.onDeleteCallback then
		self.onDeleteCallback()
	end
end

function M:OnDestroy()
	self.onDeleteCallback = nil
end
