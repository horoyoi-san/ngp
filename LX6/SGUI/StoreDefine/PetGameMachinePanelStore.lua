-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameMachinePanelStore.lua
-- Decompiled from: 00814_PetGameMachinePanelStore.lua_cb59d733ab87.luajit

local xpcall = xpcall
local traceback = tolua.traceback
local UXTime = LTUtils.UXTime
local GameObject = UnityEngine.GameObject
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local petBehaviorState = PetGameConst.Behavior
local PetAnimation = PetGameEnum.PetAnimation
local PetAniEnum = PetGameEnum.PetAniEnum
local Net_GameMode = PetGameEnum.Net_GameMode
local StageShowType = PetGameConst.StageShowType
local OutSideShowType = PetGameConst.OutSideShowType
local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local petGameConstData = require("LX6/MiniGame/PetGame/data/tbconstants")
local walkDatas = require("LX6/MiniGame/PetGame/data/tbwalk")
local dropRewards = require("LX6/MiniGame/PetGame/data/tbdroprewards")
local stageConfig = require("LX6/MiniGame/PetGame/data/tbstageconfig")
local petData = require("LX6/MiniGame/PetGame/data/tbpet")
C_PetGameMachinePanelStore = DefClass("C_PetGameMachinePanelStore", C_PetGameMachinePanelStore, C_StoreGroup)
GroupName2Class.PetGameMachinePanelStore = C_PetGameMachinePanelStore
local M = C_PetGameMachinePanelStore
local viewState = {
	["\\xac\\xb0\\xae\\7\\xfb$"] = 1,
	["\\x90!4q\\x99D\\xef>\\xaf\\xae"] = 2
}
local PANEL_TO_TAB_INDEX = {
	[gPanelId.MINI_GAMES_PET_GAME_GET_PET_PANEL] = 0,
	[gPanelId.MINI_GAMES_PET_GAME_DEATH] = 1,
	[gPanelId.MINI_GAMES_PET_GAME_ENTER_SLEEP] = 2,
	[gPanelId.MINI_GAMES_PET_GAME_WAKE_UP] = 2,
	[gPanelId.MINI_GAMES_PET_GAME_LIST_PANEL] = 3,
	[gPanelId.MINI_GAMES_PET_GAME_SHOP_VIEW_PANEL] = 4,
	[gPanelId.MINI_GAMES_PET_GAME_SYSTEM_MENU_PANEL] = 5,
	[gPanelId.MINI_GAMES_PET_GAME_FOOD_VIEW_PANEL] = 6,
	[gPanelId.MINI_GAMES_PET_GAME_TIPS_PANEL] = 7,
	[gPanelId.MINI_GAMES_PET_GAME_RECORD_VIEW_PANEL] = 8,
	[gPanelId.MINI_GAMES_PET_GAME_SETTING_PANEL] = 9,
	[gPanelId.MINI_GAMES_PET_GAME_INFO_PANEL] = 10,
	[gPanelId.MINI_GAMES_PET_GAME_TIPS_VIEW_PANEL] = 11,
	[gPanelId.MINI_GAMES_PET_GAME_SHOP_BUY_PANEL] = 12,
	[gPanelId.MINI_GAMES_PETGAME_ACHIEVEMENT] = 13,
	[gPanelId.MINI_GAMES_PETGAME_ALBUM] = 14,
	[gPanelId.MINI_GAMES_PET_GAME_SHOP] = 15,
	[gPanelId.MINI_GAMES_PET_GAME_SOCIAL_ENTRY] = 16,
	[gPanelId.MINI_GAMES_PET_GAME_CHOOSE_REGION] = 17
}
local PET_GAME_PREFAB_ROOT = "Assets/Res/SGUI/Panel/PetGame/GameContent"
local ITEM_PREFAB_PATH_FORMAT = PET_GAME_PREFAB_ROOT .. "/items/%s.prefab"
local ITEM_ICON_PREFAB_PATH_FORMAT = PET_GAME_PREFAB_ROOT .. "/ItemIcons/%s.prefab"
local TREASURE_BOX_PREFAB_PATH_FORMAT = PET_GAME_PREFAB_ROOT .. "/explorationBox/effects_box%s.prefab"
local ITEM_PET_ANI_ENUM = {
	play_1 = PetAniEnum.play1,
	play_2 = PetAniEnum.play2
}

M.OnAwake = function(self)
	self.RegisterEvent(self)
	self.RegisterChildTabRect(self)

	self.bindData.menuBtn.luaPress = self.CreateActionWithArgs(self, self.OnMenuBtnPressed, true, self)
	self.bindData.menuBtn.luaRelease = self.CreateActionWithArgs(self, self.OnMenuBtnPressed, false, self)
	self.bindData.menuBtn.luaClick = self.CreateAction(self, self.OnMenuBtnClick, self)
	self.bindData.confirmBtn.luaPress = self.CreateActionWithArgs(self, self.OnConfirmBtnPressed, true, self)
	self.bindData.confirmBtn.luaRelease = self.CreateActionWithArgs(self, self.OnConfirmBtnPressed, false, self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnConfirmBtnClick, self)
	self.bindData.cancleBtn.luaPress = self.CreateActionWithArgs(self, self.OnCancleBtnPressed, true, self)
	self.bindData.cancleBtn.luaRelease = self.CreateActionWithArgs(self, self.OnCancleBtnPressed, false, self)
	self.bindData.cancleBtn.luaClick = self.CreateAction(self, self.OnCancleBtnClick, self)

	if self.bindData.exitBtn then
		self.bindData.exitBtn.luaLongPress = self.CreateAction(self, self.OnExitBtnLongPress, self)
	end

	self.InitStageInfo(self)
	self.InitOutSideInfo(self)
	self.InitPoo(self)
	self.InitUIMaskAni(self)
end

M.RegisterChildTabRect = function(self)
	if self.bindData.childTabRect then
		self.bindData.childTabRect.OnRenderTab = self.CreateAction(self, self.OnChildTabRender, self)
		self.bindData.childTabRect.selectedIndex = -1
	end
end

M.OnChildTabRender = function(self, index, widget)
	if not widget or not widget.Store then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local args = self.pendingChildArgs or {}
	args.parent = self
	local panelId = self.pendingChildPanelId
	self.pendingChildArgs = nil
	self.pendingChildPanelId = nil

	if storeGroup.OnShow then
		storeGroup.OnShow(storeGroup, panelId, args)
	end
end

M.OnDestroy = function(self)
	self.CloseStandaloneChildPanels(self)
	self.UnregisterEvent(self)
	self.ClearRoomStageManager(self)
	self.ClearStageInfo(self)
	self.CleaningOutSideViewOnDestroy(self)
	self.ClearUIMaskAniTimer(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.pet = data.pet
	self.listPanelOpen = false
	self.listPanelId = nil
	self.curChildPanel = nil
	self.pendingChildPanelId = nil
	self.pendingChildArgs = nil
	self.standaloneChildPanels = {}

	if self.bindData.childTabRect then
		self.bindData.childTabRect.selectedIndex = -1
	end

	self:ShowView(viewState.gameView)

	if self.pet:HasClaimedPet() then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ACTUAL_BEGIN)
	else
		self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_GET_PET_PANEL, {
			parent = self
		})
	end
