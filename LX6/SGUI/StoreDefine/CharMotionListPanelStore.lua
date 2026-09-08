-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CharMotionListPanelStore.lua
-- Decompiled from: 01478_CharMotionListPanelStore.lua_9f5068d6d07a.luajit

C_CharMotionListPanelStore = DefClass("C_CharMotionListPanelStore", C_CharMotionListPanelStore, C_StoreGroup)
GroupName2Class.CharMotionListPanelStore = C_CharMotionListPanelStore
local M = C_CharMotionListPanelStore
local UXTime = LTUtils.UXTime

M.ctor = function(self)
	gMessageManager:AddMessageListener(gEventConstants.ON_ENTER_TEAM_VISIBLE_AREA, self:CreateAction("OnEnterTeamVisibleArea"))
	gMessageManager:AddMessageListener(gEventConstants.ON_EXIT_TEAM_VISIBLE_AREA, self:CreateAction("OnExitTeamVisibleArea"))
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnContentRenderItem")
	self.bindData.takePhotoButton.luaClick = self.CreateAction(self, "OnTakePhotoClick")
	self.bindData.foldButton.luaClick = self.CreateAction(self, "OnFoldClick")
	self.bindData.unfoldButton.luaClick = self.CreateAction(self, "OnUnfoldClick")
	self.bindData.takePhotoFoldButton.luaClick = self.CreateAction(self, "OnTakePhotoClick")
	self.bindData.exitFolderButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.stopButton.luaClick = self.CreateAction(self, "OnStopClick")
	self.bindData.conditionList.luaSimpleRenderItem = self.CreateAction(self, "OnConditionRenderItem")
	self.openTime = UXTime.GetNowUnixTime()

	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local eventHandlers = {
		[gEventConstants.ON_ENTER_CHAR_MOTION_ANIMATION] = self.CreateAction(self, "OnEnterCharMotionAnimation"),
		[gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION] = self.CreateAction(self, "OnExitCharMotionAnimation"),
		[gEventConstants.ON_JOYSTICK_MOVE] = self.CreateAction(self, "OnJoyStickMove"),
		[gEventConstants.ON_SYNC_MOTION_ACTION_REPLAY_INVITE_RESULT] = self.CreateAction(self, "OnReplyInviteResult"),
		[gEventConstants.ON_SYNC_CANCEL_INVITE_PLAYER_ACTION] = self.CreateAction(self, "OnCancelInvitePlayerAction"),
		[gEventConstants.ON_SYNC_CANCEL_INVITEE_PLAYER_ACTION] = self.CreateAction(self, "OnCancelInviteePlayerAction"),
		[gEventConstants.ADD_MAP_LUA_UNIT] = self.CreateAction(self, "AddMapLuaUnit"),
		[gEventConstants.ON_ENTER_TEAM_VISIBLE_AREA] = self.CreateAction(self, "OnBreakMotionAction"),
		[gEventConstants.ON_MAP_TELEPORT] = self.CreateAction(self, "ClosePanel")
	}

	self.RegisterMessageEvents(self, eventHandlers)
end

M.OnShow = function(self, panelId, args)
	self.m_Id = panelId

	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, false)

	self.waitCancelPendingInviteAction = nil
	self.waitAnimationFinished = nil
	self.lastPlayActionInfo = nil
	self.lastRotatedEnable = gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled
	self.isLinkMode = args and args.isLinkMode
	self.pendingInviteActionId = args and args.linkActionId
	self.needUpdateCamera = nil
	self.currentPlayActionInfo = nil
	self.hasPlayedLifeScheduleAction = false
	self.selectedTabIndex = 1
	self.selectedContentId = nil
	self.SELECTED_ITEM_STATUS = {
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["K(\\xb5\\xa0\\x80\\xec\\x95\\xf7\\x86\r \\x93,."] = 3,
		["\\xafW\\xafl\\xf8\\x89\\x9c"] = 1,
		["V\r^p"] = 2
	}
	self.ACTION_STATUS = {
		["\\xe9\\xe91-?\\xd4"] = 2,
		["J\\b"] = 3,
		["o\\x9c\\x87\\x8e\\x9d"] = 4,
		["T\rS~"] = 1
	}
	self.showType = args and args.showType

	if not self.showType then
		self.showType = self.isLinkMode and LTConfig.ActionItemTabConfig.ShowTypeType.Interaction or LTConfig.ActionItemTabConfig.ShowTypeType.Solo
	end

	self.npcUnit = args and args.npcUnit
	self.npcPid = args and (args.npcPid or args.inviteePid)

	if not self.npcPid and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		self.npcPid = self.npcUnit.Pid
	end

	if not gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		self.npcUnit = self.npcPid and gCS.SceneDataMgr.GetUnit(self.npcPid)
	end

	self.npcId = args and args.npcId

	if not self.npcId and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		self.npcId = self.npcUnit.NpcId
	end

	self:InitTabTypeDataList()

	local agentQuoteId = gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) and self.npcUnit.ClientData.AgentId or nil
	local actionQuoteCfg = LTConfig.AgentQuoteConfig.GetConfig(agentQuoteId)
	self.agentId = actionQuoteCfg and actionQuoteCfg.QuoteId

	if self.isLinkMode and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		self.npcOwnerId = self.npcUnit.ClientData.OwnerId
		self.npcName = gBattleNetcodeUtils:GetUserName(self.npcOwnerId)
	end
