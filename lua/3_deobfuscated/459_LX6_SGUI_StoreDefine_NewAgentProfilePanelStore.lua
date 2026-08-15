local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileCharacteristicConfig = LTConfig.ProfileCharacteristicConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local AgentConfig = LTConfig.AgentConfig
local RewardType = LTConfig.ProfileRewardConfig.RewardTypeType
C_NewAgentProfilePanelStore = DefClass("C_NewAgentProfilePanelStore", C_NewAgentProfilePanelStore, C_StoreGroup)
GroupName2Class.NewAgentProfilePanelStore = C_NewAgentProfilePanelStore
local M = C_NewAgentProfilePanelStore

function M:ctor()
	self:GenMessageEvents()

	self.lastDragPos = nil
end

function M:DefineAllVariables()
	self.allAgents = {}
	self.validMapAgents = {}
	self.agentPositionCache = {}
	self.profileHeadListStore = nil
	self.profileDetailAreaStore = nil
	self.page2Store = nil
	self.selectAgentProfileId = nil
	self.rewardListData = {}
	self.featuresData = {}
	self.targetsData = {}
	self.selectedRewardData = nil
	self.totalProgressWeight = 0
	self.totalProgressRewardListData = {}
	self.lastTotalPercent = 0
	self.lastTotalReward = nil
	self.baseMap = nil
	self.currentTipRewardIndex = nil
	self.currentTipSubRewardIndex = nil
	self.finishAnime = "S_Vx_missionTemplate2_firstComplate"
	self.tipAnime = "S_Vx_missionTemplate2_tips"
	self.rewardTipsAnime = "S_vx_page02_REWARD_tips"
	self.mapBackAnime = "S_NewAgentProfilePanel_backmap"
	self.mapBackPage2Anime = "S_NewAgentProfilePanel_backmapPage02"
	self.mapScale = 1
	self.minMapScale = 0.5
	self.maxMapScale = 2
	self.lastDragPos = nil
	self.controllerZoomInTrigger = 0
	self.controllerZoomOutTrigger = 0
	self.CONTROLLER_ZOOM_SCALE = 1
	self.controllerZoomTimer = nil
	self.ctrlerInput = {}
	self.CONTROLLER_MAP_SENSITIVITY = LTConfig.ProfileConfig.ControllerMapSensitivity or 800
	self.isControllerMode = false
	self.currentAttachedAgentId = nil
	self.CONTROLLER_ATTACH_RANGE = LTConfig.ProfileConfig.ControllerAttachRange or 100
	self.CONTROLLER_POINTER_ATTACH_SPEED = LTConfig.ProfileConfig.ControllerAttachSpeed or 300
	self.CONTROLLER_POINTER_OPEN = "s_vx_Controller_mouse_open"
	self.CONTROLLER_POINTER_LOOP = "s_vx_Controller_mouse_loop"
	self.controllerPointerAnim = nil
	self.hasShownLastRewardTip = false
end

function M:DefineAllEnumsAutoGen()
	self.showDetailsCtrlEnum = {
		reward = 2,
		list = 1,
		map = 3,
		main = 0
	}
	self.agentStateCtrlEnum = {
		detail = 2,
		lock = 1,
		unlock = 0
	}
	self.completeCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.totalProgressCtrlEnum = {
		_false = 0,
		_true = 1
	}
	self.rewardTypeCtrlEnum = {
		weapon = 0,
		car = 3,
		character = 1,
		items = 2
	}
end

function M:ClearAllEnumsAutoGen()
	self.showDetailsCtrlEnum = nil
	self.agentStateCtrlEnum = nil
	self.completeCtrlEnum = nil
	self.totalProgressCtrlEnum = nil
	self.rewardTypeCtrlEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnShow()
	self:OnPage2InitContent()

	self.totalProgressWeight = gAgentTrustManager:CalculateTotalProgressWeight()
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.main
	self.bindData.agentStateCtrl = self.agentStateCtrlEnum.lock
	self.bindData.tipActive = false
	self.bindData.giftCtrl = 0

	self:ResetMapTransform()
	self:InitBaseMap()
	self:RefreshAgentSelect()
	self:RefreshTotalProgress()
	self:RefreshTotalProgressRewardList()
	self:SwitchToCorrectArea()
	self:InitControllerPointerAnim()
	self:UpdateControllerMode(SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice())
	self:StartControllerZoomTimer()
end

function M:InitControllerPointerAnim()
	if self.bindData.ctrlerMouseRT then
		self.controllerPointerAnim = self.bindData.ctrlerMouseRT:GetComponent(typeof(UnityEngine.Animation))
	end
end

function M:PlayControllerPointerAttachAnim()
	if not self.controllerPointerAnim then
		return
	end

	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:PlayQueued(self.CONTROLLER_POINTER_LOOP)
end

function M:ResetControllerPointerAnim()
	if not self.controllerPointerAnim then
		return
	end

	self.controllerPointerAnim:Stop()
	self.controllerPointerAnim:Play(self.CONTROLLER_POINTER_OPEN)
	self.controllerPointerAnim:Sample()
	self.controllerPointerAnim:Stop()
end

function M:StartControllerZoomTimer()
	if self.controllerZoomTimer then
		return
	end

	self.controllerZoomTimer = FrameTimer.New(function ()
		self:TickControllerZoom()
	end, 1, -1):Start()
end

function M:UpdateControllerMode(isController)
	self.isControllerMode = isController

	if self.bindData.ctrlerMouseRT then
		self.bindData.ctrlerMouseRT.gameObject:SetActive(isController)
	end
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

	self.lastDragPos = nil
	self.agentPositionCache = {}

	if self.controllerZoomTimer then
		self.controllerZoomTimer:Stop()

		self.controllerZoomTimer = nil
	end

	self.currentAttachedAgentId = nil

	self:HideControllerAttachTip()
end

function M:OnActiveDeviceChange(device)
	self:UpdateControllerMode(SGUI.GameDevice.KeyboardMouse < device)
end

function M:SwitchToCorrectArea()
	if self.bindData.giftCtrl == 1 then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.totalArea

		return
	end

	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.main then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.rootArea
	elseif self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.list then
		FrameTimer.New(function ()
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.listArea
		end, 1):Start()
	elseif self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.reward then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.rewardArea
	elseif self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.map then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.rootArea
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self:CreateAction("RefreshRedPoint"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}
end

function M:OnPanelClose(eventId, panelId)
	if panelId == gPanelId.S_MAIN_PAGE_TAB_PANEL then
		self:PlayMapBackAnimation()

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self:SwitchToCorrectArea()
		end
	end
end

function M:PlayMapBackAnimation()
	local isInPage2 = self.bindData and self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.reward
	local animName = isInPage2 and self.mapBackPage2Anime or self.mapBackAnime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, animName)
end

