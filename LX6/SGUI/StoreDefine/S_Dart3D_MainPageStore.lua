-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_MainPageStore.lua
-- Decompiled from: 01389_S_Dart3D_MainPageStore.lua_ab7441c9ff48.luajit

local PanelMgrCsharp = LX6.Manager.PanelManager
C_S_Dart3D_MainPageStore = DefClass("C_S_Dart3D_MainPageStore", C_S_Dart3D_MainPageStore, C_StoreGroup)
GroupName2Class.S_Dart3D_MainPageStore = C_S_Dart3D_MainPageStore
local M = C_S_Dart3D_MainPageStore

M.ctor = function(self)
	self.TypeIdMap = {
		[gPanelId.S_Dart3D_ChoiceStorePanel] = gDart3DMainPageType.Choice,
		[gPanelId.S_Dart3D_ModeStorePanel] = gDart3DMainPageType.Mode,
		[gPanelId.S_Dart3D_OpponentStorePanel] = gDart3DMainPageType.Opponent,
		[gPanelId.S_Dart3D_InfoStorePanel] = gDart3DMainPageType.Info,
		[gPanelId.S_Dart3D_RollStorePanel] = gDart3DMainPageType.Roll,
		[gPanelId.S_Dart3D_GameTypePanel] = gDart3DMainPageType.GameType,
		[gPanelId.S_Dart3D_GameStartPanel] = gDart3DMainPageType.GameStart
	}
	self.IdTypeMap = {
		[gDart3DMainPageType.Choice] = gPanelId.S_Dart3D_ChoiceStorePanel,
		[gDart3DMainPageType.Mode] = gPanelId.S_Dart3D_ModeStorePanel,
		[gDart3DMainPageType.Opponent] = gPanelId.S_Dart3D_OpponentStorePanel,
		[gDart3DMainPageType.Info] = gPanelId.S_Dart3D_InfoStorePanel,
		[gDart3DMainPageType.Roll] = gPanelId.S_Dart3D_RollStorePanel,
		[gDart3DMainPageType.GameType] = gPanelId.S_Dart3D_GameTypePanel,
		[gDart3DMainPageType.GameStart] = gPanelId.S_Dart3D_GameStartPanel
	}
end

