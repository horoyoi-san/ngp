-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideFullScreen.lua
-- Decompiled from: 00413_GuideFullScreen.lua_82a97c468e3d.luajit

C_GuideBT_GuideFullScreen = DefClass("C_GuideBT_GuideFullScreen", C_GuideBT_GuideFullScreen, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideFullScreen

M.OnTick = function(self)
	local _nextState = self._nextState

	if _nextState then
		self._nextState = nil

		return _nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local params = {
		pageDatas = {},
		onClose = function ()
			self._nextState = gGuideNodeState.Success
		end
	}
	slot2 = ipairs
	slot4 = self.fullscreenDatas or {}

	for _, data in slot2(slot4) do
		if data then
			table.insert(params.pageDatas, data.Eval(data))
		end
	end

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, 0, -1)

	gPanelManager:CheckShow(gPanelId.GUIDE_FULL_SCREEN_PANEL, params)
end

M.OnExitRunning = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.GUIDE_FULL_SCREEN_PANEL) then
		gPanelManager:Close(gPanelId.GUIDE_FULL_SCREEN_PANEL)
	end

	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.GUIDE_FULL_SCREEN_PANEL
end