end

M.OnClose = function(self)
	self.CloseListPanel(self)
	self.ClearRoomStageManager(self)
end

M.InitRoom = function(self)
	local roomManager = gPetGameManager.currentGame:GetRoomManager()

	roomManager:InitRooms(self.bindData.roomParent)
	roomManager:ApplyFurnitureData()
	roomManager:ActiveRoom()
end

M.GetRoomStageManager = function(self)
	local currentGame = gPetGameManager and gPetGameManager.currentGame

	if currentGame then
		return currentGame.GetStageManager(currentGame)
	end
end

M.ClearRoomStageManager = function(self)
	local stageManager = self.GetRoomStageManager(self)

	if stageManager then
		stageManager.Clear(stageManager)
	end
end

M.ActualBegin = function(self)
	self.InitRoom(self)

	local stageManager = self.GetRoomStageManager(self)

	if stageManager then
		stageManager.InitStageInfo(stageManager, self)
	end

	self:OnPetWakeUp()

	if not self.pet:IsAlive() then
		self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_DEATH)

		return
	end

	local petAge = self.pet:GetAttribute("age")

	if petAge >= 1 then
		self.pet:InitPetBirthTime()
	end

	self:ShowUIMaskAni2()

	local roomManager = gPetGameManager.currentGame:GetRoomManager()
	local currentRoom = roomManager:GetCurrentRoom()

	self.pet:LoadPetGameObject(currentRoom:GetPetTrans())

	if self:CheckIsWalking() then
		local saveData = gPetGameOutSideDataManager:GetData()
		local lastType = saveData.type or PetGameConst.OutSideShowType.goStreet

		self:EnterOutSideView(lastType)
	end

	self.ShowOldPooAtBenginning(self)
end

M.OnMenuBtnPressed = function(self, isPressed)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			return
		end

		local func = eventHandler.OnMenuBtnPressed
		local target = eventHandler.target

		xpcall(func, traceback, target, isPressed)
	end
end

M.OnMenuBtnClick = function(self)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			self.systemBtnEventHandlers[self.curChildPanel] = nil

			return
		end

		local func = eventHandler.OnMenuBtnClick
		local target = eventHandler.target

		xpcall(func, traceback, target)

		return
	end

	local stageManager = self.GetRoomStageManager(self)

	if stageManager and stageManager.IsPlaying(stageManager) then
		return
	end

	if self.currentViewState ~= viewState.outSideView or gPetGameSocialPlayManager and gPetGameSocialPlayManager:IsPlaying() then
		return
	end

	if not self.pet then
		print_error("OnMenuBtnClick: self.pet is nil")

		return
	end

	local isGrowup = self.pet:GetPetLv() >= 1

	if not self.pet:IsAlive() or not isGrowup then
		return
	end

	local isPetSleep = self.pet:IsSleeping()
	local nowDateTime = UXTime.UnixTimeToDateTime(gPetGameTime:Now())
	local remindWakeUpTime = petGameConstData.data.RemindWakeUpTime

	if isPetSleep and remindWakeUpTime.startTime < nowDateTime.Hour and nowDateTime.Hour >= remindWakeUpTime.endTime then
		self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_WAKE_UP)

		return
	end

	local remindSleepTime = petGameConstData.data.RemindSleepTime

	if not isPetSleep and remindSleepTime.startTime < nowDateTime.Hour and nowDateTime.Hour >= remindSleepTime.endTime then
		self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_ENTER_SLEEP)

		return
	end

	if isPetSleep then
		return
	end

	self.ShowSystemMenu(self)
end

M.OnConfirmBtnPressed = function(self, isPressed)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			return
		end

		local func = eventHandler.OnConfirmBtnPressed
		local target = eventHandler.target

		xpcall(func, traceback, target, isPressed)
	end
end

M.OnConfirmBtnClick = function(self)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			return
		end

		local func = eventHandler.OnConfirmBtnClick
		local target = eventHandler.target

		xpcall(func, traceback, target)

		return
	end

	local stageManager = self.GetRoomStageManager(self)

	if stageManager and stageManager.IsPlaying(stageManager) then
		stageManager.ForceEndStage(stageManager)

		return
	end

	if self.curStageType then
		self.ForceEndStage(self)

		return
	end

	if self.pet and self.pet:IsSleeping() then
		return
	end

	self.Change2NextRoom(self, true)
end

M.OnCancleBtnPressed = function(self, isPressed)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			return
		end

		local func = eventHandler.OnCancleBtnPressed
		local target = eventHandler.target

		xpcall(func, traceback, target, isPressed)
	end
end

M.OnCancleBtnClick = function(self)
	if self.curChildPanel and self.systemBtnEventHandlers then
		local eventHandler = self.systemBtnEventHandlers[self.curChildPanel]

		if not eventHandler then
			return
		end

		local func = eventHandler.OnCancleBtnClick
		local target = eventHandler.target

		xpcall(func, traceback, target)

		return
	end

	if self.currentViewState ~= viewState.outSideView then
		self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_TIPS_PANEL, {
			["\\xcd\\xd2)4\\xf4"] = "vTʊ\\x85\\xb3\r\\xc7\\xef"
		})

		return
	end

	if self.pet and self.pet:IsSleeping() then
		return
	end

	self.Change2NextRoom(self, false)
end

M.Change2NextRoom = function(self, isLeft)
	if self.currentViewState == viewState.gameView or self.curChildPanel or self.curStageType then
		return
	end

	local stageManager = self.GetRoomStageManager(self)

	if stageManager and stageManager.IsPlaying(stageManager) then
		return
	end

	if not self.pet or not self.pet:IsAlive() or self.pet:GetPetLv() < 1 then
		return
	end

	if gPetGameSocialPlayManager and gPetGameSocialPlayManager:IsPlaying() then
		return
	end

	local roomManager = gPetGameManager.currentGame:GetRoomManager()

	if not roomManager or not roomManager.HasNextRoom(roomManager, isLeft) then
		return
	end

	local birthPos = roomManager.GetNextRoomBirthPoint(roomManager, isLeft)

	if not birthPos then
		return
	end

	self:ShowUIMaskAni1()
	roomManager:Change2NextRoom(isLeft)
	self.pet:SetPosition(birthPos)

	local curStatus, currentState = self.pet:GetState()

	if curStatus ~= petBehaviorState.walking and currentState and currentState.UpdateDirection then
		currentState.UpdateDirection(currentState)
	else
		self.pet:ChangeState(petBehaviorState.walking)
	end
end

M.OnExitBtnLongPress = function(self)
	gPetGameManager:DestroyGame()
end

M.RegisterSystemBtnEvent = function(self, eventHandler)
	if not self.systemBtnEventHandlers then
		self.systemBtnEventHandlers = {}
	end

	local pannelId = eventHandler.panelId
	self.systemBtnEventHandlers[pannelId] = eventHandler

	if self.listPanelOpen and pannelId == self.listPanelId then
		self.curChildPanel = pannelId
	end
end

