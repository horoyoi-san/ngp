C_CharMotionListPanelStore = DefClass("C_CharMotionListPanelStore", C_CharMotionListPanelStore, C_StoreGroup)
GroupName2Class.CharMotionListPanelStore = C_CharMotionListPanelStore
local M = C_CharMotionListPanelStore
local UXTime = LTUtils.UXTime

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnTabRenderItem")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.takePhotoButton.luaClick = self:CreateAction("OnTakePhotoClick")
	self.bindData.foldButton.luaClick = self:CreateAction("OnFoldClick")
	self.bindData.unfoldButton.luaClick = self:CreateAction("OnUnfoldClick")
	self.bindData.takePhotoFoldButton.luaClick = self:CreateAction("OnTakePhotoClick")
	self.bindData.exitFolderButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.stopButton.luaClick = self:CreateAction("OnStopClick")
	self.openTime = UXTime.GetNowUnixTime()

	self:InitGamePad()
	self:InitMessageEvents()
end

function M:InitGamePad()
	if self.bindData.rotateNavRespond then
		self.bindData.rotateNavRespond.luaGamePadInputChanged = self:CreateAction(self.OnRotateInputChange)
	end
end

function M:OnRotateInputChange(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:InitMessageEvents()
	local eventHandlers = {
		[gEventConstants.ON_ENTER_CHAR_MOTION_ANIMATION] = self:CreateAction("OnEnterCharMotionAnimation"),
		[gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION] = self:CreateAction("OnExitCharMotionAnimation"),
		[gEventConstants.ON_JOYSTICK_MOVE] = self:CreateAction("OnJoyStickMove"),
		[gEventConstants.ON_SYNC_MOTION_ACTION_REPLAY_INVITE_RESULT] = self:CreateAction("OnReplyInviteResult"),
		[gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION] = self:CreateAction("OnCancelInvitePlayerAction"),
		[gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION] = self:CreateAction("OnCancelInviteePlayerAction"),
		[gEventConstants.ADD_MAP_LUA_UNIT] = self:CreateAction("AddMapLuaUnit")
	}

	self:RegisterMessageEvents(eventHandlers)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.lastRotatedEnable = gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled
	self.isLinkMode = args and args.isLinkMode
	self.linkActionId = args and args.linkActionId
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.needUpdateCamera = nil
	self.currentPlayActionInfo = nil
	self.selectedTabIndex = 1
	self.selectedContentId = nil
	self.SELECTED_ITEM_STATUS = {
		NORMAL = 0,
		LOOP_PERFORMANCE = 3,
		PERFORMANCE = 1,
		LOCK = 2
	}
	self.ACTION_STATUS = {
		PREPARE = 2,
		PLAY = 3,
		BREAK = 4,
		NONE = 1
	}
	self.TAB_MOTION_TYPE = {
		SINGLE = 1,
		JOB = 3,
		DOUBLE = 2
	}
	self.showType = args and args.showType

	if not self.showType then
		self.showType = self.isLinkMode and gClientConst.MOTION_ACTION_SHOW_TYPE.Double or gClientConst.MOTION_ACTION_SHOW_TYPE.Single
	end

	if args and args.inviteePid then
		local _, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(args.inviteePid, ulong.zero)
		self.npcId = self.npcUnit.NpcId
		self.npcUnit = self.npcUnit
		self.npcPid = self.npcUnit.Pid
	else
		self.npcId = args and args.npcId

		self:InitTabTypeDataList()

		self.npcPid = args and args.npcPid
		self.npcUnit = self.npcPid and gCS.SceneDataMgr.GetUnit(self.npcPid)
		local agentQuoteId = self.npcUnit and self.npcUnit.ClientData.AgentId
		local actionQuoteCfg = LTConfig.AgentQuoteConfig.GetConfig(agentQuoteId)
		self.agentId = actionQuoteCfg and actionQuoteCfg.QuoteId
	end

	if self.isLinkMode and self.npcUnit then
		self.npcOwnerId = self.npcUnit.ClientData.OwnerId
		self.npcName = gBattleNetcodeUtils:GetUserName(self.npcOwnerId)
	end
end

function M:InitTabTypeDataList()
	local showType = self.showType
	self.tabTypeList = {}

	if showType == gClientConst.MOTION_ACTION_SHOW_TYPE.Single then
		self.tabTypeList = {
			{
				type = self.TAB_MOTION_TYPE.SINGLE,
				name = LTConfig.ActionItemConfig.SingleTypeName
			}
		}
	elseif showType == gClientConst.MOTION_ACTION_SHOW_TYPE.Double then
		if self.isLinkMode then
			self.tabTypeList = {
				{
					type = self.TAB_MOTION_TYPE.DOUBLE,
					name = LTConfig.ActionItemConfig.DoubleTypeName
				}
			}
		else
			self.tabTypeList = {
				{
					type = self.TAB_MOTION_TYPE.DOUBLE,
					name = LTConfig.ActionItemConfig.DoubleTypeName
				}
			}
		end
	end
end

function M:InitView(_)
	self.joyStickSortingOrder = SGUI.SguiJoystick.GetJoyStickSortingOrder()
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	self.bindData.npcThinkingNode:SetActive(false)

	self.bindData.fullScreenButton.dragActionHover = true
	local dragButton = SGUI.EventSystems.DragEventListener.Get(self.bindData.fullScreenButton.gameObject)
	dragButton.ignoreClickInDraging = true
	dragButton.onBeginDrag = self:CreateAction(self.OnBeginDrag)
	dragButton.onDrag = self:CreateAction(self.OnDrag)
	dragButton.onEndDrag = self:CreateAction(self.OnEndDrag)

	self.bindData.contentList:RegisterToScrollEvent(self:CreateAction("OnContentListOnScroll"))
	self:InitTabListView()
	self:RefreshTabContentView()

	self.motionInteractCheckModule = gCS.BaseUnitModuleUtils.GetOrAddMotionInteractCheckModule(gCS.MyPlayerManager.PlayerUnit)

	if self.motionInteractCheckModule then
		self.motionInteractCheckModule.CanStand = true

		function self.motionInteractCheckModule.OnCannotStandAction()
			self.currentPlayActionInfo = nil
			self.linkActionId = nil

			gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.NoEnoughSpaceMessage)
		end
	end

	self:SetShowJoystick(true)
