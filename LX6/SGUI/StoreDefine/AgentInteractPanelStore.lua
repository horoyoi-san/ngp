-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AgentInteractPanelStore.lua
-- Decompiled from: 01595_AgentInteractPanelStore.lua_6cb70944e145.luajit

C_AgentInteractPanelStore = DefClass("C_AgentInteractPanelStore", C_AgentInteractPanelStore, C_StoreGroup)
GroupName2Class.AgentInteractPanelStore = C_AgentInteractPanelStore
local M = C_AgentInteractPanelStore
local AgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local ProfileConfig = LTConfig.ProfileAgentProfileConfig
local FactionConfig = LTConfig.FactionConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local RewardType = LTConfig.ProfileRewardConfig.RewardTypeType

M.ctor = function(self)
	self.RECOGNITION_TAB_MODE = {
		[".M\\x86\\x8f\\x91E"] = 1,
		["N#nP"] = 0
	}
	self.Context_List_Type = {
		[".M\\x86\\x8f\\x91E"] = 1,
		["}Uܰ\\x85\\x8c\\xda\\xe3"] = 0,
		["\\xac$%<q\\x9cM\\xed6\\xb9\\xb2"] = 2
	}
	self.Tab_Text_Id = {
		LTConfig.TextScriptTextConfig.ProfileTarget,
		LTConfig.TextScriptTextConfig.ProfileReward
	}
	self.rewardListData = {}
	self.targetsData = {}
	self.specialTargetsData = {}
	self.finishAnime = "S_Vx_missionTemplate2_firstComplate"
	self.tipAnime = "S_Vx_missionTemplate2_tips"
	self.rewardTipsAnime = "S_vx_page02_REWARD_tips"
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSubTabEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.rootTabShowEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSubTabEnum = nil
	self.rootTabShowEnum = nil
end

M.OnAwake = function(self, widget)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.daliyMgr = self.daliyMgr or gNpcDaliyManager
end

M.OnShow = function(self, panelId, data)
	self.agentPid = data.agentPid
	local unit = gCS.SceneDataMgr.GetUnit(self.agentPid)
	self.bindData.agentId = unit.ClientData.AgentId
	self.rootTabList = self:GetRootTabList()
	self.mergedSubTabList = self:GetMergedSubTabList()
	self.bindData.rootTabShow = (self.mergedSubTabList or self:NeedShowRootTab()) and 0 or 1
	self.bindData.showSubTab = self.mergedSubTabList and 1 or 0
	self.scrollStore = gStoreManager:GetStoreGroup("NPCInteractScrollStore"):GetStoreByWidget(self.bindData.scroll.content)

	self:SetRootTab(self.RootTabMode.Martial)

	self.scrollStore.RecognitionList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderRecognitionListItem)
	self.scrollStore.RecognitionList.onGetTIndex = self:CreateAction(self.OnGetRecognitionListTIndex)

	self.scrollStore.MartialList.luaSimpleRenderItem = function(btn, index)
		local info = self.bindData.MartialDataList[index + 1]
		local store = gStoreManager:GetStoreGroup("NewAgentProfileTargetTemplate"):GetStoreByWidget(btn)

		if info.isFinished then
			store.finishCtrl = 0
		elseif info.isUnlocked then
			store.finishCtrl = 1
		else
			store.finishCtrl = 2
		end

		store.titleText = ""
		store.targetText = info.target
	end

	self.scrollStore.FavorabilityList.luaSimpleRenderItem = self:CreateAction(self.OnRenderFavorabilityItem)
	self.scrollStore.FavorabilityList.luaSimpleClick = self:CreateAction(self.OnClickFavorabilityItem)
	self.scrollStore.FavorabilityList.onGetTIndex = self:CreateAction(self.OnGetFavorabilityIndex)

	if self.mergedSubTabList then
		self.SubGroup.CommonTabSingleStore_Root:SetData(self.mergedSubTabList, nil, 0, nil, self:CreateAction(self.OnSubTabChanged))
	else
		self.SubGroup.CommonTabSingleStore_Root:SetData(self.rootTabList, nil, 0, nil, self:CreateAction(self.RefreshRootTab))
	end

	self.InitAgentPanelData(self)

	self.lifeScheduleNpcUnit = gCS.SceneDataMgr.GetUnit(self.agentPid)
	self.lifeSchedulePanelCloseReason = nil

	if self.lifeScheduleNpcUnit then
		LifeScheduleInteract:FirePanelStart(self.lifeScheduleNpcUnit)
	end