M.UnregisterSystemBtnEvent = function(self, pannelId)
	if not self.systemBtnEventHandlers then
		return
	end

	self.systemBtnEventHandlers[pannelId] = nil
end

M.ClearSystemBtnEvent = function(self)
	self.systemBtnEventHandlers = nil
end

M.RegisterEvent = function(self)
	self.eventHandle = {
		[gEventConstants.MINIGAME_PET_GAME_ON_PET_DIE] = function ()
			self:OnPetDie()
		end,
		[gEventConstants.MINIGAME_PET_GAME_RESTART] = function ()
			self:OnGameRestart()
		end,
		[gEventConstants.MINIGAME_PET_GAME_ACTUAL_BEGIN] = function ()
			self:ActualBegin()
		end,
		[gEventConstants.MINIGAME_PET_GAME_ENTER_SLEEP] = function ()
			self:OnPetEnterSleep()
		end,
		[gEventConstants.MINIGAME_PET_GAME_WAKE_UP] = function ()
			self:OnPetWakeUp()
		end,
		[gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN] = function (eventId, args)
			local stageManager = self:GetRoomStageManager()

			if stageManager and args and stageManager.CanHandleStage(stageManager, args.type) then
				return
			end

			self:BeginStageShow(args)
		end,
		[gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_END] = function ()
			local stageManager = self:GetRoomStageManager()

			if stageManager and stageManager.IsPlaying(stageManager) then
				return
			end

			self:EndStageShow()
		end,
		[gEventConstants.MINIGAME_PET_GAME_GO_OUTSIDE] = function (eventId, args)
			self:EnterOutSideView(args.type)
		end,
		[gEventConstants.MINIGAME_PET_GAME_SHOW_UI_MASK] = function ()
			self:ShowUIMaskAni1()
		end
	}
	local socialInviteReceivedEvent = gEventConstants.MINIGAME_PET_GAME_SOCIAL_INVITE_RECEIVED

	if socialInviteReceivedEvent then
		self.eventHandle[socialInviteReceivedEvent] = function (eventId, roomData)
			self:OnInviteMsgReceived(roomData)
		end
	end

	local socialPlayFinishedEvent = gEventConstants.MINIGAME_PET_GAME_SOCIAL_PLAY_FINISHED

	if socialPlayFinishedEvent then
		self.eventHandle[socialPlayFinishedEvent] = function ()
			self:OnSocialPlayFinished()
		end
	end

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

M.UnregisterEvent = function(self)
	if not self.eventHandle then
		return
	end

	gMessageManager:UnregisterEventHandlers(self.eventHandle)

	self.eventHandle = nil
end

M.OnPetDie = function(self)
	self.CloseListPanel(self)

	local pannelData = {
		parent = self
	}

	self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_DEATH, pannelData, true)
end

M.OnGameRestart = function(self)
end

M.OnPetEatFinish = function(self, itemId)
	self._TryRestoreAfterStage(self)
end

M.OnPetPlayingFinish = function(self, itemId)
	self._TryRestoreAfterStage(self)
end

M._TryRestoreAfterStage = function(self)
	local restore = self.pendingRestoreAfterStage

	if not restore then
		return
	end

	self.pendingRestoreAfterStage = nil

	if restore.panelId then
		self.OpenChildPanel(self, restore.panelId, restore.data)
	end
end

M.OnPetCleaningFnish = function(self)
end

M.OnPetEnterSleep = function(self)
	local nightMask = self.bindData.nightMask and self.bindData.nightMask.gameObject or nil

	if nightMask then
		nightMask.SetActive(nightMask, true)
	end
end

M.OnPetWakeUp = function(self)
	local nightMask = self.bindData.nightMask and self.bindData.nightMask.gameObject or nil

	if nightMask then
		nightMask.SetActive(nightMask, false)
	end
end

M.OpenChildPanel = function(self, childPanel, args, showUIMask, showBigUIMask)
	if childPanel ~= gPanelId.MINI_GAMES_PET_GAME_LIST_PANEL then
		self:ShowListPanel(args and args.page)

		return
	end

	if self.curChildPanel and self.curChildPanel ~= childPanel then
		return
	end

	if showBigUIMask then
		if self.openChildPanelTimer then
			return
		end
	elseif self.openChildPanelTimer then
		self.openChildPanelTimer:Stop()

		self.openChildPanelTimer = nil

		return
	end

	local tabIndex = PANEL_TO_TAB_INDEX[childPanel]

	local func = function()
		self.openChildPanelTimer = nil
		args = args or {}
		args.parent = self

		if self.curChildPanel and self.curChildPanel == childPanel then
			self:CloseChildPanel(self.curChildPanel)
		end

		if not tabIndex then
			if self.bindData.childTabRect then
				self.bindData.childTabRect.selectedIndex = -1
			end

			gPanelManager:CheckShow(childPanel, args)

			local attachParent = self.currentViewState ~= viewState.gameView and self.bindData.gameUINode or self.bindData.outSideUITrans

			gPanelManager:AttachPanelToThisPanelById(childPanel, gPanelId.MINI_GAMES_PET_GAME_MACHINE_PANEL, attachParent)

			self.standaloneChildPanels = self.standaloneChildPanels or {}
			self.standaloneChildPanels[childPanel] = true
			self.curChildPanel = childPanel

			return
		end

		self.pendingChildArgs = args
		self.pendingChildPanelId = childPanel
		self.curChildPanel = childPanel

		if self.bindData.childTabRect then
			self.bindData.childTabRect.selectedIndex = tabIndex
		end
	end

	if showBigUIMask then
		self:ShowUIMaskAni2(childPanel)

		self.openChildPanelTimer = Timer.New(func, 0.35, 1)

		self.openChildPanelTimer:Start()
	else
		if showUIMask then
			self.ShowUIMaskAni1(self)
		end

		func()
	end
end

M.CloseChildPanel = function(self, childPanel)
	if self.standaloneChildPanels and self.standaloneChildPanels[childPanel] then
		gPanelManager:ReleaseAttachingChildPanel(childPanel)
		gPanelManager:DelayClose(childPanel, nil, 0.2)

		self.standaloneChildPanels[childPanel] = nil

		if childPanel ~= self.curChildPanel then
			self.curChildPanel = nil
		end

		return
	end

	if childPanel == self.curChildPanel and childPanel == self.listPanelId then
		return
	end

	if childPanel ~= self.curChildPanel then
		if self.listPanelOpen and childPanel == self.listPanelId then
			local listPanelId = self.listPanelId
			local listTab = PANEL_TO_TAB_INDEX[listPanelId]
			self.curChildPanel = listPanelId
			self.pendingChildArgs = {
				parent = self,
				page = self.listPanelPage or "clean"
			}
			self.pendingChildPanelId = listPanelId

			if self.bindData.childTabRect and listTab then
				self.bindData.childTabRect.selectedIndex = listTab
			end

			return
		else
			self.curChildPanel = nil

			if self.bindData.childTabRect then
				self.bindData.childTabRect.selectedIndex = -1
			end
		end
	end

	if childPanel ~= self.listPanelId then
		self.listPanelOpen = false
		self.listPanelId = nil
		self.listPanelPage = nil
	end
