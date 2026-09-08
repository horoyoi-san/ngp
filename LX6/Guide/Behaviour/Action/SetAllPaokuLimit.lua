-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetAllPaokuLimit.lua
-- Decompiled from: 00424_SetAllPaokuLimit.lua_8ba0a290f523.luajit

C_GuideBT_SetAllPaokuLimit = DefClass("C_GuideBT_SetAllPaokuLimit", C_GuideBT_SetAllPaokuLimit, C_GuideBT_ActionBase)
local M = C_GuideBT_SetAllPaokuLimit

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	self.SetLimit(self, true)
end

M.OnExitRunning = function(self)
	self.SetLimit(self, false)
end

M.SetLimit = function(self, isLimit)
	if not self.isNeedExcept then
		gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allLimit, isLimit)

		return
	end

	local limitType = LX6.PaoKu.PaokuLimitType

	for k, v in pairs(limitType) do
		if v ~= gPaokuLimitManager.allLimit then
			-- Nothing
		elseif self.except == v then
			gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, v, isLimit)
		end
	end
end