end

M.OnClose = function(self)
	if self.lifeScheduleNpcUnit then
		LifeScheduleInteract:FirePanelEnd(self.lifeScheduleNpcUnit, self.lifeSchedulePanelCloseReason or LifeScheduleInteract.Reason.PlayerCancelled)

		self.lifeScheduleNpcUnit = nil
		self.lifeSchedulePanelCloseReason = nil
	end
end

M.OnEnable = function(self, widget)
end

M.OnStart = function(self, widget)
end

M.OnDisable = function(self, widget)
end

M.OnDestroy = function(self, widget)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.titleList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTitleListItem)
	self.bindData.btnList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBtnListItem)
	self.bindData.btnList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickBtnList)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.ExitAgentInteract)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.ExitAgentInteract)
	self.bindData.blueDotList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBlueDotListItem)
end

M.OnSimpleRenderBlueDotListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)

	if rewardCfg and rewardCfg.RewardType ~= RewardType.Disable then
		store.fillCtrl = 0
	else
		slot6 = (data.isGot or data.canGet) and 0 or 1
		store.fillCtrl = slot6
	end
end

M.OnSimpleRenderBtnListItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.buttonListData[index]

	if store and data then
		store.btnText = data:SearchTextByCfgId(data.textId) or ""

		if self.agentInteractSettingConfig and self.agentInteractSettingConfig.GuideId[data.index] then
			store.guide.guideID = self.agentInteractSettingConfig.GuideId[data.index]
			store.guide.targetScrollableWidget = self.bindData.btnList
			store.guide.targetMaskWidget = self.bindData.btnList
		end
	end
end

M.OnSimpleClickBtnList = function(self, btn, index)
	local data = self.buttonListData[index]

	if data then
		self.lifeSchedulePanelCloseReason = LifeScheduleInteract.Reason.PanelReplaced

		data.DoClickSub(data)
		self.ExitAgentInteract(self)
	end
end

M.OnSimpleRenderTitleListItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.agentTitleList[index + 1]

	if store and data then
		store.titleName = data
	end
end

