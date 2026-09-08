-- Original chunk: @Lua\LuaFiles\LX6\Manager\Npc\NpcFavorManager.lua
-- Decompiled from: 02190_NpcFavorManager.lua_2defc4693ecb.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local AgentConfig = LTConfig.AgentConfig
local AgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local GiftTagsConfig = LTConfig.ConsumableTagsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local StaticProps = {}
C_NpcFavorManager = DefClass("C_NpcFavorManager", C_NpcFavorManager, nil, StaticProps)
local M = C_NpcFavorManager

M.ctor = function(self)
	self:InitData()

	self.agentType2NpcId = {}

	for i = 0, NpcCultivationConfig.count - 1 do
		local cfg = NpcCultivationConfig.LoadAt(i)

		if cfg.AgentTag == 0 then
			self.agentType2NpcId[cfg.AgentTag] = cfg.Id
		end
	end
end

M.InitData = function(self)
	self.InviteRideNpc = 0
	self.InviteRideNpcActive = false
	self.defaultColor = Color.NewByStr("FFFFFF")
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))

	self.pointItemInfo = gCommonItemManager:GetItemRenderData({
		itemId = ConsumableConfig.ActionPoint
	})
	self.renderPointCb = self:CreateActionWithArgs("OnRenderToolTips", self.pointItemInfo, gCommonItemManager)
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:InitData()
end

M.OnSyncNpcFavor = function(self, npcCardId, favorDiff, favor, gamePlayType)
	favor = gNpcInteracsUtils:TransformFavor(favor)
	local faverInfo, _ = self:GetSpiritCultivationInfo(npcCardId)
	faverInfo.Favor = favor
	local msg = {
		NpcId = npcCardId,
		favor = favor,
		delta = favorDiff
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CULTIVATION_REFRESH, npcCardId)
	gMessageManager:SendMessage(gEventConstants.NPC_FAVOR_CHANGE, msg)

	if gamePlayType ~= GamePlayTypeConfig.Firework then
		gFireworkMgr.npcFavorAddInfo = msg

		return
	end

	if gNewBubbleMgr:IsAlive() then
		return
	end

	if not gPlayerManager.cacheInfo.bindData.ignoreFavorChangeShow then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.FriendShipChange, {
			Param = msg
		})
	end
end

M.OnSyncRideNpc = function(self, npcId, npcActive)
	self.InviteRideNpc = npcId
	self.InviteRideNpcActive = npcActive
end

M.GetInviteRideNpc = function(self)
	return self.InviteRideNpc
end

M.CheckIsInRide = function(self)
	return self.InviteRideNpcActive and self.InviteRideNpc == 0
end

M.GetRideNpcInst = function(self)
	local unit = gCS.SceneDataMgr.GetUnit(self.InviteRideNpc)

	if unit then
		print_debug("GetRideNpcInst", unit)
	end

	return unit
end

M.GetInviteRideNpcCultivationId = function(self)
	local unit = gCS.SceneDataMgr.GetUnit(self.InviteRideNpc)

	if unit then
		print_debug("GetInviteRideNpcId", unit)

		local cfg = FightSpiritConfig.GetConfig(unit.ClientData.cardId)

		if cfg then
			return cfg.NpcCultivationRelatedId
		end
	end

	return 0
end

M.GetLevelFromFavor = function(self, favor)
	local levelList = NpcCultivationConfig.FavorLevel
	local level = 0

	for i = 1, #levelList do
		if levelList[i] < favor then
			level = i
		end
	end

	if not level then
		return #levelList
	end

	return level
end

M.GetMaxFavoriteLevel = function(self)
	return #NpcCultivationConfig.FavorLevel
end

M.GetRoleFavor = function(self, favor)
	local favorLevel = self:GetLevelFromFavor(favor)
	local nextLevel = math.min(favorLevel + 1, self:GetMaxFavoriteLevel())
	local maxFavor = NpcCultivationConfig.FavorLevel[nextLevel]
	local minFavor = NpcCultivationConfig.FavorLevel[favorLevel]

	if minFavor ~= maxFavor then
		minFavor = NpcCultivationConfig.FavorLevel[favorLevel - 1]
	end

	return favor, favorLevel, minFavor, maxFavor
end