end

function M:SetShowJoystick(isShow)
	if isShow then
		local sortingInOrder = gCS.LuaUtils.GetSortingInOrder(self.rootGo)

		SGUI.SguiJoystick.EnableTempSorting(isShow, sortingInOrder + 10)
		LX6.GUI.GuiMgr.Instance:SetShowJoystick(true, self.m_Id)
	else
		SGUI.SguiJoystick.EnableTempSorting(true, self.joyStickSortingOrder)
		LX6.GUI.GuiMgr.Instance:SetShowJoystick(false, self.m_Id)
	end
end

function M:InitTabListView()
	self.bindData.tabList:SetSimpleList(#self.tabTypeList)

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.tabControlLeftButton then
		if #self.tabTypeList > 1 then
			self.bindData.tabControlLeftButton.luaClick = self:CreateAction(self.OnTabControlLeftClick)
			self.bindData.tabControlRightButton.luaClick = self:CreateAction(self.OnTabControlRightClick)
		else
			self.bindData.tabControlLeftButton.gameObject:SetActive(false)
			self.bindData.tabControlRightButton.gameObject:SetActive(false)
		end
	end
end

function M:OnTabControlLeftClick()
	self:OnTabItemClick(1)
end

function M:OnTabControlRightClick()
	self:OnTabItemClick(2)
end

function M:OnTabRenderItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.tabTypeList[luaIndex]
	local typeIndex = table.find(self.TAB_MOTION_TYPE, data.type)
	local iconId = self:GetTypeIconId(data.type)
	store.iconId = iconId
	local redDotKey = ("CharMotionListTab:%d"):format(typeIndex)
	store.button.redKey = redDotKey
	store.button.isSelected = self.selectedTabIndex == luaIndex
	store.button.luaClick = self:CreateActionWithArgs(self.OnTabItemClick, luaIndex)
	local hasRedDot = self:CheckTabHasRedDot(data.type)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

function M:OnTabItemClick(index)
	if self.selectedTabIndex == index then
		return
	end

	self.selectedTabIndex = index

	self:RefreshTabContentView()
end

function M:RefreshTabContentView()
	local tabData = self.tabTypeList[self.selectedTabIndex]
	self.bindData.typeName = tabData.name
	local actionType = tabData.type
	self.contentDataList = self:GetViewDataListByActionType(actionType)

	table.sort(self.contentDataList, function (data1, data2)
		local hasUnlocked1 = self:CheckActionHasUnlocked(data1.id)
		local hasUnlocked2 = self:CheckActionHasUnlocked(data2.id)

		if hasUnlocked1 ~= hasUnlocked2 then
			return hasUnlocked1
		end

		local actionItemCfg1 = LTConfig.ActionItemConfig.GetConfig(data1.id)
		local actionItemCfg2 = LTConfig.ActionItemConfig.GetConfig(data1.id)

		if actionItemCfg1.Quality ~= actionItemCfg2.Quality then
			return actionItemCfg2.Quality < actionItemCfg1.Quality
		end

		return data1.id < data2.id
	end)

	self.roundViewDataList = self:GetRoundViewDataList(self.contentDataList)

	self.bindData.pageList:SetSimpleList(#self.roundViewDataList)
	self.bindData.pageList:SetItemSelected(0, true)
	self.bindData.contentList:SetSimpleList(#self.contentDataList)

	self.bindData.emptyControl = self.selectedContentId and 0 or 1

	self.bindData.contentList:SetScrollDisabled(#self.contentDataList <= 8)
end

function M:GetRoundViewDataList(viewDataList)
	local pageCount = math.ceil(#viewDataList / 9)
	local roundViewDataList = {}

	for i = 1, pageCount do
		table.insert(roundViewDataList, {
			id = i
		})
	end

	return roundViewDataList
end

function M:GetViewDataListByActionType(actionType)
	local viewDataList = {}
	local count = LTConfig.ActionItemConfig.count

	for i = 0, count - 1 do
		local actionItemCfg = LTConfig.ActionItemConfig.LoadAt(i)

		if actionItemCfg.Type == actionType and self:CheckActionItemCanShow(actionItemCfg.Id) then
			table.insert(viewDataList, {
				id = actionItemCfg.Id
			})
		end
	end

	return viewDataList
end

function M:CheckActionItemCanShow(id)
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local ownerConditionMeet = #actionItemCfg.SpiritId == 0 or table.contains(actionItemCfg.SpiritId, currentSpiritId)

	if not ownerConditionMeet then
		return false
	end

	if self.npcId and not self.isLinkMode then
		local actionId = self:GetNpcActionId(id)

		if not actionId then
			return false
		end
	end

	if self.isLinkMode then
		if not actionItemCfg.IsLinkShow then
			return false
		end

		if #actionItemCfg.LinkSpiritId > 0 then
			local linkSpiritId = self.npcId

			return table.contains(actionItemCfg.LinkSpiritId, linkSpiritId)
		end
	end

	return true
end

function M:OnContentRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(data.id)
	store.name = actionItemCfg.Name
	store.iconId = actionItemCfg.Icon
	local hasUnlocked = self:CheckActionHasUnlocked(data.id)
	store.selectedControl = self.selectedContentId == data.id and 1 or 0
	local redDotKey = ("CharMotionListActionItem:%d"):format(data.id)
	store.button.redKey = redDotKey
	local hasRedDot = self:CheckActionHasRedDot(data.id)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	store.greyControl = hasUnlocked and self:CheckHasMeetFavor(data.id) and 0 or 1
	local loopAnimationName = "S_vx_ActionPermancing_Loop"
	local currentStatus = self:GetActionPerformanceStatus(actionItemCfg.Id)

	if store.statusControl ~= currentStatus then
		gClientUtils.ResetAnimation(store.loopAnimation, loopAnimationName)
	end

	store.statusControl = currentStatus
	store.id = data.id
	store.button.luaClick = self:CreateActionWithArgs("OnContentItemClick", data.id)
	store.statusControl = currentStatus

	if store.statusControl == self.SELECTED_ITEM_STATUS.PERFORMANCE then
		local animationNormalized = gCS.AnimationManager.AnimationGetNormalizedTime(gCS.MyPlayerManager.PlayerUnit, 0)
		store.uProgress.value = animationNormalized
	elseif store.statusControl == self.SELECTED_ITEM_STATUS.LOOP_PERFORMANCE and not store.loopAnimation:IsPlaying(loopAnimationName) then
		gCS.LuaUtils.PlayAnimationByName(store.loopAnimation, loopAnimationName)
	end
end

function M:OnContentItemClick(id)
	self.selectedContentId = id
	self.bindData.emptyControl = 0

	self.bindData.contentList:RefreshList()

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local hasUnlocked = self:CheckActionHasUnlocked(actionItemCfg.Id)

	if hasUnlocked then
		if self:CheckHasMeetFavor(id) then
			self.bindData.description = actionItemCfg.UnlockDesc
		else
			local npcActionId = self:GetNpcActionId(id)
			local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)
			local targetNpcFavor = npcActionCfg.NpcFavor
			local _, favorLevel = table.find(LTConfig.NpcCultivationConfig.FavorLevel, targetNpcFavor)
			self.bindData.description = LTConfig.ActionItemConfig.FavorUnlockTips:format(favorLevel)
		end
	else
		self.bindData.description = actionItemCfg.Desc
	end

	self:SetActionHasRead(id)
	self:PlayAction(id)
end

function M:PlayAction(id)
	local hasUnlocked = self:CheckActionHasUnlocked(id)

	if not hasUnlocked then
		print_debug(("交互动作:ActionId:%d_未解锁"):format(id))

		return
	end

	if not self:CheckHasMeetFavor(id) then
		print_debug(("交互动作:ActionId:%d_好感度未满足"):format(id))

		return
	end

	if self.currentPlayActionInfo and self.currentPlayActionInfo.status == self.ACTION_STATUS.BREAK then
		print_debug(("交互动作:ActionId:%d_正在退出"):format(id))

		self.currentPlayActionInfo.nextPlayActionId = id

		return
	end

	if self:IsPlayingAction() then
		print_debug(("交互动作:ActionId:%d当前正在播放"):format(self.currentPlayActionInfo.id))

		local currentActionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if not currentActionItemCfg.CanJoyStickBreakAction then
			return
		end

		self.currentPlayActionInfo.nextPlayActionId = id

		self:OnBreakMotionAction()

		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local parkourStateId = actionItemCfg.ParkourState
	local checkStateCfg = LTConfig.ActionItemCheckStateConfig.GetConfig(parkourStateId)
	local parkourStateList = checkStateCfg.ParkourState
	local parkourStateMatch = false

	if table.count(gMainMenuMgr.clientState.parkourState) > 0 then
		for _, parkourState in ipairs(parkourStateList) do
			if gMainMenuMgr:CheckHasClientState(parkourState) then
				parkourStateMatch = true

				break
			end
		end
	else
		parkourStateMatch = true
	end

	if not parkourStateMatch then
		print_debug(("交互动作:ActionId:%d_跑酷状态不匹配"):format(id))

		return
	end

	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS) and not checkStateCfg.CanPlayFightState then
		print_debug(("交互动作:ActionId:%d_战斗状态"):format(id))

		return
	end

	if actionItemCfg.Type == self.TAB_MOTION_TYPE.SINGLE then
		self:PlaySingleAction(id)
	elseif actionItemCfg.Type == self.TAB_MOTION_TYPE.DOUBLE then
		if self.isLinkMode then
			self:PlayLinkAction(id)
		else
			self:PlayDoubleAction(id)
		end
	end
end

function M:PlayLinkAction(id)
	if id == self.linkActionId then
		print_debug(("交互动作:ActionId:%d_已发起邀请，等待对方回应"):format(id))

		return
	end

	self.linkActionId = id
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local multiInteractType = actionItemCfg.MultiInteractType
	local result = L18.Gameplay.MotionActionManager.Instance:TryGetMultiInteractPosAndDir(multiInteractType, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

	if result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.Success then
		gClientToGameDelegate:AskInvitePlayerInteractionAction(self.npcOwnerId, id).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				self.linkActionId = nil

				print_debug(("交互动作:ActionId:%d_发起邀请返回失败 errorId：%d"):format(id, errorId))

				return
			end

			self:StartThinkingCountdown(LTConfig.ActionItemConfig.InviteCountdownTime)
		end
	else
		self.linkActionId = nil

		print_debug(("交互动作:ActionId:%d_交互动作检测失败 result：%d"):format(id, result))
		self:ShowMultiActionFailTips(id, result)
	end
end

function M:StartThinkingCountdown(totalCountdownTime, callback)
	self:StopNpcThinking()
	self.bindData.npcThinkingNode:SetActive(true)

	self.showNpcBubbleThinkingCo = coroutine.start(function ()
		local countdownTime = totalCountdownTime
		self.bindData.thinkingCountdown.value = countdownTime / totalCountdownTime

		while countdownTime > 0 do
			coroutine.wait(1)

			countdownTime = countdownTime - 1
			self.bindData.thinkingCountdown.value = countdownTime / totalCountdownTime
		end

		self.bindData.npcThinkingNode:SetActive(false)

		if callback then
			callback()
		end
	end)
end

function M:PlaySingleAction(id)
	if self.motionInteractCheckModule then
		self.motionInteractCheckModule.CanStand = true
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, actionItemCfg.GameplayEvent)

	self.currentPlayActionInfo = {
		id = id,
		status = self.ACTION_STATUS.NONE
	}
end

function M:CheckHasMeetFavor(id)
	if self.npcId then
		local npcActionId = self:GetNpcActionId(id)
		local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)

		if npcActionCfg then
			local targetNpcFavor = npcActionCfg.NpcFavor
			local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcActionCfg.SpiritId)
			local serverFavor = favorInfo and favorInfo.favor or 0

			return targetNpcFavor <= serverFavor
		end
	end

	return true
end

function M:PlayDoubleAction(id)
	local npcActionId = self:GetNpcActionId(id)
	local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)

	if npcActionCfg then
		self.bindData.npcThinkingNode:SetActive(true)
		self:StartThinkingCountdown(LTConfig.ActionItemConfig.NpcBubbleThinkingShowTime, function ()
			local dialogId = npcActionCfg.AcceptDialog or npcActionCfg.RejectDialog
			local dialogParams = gDialogManager:CreateDialogParam()

			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.CharMotion, nil, dialogParams, nil)

			local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
			local multiInteractType = actionItemCfg.MultiInteractType
			local result = L18.Gameplay.MotionActionManager.Instance:TryMultiInteract(multiInteractType, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

			if result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.Success then
				self.currentPlayActionInfo = {
					id = id,
					status = self.ACTION_STATUS.PREPARE,
					npcActionId = npcActionId
				}
			else
				self:ShowMultiActionFailTips(id, result)
			end
		end)
	else
		local agentCfg = LTConfig.AgentConfig.GetConfig(self.npcId)
		local plotId = agentCfg and agentCfg.PlotId or 0

		print_debug(("交互动作:ActionId:%d_npcId:%d_plotId:%d 未能取到NpcActionId"):format(id, self.npcId, plotId))
	end
