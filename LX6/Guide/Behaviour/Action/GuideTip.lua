-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideTip.lua
-- Decompiled from: 00418_GuideTip.lua_5a6c2a809f97.luajit

C_GuideBT_GuideTip = DefClass("C_GuideBT_GuideTip", C_GuideBT_GuideTip, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideTip

M.OnTick = function(self)
	local nextState = self.nextState

	if nextState then
		self.nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	self.GetPanelId(self)
	self.CloseConflictPanelIfNeeded(self)

	local param = {
		titleId = self.titleId
	}

	if self.guideText ~= nil then
		print_error("@huangzhecong GuideTip没有设置guideText,guideId =", self.tree.guideId, "counterId =", self.tree.counterId)

		return
	end

	param.guideText = self.guideText:Eval()
	param.escShowDelay = self.escShowDelay
	param.titleIconId = self.titleIconId
	param.mainPicId = self.mainPicId
	param.videoId = self.videoId
	param.nodeGuid = self.guid

	param.onBeforeCloseAnim = function()
		self.nextState = gGuideNodeState.Success
	end

	self:ClearTimer()

	if self.duration and self.duration <= 0 then
		self._timer = Timer.New(function ()
			self._timer = nil
			self.nextState = gGuideNodeState.Success

			self:ClosePanel()
		end, self.duration):Start()

		self:_RegisterVisibleListener()
	end

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)

	local panelId = self:GetPanelId()

	self:_RegisterPanelCloseListener(panelId)

	if gPanelManager:IsPanelShowing(panelId) then
		local storeGroup = gStoreManager:GetStoreGroup("GuideTipStore")

		if storeGroup then
			storeGroup.PlayCloseAnim(storeGroup, nil, panelId, function ()
				gPanelManager:CheckShow(panelId, param)
			end)
		else
			gPanelManager:CheckShow(panelId, param)
		end
	else
		gPanelManager:CheckShow(panelId, param)
	end

	print_notice("C_GuideBT_GuideTip:OnEnterRunning")
end

M.OnExitRunning = function(self)
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	self:ClearTimer()
	self:_RemovePanelCloseListener()
	self:_RemoveVisibleListener()
	self:ClosePanel()
	print_notice("C_GuideBT_GuideTip:OnExitRunning")
end

M.ClearTimer = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M._RegisterVisibleListener = function(self)
	self._RemoveVisibleListener(self)

	self._visibleListener = function()
		self:_OnPanelVisibleChange()
	end

	local em = gMessageManager

	em.AddMessageListener(em, gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self._visibleListener)
	em.AddMessageListener(em, gEventConstants.PANEL_ON_SHOW, self._visibleListener)
	em.AddMessageListener(em, gEventConstants.PANEL_ON_CLOSE, self._visibleListener)
end

M._RemoveVisibleListener = function(self)
	if self._visibleListener then
		local em = gMessageManager

		em.RemoveMessageListener(em, gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self._visibleListener)
		em.RemoveMessageListener(em, gEventConstants.PANEL_ON_SHOW, self._visibleListener)
		em.RemoveMessageListener(em, gEventConstants.PANEL_ON_CLOSE, self._visibleListener)

		self._visibleListener = nil
	end
end

M._OnPanelVisibleChange = function(self)
	if not self._timer then
		return
	end

	if gPanelManager:IsPanelVisible(self:GetPanelId()) then
		if not self._timer.running then
			self._timer:Start()
		end
	elseif self._timer.running then
		self._timer:Stop()
	end
end

M._RegisterPanelCloseListener = function(self, panelId)
	self:_RemovePanelCloseListener()

	self._panelCloseListener = function(eventId, closedPanelId)
		if closedPanelId ~= panelId and gPanelManager:IsPanelShowing(closedPanelId) and not self.nextState then
			self.nextState = gGuideNodeState.Success
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.DO_CLOSE, self._panelCloseListener)
end

M._RemovePanelCloseListener = function(self)
	if self._panelCloseListener then
		gMessageManager:RemoveMessageListener(gEventConstants.DO_CLOSE, self._panelCloseListener)

		self._panelCloseListener = nil
	end
end

M.ClosePanel = function(self)
	local storeGroup = gStoreManager:GetStoreGroup("GuideTipStore")
	local panelId = self:GetPanelId()

	if storeGroup then
		storeGroup.PlayCloseAnim(storeGroup, self.guid, panelId)
	else
		gPanelManager:Close(panelId)
	end
end

M.GetConflictPanelId = function(self)
	if self.isFrontLayer then
		return gPanelId.S_GUIDE_TIP
	end

	return gPanelId.S_GUIDE_TIP_FRONT
end

M.CloseConflictPanelIfNeeded = function(self)
	gPanelManager:Destroy(self:GetConflictPanelId())
end

M.GetPanelId = function(self)
	if not self.panelId then
		if self.isFrontLayer then
			self.panelId = gPanelId.S_GUIDE_TIP_FRONT
		else
			self.panelId = gPanelId.S_GUIDE_TIP
		end
	end

	return self.panelId
end

M.GetPreLoadPanelIds = function(self)
	return self.GetPanelId(self)
end
