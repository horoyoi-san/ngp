-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideTipStore.lua
-- Decompiled from: 01690_GuideTipStore.lua_6d9a6349f400.luajit

local GuideConfig = LTConfig.GuideGuideTextConfig
local CLOSE_CTRL_TYPE = {
	["RY~"] = 1,
	["I\nRl"] = 0
}
local ResourceType = {
	["{\\xa7\\xa6\\xaa\\xb9"] = 1,
	["d\\xa3\\xa3\\xa8\\xb3"] = 0
}
C_GuideTipStore = DefClass("C_GuideTipStore", C_GuideTipStore, C_StoreGroup)
GroupName2Class.GuideTipStore = C_GuideTipStore
local M = C_GuideTipStore

M.ctor = function(self)
	self.closeAnimTimerUUId = nil
	self.panelId = nil
	self.data = nil
	self.afterCloseAnim = nil
end

M.OnAwake = function(self)
	self.bindData.onPlayerClose = self.CreateAction(self, self.OnClickCloseBtn)
end

M.OnShow = function(self, panelId, param)
	if self.closeAnimTimerUUId then
		print_error("#NoCreateIssue GuideTipStore:OnShow called while closing, panelId=", panelId, "curNodeGuid=", self.data and self.data.nodeGuid, "newNodeGuid=", param and param.nodeGuid)

		if param and param.onBeforeCloseAnim then
			self.SafeInvokeCallback(self, param.onBeforeCloseAnim, "GuideTipStore.OnShow.FallbackOnBeforeCloseAnim")

			param.onBeforeCloseAnim = nil
		end

		return
	end

	self.ApplyParam(self, panelId, param)
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshUI(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshUI(self)
end

M.OnClose = function(self)
	self.StopCloseAnim(self)
	self.InvokeBeforeCloseAnimAction(self)
	self.InvokeAfterCloseAnimAction(self)
	self.ClearTimer(self)

	self.data = nil
	self.panelId = nil
	self.open = false
	self.animating = false
end

M.ClearTimer = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M.SafeInvokeCallback = function(self, cb, tag)
	local ok, err = xpcall(cb, tolua.traceback)

	if not ok then
		print_error(tag, " callback failed:\n", err)
	end
end

M.ApplyParam = function(self, panelId, param)
	self.panelId = panelId
	self.data = param

	self.ClearTimer(self)
	self.EscHide(self)

	if param.escShowDelay and param.escShowDelay <= 0 then
		self._timer = Timer.New(function ()
			self:EscShow()
		end, param.escShowDelay):Start()
	elseif param.escShowDelay ~= 0 then
		self.EscShow(self, true)
	end

	self.RefreshUI(self)
	self.RefreshResource(self)

	self.open = true
end

M.InvokeBeforeCloseAnimAction = function(self)
	if self.data and self.data.onBeforeCloseAnim then
		local cb = self.data.onBeforeCloseAnim
		self.data.onBeforeCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuideTipStore.BeforeCloseAnim")
	end
end

M.InvokeAfterCloseAnimAction = function(self)
	if self.afterCloseAnim then
		local cb = self.afterCloseAnim
		self.afterCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuideTipStore.AfterCloseAnim")

		return true
	end

	return false
end

M.OnClickCloseBtn = function(self)
	if not self.panelId then
		return
	end

	self.PlayCloseAnim(self, nil, self.panelId)
end

M.RefreshUI = function(self)
	local titleId = self.data.titleId
	local titleCfg = titleId and titleId <= 0 and GuideConfig.GetConfig(titleId)
	self.bindData.titleText = titleCfg and titleCfg.Text or "[Default Title]"
	self.bindData.titleIconId = self.data.titleIconId
	self.bindData.contentText = gGuideGlyph:GetGuideRichText(self.data.guideText)
end

M.RefreshResource = function(self)
	if self.data.mainPicId and self.data.mainPicId <= 0 then
		self.bindData.resourceCtrl = boolToNumber(true)
		self.bindData.resourceTypeCtrl = ResourceType.Image
		self.bindData.imageIconId = self.data.mainPicId
	elseif self.data.videoId and self.data.videoId <= 0 then
		self.bindData.resourceCtrl = boolToNumber(true)
		self.bindData.resourceTypeCtrl = ResourceType.Video

		self.bindData.videoPlayer:Init()
		self.bindData.videoPlayer:PlayVideo(self.data.videoId, true)
	else
		self.bindData.resourceCtrl = boolToNumber(false)
	end
end

local CLOSE_ANIM = "S_Vx_GuideTip_close"

M.CloseOrDestroyByGuideState = function(self, panelId)
	if gNewGuideMgr and gNewGuideMgr.ShouldDestroyGuidePanel and gNewGuideMgr:ShouldDestroyGuidePanel(panelId) then
		gPanelManager:Destroy(panelId)
	else
		gPanelManager:Close(panelId)
	end
end

M.ResetCloseAnimState = function(self)
	if self.bindData.anim then
		self.bindData.anim:Stop()

		local clip = self.bindData.anim:GetClip(CLOSE_ANIM)

		if clip then
			clip.SampleAnimation(clip, self.bindData.anim.gameObject, 0)
		end
	end
end

M.StopCloseAnim = function(self)
	if self.closeAnimTimerUUId then
		local uuid = self.closeAnimTimerUUId
		self.closeAnimTimerUUId = nil

		gLuaTimeMgrUtils.CancelUnitDelay(uuid)
		self.ResetCloseAnimState(self)
	end
end

M.PlayCloseAnim = function(self, nodeGuid, panelId, afterCloseAnim)
	panelId = panelId or self.panelId

	if not panelId then
		print_error("GuideTip PlayCloseAnim panelId is nil")

		return false
	end

	if not gPanelManager:IsPanelShowing(panelId) then
		return false
	end

	if self.data and self.data.nodeGuid and nodeGuid and self.data.nodeGuid == nodeGuid then
		return false
	end

	if afterCloseAnim then
		self.afterCloseAnim = afterCloseAnim
	end

	if self.closeAnimTimerUUId then
		return true
	end

	self.InvokeBeforeCloseAnimAction(self)

	if not self.bindData.anim then
		if not self.InvokeAfterCloseAnimAction(self) then
			self.CloseOrDestroyByGuideState(self, panelId)
		end

		return true
	end

	local clip = self.bindData.anim:GetClip(CLOSE_ANIM)

	if not clip then
		if not self.InvokeAfterCloseAnimAction(self) then
			self.CloseOrDestroyByGuideState(self, panelId)
		end

		return true
	end

	clip:SampleAnimation(self.bindData.anim.gameObject, 0)

	slot5 = self.bindData.anim

	slot5:Stop()

	slot5 = self.bindData.anim

	slot5:Play(CLOSE_ANIM)

	local uuid = gLuaTimeMgrUtils.Delay(function ()
		self:OnCloseAnimEnd(panelId)
	end, clip.length)

	if uuid == 0 then
		self.closeAnimTimerUUId = uuid
	end

	return true
end

M.OnCloseAnimEnd = function(self, panelId)
	self.closeAnimTimerUUId = nil

	self.ResetCloseAnimState(self)

	if not self.InvokeAfterCloseAnimAction(self) then
		self.CloseOrDestroyByGuideState(self, panelId)
	end
end

local ESC_SHOW_ANIM = "S_Vx_GuideTip_EscOpen"

M.EscShow = function(self, immediate)
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

M.EscHide = function(self)
	self.bindData.closeCtrl = CLOSE_CTRL_TYPE.HIDE
end