end

M.CloseStandaloneChildPanels = function(self)
	if not self.standaloneChildPanels then
		return
	end

	for panelId in pairs(self.standaloneChildPanels) do
		gPanelManager:ReleaseAttachingChildPanel(panelId)
		gPanelManager:Close(panelId)
	end

	self.standaloneChildPanels = nil
end

M.ShowListPanel = function(self, page)
	if self.listPanelOpen then
		return
	end

	if self.curChildPanel and self.curChildPanel ~= gPanelId.MINI_GAMES_PET_GAME_LIST_PANEL then
		return
	end

	if self.openChildPanelTimer then
		return
	end

	local listPanelId = gPanelId.MINI_GAMES_PET_GAME_LIST_PANEL
	local listTab = PANEL_TO_TAB_INDEX[listPanelId]

	if not listTab then
		return
	end

	self.listPreviousPanel = self.curChildPanel

	local func = function()
		self.openChildPanelTimer = nil
		local args = {
			parent = self,
			page = page or "clean"
		}
		self.pendingChildArgs = args
		self.pendingChildPanelId = listPanelId
		self.listPanelPage = page or "clean"
		self.curChildPanel = listPanelId
		self.listPanelOpen = true
		self.listPanelId = listPanelId

		if self.bindData.childTabRect then
			self.bindData.childTabRect.selectedIndex = listTab
		end
	end

	self:ShowUIMaskAni2(listPanelId)

	self.openChildPanelTimer = Timer.New(func, 0.35, 1)

	self.openChildPanelTimer:Start()
end

M.CloseListPanel = function(self)
	if not self.listPanelOpen then
		return
	end

	local prev = self.listPreviousPanel
	self.listPanelOpen = false
	self.listPanelId = nil
	self.listPanelPage = nil
	self.curChildPanel = nil
	self.listPreviousPanel = nil

	if prev and PANEL_TO_TAB_INDEX[prev] then
		self.pendingChildArgs = {
			parent = self,
			initialSelected = self.lastSystemMenuSelected
		}
		self.pendingChildPanelId = prev
		self.curChildPanel = prev

		if self.bindData.childTabRect then
			self.bindData.childTabRect.selectedIndex = PANEL_TO_TAB_INDEX[prev]
		end

		return
	end

	if self.bindData.childTabRect then
		self.bindData.childTabRect.selectedIndex = -1
	end
end

M.ShowSystemMenu = function(self)
	self.lastSystemMenuSelected = nil
	local menuPanelId = gPanelId.MINI_GAMES_PET_GAME_SYSTEM_MENU_PANEL
	local args = {
		parent = self
	}

	self.OpenChildPanel(self, menuPanelId, args, false, true)
end

M.CloseToMain = function(self)
	if self.curChildPanel and self.standaloneChildPanels and self.standaloneChildPanels[self.curChildPanel] then
		self.CloseChildPanel(self, self.curChildPanel)
	end

	self.listPanelOpen = false
	self.listPanelId = nil
	self.listPanelPage = nil
	self.listPreviousPanel = nil
	self.curChildPanel = nil

	if self.bindData.childTabRect then
		self.bindData.childTabRect.selectedIndex = -1
	end
end

M.OnInviteMsgReceived = function(self, roomData)
	if not roomData or not self.pet then
		return
	end

	if roomData.GameMode ~= Net_GameMode.Marriage and not self.pet:IsMatureForm() then
		return
	end

	self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_SOCIAL_REC_TIPS, {
		roomData = roomData
	})
end

M.OnSocialPlayFinished = function(self)
	self.OpenChildPanel(self, gPanelId.MINI_GAMES_PET_GAME_SOCIAL_ENTRY)
end

M.CloseSystemMenu = function(self)
	local menuPanelId = gPanelId.MINI_GAMES_PET_GAME_SYSTEM_MENU_PANEL

	if self.curChildPanel ~= menuPanelId then
		self.CloseChildPanel(self, menuPanelId)
	end
end

M.InitStageInfo = function(self)
	self.stageGo = self.bindData.stage.gameObject

	self.stageGo:SetActive(false)

	self.stagePetTrans = self.bindData.stagePetTrans.transform
	self.stageMaskGo = self.bindData.stageMask.gameObject
	self.stageMaskAni = self.stageMaskGo.transform:GetComponent("Animation")

	self:InitLevelUpStageInfo()
end

M.BeginStageShow = function(self, args)
	local type = args.type
	local itemId = args.itemId

	if self.isPlayingOutSide then
		if type ~= StageShowType.passStool then
			self.ShowRandomPoo(self)
		end

		return
	end

	if type ~= StageShowType.passStool and self.curChildPanel then
		self.ShowRandomPoo(self)

		return
	end

	if self.isStageShowing then
		if type ~= StageShowType.passStool then
			self.ShowRandomPoo(self)

			return
		end

		if type ~= StageShowType.levelUp then
			self.cacheLevelUpArgs = args

			return
		end

		return
	end

	self.isStageShowing = true
	local pet = gPetGameManager.currentGame.pet

	if not pet or not pet.petGo then
		return
	end

	self.stageGo:SetActive(true)

	if self.bindData.petNode then
		self.bindData.petNode.gameObject:SetActive(false)
	end

	self.PlayStageMaskFadeIn(self)
	self.ClearStagePetInfo(self)

	if type == StageShowType.levelUp then
		self.stagePetGo, self.stagePetAni = self.ClonePetGo(self, pet.petGo)
	end

	if type ~= StageShowType.eating then
		self.PlayEating(self, type, itemId)
	elseif type ~= StageShowType.playToy then
		self.PlayToy(self, type, itemId)
	elseif type ~= StageShowType.bathe then
		self.PlayBathe(self, type, itemId)
	elseif type ~= StageShowType.treat then
		pet.OnTreatFinish(pet)
		self.PlayTreat(self, type, itemId)
	elseif type ~= StageShowType.passStool then
		self.PlayPassStool(self, type, itemId)
	elseif type ~= StageShowType.clearUpPoop then
		pet.OnPoopCleaned(pet)
		self.PlayClearUpPoop(self, type, itemId)
	elseif type ~= StageShowType.levelUp then
		local beforeId = args.beforePetId
		local afterId = args.afterPetId

		self.PlayLevelUp(self, type, beforeId, afterId)
	end

	self.curStageType = type
	self.itemId = itemId
end

M.EndStageShow = function(self, showType)
	showType = showType or self.curStageType
	self.curStageType = nil
	local pet = gPetGameManager.currentGame.pet

	if pet then
		pet.ChangeState(pet, petBehaviorState.idle)
	end

	self.stageMaskFadeOutTimer = Timer.New(function ()
		self.stageMaskFadeOutTimer = nil
		self.isStageShowing = false

		if showType ~= StageShowType.eating then
			self:OnPetEatFinish(self.itemId)
		elseif showType ~= StageShowType.playToy then
			self:OnPetPlayingFinish(self.itemId)
		elseif showType ~= StageShowType.treat or showType ~= StageShowType.bathe or showType ~= StageShowType.clearUpPoop then
			self:OnPetCleaningFnish()
		elseif showType ~= StageShowType.levelUp then
			self:OnLevelUpFinish()
		end

		self.stageGo:SetActive(false)

		if self.bindData.petNode then
			self.bindData.petNode.gameObject:SetActive(true)
		end

		self:ClearStagePetInfo()
	end, 0.4, 1, false, false)
	slot3 = self.stageMaskFadeOutTimer

	slot3:Start()
	self:PlayStageMaskFadeOut(function ()
		if self.cacheLevelUpArgs then
			self:BeginStageShow(self.cacheLevelUpArgs)

			self.cacheLevelUpArgs = nil
		end
	end)