M.GetSpiritFavorInfo = function(self, npcId)
	if self.agentType2NpcId[npcId] then
		npcId = self.agentType2NpcId[npcId]
	end

	local favor = 0
	local favorLevel = 0
	local minFavor = 0
	local maxFavor = 0
	local dict = self:GetSpiritCultivationInfo(npcId)

	if not table.isNilOrEmpty(dict) then
		favor, favorLevel, minFavor, maxFavor = self:GetRoleFavor(dict.Favor)
	end

	local ele = {
		favor = favor,
		favorLevel = favorLevel,
		minFavor = minFavor,
		maxFavor = maxFavor,
		favorAmount = (favor - minFavor) / (maxFavor - minFavor)
	}

	return ele
end

M.GetFavorInfoByFavor = function(self, favor)
	local favor, favorLevel, minFavor, maxFavor = self:GetRoleFavor(favor)
	local ele = {
		favor = favor,
		favorLevel = favorLevel,
		minFavor = minFavor,
		maxFavor = maxFavor,
		favorAmount = (favor - minFavor) / (maxFavor - minFavor)
	}

	return ele
end

M.CheckNpcFavorIsMax = function(self, npcId)
	local favorInfo = self:GetSpiritFavorInfo(npcId)

	if favorInfo.favorLevel ~= self:GetMaxFavoriteLevel() and favorInfo.favorAmount > 1 then
		return true
	end

	return false
end

M.GetSpiritCultivationInfo = function(self, npcId)
	local index = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfosDic[npcId]
	local dict = index and gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos[index] or {}

	if table.isNilOrEmpty(dict) then
		index = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfosDic[npcId]

		if index then
			dict = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos[index]

			return dict, true
		end

		return dict, false
	end

	return dict, true
end

M.GetAllSpiritFavorInfo = function(self)
	local favorList = {}
	local list = array.concat(table.clone(gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos), gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos)

	for i = 1, #list do
		local favor, favorLevel, minFavor, maxFavor = self:GetRoleFavor(list[i].Favor)
		favorList[list[i].TemplateId] = {
			favor = favor,
			favorLevel = favorLevel,
			minFavor = minFavor,
			maxFavor = maxFavor,
			favorAmount = (favor - minFavor) / (maxFavor - minFavor)
		}
	end

	return favorList
end

M.GetAgentTypeByFightSpiritId = function(self, spiritId)
	local cfg = FightSpiritConfig.GetConfig(spiritId)

	if not cfg then
		return 0
	end

	local agentId = cfg.AgentId
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return 0
	end

	return agentCfg.AgentSpecificType
end

M.GetAgentNpcHeadInfo = function(self, npcId, style)
	style = style or 0
	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	if not npcCfg then
		return 0, self.defaultColor
	end

	return self:GetAgentTypeHeadInfo(npcCfg.AgentTag, style)
end

M.GetAgentTypeByNpcId = function(self, npcId)
	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	return npcCfg and npcCfg.AgentTag or 0
end

M.GetAgentFightSpiritHeadInfo = function(self, fightSpiritId, style)
	local agentType = self:GetAgentTypeByFightSpiritId(fightSpiritId)

	return self:GetAgentTypeHeadInfo(agentType, style)
end

M.GetAgentTypeHeadInfo = function(self, agentType, style)
	style = style or 0

	if agentType ~= AgentSpecificTypeConfig.DefaultFemale or agentType ~= AgentSpecificTypeConfig.DefaultMale then
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId)

		return headIcon, self.defaultColor
	end

	local specialType = AgentSpecificTypeConfig.GetConfig(agentType)

	if not specialType then
		return 0, self.defaultColor
	end

	return specialType.HeadIcon[style + 1], string.is_null_or_empty(specialType.HeadBgColor) and self.defaultColor or Color.NewByStr(specialType.HeadBgColor)
end

M.GetCurrentAgentType = function(self)
	local cfg = FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)

	if not cfg then
		return 0
	end

	local aCfg = AgentConfig.GetConfig(cfg.AgentId)

	if not aCfg then
		return 0
	end

	return aCfg.AgentSpecificType
end

M.GetAgentBirth = function(self, agentType)
	local npcId = self.agentType2NpcId[agentType]

	if not npcId then
		return TextScriptTextConfig.GetConfig(89900096).Text
	end

	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	return npcCfg and npcCfg.Birthday or TextScriptTextConfig.GetConfig(89900096).Text
end

M.GetAgentGetDays = function(self, agentType)
	local activeTime = self:GetAgentActiveTime(agentType)

	return activeTime <= 0 and gCS.TimeManager.ServerUnixTime - activeTime or 0
end

