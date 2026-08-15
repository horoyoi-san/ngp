local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileCharacteristicConfig = LTConfig.ProfileCharacteristicConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local ProfileConfig = LTConfig.ProfileConfig
local AgentConfig = LTConfig.AgentConfig
local FactionConfig = LTConfig.FactionConfig
local RewardType = LTConfig.ProfileRewardConfig.RewardTypeType
local ConsumableConfig = LTConfig.ConsumableConfig
C_AgentProfilePanelStore = DefClass("C_AgentProfilePanelStore", C_AgentProfilePanelStore, C_StoreGroup)
GroupName2Class.AgentProfilePanelStore = C_AgentProfilePanelStore
local M = C_AgentProfilePanelStore
M.RewardItemType = {
	Weapon = 0,
	Items = 2,
	Character = 1,
	Car = 3
}

function M:ctor()
	self:GenMessageEvents()
end

function M:DefineAllVariables()
	self.recruitableAgents = {}
	self.unrecruitableAgents = {}
	self.profileShowAreaStore = nil
	self.profileDetailAreaStore = nil
	self.profileRewardShowAreaStore = nil
	self.selectAgentProfileId = nil
	self.rewardListData = {}
	self.featuresData = {}
	self.selectedRewardData = nil
	self.selectedRewardIndex = -1
	self.nowFocusIndex = nil
	self.newAnime = "S_Vx_CharacterTemplate_Reddot_open"
	self.totalProgressWeight = 0
	self.totalProgressRewardListData = {}
	self.baseMap = nil
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
	self:CalculateTotalProgressWeight()
end

function M:OnShow()
	self.bindData.showDetailsCtrl = 0
	self.bindData.agentStateCtrl = 1
	self.bindData.totalProgressCtrl = 0
	self.bindData.tipActive = false

	self.bindData:EnableImmediatelyCommit(true)
	self:RefreshAgentSelect()
	self:RefreshTotalProgress()
	self:CheckHasCompletionRewardCanGet()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()

	if self.baseMap then
		gBaseMapMgr:Release(self.baseMap)

		self.baseMap = nil
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self:CreateAction("RefreshRedPoint")
	}
end

function M:RegisterWidget()
	self.bindData.locationBtn.luaClick = self:CreateAction("OnClickLocationBtn")
	self.bindData.locationBtn2.luaClick = self:CreateAction("OnClickLocationBtn")
	self.bindData.rewardShowBtn.luaClick = self:CreateAction("OnClickRewardShowBtn")
	self.bindData.receiveRewardBtn.luaClick = self:CreateAction("OnClickReceiveRewardBtn")
	self.bindData.specialRewardBtn.luaClick = self:CreateAction("OnClickSpecialRewardBtn")
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.totalProgressBtn.luaClick = self:CreateAction("OnClickTotalProgressBtn")
	self.bindData.closeTotalProgressBtn.luaClick = self:CreateAction("OnClickCloseTotalProgressBtn")
	self.bindData.targetList.luaSimpleRenderItem = self:CreateAction("OnRenderTargetListItem")
	self.bindData.targetList.luaSimpleClick = self:CreateAction("OnClickTargetList")
	self.bindData.targetList.onGetTIndex = self:CreateAction("OnGetTargetListTIndex")
	self.bindData.rewardList.luaSimpleClick = self:CreateAction("OnClickRewardList")
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction("OnRenderRewardListItem")
	self.bindData.rewardList.onGetTIndex = self:CreateAction("OnGetRewardListTIndex")
	self.bindData.totalProgressList.luaSimpleRenderItem = self:CreateAction("OnRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleClick = self:CreateAction("OnClickTotalProgressRewardItem")
	self.bindData.totalProgressList.onGetTIndex = self:CreateAction("OnGetTotalProgressRewardTIndex")
	self.bindData.showScroll.luaInitContent = self:CreateAction("OnShowScrollInitContent")
	self.bindData.detailScroll.luaInitContent = self:CreateAction("OnDetailScrollInitContent")
	self.bindData.gestureListener.onZoom = self:CreateAction("OnGestureZoom")
end

function M:OnGestureZoom(zoom)
	if not self.selectAgentProfileId or not self.profileShowAreaStore then
		return
	end

	local allAgents = {}

	for _, agent in ipairs(self.recruitableAgents) do
		table.insert(allAgents, {
			isRecruitable = true,
			data = agent
		})
	end

	for _, agent in ipairs(self.unrecruitableAgents) do
		table.insert(allAgents, {
			isRecruitable = false,
			data = agent
		})
	end

	local currentIndex = -1

	for i, item in ipairs(allAgents) do
		if item.data.id == self.selectAgentProfileId then
			currentIndex = i

			break
		end
	end

	if currentIndex == -1 or #allAgents == 0 then
		return
	end

	local newIndex = zoom < 0 and currentIndex % #allAgents + 1 or (currentIndex - 2) % #allAgents + 1
	local newAgent = allAgents[newIndex]
	self.selectAgentProfileId = newAgent.data.id

	if newAgent.isRecruitable then
		self.profileShowAreaStore.unrecruitableList:DeselectAll()

		local index = self:GetListIndexByProfileId(self.recruitableAgents, newAgent.data.id)

		if index ~= -1 then
			self.profileShowAreaStore.recruitableList:SelectItem(index, true)
		end
	else
		self.profileShowAreaStore.recruitableList:DeselectAll()

		local index = self:GetListIndexByProfileId(self.unrecruitableAgents, newAgent.data.id)

		if index ~= -1 then
			self.profileShowAreaStore.unrecruitableList:SelectItem(index, true)
		end
	end

	self:RefreshAgentSelect()
end

function M:GetScheduleInfo(agentProfileId)
	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId == 0 then
		return false
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)
	local scheduleInfo = gNpcDaliyManager:GetCurrentSchedule(agentCfg.AgentSpecificType)

	return scheduleInfo