end

local tmpVec = Vector2.zero
local npcNameDisplayOffset = Vector3.New(0, -0.25, 0)
local checkInterval = 0.1
local timer = 0

function M:OnUpdate()
	if self:CheckMultiInteractBeyondDistanceLimit() then
		self:ClosePanel()

		return
	end

	self:UpdateGamePadCamera()

	if self.bindData.npcThinkingNode.activation then
		if self.npcUnit and not self.npcUnit.IsDestroyed and self.npcUnit.HeadSlotPos then
			local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.npcUnit.HeadSlotPos + self.npcUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

			tmpVec:Set(x, y)

			self.bindData.npcThinkingNode.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
		end

		self.bindData.playerSelectedNode:SetActive(false)
	elseif self.isLinkMode then
		if not self:IsPlayingAction() then
			self.bindData.playerSelectedNode:SetActive(true)

			if self.npcUnit and not self.npcUnit.IsDestroyed and self.npcUnit.HeadSlotPos then
				local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.npcUnit.HeadSlotPos + self.npcUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

				tmpVec:Set(x, y)

				self.bindData.playerSelectedNode.transform.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
			end
		else
			self.bindData.playerSelectedNode:SetActive(false)
		end
	else
		self.bindData.playerSelectedNode:SetActive(false)
	end

	if self.currentPlayActionInfo then
		if self:GetActionPerformanceStatus(self.currentPlayActionInfo.id) == self.SELECTED_ITEM_STATUS.PERFORMANCE then
			timer = timer + Time.deltaTime

			if checkInterval <= timer then
				self.bindData.contentList:RefreshList()

				timer = 0
			end
		else
			timer = 0
		end
	else
		timer = 0
	end
