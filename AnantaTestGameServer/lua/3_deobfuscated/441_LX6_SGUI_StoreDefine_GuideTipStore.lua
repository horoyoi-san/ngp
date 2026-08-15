local GuideConfig = LTConfig.GuideGuideTextConfig
local CLOSE_CTRL_TYPE = {
	HIDE = 1,
	SHOW = 0
}
C_GuideTipStore = DefClass("C_GuideTipStore", C_GuideTipStore, C_StoreGroup)
GroupName2Class.GuideTipStore = C_GuideTipStore
local M = C_GuideTipStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.onPlayerClose = self:CreateAction("OnPlayerClose")
end

function M:OnShow(panelId, param)
	self.data = param

	self:ClearTimer()
	self:EscHide()

	if param.escShowDelay and param.escShowDelay > 0 then
		self._timer = Timer.New(function ()
			self:EscShow()
		end, param.escShowDelay):Start()
	elseif param.escShowDelay == 0 then
		self:EscShow(true)
	end

	self:RefreshUI()

	self.open = true
end

function M:OnActiveDeviceChange(device)
	self:RefreshUI()
end

function M:OnLanguageChange(lang)
	self:RefreshUI()
end

function M:OnClose()
	self:ClearTimer()

	self.data = nil
	self.open = false
	self.animating = false
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:OnPlayerClose()
	if self.data.onPlayerClose then
		self.data.onPlayerClose()
	end
end

function M:RefreshUI()
	local titleId = self.data.titleId
	local titleCfg = titleId and titleId > 0 and GuideConfig.GetConfig(titleId)
	self.bindData.titleText = titleCfg and titleCfg.Text or "[Default Title]"
	self.bindData.titleIconId = self.data.titleIconId
	self.bindData.contentText = gGuideGlyph:GetGuideRichText(self.data.guideText)
end

local CLOSE_ANIM = "S_Vx_GuideTip_close"

function M:PlayCloseAnim()
	local panelId = gPanelId.S_GUIDE_TIP

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
