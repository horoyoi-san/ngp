-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ProcessHUDLPGuide.lua
-- Decompiled from: 00421_ProcessHUDLPGuide.lua_c9ba194a5483.luajit

C_GuideBT_ProcessHUDLPGuide = DefClass("C_GuideBT_ProcessHUDLPGuide", C_GuideBT_ProcessHUDLPGuide, C_GuideBT_ActionBase)
local M = C_GuideBT_ProcessHUDLPGuide
local BLACKBOARD_KEY_PREFIX = "HUDLPData_"

local GetBlackboardKey = function(guideId)
	return BLACKBOARD_KEY_PREFIX .. guideId
end

local GetPopupData = function(self)
	local guideId = self.guideId or self.guideKey

	if not guideId or guideId ~= "" then
		return nil, 
	end

	local blackboard = self.GetBlackboard(self)
	local data = blackboard[GetBlackboardKey(guideId)]

	return guideId, data
end

M.OnCreate = function(self)
	self._elapsed = 0
	self._pressTime = 0
	self._nextState = nil
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	self._elapsed = 0
	self._nextState = nil
	self._pressTime = 0
	local guideId = self.guideId or self.guideKey

	if not guideId or guideId ~= "" then
		print_error("[GuideBT] ProcessHUDLPGuide no guideId")

		return
	end

	local blackboard = self.GetBlackboard(self)
	local data = blackboard[GetBlackboardKey(guideId)]

	if not data then
		return
	end

	self._pressTime = data.pressTime or 0

	self:_RefreshUI(0)
end

M.OnTick = function(self)
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

M.Run = function(self)
	if self._nextState then
		return
	end

	if self._pressTime < 0 then
		self._MarkFinish(self)
		self._RefreshUI(self, 1)

		self._nextState = gGuideNodeState.Success

		return
	end

	self._elapsed = self._elapsed + Time.deltaTime
	local ratio = math.min(self._elapsed / self._pressTime, 1)

	self._RefreshUI(self, ratio)

	if ratio > 1 then
		self._MarkFinish(self)

		self._nextState = gGuideNodeState.Success
	end
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self._nextState == gGuideNodeState.Success then
		self._RefreshUI(self, 0)
	end

	self._elapsed = 0
	self._pressTime = 0
	self._nextState = nil
end

M._MarkFinish = function(self)
	local _, data = GetPopupData(self)

	if not data then
		return
	end

	data.isFinish = true
end

M._RefreshUI = function(self, ratio)
	local guideId, data = GetPopupData(self)

	if not data then
		return
	end

	local comp = data.popupComp

	if not comp or gCS.LuaUtils.IsNull(comp) then
		data.popupComp = nil

		return
	end

	gNewGuideMgr:UpdateHUDLPPopupUI(guideId, comp, ratio, self._pressTime)
end
