local M = {}

function M:OnInit()
	local sg = gStoreManager:GetStoreGroup(self.rootWidget.Store)
	self.store = sg:GetStoreByWidget(self.rootWidget)
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextBase)
	self.guideTextDualSenseStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextDualSense)
	self.isDualSense = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation
end

function M:OnDispose()
	return
end

function M:SetupGuideText(guideTextData)
	self.guideTextData = guideTextData

	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:OnControlSchemeChange()
	self.isDualSense = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation

	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:OnLanguageChange()
	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:RefreshGuideTextList()
	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(self.guideTextData)
end

function M:RefreshGuideDualSenseText()
	if self.isDualSense then
		local id = self.guideTextData.dualSenseId

		if not id or id == 0 then
			self.store.dualsenseCtrl = 1

			return
		end

		self.store.dualsenseCtrl = 0
		local cfg = LTConfig.GuideGuideTextConfig.GetConfig(id)

		if not cfg then
			print_error("找不到DS手柄引导文本 in GuideGuideTextConfig:" .. id)

			return
		end

		local text = cfg.Text
		self.guideTextDualSenseStore.guideText = gGuideGlyph:GetRichTextByGuideStr(text)
	else
		self.store.dualsenseCtrl = 1
	end
end

return M