M.GetAgentActiveTime = function(self, agentType)
	local npcId = self.agentType2NpcId[agentType]
	local cInfo, isUnlock = self:GetSpiritCultivationInfo(npcId)

	return isUnlock and cInfo.ActivateTimestamp or 0
end

M.GetAgentName = function(self, agentType)
	local npcId = self.agentType2NpcId[agentType] or 0
	local cfg = NpcCultivationConfig.GetConfig(npcId)

	if not cfg then
		return ""
	end

	if (agentType ~= AgentSpecificTypeConfig.DefaultFemale or agentType ~= AgentSpecificTypeConfig.DefaultMale) and gPlayerManager.infoLogin.bindData.UsePlayerName then
		return gPlayerManager.infoLogin.bindData.name
	end

	return cfg.Name
end

M.GetRoleTimeDict = function(self)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local blockDict = gNewBubbleMgr.blockDict

	for i = 1, #list do
		if blockDict[list[i].TemplateId] == true then
			local targetTime = list[i].InteractDays
			ret[list[i].TemplateId] = targetTime
		end
	end

	return ret
end

M.CheckIsUnlock = function(self, agentType)
	agentType = self.agentType2NpcId[agentType] or agentType
	local cfg = NpcCultivationConfig.GetConfig(agentType)

	if not cfg then
		return false
	end

	return gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.NpcCultivation)
end

M.GetNpcQImage = function(self, agentType)
	local npcId = self.agentType2NpcId[agentType] or 0
	local cfg = NpcCultivationConfig.GetConfig(npcId)

	if not cfg then
		return 0
	end

	return cfg.QImageId or 0
end

M.CheckInteractPointEnough = function(self, playId)
	local playCfg = GamePlayTypeConfig.GetConfig(playId)
	local cost = playCfg.InteractPointCost
	local current = gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint

	return cost > current
end

M.OnAddActionPoint = function(self)
end

M.RefreshInteractPoint = function(self, playId, totalWidget)
	local playCfg = GamePlayTypeConfig.GetConfig(playId)

	self:OnRenderActionPoint(totalWidget, nil, )

	return playCfg.InteractPointCost
end

M.OnRenderActionPoint = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("CommonActionPointStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.numLabel = gPlayerManager.infoMinorNpcCultivation.bindData.InteractPoint .. "/" .. NpcCultivationConfig.InteractPointMaxLimit
	store.addBtn.luaClick = self:CreateAction(self.OnAddActionPoint)
	btn.luaRenderTooltip = self.renderPointCb
end

M.OnRenderFavorTemplate = function(self, btn, id)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local favorInfo = self:GetSpiritFavorInfo(id)
	store.favorAmount = favorInfo.favorAmount
	store.favorLabel = favorInfo.favorLevel
end

M.OnRenderFavorTemplateByFavor = function(self, btn, favor)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local favorInfo = self:GetFavorInfoByFavor(favor)
	store.favorAmount = favorInfo.favorAmount
	store.favorLabel = favorInfo.favorLevel
end

M.OnRenderHeadAvatar = function(self, btn, agentType, style)
	if not btn then
		return
	end

	if not agentType or agentType ~= 0 then
		agentType = self:GetCurrentAgentType()
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local headIcon, bgColor = self:GetAgentTypeHeadInfo(agentType, style)
	store.headIcon = headIcon
	store.bgColor = bgColor

	return store
end

M.GetNpcGiftTagInfo = function(self, npcId)
	if self.agentType2NpcId[npcId] then
		npcId = self.agentType2NpcId[npcId]
	end

	local info = gNpcInteracsUtils:TryGetNpcCultivationInfo(npcId)
	local ret = {}

	if not info then
		return ret
	end

	local cfg = NpcCultivationConfig.GetConfig(npcId)

	if not cfg then
		return ret
	end

	local tmp = {}

	for i = 1, #cfg.PreferTags do
		tmp[cfg.PreferTags[i]] = true
	end

	for i = 1, #info.ActiveGiftTags do
		local id = info.ActiveGiftTags[i]
		local cfg = GiftTagsConfig.GetConfig(id)

		if tmp[id] and cfg.Visible then
			local ele = {
				id = id
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.AskDeliverGift = function(self, npcId, itemUid, count, callback)
	gClientToGameDelegate:AskInteractNpcWithGift(npcId, itemUid, count).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		elseif callback then
			callback()
		end
	end
end

gNpcFavorManager = gNpcFavorManager or C_NpcFavorManager.new()
