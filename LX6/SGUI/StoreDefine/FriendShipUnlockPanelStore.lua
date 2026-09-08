-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FriendShipUnlockPanelStore.lua
-- Decompiled from: 01870_FriendShipUnlockPanelStore.lua_4fdc2c20c84d.luajit

local NpcCultivationConfig = LTConfig.NpcCultivationConfig
C_FriendShipUnlockPanelStore = DefClass("C_FriendShipUnlockPanelStore", C_FriendShipUnlockPanelStore, C_StoreGroup)
GroupName2Class.FriendShipUnlockPanelStore = C_FriendShipUnlockPanelStore
local M = C_FriendShipUnlockPanelStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, param)
	local data = param.Param

	if not data or not data.NpcId then
		gPanelManager:Close(gPanelId.S_FRIEND_SHIP_UNLOCK_PANEL)

		return
	end

	self.npcCultivationId = data.NpcId
	self.npcCfg = NpcCultivationConfig.GetConfig(self.npcCultivationId)
	self.areaIndex = param.areaIndex
	local sex = gPlayerManager.infoLogin.bindData.sexType

	if sex ~= UX.Game.SexType.Female then
		self.bindData.playerHeadId = 28000042
	else
		self.bindData.playerHeadId = 28000043
	end

	local friendHeadId = NpcCultivationConfig.GetConfig(self.npcCultivationId).SChatHeadId
	self.bindData.friendHeadId = friendHeadId
	slot6 = self.bindData.anim
	self.addAnimeTime = slot6:GetClip("S_Vx_S_FriendShipUnlockPanel_open").length

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_FRIEND_SHIP_UNLOCK_PANEL)
	end, self.addAnimeTime)
end

M.OnClose = function(self)
end
