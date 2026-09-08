-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoLoginData.lua
-- Decompiled from: 00097_PlayerInfoLoginData.lua_1e8f1dab7f30.luajit

C_PlayerInfoLoginData = DefClass("C_PlayerInfoLoginData", C_PlayerInfoLoginData, C_PlayerDataBase)
local M = C_PlayerInfoLoginData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	t.pid = info.InfoLogin.Pid
	t.sexType = info.InfoLogin.Sex
	t.name = info.InfoLogin.Name
	t.playerName = info.InfoLogin.Name
	t.lastChangeNameTime = info.InfoLogin.LastChangeNameTime or 0
	t.infoPzHeadInfo = info.InfoLogin.PzHeadInfo
	t.infoLinkPzHeadInfo = info.InfoLogin.LinkPzHeadInfo
	t.UsePlayerName = not info.InfoLogin.UseSystemName
	t.LastLeaveClubTime = info.InfoLogin.LastLeaveClubTime

	gMultiverseMgr:OnSyncSwitchUniverse(0, info.InfoLogin.UniverseId)
	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
