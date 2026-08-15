local NpcCultivationConfig = LTConfig.NpcCultivationConfig
C_FriendShipUnlockPanelStore = DefClass("C_FriendShipUnlockPanelStore", C_FriendShipUnlockPanelStore, C_StoreGroup)
GroupName2Class.FriendShipUnlockPanelStore = C_FriendShipUnlockPanelStore
local M = C_FriendShipUnlockPanelStore

function M:ctor()
	return
end

function M:OnShow(panelId, param)
	local data = param.Param

	if not data or not data.NpcId then
		gPanelManager:Close(gPanelId.S_FRIEND_SHIP_UNLOCK_PANEL)

		return
	end

	self.npcCultivationId = data.NpcId
	self.npcCfg = NpcCultivationConfig.GetConfig(self.npcCultivationId)
	self.areaIndex = param.areaIndex
	local sex = gPlayerManager.infoLogin.bindData.sexType

	if sex == UX.Game.SexType.Female then
		self.bindData.playerHeadId = 28000042
	else
		self.bindData.playerHeadId = 28000043
	end

	local friendHeadId = NpcCultivationConfig.GetConfig(self.npcCultivationId).SChatHeadId
	self.bindData.friendHeadId = friendHeadId
	self.addAnimeTime = self.bindData.anim:GetClip("S_Vx_S_FriendShipUnlockPanel_open").length

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_FRIEND_SHIP_UNLOCK_PANEL)
	end, self.addAnimeTime)
end

function M:OnClose()
	return
end
