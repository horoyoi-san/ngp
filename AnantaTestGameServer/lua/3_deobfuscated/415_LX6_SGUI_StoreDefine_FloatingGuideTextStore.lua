C_FloatingGuideTextStore = DefClass("C_FloatingGuideTextStore", C_FloatingGuideTextStore, C_StoreGroup)
GroupName2Class.FloatingGuideTextStore = C_FloatingGuideTextStore
local M = C_FloatingGuideTextStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
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
	local sg = gStoreManager:GetStoreGroup(self.rootWidget.Store)
	self.store = sg:GetStoreByWidget(self.rootWidget)
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextBase)
	self.guideTextDualSenseStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.store.guideTextDualSense)
	self.isDualSense = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation

	self:SetupGuideText(data.guideTextData)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:OnActiveDeviceChange(device)
	self.isDualSense = device == SGUI.GameDevice.PlayStation

	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:GenMessageEvents()
	return
end

function M:SetupGuideText(guideTextData)
	self.guideTextData = guideTextData

	self:RefreshGuideTextList()
	self:RefreshGuideDualSenseText()
end

function M:RefreshGuideTextList()
	self.guideTextStore.textComp.forceSyncLoad = true
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
		self.guideTextDualSenseStore.textComp.forceSyncLoad = true
		self.guideTextDualSenseStore.guideText = gGuideGlyph:GetRichTextByGuideStr(text)
	else
		self.store.dualsenseCtrl = 1
	end
end