end

function M:CheckMultiInteractBeyondDistanceLimit()
	if not self.npcUnit then
		return false
	end

	local playerTransform = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	local npcTransform = self.npcUnit.PlayerObj

	if gClientUtils.NotNil(playerTransform) and gClientUtils.NotNil(npcTransform) then
		if not self.bindData.rightContentWidget.activation then
			return false
		end

		local isPlaying = self.currentPlayActionInfo and (self.currentPlayActionInfo.status == self.ACTION_STATUS.PLAY or self.currentPlayActionInfo.status == self.ACTION_STATUS.PREPARE)

		if isPlaying then
			return false
		end

		if LTConfig.ActionItemConfig.InteractionDistanceLimit < Vector3.Distance(playerTransform.position, npcTransform.position) then
			return true
		end
	end

	return false
end

function M:UpdateGamePadCamera()
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:GetNpcActionId(actionId)
	local count = LTConfig.ActionItemNpcActionConfig.count

	for i = 0, count - 1 do
		local npcActionCfg = LTConfig.ActionItemNpcActionConfig.LoadAt(i)

		if table.contains(npcActionCfg.AgentId, self.agentId) and npcActionCfg.ActionItemId == actionId then
			return npcActionCfg.Id
		end
	end
end

function M:GetActionPerformanceStatus(actionId)
	local hasUnlocked = self:CheckActionHasUnlocked(actionId)

	if hasUnlocked then
		local isCurrentActionId = self.currentPlayActionInfo and self.currentPlayActionInfo.id == actionId
		local isCurrentActionPlaying = isCurrentActionId and self:IsPlayingAction()
		local selectedItemStatus = self.SELECTED_ITEM_STATUS.NORMAL

		if isCurrentActionPlaying then
			local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(actionId)

			return actionItemCfg.IsLoopAction and self.SELECTED_ITEM_STATUS.LOOP_PERFORMANCE or self.SELECTED_ITEM_STATUS.PERFORMANCE
		end

		return selectedItemStatus
	else
		return self.SELECTED_ITEM_STATUS.LOCK
	end