function M:RegisterWidget()
	self.bindData.locationBtn.luaClick = self:CreateAction("OnClickLocationBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnExitClick")
	self.bindData.page1BackBtn.luaClick = self:CreateAction("OnExitClick")
	self.bindData.goToMapBtn.luaClick = self:CreateActionWithArgs("OnClickMapBtn", true)
	self.bindData.rewardShowBtn.luaClick = self:CreateAction("OnClickRewardShowBtn")
	self.bindData.navToDetailBtn.luaClick = self:CreateAction("OnClickNavToDetailBtn")
	self.bindData.totalProgressBtn.luaClick = self:CreateActionWithArgs("OnClickTotalProgressBtn", true)
	self.bindData.closeTotalBtn.luaClick = self:CreateActionWithArgs("OnClickTotalProgressBtn", false)
	self.bindData.totalProgressList.luaSimpleRenderItem = self:CreateAction("OnRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderTotalProgressRewardItem")
	self.bindData.totalProgressList.luaSimpleClick = self:CreateAction("OnClickTotalProgressRewardItem")
	self.bindData.totalProgressList.onGetTIndex = self:CreateAction("OnGetTotalProgressRewardTIndex")
	self.bindData.rewardDotList.luaSimpleRenderItem = self:CreateAction("OnRenderRewardDotListItem")
	self.bindData.rewardDotList.onGetTIndex = self:CreateAction("OnGetRewardDotListTIndex")
	self.bindData.lastTotalReward.luaClick = self:CreateAction("OnClickLastTotalReward")
	self.bindData.lastTotalReward.luaFocus = self:CreateAction("OnFocusLastTotalReward")
	self.bindData.showScroll.luaInitContent = self:CreateAction("OnShowScrollInitContent")
	self.bindData.detailScroll.luaInitContent = self:CreateAction("OnDetailScrollInitContent")
	self.bindData.gestureListener.onZoom = self:CreateAction("OnGestureZoom")

	if self.bindData.controllerZoomInBtn then
		self.bindData.controllerZoomInBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomIn", true)
		self.bindData.controllerZoomInBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomIn", false)
	end

	if self.bindData.controllerZoomOutBtn then
		self.bindData.controllerZoomOutBtn.luaPress = self:CreateActionWithArgs("OnControllerZoomOut", true)
		self.bindData.controllerZoomOutBtn.luaRelease = self:CreateActionWithArgs("OnControllerZoomOut", false)
	end

	if self.bindData.controllerLeftJoyStickRT then
		local leftJS = self.bindData.controllerLeftJoyStickRT:GetComponent(typeof(SGUI.UCustomNavRespond))

		if leftJS then
			leftJS.luaGamePadInputChanged = self:CreateAction("OnLeftJoyStickMove")
		end
	end

	if self.bindData.controllerAttachBtn then
		self.bindData.controllerAttachBtn.luaClick = self:CreateAction("OnControllerSelectAgent")

		self.bindData.controllerAttachBtn:SetActive(false)
	end

	if self.bindData.bigBackBtn then
		self.bindData.bigBackBtn.luaClick = self:CreateAction("OnClickBigBackBtn")
	end

	if self.bindData.mapRewardBtn then
		self.bindData.mapRewardBtn.luaClick = self:CreateAction("OnClickMapRewardBtn")
	end

	self.bindData.mapIconFreeList.luaRenderItem = self:CreateAction("OnRenderMapIconItem")
	self.bindData.mapIconFreeList.luaClick = self:CreateAction("OnClickMapIcon")

	function self.bindData.mapIconFreeList.onGetTIndex()
		return 0
	end

	self:InitMapInteraction()
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

	local scheduleInfo = gAgentTrustManager:GetScheduleInfo(self.selectAgentProfileId)
	local taskState = gTaskManager:GetTaskState(60011584)
	local taskState2 = gTaskManager:GetTaskState(60017955)

	if taskState == UX.Game.TaskState.Accepted or taskState2 == UX.Game.TaskState.Accepted and self.selectAgentProfileId == 38000011 then
		gPanelManager:Close(self.m_Id)
		gMainPhoneUtils.CloseMainPhonePanel(true)

		return
	end

	if scheduleInfo then
		local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, scheduleInfo.ActivityId)
		local element = gMapSystem.container:GetByGpsId(gpsId)

		if element then
			gAgentTrustManager.openMapFromAgentProfile = true

			gMapGpsCmd:TryOpenBigMapAndFocusSelectFavorNpc(scheduleInfo.ActivityId)
		else
			local name = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(agentType).Name
			local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

			gDisplayMessageMgr:ShowMessageContent(message)
		end
	else
		local name = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(agentType).Name
		local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

		gDisplayMessageMgr:ShowMessageContent(message)
	end
end

function M:OnClickRewardShowBtn()
	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.main then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list

		self:SwitchToCorrectArea()
	end
end

function M:OnClickNavToDetailBtn()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.detailArea

		self.bindData.detailScroll:GoToPos(Vector2.New(0, 0), false)

		if self.profileDetailAreaStore.rewardListActive == false then
			self.profileDetailAreaStore.featureList:SelectItem(0, true)
			self.profileDetailAreaStore.featureList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.rewardList:DeselectAll(false)
		else
			self.profileDetailAreaStore.rewardList:SelectItem(0, true)
			self.profileDetailAreaStore.rewardList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.featureList:DeselectAll(false)
		end
	end
end

function M:OnHoverRadarBtn()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local layoutBoxHeight = self.profileDetailArea.rectTransform.sizeDelta.y
		local scrollRectHeight = self.bindData.detailScroll.rectTransform.sizeDelta.y
		local y = layoutBoxHeight - scrollRectHeight

		self.bindData.detailScroll:GoToPos(Vector2.New(0, y), false)
	end
end

function M:OnHoverShowRewardBtn()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local parentPos = self.profileDetailAreaStore.layoutBox.parentComponent.rectTransform.anchoredPosition
		self.profileDetailAreaStore.layoutBox.parentComponent.rectTransform.anchoredPosition = Vector2.New(parentPos.x, 0)
	end
end

function M:OnClickShowRewardBtn()
	self.profileDetailAreaStore.btnCtrl = self.profileDetailAreaStore.btnCtrl == 0 and 1 or 0
	self.profileDetailAreaStore.rewardListActive = self.profileDetailAreaStore.btnCtrl == 0

	if gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgr.Inst.CurrentActiveArea == self.bindData.detailArea then
		if self.profileDetailAreaStore.rewardListActive == false then
			self.profileDetailAreaStore.featureList:SelectItem(0, true)
			self.profileDetailAreaStore.featureList:SetNavSelectToSelect(true)
			self.profileDetailAreaStore.rewardList:DeselectAll(false)
		else
			self.profileDetailAreaStore.featureList:DeselectAll(false)
			self.profileDetailAreaStore.rewardList:SelectItem(0, true)
			FrameTimer.New(function ()
				self.profileDetailAreaStore.rewardList:SetNavSelectToSelect(true)
			end, 1):Start()
		end
	end
end

function M:OnClickTotalProgressBtn(isOpen)
	self.bindData.giftCtrl = isOpen and 1 or 0

	self.bindData.totalProgressList:SelectItem(0)
	self.bindData.totalProgressList:SetNavSelectToSelect(true)
	self:SwitchToCorrectArea()
end

function M:OnClickMapBtn(force)
	if self.lastDragPos and not force then
		return
	end

	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.map

	self:SwitchToCorrectArea()
end

function M:OnExitClick()
	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.map then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.main

		self:SwitchToCorrectArea()

		return
	end

	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.reward or gCS.LuaUtils.IsNonMobileAdaptive() and SGUI.UNavigationMgr.Inst.CurrentActiveArea == self.bindData.detailArea then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
		self.selectedRewardData = nil
		self.hasShownLastRewardTip = false

		self:SwitchToCorrectArea()

		return
	end

	if self.bindData.showDetailsCtrl == self.showDetailsCtrlEnum.list then
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.main
		self.bindData.tipActive = false
		self.currentTipRewardIndex = nil
		self.currentTipSubRewardIndex = nil

		self:SwitchToCorrectArea()

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnClickBigBackBtn()
	gPanelManager:Close(self.m_Id)
end

function M:OnClickMapRewardBtn()
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.main
	self.bindData.giftCtrl = 1

	self:SwitchToCorrectArea()
end

function M:OnGestureZoom(zoom)
	if not self.selectAgentProfileId or not self.profileHeadListStore then
		return
	end

	local currentIndex = -1

	for i, agent in ipairs(self.allAgents) do
		if agent.id == self.selectAgentProfileId then
			currentIndex = i

			break
		end
	end

	if currentIndex == -1 or #self.allAgents == 0 then
		return
	end

	local newIndex = zoom < 0 and currentIndex % #self.allAgents + 1 or (currentIndex - 2) % #self.allAgents + 1
	self.selectAgentProfileId = self.allAgents[newIndex].id
	local index = self:GetListIndexByProfileId(self.selectAgentProfileId)

	if index ~= -1 then
		self.profileHeadListStore.headList:SelectItem(index, true)
	end

	self:RefreshAgentSelect()
end

function M:OnControllerZoomIn(holding)
	self.controllerZoomInTrigger = holding and 1 or 0
end

