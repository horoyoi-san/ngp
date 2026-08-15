local M = C_NewMapPanelStore

function M:EnableJiaMuView(enable)
	if enable then
		self:SetViewMask(EMapViewMask.Gangster + EMapViewMask.BigMap)
		self:SendFSMSignal(EBigMapFSMSignal.OpenJiaMuView)
	else
		self:SetViewMask(EMapViewMask.BigMap)
		self:SendFSMSignal(EBigMapFSMSignal.CloseJiaMuView)
	end

	self:SetScale(self.scale, true, true)
end

function M:IsJiaMuViewEnabled()
	return self.fsms[4].currentState == EBigMapFSMState.JiaMuView_Open
end

local JIAMU_SPIRIT_ID = 15020989

function M:NeedAddJiaMuViewEntry()
	local isJiaMu = self.filterCharacterTid == JIAMU_SPIRIT_ID
	local systemUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FactionInfluenceMap)

	return isJiaMu and systemUnlock
end