end

M.ForceEndStage = function(self)
	local curStageType = self.curStageType

	if not curStageType then
		return
	end

	local canSkip = stageConfig[curStageType] and stageConfig[curStageType].canSkip

	if not canSkip then
		return
	end

	self.ClearStageMaskTimer(self)
	self.ClearInteractTimer(self)
	self.EndStageShow(self, curStageType)
end

M.PlayStageMaskFadeIn = function(self)
	self.stageMaskGo:SetActive(true)
	self.stageMaskAni:Play("StageMaskFadeIn")
	self:ClearStageMaskTimer()

	self.stageMaskTimer = Timer.New(function ()
		self.stageMaskTimer = nil

		self.stageMaskGo:SetActive(false)
	end, 1, 1, false, false)

	self.stageMaskTimer:Start()
end

M.PlayStageMaskFadeOut = function(self, callback)
	self.stageMaskGo:SetActive(true)
	self.stageMaskAni:Play("StageMaskFadeOut")
	self:ClearStageMaskTimer()

	self.stageMaskTimer = Timer.New(function ()
		self.stageMaskTimer = nil

		self.stageMaskGo:SetActive(false)

		if callback then
			callback(self)
		end
	end, 1.15, 1, false, false)

	self.stageMaskTimer:Start()
end

M.ClonePetGo = function(self, petGo)
	local parent = self.stagePetTrans
	local clone = UnityEngine.GameObject.Instantiate(petGo, parent)

	clone.transform:SetLocalPosition(0, 0, 0)
	self:ClearPetEffect(clone.transform)

	local animator = clone.transform:GetComponent("Animation")

	return clone, animator
end

M.ClearPetEffect = function(self, petTrans)
	local effects_treat = petTrans.Find(petTrans, "body/effects_treat")

	if effects_treat then
		effects_treat.gameObject:SetActive(false)
	end

	local effects_sleep = petTrans.Find(petTrans, "body/effects_sleep")

	if effects_sleep then
		effects_sleep.gameObject:SetActive(false)

		local sleepAni = effects_sleep:GetChild(0)

		if sleepAni then
			sleepAni.gameObject:SetActive(false)
		end
	end

	local effects_up = petTrans.Find(petTrans, "body/effects_up")

	if effects_up then
		effects_up.gameObject:SetActive(false)
	end

	local effects_dirty = petTrans.Find(petTrans, "body/effects_dirty")

	if effects_dirty then
		effects_dirty.gameObject:SetActive(false)
	end
end

M.PlayPetAni = function(self, animator, petAniEnum)
	if not animator then
		return false
	end

	local baseAni = PetAnimation[petAniEnum]

	if not baseAni or not animator.GetClip(animator, baseAni) then
		print_warn("宠物身上找不到动画 clip：", petAniEnum)

		return false
	end

	animator.Play(animator, baseAni)

	return true
end

M.PlayEating = function(self, showType, foodId)
	local feedTrans = self.stagePetGo.transform:Find("body/eat")

	self:LoadItemGo(ITEM_PREFAB_PATH_FORMAT, foodId, feedTrans)
	self:PlayPetAni(self.stagePetAni, PetAniEnum.eat)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.PlayToy = function(self, showType, itemId)
	local itemData = ItemDatas[itemId]

	if not itemData or not itemData.itemParent then
		print_error("PlayToy Error:", itemId)

		return
	end

	local feedTrans = self.stagePetGo.transform:Find(itemData.itemParent)

	self:LoadItemGo(ITEM_PREFAB_PATH_FORMAT, itemId, feedTrans)
	self:PlayPetAni(self.stagePetAni, ITEM_PET_ANI_ENUM[itemData.petAni])
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.PlayBathe = function(self, showType, itemId)
	self:PlayPetAni(self.stagePetAni, PetAniEnum.batheAni)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.PlayTreat = function(self, showType, itemId)
	self:PlayPetAni(self.stagePetAni, PetAniEnum.treatAni)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.PlayPassStool = function(self, showType, itemId)
	self:PlayPetAni(self.stagePetAni, PetAniEnum.defecate)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:ShowRandomPoo()
		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.PlayClearUpPoop = function(self, showType, itemId)
	self:ClearInteractTimer()
	self:PlayPetAni(self.stagePetAni, PetAniEnum.idle)

	self.pooAniCloneGo = self:ClonePooAni()
	local delayTime = self:PlayPooCleanAni(self.pooAniCloneGo.transform)

	self:ResetPoo()

	local aniTime = stageConfig[showType].aniLenth + delayTime
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

M.ClonePooAni = function(self)
	local parent = self.bindData.stagePooAniTrans.transform
	local pooAniGo = self.bindData.pooTrans.gameObject
	local clone = UnityEngine.GameObject.Instantiate(pooAniGo, parent)

	clone.transform:SetLocalPosition(0, 0, 0)

	return clone
end

M.PlayPooCleanAni = function(self, clonePooTrans)
	local cout = clonePooTrans.childCount
	local delay = 0

	for i = 1, cout do
		local pooItem = clonePooTrans.GetChild(clonePooTrans, i - 1)

		if pooItem then
			local pooItemGo = pooItem.GetChild(pooItem, 0).gameObject

			if pooItemGo.activeSelf then
				local pooAni = pooItemGo.transform:GetComponent("Animation")
				delay = delay + 0.1

				Timer.New(function ()
					if not pooAni then
						return
					end

					pooAni.enabled = true

					pooAni:Play("clean")
				end, delay, 1):Start()
			end
		end
	end

	return delay
end

M.InitLevelUpStageInfo = function(self)
	self.levelUpStageGo = self.bindData.stageEffect.gameObject
	self.levelUpStageAni = self.levelUpStageGo.transform:GetComponent("Animation")
	self.stageLvUpLost1 = self.bindData.stageLvUpLost1.transform
	self.stageLvUpLost2 = self.bindData.stageLvUpLost2.transform
end

M.PlayLevelUp = function(self, showType, beforeId, afterId)
	self.levelUpStageGo:SetActive(true)

	self.levelUpStageAni.enabled = true

	self.levelUpStageAni:Play("up")
	self:ClearLevelUpPet()

	local beforePetData = petData[beforeId]

	self:LoadPrefabGo(beforePetData.prefab, self.stageLvUpLost1, self.OnLevelUpPetBeForPetLoaded)

	local afterPetData = petData[afterId]

	self:LoadPrefabGo(afterPetData.prefab, self.stageLvUpLost2, self.OnLevelUpPetAfterPetLoaded)

	local stayTime = stageConfig[showType].aniLenth or 5

	self:ClearLevelUpTimer()

	self.levelUpTimer = Timer.New(function ()
		self:EndStageShow(showType)
	end, stayTime, 1)

	self.levelUpTimer:Start()
