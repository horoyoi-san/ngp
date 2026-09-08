-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuidePic.lua
-- Decompiled from: 00416_GuidePic.lua_69eb295b80f2.luajit

C_GuideBT_GuidePic = DefClass("C_GuideBT_GuidePic", C_GuideBT_GuidePic, C_GuideBT_ActionBase)
local M = C_GuideBT_GuidePic

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

	local param = {
		nodeGuid = self.guid,
		titleId = self.titleId,
		typeTextId = self.typeTextId,
		mainPicId = self.mainPicId,
		videoId = self.videoId
	}

	if self.guideText ~= nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePic没有设置guideText")

		return
	end

	slot2 = self.guideText
	param.guideText = slot2:Eval()
	param.notInteractiveTime = self.notInteractiveTime

	param.onBeforeCloseAnim = function()
		self._nextState = gGuideNodeState.Success
	end

	if self.autoCloseTime and self.autoCloseTime <= 0 then
		self._timer = Timer.New(function ()
			self._timer = nil
			self._nextState = gGuideNodeState.Success

			self:ClosePanel()
		end, self.autoCloseTime):Start()

		self:_RegisterVisibleListener()
	end

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)

	local panelId = gPanelId.S_GUIDE_PIC

	self:_RegisterPanelCloseListener(panelId)

	if gPanelManager:IsPanelShowing(panelId) then
		self.panelStoreCache = self.panelStoreCache or gStoreManager:GetStoreGroup("GuidePicPanelStore")

		if self.panelStoreCache then
			slot3 = self.panelStoreCache

			slot3:PlayCloseAnim(nil, panelId, function ()
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
	self:ClearTimer()
	self:_RemovePanelCloseListener()
	self:_RemoveVisibleListener()
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
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

	if gPanelManager:IsPanelVisible(gPanelId.S_GUIDE_PIC) then
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
	self.panelStoreCache = self.panelStoreCache or gStoreManager:GetStoreGroup("GuidePicPanelStore")

	if self.panelStoreCache then
		self.panelStoreCache:PlayCloseAnim(self.guid, gPanelId.S_GUIDE_PIC)
	else
		gPanelManager:Close(gPanelId.S_GUIDE_PIC)
	end
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.S_GUIDE_PIC
end