end

M.InitTabTypeDataList = function(self)
	self.tabTypeList = {}
	local count = LTConfig.ActionItemTabConfig.count

	for i = 0, count - 1 do
		local cfg = LTConfig.ActionItemTabConfig.LoadAt(i)

		if cfg.ShowType ~= self.showType then
			table.insert(self.tabTypeList, cfg.Id)
		end
	end
end

M.InitView = function(self, args)
	if self.m_Id ~= gPanelId.CHAR_MOTION_LIST_HALF_PANEL then
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
	end

	self.isFromMainPhone = args and args.isFromMainPhone

	if self.isFromMainPhone then
		gClientUtils.ExitPhoneAction()
	end

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

		self.motionInteractCheckModule.OnCannotStandAction = function()
			self.currentPlayActionInfo = nil
			self.pendingInviteActionId = nil

			gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.NoEnoughSpaceMessage)
		end
	end

	self.SetShowJoystick(self, true)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 1)

	self.bindData.emptyControl = 1

	self.SetForceReadMouseMove(self)
end

M.SetShowJoystick = function(self, isShow)
	if isShow then
		LX6.GUI.GuiMgr.Instance:SetShowJoystick(true, self.m_Id)

		local sortingInOrder = gCS.LuaUtils.GetSortingInOrder(self.rootGo)

		if sortingInOrder then
			SGUI.SguiJoystick.EnableTempSorting(isShow, sortingInOrder + 10)
		end
	else
		LX6.GUI.GuiMgr.Instance:SetShowJoystick(false, self.m_Id)

		if self.joyStickSortingOrder then
			SGUI.SguiJoystick.EnableTempSorting(true, self.joyStickSortingOrder)
		end
	end
end