end

function M:IsPlayingAction()
	return self.currentPlayActionInfo and self.currentPlayActionInfo.status == self.ACTION_STATUS.PLAY
end

function M:GetUnlockedActionItemInfo(id)
	local playerInteractionActionInfo = gPlayerManager.infoMinor.bindData.playerInteractionActionInfo

	return playerInteractionActionInfo and playerInteractionActionInfo.UnlockActionItemDict and playerInteractionActionInfo.UnlockActionItemDict[id]
end

function M:CheckActionHasUnlocked(id)
	local unlockedActionItemInfo = self:GetUnlockedActionItemInfo(id)

	return unlockedActionItemInfo ~= nil
end

function M:CheckActionHasRedDot(id)
	local unlockedActionItemInfo = self:GetUnlockedActionItemInfo(id)

	if unlockedActionItemInfo then
		return unlockedActionItemInfo.ShowRedPoint
	else
		return false
	end
end

function M:SetActionHasRead(id)
	local unlockedActionItemInfo = self:GetUnlockedActionItemInfo(id)

	if unlockedActionItemInfo then
		unlockedActionItemInfo.ShowRedPoint = false

		gClientToGameDelegate:AskCancelInteractionActionRedPoint(id).Callback = function ()
			return
		end

		self.bindData.tabList:RefreshList()
		self.bindData.contentList:RefreshList()
	end