function M:OnControllerZoomOut(holding)
	self.controllerZoomOutTrigger = holding and 1 or 0
end

function M:OnLeftJoyStickMove(ctx)
	if ctx.canceled then
		self.ctrlerInput.leftJS = nil
	elseif ctx.performed then
		self.ctrlerInput.leftJS = ctx:ReadValueVector2()
	end
end

function M:OnControllerSelectAgent()
	if not self.currentAttachedAgentId then
		return
	end

	self.selectAgentProfileId = self.currentAttachedAgentId
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	local index = self:GetListIndexByProfileId(self.selectAgentProfileId)

	if index ~= -1 and self.profileHeadListStore then
		self.profileHeadListStore.headList:SelectItem(index, true)
	end

	self:RefreshAgentSelect()
	self:SwitchToCorrectArea()

	self.currentAttachedAgentId = nil

	self:HideControllerAttachTip()
end

function M:GetListIndexByProfileId(profileId)
	for i, data in ipairs(self.allAgents) do
		if data and data.id == profileId then
			return i - 1
		end
	end

	return -1
end

function M:OnShowScrollInitContent(widget)
	self:InitProfileData()

	self.profileHeadListStore = gStoreManager:GetStoreGroup("AgentProfileHeadList"):GetStoreByWidget(widget)
	self.profileHeadListStore.headList.luaSimpleRenderItem = self:CreateAction("OnRenderHeadListItem")
	self.profileHeadListStore.headList.onGetTIndex = self:CreateAction("OnGetHeadListTIndex")
	self.profileHeadListStore.headList.luaSimpleClick = self:CreateAction("OnClickHeadList")
	self.profileHeadListStore.headList.luaSelectedChanged = self:CreateAction("OnHeadListSelectedChanged")

	self:RefreshHeadList()
end

function M:OnDetailScrollInitContent(widget)
	self.profileDetailArea = widget
	self.profileDetailAreaStore = gStoreManager:GetStoreGroup("NewAgentProfileDetailContentTemplate"):GetStoreByWidget(widget)
	self.profileDetailAreaStore.featureList.luaSimpleRenderItem = self:CreateAction("OnRenderFeatureListItem")
	self.profileDetailAreaStore.featureList.luaSimpleClick = self:CreateAction("OnClickFeatureListItem")
	self.profileDetailAreaStore.featureList.onGetTIndex = self:CreateAction("OnGetFeatureListTIndex")
	self.profileDetailAreaStore.featureList.luaLayoutSet = self:CreateAction("OnLuaLayoutSet")
	self.profileDetailAreaStore.rewardList.luaSimpleRenderItem = self:CreateAction("OnRenderDetailRewardListItem")
	self.profileDetailAreaStore.rewardList.onGetTIndex = self:CreateAction("OnGetDetailRewardListTIndex")
	self.profileDetailAreaStore.rewardList.luaSimpleClick = self:CreateAction("OnClickRewardListItem")
	self.profileDetailAreaStore.rewardList.luaLayoutSet = self:CreateAction("OnLuaLayoutSet")

	function self.profileDetailAreaStore.radarBtn.luaClick()
		if not self.profileDetailAreaStore.showCtrl then
			self.profileDetailAreaStore.showCtrl = 1

			return
		end

		self.profileDetailAreaStore.showCtrl = 1 - self.profileDetailAreaStore.showCtrl
	end

	self.profileDetailAreaStore.radarBtn.luaFocus = self:CreateAction("OnHoverRadarBtn")
	self.profileDetailAreaStore.showRewardBtn.luaFocus = self:CreateAction("OnHoverShowRewardBtn")
	self.profileDetailAreaStore.showRewardBtn.luaClick = self:CreateAction("OnClickShowRewardBtn")
	self.profileDetailAreaStore.rewardListActive = true
	self.profileDetailAreaStore.btnCtrl = 0
	self.profileDetailAreaStore.lockCtrl = 1
end

function M:OnPage2InitContent()
	self.page2Store = gStoreManager:GetStoreGroup("AgentProfileRewardPageStore"):GetStoreByWidget(self.bindData.page2Comp)
	self.page2Store.rewardItemList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2RewardListItem")
	self.page2Store.rewardItemList.luaSimpleClick = self:CreateAction("OnClickPage2RewardItem")

	function self.page2Store.rewardItemList.onGetTIndex()
		return 0
	end

	self.page2Store.dotList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2DotListItem")

	function self.page2Store.dotList.onGetTIndex()
		return 0
	end

	self.page2Store.taskList.luaSimpleRenderItem = self:CreateAction("OnRenderPage2TaskListItem")

	function self.page2Store.taskList.onGetTIndex()
		return 0
	end

	self.page2Store.unlockDotList.luaSimpleRenderItem = self:CreateAction("OnRenderUnlockDotListItem")

	function self.page2Store.unlockDotList.onGetTIndex()
		return 0
	end

	self.page2Store.receiveBtn.luaClick = self:CreateAction("OnClickPage2ReceiveBtn")
end