M.InitTabListView = function(self)
	self.bindData.tabList:SetSimpleList(#self.tabTypeList)

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.tabControlLeftButton then
		if #self.tabTypeList <= 1 then
			self.bindData.tabControlLeftButton.luaClick = self.CreateAction(self, self.OnTabControlLeftClick)
			self.bindData.tabControlRightButton.luaClick = self.CreateAction(self, self.OnTabControlRightClick)
		else
			self.bindData.tabControlLeftButton.gameObject:SetActive(false)
			self.bindData.tabControlRightButton.gameObject:SetActive(false)
		end
	end
end

M.OnTabControlLeftClick = function(self)
	self.OnTabItemClick(self, 1)
end

M.OnTabControlRightClick = function(self)
	self.OnTabItemClick(self, 2)
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local id = self.tabTypeList[luaIndex]
	local tabCfg = LTConfig.ActionItemTabConfig.GetConfig(id)
	btn.redKey = ("CharMotion.Tab:%d"):format(id)
	store.iconId = tabCfg.TabIcon
	store.button.isSelected = self.selectedTabIndex ~= luaIndex
	store.button.luaClick = self:CreateActionWithArgs(self.OnTabItemClick, luaIndex)
end

M.OnTabItemClick = function(self, index)
	if self.selectedTabIndex ~= index then
		return
	end

	self.selectedTabIndex = index

	self.bindData.tabList:RefreshList()
	self:RefreshTabContentView()

	self.bindData.emptyControl = 1
end

M.RefreshTabContentView = function(self)
	local tabId = self.tabTypeList[self.selectedTabIndex]
	local tabData = LTConfig.ActionItemTabConfig.GetConfig(tabId)
	self.bindData.typeName = tabData.TabName
	self.contentDataList = self.GetViewDataListByActionType(self, tabId)

	for _, data in ipairs(self.contentDataList) do
		self.SetRedDot(self, tabId, data.id)
	end

	table.sort(self.contentDataList, function (data1, data2)
		local hasUnlocked1 = self:CheckActionHasUnlocked(data1.id)
		local hasUnlocked2 = self:CheckActionHasUnlocked(data2.id)

		if hasUnlocked1 == hasUnlocked2 then
			return hasUnlocked1
		end

		local hasMeetFavor1 = self:CheckHasMeetFavor(data1.id)
		local hasMeetFavor2 = self:CheckHasMeetFavor(data2.id)

		if hasMeetFavor1 == hasMeetFavor2 then
			return hasMeetFavor1
		end

		local hasMeetOwner1 = self:CheckOwnerConditionMeet(data1.id)
		local hasMeetOwner2 = self:CheckOwnerConditionMeet(data2.id)

		if hasMeetOwner1 == hasMeetOwner2 then
			return hasMeetOwner1
		end

		local actionItemCfg1 = LTConfig.ActionItemConfig.GetConfig(data1.id)
		local actionItemCfg2 = LTConfig.ActionItemConfig.GetConfig(data2.id)

		if actionItemCfg1.Quality == actionItemCfg2.Quality then
			return actionItemCfg2.Quality <= actionItemCfg1.Quality
		end

		return data1.id <= data2.id
	end)

	self.roundViewDataList = self.GetRoundViewDataList(self, self.contentDataList)

	if #self.roundViewDataList <= 1 then
		self.bindData.pageList:SetSimpleList(#self.roundViewDataList)
		self.bindData.pageList:SetItemSelected(0, true)
	else
		self.bindData.pageList:SetSimpleList(0)
	end

	self.bindData.contentList:SetSimpleList(#self.contentDataList)
	self.bindData.contentList:SetScrollDisabled(#self.contentDataList > 8)
end

M.GetRoundViewDataList = function(self, viewDataList)
	local pageCount = math.ceil(#viewDataList / 9)
	local roundViewDataList = {}

	for i = 1, pageCount do
		table.insert(roundViewDataList, {
			id = i
		})
	end

	return roundViewDataList
end

M.GetViewDataListByActionType = function(self, tabId)
	local viewDataList = {}
	local count = LTConfig.ActionItemConfig.count

	for i = 0, count - 1 do
		local actionItemCfg = LTConfig.ActionItemConfig.LoadAt(i)

		if actionItemCfg.Type ~= tabId and self.CheckActionItemCanShow(self, actionItemCfg.Id) then
			table.insert(viewDataList, {
				id = actionItemCfg.Id
			})
		end
	end

	return viewDataList
end

M.CheckActionItemCanShow = function(self, id)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if self.npcId and not self.isLinkMode then
		local actionId = self.GetNpcActionId(self, id)

		if not actionId then
			return false
		end
	end

	if self.isLinkMode then
		if not actionItemCfg.IsLinkShow then
			return false
		end

		if #actionItemCfg.LinkSpiritId <= 0 then
			local linkSpiritId = self.npcId

			return table.contains(actionItemCfg.LinkSpiritId, linkSpiritId)
		end
	end

	return true
end

M.CheckOwnerConditionMeet = function(self, id)
	return gCharMotionUtils.IsActionMatchCurSpirit(id)
end

M.OnContentRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(data.id)
	store.name = actionItemCfg.Name
	store.iconId = actionItemCfg.Icon

	self.bindData.contentList:SetItemId(csIndex, data.id)

	local hasUnlocked = self:CheckActionHasUnlocked(data.id)
	store.selectedControl = self.selectedContentId ~= data.id and 1 or 0
	btn.redKey = ("CharMotion.ActionItem:%d"):format(data.id)
	store.greyControl = hasUnlocked and self:CheckHasMeetFavor(data.id) and self:CheckOwnerConditionMeet(data.id) and 0 or 1
	local loopAnimationName = "S_vx_ActionPermancing_Loop"
	local currentStatus = self:GetActionPerformanceStatus(actionItemCfg.Id)

	if store.statusControl == currentStatus then
		gClientUtils.ResetAnimation(store.loopAnimation, loopAnimationName)
	end

	store.statusControl = currentStatus
	store.id = data.id
	store.button.luaClick = self.CreateActionWithArgs(self, "OnContentItemClick", data.id)

	if store.statusControl ~= self.SELECTED_ITEM_STATUS.PERFORMANCE then
		local animationNormalized = gCS.AnimationManager.AnimationGetNormalizedTime(gCS.MyPlayerManager.PlayerUnit, 0)
		store.uProgress.value = animationNormalized
	elseif store.statusControl ~= self.SELECTED_ITEM_STATUS.LOOP_PERFORMANCE and not store.loopAnimation:IsPlaying(loopAnimationName) then
		gCS.LuaUtils.PlayAnimationByName(store.loopAnimation, loopAnimationName)
	end
end

M.SetRedDot = function(self, tabId, id)
	local hasRedDot = self:CheckActionHasRedDot(id)
	local redDotKey = ("CharMotion/CharMotion.Tab:%d/CharMotion.ActionItem:%d"):format(tabId, id)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.OnContentItemClick = function(self, id)
	self.selectedContentId = id

	self.bindData.contentList:RefreshList()

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local hasUnlocked = self:CheckActionHasUnlocked(id)
	local hasMeetFavor = self:CheckHasMeetFavor(id)
	local hasMeetOwnerCondition = self:CheckOwnerConditionMeet(id)

	self.bindData.hyperLinkButton:SetActive(false)

	self.bindData.emptyControl = 0
	local showCondition = not hasUnlocked or not hasMeetFavor or not hasMeetOwnerCondition

	if showCondition then
		self.bindData.emptyControl = 2

		if actionItemCfg.HyperLink <= 0 and not hasUnlocked then
			local hyperLinkCfg = LTConfig.HyperLinkConfig.GetConfig(actionItemCfg.HyperLink)
			self.bindData.hyperLinkDesc = hyperLinkCfg.SourceLabels

			self.bindData.hyperLinkButton:SetActive(true)

			self.bindData.hyperLinkButton.luaClick = self:CreateActionWithArgs("OnHyperLinkClick", id)
		else
			self.bindData.hyperLinkButton:SetActive(false)
		end

		self.conditionList = self:GetUnlockedConditionList(id)

		self.bindData.conditionList:SetSimpleList(#self.conditionList)
	else
		self.bindData.description = actionItemCfg.UnlockDesc
	end

	self.SetActionHasRead(self, id)
	self.PlayAction(self, id)
end

M.GetUnlockedConditionList = function(self, id)
	local conditionList = {}
	local hasMeetOwnerCondition = self.CheckOwnerConditionMeet(self, id)

	if not hasMeetOwnerCondition then
		table.insert(conditionList, {
			["n;m^"] = 1,
			id = id
		})
	end

	local hasMeetFavor = self.CheckHasMeetFavor(self, id)

	if not hasMeetFavor then
		table.insert(conditionList, {
			["n;m^"] = 2,
			id = id
		})
	end

	return conditionList
end

M.GetFavorMeetTips = function(self, id)
	local npcActionId = self.GetNpcActionId(self, id)

	if npcActionId then
		local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)
		local targetNpcFavor = npcActionCfg and npcActionCfg.NpcFavor
		local _, favorLevel = table.find(LTConfig.NpcCultivationConfig.FavorLevel, targetNpcFavor)
		local favorMeetTips = LTConfig.ActionItemConfig.FavorUnlockTips:format(favorLevel)

		return favorMeetTips
	end
end

M.PlayAction = function(self, id)
	local hasUnlocked = self.CheckActionHasUnlocked(self, id)

	if not hasUnlocked then
		print_debug(("交互动作:ActionId:%d_未解锁"):format(id))

		return
	end

	if not self.CheckHasMeetFavor(self, id) then
		print_debug(("交互动作:ActionId:%d_好感度未满足"):format(id))

		return
	end

	if not self.CheckOwnerConditionMeet(self, id) then
		print_debug(("交互动作:ActionId:%d_所属角色不满足"):format(id))

		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if table.count(gMainMenuMgr.clientState.parkourState) <= 0 and gMainMenuMgr:CheckHasClientState(LTConfig.ParkourStateConfig.MultiInteract) then
		print_debug(("交互动作:ActionId:%d_正在双人交互动作中，无法切换打断"):format(id))

		return
	end

	local parkourStateId = actionItemCfg.ParkourState
	local checkStateCfg = LTConfig.ActionItemCheckStateConfig.GetConfig(parkourStateId)

	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS) and checkStateCfg and not checkStateCfg.CanPlayFightState then
		print_debug(("交互动作:ActionId:%d_战斗状态"):format(id))

		return
	end

	if not gGameSwitch.EnableInteractionAction then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.LinkCanNotDoubleInteract)

		return
	end

	if actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Single then
		self.PlaySingleAction(self, id)
	elseif actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Instrument then
		self.PlaySummonAction(self, id)
	elseif actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Double then
		if self.isEnterTeamVisibleArea then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.LinkCanNotDoubleInteract)

			return
		end

		if self.isLinkMode then
			self.PlayLinkAction(self, id)
		else
			self.PlayDoubleAction(self, id)
		end
	end
end

M.PlaySummonAction = function(self, id)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if not actionItemCfg.EnterBlackScreen then
		self.PlaySingleAction(self, id)

		return
	end

	slot3 = gBlackScreenManager

	slot3:AutoTransition(gBlackScreenId.INSTRUMENT_ACTION, "", false, false, LTConfig.ActionItemConfig.InstrumentBlackOpenTime, LTConfig.ActionItemConfig.InstrumentBlackStayTime, LTConfig.ActionItemConfig.InstrumentBlackCloseTime, function ()
		self:PlaySingleAction(id)
	end)
end

M.PlayLinkAction = function(self, id)
	if self.waitCancelPendingInviteAction then
		print_debug("交互动作 等待CancelPendingInvite rpc")

		return
	end

	if id ~= self.pendingInviteActionId then
		print_debug(("交互动作:ActionId:%d_已发起邀请，等待对方回应"):format(id))

		return
	end

	if not gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
		print_debug(("交互动作:ActionId:%d_PlayerUnit已销毁"):format(id))
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CanNotDoubleInteract)

		return
	end

	if not gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
		print_debug(("交互动作:ActionId:%d_NPCUnit已销毁"):format(id))
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CanNotDoubleInteract)

		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local multiInteractType = actionItemCfg.MultiInteractType
	local canPlayMultiInteract = L18.Gameplay.MotionActionManager.Instance:CanInvitedPlayerMultiInteract(multiInteractType, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

	if not canPlayMultiInteract then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CanNotDoubleInteract)

		return
	end

	self.pendingInviteActionId = id
	local result = gCharMotionUtils.TryGetMultiInteractPosAndDir(id, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

	if result then
		local rootWidget = self.rootWidget
		slot7 = gClientToGameDelegate

		slot7:AskInvitePlayerInteractionAction(self.npcOwnerId, id).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				self.pendingInviteActionId = nil

				print_debug(("交互动作:ActionId:%d_发起邀请返回失败 errorId：%d"):format(id, errorId))

				return
			end

			if gClientUtils.NotNil(rootWidget) then
				self:StartThinkingCountdown()
			end
		end

		return
	end

	self.pendingInviteActionId = nil
end

M.PlaySingleAction = function(self, id)
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

M.CheckHasMeetFavor = function(self, id)
	if self.npcId then
		local npcActionId = self.GetNpcActionId(self, id)
		local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)

		if npcActionCfg then
			local targetNpcFavor = npcActionCfg.NpcFavor
			local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcActionCfg.SpiritId)
			local serverFavor = favorInfo and favorInfo.favor or 0

			return targetNpcFavor > serverFavor
		end
	end

	return true
