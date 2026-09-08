-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MapGuidePanelStore.lua
-- Decompiled from: 00964_MapGuidePanelStore.lua_d78d876bb199.luajit

C_MapGuidePanelStore = DefClass("C_MapGuidePanelStore", C_MapGuidePanelStore, C_StoreGroup)
GroupName2Class.MapGuidePanelStore = C_MapGuidePanelStore
local M = C_MapGuidePanelStore

M.ctor = function(self)
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

M.OnAwake = function(self)
	self.bindData.traceBtn.luaClick = self.CreateAction(self, "OnTraceBtnClick")

	if self.bindData.heightBox then
		self.bindData.heightBox.luaSizeChanged = self.CreateAction(self, "OnSizeChanged")
	end
end

M.OnSizeChanged = function(self)
	self.CalculateHeightBox(self)
end

M.CalculateHeightBox = function(self)
	if not self.bindData.heightBox then
		return
	end

	local height = self.bindData.heightBox:GetTargetHeight()
	local heightBoxOffsetY = math.abs(self.bindData.heightBox.rectTransform.anchoredPosition.y)

	gTaskUtils:SetBloodBarPosition(heightBoxOffsetY + height)
	gTaskUtils:SendMobileTaskPanelChange(height + gTaskUtils:GetGameBarPanelHeight())
end

M.OnTraceBtnClick = function(self)
	gMapUtils:CheckRaidCanOpenMap()
end

M.RefreshTitle = function(self)
	self.bindData.type = 0
	local titles = gMapSubSystem_Task:GetGuidingTitles()

	if titles ~= nil or #titles < 0 then
		self.bindData.type = 0
	elseif #titles ~= 1 then
		local curTitle = titles[1]
		local foundValid = false

		for i, v in pairs(self.titlesDic) do
			if i ~= curTitle then
				foundValid = true
				self.bindData.type = self.titlesDic[i]

				break
			end
		end

		if not foundValid then
			print_error("#NoCreateIssue @huangzhecong 有一个任务title解锁，MapTask对应任务title没找到配置, title = ", titles[1])
		end
	elseif #titles <= 1 then
		self.bindData.type = 1
	end
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	gTaskUtils:SendMobileTaskPanelChange(0)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshTitle(self)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.CalculateHeightBox(self)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