end

function M:OnFoldClick()
	self.bindData.showControl = 1
end

function M:OnUnfoldClick()
	self.bindData.showControl = 0
end

function M:OnTakePhotoClick()
	gTakePhotoUtils.TryTakePhoto()
end

function M:OnExitClick()
	if not self.bindData.rightContentWidget.activation then
		return
	end

	local isPlaying = self.currentPlayActionInfo and (self.currentPlayActionInfo.status == self.ACTION_STATUS.PLAY or self.currentPlayActionInfo.status == self.ACTION_STATUS.PREPARE)

	if isPlaying then
		self.bindData.rightContentWidget:SetActive(false)
		self:OnBreakMotionAction()
		self:StartAutoClose()
	else
		self:ClosePanel()
	end
end

function M:OnContentListOnScroll()
	local csIndex = self.bindData.contentList:GetNearestPageIndex()

	self.bindData.pageList:SelectItem(csIndex)
end

function M:StartAutoClose()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(30)
		self:ClosePanel()
	end)
end

function M:OnEnterCharMotionAnimation()
	if not self.currentPlayActionInfo then
		return
	end

	self.currentPlayActionInfo.status = self.ACTION_STATUS.PLAY

	self.bindData.contentList:RefreshList()
	self:RefreshStopButtonView()
	self:AskReportPose(self.currentPlayActionInfo.id, UX.Game.PoseTriggerType.Start)
