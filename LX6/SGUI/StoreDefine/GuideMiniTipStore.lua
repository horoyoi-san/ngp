-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideMiniTipStore.lua
-- Decompiled from: 01730_GuideMiniTipStore.lua_73267af2a9f7.luajit

local CLOSE_CTRL_TYPE = {
	["RY~"] = 1,
	["I\nRl"] = 0
}
C_GuideMiniTipStore = DefClass("C_GuideMiniTipStore", C_GuideMiniTipStore, C_StoreGroup)
GroupName2Class.GuideMiniTipStore = C_GuideMiniTipStore
local M = C_GuideMiniTipStore

M.ctor = function(self)
	self.closeAnimTimerUUId = nil
	self.panelId = nil
	self.data = nil
	self.afterCloseAnim = nil
end

M.OnAwake = function(self)
	self.bindData.onPlayerClose = self.CreateAction(self, "OnPlayerClose")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

local HAS_TITLE = 0
local NO_TITLE = 1

M.OnShow = function(self, panelId, data)
	if self.closeAnimTimerUUId then
		print_error("#NoCreateIssue GuideMiniTipStore:OnShow called while closing, panelId=", panelId, "curNodeGuid=", self.data and self.data.nodeGuid, "newNodeGuid=", data and data.nodeGuid)

		if data and data.onBeforeCloseAnim then
			self.SafeInvokeCallback(self, data.onBeforeCloseAnim, "GuideMiniTipStore.OnShow.FallbackOnBeforeCloseAnim")

			data.onBeforeCloseAnim = nil
		end

		return
	end

	self.ApplyData(self, panelId, data)
end

M.OnClose = function(self)
	self.StopCloseAnim(self)
	self.InvokeBeforeCloseAnimAction(self)
	self.InvokeAfterCloseAnimAction(self)
	self.ClearTimer(self)

	self.data = nil
	self.panelId = nil
	self.guideTextList = nil
	self.open = false
	self.animating = false
end

M.ClearTimer = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshGuideTextList(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshGuideTextList(self)
end

M.SafeInvokeCallback = function(self, cb, tag)
	local ok, err = xpcall(cb, tolua.traceback)

	if not ok then
		print_error(tag, " callback failed:\n", err)
	end
end

M.ApplyData = function(self, panelId, data)
	self.data = data
	self.panelId = panelId
	self.guideTextList = data.guideTextList

	self.ClearTimer(self)
	self.EscHide(self)

	if data.escShowDelay and data.escShowDelay <= 0 then
		self._timer = Timer.New(function ()
			self:EscShow()
		end, data.escShowDelay):Start()
	elseif data.escShowDelay ~= 0 then
		self.EscShow(self, true)
	end

	self.bindData.hasTitle = NO_TITLE

	if data.titleId and data.titleId <= 0 then
		self.bindData.hasTitle = HAS_TITLE
		local titleCfg = LTConfig.GuideGuideTextConfig.GetConfig(data.titleId)

		if titleCfg then
			self.bindData.title = titleCfg.Text
		end
	end

	self.RefreshGuideTextList(self)

	self.open = true
end

M.RefreshGuideTextList = function(self)
	self.bindData.guideText = gGuideGlyph:GetGuideRichTexts(self.guideTextList)
end

M.InvokeBeforeCloseAnimAction = function(self)
	if self.data and self.data.onBeforeCloseAnim then
		local cb = self.data.onBeforeCloseAnim
		self.data.onBeforeCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuideMiniTipStore.BeforeCloseAnim")
	end
end

M.InvokeAfterCloseAnimAction = function(self)
	if self.afterCloseAnim then
		local cb = self.afterCloseAnim
		self.afterCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuideMiniTipStore.AfterCloseAnim")

		return true
	end

	return false
end

M.OnPlayerClose = function(self)
	if not self.panelId then
		return
	end

	self.PlayCloseAnim(self, nil, self.panelId)
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
		print_error("GuideMiniTipStore PlayCloseAnim error, panelId is nil")

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
