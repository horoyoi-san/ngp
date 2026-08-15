local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_XinShouRaidQuitPanelStore = DefClass("C_XinShouRaidQuitPanelStore", C_XinShouRaidQuitPanelStore, C_StoreGroup)
GroupName2Class.XinShouRaidQuitPanelStore = C_XinShouRaidQuitPanelStore
local M = C_XinShouRaidQuitPanelStore

function M:OnAwake()
	self.bindData.btnList.luaSimpleClick = self:CreateAction(self.OnClickBtn)
	self.bindData.backBtn.luaClick = self:CreateAction(self.ClosePanel)
	self.actionList = {
		{
			label = TextScriptTextConfig.GetConfig(89901342).Text,
			action = self:CreateAction(self.ClosePanel)
		},
		{
			label = TextScriptTextConfig.GetConfig(89901109).Text,
			action = self:CreateAction(self.OnSettingBtnClick)
		},
		{
			label = TextScriptTextConfig.GetConfig(89901069).Text,
			action = self:CreateAction(self.OnExitBtnClick)
		}
	}

	if not gUIUtils:IsInXinShouRaid() then
		table.insert(self.actionList, 2, {
			label = TextScriptTextConfig.GetConfig(89901343).Text,
			action = self:CreateAction(self.RestartCurrentTask)
		})
		table.insert(self.actionList, 3, {
			label = TextScriptTextConfig.GetConfig(89900709).Text,
			action = self:CreateAction(self.GiveUpCurrentTask)
		})
	end
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnShow(panelId, data)
	self.currentTaskId = gTaskNodeManager:GetNowDoingTask()

	self.bindData.btnList:InitSimpleList()

	for i = 1, #self.actionList do
		self.bindData.btnList:AddSimpleLabel(0, self.actionList[i].label)
	end

	self.bindData.btnList:RefreshList()
end

function M:OnClose()
	return
end

function M:ClosePanel()
	gPanelManager:Close(gPanelId.XINSHOU_EXIT)
end

function M:OnSettingBtnClick()
	self:ClosePanel()
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL)
end

function M:OnExitBtnClick()
	self:ClosePanel()
	gLoginManager:DoKickToLogin()
end

function M:RestartCurrentTask()
	self:ClosePanel()
	gTaskNodeManager:AskResetTask(self.currentTaskId)
end

function M:GiveUpCurrentTask()
	self:ClosePanel()
	gTaskNodeManager:AskCancelChasing(self.currentTaskId)
end

function M:OnClickBtn(btn, index)
	local data = self.actionList[index + 1]

	if data.action then
		data.action()
	end
end