end

M.PlayDoubleAction = function(self, id)
	local npcActionId = self.GetNpcActionId(self, id)
	local npcActionCfg = LTConfig.ActionItemNpcActionConfig.GetConfig(npcActionId)

	if npcActionCfg then
		local dialogId = npcActionCfg.AcceptDialog or npcActionCfg.RejectDialog

		if dialogId <= 0 then
			local dialogParams = gDialogManager:CreateDialogParam()

			gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.CharMotion, nil, dialogParams, nil)
		end

		local result, multiInteractId = gCharMotionUtils.TryMultiInteract(id, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

		if result then
			self.currentPlayActionInfo = {
				id = id,
				status = self.ACTION_STATUS.PREPARE,
				npcActionId = npcActionId,
				multiInteractId = multiInteractId
			}
		end
	else
		local agentCfg = LTConfig.AgentConfig.GetConfig(self.npcId)
		local plotId = agentCfg and agentCfg.PlotId or 0

		print_debug(("交互动作:ActionId:%d_npcId:%d_plotId:%d 未能取到NpcActionId"):format(id, self.npcId, plotId))
	end
end

local tmpVec = Vector2.zero
local npcNameDisplayOffset = Vector3.New(0, 0, 0)
local checkInterval = 0.1
local timer = 0

M.OnUpdate = function(self)
	if self.CheckMultiInteractBeyondDistanceLimit(self) then
		self.ClosePanel(self)

		return
	end

	self.UpdateGamePadCamera(self)

	if self.bindData.npcThinkingNode.activation then
		if gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) and self.npcUnit.HeadSlotPos then
			local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.npcUnit.HeadSlotPos + self.npcUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

			tmpVec:Set(x, y)

			self.bindData.npcThinkingNode.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
		end

		self.bindData.playerSelectedNode:SetActive(false)
	elseif self.isLinkMode then
		if not self.IsPlayingAction(self) then
			self.bindData.playerSelectedNode:SetActive(true)

			if gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) and self.npcUnit.HeadSlotPos then
				local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.npcUnit.HeadSlotPos + self.npcUnit.LocalPosition + npcNameDisplayOffset, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

				tmpVec:Set(x, y)

				self.bindData.playerSelectedNode.transform.localPosition = gCS.LuaUtils.ScreenPointUI(self.bindData.centerNode, tmpVec)
			else
				self.bindData.playerSelectedNode:SetActive(false)
			end
		else
			self.bindData.playerSelectedNode:SetActive(false)
		end
	else
		self.bindData.playerSelectedNode:SetActive(false)
	end

	if self.currentPlayActionInfo then
		if self.GetActionPerformanceStatus(self, self.currentPlayActionInfo.id) ~= self.SELECTED_ITEM_STATUS.PERFORMANCE then
			timer = timer + Time.deltaTime

			if checkInterval < timer then
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

