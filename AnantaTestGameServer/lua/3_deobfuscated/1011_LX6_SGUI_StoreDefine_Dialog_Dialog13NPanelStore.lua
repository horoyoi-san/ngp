C_Dialog13NPanelStore = DefClass("C_Dialog13NPanelStore", C_Dialog13NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog13NPanelStore = C_Dialog13NPanelStore
local M = C_Dialog13NPanelStore

function M:InitDialogComponent(data)
	self.contentText = self:ConcatLeftNameAndMessage(data)
	local finalStr = self.contentText

	if gDialogManager.attachContentText then
		if finalStr then
			finalStr = gDialogManager.attachContentText .. finalStr
		else
			finalStr = gDialogManager.attachContentText
		end
	end

	self.bindData.ContentText.text = finalStr

	if string.contains(finalStr, "\n") then
		self.bindData.ContentText.alignment = 1026
		self.bindData.ContentText = finalStr
	else
		self:AdjustAlignmentByLines(self.bindData.ContentText, finalStr)
	end
end

function M:OnAttachContentChanged()
	local finalStr = self.contentText

	if gDialogManager.attachContentText then
		if finalStr then
			finalStr = gDialogManager.attachContentText .. finalStr
		else
			finalStr = gDialogManager.attachContentText
		end
	end

	self.bindData.ContentText.text = finalStr

	self:AdjustAlignmentByLines(self.bindData.ContentText, self.bindData.ContentText.text)
end