end

function M:RefreshStopButtonView()
	if self:IsPlayingAction() then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if not actionItemCfg.CanJoyStickBreakAction then
			self.bindData.stopButton:SetActive(true)

			return
		end
	end

	self.bindData.stopButton:SetActive(false)
end

function M:OnExitCharMotionAnimation()
	if self.currentPlayActionInfo then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if actionItemCfg and actionItemCfg.IsLoopAction then
			self:AskReportPose(self.currentPlayActionInfo.id, UX.Game.PoseTriggerType.Loop)
		end
	end

	if not self.bindData.rightContentWidget.activation then
		self:ClosePanel()

		return
	end

	self:RefreshStopButtonView()

	if not self.currentPlayActionInfo then
		return
	end

	local nextPlayActionId = self.currentPlayActionInfo.nextPlayActionId

	self:AskReportPose(self.currentPlayActionInfo.id, UX.Game.PoseTriggerType.End)
	self:AskCancelInviterPlayerInteractionAction()

	self.currentPlayActionInfo = nil

	self.bindData.contentList:RefreshList()

	self.playNextActionCo = nextPlayActionId and coroutine.start(function ()
		coroutine.step()
		self:PlayAction(nextPlayActionId)
	end)
end

function M:OnJoyStickMove()
	if self:IsPlayingAction() then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if actionItemCfg.CanJoyStickBreakAction then
			self:OnBreakMotionAction()
		end
	end
end

function M:OnBeginDrag()
	return
end

function M:OnDrag(eventData)
	if eventData.button == 0 then
		gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(eventData.delta.x, eventData.delta.y))
	end
end

function M:OnEndDrag()
	return
end

function M:OnBreakMotionAction()
	if self.currentPlayActionInfo then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if actionItemCfg and actionItemCfg.IsLoopAction then
			if actionItemCfg.Type == self.TAB_MOTION_TYPE.SINGLE then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, actionItemCfg.GameplayEndEvent)
			elseif actionItemCfg.Type == self.TAB_MOTION_TYPE.DOUBLE then
				local playerUnit = gCS.MyPlayerManager.PlayerUnit
				local targetUnit = playerUnit or self.npcUnit

				LX6.Units.SpoonBTBridge.TryStoMultiInteract(targetUnit)
			end

			self.currentPlayActionInfo.status = self.ACTION_STATUS.BREAK
		end
	end

	self:RefreshStopButtonView()
end

function M:AskCancelInviterPlayerInteractionAction()
	if self.isLinkMode and self.linkActionId then
		self.linkActionId = nil

		gLuaTimeMgrUtils.Delay(function ()
			gClientToGameDelegate:AskCancelInviterPlayerInteractionAction().Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end, 1)
	end
end

function M:CheckTabHasRedDot(actionType)
	local viewDataList = self:GetViewDataListByActionType(actionType)

	for _, data in ipairs(viewDataList) do
		if self:CheckActionHasRedDot(data.id) then
			return true
		end
	end