end

function M:OnClickLocationBtn()
	if not self.selectAgentProfileId or not gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId) then
		return
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local agentType = AgentConfig.GetConfig(config.AgentId).AgentSpecificType
	local currentSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)
	local agentTypeNow = AgentConfig.GetConfig(currentSpiritCfg.AgentId).AgentSpecificType

	if agentType == agentTypeNow then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotFindPosition)

		return
	end

	local timeTableInfo = gNpcDaliyManager.NpcTimeTableInfos[agentType]

	if timeTableInfo and timeTableInfo.CurrentSpoonAgentId and timeTableInfo.CurrentSpoonAgentId ~= 0 and timeTableInfo.SpoonPosition then
		local spoonPos = timeTableInfo.SpoonPosition
		local worldPos = Vector3.New(spoonPos.X, spoonPos.Y, spoonPos.Z)
		local canOpenMap = gMapSystem:Tmp_CanOpenBigMap(gMapSystem.lastRaidId, gMapSystem.lastIndoorId)

		if not canOpenMap then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotFindPosition)
		else
			gMapUtils:CheckRaidCanOpenMap({
				MapRaidId = LTConfig.RaidConfig.WorldMap,
				autoPinWorldPos = worldPos
			})
			gPanelManager:Close(self.m_Id)
		end

		return
	end

	local scheduleInfo = self:GetScheduleInfo(self.selectAgentProfileId)
	local success = scheduleInfo and gMapGpsCmd:TryOpenBigMapAndFocusSelectFavorNpc(scheduleInfo.ActivityId) or false

	if success then
		gPanelManager:Close(self.m_Id)
	else
		local name = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(agentType).Name
		local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

		gDisplayMessageMgr:ShowMessageContent(message)
	end
end

function M:OnClickRewardShowBtn()
	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)

	if not isAcquainted then
		return
	end

	self.bindData.showDetailsCtrl = 1 - self.bindData.showDetailsCtrl
	self.selectedRewardIndex = -1
	self.selectedRewardData = nil
	self.bindData.rewardIconBig = 0
	self.bindData.rewardName = ""
	self.bindData.rewardNum = ""
	self.bindData.receivedCtrl = 0

	if self.bindData.showDetailsCtrl == 0 then
		self:SetNowSelectedIndexFocus()
	else
		self:AutoSelectFirstReward()
	end
end

function M:OnClickReceiveRewardBtn()
	local data = self.selectedRewardData

	if not data or not data.canGet then
		return
	end

	if data.rewardType == RewardType.UI then
		self:ShowRewardPreviewWindow(data)
	elseif data.rewardType == RewardType.InPerson then
		self:OnClickLocationBtn()
	end
end

function M:ShowRewardPreviewWindow(data)
	local rewardConfig = AgentProfileRewardConfig.GetConfig(data.id)

	if not rewardConfig then
		return
	end

	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(rewardConfig.DropId, 1)
	local previewMaterials = {}

	for _, item in ipairs(fakeItems) do
		table.insert(previewMaterials, {
			ItemId = item.Id,
			Count = item.Count
		})
	end

	local function cb()
		self:RefreshReward()

		self.bindData.receivedCtrl = 1

		gDropManager:ShowRewardWindow({
			ExtraRewardParam = 2,
			Param = previewMaterials
		})
	end

	gAgentTrustManager:TakeProfileTrustReward(self.selectAgentProfileId, data.id, cb)
end

function M:OnClickSpecialRewardBtn()
	if not self.selectAgentProfileId then
		return
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local maxTrust = config.MaxTrust
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(config.MaxTrustReward, 1)
	local previewMaterials = {}

	for _, item in ipairs(fakeItems) do
		table.insert(previewMaterials, {
			ItemId = item.Id,
			Count = item.Count
		})
	end

	if nowTrust and maxTrust <= nowTrust then
		local function cb()
			gDropManager:ShowRewardWindow({
				ExtraRewardParam = 2,
				Param = previewMaterials
			})
		end

		gClientToGameDelegate:AskTakeNpcProfileMaxTrustReward(self.selectAgentProfileId).Callback = function (errId)
			if errId ~= 0 then
				print_warn("AskTakeNpcProfileMaxTrustReward 请求失败，err = " .. gCS.Error.GetNameById(errId))

				return
			end

			gAgentTrustManager:UpdateMaxTrustRewardGot(self.selectAgentProfileId)
			self:RefreshSpecialRewardBtnState()

			if cb then
				cb()
			end
		end
	end
end

function M:RefreshSpecialRewardBtnState()
	if not self.selectAgentProfileId then
		return
	end

	local isTafei = self.selectAgentProfileId == 38000002
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local maxTrust = config.MaxTrust
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	local isMaxTrustRewardGot = gAgentTrustManager:CheckMaxTrustRewardGot(self.selectAgentProfileId)

	if isTafei then
		self.bindData.specialRewardBtn.gameObject:SetActive(false)
	elseif nowTrust and maxTrust <= nowTrust then
		if isMaxTrustRewardGot then
			self.bindData.specialRewardBtn.gameObject:SetActive(false)
		else
			self.bindData.specialRewardBtn.gameObject:SetActive(true)
		end
	else
		self.bindData.specialRewardBtn.gameObject:SetActive(false)
	end
end

function M:OnExitClick()
	if self.bindData.totalProgressCtrl == 1 then
		self.bindData.totalProgressCtrl = 0

		return
	end

	if self.bindData.showDetailsCtrl == 1 then
		self.bindData.showDetailsCtrl = 1 - self.bindData.showDetailsCtrl

		self:SetNowSelectedIndexFocus()

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnClickTotalProgressBtn()
	self.bindData.totalProgressCtrl = 1
	self.bindData.tipActive = false
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil

	self:RefreshTotalProgressRewardList()
