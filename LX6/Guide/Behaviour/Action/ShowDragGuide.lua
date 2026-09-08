-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowDragGuide.lua
-- Decompiled from: 00432_ShowDragGuide.lua_1205a8e7ee8e.luajit

C_GuideBT_ShowDragGuide = DefClass("C_GuideBT_ShowDragGuide", C_GuideBT_ShowDragGuide, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowDragGuide
local UGuideActionCommon = require("LX6/Guide/Behaviour/Action/UGuideActionCommon")

M.OnCreate = function(self)
	UGuideActionCommon.InitMatchState(self)

	self._nextState = nil
	self._onDrop = nil
	self._targetGuideId = nil
end

M.OnTick = function(self)
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	local sourceGuideId = self.sourceGuideId:Eval()
	local targetGuideId = self.targetGuideId:Eval()

	if not sourceGuideId or sourceGuideId ~= "" then
		print_error("[GuideBT] ShowDragGuide 没有配置 sourceGuideId")

		return
	end

	if not targetGuideId or targetGuideId ~= "" then
		print_error("[GuideBT] ShowDragGuide 没有配置 targetGuideId")

		return
	end

	self._nextState = nil
	self._targetGuideId = targetGuideId

	SGUI.GuideMgr.RegisterDragDropTarget(targetGuideId)

	self._onDrop = function(dropGuideId)
		if dropGuideId ~= self._targetGuideId then
			self._nextState = gGuideNodeState.Success
		end
	end

	gNewGuideMgr:RegisterSGUIGuideEvent(gNewGuideMgr.SEventType.ButtonDropped, self._onDrop)
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self._onDrop then
		gNewGuideMgr:UnRegisterSGUIGuideEvent(gNewGuideMgr.SEventType.ButtonDropped, self._onDrop)

		self._onDrop = nil
	end

	if self._targetGuideId and self._targetGuideId == "" then
		SGUI.GuideMgr.UnregisterDragDropTarget(self._targetGuideId)

		self._targetGuideId = nil
	end

	self._nextState = nil
end
