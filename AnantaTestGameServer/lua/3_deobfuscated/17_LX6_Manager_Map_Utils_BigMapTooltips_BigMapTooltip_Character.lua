C_BigMapTooltip_Character = DefClass("C_BigMapTooltip_Character", C_BigMapTooltip_Character, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Character
local ActivityConfig = LTConfig.AgentDataSetsActivityConfig
local AgentTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local ProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("characterInfo") then
		return
	end

	self:GetStore("MapCharacterTooltipStore")

	local info = self.tooltipInfo.characterInfo
	local activityCfg = ActivityConfig.GetConfig(info.agenActivityId)

	if not activityCfg then
		print_error("BigMapTooltip_Character:SetUpInfo activityCfg is nil! id:" .. tostring(info.agenActivityId))

		return
	end

	local agentTypeCfg = AgentTypeConfig.GetConfig(activityCfg.AgentTag)

	if not agentTypeCfg then
		print_error("BigMapTooltip_Character:SetUpInfo agentTypeCfg is nil! id:" .. tostring(activityCfg.AgentTag))

		return
	end

	self.profileId = agentTypeCfg.ProfileId
	local profileCfg = ProfileConfig.GetConfig(self.profileId)

	if not profileCfg then
		print_error("BigMapTooltip_Character:SetUpInfo profileCfg is nil! id:" .. tostring(self.profileId))

		return
	end

	if #profileCfg.UrbanAttribute ~= 6 then
		print_error("BigMapTooltip_Character:SetUpInfo profileCfg.UrbanAtribute count is not 6! id:" .. tostring(self.profileId))

		return
	end

	local npcCultivationId = activityCfg.NpccultivationId
	self.isNotANpc = npcCultivationId ~= 0
	local favorInfo = nil

	if self.isNotANpc then
		favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcCultivationId)

		if not favorInfo then
			print_error("BigMapTooltip_Character:SetUpInfo favorInfo is nil! npcCultivationId:" .. tostring(npcCultivationId))
		end
	end

	self:SetUpHeaderWithParams(agentTypeCfg.SImageId, self.element:GetName(), nil)
	self:SetUpLocation()

	local scale = agentTypeCfg.ImageScaleOffset and agentTypeCfg.ImageScaleOffset[1] or 1
	local offsetX = agentTypeCfg.ImageScaleOffset and agentTypeCfg.ImageScaleOffset[2] or 0
	local offsetY = agentTypeCfg.ImageScaleOffset and agentTypeCfg.ImageScaleOffset[3] or 0

	self.store.portraitRoot.rectTransform:SetLocalScaleXY(scale, scale)
	self.store.portraitRoot.rectTransform:SetAnchoredPosition(offsetX, offsetY)

	if self.isNotANpc then
		self.store.hasFavor = 0
		self.store.favorLevel = favorInfo.favorLevel
		local favorProgress = (favorInfo.favor - favorInfo.minFavor) / (favorInfo.maxFavor - favorInfo.minFavor)
		self.store.favorProgress = favorProgress
	else
		self.store.hasFavor = 1
	end

	self.store.headIconId = agentTypeCfg.QImageId
	self.rewards = profileCfg.TrustReward
	self.store.trustList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderHeadRewardDotItem", self)

	self.store.trustList:SetSimpleList(#self.rewards)

	self.abilities = profileCfg.Characteristic
	self.store.abilityList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderAbilityItem", self)
	self.store.abilityList.luaSimpleDynamicRenderItem = self.bigMap:CreateAction("OnRenderAbilityItem", self)
	self.store.abilityList.luaSimpleClick = self.bigMap:CreateAction("OnClickAbilityItem", self)

	self.store.abilityList:SetSimpleList(#self.abilities)

	local lifeAttrRuleList = gSpiritManager:GetUrbanRuleList(true)

	for i = 1, 6 do
		self.store.radar:SetVertexValue(i - 1, profileCfg.UrbanAttribute[i])

		local component = self.store["radarTitle" .. i]
		local store = gStoreManager:GetStoreGroup("Xuwei6DemensionInfoStore"):GetStoreByWidget(component)
		store.icon = lifeAttrRuleList[i].attrIcon
		store.nameLabel = profileCfg.UrbanAttribute[i]
	end

	local hasReward = gAgentTrustManager:CheckHasRewardCanGot(self.profileId)
	self.store.hasReward = hasReward and 0 or 1
end

function M:OnRenderAbilityItem(btn, index)
	index = index + 1
	local abilityId = self.abilities[index]
	local abilityCfg = LTConfig.ProfileCharacteristicConfig.GetConfig(abilityId)

	if not abilityCfg then
		print_error("BigMapTooltip_Character:OnRenderAbilityItem abilityCfg is nil! id:" .. tostring(abilityId))

		return
	end

	local store = gStoreManager:GetStoreGroup("AgentProfileDetailType"):GetStoreByWidget(btn)
	store.iconId = abilityCfg.Image
	store.title = abilityCfg.Name
	store.des = abilityCfg.Description
	store.isOpen = store.isOpen or false
	local type = (index - 1) % 4
	store.typeCtrl = store.isOpen and type + 4 or type
end

function M:OnClickAbilityItem(btn, index)
	local store = gStoreManager:GetStoreGroup("AgentProfileDetailType"):GetStoreByWidget(btn)
	store.isOpen = not store.isOpen and true

	self.store.abilityList:SetSimpleList(#self.abilities)
end

function M:OnRenderHeadRewardDotItem(btn, index)
	local rewardId = self.rewards[index + 1]

	if not rewardId then
		return
	end

	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreByWidget(btn)
	local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

	if rewardCfg and rewardCfg.RewardType == AgentProfileRewardConfig.RewardTypeType.Disable then
		store.fillCtrl = 0
	else
		local nowTrust = gAgentTrustManager:GetTrustValue(self.profileId) or 0
		local canGet = rewardCfg and rewardCfg.NeedTrust <= nowTrust
		store.fillCtrl = canGet and 0 or 1
	end
end