end

function M:OnClickCloseTotalProgressBtn()
	self.bindData.totalProgressCtrl = 0
	self.bindData.tipActive = false
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
end

function M:SetNowSelectedIndexFocus()
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return
	end

	local ifRecruitable = gAgentTrustManager:GetIfRecruitable(self.selectAgentProfileId)
	local list = ifRecruitable and self.profileShowAreaStore.recruitableList or self.profileShowAreaStore.unrecruitableList
	local dataArray = ifRecruitable and self.recruitableAgents or self.unrecruitableAgents
	local index = self:GetListIndexByProfileId(dataArray, self.selectAgentProfileId)

	if index ~= -1 then
		local _, btn = list:TryGetChildAt(index, nil)

		btn:Navigate(btn)
	else
		self.profileShowAreaStore.recruitableList:SetNavSelectToTop()
	end
end

function M:GetListIndexByProfileId(dataArray, profileId)
	for i, data in ipairs(dataArray) do
		if data and data.id == profileId then
			return i - 1
		end
	end

	return -1
end

function M:OnRenderFeatureListItem(btn, index)
	local data = self.featuresData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentFeatureTemplate"):GetStoreById(id)

	if store then
		store.iconId = data.icon
		store.nameText = data.name
	end
end

function M:OnRenderFeatureDetailListItem(btn, index)
	local data = self.featuresData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentFeatureDetailTemplate"):GetStoreById(id)

	if store then
		store.iconId = data.icon
		store.nameText = data.name
		store.descText = data.desc
	end
end

function M:OnRenderTargetListItem(btn, index)
	local data = self.targetsData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()

	if data.isFinished then
		local store = gStoreManager:GetStoreGroup("AgentProfileTargetTemplate"):GetStoreById(id)

		if store then
			store.targetText = data.desc
			store.stateCtrl = 0
		end
	else
		local store = gStoreManager:GetStoreGroup("AgentProfileTargetBigTemplate"):GetStoreById(id)

		if store then
			store.targetText = data.desc
			store.addText = "+" .. tostring(data.score)
		end
	end
end

function M:OnClickTargetList(btn, index)
	return
end