end

function M:AddMapLuaUnit(_, pid)
	if pid == gCS.MyPlayerManager.PlayerUnit.Pid then
		self:ClosePanel()
	end
end

function M:ClosePanel()
	gPanelManager:Close(self.m_Id)
end

function M:StopNpcThinking()
	self.showNpcBubbleThinkingCo = coroutine.stop(self.showNpcBubbleThinkingCo)

	self.bindData.npcThinkingNode:SetActive(false)
end

function M:OnReplyInviteResult(_, isAccept)
	self:StopNpcThinking()

	if not isAccept then
		self.linkActionId = nil

		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.RejectInviteTips)

		return
	end

	local id = self.linkActionId

	gClientToGameDelegate:AskStartPlayerInteractionAction().Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			print_debug(("交互动作:ActionId:%d_发起开始交互动作返回失败 errorId：%d"):format(id, errorId))
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
		local multiInteractType = actionItemCfg.MultiInteractType
		local result = L18.Gameplay.MotionActionManager.Instance:TryMultiInteract(multiInteractType, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

		if result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.Success then
			self.currentPlayActionInfo = {
				id = id,
				status = self.ACTION_STATUS.PREPARE
			}
		else
			self:ShowMultiActionFailTips(id, result)
		end
	end
end

function M:OnCancelInvitePlayerAction()
	self:StopNpcThinking()

	self.linkActionId = nil

	self:OnBreakMotionAction()
end

function M:OnCancelInviteePlayerAction(_, interactionActionState)
	self:StopNpcThinking()

	if interactionActionState == UX.Game.InteractionActionState.InvitingTimeout then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.InviteTimeOutTips)
	elseif interactionActionState == UX.Game.InteractionActionState.Cancel and self.npcName then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CancelInviteTips:format(self.npcName))
	end

	self.linkActionId = nil

	self:OnBreakMotionAction()
end

function M:ShowMultiActionFailTips(id, result)
	if result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfSpace then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.NoEnoughSpaceMessage)
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，没有足够空间"):format(id, result))
	elseif result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfUnit then
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，缺少主角或NPC"):format(id, result))
	elseif result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfConfig then
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，找不到配置表项，可能是角色体型不匹配"):format(id, result))
	elseif result == AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.UnReachable then
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，不可到达"):format(id, result))
	else
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d"):format(id, result))
	end
end

function M:GetTypeIconId(typeId)
	if typeId == self.TAB_MOTION_TYPE.SINGLE then
		return LTConfig.ActionItemConfig.TypeSingleIconId
	elseif typeId == self.TAB_MOTION_TYPE.DOUBLE then
		return LTConfig.ActionItemConfig.TypeDoubleIconId
	elseif typeId == self.TAB_MOTION_TYPE.JOB then
		return LTConfig.ActionItemConfig.TypeJobIconId
	end
end

function M:OnStopClick()
	self:OnBreakMotionAction()
end

function M:AskReportPose(id, poseTriggerType)
	if not id then
		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if actionItemCfg.Type == gClientConst.MOTION_ACTION_SHOW_TYPE.Single then
		gClientToGameDelegate:AskReportSinglePose(id, poseTriggerType)
	else
		gClientToGameDelegate:AskReportDoublePose(id, poseTriggerType, self.npcPid)
	end
end

function M:OnDestroy()
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = self.lastRotatedEnable

	if self.motionInteractCheckModule then
		self.motionInteractCheckModule.OnCannotStandAction = nil
	end

	self.motionInteractCheckModule = nil

	self:ClearMessageEvents()
	self:OnBreakMotionAction()
	self:AskCancelInviterPlayerInteractionAction()

	self.showNpcBubbleThinkingCo = coroutine.stop(self.showNpcBubbleThinkingCo)
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
	self.tabTipsCo = coroutine.stop(self.tabTipsCo)
	self.playNextActionCo = coroutine.stop(self.playNextActionCo)
	local duration = UXTime.GetNowUnixTime() - self.openTime

	gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.CHAR_MOTION_LIST_PANEL, self.selectedContentId or 0, duration)
	self:SetShowJoystick(false)
end
