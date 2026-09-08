-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SimpleInputWhitelistV1.lua
-- Decompiled from: 00438_SimpleInputWhitelistV1.lua_5f0507e58c9d.luajit

C_GuideBT_SimpleInputWhitelistV1 = DefClass("C_GuideBT_SimpleInputWhitelistV1", C_GuideBT_SimpleInputWhitelistV1, C_GuideBT_ActionBase)
local M = C_GuideBT_SimpleInputWhitelistV1

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	SGUI.GuideMgr.SimpleSetWhitelistV1(self.guid, self.pckeyId, self.controllerId)
end

M.OnExitRunning = function(self)
	SGUI.GuideMgr.RemoveWhitelistV1(self.guid)
end