function M:OnRenderHeadListItem(btn, index)
	local data = self.allAgents[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileCharacterTemplateNew"):GetStoreById(id)

	if store then
		local profileId = data.id
		local config = AgentProfileConfig.GetConfig(profileId)
		local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(profileId)
		local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon

		if iconId > 0 then
			store.iconId = iconId
		end

		store.lockCtrl = isAcquainted and self.agentStateCtrlEnum.unlock or self.agentStateCtrlEnum.lock
		store.canJoinCtrl = config.CanJoin and 0 or 1
		store.name = isAcquainted and config.Name or ""

		if isAcquainted then
			local isNew = gAgentTrustManager:CheckIfNewAcquaintedByProfileId(profileId)
			local hasReward = gAgentTrustManager:CheckHasRewardCanGot(profileId)

			if hasReward then
				store.newCtrl = 2
			elseif isNew then
				store.newCtrl = 1
			else
				store.newCtrl = 0
			end

			local rewards = config.TrustReward
			local allRewardsGot = false

			if rewards and #rewards > 0 then
				allRewardsGot = true

				for _, rewardId in ipairs(rewards) do
					local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

					if rewardCfg and rewardCfg.RewardType ~= RewardType.Disable and not gAgentTrustManager:CheckRewardGot(profileId, rewardId) then
						allRewardsGot = false

						break
					end
				end
			end

			if allRewardsGot then
				store.maxCtrl = 1

				store.rewardDotList:SetSimpleList(0)

				if store.anim and not store.hasPlayedRewardMaxAnim then
					gCS.LuaUtils.PlayAnimationByName(store.anim, "S_CharacterTemplateNew_RewardMax")

					store.hasPlayedRewardMaxAnim = true
				end
			else
				store.maxCtrl = 0
				store.hasPlayedRewardMaxAnim = false

				if rewards and #rewards > 0 then
					store.rewardDotList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderHeadRewardDotItem", {
						profileId = profileId,
						rewards = rewards
					})

					store.rewardDotList:SetSimpleList(#rewards)
				else
					store.rewardDotList:SetSimpleList(0)
				end

				store.anim:Stop()
			end
		else
			store.newCtrl = 0
			store.maxCtrl = 0
		end

		store.guide.guideID = data.guide
		store.guide.targetScrollableWidget = self.profileHeadListStore.headList
		store.guide.targetMaskWidget = self.profileHeadListStore.headList
	end
end

function M:OnRenderHeadRewardDotItem(params, btn, index)
	local profileId = params.profileId
	local rewards = params.rewards
	local rewardId = rewards[index + 1]

	if not rewardId then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		if rewardCfg and rewardCfg.RewardType == RewardType.Disable then
			store.fillCtrl = 0
		else
			local nowTrust = gAgentTrustManager:GetTrustValue(profileId)
			local canGet = rewardCfg and rewardCfg.NeedTrust <= nowTrust
			store.fillCtrl = canGet and 0 or 1
		end
	end
end

function M:OnClickHeadList(btn, index)
	local data = self.allAgents[index + 1]

	if not data then
		return
	end

	self.selectAgentProfileId = data.id
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	self.bindData.giftCtrl = 0

	self:RefreshAgentSelect()
	self:SwitchToCorrectArea()
end

function M:OnHeadListSelectedChanged()
	local selectIndex = self.profileHeadListStore.headList.selectedIndex

	if selectIndex == -1 then
		return
	end

	local data = self.allAgents[selectIndex + 1]

	if data then
		self.selectAgentProfileId = data.id
		self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
		self.bindData.giftCtrl = 0

		self:RefreshAgentSelect()
		self:SwitchToCorrectArea()
	end
end

function M:OnGetHeadListTIndex()
	return 0
end

function M:OnRenderFeatureListItem(btn, index)
	local data = self.featuresData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileDetailType"):GetStoreById(id)

	if store then
		store.iconId = data.icon
		store.title = data.name
		store.des = data.desc
	end
end

function M:OnClickFeatureListItem(btn, index)
	return
end

function M:OnLuaLayoutSet()
	local targetHeight = self.profileDetailAreaStore.layoutBox.rectTransform.rect.height
	local currentSizeDelta = self.profileDetailArea.rectTransform.sizeDelta
	local oldHeight = currentSizeDelta.y
	local heightDelta = targetHeight - oldHeight
	self.profileDetailArea.rectTransform.sizeDelta = Vector2.New(currentSizeDelta.x, targetHeight)

	if heightDelta ~= 0 then
		local layoutBoxPos = self.profileDetailAreaStore.layoutBox.rectTransform.anchoredPosition
		self.profileDetailAreaStore.layoutBox.rectTransform.anchoredPosition = Vector2.New(layoutBoxPos.x, layoutBoxPos.y + heightDelta / 2)
	end
end

function M:OnGetFeatureListTIndex()
	return 0
end

function M:OnRenderDetailRewardListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileRewardTemplateNew"):GetStoreById(id)

	if store then
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

		if rewardCfg and rewardCfg.GuideId then
			store.guide.guideID = rewardCfg.GuideId
			store.guide.targetScrollableWidget = self.profileDetailAreaStore.rewardList
			store.guide.targetMaskWidget = self.profileDetailAreaStore.rewardList
		end
	end
end

function M:OnClickRewardListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	self.selectedRewardData = data
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.reward

	self:RefreshRewardPage()
	self:SwitchToCorrectArea()
	self:CheckAndShowLastRewardTip()
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

	gAgentTrustManager:TakeProfileTrustReward(self.selectAgentProfileId, data.id, function ()
		self:RefreshReward()
		self:RefreshHeadList()
		gDropManager:ShowRewardWindow({
			ExtraRewardParam = 2,
			Param = previewMaterials
		})
	end)
end

function M:RefreshRewardPage()
	local data = self.selectedRewardData
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	self.page2Store.rewardTitle = data.name or ""
	self.page2Store.bigIconId = data.bigIconId or 0
	self.page2Store.desText = data.desc or ""
	local name = config.Name or ""
	self.page2Store.nameText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901328).Text, name)
	local locateCtrl = gAgentTrustManager:GetAgentLocateCtrl(self.selectAgentProfileId)
	local isResting = locateCtrl == 2

	if data.isGot then
		self.page2Store.receiveCtrl = 1

		self.page2Store.anim:Stop()
	elseif data.canGet then
		if isResting then
			self.page2Store.receiveCtrl = 3

			self.page2Store.anim:Stop()
		else
			self.page2Store.receiveCtrl = 0

			gCS.LuaUtils.PlayAnimationByName(self.page2Store.anim, self.rewardTipsAnime)
		end
	else
		self.page2Store.receiveCtrl = 2

		self.page2Store.anim:Stop()
	end

	self.page2Store.receiveBtn.interactable = self.page2Store.receiveCtrl ~= 3
	local isLocked = not data.isGot and not data.canGet
	self.page2Store.unlockCondActive = isLocked
	self.shouldPlayTipAnimForFirstUnfinishedTask = isLocked

	if isLocked then
		self.page2Store.unlockDotList:SetSimpleList(data.rewardIndex)
	end

	local rewardConfig = AgentProfileRewardConfig.GetConfig(data.id)
	local itemTypeCtrl = self.rewardTypeCtrlEnum.items

	if rewardConfig and rewardConfig.DropId then
		itemTypeCtrl = gAgentTrustManager:GetRewardItemType(rewardConfig.DropId)
	end

	self.bindData.rewardTypeCtrl = itemTypeCtrl
	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)
	local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon
	self.page2Store.headIconId = iconId or 0

	self.page2Store.rewardItemList:SetSimpleList(#self.rewardListData)
	self.page2Store.dotList:SetSimpleList(#self.rewardListData)
	self:RefreshPage2TaskList()
end

function M:RefreshPage2TaskList()
	if not self.page2Store then
		return
	end

	local targets = AgentProfileConfig.GetConfig(self.selectAgentProfileId).TrustTarget

	table.clear(self.targetsData)

	for _, id in ipairs(targets) do
		local data = {}
		local cfg = AgentProfileTargetConfig.GetConfig(id)
		data.id = id
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
	self.page2Store.taskList:SetSimpleList(#self.targetsData)
end

function M:OnRenderPage2RewardListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileSmallRewardTemplate"):GetStoreById(id)

	if store then
		store.smallIconId = data.iconId or 0
		store.indexText = string.format("%02d", index + 1)

		if self.selectedRewardData and self.selectedRewardData.id == data.id then
			store.typeCtrl = 1
		else
			store.typeCtrl = 0
		end

		if data.isGot then
			store.giftCtrl = 2
		elseif data.canGet then
			store.giftCtrl = 1
		else
			store.giftCtrl = 0
		end

		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)
		store.qualityCtrl = rewardCfg.Quality
	end
end

function M:OnRenderPage2DotListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)

		if rewardCfg and rewardCfg.RewardType == RewardType.Disable then
			store.fillCtrl = 0
		else
			store.fillCtrl = (data.isGot or data.canGet) and 0 or 1
		end
	end
end

function M:OnRenderUnlockDotListItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		store.fillCtrl = 0
	end
end

function M:OnRenderPage2TaskListItem(btn, index)
	local data = self.targetsData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewAgentProfileTargetTemplate"):GetStoreById(id)

	if store then
		store.targetText = data.desc or ""
		store.finishCtrl = data.isFinished and 0 or 1

		if data.isFinished and store.anim then
			local isTargetNew = gAgentTrustManager:CheckIfTargetIsNew(self.selectAgentProfileId, data.id)

			if isTargetNew then
				local profileId = self.selectAgentProfileId
				local targetId = data.id
				local animComp = store.anim

				gClientToGameDelegate:AskNpcProfileCancelTargetNewState(profileId, targetId).Callback = function (errId)
					if errId ~= 0 then
						gDisplayMessageMgr:ShowMessage(errId)

						return
					end

					gAgentTrustManager:UpdateTargetNewStatus(profileId, targetId)
					gCS.LuaUtils.PlayAnimationByName(animComp, self.finishAnime)
				end
			end
		end

		if self.shouldPlayTipAnimForFirstUnfinishedTask and index == 0 and not data.isFinished and store.anim then
			gCS.LuaUtils.PlayAnimationByName(store.anim, self.tipAnime)

			self.shouldPlayTipAnimForFirstUnfinishedTask = false
		end

		local targetCfg = AgentProfileTargetConfig.GetConfig(data.id)

		if targetCfg and targetCfg.GuideId then
			store.guide.guideID = targetCfg.GuideId
			store.guide.targetScrollableWidget = self.page2Store.taskList
			store.guide.targetMaskWidget = self.page2Store.taskList
		end
	end
end

function M:OnClickPage2RewardItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	self.selectedRewardData = data

	self.page2Store.rewardItemList:SelectItem(index, false)
	self:RefreshRewardPage()
	self:SwitchToCorrectArea()
	self:CheckAndShowLastRewardTip()
end

function M:OnClickPage2ReceiveBtn()
	if not self.selectedRewardData or not self.selectedRewardData.canGet then
		return
	end

	local data = self.selectedRewardData

	if data.rewardType == RewardType.UI then
		self:ShowRewardPreviewWindowFromPage2(data)
	elseif data.rewardType == RewardType.InPerson then
		self:OnClickLocationBtn()
	end
end

function M:ShowRewardPreviewWindowFromPage2(data)
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

	gAgentTrustManager:TakeProfileTrustReward(self.selectAgentProfileId, data.id, function ()
		self:RefreshReward()
		self:RefreshHeadList()
		self:RefreshRewardPage()
		gDropManager:ShowRewardWindow({
			ExtraRewardParam = 2,
			Param = previewMaterials
		})
	end)
end

function M:OnGetDetailRewardListTIndex()
	return 0
end

function M:CheckAndShowLastRewardTip()
	if self.hasShownLastRewardTip then
		return
	end

	if not self.selectedRewardData or #self.rewardListData == 0 then
		return
	end

	local lastReward = self.rewardListData[#self.rewardListData]

	if self.selectedRewardData.id == lastReward.id then
		self.hasShownLastRewardTip = true
		local profileConfig = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
		local animName = profileConfig.SpecialRewardAnim

		if not string.is_null_or_empty(animName) then
			FrameTimer.New(function ()
				self.page2Store.rewardAnim:Play(animName)
			end, 1, 1):Start()
		end
	end
end

function M:OnRenderRewardDotListItem(btn, index)
	local data = self.rewardListData[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("AgentProfileBlueDot"):GetStoreById(id)

	if store then
		local rewardCfg = AgentProfileRewardConfig.GetConfig(data.id)

		if rewardCfg and rewardCfg.RewardType == RewardType.Disable then
			store.fillCtrl = 0
		else
			store.fillCtrl = (data.isGot or data.canGet) and 0 or 1
		end
	end
end

function M:OnGetRewardDotListTIndex()
	return 0
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
	local store = gStoreManager:GetStoreGroup("ProgressRewardListStore"):GetStoreById(id)

	if store then
		store.percentText = string.format("%.0f%%", data.percent * 100)

		if store.rewardList then
			store.rewardList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderTotalProgressSubRewardItem", {
				rewards = data.rewards,
				canGet = data.canGet,
				isGot = data.isGot,
				data = data
			})
			store.rewardList.luaSimpleClick = self:CreateActionWithArgs("OnClickTotalProgressSubRewardItem", {
				mainIndex = index,
				data = data
			})
			store.rewardList.luaSelectedChanged = self:CreateActionWithArgs("OnFocusTotalProgressSubRewardItem", {
				data = data
			})

			store.rewardList:SetSimpleList(#data.rewards)
		end
	end
end

function M:OnRenderTotalProgressSubRewardItem(params, btn, index)
	local data = params.data
	local rewards = params.rewards
	local canGet = params.canGet
	local isGot = params.isGot
	local reward = rewards[index + 1]

	if not reward then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ProgressRewardBaseNewStore"):GetStoreById(id)

	if store then
		data.btn = btn
		local itemNum = reward.Count == 1 and 0 or reward.Count
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = reward.ItemId,
			itemNum = itemNum,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
			IsOwned = isGot,
			isLock = not canGet and not isGot
		})

		gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
	end
