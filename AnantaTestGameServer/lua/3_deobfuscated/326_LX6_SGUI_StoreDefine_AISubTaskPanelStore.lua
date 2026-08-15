local MassNPCConversationConfig = LTConfig.MassNPCConversationConfig
C_AISubTaskPanelStore = DefClass("C_AISubTaskPanelStore", C_AISubTaskPanelStore, C_StoreGroup)
GroupName2Class.AISubTaskPanelStore = C_AISubTaskPanelStore
local M = C_AISubTaskPanelStore
local SHOW_TYPE = {
	HIDE = 0,
	SHOW = 1
}

function M:ctor()
	self.textId = 0
	self.enableByDialog = true
	self.enableBySelf = false
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.DIALOG_START] = self:CreateActionWithArgs("OnDialogStateChange", false),
		[gEventConstants.DIALOG_END] = self:CreateActionWithArgs("OnDialogStateChange", true)
	}
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnLanguageChange(lang)
	self:RefreshText()
	self:RefreshState()
end

function M:OnDialogStateChange(show)
	self.enableByDialog = show

	self:RefreshState()
end

function M:RefreshState()
	self.bindData.showTextCtrl = self.enableByDialog and self.enableBySelf and SHOW_TYPE.SHOW or SHOW_TYPE.HIDE
end

function M:RefreshText()
	if self.textId > 0 then
		local cfg = MassNPCConversationConfig.GetConfig(self.textId)

		if cfg then
			self.enableBySelf = true
			self.bindData.text = cfg.Content

			return
		end
	end

	self.enableBySelf = false
end

function M:OpenAIText(id)
	self.textId = id

	self:RefreshText()
	self:RefreshState()
end

function M:CloseAIText()
	self.textId = 0

	self:RefreshText()
	self:RefreshState()
end
