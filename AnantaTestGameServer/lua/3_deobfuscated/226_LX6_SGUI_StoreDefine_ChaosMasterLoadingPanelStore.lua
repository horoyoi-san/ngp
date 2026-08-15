C_ChaosMasterLoadingPanelStore = DefClass("C_ChaosMasterLoadingPanelStore", C_ChaosMasterLoadingPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterLoadingPanelStore = C_ChaosMasterLoadingPanelStore
local M = C_ChaosMasterLoadingPanelStore
local ShowType = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	self.leftChaos = {}
	self.rightChaos = {}

	function self.OnEndPortalAction()
		self:OnEndPortal()
	end
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.leftAvatar = gStoreManager:GetStoreGroup("ChaosOnlinMemberTemplate"):GetStoreByWidget(self.bindData.leftAvatar)
	self.rightAvatar = gStoreManager:GetStoreGroup("ChaosOnlinMemberTemplate"):GetStoreByWidget(self.bindData.rightAvatar)
	self.leftChaos[1] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.leftChaos1)
	self.leftChaos[2] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.leftChaos2)
	self.leftChaos[3] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.leftChaos3)
	self.rightChaos[1] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.rightChaos1)
	self.rightChaos[2] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.rightChaos2)
	self.rightChaos[3] = gStoreManager:GetStoreGroup("ChaosLoadingTemplate"):GetStoreByWidget(self.bindData.rightChaos3)
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.isStart = true
	self.endTime = Time.time + LTConfig.ChaosMasterConfig.ShowTime
	self.me = data.me
	self.other = data.other

	self:RefreshChaosInfo(true)
	self:RefreshChaosInfo(false)
	self:RefreshChaosList(true)
	self:RefreshChaosList(false)

	local clip = self.bindData.ani:GetClip("S_ChaosMasterLoadingPanel_open")
	self.openAniTime = Time.time + (clip and clip.length or 1)
	self.loadingFinish = false
	self.closing = false

	gBattlePetsMgr:EnableHud(false)
	gMessageManager:AddMessageListener(gEventConstants.ON_END_PORTAL, self.OnEndPortalAction)
	gCS.PreLoadSkillMgr:StartLoad(LX6.Fight.PreLoad.LoadType.BVB)
end

function M:OnClose()
	self.isStart = false

	gMessageManager:RemoveMessageListener(gEventConstants.ON_END_PORTAL, self.OnEndPortalAction)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.leftAvatar.luaClick = self:CreateAction("OnClickLeftAvatar")
	self.bindData.rightAvatar.luaClick = self:CreateAction("OnClickRightAvatar")
end

function M:OnUpdate()
	if self.closing then
		return
	end

	if self.loadingFinish and self.openAniTime < Time.time then
		self:OnEndPortal()
	end

	if self.endTime < Time.time then
		self:OnEndPortal()
	end
end

function M:RefreshChaosInfo(isMyChaos)
	local store = isMyChaos and self.leftAvatar or self.rightAvatar

	if isMyChaos then
		store.name = gPlayerManager.infoLogin.bindData.name
		store.iconId = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	elseif self.other.PlayerType == UX.Game.BVBPlayerType.Npc then
		local npcId = self.other.NpcId
		store.name = LTConfig.ChaosMasterChaosBattleNpcConfig.GetConfig(npcId).Name
	else
		local memberInfo = gLinkManager:GetMemberInfo(gBattlePetsMgr.otherPlayerPid)
		local characterId = gLinkManager:GetCharacterId(gBattlePetsMgr.otherPlayerPid)
		local imageAvatarId = memberInfo and memberInfo.PzHeadInfo.SystemHeadId or 0
		local imageAvatarCfg = LTConfig.ImageAvatarConfig.GetConfig(imageAvatarId)
		local headIcon = imageAvatarCfg and imageAvatarCfg.SguiImageId or 0

		if characterId ~= 0 then
			local cfg = LTConfig.FightSpiritConfig.GetConfig(characterId)
			headIcon = cfg and cfg.SHeadIconID or 0
		end

		store.name = memberInfo and memberInfo.Name or ""
		store.iconId = headIcon
	end

	self:RefreshLifeList(store, isMyChaos and self.me.Pokemons or self.other.Pokemons)
end

function M:RefreshLifeList(store, chaosList)
	local list = {}

	for i = 1, chaosList.Count do
		local item = {
			survivalCtrl = 0
		}

		table.insert(list, item)
	end

	store.survialList:SetList(list)
end

function M:RefreshChaosList(isMyChaos)
	local chaos = isMyChaos and self.me.Pokemons or self.other.Pokemons

	for i = 1, 3 do
		local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos[i])

		if cfg then
			local posData = cfg.ImageScaleOffset

			if isMyChaos then
				self.leftChaos[i].iconId = cfg.Icon

				self.leftChaos[i].imageTrans:SetLocalScaleXY(posData[1], posData[1])
				self.leftChaos[i].imageTrans:SetLocalPositionXY(posData[2], posData[3])
			else
				self.rightChaos[i].iconId = cfg.Icon

				self.rightChaos[i].imageTrans:SetLocalScaleXY(posData[1], posData[1])
				self.rightChaos[i].imageTrans:SetLocalPositionXY(posData[2], posData[3])
			end
		end

		if isMyChaos then
			self.bindData["showLeft" .. i .. "Ctrl"] = cfg and ShowType.Show or ShowType.Hide
		else
			self.bindData["showRight" .. i .. "Ctrl"] = cfg and ShowType.Show or ShowType.Hide
		end
	end
end

function M:OnEndPortal()
	if self.closing or not self.isStart then
		return
	end

	if Time.time < self.openAniTime then
		self.loadingFinish = true

		return
	end

	self.closing = true

	gBattleMgr:CommonPlayAniTool(self.bindData.ani, "S_ChaosMasterLoadingPanel_close", 0, 1, true, function ()
		gPanelManager:Close(gPanelId.CHAOS_MASTER_LOADING_PANEL)

		if gBattlePetsMgr.currentLevelNpcId == LTConfig.ChaosMasterConfig.GuideNpc then
			gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_GUIDE_PANEL)
		end
	end)
end
