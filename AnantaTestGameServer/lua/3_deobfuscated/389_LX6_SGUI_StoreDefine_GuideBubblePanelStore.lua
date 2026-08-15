C_GuideBubblePanelStore = DefClass("C_GuideBubblePanelStore", C_GuideBubblePanelStore, C_StoreGroup)
GroupName2Class.GuideBubblePanelStore = C_GuideBubblePanelStore
local M = C_GuideBubblePanelStore

function M:OnAwake()
	self.bindData.clickOpen = self:CreateAction("OnClickOpenGuideBtn")
end

function M:OnShow(panelId, data)
	self.data = data

	if data.closeTime then
		self._timer = Timer.New(function ()
			gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
			self:ClearTimer()

			if self.data and self.data.finishNode then
				self.data.finishNode()
			end
		end, data.closeTime):Start()
	end

	self:RefreshText()
end

function M:RefreshText()
	local teachCfg = LTConfig.GuideGuideTeachConfig.GetConfig(self.data.guideTeachId)

	if not teachCfg then
		print_error("GuideBubblePanelStore:teachCfg is nil for guideTeachId:", self.data.guideTeachId)

		return
	end

	self.bindData.title = self:GetGuideTabName(teachCfg.BelongTab)
	self.bindData.content = teachCfg.Name
end

function M:OnLanguageChange(lang)
	self:RefreshText()
end

function M:OnActiveDeviceChange(device)
	self:RefreshText()
end

function M:OnClose()
	self:ClearTimer()
end

function M:GetGuideTabName(tabId)
	if not self.tabNames then
		self.tabNames = {}

		for i = 1, #LTConfig.GuideConfig.TeachTabName do
			self.tabNames[i] = LTConfig.GuideConfig.TeachTabName[i]
		end
	end

	return self.tabNames[tabId] or ""
end

function M:OnClickOpenGuideBtn()
	self:ClearTimer()
	gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)

	local cfg = LTConfig.GuideGuideTeachConfig.GetConfig(self.data.guideTeachId)
	local param = {
		guideTeachCfg = cfg,
		finishNode = self.data.finishNode,
		subtitle = self:GetGuideTabName(cfg.BelongTab),
		title = cfg.Name
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_BUBBLE_FULL_SCREEN_PANEL, param)
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end