end

function M:OnClickTotalProgressRewardItem()
	return
end

function M:OnFocusLastTotalReward()
	local data = self.lastTotalReward

	self.bindData.lastTotalReward:ChangeButtonNameByActionId(3, data.canGet and 23 or 9)
end

function M:OnClickLastTotalReward()
	if not self.lastTotalReward then
		return
	end

	local data = self.lastTotalReward

	if data.canGet then
		self:TakeCompletionRewardWithPreview(data)
	elseif self.currentTipRewardIndex == -1 and self.bindData.tipActive then
		self:HideTotalProgressRewardTip()
	else
		self:ShowTotalProgressRewardTip(data, -1, 0)
	end
end

function M:OnFocusTotalProgressSubRewardItem(params)
	local data = params.data

	if data and data.btn then
		data.btn:ChangeButtonNameByActionId(3, data.canGet and 23 or 9)
	end
end

function M:OnClickTotalProgressSubRewardItem(params, btn, subIndex)
	local mainIndex = params.mainIndex
	local data = params.data

	if data.canGet then
		self:TakeCompletionRewardWithPreview(data)
	elseif self.currentTipRewardIndex == mainIndex and self.currentTipSubRewardIndex == subIndex and self.bindData.tipActive then
		self:HideTotalProgressRewardTip()
	else
		self:ShowTotalProgressRewardTip(data, mainIndex, subIndex)
	end
end

function M:OnGetTotalProgressRewardTIndex()
	return 0
end

function M:ShowTotalProgressRewardTip(data, mainIndex, subIndex)
	local reward = subIndex > 0 and data.rewards[subIndex + 1] or data.rewards and data.rewards[1] or nil

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

	self:TakeCompletionReward(data.index, function ()
		self.bindData.tipActive = false
		self.currentTipRewardIndex = nil
		self.currentTipSubRewardIndex = nil

		self:RefreshTotalProgressRewardList()
		gDropManager:ShowRewardWindow({
			ExtraRewardParam = 2,
			Param = previewMaterials
		})
	end)
end

function M:TakeCompletionReward(index, cb)
	gClientToGameDelegate:AskTakeNpcProfileProgressReward(index - 1).Callback = function (errId)
		if errId ~= 0 then
			print_warn("AskTakeNpcProfileProgressReward failed, err = " .. gCS.Error.GetNameById(errId))

			return
		end

		gAgentTrustManager:UpdateProgressRewardGot(index - 1)
		self:RefreshTotalProgressRewardList()

		if cb then
			cb()
		end
	end
end

function M:InitProfileData()
	local count = AgentProfileConfig.count
	local firstSelect = nil

	for i = 0, count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local data = {
				id = config.Id,
				guide = config.GuideId,
				orderIndex = config.OrderIndex or 0
			}

			if firstSelect == nil then
				firstSelect = data.id
			end

			if self.selectAgentProfileId == nil and gAgentTrustManager:GetIfAcquaintedByProfileId(data.id) then
				self.selectAgentProfileId = data.id
			end

			table.insert(self.allAgents, data)
		end
	end

	table.sort(self.allAgents, function (a, b)
		return a.orderIndex < b.orderIndex
	end)

	if self.selectAgentProfileId == nil then
		self.selectAgentProfileId = firstSelect
	end
end

