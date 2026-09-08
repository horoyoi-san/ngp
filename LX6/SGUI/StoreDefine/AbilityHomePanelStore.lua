-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AbilityHomePanelStore.lua
-- Decompiled from: 00774_AbilityHomePanelStore.lua_421f97aab993.luajit

C_AbilityHomePanelStore = DefClass("C_AbilityHomePanelStore", C_AbilityHomePanelStore, C_StoreGroup)
GroupName2Class.AbilityHomePanelStore = C_AbilityHomePanelStore
local M = C_AbilityHomePanelStore

M.OnAwake = function(self)
	self.bindData.canJoinTeamList.luaRenderItem = self:CreateAction("OnRenderJoinTeamItem")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.occupationList.luaSimpleRenderItem = self:CreateAction("OnRenderOccupationItem")
	self.bindData.badgeList.luaSimpleRenderItem = self:CreateAction("OnRenderBadgeItem")
	self.bindData.abilityList.luaSimpleRenderItem = self:CreateAction("OnRenderAbilityItem")
	self.bindData.dimensionBtn.luaClick = self:CreateAction("OnDimensionBtnClick")
	self.bindData.goAbilityBtn.luaClick = self:CreateAction("OnAbilityBtnClick")
	self.bindData.goBadgeBtn.luaClick = self:CreateAction("OnBadgeBtnClick")
	self.bindData.goBadgeBtn2.luaClick = self:CreateAction("OnBadgeBtn2Click")
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	local msgEvents = {
		[gEventConstants.ON_SYNC_SPIRIT_ABILITYINFO] = self:CreateAction("SyncSpiritAbilityInfo"),
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData"),
		[gEventConstants.ON_ASK_ALL_SPIRIT_PANEL_DATA] = self:CreateAction("OnAllSpiritPanelData")
	}

	self:RegisterMessageEvents(msgEvents)
end

M.OnEnable = function(self)
	self.spiritId = self.urbanAbilityStore:GetCurSpiritTid()
	self.spiritViewData = gSpiritManager:GetSpirit(self.spiritId)

	self:SetSpiritData()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.SyncSpiritAbilityInfo = function(self)
	self.SetSpiritData(self)
end

M.ChangeSpiriViewData = function(self, eventId, data)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityHomePanel_cut")
	Timer.New(function ()
		self.spiritId = data.data.id
		self.spiritViewData = gSpiritManager:GetSpirit(self.spiritId)

		self:SetSpiritData()
	end, 0.2):Start()
end

M.OnAllSpiritPanelData = function(self)
	self.SetLiuWei(self)
end

M.SetSpiritData = function(self)
	if not self.spiritViewData then
		return
	end

	self.SetSpirit(self)
	self.SetOccupationList(self)
	self.SetBadgeList(self)
	self.SetAbilityList(self)
	self.SetLiuWei(self)
	self.SetFaction(self)
	self.SetFriendShip(self)
end

M.SetSpirit = function(self)
	self.bindData.phoneNum.text = gUrbanAbilityManager:GetPhoneNum(self.spiritId)
	self.bindData.name.text = self.spiritViewData.Name
	local spiritInfo = self.spiritViewData.SpiritInfo
	self.bindData.badgeNum.text = gUrbanAbilityManager:GetSpiritAllBadgeNum(self.spiritId)
	self.bindData.abilityNum.text = gUrbanAbilityManager:GetAbilitySumExp(spiritInfo.SpiritAbilities)
end

