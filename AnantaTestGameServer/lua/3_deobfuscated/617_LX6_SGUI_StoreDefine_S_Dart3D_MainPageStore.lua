local PanelMgrCsharp = LX6.Manager.PanelManager
C_S_Dart3D_MainPageStore = DefClass("C_S_Dart3D_MainPageStore", C_S_Dart3D_MainPageStore, C_StoreGroup)
GroupName2Class.S_Dart3D_MainPageStore = C_S_Dart3D_MainPageStore
local M = C_S_Dart3D_MainPageStore

function M:ctor()
	self.TypeIdMap = {
		[gPanelId.S_Dart3D_ChoiceStorePanel] = gDart3DMainPageType.Choice,
		[gPanelId.S_Dart3D_ModeStorePanel] = gDart3DMainPageType.Mode,
		[gPanelId.S_Dart3D_OpponentStorePanel] = gDart3DMainPageType.Opponent,
		[gPanelId.S_Dart3D_InfoStorePanel] = gDart3DMainPageType.Info,
		[gPanelId.S_Dart3D_GameTypePanel] = gDart3DMainPageType.GameType,
		[gPanelId.S_Dart3D_GameStartPanel] = gDart3DMainPageType.GameStart
	}
	self.IdTypeMap = {
		[gDart3DMainPageType.Choice] = gPanelId.S_Dart3D_ChoiceStorePanel,
		[gDart3DMainPageType.Mode] = gPanelId.S_Dart3D_ModeStorePanel,
		[gDart3DMainPageType.Opponent] = gPanelId.S_Dart3D_OpponentStorePanel,
		[gDart3DMainPageType.Info] = gPanelId.S_Dart3D_InfoStorePanel,
		[gDart3DMainPageType.GameType] = gPanelId.S_Dart3D_GameTypePanel,
		[gDart3DMainPageType.GameStart] = gPanelId.S_Dart3D_GameStartPanel
	}
end

function M:OnAwake()
	self.bindData.btnClose.luaClick = self:CreateAction("OnBtnExitClick")
	self.bindData.rootTabRect.OnGenerateTab = self:CreateAction("OnTabGenerate")
	self.bindData.rootTabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.changePlayerHandler = self:CreateAction("DoDartSceneNodeLoaded")
	self.msgEvents = {
		[gEventConstants.DO_DART_SCENE_NODE_LOADED] = self.changePlayerHandler
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnEnable()
	self.bindData.TipsVisible = 1
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:DoDartSceneNodeLoaded()
	local transform = gDartsGameManager.currentDartsGame:GetScreenUITransform()

	PanelMgrCsharp.Instance:ApplyWorldParam(gPanelId.S_DART_HARD_LEVEL_SELECT, transform.position, transform.rotation.eulerAngles, 0.889, 0.5)
end

function M:OnShow(panelId, data)
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

	local position, rotation = nil

	if self.slotEntity ~= nil and self.slotEntity.gameObject ~= nil then
		local slotGo = self.slotEntity.gameObject
		position = {
			slotGo.transform.position.x,
			slotGo.transform.position.y,
			slotGo.transform.position.z
		}
		rotation = {
			self.slotEntity.gameObject.transform.rotation.x,
			self.slotEntity.gameObject.transform.rotation.y,
			self.slotEntity.gameObject.transform.rotation.z,
			self.slotEntity.gameObject.transform.rotation.w
		}
	else
		local me = gCS.MyPlayerManager.PlayerUnit
		position = {
			me.LocalPosition.x,
			me.LocalPosition.y,
			me.LocalPosition.z
		}
		rotation = {
			0,
			0,
			0,
			1
		}
	end

	if gDartsGameManager.currentDartsGame == nil then
		gDartsGameManager:CreateGame({
			wayPointPosition = position,
			wayPointRotation = rotation,
			slotEntity = self.slotEntity,
			onInitFinish = data.onInitFinish,
			useSuit = data.useSuit
		})
	end

	if data.onEndTlFinishHandler then
		gDartsGameManager.currentDartsGame.onEndTlFinishHandler = data.onEndTlFinishHandler
	end

	self.backBtnCb = data and data.backCallback

	if data.isSkip then
		if not gDartsGameManager.currentDartsGame or gDartsGameManager.currentDartsGame.isDestroy then
			return
		end

		gCoroutineManager:StartCoroutine(function ()
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
		if self.curTypeStore and self.bindData.rootTabRect.selectedIndex and self.bindData.rootTabRect.selectedIndex ~= self.playType then
			self.curTypeStore:OnClose()
		end

		coroutine.start(function ()
			coroutine.wait(0.5)

			if not gDartsGameManager.currentDartsGame or gDartsGameManager.currentDartsGame.isDestroy then
				return
			end

			if self.playType == gDart3DMainPageType.Choice and data.aiConfigId then
				gDartsGameManager:SetAiConfig(data.aiConfigId)
			end

			self.bindData.rootTabRect.selectedIndex = self.playType
			self.bindData.TipsVisible = (self.playType == gDart3DMainPageType.GameStart or self.playType == gDart3DMainPageType.GameType) and 1 or 0
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

	self.bindData.rootTabRect.selectedIndex = -1
end

function M:OnClose()
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

function M:OnTabGenerate()
	if self.firstShow then
		self.firstShow = false
	end
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end
end

function M:ShowTabByPanelId(panelId, prePanel)
	self.playType = self.TypeIdMap[panelId] or 0
	self.bindData.rootTabRect.selectedIndex = self.playType
	self.bindData.TipsVisible = (self.playType == gDart3DMainPageType.GameStart or self.playType == gDart3DMainPageType.GameType) and 1 or 0
	self.prePanel = prePanel
end

function M:BackPre()
	self.playType = self.TypeIdMap[self.prePanel] or 0
	self.bindData.rootTabRect.selectedIndex = self.playType
	self.bindData.TipsVisible = (self.playType == gDart3DMainPageType.GameStart or self.playType == gDart3DMainPageType.GameType) and 1 or 0
	self.prePanel = nil
end

function M:OnBtnExitClick()
	gDartsGameManager:DestroyGame()
end