M.StartThinkingCountdown = function(self)
	if gClientUtils.IsNil(self.rootWidget) then
		return
	end

	self:StopNpcThinking()

	local totalCountdownTime = LTConfig.ActionItemConfig.InviteCountdownTime
	slot2 = self.bindData.npcThinkingNode

	slot2:SetActive(true)

	self.showNpcBubbleThinkingCo = coroutine.start(function ()
		local countdownTime = totalCountdownTime
		self.bindData.thinkingCountdown.value = countdownTime / totalCountdownTime

		while countdownTime <= 0 do
			coroutine.step()

			countdownTime = countdownTime - Time.deltaTime
			self.bindData.thinkingCountdown.value = countdownTime / totalCountdownTime
		end

		self.bindData.npcThinkingNode:SetActive(false)
	end)
end

M.CheckMultiInteractBeyondDistanceLimit = function(self)
	if self.npcPid then
		if gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) and gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
			if not self.bindData.rightContentWidget.activation then
				return false
			end

			local isPlaying = self.currentPlayActionInfo and (self.currentPlayActionInfo.status ~= self.ACTION_STATUS.PLAY or self.currentPlayActionInfo.status ~= self.ACTION_STATUS.PREPARE)

			if isPlaying then
				return false
			end

			local playerTransform = gCS.MyPlayerManager.PlayerUnit.PlayerObj
			local npcTransform = self.npcUnit.PlayerObj

			if LTConfig.ActionItemConfig.InteractionDistanceLimit >= Vector3.Distance(playerTransform.position, npcTransform.position) then
				return true
			end
		elseif not gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
			return true
		end
	end

	return false
end

M.UpdateGamePadCamera = function(self)
end

M.GetNpcActionId = function(self, actionId)
	local count = LTConfig.ActionItemNpcActionConfig.count
	local agentCfg = LTConfig.AgentConfig.GetConfig(self.npcId)

	if agentCfg then
		for i = 0, count - 1 do
			local npcActionCfg = LTConfig.ActionItemNpcActionConfig.LoadAt(i)
			local agentSpecialType = agentCfg.AgentSpecificType

			if npcActionCfg.AgentType ~= agentSpecialType and npcActionCfg.ActionItemId ~= actionId then
				return npcActionCfg.Id
			end
		end
	end
end

M.GetActionPerformanceStatus = function(self, actionId)
	local hasUnlocked = self.CheckActionHasUnlocked(self, actionId)

	if hasUnlocked then
		local isCurrentActionId = self.currentPlayActionInfo and self.currentPlayActionInfo.id ~= actionId
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

M.IsPlayingAction = function(self)
	return self.currentPlayActionInfo and self.currentPlayActionInfo.status ~= self.ACTION_STATUS.PLAY
end

