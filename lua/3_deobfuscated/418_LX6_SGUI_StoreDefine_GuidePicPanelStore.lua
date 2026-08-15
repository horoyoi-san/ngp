C_GuidePicPanelStore = DefClass("C_GuidePicPanelStore", C_GuidePicPanelStore, C_StoreGroup)
GroupName2Class.GuidePicPanelStore = C_GuidePicPanelStore
local M = C_GuidePicPanelStore

function M:ctor()
	self.areaIndex = 0
end

local PIC_MODE = 0
local VIDEO_MODE = 1

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")

	self.bindData.videoPlayer:Init()
end

function M:OnShow(panelId, param)
	self.param = param
	self.panelId = panelId
	self.areaIndex = param.areaIndex or 0
	local titleTextCfg = param.titleId and param.titleId > 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.titleId)
	self.bindData.title = titleTextCfg and titleTextCfg.Text or ""

	if not param.mainPicId or param.mainPicId <= 0 then
		self.bindData.mode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(param.videoId, true, nil, nil)
	else
		self.bindData.mode = PIC_MODE
		self.bindData.imageId = param.mainPicId or 0
	end

	self:RefreshRichText()

	local typeTextCfg = param.typeId and param.typeId > 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.typeId)
	self.bindData.typeText = typeTextCfg and typeTextCfg.Text or ""

	self:EscHide()

	if param.notInteractiveTime and param.notInteractiveTime > 0 then
		self._timer = Timer.New(function ()
			self:EscShow()
		end, param.notInteractiveTime):Start()
	else
		self:EscShow(true)
	end

	self.open = true

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:SetHudState(false)
	end
end

function M:OnCloseBtnClick()
	self:PlayCloseAnim()
end

function M:OnClose()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end

	if self.param.onClose then
		self.param.onClose()
	end

	self.open = false
	self.animating = false

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:SetHudState(true)
	end
end

function M:OnActiveDeviceChange(device)
	self:RefreshRichText()

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self:SetHudState(false)
	end
end

function M:OnLanguageChange(lang)
	self:RefreshRichText()
end

function M:RefreshRichText()
	if self.param.guideText then
		self.bindData.desc = gGuideGlyph:GetGuideRichText(self.param.guideText)
	end
end

function M:SetHudState(isShow)
	if isShow then
		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.S_GUIDE_PIC)
	else
		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.S_GUIDE_PIC)
	end

	gUIFunctionStateManager.isGuidePicOpen = not isShow

	gUIFunctionStateManager:RefreshMotionActionState()
end

local CLOSE_ANIM = "S_Vx_GuidePic_close"

function M:PlayCloseAnim()
	local panelId = gPanelId.S_GUIDE_PIC

	if not self.open and not self.animating then
		gPanelManager:Close(panelId)

		return
	elseif self.animating then
		return
	end

	self.animating = gUIUtils:PlayAniClosePanel(self.bindData.anim, CLOSE_ANIM, panelId)

	if not self.animating then
		gPanelManager:Close(panelId)
	end
end

local ESC_SHOW_ANIM = "S_Vx_GuideTip_EscOpen"

function M:EscShow(immediate)
	if self.bindData.closeTip then
		self.bindData.closeTip:SetActive(true)

		if immediate then
			local clip = self.bindData.escAnim:GetClip(ESC_SHOW_ANIM)

			self.bindData.escAnim:Play(ESC_SHOW_ANIM)
			clip:SampleAnimation(self.bindData.escAnim.gameObject, clip.length)
			self.bindData.escAnim:Stop()
		else
			self.bindData.escAnim:Play(ESC_SHOW_ANIM)
		end
	end

	if self.bindData.closeBtn then
		self.bindData.closeBtn:SetActive(true)
	end
end

function M:EscHide()
	if self.bindData.closeBtn then
		self.bindData.closeBtn:SetActive(false)
	end

	if self.bindData.closeTip then
		self.bindData.closeTip:SetActive(false)
	end
end