function M:RefreshHeadList()
	self.profileHeadListStore.headList:SetSimpleList(#self.allAgents)
end

function M:RefreshAgentSelect()
	local isAcquainted = gAgentTrustManager:GetIfAcquaintedByProfileId(self.selectAgentProfileId)
	self.bindData.agentStateCtrl = isAcquainted and self.agentStateCtrlEnum.unlock or self.agentStateCtrlEnum.lock
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local iconId = isAcquainted and config.HeadIcon or config.LockedHeadIcon

	if iconId > 0 then
		self.bindData.agentAvatarIconId = iconId
	end

	self.bindData.npcNameText = config.Name
	self.bindData.locateCtrl = gAgentTrustManager:GetAgentLocateCtrl(self.selectAgentProfileId)

	if not isAcquainted then
		self.profileDetailArea:SetActive(false)

		self.bindData.lockTip = config.UnlockClue or "test"
		self.bindData.giftNum = 0
		self.bindData.giftActive = false

		self.bindData.navToDetailBtn:SetActive(false)

		return
	end

	self.bindData.navToDetailBtn:SetActive(true)

	local hasRewardCanGet = gAgentTrustManager:CheckHasRewardCanGot(self.selectAgentProfileId)
	self.bindData.giftActive = self.bindData.locateCtrl == 0 and hasRewardCanGet
	self.bindData.locationBtn.interactable = self.bindData.locateCtrl == 0

	self.profileDetailArea:SetActive(true)

	local isNew = gAgentTrustManager:CheckIfNewAcquaintedByProfileId(self.selectAgentProfileId)

	if isNew then
		gClientToGameDelegate:AskCancelNpcProfileNew(self.selectAgentProfileId).Callback = function (errId)
			if errId ~= 0 then
				gDisplayMessageMgr:ShowMessage(errId)

				return
			end

			gAgentTrustManager:UpdateProfileNewStatus(self.selectAgentProfileId)
			self:RefreshIconRedPoint(self.selectAgentProfileId)
		end
	end

	self.profileDetailAreaStore.npcDescText = config.Description

	self:RefreshRedPoint()
	self:RefreshFeature()
	self:RefreshReward()
	self.bindData.rewardDotList:SetSimpleList(#self.rewardListData)

	local canGetCount = 0

	for _, reward in ipairs(self.rewardListData) do
		if reward.canGet then
			canGetCount = canGetCount + 1
		end
	end

	self.bindData.giftNum = canGetCount

	self:RefreshUrbanAttribute()
	self:RefreshMapIconList()
end

function M:RefreshRedPoint()
	self.bindData.redPointCtrl = gAgentTrustManager:CheckHasRewardCanGot(self.selectAgentProfileId) and self.completeCtrlEnum._true or self.completeCtrlEnum._false

	self:RefreshIconRedPoint(self.selectAgentProfileId)
end

function M:RefreshIconRedPoint(profileId)
	if not self.profileHeadListStore or not self.profileHeadListStore.headList or not self.allAgents then
		return
	end

	for i, data in ipairs(self.allAgents) do
		if data and data.id == profileId then
			self.profileHeadListStore.headList:RefreshElement(i - 1)

			break
		end
	end
end

function M:RefreshFeature()
	if not self.profileDetailAreaStore then
		return
	end

	local features = AgentProfileConfig.GetConfig(self.selectAgentProfileId).Characteristic

	table.clear(self.featuresData)

	for _, id in ipairs(features) do
		local cfg = AgentProfileCharacteristicConfig.GetConfig(id)

		table.insert(self.featuresData, {
			name = cfg.Name,
			icon = cfg.Image,
			desc = cfg.Description
		})
	end

	self.profileDetailAreaStore.featureList:SetSimpleList(#self.featuresData)
end

function M:RefreshReward()
	if not self.selectAgentProfileId or not self.profileDetailAreaStore then
		return
	end

	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local nowTrust = gAgentTrustManager:GetTrustValue(self.selectAgentProfileId)
	local sortedRewards = {}

	for _, rewardId in ipairs(config.TrustReward) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		table.insert(sortedRewards, {
			id = rewardId,
			needTrust = rewardCfg.NeedTrust,
			cfg = rewardCfg
		})
	end

	table.sort(sortedRewards, function (a, b)
		return a.needTrust < b.needTrust
	end)

	local nextTargetIndex = -1

	for i, item in ipairs(sortedRewards) do
		if nowTrust < item.needTrust then
			nextTargetIndex = i

			break
		end
	end

	table.clear(self.rewardListData)

	for i, item in ipairs(sortedRewards) do
		local rewardCfg = item.cfg
		local isDisableReward = rewardCfg.RewardType == RewardType.Disable
		local isGot = isDisableReward or gAgentTrustManager:CheckRewardGot(self.selectAgentProfileId, rewardCfg.Id)

		table.insert(self.rewardListData, {
			id = rewardCfg.Id,
			needTrust = rewardCfg.NeedTrust,
			rewardIndex = i,
			isGot = isGot,
			canGet = not isDisableReward and rewardCfg.NeedTrust <= nowTrust and not isGot,
			name = rewardCfg.Description,
			desc = rewardCfg.DetailExplain,
			iconId = rewardCfg.SmallIconId,
			bigIconId = rewardCfg.IconId,
			rewardType = rewardCfg.RewardType,
			isNextTarget = i == nextTargetIndex,
			nowTrust = nowTrust
		})
	end

	self.profileDetailAreaStore.rewardList:SetSimpleList(#self.rewardListData)

	self.profileDetailAreaStore.listNumCtrl = #self.rewardListData > 0 and math.min(#self.rewardListData - 1, 4) or 0
end

function M:RefreshUrbanAttribute()
	local config = AgentProfileConfig.GetConfig(self.selectAgentProfileId)
	local urbanAttrs = config.UrbanAttribute
	local lifeAttrRuleList = gSpiritManager:GetUrbanRuleList(true)

	for i = 1, #urbanAttrs do
		self.profileDetailAreaStore.radarChart:SetVertexValue(i - 1, urbanAttrs[i])

		local store = gStoreManager:GetStoreGroup("Xuwei6DemensionInfoStore"):GetStoreByWidget(self.profileDetailAreaStore["radarTitle" .. i])

		if store then
			store.icon = lifeAttrRuleList[i].attrIcon
			store.nameLabel = urbanAttrs[i]
		end
	end
end

function M:InitBaseMap()
	self.baseMap = gBaseMapMgr:GetBaseMap(self.bindData.baseMap)

	if not self.baseMap then
		return
	end

	self.baseMap:SetFixedScaleLevel(1)
	self.baseMap:SetMapInfo(gMapSystem.area:GetAreaId(LTConfig.RaidConfig.WorldMap, 0), 1)

	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if not playerUnit then
		return
	end

	local pos = playerUnit.LocalPosition
	self.playerPos = pos

	self.baseMap:Align(pos, self.bindData.anchor)
	self.bindData.playerIcon:SetParent(self.bindData.mapRT)

	local texPosX, texPosY = self.baseMap:TransformWorldPosXZ2TexPosXY(pos.x, pos.z)

	self.bindData.playerIcon:SetLocalPositionXY(texPosX, texPosY)
	self:RefreshMapIconList()
end

function M:RefreshMapIconList()
	if not self.bindData.mapIconFreeList or not self.baseMap then
		return
	end

	table.clear(self.agentPositionCache)

	local validAgents = {}

	for _, agent in ipairs(self.allAgents) do
		if gAgentTrustManager:GetIfAcquaintedByProfileId(agent.id) then
			local worldPos = gAgentTrustManager:GetAgentActualPosition(agent.id)

			if worldPos then
				local texPosX, texPosY = self.baseMap:TransformWorldPosXZ2TexPosXY(worldPos.x, worldPos.z)
				local mapPos = Vector2.New(texPosX, texPosY)
				self.agentPositionCache[agent.id] = {
					worldPos = worldPos,
					mapPos = mapPos
				}

				table.insert(validAgents, agent)
			end
		end
	end

	self.validMapAgents = validAgents
	local mapSize = self.baseMap.mapCfg and self.baseMap.mapCfg.mapSize

	self.bindData.mapIconFreeList:SetSize(mapSize)
	self.bindData.mapIconFreeList:SetList(#validAgents)
end

function M:OnRenderMapIconItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.validMapAgents and self.validMapAgents[index]

	if not data then
		return
	end

	local cachedPos = self.agentPositionCache[data.id]

	if cachedPos and cachedPos.mapPos then
		btn.rectTransform.anchoredPosition = cachedPos.mapPos
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local config = AgentProfileConfig.GetConfig(data.id)
	local maxTrust = config.MaxTrust or 1
	local nowTrust = gAgentTrustManager:GetTrustValue(data.id) or 0
	local trustPercent = maxTrust > 0 and nowTrust / maxTrust or 0
	local locatedCtrl = 0

	if trustPercent >= 1 then
		locatedCtrl = 4
	elseif trustPercent >= 0.75 then
		locatedCtrl = 3
	elseif trustPercent >= 0.5 then
		locatedCtrl = 2
	elseif trustPercent >= 0.25 then
		locatedCtrl = 1
	else
		locatedCtrl = 0
	end

	store.locatedCtrl = locatedCtrl

	if locatedCtrl == 4 then
		store.iconId = config.FactionIcon
	end
end

function M:OnClickMapIcon(btn, csIndex)
	local data = self.validMapAgents and self.validMapAgents[csIndex + 1]

	if not data then
		return
	end

	self.selectAgentProfileId = data.id
	self.bindData.showDetailsCtrl = self.showDetailsCtrlEnum.list
	local index = self:GetListIndexByProfileId(self.selectAgentProfileId)

	self.profileHeadListStore.headList:SelectItem(index, true)
	self.profileHeadListStore.headList:SetNavSelectToSelect()
	self:SwitchToCorrectArea()
end

function M:RefreshTotalProgress()
	local completedWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			if gAgentTrustManager:GetIfAcquaintedByProfileId(config.Id) then
				completedWeight = completedWeight + (config.Weight or 0)
			end

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig and gAgentTrustManager:CheckTargetFinish(config.Id, targetId) then
					completedWeight = completedWeight + (targetConfig.Weight or 0)
				end
			end
		end
	end

	local progress = self.totalProgressWeight > 0 and completedWeight / self.totalProgressWeight or 0
	self.bindData.totalProgress = progress
	self.bindData.totalProgressText = string.format("%.0f%%", math.floor(progress * 100))
end

function M:RefreshTotalProgressRewardList()
	local rewards = gAgentTrustManager:GetCompletionRewards(self.bindData.totalProgress or 0)

	table.clear(self.totalProgressRewardListData)

	if #rewards > 0 then
		local lastReward = rewards[#rewards]
		self.bindData.lastTotalPercent = string.format("%.0f", lastReward.percent * 100) .. "%"
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(lastReward.dropId, 1)
		local rewardItems = {}

		for _, item in ipairs(fakeItems) do
			local itemConfig = LTConfig.CommonItemConfig.GetConfig(item.Id)

			table.insert(rewardItems, {
				ItemId = item.Id,
				IconId = itemConfig and itemConfig.SItemIconId or 0,
				Count = item.Count,
				Quality = itemConfig and itemConfig.Quality or 0
			})
		end

		self.lastTotalReward = {
			index = lastReward.index,
			percent = lastReward.percent,
			dropId = lastReward.dropId,
			canGet = lastReward.canGet,
			isGot = lastReward.isGot,
			rewards = rewardItems
		}

		self:RefreshLastTotalReward()
	else
		self.bindData.lastTotalPercent = 0
		self.lastTotalReward = nil
	end

	for i = 1, #rewards - 1 do
		local reward = rewards[i]
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(reward.dropId, 1)
		local rewardItems = {}

		for _, item in ipairs(fakeItems) do
			local itemConfig = LTConfig.CommonItemConfig.GetConfig(item.Id)

			table.insert(rewardItems, {
				ItemId = item.Id,
				IconId = itemConfig and itemConfig.SItemIconId or 0,
				Count = item.Count,
				Quality = itemConfig and itemConfig.Quality or 0
			})
		end

		local listData = {
			index = reward.index,
			percent = reward.percent,
			dropId = reward.dropId,
			canGet = reward.canGet,
			isGot = reward.isGot,
			rewards = rewardItems
		}

		table.insert(self.totalProgressRewardListData, listData)
	end

	self.bindData.totalProgressList:SetSimpleList(#self.totalProgressRewardListData)
	self:RefreshTotalProgressRedDot()
end

function M:RefreshLastTotalReward()
	if not self.lastTotalReward or not self.bindData.lastTotalReward then
		return
	end

	local data = self.lastTotalReward
	local store = gStoreManager:GetStoreGroup("ProgressRewardBaseNewStore"):GetStoreByWidget(self.bindData.lastTotalReward)
	store.percentText = string.format("%.0f", data.percent * 100)

	if data.rewards and #data.rewards > 0 then
		local reward = data.rewards[1]
		local itemNum = reward.Count == 1 and 0 or reward.Count
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = reward.ItemId,
			itemNum = itemNum,
			countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP,
			IsOwned = data.isGot,
			isLock = not data.canGet and not data.isGot
		})

		gCommonItemManager:OnCommonItemRender(store.commonItem, 0, itemData)
	end
end

function M:RefreshTotalProgressRedDot()
	local hasRewardCanGet = false

	for _, data in ipairs(self.totalProgressRewardListData) do
		if data.canGet then
			hasRewardCanGet = true

			break
		end
	end

	if not hasRewardCanGet and self.lastTotalReward and self.lastTotalReward.canGet then
		hasRewardCanGet = true
	end

	if self.bindData.totalProgressBtn then
		self.bindData.totalProgressBtn.redKey = "NewAgentProfilePanel_TotalProgress"

		SGUI.RedDotMgr.LuaSetRedDot(hasRewardCanGet, "NewAgentProfilePanel_TotalProgress")
	end
end

function M:InitMapInteraction()
	local dragListener = SGUI.EventSystems.DragEventListener.Get(self.bindData.mapRayBoxRT.gameObject)

	if dragListener then
		dragListener.onBeginDrag = self:CreateAction("OnMapBeginDrag")
		dragListener.onDrag = self:CreateAction("OnMapDrag")
		dragListener.onEndDrag = self:CreateAction("OnMapEndDrag")
	end

	local gestureListener = self.bindData.mapRayBoxRT:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))

	if gestureListener then
		gestureListener.onZoom = self:CreateAction("OnMapGestureZoom")
	end

	local clickListener = SGUI.EventSystems.ClickEventListener.Get(self.bindData.mapRayBoxRT.gameObject)

	if clickListener then
		clickListener.onClick = self:CreateAction("OnClickMapBtn")
	end

	dragListener = SGUI.EventSystems.DragEventListener.Get(self.bindData.mapRayBoxRT2.gameObject)

	if dragListener then
		dragListener.onBeginDrag = self:CreateAction("OnMapBeginDrag")
		dragListener.onDrag = self:CreateAction("OnMapDrag")
		dragListener.onEndDrag = self:CreateAction("OnMapEndDrag")
	end

	gestureListener = self.bindData.mapRayBoxRT2:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))

	if gestureListener then
		gestureListener.onZoom = self:CreateAction("OnMapGestureZoom")
	end

	clickListener = SGUI.EventSystems.ClickEventListener.Get(self.bindData.mapRayBoxRT2.gameObject)

	if clickListener then
		clickListener.onClick = self:CreateAction("OnClickMapBtn")
	end
end

function M:OnMapBeginDrag(evtData)
	if evtData.button ~= 0 then
		return
	end

	self.lastDragPos = gUtils:GetTouchPosition()
end

function M:OnMapDrag(evtData)
	if evtData.button ~= 0 then
		return
	end

	if not self.lastDragPos or not self.bindData.mapRT then
		return
	end

	local currentPos = gUtils:GetTouchPosition()
	local delta = currentPos - self.lastDragPos
	local currentLocalPos = self.bindData.mapRT.localPosition
	local newPos = Vector3.New(currentLocalPos.x + delta.x, currentLocalPos.y + delta.y, currentLocalPos.z)
	newPos = self:ClampMapPosition(newPos)
	self.bindData.mapRT.localPosition = newPos
	self.lastDragPos = currentPos
end

function M:OnMapEndDrag(evtData)
	if evtData.button == 0 then
		self.lastDragPos = nil
	end
end

function M:OnMapGestureZoom(val)
	if not self.bindData.mapRT then
		return
	end

	local mouseScreenPos = UnityEngine.Input.mousePosition
	local mouseUIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.mapRT.parent, mouseScreenPos)
	local oldMapPos = self.bindData.mapRT.localPosition
	local oldScale = self.mapScale
	local newScale = math.exp(math.log(oldScale) + val * 0.002)

	if self.maxMapScale < newScale then
		newScale = self.maxMapScale
	elseif newScale < self.minMapScale then
		newScale = self.minMapScale
	end

	local offsetX = mouseUIPos.x - oldMapPos.x
	local offsetY = mouseUIPos.y - oldMapPos.y
	local scaleRatio = newScale / oldScale
	local newOffsetX = offsetX * scaleRatio
	local newOffsetY = offsetY * scaleRatio
	local newMapPosX = mouseUIPos.x - newOffsetX
	local newMapPosY = mouseUIPos.y - newOffsetY
	self.mapScale = newScale
	self.bindData.mapRT.localScale = Vector3.New(newScale, newScale, 1)
	local newPos = Vector3.New(newMapPosX, newMapPosY, oldMapPos.z)
	newPos = self:ClampMapPosition(newPos)
	self.bindData.mapRT.localPosition = newPos
