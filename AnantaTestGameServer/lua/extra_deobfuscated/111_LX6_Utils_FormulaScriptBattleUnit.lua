local ScriptBattleUnit = {}

function ScriptBattleUnit.New(pid)
	local instance = {
		pid = pid
	}

	setmetatable(instance, {
		__index = ScriptBattleUnit
	})

	return instance
end

function ScriptBattleUnit:HasBuff(buffId)
	return gBuffUtils.HasBuff(self.pid, buffId)
end

function ScriptBattleUnit:HasState(stateId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(self.pid)

	if cs_unit then
		return gCS.UnitStateMgr:HasState(cs_unit, stateId)
	end

	return false
end

return ScriptBattleUnit