function M:OnClickRewardList(btn, index)
	local data = self.rewardListData[index + 1]

	if not data or data.tIndex == 1 then
		return
	end

	self.selectedRewardIndex = index
	self.selectedRewardData = data
	self.bindData.rewardIconBig = data.rewardIconIdBig
	self.bindData.rewardName = data.desc or ""
	local rewardCount = 0
	local rewardConfig = AgentProfileRewardConfig.GetConfig(data.id)

	if rewardConfig and rewardConfig.DropId and rewardConfig.DropId > 0 then
		local dropConfig = LTConfig.DropConfig.GetConfig(rewardConfig.DropId)

		if dropConfig then
			if dropConfig.Money and dropConfig.Money > 0 then
				rewardCount = dropConfig.Money
			elseif dropConfig.Item1 and dropConfig.Item1[1] then
				rewardCount = dropConfig.Item1[1].count or 0
			end
		end
	end

	if rewardCount <= 1 then
		self.bindData.rewardNum = ""
	else
		self.bindData.rewardNum = "X" .. tostring(rewardCount)
	end

	self.bindData.rewardTypeCtrl = data.itemTypeCtrl or self.RewardItemType.Items
	local isReceived = data.isTrustEnough and not data.canGet
	self.bindData.receivedCtrl = isReceived and 1 or 0

	self.bindData.rewardList:SetSimpleList(#self.rewardListData)
end

function M:OnRenderRewardListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data or data.tIndex == 1 then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileRewardTemplate"):GetStoreById(id)

	if store then
		store.scoreText = data.need
		store.numText = tostring(data.need or 0)
		local checkIconId = 0
		local uncheckIconId = 0
		local lockIconId = 0
		btn.interactable = true

		if data.rewardType == RewardType.UI then
			checkIconId = ProfileConfig.UIRewardIconId[1]
			uncheckIconId = ProfileConfig.UIRewardIconId[2]
			lockIconId = ProfileConfig.UIRewardIconId[3]
		elseif data.rewardType == RewardType.InPerson then
			checkIconId = ProfileConfig.InPersonRewardIconId[1]
			uncheckIconId = ProfileConfig.InPersonRewardIconId[2]
			lockIconId = ProfileConfig.InPersonRewardIconId[3]
		elseif data.rewardType == RewardType.Disable then
			store.checkIconId = ProfileConfig.DisableRewardIconId
			store.uncheckIconId = ProfileConfig.DisableRewardIconId
			store.lockIconId = ProfileConfig.DisableRewardIconId
			btn.interactable = false
			store.stateCtrl = 0
		end

		store.checkIconId = checkIconId
		store.uncheckIconId = uncheckIconId
		store.lockIconId = lockIconId
		local isSelected = self.selectedRewardIndex == index
		store.rewardTypeCtrl = 0

		if data.isTrustEnough and data.canGet then
			store.stateCtrl = 1
			store.rewardTypeCtrl = isSelected and 2 or 0
			store.rewardReceiveText = LTConfig.TextScriptTextConfig.GetConfig(89901284).Text
		elseif data.isTrustEnough then
			store.stateCtrl = 0
			store.rewardTypeCtrl = 1
			store.rewardReceiveText = LTConfig.TextScriptTextConfig.GetConfig(89901285).Text
		else
			store.stateCtrl = 2
			store.rewardTypeCtrl = isSelected and 2 or 0
			store.rewardReceiveText = LTConfig.TextScriptTextConfig.GetConfig(89901286).Text
		end

		store.rewardNameText = data.desc
		store.rewardIconId = data.rewardIconIdSmall
	end
end

function M:OnDetailScrollInitContent(widget)
	self.profileDetailAreaStore = gStoreManager:GetStoreGroup("AgentProfileDetailContentTemplate"):GetStoreByWidget(widget)
	self.profileDetailAreaStore.featureList.luaSimpleRenderItem = self:CreateAction("OnRenderFeatureListItem")
	self.profileDetailAreaStore.featureList.onGetTIndex = self:CreateAction("OnGetFeatureListTIndex")

	function self.profileDetailAreaStore.featureList.luaLayoutSet()
		self.profileDetailAreaStore.featureBtn:SetSizeY(self.profileDetailAreaStore.featureList.rectTransform.rect.height + 50)
		self.profileDetailAreaStore.layoutBox:ForceRebuildLayoutImmediate()
	end

	self.profileDetailAreaStore.featureDetailList.luaSimpleRenderItem = self:CreateAction("OnRenderFeatureDetailListItem")
	self.profileDetailAreaStore.featureDetailList.onGetTIndex = self:CreateAction("OnGetFeatureDetailListTIndex")

	function self.profileDetailAreaStore.featureDetailList.luaLayoutSet()
		self.profileDetailAreaStore.featureBtn:SetSizeY(self.profileDetailAreaStore.featureDetailList.rectTransform.rect.height + 80)
		self.profileDetailAreaStore.layoutBox:ForceRebuildLayoutImmediate()
	end

	function self.profileDetailAreaStore.featureBtn.luaClick()
		if not self.profileDetailAreaStore.detailCtrl then
			self.profileDetailAreaStore.detailCtrl = 1

			return
		end

		self.profileDetailAreaStore.detailCtrl = 1 - self.profileDetailAreaStore.detailCtrl
	end

	function self.profileDetailAreaStore.radarBtn.luaClick()
		if not self.profileDetailAreaStore.showCtrl then
			self.profileDetailAreaStore.showCtrl = 1

			return
		end

		self.profileDetailAreaStore.showCtrl = 1 - self.profileDetailAreaStore.showCtrl
	end
end

function M:OnShowScrollInitContent(widget)
	self:InitProfileData()

	self.profileShowAreaStore = gStoreManager:GetStoreGroup("AgentProfileShowArea"):GetStoreByWidget(widget)
	self.profileShowAreaStore.recruitableList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderRecruitableListItem", true)
	self.profileShowAreaStore.recruitableList.onGetTIndex = self:CreateAction("OnGetRecruitableListTIndex")
	self.profileShowAreaStore.unrecruitableList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderRecruitableListItem", false)
	self.profileShowAreaStore.unrecruitableList.onGetTIndex = self:CreateAction("OnGetUnrecruitableListTIndex")
	self.profileShowAreaStore.recruitableList.luaSimpleClick = self:CreateAction("OnClickRecruitableList")
	self.profileShowAreaStore.unrecruitableList.luaSimpleClick = self:CreateAction("OnClickUnrecruitableList")
	self.profileShowAreaStore.recruitableList.luaSelectedChanged = self:CreateAction("OnRecruitableListSelectedChanged")
	self.profileShowAreaStore.unrecruitableList.luaSelectedChanged = self:CreateAction("OnUnrecruitableListSelectedChanged")

	self:RefreshProfileList()
end

function M:OnRenderRecruitableListItem(isRecruitable, btn, index)
	local data = isRecruitable and self.recruitableAgents[index + 1] or self.unrecruitableAgents[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileAvatarTemplate"):GetStoreById(id)

	if store then
		local profileId = data.id
		local iconId = AgentProfileConfig.GetConfig(profileId).HeadIcon

		if iconId > 0 then
			store.iconId = iconId
		end

		local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(profileId)

		if isAcquainted then
			local isNew = gAgentTrustManager:CheckIfNewAcquaintedByProfileId(profileId)
			local hasReward = gAgentTrustManager:CheckHasRewardCanGot(profileId)
			store.newCtrl = (isNew or hasReward) and 1 or 0

			if isNew or hasReward then
				gCS.LuaUtils.PlayAnimationByName(store.ani, self.newAnime)
			end

			store.stateCtrl = 0
		else
			store.newCtrl = 0
			store.stateCtrl = 1
		end

		store.guide.guideID = data.guide
		store.guide.targetScrollableWidget = self.bindData.showScroll
		store.guide.targetMaskWidget = self.bindData.showScroll.maskWidget

		if isAcquainted then
			local config = AgentProfileConfig.GetConfig(profileId)
			local maxTrust = config.MaxTrust
			local nowTrust = gAgentTrustManager:GetTrustValue(profileId)

			if nowTrust and maxTrust > 0 then
				store.trustPercent = nowTrust / maxTrust
				store.fullTrustCtrl = maxTrust <= nowTrust and 1 or 0
			else
				store.trustPercent = 0
				store.fullTrustCtrl = 0
			end
		else
			store.trustPercent = 0
			store.fullTrustCtrl = 0
		end
	end
end

function M:OnGetTargetListTIndex(index)
	local data = self.targetsData[index + 1]

	if not data then
		return 0
	end

	return data.isFinished and 0 or 1
end

function M:OnGetRewardListTIndex(index)
	local data = self.rewardListData[index + 1]

	if data and data.tIndex then
		return data.tIndex
	end

	return 0
end

function M:OnGetFeatureListTIndex(index)
	return 0
end

function M:OnGetFeatureDetailListTIndex(index)
	return 0
end

function M:OnGetRecruitableListTIndex(index)
	return 0
end

function M:OnGetUnrecruitableListTIndex(index)
	return 0
end

function M:OnGetTotalProgressRewardTIndex(index)
	local data = self.totalProgressRewardListData[index + 1]

	if data and data.tIndex then
		return data.tIndex
	end

	return 0
end

function M:OnClickRecruitableList(btn, index)
	local data = self.recruitableAgents[index + 1]

	if not data then
		return
	end

	self.profileShowAreaStore.unrecruitableList:DeselectAll()

	self.selectAgentProfileId = data.id
end

function M:OnClickUnrecruitableList(btn, index)
	local data = self.unrecruitableAgents[index + 1]

	if not data then
		return
	end

	self.profileShowAreaStore.recruitableList:DeselectAll()

	self.selectAgentProfileId = data.id
end

function M:OnRecruitableListSelectedChanged()
	local selectIndex = self.profileShowAreaStore.recruitableList.selectedIndex

	if selectIndex == -1 then
		return
	end

	local data = self.recruitableAgents[selectIndex + 1]

	if data then
		self.selectAgentProfileId = data.id

		self:RefreshAgentSelect()
	end
end

function M:OnUnrecruitableListSelectedChanged()
	local selectIndex = self.profileShowAreaStore.unrecruitableList.selectedIndex

	if selectIndex == -1 then
		return
	end

	local data = self.unrecruitableAgents[selectIndex + 1]

	if data then
		self.selectAgentProfileId = data.id

		self:RefreshAgentSelect()
	end
end

function M:OnDynamicRenderTotalProgressRewardItem(btn, index)
	self:OnRenderTotalProgressRewardItem(btn, index)
end

function M:OnRenderTotalProgressRewardItem(btn, index)
	local data = self.totalProgressRewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = nil

	if data.tIndex == 0 then
		store = gStoreManager:GetStoreGroup("ProgressRewardListStore"):GetStoreById(id)

		if store then
			store.percentText = string.format("%.0f%%", data.percent * 100)

			if data.isGot then
				store.isAvailable = 2
			elseif data.canGet then
				store.isAvailable = 1
			else
				store.isAvailable = 0
			end

			if store.rewardList then
				store.rewardList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderTotalProgressSubRewardItem", {
					rewards = data.rewards,
					canGet = data.canGet,
					isGot = data.isGot
				})
				store.rewardList.luaSimpleClick = self:CreateActionWithArgs("OnClickTotalProgressSubRewardItem", {
					mainIndex = index,
					data = data
				})

				store.rewardList:SetSimpleList(#data.rewards)
			end
		end
	else
		store = gStoreManager:GetStoreGroup("ProgressRewardBigStore"):GetStoreById(id)

		if store then
			store.percentText = string.format("%.0f%%", data.percent * 100)

			if data.isGot then
				store.isAvailable = 2
			elseif data.canGet then
				store.isAvailable = 1
			else
				store.isAvailable = 0
			end

			if data.rewards and #data.rewards > 0 then
				local reward = data.rewards[1]
				store.icon = reward.IconId or 0
				store.quality = reward.Quality or 0
				store.numText = "X" .. tostring(reward.Count or 1)
			end
		end
	end
end

function M:OnRenderTotalProgressSubRewardItem(params, btn, index)
	local rewards = params.rewards
	local canGet = params.canGet
	local isGot = params.isGot
	local reward = rewards[index + 1]

	if not reward then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ProgressRewardBaseStore"):GetStoreById(id)

	if store then
		store.icon = reward.IconId or 0
		store.quality = reward.Quality or 0

		if isGot then
			store.isAvailable = 2
		elseif canGet then
			store.isAvailable = 1
		else
			store.isAvailable = 0
		end

		store.numText = "X" .. tostring(reward.Count or 1)
	end
end

function M:OnClickTotalProgressRewardItem(btn, index)
	local data = self.totalProgressRewardListData[index + 1]

	if not data then
		return
	end

	if data.tIndex == 1 then
		if data.canGet then
			self:TakeCompletionRewardWithPreview(data)
		elseif self.currentTipRewardIndex == index and self.bindData.tipActive == true then
			self:HideTotalProgressRewardTip()
		else
			self:ShowTotalProgressRewardTip(data, index, 0)
		end
	end
end

function M:OnClickTotalProgressSubRewardItem(params, btn, subIndex)
	local mainIndex = params.mainIndex
	local data = params.data

	if data.canGet then
		self:TakeCompletionRewardWithPreview(data)
	elseif self.currentTipRewardIndex == mainIndex and self.currentTipSubRewardIndex == subIndex and self.bindData.tipActive == true then
		self:HideTotalProgressRewardTip()
	else
		self:ShowTotalProgressRewardTip(data, mainIndex, subIndex)
	end
end

function M:ShowTotalProgressRewardTip(data, mainIndex, subIndex)
	local reward = nil

	if subIndex > 0 then
		reward = data.rewards[subIndex + 1]
	elseif data.rewards and #data.rewards > 0 then
		reward = data.rewards[1]
	end

	if not reward or not reward.ItemId or reward.ItemId == 0 then
		return
	end

	local itemConfig = LTConfig.CommonItemConfig.GetConfig(reward.ItemId)

	if itemConfig then
		self.bindData.tipActive = true
		self.bindData.tipNameText = itemConfig.Name
		self.bindData.tipDesText = itemConfig.Description or itemConfig.ShortDescription
		self.currentTipRewardIndex = mainIndex
		self.currentTipSubRewardIndex = subIndex
	end
end

function M:HideTotalProgressRewardTip()
	self.bindData.tipActive = false
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
end

function M:TakeCompletionRewardWithPreview(data)
	local fakeItems = gCommonItemManager:ConvertDropToFakeItem(data.dropId, 1)
	local previewMaterials = {}

	for _, item in ipairs(fakeItems) do
		table.insert(previewMaterials, {
			ItemId = item.Id,
			Count = item.Count
		})
	end

	local function cb()
		self.bindData.tipActive = false
		self.currentTipRewardIndex = nil
		self.currentTipSubRewardIndex = nil

		self:RefreshTotalProgressRewardList()
		gDropManager:ShowRewardWindow({
			ExtraRewardParam = 2,
			Param = previewMaterials
		})
	end

	self:TakeCompletionReward(data.index, cb)
end

function M:InitProfileData()
	local count = AgentProfileConfig.count
	local firstSelect = nil

	for i = 0, count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local data = {
				id = config.Id,
				guide = config.GuideId
			}

			if firstSelect == nil then
				firstSelect = data.id
			end

			if self.selectAgentProfileId == nil and gAgentTrustManager:GetIfAcquaintedByProfileId(data.id) then
				self.selectAgentProfileId = data.id
				data.selected = true
			end

			if config.CanJoin then
				table.insert(self.recruitableAgents, data)
			else
				table.insert(self.unrecruitableAgents, data)
			end
		end
	end

	if self.selectAgentProfileId == nil then
		self.selectAgentProfileId = firstSelect
	end
end

function M:RefreshProfileList()
	self.profileShowAreaStore.recruitableList:SetSimpleList(#self.recruitableAgents)
	self.profileShowAreaStore.unrecruitableList:SetSimpleList(#self.unrecruitableAgents)
end

local tmpTable = {}

function M:RefreshAgentSelect()
	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)
	self.bindData.agentStateCtrl = 0
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local agentId = config.AgentId
	local iconId = config.HeadIcon

	if iconId > 0 then
		self.bindData.agentAvatarIconId = iconId
	end

	if not isAcquainted then
		self.bindData.agentStateCtrl = 1
		self.bindData.trustValueText = "-"
		self.bindData.trustProgress.value = 0
		self.bindData.npcNameText = ""
		self.bindData.factionNameText = ""
		self.profileDetailAreaStore.npcDescText = ""

		table.clear(self.rewardListData)
		table.clear(self.targetsData)

		self.selectedRewardData = nil
		self.selectedRewardIndex = -1

		self.bindData.rewardList:SetSimpleList(0)
		self.bindData.targetList:SetSimpleList(0)

		self.bindData.rewardIconBig = 0
		self.bindData.rewardName = ""
		self.bindData.rewardNum = ""
		self.bindData.receivedCtrl = 0

		return
	end

	if agentId and agentId > 0 then
		local faction = AgentConfig.GetConfig(agentId).Faction

		if faction and faction > 0 then
			local factionName = FactionConfig.GetConfig(faction).name
			self.bindData.factionNameText = factionName
		else
			self.bindData.factionNameText = ""
		end
	end

	self.bindData.npcNameText = config.Name
	self.profileDetailAreaStore.npcDescText = config.Description
	local maxTrust = config.MaxTrust
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	self.bindData.trustProgress.value = nowTrust / maxTrust
	self.bindData.trustHintProgress.value = nowTrust / maxTrust
	self.bindData.fullTrustCtrl = maxTrust <= nowTrust and 1 or 0

	table.clear(tmpTable)

	local rewards = config.TrustReward

	for _, rewardId in ipairs(rewards) do
		local trust = AgentProfileRewardConfig.GetConfig(rewardId).NeedTrust

		table.insert(tmpTable, trust)
	end

	table.sort(tmpTable)

	local meetTrustIndex = 0

	for i, v in ipairs(tmpTable) do
		if v <= nowTrust then
			meetTrustIndex = i
		end
	end

	local diff = nil

	if meetTrustIndex == #tmpTable then
		self.bindData.completeCtrl = 1
	else
		self.bindData.completeCtrl = 0
		diff = tmpTable[meetTrustIndex + 1] - nowTrust
	end

	self.bindData.nextScoreText = diff

	self:RefreshRedPoint()
	self:RefreshFeature()
	self:RefreshReward()
	self:RefreshTarget()
	self:RefreshUrbanAttribute()
	self:RefreshBaseMap()
	self:RefreshSpecialRewardBtnState()
	self:AutoSelectFirstReward()
end

function M:RefreshRedPoint()
	if gAgentTrustManager:CheckHasRewardCanGot(self.selectAgentProfileId) then
		self.bindData.redPointCtrl = 1
	else
		self.bindData.redPointCtrl = 0
	end

	self:RefreshIconRedPoint(self.selectAgentProfileId)
	self:RefreshTotalProgressRedPoint()
end

function M:RefreshTotalProgressRedPoint()
	return
end

function M:RefreshFeature()
	local features = AgentProfileConfig.GetConfig(self.selectAgentProfileId).Characteristic

	table.clear(self.featuresData)

	for _, id in ipairs(features) do
		local data = {}
		local cfg = AgentProfileCharacteristicConfig.GetConfig(id)
		data.name = cfg.Name
		data.icon = cfg.Image
		data.desc = cfg.Description

		table.insert(self.featuresData, data)
	end

	self.profileDetailAreaStore.featureList:SetSimpleList(#self.featuresData)
	self.profileDetailAreaStore.featureDetailList:SetSimpleList(#self.featuresData)
end

function M:RefreshReward()
	if not self.selectAgentProfileId then
		return
	end

	if self.selectAgentProfileId == 38000002 then
		self.bindData.tafeiCtrl = 1
	else
		self.bindData.tafeiCtrl = 0
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	self.bindData.npcNameText = config.Name
	local maxTrust = config.MaxTrust
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	local rewards = config.TrustReward
	local gridCount = 13

	table.clear(self.rewardListData)

	local rewardListData = self.rewardListData

	for i = 1, gridCount do
		local data = {
			tIndex = 1
		}

		table.insert(rewardListData, data)
	end

	local isTafei = self.selectAgentProfileId == 38000002

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)
		local needTrust = rewardCfg.NeedTrust
		local index = needTrust / maxTrust * (gridCount - 1)
		index = index + 1
		rewardListData[index].tIndex = 0
		rewardListData[index].id = rewardCfg.Id
		rewardListData[index].need = needTrust

		if isTafei then
			rewardListData[index].isTrustEnough = true
			rewardListData[index].canGet = false
		else
			rewardListData[index].isTrustEnough = needTrust <= nowTrust
			rewardListData[index].canGet = needTrust <= nowTrust and not gAgentTrustManager:CheckRewardGot(self.selectAgentProfileId, rewardCfg.Id)
		end

		rewardListData[index].desc = rewardCfg.Description
		rewardListData[index].rewardType = rewardCfg.RewardType
		rewardListData[index].rewardIconIdBig = rewardCfg.IconId
		rewardListData[index].rewardIconIdSmall = rewardCfg.SmallIconId
		local itemTypeCtrl, spiritId = self:GetRewardItemType(rewardCfg.DropId, self.selectAgentProfileId)
		rewardListData[index].itemTypeCtrl = itemTypeCtrl
		rewardListData[index].spiritId = spiritId
	end

	self.bindData.rewardList:SetSimpleList(#rewardListData)
end

function M:GetRewardItemType(dropId, profileId)
	local profileConfig = AgentProfileConfig.GetConfig(profileId)

	if profileId == 38000002 and profileConfig and profileConfig.AgentId and profileConfig.AgentId > 0 then
		return self.RewardItemType.Character, profileConfig.AgentId
	end

	if not dropId or dropId <= 0 then
		return self.RewardItemType.Items, nil
	end

	local dropConfig = LTConfig.DropConfig.GetConfig(dropId)

	if not dropConfig or not dropConfig.Item1 or #dropConfig.Item1 == 0 then
		return self.RewardItemType.Items, nil
	end

	local firstItem = dropConfig.Item1[1]

	if not firstItem or not firstItem.id1 or firstItem.id1 <= 0 then
		return self.RewardItemType.Items, nil
	end

	local itemConfig = LTConfig.CommonItemConfig.GetConfig(firstItem.id1)

	if not itemConfig then
		return self.RewardItemType.Items, nil
	end

	if itemConfig.SubType then
		if itemConfig.SubType == LTConfig.ConsumableTypeConfig.Character then
			return self.RewardItemType.Character, profileConfig.AgentId
		end

		if itemConfig.SubType == LTConfig.ConsumableTypeConfig.Vehicle then
			return self.RewardItemType.Car, nil
		end

		local weaponSubTypes = {
			LTConfig.ConsumableTypeConfig.Weapon,
			LTConfig.ConsumableTypeConfig.WeaponSkin
		}

		for _, wType in ipairs(weaponSubTypes) do
			if itemConfig.SubType == wType then
				return self.RewardItemType.Weapon, nil
			end
		end
	end

	return self.RewardItemType.Items, nil
end

function M:RefreshTarget()
	local targets = AgentProfileConfig.GetConfig(self.selectAgentProfileId).TrustTarget
	self.targetsData = {}

	for _, id in ipairs(targets) do
		local data = {}
		local cfg = AgentProfileTargetConfig.GetConfig(id)
		data.isFinished = gAgentTrustManager:CheckTargetFinish(self.selectAgentProfileId, id)
		data.desc = cfg.Description
		data.score = cfg.AddTrust

		table.insert(self.targetsData, data)
	end

	table.sort(self.targetsData, function (a, b)
		if a.isFinished == b.isFinished then
			return false
		end

		return not a.isFinished
	end)
	self.bindData.targetList:SetSimpleList(#self.targetsData)
end

function M:RefreshIconRedPoint(profileId)
	if not self.profileShowAreaStore then
		return
	end

	if self.profileShowAreaStore.recruitableList and self.recruitableAgents then
		for i, data in ipairs(self.recruitableAgents) do
			if data and data.id == profileId then
				self.profileShowAreaStore.recruitableList:RefreshElement(i - 1)

				break
			end
		end
	end

	if self.profileShowAreaStore.unrecruitableList and self.unrecruitableAgents then
		for i, data in ipairs(self.unrecruitableAgents) do
			if data and data.id == profileId then
				self.profileShowAreaStore.unrecruitableList:RefreshElement(i - 1)

				break
			end
		end
	end
end

function M:RefreshUrbanAttribute()
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local urbanAttrs = config.UrbanAttribute
	local lifeAttrRuleList = gSpiritManager:GetUrbanRuleList(true)

	for i = 1, #urbanAttrs do
		self.profileDetailAreaStore.radarChart:SetVertexValue(i - 1, urbanAttrs[i])

		local component = self.profileDetailAreaStore["radarTitle" .. i]
		local store = gStoreManager:GetStoreGroup("Xuwei6DemensionInfoStore"):GetStoreByWidget(component)

		if store then
			store.icon = lifeAttrRuleList[i].attrIcon
			store.nameLabel = urbanAttrs[i]
		end
	end
end

function M:RefreshBaseMap()
	if not self.selectAgentProfileId then
		return
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)

	if not config or not config.Position or #config.Position < 3 then
		return
	end

	self.baseMap = gBaseMapMgr:GetBaseMap(self.bindData.baseMap)

	if not self.baseMap then
		return
	end

	self.baseMap:SetFixedScaleLevel(3)
	self.baseMap:SetMapInfo(gMapSystem.area:GetAreaId(LTConfig.RaidConfig.WorldMap, 0), 2)

	local scheduleInfo = self:GetScheduleInfo(self.selectAgentProfileId)
	local posCfg = config.Position
	local pos = nil

	if scheduleInfo then
		pos = Vector3.New(scheduleInfo.Position.X, scheduleInfo.Position.Y, scheduleInfo.Position.Z)
	else
		pos = Vector3.New(posCfg[1], posCfg[2], posCfg[3])
	end

	self.baseMap:Align(pos, self.bindData.anchor)
end

function M:CalculateTotalProgressWeight()
	self.totalProgressWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			self.totalProgressWeight = self.totalProgressWeight + (config.Weight or 0)

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig then
					self.totalProgressWeight = self.totalProgressWeight + (targetConfig.Weight or 0)
				end
			end
		end
	end
end

function M:RefreshTotalProgress()
	local completedWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(config.Id)

			if isAcquainted then
				completedWeight = completedWeight + (config.Weight or 0)
			end

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig then
					local isFinished = gAgentTrustManager:CheckTargetFinish(config.Id, targetId)

					if isFinished then
						completedWeight = completedWeight + (targetConfig.Weight or 0)
					end
				end
			end
		end
	end

	local progress = self.totalProgressWeight > 0 and completedWeight / self.totalProgressWeight or 0
	self.bindData.totalProgress = progress
end

function M:GetCompletionRewards()
	local completionRewards = ProfileConfig.CompletionReward

	if not completionRewards or #completionRewards == 0 then
		return {}
	end

	local currentProgress = self.bindData.totalProgress or 0
	local rewardList = {}

	for i, rewardCfg in ipairs(completionRewards) do
		local rewardData = {
			canGet = false,
			isGot = false,
			index = i,
			percent = rewardCfg.percent,
			dropId = rewardCfg.dropId
		}
		rewardData.isGot = gAgentTrustManager:CheckProgressRewardGot(rewardData.index - 1)

		if rewardCfg.percent <= currentProgress and not rewardData.isGot then
			rewardData.canGet = true
		end

		table.insert(rewardList, rewardData)
	end

	table.sort(rewardList, function (a, b)
		return a.percent < b.percent
	end)

	return rewardList
end

function M:CheckHasCompletionRewardCanGet()
	local rewardList = self:GetCompletionRewards()

	for _, reward in ipairs(rewardList) do
		if reward.canGet then
			return true
		end
	end

	return false
end

function M:RefreshTotalProgressRewardList()
	local rewards = self:GetCompletionRewards()

	table.clear(self.totalProgressRewardListData)

	for _, reward in ipairs(rewards) do
		local dropConfig = LTConfig.DropConfig.GetConfig(reward.dropId)
		local rewardItems = {}

		if dropConfig then
			if dropConfig.Money and dropConfig.Money > 0 then
				local moneyCfg = ConsumableConfig.GetConfig(ConsumableConfig.RewardMoney)

				if moneyCfg then
					table.insert(rewardItems, {
						ItemId = ConsumableConfig.RewardMoney,
						IconId = moneyCfg.SItemIconId or 0,
						Count = dropConfig.Money,
						Quality = moneyCfg.Quality or 0
					})
				end
			end

			if dropConfig.Item1 then
				for _, itemData in ipairs(dropConfig.Item1) do
					local quality = 0
					local iconId = 0

					if itemData.id1 and itemData.id1 > 0 then
						local itemConfig = LTConfig.CommonItemConfig.GetConfig(itemData.id1)

						if itemConfig then
							quality = itemConfig.Quality or 0
							iconId = itemConfig.SItemIconId or 0
						end
					end

					table.insert(rewardItems, {
						ItemId = itemData.id1,
						IconId = iconId,
						Count = itemData.count or 1,
						Quality = quality
					})
				end
			end
		end

		local tIndex = 0
		local listData = {
			index = reward.index,
			percent = reward.percent,
			dropId = reward.dropId,
			canGet = reward.canGet,
			isGot = reward.isGot,
			rewards = rewardItems,
			tIndex = tIndex
		}

		table.insert(self.totalProgressRewardListData, listData)
	end

	self.totalProgressRewardListData[#self.totalProgressRewardListData].tIndex = 1

	self.bindData.totalProgressList:SetSimpleList(#self.totalProgressRewardListData)
end

function M:TakeCompletionReward(index, cb)
	gClientToGameDelegate:AskTakeNpcProfileProgressReward(index - 1).Callback = function (errId)
		if errId ~= 0 then
			print_warn("AskTakeNpcProfileProgressReward 请求失败，err = " .. gCS.Error.GetNameById(errId))

			return
		end

		gAgentTrustManager:UpdateProgressRewardGot(index - 1)

		if cb then
			cb()
		end
	end
end

function M:AutoSelectFirstReward()
	if not self.rewardListData or #self.rewardListData == 0 then
		self.selectedRewardData = nil
		self.bindData.rewardIconBig = 0
		self.bindData.rewardName = ""
		self.bindData.rewardNum = ""
		self.bindData.receivedCtrl = 0

		return
	end

	self.selectedRewardIndex = -1
	local firstUnclaimedIndex, firstUnreachableIndex, lastRewardIndex = nil

	for i = 1, #self.rewardListData do
		local data = self.rewardListData[i]

		if data.tIndex ~= 1 then
			lastRewardIndex = i - 1

			if not firstUnclaimedIndex and data.canGet then
				firstUnclaimedIndex = i - 1
			end

			if not firstUnreachableIndex and not data.isTrustEnough then
				firstUnreachableIndex = i - 1
			end
		end
	end

	if firstUnclaimedIndex then
		self:OnClickRewardList(nil, firstUnclaimedIndex)
	elseif firstUnreachableIndex then
		self:OnClickRewardList(nil, firstUnreachableIndex)
	elseif lastRewardIndex then
		self:OnClickRewardList(nil, lastRewardIndex)
	end
end
