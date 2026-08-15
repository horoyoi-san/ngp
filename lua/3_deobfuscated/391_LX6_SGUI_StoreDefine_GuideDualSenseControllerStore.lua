local GuideGuideTextConfig = LTConfig.GuideGuideTextConfig
C_GuideDualSenseControllerStore = DefClass("C_GuideDualSenseControllerStore", C_GuideDualSenseControllerStore, C_StoreGroup)
GroupName2Class.GuideDualSenseControllerStore = C_GuideDualSenseControllerStore
local M = C_GuideDualSenseControllerStore

function M:ctor()
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
	if not data then
		print_error("GuideDualSenseControllerStore OnShow data is nil")

		return
	end

	self.showData = data

	if not data.controllerTabIndex then
		print_error("GuideDualSenseController节点的TabIndex为空")
	elseif data.controllerTabIndex < 0 or self.bindData.controllerAnimTab.tabUrlListCount <= data.controllerTabIndex then
		print_error("GuideDualSenseController节点的TabIndex越界, index:" .. data.controllerTabIndex)
	else
		self.bindData.controllerAnimTab.selectedIndex = data.controllerTabIndex
	end

	self:RefreshText(data)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	self:RefreshText(self.showData)
end

function M:OnActiveDeviceChange(device)
	self:RefreshText(self.showData)
end

function M:RefreshText(data)
	local normalText = GuideGuideTextConfig.GetConfig(data.normalGuideTextId).Text
	local dualSenseText = GuideGuideTextConfig.GetConfig(data.dualSenseGuideTextId).Text
	self.bindData.normalGuideTextId = gGuideGlyph:GetRichTextByGuideStr(normalText)
	self.bindData.dualSenseGuideTextId = gGuideGlyph:GetRichTextByGuideStr(dualSenseText)
end
