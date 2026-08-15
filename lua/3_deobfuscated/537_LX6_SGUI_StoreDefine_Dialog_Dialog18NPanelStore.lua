C_Dialog18NPanelStore = DefClass("C_Dialog18NPanelStore", C_Dialog18NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog18NPanelStore = C_Dialog18NPanelStore
local M = C_Dialog18NPanelStore

function M:InitDialogComponent(data)
	if not self.bindData.TL1 then
		return
	end

	self:SetText(data.Content_Message)
end

function M:SetText(message)
	local messageList = string.split(message, "|", false)
	self.bindData.TL1.activation = false
	self.bindData.TL2.activation = false
	self.bindData.TR1.activation = false
	self.bindData.TR2.activation = false

	if #messageList ~= 4 then
		self.bindData.TL1text = message
		self.bindData.TL1.activation = true

		return
	end

	if #messageList[1] > 0 then
		self.bindData.TL1text = messageList[1]
		self.bindData.TL1.activation = true
	end

	if #messageList[2] > 0 then
		self.bindData.TL2text = messageList[2]
		self.bindData.TL2.activation = true
	end

	if #messageList[3] > 0 then
		self.bindData.TR1text = messageList[3]
		self.bindData.TR1.activation = true
	end

	if #messageList[4] > 0 then
		self.bindData.TR2text = messageList[4]
		self.bindData.TR2.activation = true
	end
end