end

function M:TickControllerZoom()
	local fixedDt = UnityEngine.Time.deltaTime
	local signZoom = self.controllerZoomInTrigger - self.controllerZoomOutTrigger

	if signZoom ~= 0 then
		local scaleChange = signZoom * self.CONTROLLER_ZOOM_SCALE * fixedDt
		local centerPos = Vector2.zero

		if self.bindData.ctrlerMouseRT then
			local mousePos = self.bindData.ctrlerMouseRT.localPosition
			centerPos = Vector2.New(mousePos.x, mousePos.y)
		end

		self:ApplyMapScale(scaleChange, centerPos)
	end

	if self.ctrlerInput.leftJS and self.bindData.mapRT then
		local moveOffset = self.ctrlerInput.leftJS * self.CONTROLLER_MAP_SENSITIVITY * fixedDt
		local currentLocalPos = self.bindData.mapRT.localPosition
		local newPos = Vector3.New(currentLocalPos.x - moveOffset.x, currentLocalPos.y - moveOffset.y, currentLocalPos.z)
		newPos = self:ClampMapPosition(newPos)
		self.bindData.mapRT.localPosition = newPos
	end

	self:SyncPointerScale()
	self:TickControllerAttach()
end

function M:SyncPointerScale()
	if self.bindData.ctrlerMouseRT then
		local uniformScale = 1 / self.mapScale

		self.bindData.ctrlerMouseRT:SetLocalScaleXY(self.mapScale, self.mapScale)
	end
