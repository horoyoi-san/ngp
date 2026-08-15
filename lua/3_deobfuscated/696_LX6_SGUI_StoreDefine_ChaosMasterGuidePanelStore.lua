C_ChaosMasterGuidePanelStore = DefClass("C_ChaosMasterGuidePanelStore", C_ChaosMasterGuidePanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterGuidePanelStore = C_ChaosMasterGuidePanelStore
local M = C_ChaosMasterGuidePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	self:InitGuideData()
	self:RefreshGuideData(self.curIndex)
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

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.leftArrow.luaClick = self:CreateAction("OnClickLeftArrow")
	self.bindData.rightArrow.luaClick = self:CreateAction("OnClickRightArrow")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
end

function M:OnClickLeftArrow()
	self:RefreshGuideData(self.curIndex - 1)
end

function M:OnClickRightArrow()
	self:RefreshGuideData(self.curIndex + 1)
end

function M:OnClickExitBtn()
	gPanelManager:Close(gPanelId.CHAOS_MASTER_GUIDE_PANEL)
end

function M:InitGuideData()
	self.imageList = LTConfig.ChaosMasterConfig.GuideImg
	self.textList = LTConfig.ChaosMasterConfig.GuideText
	self.curIndex = 1
end

function M:RefreshGuideData(newIndex)
	self.curIndex = newIndex
	self.bindData.leftArrow.interactable = true
	self.bindData.rightArrow.interactable = true

	if newIndex == 1 then
		self.bindData.leftArrow.interactable = false
	elseif newIndex == #self.imageList then
		self.bindData.rightArrow.interactable = false
	end

	self.bindData.image = self.imageList[newIndex]
	self.bindData.text = self.textList[newIndex]
end