end

M.OnLevelUpPetBeForPetLoaded = function(self, petGo)
	self.levelUpPetGo1 = petGo

	self.PlayLevelUpAni(self, self.levelUpPetGo1, PetAniEnum.up1)
end

M.OnLevelUpPetAfterPetLoaded = function(self, petGo)
	self.levelUpPetGo2 = petGo

	self.PlayLevelUpAni(self, self.levelUpPetGo2, PetAniEnum.up2)
end

M.PlayLevelUpAni = function(self, petGo, petAniEnum)
	local animator = petGo.transform:GetComponent("Animation")

	self:PlayPetAni(animator, petAniEnum)
end

M.OnLevelUpFinish = function(self)
	self.levelUpStageGo:SetActive(false)

	if self.levelUpStageAni then
		self.levelUpStageAni.enabled = false
	end

	self.ClearLevelUpPet(self)
	self.ClearLevelUpTimer(self)
end

M.ClearLevelUpPet = function(self)
	if self.levelUpPetGo1 then
		GameObject.Destroy(self.levelUpPetGo1)

		self.levelUpPetGo1 = nil
	end

	if self.levelUpPetGo2 then
		GameObject.Destroy(self.levelUpPetGo2)

		self.levelUpPetGo2 = nil
	end
end

M.ClearLevelUpTimer = function(self)
	if self.levelUpTimer then
		self.levelUpTimer:Stop()
	end

	self.levelUpTimer = nil
end

M.LoadItemGo = function(self, parentPath, itemId, parent, callback)
	local itemData = ItemDatas[itemId]

	if not itemData or not itemData.icon then
		print_error("do not find this food:%s in the tbitems:", itemId)

		return
	end

	local iconPath = itemData.icon
	local prefabPath = string.format(parentPath, iconPath)
	slot8 = gResourceManager

	slot8:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if loadOp.asset then
			local itemGo = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not itemGo then
				error("Failed to instantiate food prefab: " .. prefabPath)

				return
			end

			if callback then
				xpcall(callback, traceback, self, itemGo)
			end
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

M.LoadPrefabGo = function(self, prefabPath, parent, callback)
	slot4 = gResourceManager

	slot4:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if loadOp.asset then
			local itemGo = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not itemGo then
				error("Failed to instantiate food prefab: " .. prefabPath)

				return
			end

			itemGo.transform:SetLocalPosition(0, 0, 0)

			if callback then
				xpcall(callback, traceback, self, itemGo)
			end
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

M.ClearStageInfo = function(self)
	self.stageGo = nil
	self.stagePetTrans = nil
	self.stageMaskGo = nil
	self.stageMaskAni = nil

	self.ClearStagePetInfo(self)
	self.ClearStageMaskTimer(self)
	self.ClearInteractTimer(self)
	self.ClearStageMaskFadeOutTimer(self)
end

M.ClearStageMaskTimer = function(self)
	if self.stageMaskTimer then
		self.stageMaskTimer:Stop()
	end

	self.stageMaskTimer = nil
end

M.ClearInteractTimer = function(self)
	if self.interactTimer then
		self.interactTimer:Stop()
	end

	self.interactTimer = nil
end

M.ClearStageMaskFadeOutTimer = function(self)
	if self.stageMaskFadeOutTimer then
		self.stageMaskFadeOutTimer:Stop()

		self.stageMaskFadeOutTimer = nil
	end
end

M.ClearStagePetInfo = function(self)
	if self.stagePetGo then
		GameObject.Destroy(self.stagePetGo)

		self.stagePetGo = nil
		self.stagePetAni = nil
	end

	if self.pooAniCloneGo then
		GameObject.Destroy(self.pooAniCloneGo)

		self.pooAniCloneGo = nil
	end
end

M.InitPoo = function(self)
	local pooTrans = self.bindData.pooTrans.transform
	local cout = pooTrans.childCount
	self.allPooList = {}
	self.unUsePoo = {}
	self.curPooNum = 0

	for i = 1, cout do
		local pooItem = pooTrans.GetChild(pooTrans, i - 1)

		if pooItem then
			local pooItemGo = pooItem.GetChild(pooItem, 0).gameObject

			pooItemGo.SetActive(pooItemGo, false)

			self.allPooList[i] = pooItemGo

			table.insert(self.unUsePoo, i)
		end
	end
end

M.ResetPoo = function(self)
	for i, v in pairs(self.allPooList) do
		v.SetActive(v, false)
	end

	self.unUsePoo = {}

	for i = 1, #self.allPooList do
		table.insert(self.unUsePoo, i)
	end

	self.curPooNum = 0
end

M.ShowOldPooAtBenginning = function(self)
	local pet = self.pet
	local num = pet.GetAttribute(pet, "poopNum")

	self.ResetPoo(self)

	for i = 1, num do
		self.ShowRandomPoo(self)
	end
end

M.ShowRandomPoo = function(self)
	if PetGameConst.MAX_POO_NUM < self.curPooNum then
		return
	end

	local index = self.GetRandomPooIndex(self)

	if not index then
		return
	end

	local pooItemGo = self.allPooList[index]

	if pooItemGo then
		self.curPooNum = self.curPooNum + 1

		pooItemGo.SetActive(pooItemGo, true)
	end
end

M.HasPooInRoom = function(self)
	return self.curPooNum >= 0
end

M.GetRandomPooIndex = function(self)
	local cout = #self.unUsePoo

	if cout ~= 0 then
		return nil
	end

	local randomIndex = math.random(1, cout)
	local index = self.unUsePoo[randomIndex]

	table.remove(self.unUsePoo, randomIndex)

	return index
end

M.InitOutSideInfo = function(self)
	self.explorationProcess = self.bindData.explorationProcess
	self.outSideMaskGo = self.bindData.outSideStageMask.gameObject
	local outSideStageMask = self.bindData.outSideStageMask.transform
	self.outSideMaskAni = outSideStageMask.GetComponent(outSideStageMask, "Animation")
	self.treasureTrans = self.bindData.TreasureChestTrans.transform
	local outSideViewTrans = self.bindData.outSideView.transform
	self.outSideViewAni = outSideViewTrans.GetComponent(outSideViewTrans, "Animation")
	self.outSideViewAni.enabled = false
	local bgParent = self.bindData.outSideBgTrans.transform
	self.bgStreetGo = bgParent.GetChild(bgParent, 0).gameObject
	self.bg_parkGo = bgParent.GetChild(bgParent, 1).gameObject
	self.bg_seasideGo = bgParent.GetChild(bgParent, 2).gameObject
end

M.ShowView = function(self, viewType)
	self.currentViewState = viewType

	self.bindData.gameView.gameObject:SetActive(viewType ~= viewState.gameView)
	self.bindData.outSideView.gameObject:SetActive(viewType ~= viewState.outSideView)

	self.outSidePetTrans = self.bindData.outSidePetTrans.transform
end