end

function M:TickControllerAttach()
	if not self.isControllerMode or not self.bindData.ctrlerMouseRT or not self.bindData.mapRT then
		return
	end

	local nearestAgentId = self:FindNearestAgent()

	if nearestAgentId then
		if nearestAgentId ~= self.currentAttachedAgentId then
			self.currentAttachedAgentId = nearestAgentId

			self:ShowControllerAttachTip(nearestAgentId)
			self:PlayControllerPointerAttachAnim()
			gSoundMgr:PlaySoundByTid(70601120)
		end

		local mapDelta = self:AttachPointerToAgent(nearestAgentId)

		if mapDelta then
			local currentPos = self.bindData.mapRT.localPosition
			local newPos = Vector3.New(currentPos.x + mapDelta.x, currentPos.y + mapDelta.y, currentPos.z)
			newPos = self:ClampMapPosition(newPos)
			self.bindData.mapRT.localPosition = newPos
		end
	elseif self.currentAttachedAgentId then
		self.currentAttachedAgentId = nil

		self:HideControllerAttachTip()
		self:ResetControllerPointerAnim()
	end
end

function M:FindNearestAgent()
	if not self.bindData.ctrlerMouseRT or not self.validMapAgents then
		return nil
	end

	local pointerPos = self.bindData.ctrlerMouseRT.localPosition
	local pointerVec2 = Vector2.New(pointerPos.x, pointerPos.y)
	local detectRange = self.CONTROLLER_ATTACH_RANGE
	local nearestId = nil
	local nearestDist = detectRange

	for _, agent in ipairs(self.validMapAgents) do
		local cachedPos = self.agentPositionCache[agent.id]

		if cachedPos and cachedPos.mapPos then
			local mapRT = self.bindData.mapRT
			local iconUIPos = Vector2.New(cachedPos.mapPos.x * self.mapScale + mapRT.localPosition.x, cachedPos.mapPos.y * self.mapScale + mapRT.localPosition.y)
			local distance = Vector2.Distance(pointerVec2, iconUIPos)

			if distance < nearestDist then
				nearestDist = distance
				nearestId = agent.id
			end
		end
	end

	return nearestId
end

function M:ShowControllerAttachTip(agentId)
	if not self.bindData.controllerAttachBtn then
		return
	end

	self.bindData.controllerAttachBtn:SetActive(true)
end

function M:HideControllerAttachTip()
	if self.bindData.controllerAttachBtn then
		self.bindData.controllerAttachBtn:SetActive(false)
	end
end

function M:AttachPointerToAgent(agentId)
	local cachedPos = self.agentPositionCache[agentId]

	if not cachedPos or not cachedPos.mapPos then
		return nil
	end

	local pointerPos = self.bindData.ctrlerMouseRT.localPosition
	local pointerUiPos = Vector2.New(pointerPos.x, pointerPos.y)
	local mapRT = self.bindData.mapRT
	local iconUiPos = Vector2.New(cachedPos.mapPos.x * self.mapScale + mapRT.localPosition.x, cachedPos.mapPos.y * self.mapScale + mapRT.localPosition.y)
	local delta = pointerUiPos - iconUiPos
	local dir = Vector2.Normalize(delta)
	local distance = Vector2.Magnitude(delta)
	local fixedDt = UnityEngine.Time.deltaTime
	local step = self.CONTROLLER_POINTER_ATTACH_SPEED * fixedDt
	local mapMoveDelta = dir * (distance > step and step or distance)

	return mapMoveDelta
end

function M:ApplyMapScale(scaleChange, centerUIPos)
	if not self.bindData.mapRT then
		return
	end

	centerUIPos = centerUIPos or Vector2.zero
	local oldMapPos = self.bindData.mapRT.localPosition
	local oldScale = self.mapScale
	local newScale = oldScale + scaleChange

	if self.maxMapScale < newScale then
		newScale = self.maxMapScale
	elseif newScale < self.minMapScale then
		newScale = self.minMapScale
	end

	if newScale == oldScale then
		return
	end

	local offsetX = centerUIPos.x - oldMapPos.x
	local offsetY = centerUIPos.y - oldMapPos.y
	local scaleRatio = newScale / oldScale
	local newOffsetX = offsetX * scaleRatio
	local newOffsetY = offsetY * scaleRatio
	local newMapPosX = centerUIPos.x - newOffsetX
	local newMapPosY = centerUIPos.y - newOffsetY
	self.mapScale = newScale
	self.bindData.mapRT.localScale = Vector3.New(newScale, newScale, 1)
	local newPos = Vector3.New(newMapPosX, newMapPosY, oldMapPos.z)
	newPos = self:ClampMapPosition(newPos)
	self.bindData.mapRT.localPosition = newPos
end

function M:ClampMapPosition(pos)
	if not self.baseMap or not self.baseMap.mapCfg or not self.baseMap.mapCfg.mapSize then
		return pos
	end

	if not self.bindData.mapRT or not self.bindData.mapRT.parent then
		return pos
	end

	local mapSize = self.baseMap.mapCfg.mapSize
	local parentSize = gCS.LuaUtils.GetRectTransformSize(self.bindData.mapRT.parent)
	local scaledMapWidth = mapSize.x * self.mapScale
	local scaledMapHeight = mapSize.y * self.mapScale
	local maxX, minX, maxY, minY = nil

	if parentSize.x < scaledMapWidth then
		local halfMapWidth = scaledMapWidth * 0.5
		local halfParentWidth = parentSize.x * 0.5
		maxX = halfMapWidth - halfParentWidth
		minX = -(halfMapWidth - halfParentWidth)
	else
		maxX = 0
		minX = 0
	end

	if parentSize.y < scaledMapHeight then
		local halfMapHeight = scaledMapHeight * 0.5
		local halfParentHeight = parentSize.y * 0.5
		maxY = halfMapHeight - halfParentHeight
		minY = -(halfMapHeight - halfParentHeight)
	else
		maxY = 0
		minY = 0
	end

	local clampedX = math.max(minX, math.min(maxX, pos.x))
	local clampedY = math.max(minY, math.min(maxY, pos.y))

	return Vector3.New(clampedX, clampedY, pos.z)
end

function M:ResetMapTransform()
	if not self.bindData.mapRT then
		return
	end

	self.mapScale = 1
	self.bindData.mapRT.localScale = Vector3.New(1, 1, 1)
	self.bindData.mapRT.localPosition = Vector3.New(0, 0, 0)
end