M.GetUnlockedActionItemInfo = function(self, id)
	local playerInteractionActionInfo = gPlayerManager.infoMinor.bindData.playerInteractionActionInfo

	return playerInteractionActionInfo and playerInteractionActionInfo.UnlockActionItemDict and playerInteractionActionInfo.UnlockActionItemDict[id]
end

M.CheckActionHasUnlocked = function(self, id)
	local unlockedActionItemInfo = self:GetUnlockedActionItemInfo(id)

	return unlockedActionItemInfo == nil
end

M.CheckActionHasRedDot = function(self, id)
	if not self.CheckActionHasUnlocked(self, id) then
		return false
	end

	if not self.CheckHasMeetFavor(self, id) then
		return false
	end

	local unlockedActionItemInfo = self.GetUnlockedActionItemInfo(self, id)

	if unlockedActionItemInfo then
		return unlockedActionItemInfo.ShowRedPoint
	else
		return false
	end
end

M.SetActionHasRead = function(self, id)
	local unlockedActionItemInfo = self.GetUnlockedActionItemInfo(self, id)

	if unlockedActionItemInfo then
		unlockedActionItemInfo.ShowRedPoint = false

		gClientToGameDelegate:AskCancelInteractionActionRedPoint(id).Callback = function ()
		end

		local tabId = self.tabTypeList[self.selectedTabIndex]

		self:SetRedDot(tabId, id)
	end
end

M.OnFoldClick = function(self)
	self.currentActiveContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
	self.bindData.showControl = 1
end

M.OnUnfoldClick = function(self)
	self.bindData.showControl = 0

	if self.currentActiveContent then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.currentActiveContent
	end
end

M.OnTakePhotoClick = function(self)
	gTakePhotoUtils.TryTakePhoto()
end

M.OnExitClick = function(self)
	local isPlaying = self.currentPlayActionInfo and self.currentPlayActionInfo.status ~= self.ACTION_STATUS.PLAY

	if isPlaying then
		self.bindData.rightContentWidget:SetActive(false)

		self.waitAnimationFinished = true

		if self:OnBreakMotionAction() then
			self.ClosePanel(self)
		elseif self.waitAnimationFinished then
			self.waitCloseCo = coroutine.start(function ()
				coroutine.wait(20)
				self:ClosePanel()
			end)
		end
	else
		self.ClosePanel(self)
	end
end

M.OnContentListOnScroll = function(self)
	local csIndex = self.bindData.contentList:GetNearestPageIndex()

	self.bindData.pageList:SelectItem(csIndex)
end

M.OnEnterCharMotionAnimation = function(self)
	if not self.currentPlayActionInfo then
		return
	end

	self.currentPlayActionInfo.status = self.ACTION_STATUS.PLAY
	self.hasPlayedLifeScheduleAction = true
	self.lastPlayActionInfo = self.currentPlayActionInfo

	self:NotifyCompanionSingleActionIfNeeded(self.currentPlayActionInfo.id)
	self.bindData.contentList:RefreshList()
	self:RefreshStopButtonView()
	self:AskReportPose(self.currentPlayActionInfo.id, UX.Game.PoseTriggerType.Start)
end

M.NotifyCompanionSingleActionIfNeeded = function(self, id)
	if not id then
		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if not actionItemCfg or actionItemCfg.Type == LTConfig.ActionItemConfig.TypeType.Single then
		return
	end

	gCS.LuaUtils.NotifyCompanionSingleActionChanged(id)
end

M.RefreshStopButtonView = function(self)
	if self.IsPlayingAction(self) then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)
		local multiInteractId = self.currentPlayActionInfo.multiInteractId
		local multiInteractCfg = LTConfig.MultiInteractConfig.GetConfig(multiInteractId)

		if not actionItemCfg.CanJoyStickBreakAction and multiInteractCfg and multiInteractCfg.IsStartLoopEnd ~= 1 then
			self.bindData.showStopButtonCtrl = 1

			self.bindData.stopButton:SetActive(true)

			return
		end
	end

	self.bindData.showStopButtonCtrl = 0

	self.bindData.stopButton:SetActive(false)
end

M.OnExitCharMotionAnimation = function(self, _, _)
	if not self.lastPlayActionInfo then
		if self.waitAnimationFinished then
			self.ClosePanel(self)
		end

		return
	end

	local id = self.lastPlayActionInfo.id
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if actionItemCfg.IsLoopAction then
		self.AskReportPose(self, id, UX.Game.PoseTriggerType.Loop)
	end

	self.AskReportPose(self, self.lastPlayActionInfo.id, UX.Game.PoseTriggerType.End)

	if self.lastPlayActionInfo ~= self.currentPlayActionInfo then
		self.lastPlayActionInfo = nil
		self.currentPlayActionInfo = nil

		gCS.LuaUtils.NotifyCompanionSingleActionEnded()
	end

	self:RefreshStopButtonView()
	self.bindData.contentList:RefreshList()

	if self.waitAnimationFinished then
		self.ClosePanel(self)
	end
end

M.OnJoyStickMove = function(self)
	if self.IsPlayingAction(self) then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if actionItemCfg.CanJoyStickBreakAction then
			self.OnBreakMotionAction(self)
		end
	end
end

M.OnBeginDrag = function(self)
end

M.OnDrag = function(self, eventData)
	if eventData.button ~= 0 then
		gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(eventData.delta.x, eventData.delta.y))
	end
end

M.OnEndDrag = function(self)
end

