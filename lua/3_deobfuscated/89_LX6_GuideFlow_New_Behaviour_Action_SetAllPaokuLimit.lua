C_GuideBT_SetAllPaokuLimit = DefClass("C_GuideBT_SetAllPaokuLimit", C_GuideBT_SetAllPaokuLimit, C_GuideBT_ActionBase)
local M = C_GuideBT_SetAllPaokuLimit

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
		gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allLimit, isLimit)

		return
	end

	local limitType = LX6.PaoKu.PaokuLimitType

	for k, v in pairs(limitType) do
		if v == gPaokuLimitManager.allLimit then
			-- Nothing
		elseif self.except ~= v then
			gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, v, isLimit)
		end
	end
end