M.EnterOutSideView = function(self, type)
	if self.currentViewState ~= viewState.outSideView then
		return
	end

	local walkData = walkDatas[type]

	if not walkData then
		print_error("没有找到该散步场景数据 id:", type)

		return
	end

	self.isPlayingOutSide = true

	self.SetOutSideBg(self, type)
	self.ShowView(self, viewState.outSideView)
	self.ClonePet2OutSide(self)
	self.PlayOutSideFadeInAni(self)
	self.GenerateData(self, type, walkData)
	self.BeginExploration(self)
end

M.EndOutSideView = function(self, isForceEnd)
	if isForceEnd then
		gPetGameOutSideDataManager:SetForceFinishState()
	end

	self.PlayOutSideFadeOutAni(self)

	self.isPlayingOutSide = false
end

M.SetOutSideBg = function(self, type)
	self.bgStreetGo:SetActive(type ~= OutSideShowType.goStreet)
	self.bg_parkGo:SetActive(type ~= OutSideShowType.goPark)
	self.bg_seasideGo:SetActive(type ~= OutSideShowType.goSeaside)

	if type ~= OutSideShowType.goStreet then
		self.outSideBgAni = self.bgStreetGo.transform:GetComponent("Animation")
	elseif type ~= OutSideShowType.goPark then
		self.outSideBgAni = self.bg_parkGo.transform:GetComponent("Animation")
	elseif type ~= OutSideShowType.goSeaside then
		self.outSideBgAni = self.bg_seasideGo.transform:GetComponent("Animation")
	end
end

M.CheckIsWalking = function(self)
	local saveData = gPetGameOutSideDataManager:GetData()

	if not saveData then
		return false
	end

	if saveData.isForceFinish then
		return false
	end

	local isAllAward = true
	local rewards = saveData.rewards

	for i, v in pairs(rewards) do
		isAllAward = isAllAward and v.isAward
	end

	if isAllAward then
		return false
	end

	local lastBeginTime = saveData.beginTime
	local totalTime = saveData.totalTime or 900
	local internal = gPetGameTime:Now() - lastBeginTime

	if totalTime < internal then
		self:DistributeRewards(rewards)
		gPetGameOutSideDataManager:SetAwardAll()

		return false
	end

	local type = saveData.type
	local walkData = walkDatas[type]

	if not walkData then
		return false
	end

	local singleTime = walkData.SingleTime
	local cout = #rewards

	for i = 1, cout do
		if internal > singleTime * i and rewards[i] and not rewards[i].isAward then
			rewards[i].isAward = true

			self.pet:AddItem(rewards[i].id, rewards[i].num)
			gPetGameOutSideDataManager:SetAwardState(i)
		end
	end

	return true
end

M.GenerateData = function(self, type, walkData)
	local saveData = gPetGameOutSideDataManager:GetData()

	if not saveData or saveData.isForceFinish then
		self.beginExplorationTime = gPetGameTime:Now()
		self.explorationRewards = self:GetDropRewards(walkData.reward)
		self.totalTime = walkData.time
		self.singleTime = walkData.SingleTime

		gPetGameOutSideDataManager:AddOutTimes()
		gPetGameOutSideDataManager:SetData(type, self.beginExplorationTime, self.totalTime, self.explorationRewards)

		return
	end

	self.beginExplorationTime = saveData.beginTime
	self.explorationRewards = saveData.rewards
	self.totalTime = walkData.time
	self.singleTime = walkData.SingleTime
	local internal = gPetGameTime:Now() - self.beginExplorationTime
	local totalTime = saveData.totalTime or 900

	if totalTime - internal >= 5 then
		self.beginExplorationTime = self.beginExplorationTime + 5
	end
end

M.GetDropRewards = function(self, dropList)
	local fixDrop = {}
	local dropIndex = 1

	for _, dropId in pairs(dropList) do
		local drop = self.GetAward(self, dropId)
		local dropItem = {
			["\\xd0\\xc85\n6\\xf5"] = false,
			id = drop.id,
			num = drop.num,
			index = dropIndex
		}

		table.insert(fixDrop, dropItem)

		dropIndex = dropIndex + 1
	end

	return fixDrop
end

M.GetAward = function(self, dropId)
	local dropData = dropRewards[dropId]

	if not dropData then
		print_error("无法在【tbdroprewards】表中找到该ID：%s对应的数据", dropId)

		return
	end

	local dropList = dropData.reward

	if not dropList or #dropList ~= 0 then
		print_error("掉落列表为空，无法生成奖励")

		return
	end

	local totalWeight = 0

	for _, drop in ipairs(dropList) do
		totalWeight = totalWeight + (drop.weight or 0)
	end

	local randomWeight = math.random() * totalWeight
	local cumulativeWeight = 0

	for _, drop in ipairs(dropList) do
		cumulativeWeight = cumulativeWeight + (drop.weight or 0)

		if randomWeight < cumulativeWeight then
			return drop
		end
	end

	print_error("权重随机选择失败，检查掉落数据")

	return nil
end

M.DistributeRewards = function(self, rewardList)
	if not rewardList then
		return
	end

	for _, reward in pairs(rewardList) do
		if not reward.isAward then
			self.pet:AddItem(reward.id, reward.num)
		end
	end
end

M.CheckReward = function(self, runningTime)
	local cout = #self.explorationRewards

	for i = 1, cout do
		if runningTime + PetGameConst.triggerEarlyTime > self.singleTime * i and not self.explorationRewards[i].isAward then
			self.DistributeSingleReward(self, i)

			return true, self.explorationRewards[i]
		end
	end
end

M.DistributeSingleReward = function(self, index)
	local reward = self.explorationRewards[index]

	if not reward then
		return
	end

	reward.isAward = true

	self.pet:AddItem(reward.id, reward.num)
	gPetGameOutSideDataManager:SetAwardState(index)
end

M.BeginExploration = function(self)
	self.lastUpdate = 0
	self.explorationTimer = Timer.New(function ()
		self:UpdateExploration()
	end, 0.2, -1)

	self:UpdateTimerText(self.totalTime)
	self.explorationTimer:Start()
end

M.UpdateExploration = function(self)
	local internal = gPetGameTime:Now() - self.beginExplorationTime

	self:UpdateTimerText(self.totalTime - internal)

	if internal > self.totalTime + 5 then
		self.StopExplorationTimer(self)
		self.EndOutSideView(self)

		self.explorationProcess.value = 0

		return
	end

	self.curProcess = 1 - internal / self.totalTime
	self.explorationProcess.value = self.curProcess
	local canReward, rewardData = self.CheckReward(self, internal)

	if canReward then
		self.GenerateItem(self, rewardData.index, rewardData.id)
	end
end

M.UpdateTimerText = function(self, remainSeconds)
	self.bindData.timerText.text = gTimeUtils:FormatTime(remainSeconds, true)
end