M.OnBreakMotionAction = function(self)
	if self.currentPlayActionInfo then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(self.currentPlayActionInfo.id)

		if actionItemCfg and actionItemCfg.IsLoopAction then
			if actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Single then
				if actionItemCfg.GameplayEndEvent <= 0 then
					gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, actionItemCfg.GameplayEndEvent)

					return false
				else
					print_error("@linminghe actionItemCfg.GameplayEndEvent is 0, id", actionItemCfg.Id)

					return true
				end
			elseif actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Double then
				local playerUnit = gCS.MyPlayerManager.PlayerUnit
				local targetUnit = playerUnit or self.npcUnit
				local result = nil
				local stateMachine = LX6.Units.Module.Interact.MainUnitInteractStateMachineModule.GetModule(playerUnit)

				if stateMachine then
					result = stateMachine.RequestMainManualExit(stateMachine)
				else
					result = LX6.Units.SpoonBTBridge.TryStoMultiInteract(targetUnit)
				end

				if result ~= AetherAI.Systems.InteractionSystem.MultiInteractStopResult.Success then
					return false
				else
					self.waitAnimationFinished = nil

					if result ~= AetherAI.Systems.InteractionSystem.MultiInteractStopResult.NoEndSpace then
						gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.NoEnoughSpaceStop)
					end

					return false
				end
			elseif actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Instrument then
				if actionItemCfg.GameplayEndEvent < 0 then
					print_error("乐器动作未配置GameplayEndEvent，无法退出，id", actionItemCfg.Id)

					return true
				end

				local playerUnit = gCS.MyPlayerManager.PlayerUnit

				local sendEndEvent = function()
					gCS.LogicStateMachineManager.SendGameplayInwardSignal(playerUnit, actionItemCfg.GameplayEndEvent)
				end

				if actionItemCfg.ExitBlackScreen then
					gBlackScreenManager:AutoTransition(gBlackScreenId.INSTRUMENT_ACTION, "", false, false, LTConfig.ActionItemConfig.InstrumentBlackOpenTime, LTConfig.ActionItemConfig.InstrumentBlackStayTime, LTConfig.ActionItemConfig.InstrumentBlackCloseTime, sendEndEvent)
				else
					sendEndEvent()
				end

				self.currentPlayActionInfo.status = self.ACTION_STATUS.BREAK

				return false
			end

			self.currentPlayActionInfo.status = self.ACTION_STATUS.BREAK
		end
	end

	self.RefreshStopButtonView(self)

	return true
end

M.CancelPendingInviteIfNeeded = function(self)
	if not self.isLinkMode or not self.pendingInviteActionId then
		return false
	end

	if self.currentPlayActionInfo or self.lastPlayActionInfo then
		return false
	end

	self.pendingInviteActionId = nil
	self.waitCancelPendingInviteAction = true

	if not self.IsPlayingAction(self) then
		slot1 = gClientToGameDelegate

		slot1:AskCancelInviterPlayerInteractionAction().Callback = function (errorId)
			self.waitCancelPendingInviteAction = nil

			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return
	end

	gLuaTimeMgrUtils.Delay(function ()
		if not self.waitCancelPendingInviteAction then
			return
		end

		if gCS.LuaUtils.IsBaseUnitValid(self.npcUnit) then
			gCS.LogicStateMachineManager.ResetStateToRoot(self.npcUnit)
		end

		slot0 = gClientToGameDelegate

		slot0:AskCancelInviterPlayerInteractionAction().Callback = function (errorId)
			self.waitCancelPendingInviteAction = nil

			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end
	end, 3)

	return true
end

M.AddMapLuaUnit = function(self, _, pid)
	if pid ~= gCS.MyPlayerManager.PlayerUnit.Pid then
		self.ClosePanel(self)
	end
end

M.ClosePanel = function(self)
	local reason = self.hasPlayedLifeScheduleAction and LifeScheduleInteract.Reason.Success or LifeScheduleInteract.Reason.PlayerCancelled

	LifeScheduleInteract:FireEnd(self.npcUnit, LifeScheduleInteract.Type.CharMotion, reason, self.npcPid)
	gPanelManager:Close(self.m_Id)
end

M.StopNpcThinking = function(self)
	self.bindData.npcThinkingNode:SetActive(false)

	self.showNpcBubbleThinkingCo = coroutine.stop(self.showNpcBubbleThinkingCo)
end

M.OnReplyInviteResult = function(self, _, replayState)
	self.StopNpcThinking(self)

	if replayState ~= UX.Game.InteractionActionInviteReplyState.InInteractionReject then
		self.pendingInviteActionId = nil

		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CanNotDoubleInteract)

		return
	end

	if replayState ~= UX.Game.InteractionActionInviteReplyState.Reject then
		self.pendingInviteActionId = nil

		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.RejectInviteTips)

		return
	end

	if not gGameSwitch.EnableInteractionAction then
		self.pendingInviteActionId = nil

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.GameSwitchFunctionDisabled)

		return
	end

	local id = self.pendingInviteActionId

	if not gCharMotionUtils.TryGetMultiInteractPosAndDir(id, gCS.MyPlayerManager.PlayerUnit, self.npcUnit) then
		self.pendingInviteActionId = nil

		return
	end

	slot4 = gClientToGameDelegate

	slot4:AskStartPlayerInteractionAction().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			print_debug(("交互动作:ActionId:%d_发起开始交互动作返回失败 errorId：%d"):format(id, errorId))
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gCS.LuaUtils.ManualCheckAnimLookAtIKOff(self.npcPid)

		local result, multiInteractId = gCharMotionUtils.TryMultiInteract(id, gCS.MyPlayerManager.PlayerUnit, self.npcUnit)

		if result then
			self.pendingInviteActionId = nil
			self.currentPlayActionInfo = {
				id = id,
				status = self.ACTION_STATUS.PREPARE,
				multiInteractId = multiInteractId
			}
		end
	end
