-- Original chunk: @Lua\LuaFiles\LX6\Utils\FormulaScriptBattleUnit.lua
-- Decompiled from: 00113_FormulaScriptBattleUnit.lua_33bea075e59f.luajit

local ScriptBattleUnit = {}

ScriptBattleUnit.New = function(pid)
	local instance = {
		pid = pid
	}

	setmetatable(instance, {
		__index = ScriptBattleUnit
	})

	return instance
end

ScriptBattleUnit.HasBuff = function(self, buffId)
	return gBuffUtils.HasBuff(self.pid, buffId)
end

ScriptBattleUnit.HasState = function(self, stateId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(self.pid)

	if cs_unit then
		return gCS.UnitStateMgr:HasState(cs_unit, stateId)
	end

	return false
end

return ScriptBattleUnit
