-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuziqiLevelSelectPanelStore.lua
-- Decompiled from: 01241_WuziqiLevelSelectPanelStore.lua_812db2485f0c.luajit

C_WuziqiLevelSelectPanelStore = DefClass("C_WuziqiLevelSelectPanelStore", C_WuziqiLevelSelectPanelStore, C_StoreGroup)
GroupName2Class.WuziqiLevelSelectPanelStore = C_WuziqiLevelSelectPanelStore
local M = C_WuziqiLevelSelectPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.endGameIds = {}
	self.difficultyIndex = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
end

M.OnGroupDisable = function(self)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
end

M.OnShow = function(self, panelId, data)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.WUZIQI_LEVEL_SELECT_PANEL, true)

	gClientToGameSceneDelegate:QueryGomokuPlayerInfo().Callback = function (errId, playerInfo)
		if errId == 0 then
			print_error("QueryGomokuPlayerInfo Failed Error = ", gCS.Error.GetNameById(errId))
		end

		if playerInfo then
			self.playerInfo = playerInfo
		end

		for i = 0, LTConfig.PoiGameGomokuEndgameConfig.count - 1 do
			local cfg = LTConfig.PoiGameGomokuEndgameConfig.LoadAt(i)

			if cfg then
				if not self.endGameIds[cfg.DifficultyLevel] then
					self.endGameIds[cfg.DifficultyLevel] = {}
				end

				table.insert(self.endGameIds[cfg.DifficultyLevel], cfg.Id)
			end
		end

		local savedDifficulty = L50.L50App.Scene.GomokuManager.LastDifficultyIndex
		local restoreDifficulty = savedDifficulty and savedDifficulty > 0 and savedDifficulty or 0
		local savedEndGameId = L50.L50App.Scene.GomokuManager.LastEndGameId
		local restoreEndGameId = savedEndGameId and savedEndGameId <= 0 and savedEndGameId or nil
		self.isRestoring = true

		self:RefreshTab(restoreDifficulty)

		local restoreListIndex = 0

		if restoreEndGameId and self.endGameIds[restoreDifficulty] then
			for i, id in ipairs(self.endGameIds[restoreDifficulty]) do
				if id ~= restoreEndGameId then
					restoreListIndex = i - 1

					break
				end
			end
		end

		self.difficultyIndex = restoreDifficulty

		self.bindData.endGameList:SetSimpleList(#self.endGameIds[restoreDifficulty])
		self.bindData.endGameList:SetItemSelected(restoreListIndex, true)

		self.endGameId = self.endGameIds[restoreDifficulty][restoreListIndex + 1] or self.endGameIds[restoreDifficulty][1]
	end

	self.bindData.endGameList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderEndGameListItem)
	self.bindData.endGameList.luaSimpleClick = self:CreateAction(self.OnSimpleClickEndGameList)
end

M.OnClose = function(self)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.WUZIQI_LEVEL_SELECT_PANEL, false)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickStartBtn = function(self)
	if not self.endGameId then
		return
	end

	L50.L50App.Scene.GomokuManager:StartGomoke(1, true, self.difficultyIndex, self.endGameId)
	gUIUtils:PlayAniClosePanel(self.bindData.closeAnimation, "S_Vx_WuziqiLevelSelectPanel_close", self.m_Id)
end

M.OnClickBackBtn = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.closeAnimation, "S_Vx_WuziqiLevelSelectPanel_close", self.m_Id)
end

M.OnClickKeyLeftBtn = function(self)
	local tabStore = self.SubGroup.CommonTabSingleStore
	local newIndex = self.difficultyIndex - 1

	if newIndex >= 0 then
		return
	end

	tabStore.SetSelectedIndex(tabStore, newIndex, true, false)
end

M.OnClickKeyRightBtn = function(self)
	local tabStore = self.SubGroup.CommonTabSingleStore
	local maxIndex = table.count(self.endGameIds) - 1
	local newIndex = self.difficultyIndex + 1

	if maxIndex >= newIndex then
		return
	end

	tabStore.SetSelectedIndex(tabStore, newIndex, true, false)
end

M.OnSimpleRenderEndGameListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not self.endGameIds then
		return
	end

	local id = self.endGameIds[self.difficultyIndex][index + 1]

	if not id then
		return
	end

	local cfg = LTConfig.PoiGameGomokuEndgameConfig.GetConfig(id)

	if not cfg then
		return
	end

	store.step = math.ceil(cfg.StepCount / 2)
	store.indexNum = string.format("%02d", index + 1)
	local rewardItems = {}
	local dropList = {}
	local worldLifeConfig = LTConfig.WorldLifeConfig.GetConfig(cfg.WorldLifeId)

	if worldLifeConfig then
		local dropConfig = LTConfig.DropConfig.GetConfig(worldLifeConfig.Drop)

		if dropConfig then
			table.insert(dropList, {
				dropId = worldLifeConfig.Drop
			})
		end
	end

	local itemSortedList = gCommonItemManager:GetItemSortedListByDropList(dropList, true) or {}

	for i = 1, #itemSortedList do
		local item = itemSortedList[i]
		local showData = gCommonItemManager:GetItemRenderData({
			itemId = item.Id,
			itemNum = item.Count
		})

		if self.playerInfo and self.playerInfo.DroppedEndGameIdSet[id] then
			store.complete = 1
			showData.IsOwned = true
			showData.isFirstKill = false
		else
			showData.isFirstKill = false
			store.complete = 0
			showData.IsOwned = false
		end

		table.insert(rewardItems, showData)
	end

	store.rewardList:SetSimpleList(#rewardItems)

	store.rewardList.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
		local data = rewardItems[rewardIndex + 1]

		if not data then
			return
		end

		gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, data)
	end

	store.rewardList.luaSimpleClick = self:CreateAction(self.OnSimpleClickRewardList)

	store.rewardList:RefreshList()
end

M.OnSimpleClickEndGameList = function(self, btn, index)
	self.endGameId = self.endGameIds[self.difficultyIndex][index + 1]
	L50.L50App.Scene.GomokuManager.LastEndGameId = self.endGameId
end

M.OnSimpleClickRewardList = function(self, btn, index)
end

M.RefreshTab = function(self, defaultIndex)
	local tabStore = self.SubGroup.CommonTabSingleStore
	local optionConfig = LTConfig.GameplayHudDescBeginOptionConfig.GetConfig(LTConfig.GameplayHudDescBeginOptionConfig.SelectDifficulty)

	if not optionConfig then
		tabStore.SetSimpleData(tabStore, 0, nil, 0, nil)

		return
	end

	local tabList = {}

	for i = 1, #optionConfig.Options do
		tabList[i] = {
			id = i - 1,
			title = optionConfig.Options[i]
		}
	end

	local initIndex = defaultIndex or 0

	tabStore:SetData(tabList, nil, initIndex, nil, self:CreateAction(self.OnTabChanged))
end

M.OnTabChanged = function(self, uList)
	local tabIndex = uList.selectedIndex
	self.difficultyIndex = tabIndex

	if self.isRestoring then
		self.isRestoring = false

		return
	end

	L50.L50App.Scene.GomokuManager.LastDifficultyIndex = tabIndex
	local count = self.endGameIds[self.difficultyIndex] and #self.endGameIds[self.difficultyIndex] or 0

	self.bindData.endGameList:SetSimpleList(count)
	self.bindData.endGameList:SetItemSelected(0, true)

	self.endGameId = self.endGameIds[self.difficultyIndex] and self.endGameIds[self.difficultyIndex][1]
	L50.L50App.Scene.GomokuManager.LastEndGameId = self.endGameId
end
