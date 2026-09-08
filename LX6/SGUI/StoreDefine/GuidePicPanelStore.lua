-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuidePicPanelStore.lua
-- Decompiled from: 01688_GuidePicPanelStore.lua_e6aac86244fe.luajit

C_GuidePicPanelStore = DefClass("C_GuidePicPanelStore", C_GuidePicPanelStore, C_StoreGroup)
GroupName2Class.GuidePicPanelStore = C_GuidePicPanelStore
local M = C_GuidePicPanelStore

M.ctor = function(self)
	self.areaIndex = 0
	self.closeAnimTimerUUId = nil
	self.param = nil
	self.afterCloseAnim = nil
end

local PIC_MODE = 0
local VIDEO_MODE = 1

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.scrollRect.luaInitContent = self:CreateAction(self.OnInitScrollRect)

	self.bindData.videoPlayer:Init()
end

M.OnShow = function(self, panelId, param)
	if self.closeAnimTimerUUId then
		print_error("#NoCreateIssue GuidePicPanelStore:OnShow called while closing, panelId=", panelId, "curNodeGuid=", self.param and self.param.nodeGuid, "newNodeGuid=", param and param.nodeGuid)

		if param and param.onBeforeCloseAnim then
			self.SafeInvokeCallback(self, param.onBeforeCloseAnim, "GuidePicPanelStore.OnShow.FallbackOnBeforeCloseAnim")

			param.onBeforeCloseAnim = nil
		end

		return
	end

	self.ApplyParam(self, param)
end

M.ApplyParam = function(self, param)
	self.param = param
	self.areaIndex = param.areaIndex or 0
	local titleTextCfg = param.titleId and param.titleId <= 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.titleId)
	self.bindData.title = titleTextCfg and titleTextCfg.Text or ""

	if not param.mainPicId or param.mainPicId < 0 then
		self.bindData.mode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(param.videoId, true, nil, )
	else
		self.bindData.mode = PIC_MODE
		self.bindData.imageId = param.mainPicId or 0
	end

	self:RefreshRichText()

	local typeTextCfg = param.typeTextId and param.typeTextId <= 0 and LTConfig.GuideGuideTextConfig.GetConfig(param.typeTextId)
	self.bindData.typeText = typeTextCfg and typeTextCfg.Text or ""

	self:EscHide()

	if param.notInteractiveTime and param.notInteractiveTime <= 0 then
		self._escDelayShowTimer = Timer.New(function ()
			self:EscShow()
		end, param.notInteractiveTime):Start()
	else
		self.EscShow(self, true)
	end

	self.open = true

	if self.bindData.anim then
		self.bindData.anim:Play(self:GetOpenAnimName())
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetHudState(self, false)
	end
end

M.OnCloseBtnClick = function(self)
	self.PlayCloseAnim(self, nil, gPanelId.S_GUIDE_PIC)
end

M.OnClose = function(self)
	self.StopCloseAnim(self)

	if self._escDelayShowTimer then
		self._escDelayShowTimer:Stop()

		self._escDelayShowTimer = nil
	end

	self.InvokeBeforeCloseAnimAction(self)
	self.InvokeAfterCloseAnimAction(self)

	self.open = false
	self.animating = false
	self.param = nil
	self.textComp = nil

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetHudState(self, true)
	end
end

M.SafeInvokeCallback = function(self, cb, tag)
	local ok, err = xpcall(cb, tolua.traceback)

	if not ok then
		print_error(tag, " callback failed:\n", err)
	end
end

M.InvokeBeforeCloseAnimAction = function(self)
	if self.param and self.param.onBeforeCloseAnim then
		local cb = self.param.onBeforeCloseAnim
		self.param.onBeforeCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuidePicPanelStore.BeforeCloseAnim")
	end
end

M.InvokeAfterCloseAnimAction = function(self)
	if self.afterCloseAnim then
		local cb = self.afterCloseAnim
		self.afterCloseAnim = nil

		self.SafeInvokeCallback(self, cb, "GuidePicPanelStore.AfterCloseAnim")

		return true
	end

	return false
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshRichText(self)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SetHudState(self, false)
	end
end

M.OnLanguageChange = function(self, lang)
	self.RefreshRichText(self)
end

M.RefreshRichText = function(self)
	if not self.textComp then
		return
	end

	if self.param and self.param.guideText then
		self.textComp.text = gGuideGlyph:GetGuideRichText(self.param.guideText)
	end
end

M.OnInitScrollRect = function(self, content)
	self.textComp = content

	self.RefreshRichText(self)
end

M.SetHudState = function(self, isShow)
	if isShow then
		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.S_GUIDE_PIC)
	else
		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.S_GUIDE_PIC)
	end

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.MotionAction, "isGuidePicClosed", isShow)
end

local OPEN_ANIM = "S_Vx_GuidePic_open"
local OPEN_ANIM_MOBILE = "S_Vx_GuidePic_open_mobile"
local CLOSE_ANIM = "S_Vx_GuidePic_close"
local CLOSE_ANIM_MOBILE = "S_Vx_GuidePic_close_mobile"

M.GetOpenAnimName = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive() and OPEN_ANIM or OPEN_ANIM_MOBILE
end

M.GetCloseAnimName = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive() and CLOSE_ANIM or CLOSE_ANIM_MOBILE
end

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

		local clip = self.bindData.anim:GetClip(self:GetCloseAnimName())

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
	panelId = panelId or gPanelId.S_GUIDE_PIC

	if not gPanelManager:IsPanelShowing(panelId) then
		return false
	end

	if self.param and self.param.nodeGuid and nodeGuid and self.param.nodeGuid == nodeGuid then
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

	local closeAnimName = self:GetCloseAnimName()
	local clip = self.bindData.anim:GetClip(closeAnimName)

	if not clip then
		if not self.InvokeAfterCloseAnimAction(self) then
			self.CloseOrDestroyByGuideState(self, panelId)
		end

		return true
	end

	clip:SampleAnimation(self.bindData.anim.gameObject, 0)

	slot6 = self.bindData.anim

	slot6:Stop()

	slot6 = self.bindData.anim

	slot6:Play(closeAnimName)

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

M.EscHide = function(self)
	if self.bindData.closeBtn then
		self.bindData.closeBtn:SetActive(false)
	end

	if self.bindData.closeTip then
		self.bindData.closeTip:SetActive(false)
	end
end