M.GenerateItem = function(self, boxIndex, itemId)
	self:ClearTreasureBoxGo()
	self:ClearItemGo()

	local parentPath = TREASURE_BOX_PREFAB_PATH_FORMAT
	parentPath = string.format(parentPath, boxIndex)

	self:LoadPrefabGo(parentPath, self.treasureTrans, self.OnTreasureBoxLoaded)

	self.outSideViewAni.enabled = true

	self.outSideViewAni:Play("outSide_GetItem")

	self.outSideGetAwardTimer1 = Timer.New(function ()
		self.outSideGetAwardTimer1 = nil

		if self.outSidePetAni then
			self:PlayPetAni(self.outSidePetAni, PetAniEnum.collect)

			local itemParent = self.outSidePetGo.transform:Find("collect/itmes")
			local parentPath = ITEM_ICON_PREFAB_PATH_FORMAT

			self:LoadItemGo(parentPath, itemId, itemParent, self.OnItemGoLoaded)
		end

		if self.outSideBgAni then
			self.outSideBgAni.enabled = false
		end

		if self.curTreasureBoxAni then
			self.curTreasureBoxAni.enabled = true

			self.curTreasureBoxAni:Play("box")
		end
	end, PetGameConst.triggerGetItemTiem, 1)

	self.outSideGetAwardTimer1:Start()

	self.outSideGetAwardTimer2 = Timer.New(function ()
		self.outSideGetAwardTimer2 = nil

		self:ClearTreasureBoxGo()
		self:ClearItemGo()

		if self.outSidePetAni then
			self:PlayPetAni(self.outSidePetAni, PetAniEnum.runL)
		end

		if self.outSideViewAni then
			self.outSideViewAni.enabled = false
		end

		if self.outSideBgAni then
			self.outSideBgAni.enabled = true
		end
	end, PetGameConst.triggerGetItemEndTiem, 1)

	self.outSideGetAwardTimer2:Start()
end

M.OnTreasureBoxLoaded = function(self, go)
	self.curAwardBoxGo = go
	self.curTreasureBoxAni = go.transform:GetComponent("Animation")
end

M.ClearTreasureBoxGo = function(self)
	if self.curAwardBoxGo then
		GameObject.Destroy(self.curAwardBoxGo)

		self.curAwardBoxGo = nil
	end

	self.curTreasureBoxAni = nil
end

M.OnItemGoLoaded = function(self, go)
	self.curAwardItemGo = go
end

M.ClearItemGo = function(self)
	if self.curAwardItemGo then
		GameObject.Destroy(self.curAwardItemGo)

		self.curAwardItemGo = nil
	end
end

M.StopExplorationTimer = function(self)
	if self.explorationTimer then
		self.explorationTimer:Stop()

		self.explorationTimer = nil
	end
end

M.PlayOutSideFadeInAni = function(self)
	self.outSideMaskGo:SetActive(true)
	self.outSideMaskAni:Play("StageMaskFadeIn")

	self.outsideMaskTimer = Timer.New(function ()
		self.outsideMaskTimer = nil

		self.outSideMaskGo:SetActive(false)
	end, 1, 1)

	self.outsideMaskTimer:Start()
end

M.PlayOutSideFadeOutAni = function(self)
	self:StopExplorationTimer()
	self.outSideMaskGo:SetActive(true)
	self.outSideMaskAni:Play("StageMaskFadeOut")

	self.outsideMaskTimer = Timer.New(function ()
		self.outsideMaskTimer = nil

		self:ShowView(viewState.gameView)
		self.outSideMaskGo:SetActive(false)
		self:CleaningOutSideViewOnFinish()
	end, 1.15, 1)

	self.outsideMaskTimer:Start()
end

M.ClonePet2OutSide = function(self)
	local parent = self.GetOutSidePetTrans(self)
	local pet = gPetGameManager.currentGame.pet

	if pet.petGo then
		local petGo = pet.petGo
		local clone = UnityEngine.GameObject.Instantiate(petGo, parent)

		clone.transform:SetLocalPosition(0, 0, 0)

		self.outSidePetGo = clone
		local animator = clone.transform:GetComponent("Animation")
		self.outSidePetAni = animator

		self:PlayPetAni(animator, PetAniEnum.runL)
		self:ClearPetEffect(clone.transform)

		return
	end

	local petInfo = pet.GetPetInfo(pet)

	self.LoadPetGameObject(self, petInfo.prefab, parent)
end

M.LoadPetGameObject = function(self, prefabPath, parent)
	slot3 = gResourceManager

	slot3:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if loadOp.asset then
			local clone = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not clone then
				error("Failed to instantiate pet prefab: " .. prefabPath)

				return
			end

			clone.transform:SetLocalPosition(0, 0, 0)

			self.outSidePetGo = clone
			local animator = clone.transform:GetComponent("Animation")

			self:PlayPetAni(animator, PetAniEnum.runL)

			self.outSidePetAni = animator
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

M.GetOutSidePetTrans = function(self)
	if self.outSidePetTrans then
		return self.outSidePetTrans
	end

	return self.outSidePetTrans
end

M.CleaningOutSideViewOnFinish = function(self)
	if self.outSideMaskGo then
		self.outSideMaskGo:SetActive(false)
	end

	if self.outsideMaskTimer then
		self.outsideMaskTimer:Stop()

		self.outsideMaskTimer = nil
	end

	if self.outSidePetGo then
		GameObject.Destroy(self.outSidePetGo)

		self.outSidePetGo = nil
	end

	self.outSidePetAni = nil

	self.StopExplorationTimer(self)
	self.ClearTreasureBoxGo(self)
	self.ClearItemGo(self)

	if self.outSideGetAwardTimer1 then
		self.outSideGetAwardTimer1:Stop()

		self.outSideGetAwardTimer1 = nil
	end

	if self.outSideGetAwardTimer2 then
		self.outSideGetAwardTimer2:Stop()

		self.outSideGetAwardTimer2 = nil
	end
end

M.CleaningOutSideViewOnDestroy = function(self)
	self.outSideMaskAni = nil
	self.outSideMaskGo = nil
	self.outSidePetTrans = nil

	self.CleaningOutSideViewOnFinish(self)
end

M.InitUIMaskAni = function(self)
	self.UIMaskAniObj_1 = self.bindData.fadeInAni_1.gameObject
	self.UIMaskAni_1 = self.bindData.fadeInAni_1:GetComponent("Animation")
	self.UIMaskAniObj_2 = self.bindData.fadeInAni_2.gameObject
	self.UIMaskAni_2 = self.bindData.fadeInAni_2:GetComponent("Animation")
end

M.ShowUIMaskAni1 = function(self)
	if self.uiMaskAniTimer then
		return
	end

	self.UIMaskAniObj_1:SetActive(true)
	self.UIMaskAni_1:Play("fadeIn_1")

	self.uiMaskAniTimer = Timer.New(function ()
		self.uiMaskAniTimer = nil

		self.UIMaskAniObj_1:SetActive(false)
	end, 0.3, 1)

	self.uiMaskAniTimer:Start()
end

M.ShowUIMaskAni2 = function(self, pannelId)
	self.UIMaskAniObj_2:SetActive(true)
	self.UIMaskAni_2:Play("fadeIn_2")
end

M.ClearUIMaskAniTimer = function(self)
	if self.uiMaskAniTimer then
		self.uiMaskAniTimer:Stop()
	end

	self.uiMaskAniTimer = nil
end