end

M.OnCancelInvitePlayerAction = function(self, eventID, state)
	self.StopNpcThinking(self)

	self.pendingInviteActionId = nil

	self.RefreshStopButtonView(self)
end

M.OnCancelInviteePlayerAction = function(self, _, interactionActionState)
	self.StopNpcThinking(self)

	if interactionActionState ~= UX.Game.InteractionActionState.InvitingTimeout then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.InviteTimeOutTips)
	elseif interactionActionState ~= UX.Game.InteractionActionState.Cancel and self.npcName then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CancelInviteTips:format(self.npcName))
	end

	self.pendingInviteActionId = nil

	self.RefreshStopButtonView(self)
end

M.GetTypeIconId = function(self, typeId)
	if typeId ~= LTConfig.ActionItemConfig.TypeType.Single then
		return LTConfig.ActionItemConfig.TypeSingleIconId
	elseif typeId ~= LTConfig.ActionItemConfig.TypeType.Double then
		return LTConfig.ActionItemConfig.TypeDoubleIconId
	elseif typeId ~= LTConfig.ActionItemConfig.TypeType.Job then
		return LTConfig.ActionItemConfig.TypeJobIconId
	elseif typeId ~= LTConfig.ActionItemConfig.TypeType.Instrument then
		return LTConfig.ActionItemConfig.TypeInstrument
	end
end

M.OnStopClick = function(self)
	self.OnBreakMotionAction(self)
end

M.AskReportPose = function(self, id, poseTriggerType)
	if not id then
		return
	end

	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)

	if actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Single then
		gClientToGameSceneDelegate:AskReportSinglePose(id, poseTriggerType)
	elseif actionItemCfg.Type ~= LTConfig.ActionItemConfig.TypeType.Double then
		gClientToGameSceneDelegate:AskReportDoublePose(id, poseTriggerType, self.npcPid)
	end
end

M.OnHyperLinkClick = function(self, id)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
	local hyperLinkId = actionItemCfg.HyperLink
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	gCommonItemManager:OnDescItemClick(self.bindData.hyperLinkButton, hyperLinkInfo)
	self:OnExitClick()
end

M.OnConditionRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.conditionList[index + 1]

	if data.type ~= 1 then
		store.desc = LTConfig.ActionItemConfig.CurrentSpiritNotAvailableTips
	elseif data.type ~= 2 then
		local favorMeetTips = self.GetFavorMeetTips(self, data.id)
		store.desc = favorMeetTips
	end
end

M.OnGroupEnable = function(self)
	if self.m_Id ~= gPanelId.CHAR_MOTION_LIST_HALF_PANEL then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	end
end

M.OnGroupDisable = function(self)
	if self.m_Id ~= gPanelId.CHAR_MOTION_LIST_HALF_PANEL then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	end
end

M.OnDestroy = function(self)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)
	gCS.LuaUtils.ForceReadMouseMove(false)

	if self.m_Id ~= gPanelId.CHAR_MOTION_LIST_HALF_PANEL then
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	end

	if self.isFromMainPhone and gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
		gClientUtils.PlayPhoneAction()
	end

	self.showNpcBubbleThinkingCo = coroutine.stop(self.showNpcBubbleThinkingCo)
	self.isFromMainPhone = nil

	if gClientUtils.NotNil(gCS.CameraDataMgr.cameraControllerManager) then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	if self.motionInteractCheckModule then
		self.motionInteractCheckModule.OnCannotStandAction = nil
	end

	self.motionInteractCheckModule = nil

	self:ClearMessageEvents()
	self:OnBreakMotionAction()
	self:CancelPendingInviteIfNeeded()

	self.tabTipsCo = coroutine.stop(self.tabTipsCo)
	self.playNextActionCo = coroutine.stop(self.playNextActionCo)
	self.waitCloseCo = coroutine.stop(self.waitCloseCo)
	local duration = UXTime.GetNowUnixTime() - self.openTime

	gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.CHAR_MOTION_LIST_PANEL, self.selectedContentId or 0, duration)
	self:SetShowJoystick(false)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)
end

M.OnEnterTeamVisibleArea = function(self)
	self.isEnterTeamVisibleArea = true
end

M.OnExitTeamVisibleArea = function(self)
	self.isEnterTeamVisibleArea = nil
end

M.OnLogOut = function(self)
	self.isEnterTeamVisibleArea = nil
end

M.OnActiveDeviceChange = function(self, _)
	self.SetForceReadMouseMove(self)
end

M.SetForceReadMouseMove = function(self)
	if gClientUtils.CheckIsGamePadMode() then
		gCS.LuaUtils.ForceReadMouseMove(true)
	else
		gCS.LuaUtils.ForceReadMouseMove(false)
	end
end
