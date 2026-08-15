local GameplayGuideConfig = LTConfig.GameplayGuideConfig
local ContentConfig = LTConfig.GameplayGuideContentConfig
local GameDevice = SGUI.GameDevice
C_CommonGameplayInstructionsStore = DefClass("C_CommonGameplayInstructionsStore", C_CommonGameplayInstructionsStore, C_StoreGroup)
GroupName2Class.CommonGameplayInstructionsStore = C_CommonGameplayInstructionsStore
local M = C_CommonGameplayInstructionsStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.playId = 0
	self.cfg = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	if table.isNilOrEmpty(data) or data.id == nil then
		self:OnClickCloseBtn()
		print_error("[CommonGameplayInstructionsStore] :OnShow - data is nil or empty")

		return
	end

	self.playId = data.id
	self.device = gCS.LuaUtils.GetActiveDevice()

	self:RefreshInfo()
end

function M:OnClose()
	return
end

function M:OnActiveDeviceChange(device)
	self.device = device

	self:RefreshPage()
end

function M:RegisterWidget()
	self.bindData.leftArrow.luaClick = self:CreateActionWithArgs(self.OnStep, -1)
	self.bindData.rightArrow.luaClick = self:CreateActionWithArgs(self.OnStep, 1)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnClickCloseBtn)
	self.bindData.dotList.luaSelectedChanged = self:CreateAction(self.RefreshPage)

	self.bindData.videoPlayer:Init()
end

function M:OnStep(step)
	local index = self.bindData.dotList.selectedIndex + step

	self.bindData.dotList:SelectItem(index)
end

function M:OnClickCloseBtn()
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS)
end

function M:RefreshInfo()
	self.cfg = GameplayGuideConfig.GetConfig(self.playId)

	if not self.cfg then
		print_error("[CommonGameplayInstructionsStore] :RefreshInfo - cfg is nil for playId:", self.playId)

		return
	end

	self.bindData.title = self.cfg.Name
	self.bindData.subtitle = self.cfg.SubTitle
	local contentCount = #self.cfg.Contents
	self.bindData.showDots = BOOL2CTL[contentCount > 1]

	self.bindData.dotList:SetSimpleList(contentCount)
	self.bindData.dotList:SelectItem(0)
	self:RefreshPage()
end

function M:RefreshPage()
	local index = self.bindData.dotList.selectedIndex
	local contentCfg = ContentConfig.GetConfig(self.cfg.Contents[index + 1])

	if not contentCfg then
		print_error("[CommonGameplayInstructionsStore] :RefreshPage - contentCfg is nil for index:", index)

		return
	end

	if contentCfg.VideoId and contentCfg.VideoId ~= 0 then
		self.bindData.isVideo = BOOL2CTL[true]

		self.bindData.videoPlayer:PlayVideo(contentCfg.VideoId, true)
	else
		self.bindData.isVideo = BOOL2CTL[false]
		self.bindData.imageId = contentCfg.ImageId
	end

	local text = contentCfg.Desc
	local device = self.device

	if device == GameDevice.KeyboardMouse then
		text = string.is_null_or_empty(contentCfg.StandaloneStr) and text or contentCfg.StandaloneStr
	elseif GameDevice.PlayStation <= device then
		text = string.is_null_or_empty(contentCfg.ControllerStr) and text or contentCfg.ControllerStr
	else
		text = string.is_null_or_empty(contentCfg.MobileStr) and text or contentCfg.MobileStr
	end

	self.bindData.descText = gGuideGlyph:GetGuideRichText({
		text = text
	})
	local itemCount = self.bindData.dotList:GetListCount()
	self.bindData.leftArrow.interactable = index > 0
	self.bindData.rightArrow.interactable = index < itemCount - 1
end
