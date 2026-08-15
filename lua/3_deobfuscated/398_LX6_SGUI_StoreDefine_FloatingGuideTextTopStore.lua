C_FloatingGuideTextTopStore = DefClass("C_FloatingGuideTextTopStore", C_FloatingGuideTextTopStore, C_StoreGroup)
GroupName2Class.FloatingGuideTextTopStore = C_FloatingGuideTextTopStore
local M = C_FloatingGuideTextTopStore

function M:ctor()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.areaIndex = data.areaIndex
	self.guideTextData = data.Param.guideTextData
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.bindData.guideTextBase)

	self:RefreshGuideTextList()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	self:RefreshGuideTextList()
end

function M:OnActiveDeviceChange(device)
	self:RefreshGuideTextList()
end

function M:RefreshGuideTextList()
	self.guideTextStore.textComp.forceSyncLoad = true
	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(self.guideTextData)
end
