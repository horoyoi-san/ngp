local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local StaticProps = {}
C_InvestigatorManager = DefClass("C_InvestigatorManager", C_InvestigatorManager, nil, StaticProps)
local M = C_InvestigatorManager

function M:ctor()
	return
end

function M:InitData()
	return
end

function M:OnInit()
	return
end

function M:CheckIsUnlock()
	return gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.InvestigatorUnlock)
end

gInvestigatorManager = gInvestigatorManager or C_InvestigatorManager.new()