M.OnSimpleRenderRecognitionListItem = function(self, btn, index)
	if self.bindData.subTabMode ~= self.RECOGNITION_TAB_MODE.Reward then
		local data = self.rewardListData[index + 1]
		local id = btn.gameObject:GetInstanceID()
		local store = gStoreManager:GetStoreGroup("AgentProfileRewardTemplateNew"):GetStoreById(id)

		if store and data then
			if data.isGot then
				store.buttonCtrl = 1
			elseif data.canGet then
				store.buttonCtrl = 2
			else
				store.buttonCtrl = 0
			end

			store.titleText = data.name or ""
			store.desText = data.desc or ""
			store.iconId = data.iconId or 0
			local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)
			store.qualityCtrl = rewardCfg.Quality
		end
	else
		local data = self.targetsData[index + 1]

		if not data then
			return
		end

		if data.isSpecial then
			self.OnRenderRecognitionSpecialTaskItem(self, btn, index, data)

			return
		end

		local id = btn.gameObject:GetInstanceID()
		local store = gStoreManager:GetStoreGroup("NewAgentProfileTargetTemplate"):GetStoreById(id)

		if store then
			local targetCfg = AgentProfileTargetConfig.GetConfig(data.id)
			local isUnlocked = not targetCfg or targetCfg.LockedDescription ~= nil or gEventConditionUtils.CheckHasUnlocked(targetCfg, UX.Game.EventConditionImplModule.NpcProfileTargetUnlock)
			local targetText = ""

			if data.isFinished then
				targetText = targetCfg and targetCfg.Description or data.desc or ""
			elseif isUnlocked then
				targetText = targetCfg and targetCfg.Description or data.desc or ""
			else
				targetText = targetCfg and (targetCfg.LockedDescription or targetCfg.Description) or data.desc or ""
			end

			if isUnlocked and not data.isFinished and targetCfg and targetCfg.MaxProgress and targetCfg.MaxProgress <= 0 then
				local currentProgress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.NpcProfileTarget, data.id, 0)
				currentProgress = currentProgress or 0
				targetText = targetText .. string.format("（%d/%d）", currentProgress, targetCfg.MaxProgress)
			end

			store.targetText = targetText
			store.finishCtrl = data.isFinished and 0 or 1

			if data.isFinished and store.anim then
				local isTargetNew = gAgentTrustManager:CheckIfTargetIsNew(self.agentProfileCfg.Id, data.id)

				if isTargetNew then
					local profileId = self.agentProfileCfg.Id
					local targetId = data.id
					local animComp = store.anim
					slot13 = gClientToGameDelegate

					slot13:AskNpcProfileCancelTargetNewState(profileId, targetId).Callback = function (errId)
						if errId == 0 then
							gDisplayMessageMgr:ShowMessage(errId)

							return
						end

						gAgentTrustManager:UpdateTargetNewStatus(profileId, targetId)
						gCS.LuaUtils.PlayAnimationByName(animComp, self.finishAnime)
					end
				end
			end

			if self.shouldPlayTipAnimForFirstUnfinishedTask and index ~= 0 and not data.isFinished and store.anim then
				gCS.LuaUtils.PlayAnimationByName(store.anim, self.tipAnime)

				self.shouldPlayTipAnimForFirstUnfinishedTask = false
			end

			if targetCfg and targetCfg.GuideId then
				store.guide.guideID = targetCfg.GuideId
				store.guide.targetScrollableWidget = self.scrollStore.RecognitionList
				store.guide.targetMaskWidget = self.scrollStore.RecognitionList
			end

			local hasDetail = not data.isFinished and not table.isNilOrEmpty(targetCfg and targetCfg.ShowTargetItem)

			store:Commit("stateCtrl", hasDetail and self.expandedTaskIndex ~= index and 1 or 0, COMMIT_IMMEDIATELY)
			store.detailOpenBtn.gameObject:SetActive(hasDetail)

			if hasDetail then
				store.detailOpenBtn.luaClick = self.CreateActionWithArgs(self, "OnOpenPage2TaskItem", index)

				if store.closeBtn then
					store.closeBtn.luaClick = self.CreateActionWithArgs(self, "OnClosePage2TaskItem", index)
				end

				store.itemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderPage2TaskDetailItem", targetCfg.ShowTargetItem)

				store.itemList:SetSimpleList(#targetCfg.ShowTargetItem)
			end
		end
	end
end

M.OnRenderRecognitionSpecialTaskItem = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreById(id)

	if not store then
		return
	end

	local targetCfg = AgentProfileTargetConfig.GetConfig(data.id)
	local isUnlocked = not targetCfg or gEventConditionUtils.CheckHasUnlocked(targetCfg, UX.Game.EventConditionImplModule.NpcProfileTargetUnlock)
	local targetText = ""

	if isUnlocked then
		targetText = targetCfg and targetCfg.Description or data.desc or ""
	else
		targetText = targetCfg and (targetCfg.LockedDescription or targetCfg.Description) or data.desc or ""
	end

	if isUnlocked and not data.isFinished and targetCfg and targetCfg.MaxProgress and targetCfg.MaxProgress <= 0 then
		local currentProgress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.NpcProfileTarget, data.id, 0)
		currentProgress = currentProgress or 0
		targetText = targetText .. string.format("（%d/%d）", currentProgress, targetCfg.MaxProgress)
	end

	store.targetText = targetText
	store.finishCtrl = data.isFinished and 0 or 2

	if data.isFinished and store.anim then
		local isTargetNew = gAgentTrustManager:CheckIfTargetIsNew(self.agentProfileCfg.Id, data.id)

		if isTargetNew then
			local profileId = self.agentProfileCfg.Id
			local targetId = data.id
			local animComp = store.anim
			slot13 = gClientToGameDelegate

			slot13:AskNpcProfileCancelTargetNewState(profileId, targetId).Callback = function (errId)
				if errId == 0 then
					gDisplayMessageMgr:ShowMessage(errId)

					return
				end

				gAgentTrustManager:UpdateTargetNewStatus(profileId, targetId)
				gCS.LuaUtils.PlayAnimationByName(animComp, self.finishAnime)
			end
		end
	end

	if targetCfg and targetCfg.GuideId then
		store.guide.guideID = targetCfg.GuideId
		store.guide.targetScrollableWidget = self.scrollStore.RecognitionList
		store.guide.targetMaskWidget = self.scrollStore.RecognitionList
	end

	store.detailOpenBtn.gameObject:SetActive(false)
