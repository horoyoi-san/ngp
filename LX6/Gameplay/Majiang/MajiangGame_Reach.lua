-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_Reach.lua
-- Decompiled from: 00343_MajiangGame_Reach.lua_6c24809470b4.luajit

local M = C_MajiangGame

M.OnSyncReachRoundPrepare = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnRoundPrepare(state, info)
	self.Reach3D_OnRoundPrepare(self, info)
end

M.OnSyncReachRoundStart = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state:OnRoundStart(info)
	self:Reach3D_OnRoundStart(info)
	self:RunQueuedAction("OnSyncReachRoundStart")
	gPanelManager:Close(gPanelId.MAJIANG_RIMA_FINAL_PANEL)
end

M.OnSyncReachDrawTile = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnDrawTile(state, info)
	self.RefreshMyHandDisplayList(self, false)
	self.Reach3D_OnDrawTile(self, info)
	self.RefreshTimeOutByState(self, nil)
	self.RunQueuedAction(self, "OnSyncReachDrawTile")
end

M.OnSyncReachDiscardOperation = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnDiscardOperation(state, info)
	self.RefreshMyHandDisplayList(self, false)
	self.Reach3D_OnDiscardOperation(self, info)
	self.RefreshTimeOutByState(self, nil)
	self.RunQueuedAction(self, "OnSyncReachDiscardOperation")
end

M.OnSyncReachTurnEnd = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnTurnEnd(state, info)
	self.Reach3D_OnTurnEnd(self, info)

	self.timeOut = nil

	self.RunQueuedAction(self, "OnSyncReachTurnEnd")
end

M.OnSyncReachOperationPerform = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnOperationPerform(state, info)
	self.RefreshMyHandDisplayList(self, false)
	self.Reach3D_OnOperationPerform(self, info)
	self.RefreshTimeOutByState(self, nil)
	self.RunQueuedAction(self, "OnSyncReachOperationPerform")
end

M.OnSyncReachKongInfo = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnKongInfo(state, info)
	self.Reach3D_OnKongInfo(self, info)
	self.RefreshTimeOutByState(self, nil)
	self.RunQueuedAction(self, "OnSyncReachKongInfo")
end

M.OnSyncReachBeiDora = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnBeiDora(state, info)
	self.RefreshMyHandDisplayList(self, false)
	self.Reach3D_OnBeiDora(self, info)
	self.RefreshTimeOutByState(self, nil)
	self.RunQueuedAction(self, "OnSyncReachBeiDora")
end

M.OnSyncReachTsumo = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnTsumo(state, info)
	self.RefreshMyHandDisplayList(self, true)
	self.Reach3D_OnTsumo(self, info)
	self.RunQueuedAction(self, "OnSyncReachTsumo")
end

M.OnSyncReachRong = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnRong(state, info)
	self.RefreshMyHandDisplayList(self, true)
	self.Reach3D_OnRong(self, info)
	self.RunQueuedAction(self, "OnSyncReachRong")
end

M.OnSyncReachPointTransfer = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnPointTransfer(state, info)
	self.Reach3D_OnPointTransfer(self, info)
	self.RunQueuedAction(self, "OnSyncReachPointTransfer")
end

M.OnSyncReachRoundDraw = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	state.OnRoundDraw(state, info)
	self.Reach3D_OnRoundDraw(self, info)
	self.RunQueuedAction(self, "OnSyncReachRoundDraw", info)
end

M.OnSyncReachGameEnd = function(self, info)
	local state = self.reachGameState

	if state ~= nil then
		return
	end

	if state.CurrentRound ~= nil then
		return
	end

	state.OnGameEnd(state, info)
	self.Reach3D_OnGameEnd(self, info)
	self.RunQueuedAction(self, "OnSyncReachGameEnd")
end

M.BeginReachGame = function(self)
end
