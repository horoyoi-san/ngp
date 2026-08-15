if not gHurtStiffManager then
	local M = {
		effectCd = 0,
		effectId = 0,
		ForceStiffsRecord = {}
	}
end

M.Debug = false
M.DebugInfo = ""
M.DebugHurtSpeed = false
M.PlayerUseSpecialHitDiaup = false
M.PlayerExecuteTarget = nil
HitStateType = {
	HitInAir = 9,
	MindPower = 15,
	Pull = 7,
	Ass = 13,
	ElectricShock = 12,
	DeathFall = 18,
	PuppetFall = 17,
	Global = 999,
	Hover = 4,
	Stiff = 1,
	ForceFieldHover = 8,
	HitWall = 10,
	ActionTransition = 11,
	FallGround = 5,
	Diaup = 2,
	PuppetGetup = 19,
	Fall = 3,
	StandUp = 6,
	Puppet = 14,
	FloatUp = 16
}

function M:OnInit()
	return
end

function M:DoCheckConfig(TransitionCondition)
	if TransitionCondition == "" then
		return true
	end

	local status, ret = self:RunCode(TransitionCondition, gHurtStiffScriptFunc)

	if not status then
		print_error("HurtStiffManager DoCheckConfig Error, TransitionCondition:", TransitionCondition)
	end

	return ret
end

function M:RunCode(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, ret = xpcall(f, tolua.traceback)

		return status, ret
	end

	return false, nil
end

gHurtStiffManager = M

return M
