C_MapGuidePanelStore = DefClass("C_MapGuidePanelStore", C_MapGuidePanelStore, C_StoreGroup)
GroupName2Class.MapGuidePanelStore = C_MapGuidePanelStore
local M = C_MapGuidePanelStore

function M:ctor()
	self.titlesDic = {
		4,
		3,
		nil,
		nil,
		nil,
		2
	}
	self.templateHeight = gTaskUtils:GetMobileDefaultTemplateHeight(gTaskUtils.TaskGuideSubPanel.MapGuide)
	self.defaultHeight = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.MapGuide)
end

function M:OnAwake()
	self.bindData.traceBtn.luaClick = self:CreateAction("OnTraceBtnClick")
end

function M:OnTraceBtnClick()
	gMapUtils:CheckRaidCanOpenMap()
end

function M:RefreshTitle()
	self.bindData.type = 0
	local titles = gMapSubSystem_Task:GetGuidingTitles()

	if titles == nil or #titles <= 0 then
		self.bindData.type = 0
	elseif #titles == 1 then
		local curTitle = titles[1]
		local foundValid = false

		for i, v in pairs(self.titlesDic) do
			if i == curTitle then
				foundValid = true
				self.bindData.type = self.titlesDic[i]

				break
			end
		end

		if not foundValid then
			print_error("#NoCreateIssue @huangzhecong 有一个任务title解锁，MapTask对应任务title没找到配置, title = ", titles[1])
		end
	elseif #titles > 1 then
		self.bindData.type = 1
	end
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	gTaskUtils:SendMobileTaskPanelChange(0)
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	gTaskUtils:SendMobileTaskPanelChange(self.defaultHeight)
	self:RefreshTitle()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
