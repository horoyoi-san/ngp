-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\InvestigatorManager.lua
-- Decompiled from: 02216_InvestigatorManager.lua_4cf33de18f8b.luajit

local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local StaticProps = {}
C_InvestigatorManager = DefClass("C_InvestigatorManager", C_InvestigatorManager, nil, StaticProps)
local M = C_InvestigatorManager

M.ctor = function(self)
end

M.InitData = function(self)
end

M.OnInit = function(self)
end

M.CheckIsUnlock = function(self)
	return gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.InvestigatorUnlock)
end

gInvestigatorManager = gInvestigatorManager or C_InvestigatorManager.new()
