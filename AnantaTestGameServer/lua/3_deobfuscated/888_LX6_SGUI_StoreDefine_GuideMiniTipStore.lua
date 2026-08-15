local CLOSE_CTRL_TYPE = {
	HIDE = 1,
	SHOW = 0
}
C_GuideMiniTipStore = DefClass("C_GuideMiniTipStore", C_GuideMiniTipStore, C_StoreGroup)
GroupName2Class.GuideMiniTipStore = C_GuideMiniTipStore
local M = C_GuideMiniTipStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.onPlayerClose = self:CreateAction("OnPlayerClose")
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

local HAS_TITLE = 0
local NO_TITLE = 1

function M:OnShow(panelId, data)
	self.data = data
	self.guideTextList = data.guideTextList

	self:ClearTimer()
	self:EscHide()

	if data.escShowDelay and data.escShowDelay > 0 then
		self._timer = Timer.New(function ()
			self:EscShow()
		end, data.escShowDelay):Start()
	elseif data.escShowDelay == 0 then
		self:EscShow(true)
	end

	self.bindData.hasTitle = NO_TITLE

	if data.titleId and data.titleId > 0 then
		self.bindData.hasTitle = HAS_TITLE
		local titleCfg = LTConfig.GuideGuideTextConfig.GetConfig(data.titleId)

		if titleCfg then
			self.bindData.title = titleCfg.Text
		end
	end

	self:RefreshGuideTextList()

	self.open = true
end

function M:OnClose()
	if self.data.onPlayerClose then
		self.data.onPlayerClose()
	end

	self:ClearTimer()

	self.data = nil
	self.guideTextList = nil
	self.open = false
	self.animating = false
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:OnActiveDeviceChange(device)
	self:RefreshGuideTextList()
end

function M:OnLanguageChange(lang)
	self:RefreshGuideTextList()
end

function M:RefreshGuideTextList()
	self.bindData.guideText = gGuideGlyph:GetGuideRichTexts(self.guideTextList)
end

function M:OnPlayerClose()
	self:PlayCloseAnim()
end

local CLOSE_ANIM = "S_Vx_GuideTip_close"

function M:PlayCloseAnim()
	local panelId = gPanelId.S_GUIDE_MINI_TIP_PANEL

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
	self.bindData.closeCtrl = CLOSE_CTRL_TYPE.SHOW

	if immediate then
		local clip = self.bindData.escAnim:GetClip(ESC_SHOW_ANIM)

		self.bindData.escAnim:Play(ESC_SHOW_ANIM)
		clip:SampleAnimation(self.bindData.escAnim.gameObject, clip.length)
		self.bindData.escAnim:Stop()
	else
		self.bindData.escAnim:Play(ESC_SHOW_ANIM)
	end
end

function M:EscHide()
	self.bindData.closeCtrl = CLOSE_CTRL_TYPE.HIDE
end