M.OnAwake = function(self)
	self.bindData.btnClose.luaClick = self.CreateAction(self, "OnBtnExitClick")
	self.bindData.rootTabRect.OnGenerateTab = self.CreateAction(self, "OnTabGenerate")
	self.bindData.rootTabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.changePlayerHandler = self.CreateAction(self, "DoDartSceneNodeLoaded")
	self.msgEvents = {
		[gEventConstants.DO_DART_SCENE_NODE_LOADED] = self.changePlayerHandler
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
	self.bindData.TipsVisible = 1
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.DoDartSceneNodeLoaded = function(self)
	if not gDartsGameManager.currentDartsGame then
		return
	end

	local transform = gDartsGameManager.currentDartsGame:GetScreenUITransform()

	if not transform then
		return
	end

	PanelMgrCsharp.Instance:ApplyWorldParam(gPanelId.S_DART_HARD_LEVEL_SELECT, transform.position, transform.rotation.eulerAngles, 0.889, 0.5)
end

M.OnShow = function(self, panelId, data)
	self.playType = 2

	if data then
		if data.gameplayType then
			self.playType = self.TypeIdMap[data.gameplayType] or 2
		end

		if data.playType then
			self.playType = data.playType
		end
	end

	self.showData = data.params

	if data then
		self.slotEntity = data[3]
	end

	self.backBtnCb = data and data.backCallback

	self.bindData.btnClose.gameObject:SetActive(not gTaskUtils:CheckIsInCultivation())

	if data.isSkip and not gLinkManager:CheckInLinkMode() then
		if not gDartsGameManager.currentDartsGame or gDartsGameManager.currentDartsGame.isDestroy then
			return
		end

		slot3 = gCoroutineManager

		slot3:StartCoroutine(function ()
			while not gDartsGameManager.currentDartsGame.isLoadFinish do
				coroutine.yield(nil)
			end

			if self.curTypeStore then
				self.curTypeStore:OnClose()
			end

			if not data.zoneInfo then
				if data.aiConfigId then
					gDartsGameManager.currentDartsGame:SetAiConfig(data.aiConfigId)
					gDartsGameManager.currentDartsGame:DoConfirmAISetting()
				end

				gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(data.gameMode, data.x01Score)
			end
		end)
	else
		if self.curTypeStore and self.bindData.rootTabRect.selectedIndex and self.bindData.rootTabRect.selectedIndex == self.playType then
			self.curTypeStore:OnClose()
		end

		coroutine.start(function ()
			coroutine.wait(0.5)

			if not gDartsGameManager.currentDartsGame or gDartsGameManager.currentDartsGame.isDestroy then
				return
			end

			if self.playType ~= gDart3DMainPageType.Choice and data.aiConfigId then
				gDartsGameManager:SetAiConfig(data.aiConfigId)
			end

			self.bindData.rootTabRect.selectedIndex = self.playType
			self.bindData.TipsVisible = (self.playType ~= gDart3DMainPageType.GameStart or self.playType ~= gDart3DMainPageType.GameType) and 1 or 0
			self.firstShow = true
			local opened = gLuaUIMgr.OpenedPanelTable[tostring(gPanelId.S_DART_HARD_LEVEL_SELECT)]

			if not opened then
				gLuaUIMgr.OpenedPanelTable[tostring(gPanelId.S_DART_HARD_LEVEL_SELECT)] = true

				gUIUtils:SaveLuaTableToJson(gLuaUIMgr.LOCAL_OPENED_PANEL_PATH, gLuaUIMgr.OpenedPanelTable)

				local prePanel = self.IdTypeMap[self.playType] or gPanelId.S_Dart3D_OpponentStorePanel

				self:ShowTabByPanelId(gPanelId.S_Dart3D_InfoStorePanel, prePanel)
			end
		end)
	end

	if gDartsGameManager.currentDartsGame and gDartsGameManager.currentDartsGame.isLoadFinish then
		self.DoDartSceneNodeLoaded(self)
	end

	self.bindData.rootTabRect.selectedIndex = -1
end

M.OnClose = function(self)
	self.showData = nil

	if self.curTypeStore then
		self.curTypeStore:OnClose()

		self.curTypeStore = nil
	end

	self.backBtnCb = nil
	self.switchViewBtnCb = nil
	self.firstShow = false
	self.playType = -1
end

M.OnTabGenerate = function(self)
	if self.firstShow then
		self.firstShow = false
	end
end

M.OnRenderTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end

	if index ~= gDart3DMainPageType.Roll then
		self.bindData.btnClose.gameObject:SetActive(false)
	else
		self.bindData.btnClose.gameObject:SetActive(true)
	end
end

M.ShowTabByPanelId = function(self, panelId, prePanel)
	self.playType = self.TypeIdMap[panelId] or 0
	self.bindData.rootTabRect.selectedIndex = self.playType
	self.bindData.TipsVisible = (self.playType ~= gDart3DMainPageType.GameStart or self.playType ~= gDart3DMainPageType.GameType) and 1 or 0
	self.prePanel = prePanel
end

M.BackPre = function(self)
	self.playType = self.TypeIdMap[self.prePanel] or 0
	self.bindData.rootTabRect.selectedIndex = self.playType
	self.bindData.TipsVisible = (self.playType ~= gDart3DMainPageType.GameStart or self.playType ~= gDart3DMainPageType.GameType) and 1 or 0
	self.prePanel = nil
end

M.OnBtnExitClick = function(self)
	if gTaskUtils:CheckIsInCultivation() then
		return
	end

	if gDartsGameManager._isSkip then
		gSpoonClientMgr:ReleaseContextEvent(gDartsGameManager._dart_gadgetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnDartInterrupt, {
			npcId = gDartsGameManager._dartNpcCfg.Id,
			gadgetId = gDartsGameManager._dart_gadgetId
		})
	end

	if gLinkManager:CheckInLinkMode() then
		local gadgetId = gDartsGameManager._dart_gadgetId
		slot2 = gDartsGameManager

		slot2:SendDartRpc("LeaveDart", function ()
			return gClientToGameSceneDelegate:LeaveDart(gadgetId)
		end, nil, function (err)
			gDartsGameManager:DestroyGame()
		end)

		return
	end

	gDartsGameManager:DestroyGame()
end
