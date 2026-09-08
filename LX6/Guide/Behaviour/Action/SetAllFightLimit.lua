-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetAllFightLimit.lua
-- Decompiled from: 00423_SetAllFightLimit.lua_107fc1d545b4.luajit

C_GuideBT_SetAllFightLimit = DefClass("C_GuideBT_SetAllFightLimit", C_GuideBT_SetAllFightLimit, C_GuideBT_ActionBase)
local M = C_GuideBT_SetAllFightLimit

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
		gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allFightLimit, isLimit)

		return
	end

	local limitType = LX6.PaoKu.FightLimitType

	for k, v in pairs(limitType) do
		if v ~= gPaokuLimitManager.allFightLimit then
			-- Nothing
		elseif not self.isNeedExcept or self.except == v then
			gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, v, isLimit)
		end
	end
end
