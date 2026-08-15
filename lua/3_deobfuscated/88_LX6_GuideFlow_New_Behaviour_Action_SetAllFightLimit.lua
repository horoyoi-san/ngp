C_GuideBT_SetAllFightLimit = DefClass("C_GuideBT_SetAllFightLimit", C_GuideBT_SetAllFightLimit, C_GuideBT_ActionBase)
local M = C_GuideBT_SetAllFightLimit

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	self:SetLimit(true)
end

function M:OnExitRunning()
	self:SetLimit(false)
end

function M:SetLimit(isLimit)
	if not self.isNeedExcept then
		gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allFightLimit, isLimit)

		return
	end

	local limitType = LX6.PaoKu.FightLimitType

	for k, v in pairs(limitType) do
		if v == gPaokuLimitManager.allFightLimit then
			-- Nothing
		elseif not self.isNeedExcept or self.except ~= v then
			gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, v, isLimit)
		end
	end
end