M.SetOccupationList = function(self)
	local list = {}

	for i, v in pairs(self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		if v.Job == LTConfig.UrbanJobConfig.Jobless then
			local info = {
				id = v.Job,
				selected = false
			}

			table.insert(list, info)
		end
	end

	self._occupationListData = list

	self.bindData.occupationList:SetSimpleList(#list)
end

M.SetLiuWei = function(self)
	local urbanAttrs = gUrbanAbilityManager:GetUrbanAttrs(self.spiritId)

	if not urbanAttrs then
		local cfg = LTConfig.FightSpiritConfig.GetConfig(self.spiritId)

		if cfg and cfg.UrbanAttribute then
			urbanAttrs = cfg.UrbanAttribute
		end
	end

	if not urbanAttrs then
		return
	end

	local list = {}

	for i, v in ipairs(urbanAttrs) do
		local cfg = LTConfig.UrbanAttributeConfig.GetConfig(i)

		self.bindData["progress" .. i]:ProgressToValue(v / 120)

		self.bindData["raderText" .. i] = v

		DOTween.To(function ()
			return 0
		end, function (value)
			if self.bindData.radarChart then
				self.bindData.radarChart:SetVertexValue(i - 1, value)
			end
		end, v, v / 100 * 1.2):SetEase(DG.Tweening.Ease.OutQuart)

		local component = self.bindData["radarTitle" .. i]
		local store = gStoreManager:GetStoreGroup("Xuwei6DemensionInfoStore"):GetStoreByWidget(component)

		if store then
			store.icon = cfg.SIcon
			store.nameLabel = cfg.Name
		end

		local info = {
			id = i,
			selected = false,
			cfg = cfg,
			value = v
		}

		table.insert(list, info)
	end

	self._listData = list

	self.bindData.list:SetSimpleList(#list)
end

M.SetBadgeList = function(self)
	local badges = gUrbanAbilityManager:GetTop3BadgeList(self.spiritViewData.SpiritInfo.InfoBadge.Badges)
	local list = {}

	for i, v in pairs(badges) do
		if v.data then
			local info = {
				id = v.data.TemplateId,
				selected = false
			}

			table.insert(list, info)
		end
	end

	self._badgeListData = list

	self.bindData.badgeList:SetSimpleList(#list)
end

M.SetAbilityList = function(self)
	local list = {}

	for i, v in pairs(gUrbanAbilityManager:GetAbilityClassList()) do
		local info = {
			id = i,
			selected = false
		}

		table.insert(list, info)
	end

	self._abilityListData = list

	self.bindData.abilityList:SetSimpleList(#list)
end

M.SetFaction = function(self)
	local fsCfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())
	local agentCfg = LTConfig.AgentConfig.GetConfig(fsCfg.AgentId)

	if agentCfg and agentCfg.Faction <= 0 then
		local factionCfg = LTConfig.FactionConfig.GetConfig(agentCfg.Faction)
		local factionInfo = gClientUtils.GetFactionInfo(agentCfg.Faction)
		self.bindData.factionText = factionCfg.name
		self.bindData.factionType = factionInfo.DispositionLevel - 1
		self.bindData.factionIcon = factionCfg.imageId

		self.bindData.faction:SetActive(true)
	else
		self.bindData.faction:SetActive(false)
	end
end

M.SetFriendShip = function(self)
	local IsUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Favorability)

	if not IsUnlock then
		self.bindData.friendShip:SetActive(false)

		return
	end

	local npcId = gUrbanAbilityManager:GetNpcIdBySpiritId(self.spiritId)

	if not gNpcInteracsUtils:CheckIfCanInteract(npcId) then
		self.bindData.friendShip:SetActive(false)

		return
	end

	if gSpiritManager.CheckIsDefaultSpiritId(self.spiritId) then
		self.bindData.friendShip:SetActive(false)

		return
	end

	self.bindData.friendShip:SetActive(true)

	local store = gStoreManager:GetStoreGroup("CommonFriendshipTemplate"):GetStoreByWidget(self.bindData.friendShip)

	if not store then
		return
	end

	local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcId)
	store.favorAmount = favorInfo.favorAmount
	store.favorLabel = favorInfo.favorLevel
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityDimensionTemplateStore"):GetStoreByWidget(btn)
	store.title.text = data.cfg.Name
	store.num.text = data.value
	store.icon = data.cfg.SIcon
end

M.OnRenderBadgeItem = function(self, btn, index)
	local data = self._badgeListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadge2TemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	store.icon = cfg.Image
	store.name = cfg.Name
	store.quality = cfg.Quality - 1
end

M.OnRenderAbilityItem = function(self, btn, index)
	local data = self._abilityListData[index + 1]
	local store = gStoreManager:GetStoreGroup("AbilitySumTemplateStore"):GetStoreByWidget(btn)
	store.title = LTConfig.UrbanAbilityUrbanAbilityTypeConfig.GetConfig(data.id).Name
	local curExp = 0

	if self.spiritViewData and self.spiritViewData.SpiritInfo.SpiritAbilities then
		curExp = gUrbanAbilityManager:GetAbilityClassCurExp(self.spiritViewData.SpiritInfo.SpiritAbilities, data.id)
	end

	local maxExp = gUrbanAbilityManager:GetAbilityClassMaxExp(data.id)
	local value = curExp / maxExp

	store.progress:ProgressToValue(0)
	store.progress:ProgressToValue(value, value * 0.7, 0, DG.Tweening.Ease.OutQuart)

	store.level = gUrbanAbilityManager:GetAbilityInterval(curExp / maxExp)

	if maxExp < curExp then
		store.isFull = 1
	else
		store.isFull = 0
	end

	store.button.luaClick = self.CreateActionWithArgs(self, "OnAbilitySumTemplateClick", data.id)
end

M.OnRenderOccupationItem = function(self, btn, index)
	local data = self._occupationListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationShortTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	local classCfg = LTConfig.UrbanJobJobClassConfig.GetConfig(cfg.JobClass)

	if classCfg then
		store.text = classCfg.ClassName
	end
end

M.OnRenderJoinTeamItem = function(self, btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTemplateStore"):GetStoreByWidget(btn)
	store.name.text = data.cfg.Name
	store.buff.text = data.cfg.Description
	store.iconId = data.cfg.Image
	store.quality = data.cfg.Quality - 1
end

M.OnDimensionBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_XUWEI6_DEMENSION_DETAIL_PANEL, {
		selectedCardTid = self.urbanAbilityStore:GetCurSpiritTid()
	})
end

M.OnAbilitySumTemplateClick = function(self, id)
	local selectData = {
		pageId = gUrbanAbilityManager.URBANABILITY_PAGE.ATTRIBUTE_DETAIL,
		selectId = id
	}

	self.urbanAbilityStore:SetPageData(gUrbanAbilityManager.URBANABILITY_PAGE.ATTRIBUTE_DETAIL, selectData)
end

M.OnAbilityBtnClick = function(self)
	self.urbanAbilityStore:SetPageData(gUrbanAbilityManager.URBANABILITY_PAGE.ATTRIBUTE_DETAIL)
end

M.OnBadgeBtnClick = function(self)
	self.urbanAbilityStore:SetPageData(gUrbanAbilityManager.URBANABILITY_PAGE.BADGE)
end

M.OnBadgeBtn2Click = function(self)
	self.urbanAbilityStore:SetPageData(gUrbanAbilityManager.URBANABILITY_PAGE.BADGE)
end
