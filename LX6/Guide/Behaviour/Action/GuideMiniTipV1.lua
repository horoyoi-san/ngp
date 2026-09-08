-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideMiniTipV1.lua
-- Decompiled from: 00414_GuideMiniTipV1.lua_41ddaa44c244.luajit

C_GuideBT_GuideMiniTipV1 = DefClass("C_GuideBT_GuideMiniTipV1", C_GuideBT_GuideMiniTipV1, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideMiniTipV1

M.OnTick = function(self)
	local _nextState = self._nextState

	if _nextState then
		self._nextState = nil

		return _nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	self.ClearTimer(self)
	self.CloseConflictPanelIfNeeded(self)

	if self.duration and self.duration <= 0 then
		self._timer = Timer.New(function ()
			self._timer = nil
			self._nextState = gGuideNodeState.Success

			self:ClosePanel()
		end, self.duration):Start()

		self:_RegisterVisibleListener()
	end

	local list = {}

	if self.guideText1 then
		table.insert(list, self.guideText1:Eval())
	end

	if self.guideText2 then
		table.insert(list, self.guideText2:Eval())
	end

	if self.guideText3 then
		table.insert(list, self.guideText3:Eval())
	end

	if self.guideText4 then
		table.insert(list, self.guideText4:Eval())
	end

	if #list ~= 0 then
		print_error("@huangzhecong GuideMiniTipV1没有设置guideText,guideId =", self.tree.guideId, "counterId =", self.tree.counterId)

		return
	end

	local param = {
		escShowDelay = self.escShowDelay,
		nodeGuid = self.guid,
		onBeforeCloseAnim = function ()
			self._nextState = gGuideNodeState.Success
		end,
		guideTextList = list,
		titleId = self.title
	}

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)

	local panelId = self:GetPanelId()

	self:_RegisterPanelCloseListener(panelId)

	if gPanelManager:IsPanelShowing(panelId) then
		local storeGroup = gStoreManager:GetStoreGroup("GuideMiniTipStore")

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
end

M.OnExitRunning = function(self)
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	self:ClearTimer()
	self:_RemovePanelCloseListener()
	self:_RemoveVisibleListener()
	self:ClosePanel()
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
		if closedPanelId ~= panelId and gPanelManager:IsPanelShowing(closedPanelId) and not self._nextState then
			self._nextState = gGuideNodeState.Success
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
	local storeGroup = gStoreManager:GetStoreGroup("GuideMiniTipStore")
	local panelId = self:GetPanelId()

	if storeGroup then
		storeGroup.PlayCloseAnim(storeGroup, self.guid, panelId)
	else
		gPanelManager:Close(panelId)
	end
end

M.GetConflictPanelId = function(self)
	if self.isFrontLayer then
		return gPanelId.S_GUIDE_MINI_TIP_PANEL
	end

	return gPanelId.S_GUIDE_MINI_TIP_PANEL_FRONT
end

M.CloseConflictPanelIfNeeded = function(self)
	gPanelManager:Destroy(self:GetConflictPanelId())
end

M.GetPanelId = function(self)
	if not self.panelId then
		if self.isFrontLayer then
			self.panelId = gPanelId.S_GUIDE_MINI_TIP_PANEL_FRONT
		else
			self.panelId = gPanelId.S_GUIDE_MINI_TIP_PANEL
		end
	end

	return self.panelId
end

M.GetPreLoadPanelIds = function(self)
	return self.GetPanelId(self)
end