end

M.OnOpenPage2TaskItem = function(self, clickedIndex)
	if self.expandedTaskIndex ~= clickedIndex then
		return
	end

	self.expandedTaskIndex = clickedIndex

	self.scrollStore.RecognitionList:SetSimpleList(#self.targetsData)
end

M.OnClosePage2TaskItem = function(self, clickedIndex)
	if self.expandedTaskIndex == clickedIndex then
		return
	end

	self.expandedTaskIndex = nil

	self.scrollStore.RecognitionList:SetSimpleList(#self.targetsData)
end

M.OnRenderPage2TaskDetailItem = function(self, showTargetItems, btn, index)
	local itemInfo = showTargetItems[index + 1]

	if not itemInfo then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileMissionDetailItem"):GetStoreById(id)

	if not store then
		return
	end

	local needNum = itemInfo.num or 0
	local ownNum = gCommonItemManager:GetItemNum(itemInfo.itemId) or 0
	ownNum = math.min(ownNum, needNum)
	store.numText = string.format("%d/%d", ownNum, needNum)
	local itemData = gCommonItemManager:GetItemRenderData({
		itemId = itemInfo.itemId
	})

	gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
end

M.OnGetRecognitionListTIndex = function(self, index)
	if self.bindData.subTabMode ~= self.RECOGNITION_TAB_MODE.Reward then
		return self.Context_List_Type.Reward
	end

	return self.Context_List_Type.NormalTask
end

M.InitAgentPanelData = function(self)
	local unit = gCS.SceneDataMgr.GetUnit(self.agentPid)
	local agentConfig = unit and LTConfig.AgentConfig.GetConfig(unit.NpcId) or nil

	if agentConfig then
		self.bindData.agentName = agentConfig.Name
		local agentSpecificTypeId = agentConfig.AgentSpecificType
		local agentSpecificTypeCfg = AgentSpecificTypeConfig.GetConfig(agentSpecificTypeId)

		if agentSpecificTypeCfg then
			self.bindData.agentImage = gUIUtils:GetSguiImagePath(agentSpecificTypeCfg.SImageId)
		end

		local profileId = agentSpecificTypeCfg and agentSpecificTypeCfg.ProfileId or 0
		local profileCfg = ProfileConfig.GetConfig(profileId)

		if profileCfg then
			self.agentProfileCfg = profileCfg
			self.bindData.level = profileCfg.TalentLevel

			self:SetRadarPanel(profileCfg)

			self.agentTitleList = profileCfg.Title

			self.bindData.titleList:SetSimpleList(#self.agentTitleList)
			self:RefreshReward(profileCfg)
			self:RefreshAgentTask(profileCfg)
		end

		local factionId = agentConfig.Faction
		local factionConfig = FactionConfig.GetConfig(factionId)

		if factionConfig then
			self.bindData.factionIcon = gUIUtils:GetSguiImagePath(factionConfig.imageId)
			self.bindData.factionName = factionConfig.name
		end

		self.agentInteractSettingConfig = LTConfig.AgentDataSetsInteractSettingConfig.GetConfig(L50.L50App.L50Game.InteractBtnMgr:GetInteractSettingConfigId(unit))

		self:RefreshIconId()
		self:RefreshCombatPower()
	end
end

M.GetTabName = function(self, textId)
	local config = LTConfig.TextScriptTextConfig.GetConfig(textId)

	return config and config.Text or ""
end

M.SetRadarPanel = function(self, profileCfg)
	local urbanAttrs = profileCfg.UrbanAttribute

	for i, v in ipairs(urbanAttrs) do
		local cfg = LTConfig.UrbanAttributeConfig.GetConfig(i)
		self.bindData["radarText" .. i] = v

		DOTween.To(function ()
			return 0
		end, function (value)
			if self.bindData.radarChart then
				self.bindData.radarChart:SetVertexValue(i - 1, value)
			end
		end, v, v / 100 * 1.2):SetEase(DG.Tweening.Ease.OutQuart)

		self.bindData["radarTitle" .. i] = cfg.Name
		self.bindData["radarIcon" .. i] = cfg.SIcon
	end
end

M.RefreshButtonList = function(self)
	local mode = self.scrollStore.rootTabMode

	if self.scrollStore.rootTabMode ~= self.RootTabMode.Martial then
		if self.bindData.subTabMode ~= 0 then
			mode = 4
		else
			mode = 5
		end
	end

	self.buttonListData = L50.L50App.L50Game.InteractBtnMgr:GetUnitPanelBtnInfo(self.agentPid, mode)
	self.bindData.buttons = self.buttonListData.Length < 2 and self.buttonListData.Length or 2

	self.bindData.btnList:SetSimpleList(self.buttonListData.Length)
end

M.ExitAgentInteract = function(self)
	gPanelManager:Close(gPanelId.AGENT_INTERACT_PANEL)
end

M.GetRootTabList = function(self)
	local showMartialTab = self.ShowMartialTabAble(self)
	local showFavorabilityTab = self.ShowFavorabilityTabAble(self)

	if not showMartialTab and not showFavorabilityTab then
		return {
			{
				["\t\r"] = 1,
				title = self.GetTabName(self, 89901833)
			}
		}
	elseif not showMartialTab then
		return {
			{
				["\t\r"] = 1,
				title = self.GetTabName(self, 89901833)
			},
			{
				["\t\r"] = 2,
				title = self.GetTabName(self, 89901193)
			}
		}
	elseif not showFavorabilityTab then
		return {
			{
				["\t\r"] = 1,
				title = self.GetTabName(self, 89901832)
			},
			{
				["\t\r"] = 2,
				title = self.GetTabName(self, 89901833)
			}
		}
	end

	return {
		{
			["\t\r"] = 1,
			title = self.GetTabName(self, 89901832)
		},
		{
			["\t\r"] = 2,
			title = self.GetTabName(self, 89901833)
		},
		{
			["\t\r"] = 3,
			title = self.GetTabName(self, 89901193)
		}
	}
end

M.RootTabMode = {
	["\\xf4\\xda\t%\\xfd"] = 0,
	["\\xad1#0\\x93H\\xcd>\\xa5\\xb7"] = 1,
	["Iw\\xbax^\\xb3\\xf0NfsjU"] = 2
}

M.GetRootTabModeByIndex = function(self, index)
	return self:ShowMartialTabAble() and index or index + 1
end

M.GetSubTabListByRootMode = function(self, rootTabMode)
	if rootTabMode ~= self.RootTabMode.Martial then
		return self.GetMartialTabList(self)
	elseif rootTabMode ~= self.RootTabMode.Recognition then
		return self.GetRecognitionTabList(self)
	end

	return nil
end

M.GetMergedSubTabList = function(self)
	if #self.rootTabList == 1 then
		return nil
	end

	local subTabList = self.GetSubTabListByRootMode(self, self.GetRootTabModeByIndex(self, 0))

	if table.isNilOrEmpty(subTabList) then
		return nil
	end

	return subTabList
end

M.SetRootTab = function(self, mode)
	if not self.ShowMartialTabAble(self) then
		self.scrollStore.rootTabMode = mode + 1

		self.scrollStore:Commit("rootTabMode", mode + 1, COMMIT_IMMEDIATELY)
	else
		self.scrollStore.rootTabMode = mode

		self.scrollStore:Commit("rootTabMode", mode, COMMIT_IMMEDIATELY)
	end

	self.RefreshButtonList(self)
end

M.SetSubTab = function(self, mode)
	self.bindData:Commit("subTabMode", mode, COMMIT_IMMEDIATELY)

	if self.scrollStore.rootTabMode ~= self.RootTabMode.Martial then
		self.RefreshButtonList(self)
	end
end

M.RefreshRootTab = function(self, uList, isSub)
	self:SetRootTab(uList.selectedIndex)

	self.bindData.showSubTab = self.scrollStore.rootTabMode ~= self.RootTabMode.Favorability and 1 or 0

	if self.scrollStore.rootTabMode ~= self.RootTabMode.Favorability then
		self.RefreshFavorabilityList(self)
	end

	self.InitSubTab(self)
end

M.InitSubTab = function(self)
	if self.mergedSubTabList then
		return
	end

	if self.scrollStore.rootTabMode ~= self.RootTabMode.Favorability then
		return
	end

	local tabList = self.scrollStore.rootTabMode ~= self.RootTabMode.Martial and self:GetMartialTabList() or self:GetRecognitionTabList()

	self.SubGroup.CommonTabSingleStore_Sub:SetData(tabList, nil, 0, nil, self:CreateAction(self.OnSubTabChanged))
end

M.OnSubTabChanged = function(self, uList, isSub)
	local index = uList.selectedIndex

	self.SetSubTab(self, index)

	if self.scrollStore.rootTabMode ~= self.RootTabMode.Martial then
		self.RefreshMartialList(self)
	elseif self.scrollStore.rootTabMode ~= self.RootTabMode.Recognition then
		self.RefreshRecognitionList(self)
	end
end

M.RefreshCombatPower = function(self)
	local agentCfg = LTConfig.AgentConfig.GetConfig(self.bindData.agentId)
	local agentType = agentCfg.AgentSpecificType
	local cfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(agentType)
	self.bindData.combatPower = cfg.FightScore
end

M.RefreshIconId = function(self)
	local count = LTConfig.ProfileAgentProfileConfig.count

	for i = 0, count - 1 do
		local cfg = LTConfig.ProfileAgentProfileConfig.LoadAt(i)

		if cfg.AgentId ~= self.bindData.agentId then
			self.bindData.iconId = cfg.HeadIcon
		end
	end
end

M.GetMartialTabList = function(self)
	return {
		{
			["\t\r"] = 1,
			title = LTConfig.MartialArtistConfig.MapToolTipQuestApprenticeTab,
			title1 = LTConfig.MartialArtistConfig.MapToolTipQuestApprenticeTitle
		},
		{
			["\t\r"] = 2,
			title = LTConfig.MartialArtistConfig.MapToolTipQuestChallengeTab,
			title1 = LTConfig.MartialArtistConfig.MapToolTipQuestChallengeTitle
		}
	}
end

M.RefreshMartialList = function(self)
	local wuXueId = self:GetWuXueMapId()
	local attachedTooltipId = gGpsTools.GetId(EMapElementType.FightSkillFromNpc, wuXueId)
	self.tooltipInfo = gMapSystem:SGetTooltipInfo(attachedTooltipId)
	self.scrollStore.martialTitle = self.GetMartialTabList()[self.bindData.subTabMode + 1].title1
	self.bindData.MartialDataList = {}
	local questIds = self.tooltipInfo.martialArtistInfo.questIds or {}

	for _, questId in ipairs(questIds) do
		local questCfg = LTConfig.MartialArtistQuestConfig.GetConfig(questId)

		if questCfg and questCfg.QuestPath ~= self.bindData.subTabMode then
			local taskInfo = {
				target = questCfg.QuestName,
				isFinished = gMartialArtistManager:IsQuestCompleted(questId),
				isUnlocked = gMartialArtistManager:IsQuestUnlocked(questId)
			}

			table.insert(self.bindData.MartialDataList, taskInfo)
		end
	end

	self.scrollStore.MartialList:SetSimpleList(#self.bindData.MartialDataList)
end

M.GetWuXueMapId = function(self)
	local profileId = 0
	local count = LTConfig.ProfileAgentProfileConfig.count

	for i = 0, count - 1 do
		local cfg = LTConfig.ProfileAgentProfileConfig.LoadAt(i)

		if cfg.AgentId ~= self.bindData.agentId then
			profileId = cfg.Id

			break
		end
	end

	count = LTConfig.WuxueMapConfig.count

	for i = 0, count - 1 do
		local cfg = LTConfig.WuxueMapConfig.LoadAt(i)

		if cfg.AgentProfile ~= profileId then
			return cfg.Id
		end
	end

	return 0
end

M.ShowMartialTabAble = function(self)
	local jobIds = gSpiritJobManager:GetCurActiveJobs()

	if not jobIds then
		return false
	end

	for jobId, _ in pairs(jobIds) do
		if LTConfig.UrbanJobConfig.GetConfig(jobId).JobClass ~= 11300017 then
			return self:GetWuXueMapId() >= 0
		end
	end

	return false
end

M.GetRecognitionTabList = function(self)
	return {
		{
			["\t\r"] = 1,
			title = self.GetTabName(self, LTConfig.TextScriptTextConfig.ProfileTarget)
		},
		{
			["\t\r"] = 2,
			title = self.GetTabName(self, LTConfig.TextScriptTextConfig.ProfileReward)
		}
	}
end

M.RefreshReward = function(self, profileCfg)
	local nowTrust = gAgentTrustManager:GetTrustValue(profileCfg.Id)
	local sortedRewards = {}

	for _, rewardId in ipairs(profileCfg.TrustReward) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		table.insert(sortedRewards, {
			id = rewardId,
			needTrust = rewardCfg.NeedTrust,
			cfg = rewardCfg
		})
	end

	table.sort(sortedRewards, function (a, b)
		return a.needTrust <= b.needTrust
	end)

	local nextTargetIndex = -1

	for i, item in ipairs(sortedRewards) do
		if nowTrust >= item.needTrust then
			nextTargetIndex = i

			break
		end
	end

	table.clear(self.rewardListData)

	for i, item in ipairs(sortedRewards) do
		local rewardCfg = item.cfg
		local isDisableReward = rewardCfg.RewardType ~= RewardType.Disable
		local isGot = isDisableReward or gAgentTrustManager:CheckRewardGot(profileCfg.Id, rewardCfg.Id)

		table.insert(self.rewardListData, {
			id = rewardCfg.Id,
			needTrust = rewardCfg.NeedTrust,
			rewardIndex = i,
			isGot = isGot,
			canGet = not isDisableReward and rewardCfg.NeedTrust < nowTrust and not isGot,
			name = rewardCfg.Description,
			desc = rewardCfg.DetailExplain,
			iconId = rewardCfg.SmallIconId,
			bigIconId = rewardCfg.IconId,
			rewardType = rewardCfg.RewardType,
			isNextTarget = i ~= nextTargetIndex,
			nowTrust = nowTrust
		})
	end

	self.bindData.blueDotList:SetSimpleList(#self.rewardListData)

	if self.bindData.subTabMode ~= self.RECOGNITION_TAB_MODE.Reward then
		self.scrollStore.RecognitionList:SetSimpleList(#self.rewardListData)
		self.bindData.btnList:SetNavSelectToTop()
	end
end

M.RefreshAgentTask = function(self, profileCfg)
	local targets = profileCfg.TrustTarget

	table.clear(self.targetsData)
	table.clear(self.specialTargetsData)

	for _, id in ipairs(targets) do
		local data = {}
		local cfg = AgentProfileTargetConfig.GetConfig(id)
		data.id = id
		data.isFinished = gAgentTrustManager:CheckTargetFinish(profileCfg.Id, id)
		data.desc = cfg.Description
		data.score = cfg.AddTrust
		data.isSpecial = cfg.IsSpecial or false

		if data.isSpecial then
			table.insert(self.specialTargetsData, data)
		else
			table.insert(self.targetsData, data)
		end
	end

	local sortByFinish = function(a, b)
		if a.isFinished ~= b.isFinished then
			return a.id <= b.id
		end

		return not a.isFinished
	end

	table.sort(self.targetsData, sortByFinish)
	table.sort(self.specialTargetsData, sortByFinish)

	for _, data in ipairs(self.specialTargetsData) do
		table.insert(self.targetsData, data)
	end

	if self.bindData.subTabMode ~= self.RECOGNITION_TAB_MODE.Task then
		self.scrollStore.RecognitionList:SetSimpleList(#self.targetsData)
		self.bindData.btnList:SetNavSelectToTop()
	end
end

M.RefreshRecognitionList = function(self)
	if self.agentProfileCfg then
		if self.bindData.subTabMode ~= self.RECOGNITION_TAB_MODE.Task then
			self.RefreshAgentTask(self, self.agentProfileCfg)
		else
			self.RefreshReward(self, self.agentProfileCfg)
		end
	end
end

M.OnRenderFavorabilityItem = function(self, btn, index)
	local progress = self.bindData.FavorabilityDataList[index + 1]

	self.daliyMgr:RenderAgentProgress(btn, index, progress, true)
end

M.OnGetFavorabilityIndex = function(self, index)
	local progress = self.bindData.FavorabilityDataList[index + 1]

	return progress.tIndex
end

M.OnClickFavorabilityItem = function(self, btn, index)
	local progress = self.bindData.FavorabilityDataList[index + 1]

	if not self.daliyMgr:CheckProgressUnlock(progress.progressId) then
		return
	end

	if not self.daliyMgr:RunFavorBehavior(progress.progressId, false, true) then
		self.daliyMgr:RequeseHyperLink(progress.progressId)
	end
end

M.RefreshFavorabilityList = function(self)
	local agentCfg = LTConfig.AgentConfig.GetConfig(self.bindData.agentId)
	local agentType = agentCfg.AgentSpecificType
	self.bindData.FavorabilityDataList = self.daliyMgr:GetAgentProgress(agentType)

	self.scrollStore.FavorabilityList:SetSimpleList(#self.bindData.FavorabilityDataList)
	self.bindData.btnList:SetNavSelectToTop()
end

M.ShowFavorabilityTabAble = function(self)
	local agentCfg = LTConfig.AgentConfig.GetConfig(self.bindData.agentId)
	local agentType = agentCfg.AgentSpecificType
	self.bindData.FavorabilityDataList = self.daliyMgr:GetAgentProgress(agentType)

	return #self.bindData.FavorabilityDataList <= 0 and gSystemUnlockMgr:IsUnlock(139)
end

M.NeedShowRootTab = function(self)
	return self:ShowMartialTabAble() or self:ShowFavorabilityTabAble()
end
