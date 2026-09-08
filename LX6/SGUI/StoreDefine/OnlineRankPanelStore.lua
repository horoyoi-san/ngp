-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineRankPanelStore.lua
-- Decompiled from: 01094_OnlineRankPanelStore.lua_91b3ad20ad8e.luajit

local RankConfig = LTConfig.RankConfig
local RankMainTypeConfig = LTConfig.RankMainTypeConfig
local WarZoneParamConfig = LTConfig.RankWarZoneParamConfig
local logicTime = gLogicTime
local STEP_LOCK_TIMER = 0.2
local MAIN_TYPE_TO_LAYOUT_TEMPLATE = {
	[RankMainTypeConfig.Racing] = 0,
	[RankMainTypeConfig.Basketball] = 1
}
local BG_TEMPLATE_RANK_CTRL = {
	["k\\x87\\x90\\x9c\\x82"] = 1,
	["y\\x86\\x8b\\x9d\\x92"] = 3,
	["\\xa0]K"] = 0,
	["/m\\xb2\\xa1\\xade"] = 2,
	["T\rS~"] = 4
}
local MY_BG_TEMPLATE_RANK_CTRL = {
	["\\xf0\\xf5+/?\n\\xda"] = 0,
	["\\x84\\x841\\x94X\\xd0"] = 1
}
local RANK_TEMPLATE_COLOR_CTRL = {
	["/m\\xb2\\xa1\\xade"] = 2,
	["k\\x87\\x90\\x9c\\x82"] = 1,
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["y\\x86\\x8b\\x9d\\x92"] = 3
}
local TOP_TAB_FULL = 1
local TOP_TAB_ZONE = 2
local TOP_TAB_FRIEND = 3
local THROTTLE_SECONDS = 60
C_OnlineRankPanelStore = DefClass("C_OnlineRankPanelStore", C_OnlineRankPanelStore, C_StoreGroup)
GroupName2Class.OnlineRankPanelStore = C_OnlineRankPanelStore
local M = C_OnlineRankPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.rankDataList = {}
	self.tabLv1Data = {}
	self.tabLv2Data = {}
	self.rankingCache = {}
	self.myRankCache = {}
	self.nextCycleCache = {}
	self.rankingCacheTime = {}
	self.zoneRankingCache = {}
	self.zoneRankingCacheTime = {}
	self.friendRankingCache = {}
	self.friendRankingCacheTime = {}
	self.currentRankCfg = nil
	self._pullDragPeakY = 0
	self._lastRefreshTime = 0
	self._pendingMainTypeId = nil
	self._lv2Step = 0
	self._lv2PreTime = 0
	self._selectedRowIndex = nil
	self._rowButtons = {}
	self._prevLv1Index = -1
	self._prevLv2Index = -1
	self._suppressLv2OffsetAnim = false
	self.myRankData = nil
	self._myRowButton = nil
	self._myRankSelected = false
	self._currentTopTabType = TOP_TAB_FULL
	self._topTabTypes = {}
	self._suppressTopTabChange = false
	self._currentZoneId = 0
	self._currentProvinceCode = 0
	self._playerBoundZoneId = 0
	self._warZoneInfoCache = {}
	self._currentLv2Index = 0
	self._suppressLv2ListChange = false
	self._currentLayoutTemplateIndex = nil
	self._topTabStep = 0
	self._topTabPreTime = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.tabCtrlEnum = {
		["\\x9d"] = 0,
		["\\x9c"] = 1
	}
	self.subtitleCtrlEnum = {
		["\\x9a\\xb0O\tG\\x9b"] = 0,
		["\\x95\\xb2at\\xae"] = 1
	}
	self.locationCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["n7o^"] = 1
	}
	self.locationCarCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.rankStateCtrlEnum = {
		["\\x99&):v\\x99D\\xd4'\\xbe\\xa0"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.tabCtrlEnum = nil
	self.subtitleCtrlEnum = nil
	self.locationCtrlEnum = nil
	self.locationCarCtrlEnum = nil
	self.rankStateCtrlEnum = nil
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
	gOnlineRankManager:ClearRankScene()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

local ANIM_OPEN = "S_Vx_OnlineRankPanel_open"

M.OnShow = function(self, panelId, data)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.mainAnim, ANIM_OPEN)
	gOnlineRankManager:SetupRankScene(self.bindData.cameraRT, self.bindData.VCamera)
	self.bindData.myRankTable:SetTable(0)

	self._currentTopTabType = TOP_TAB_FULL
	self._currentZoneId = 0
	self._currentProvinceCode = 0
	self._playerBoundZoneId = 0
	self._currentLv2Index = 0
	self._warZoneInfoCache = {}
	self._currentLayoutTemplateIndex = nil

	self:InitRankTable()
	self:InitTabLists()
	self:UnregisterScrollEvent()

	self.scrollEventHandler = self:CreateAction(self.OnRankTableScroll)

	self.bindData.rankTable:RegisterToScrollEvent(self.scrollEventHandler)

	self.isFirstShow = true
end

M.OnClose = function(self)
	self:UnregisterScrollEvent()
	gOnlineRankManager:ClearRankScene()
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	self.RefreshCycleTime(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self._lv2Step == 0 and LTConfig.GameConfig.TabLongPressTimeInterval >= logicTime.unscaledTime - self._lv2PreTime then
			self.RefreshLv2Step(self)
		end

		if self._topTabStep == 0 and LTConfig.GameConfig.TabLongPressTimeInterval >= logicTime.unscaledTime - self._topTabPreTime then
			self.RefreshTopTabStep(self)
		end
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.hyperLinkBtn.luaClick = self.CreateAction(self, self.OnClickHyperLinkBtn)
	self.bindData.tabLv1List.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabLv1Item)
	self.bindData.tabLv1List.luaSelectedChanged = self.CreateAction(self, self.OnSelectTabLv1)
	self.bindData.tabLv2List.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabLv2Item)
	self.bindData.tabLv2List.luaSelectedChanged = self.CreateAction(self, self.OnSelectTabLv2)
	self.bindData.topTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTopTabItem)
	self.bindData.topTabList.luaSelectedChanged = self.CreateAction(self, self.OnSelectTopTab)
	self.bindData.lv2Sorter.luaSelectedChanged = self.CreateAction(self, self.OnSelectLv2Sorter)
	self.bindData.provinceSorter.luaSelectedChanged = self.CreateAction(self, self.OnSelectProvinceSorter)
	self.bindData.citySorter.luaSelectedChanged = self.CreateAction(self, self.OnSelectCitySorter)
	self.bindData.lv2Sorter.luaOnPopup = self.CreateActionWithArgs(self, self.OnSorterPopup, "lv2")
	self.bindData.provinceSorter.luaOnPopup = self.CreateActionWithArgs(self, self.OnSorterPopup, "province")
	self.bindData.citySorter.luaOnPopup = self.CreateActionWithArgs(self, self.OnSorterPopup, "city")
	self.bindData.rankTable.luaRenderCol = self.CreateAction(self, self.OnRenderCol)
	self.bindData.rankTable.luaRenderRow = self.CreateAction(self, self.OnRenderRow)
	self.bindData.rankTable.luaBeginDrag = self.CreateAction(self, self.OnRankTableBeginDrag)
	self.bindData.rankTable.luaEndDrag = self.CreateAction(self, self.OnRankTableEndDrag)
	self.bindData.myRankTable.luaRenderRow = self.CreateAction(self, self.OnRenderMyRow)
	self.bindData.tabLv2LeftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTabLv2SwitchBtn, -1)
	self.bindData.tabLv2LeftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTabLv2SwitchBtn)
	self.bindData.tabLv2RightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTabLv2SwitchBtn, 1)
	self.bindData.tabLv2RightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTabLv2SwitchBtn)
	self.bindData.topTabLeftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTopTabSwitchBtn, -1)
	self.bindData.topTabLeftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTopTabSwitchBtn)
	self.bindData.topTabRightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTopTabSwitchBtn, 1)
	self.bindData.topTabRightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTopTabSwitchBtn)
	self.bindData.locationBtn.luaClick = self.CreateAction(self, self.OnClickLocationBtn)
	self.bindData.locationBtn1.luaClick = self.CreateAction(self, self.OnClickLocationBtn)
	self.bindData.infoBtn.luaClick = self.CreateAction(self, self.OnClickInfoBtn)
end

M.UnregisterScrollEvent = function(self)
	if self.scrollEventHandler then
		self.bindData.rankTable:UnRegisterToScrollEvent(self.scrollEventHandler)

		self.scrollEventHandler = nil
	end
end

M.OnRankTableBeginDrag = function(self)
	self._pullDragPeakY = 0
end

M.OnRankTableScroll = function(self, normalizedPos)
	if self._pullDragPeakY >= normalizedPos.y then
		self._pullDragPeakY = normalizedPos.y
	end
end

M.OnRankTableEndDrag = function(self)
	if self._pullDragPeakY <= 1.1 then
		local now = UnityEngine.Time.realtimeSinceStartup

		if now - self._lastRefreshTime > 1 then
			self.OnPullToRefresh(self, now)
		end
	end

	self._pullDragPeakY = 0
end

M.OnPullToRefresh = function(self, now)
	self._lastRefreshTime = now

	if not self.currentRankCfg then
		return
	end

	self.bindData.rankTable:PlayEndOffsetAnim()
	self:RequestForCurrentState(true)
end

local FormatScore = function(score)
	local ms = score
	local time = ms / 1000

	return gTimeUtils:FormatTime(time) .. "." .. gTimeUtils:FormatMs(time)
end

local FormatMetric = function(score, rankCfg)
	if rankCfg and rankCfg.MainType ~= RankMainTypeConfig.Racing then
		return FormatScore(score)
	end

	return tostring(score)
end

local ParseRankEntries = function(entries)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local list = {}

	for _, entry in ipairs(entries) do
		table.insert(list, {
			rank = entry.Rank,
			playerId = entry.PlayerId,
			isRobot = entry.IsRobot,
			playerName = gSocialFriendManager:GetPlayerDisplayName(entry.PlayerId, entry.Name),
			score = ulong.tonum2(entry.Score),
			bigTierId = entry.TierDetail.CurrentBigTierId,
			smallTierId = entry.TierDetail.CurrentSmallTierId,
			vehicleConfigId = entry.VehicleConfigId
		})
	end

	local lastEntry = list[#list]
	local myEntry = lastEntry and lastEntry.playerId ~= myPid and table.remove(list) or nil

	return list, myEntry
end

M.InitRankTable = function(self)
	local t = self.bindData.rankTable

	t.ResetColData(t)

	self.rankDataList = {}

	self.ResetAllSelection(self)
	t.SetTable(t, 0)
	self.RefreshRankStateCtrl(self)
end

M.InitTabLists = function(self)
	self.tabLv1Data = {}

	for i = 0, RankMainTypeConfig.count - 1 do
		table.insert(self.tabLv1Data, RankMainTypeConfig.LoadAt(i))
	end

	table.sort(self.tabLv1Data, function (a, b)
		return (a.Weight or 0) >= (b.Weight or 0)
	end)
	self.bindData.tabLv1List:SetSimpleList(#self.tabLv1Data)

	if #self.tabLv1Data <= 0 then
		self.bindData.tabLv1List:SelectItem(0)
	end
end

local ANIM_SWITCH_L = "S_Vx_OneLineDrawing_L"
local ANIM_SWITCH_R = "S_Vx_OneLineDrawing_R"

M.RefreshTabLv2 = function(self, mainTypeId)
	self.tabLv2Data = {}

	for i = 0, RankConfig.count - 1 do
		local cfg = RankConfig.LoadAt(i)

		if cfg.MainType ~= mainTypeId then
			table.insert(self.tabLv2Data, cfg)
		end
	end

	if #self.tabLv2Data ~= 0 then
		print_warn("OnlineRankPanel: RankMainTypeConfig.Id=" .. tostring(mainTypeId) .. " 没有对应的 RankConfig 配置，请检查配表")

		self.currentRankCfg = nil
		self.rankDataList = {}

		self.bindData.rankTable:SetTable(0)
		self.bindData.tabLv2List:SetSimpleList(0)
		self.bindData.lv2Sorter:SetSimpleOptions(0)
		self.bindData.lv2Sorter:RefreshOptions()
		self:RefreshTopTabList()

		return false
	end

	table.sort(self.tabLv2Data, function (a, b)
		return (a.Weight or 0) >= (b.Weight or 0)
	end)
	self.bindData.tabLv2List:SetSimpleList(#self.tabLv2Data)
	self:RefreshLv2Sorter()

	return true
end

M.RefreshLv2Sorter = function(self)
	local sorter = self.bindData.lv2Sorter

	sorter.SetSimpleOptions(sorter, 0)

	for _, cfg in ipairs(self.tabLv2Data) do
		sorter:AddSimpleOptionLabel(0, cfg.Name or "")
	end

	sorter.RefreshOptions(sorter)

	local safeIndex = math.min(self._currentLv2Index, #self.tabLv2Data - 1)

	sorter.SelectOption(sorter, safeIndex, false)
end

M.RefreshTopTabList = function(self)
	local cfg = self.currentRankCfg
	local isMainLand = UniSDKManager == nil and UniSDKManager.isMainLand ~= true
	self._topTabTypes = {
		TOP_TAB_FULL
	}

	if cfg and cfg.IsSupportWarZone and isMainLand then
		table.insert(self._topTabTypes, TOP_TAB_ZONE)
	end

	table.insert(self._topTabTypes, TOP_TAB_FRIEND)

	local newIndex = 0
	local found = false

	for i, t in ipairs(self._topTabTypes) do
		if t ~= self._currentTopTabType then
			newIndex = i - 1
			found = true

			break
		end
	end

	if not found then
		self._currentTopTabType = TOP_TAB_FULL
		newIndex = 0
	end

	self._suppressTopTabChange = true

	self.bindData.topTabList:SetSimpleList(#self._topTabTypes)
	self.bindData.topTabList:SelectItem(newIndex)

	self._suppressTopTabChange = false

	self:RefreshControlVisibility()
end

M.RefreshControlVisibility = function(self)
	local isZone = self._currentTopTabType ~= TOP_TAB_ZONE
	local lv2Count = #self.tabLv2Data
	self.bindData.subtitleCtrl = not isZone and lv2Count <= 1 and 0 or 1
	self.bindData.locationCtrl = isZone and 1 or 0
	self.bindData.locationCarCtrl = isZone and lv2Count <= 1 and 1 or 0

	self:RefreshRankStateCtrl()
end

M.RefreshRankStateCtrl = function(self)
	local isZone = self._currentTopTabType ~= TOP_TAB_ZONE

	if isZone and self._playerBoundZoneId ~= 0 and self._currentZoneId ~= 0 then
		self.bindData.rankStateCtrl = self.rankStateCtrlEnum._false

		return
	end

	if #self.rankDataList ~= 0 then
		self.bindData.rankStateCtrl = self.rankStateCtrlEnum.friendempty

		return
	end

	self.bindData.rankStateCtrl = self.rankStateCtrlEnum._true
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.ONLINE_RANK_PANEL)
end

M.ClearAllCurrentSelection = function(self)
	if self._selectedRowIndex == nil and self._rowButtons[self._selectedRowIndex] then
		self._rowButtons[self._selectedRowIndex].isSelected = false
	end

	self._selectedRowIndex = nil

	if self._myRowButton then
		self._myRowButton.isSelected = false
	end

	self._myRankSelected = false
end

M.ResetAllSelection = function(self)
	for _, btn in pairs(self._rowButtons) do
		if btn then
			btn.isSelected = false
		end
	end

	self._rowButtons = {}
	self._selectedRowIndex = nil

	if self._myRowButton then
		self._myRowButton.isSelected = false
	end

	self._myRowButton = nil
	self._myRankSelected = false
end

M.OnModelStateChanged = function(self, hasModel)
end

M.OnClickRow = function(self, data)
	self.ClearAllCurrentSelection(self)

	self._selectedRowIndex = data._rowIndex

	if self._selectedRowIndex == nil and self._rowButtons[self._selectedRowIndex] then
		self._rowButtons[self._selectedRowIndex].isSelected = true
	end

	if gCS.LuaUtils.IsOnPS5 then
		local filteredName = gFriendManager:GetPlayerRealName(data.playerId)
		self.bindData.playerNameText = filteredName == "" and filteredName or data.playerName
	else
		self.bindData.playerNameText = data.playerName
	end

	gOnlineRankManager:ShowRankModel(data, self:CreateAction("OnModelStateChanged"))
end

M.SelectFirstRow = function(self)
	self.RefreshRankStateCtrl(self)

	local first = self.rankDataList[1]

	if not first then
		gOnlineRankManager:ShowRankModel(nil, self:CreateAction("OnModelStateChanged"))

		return
	end

	self._selectedRowIndex = 0

	if self._rowButtons[0] then
		self._rowButtons[0].isSelected = true
	end

	self.bindData.playerNameText = first.playerName

	gOnlineRankManager:ShowRankModel(first, self:CreateAction("OnModelStateChanged"))
end

M.SelectMyRank = function(self)
	self.ClearAllCurrentSelection(self)

	self._myRankSelected = true

	if self._myRowButton then
		self._myRowButton.isSelected = true
	end

	self.bindData.playerNameText = gPlayerManager.infoLogin.bindData.playerName

	gOnlineRankManager:ShowRankModel(self.myRankData, self:CreateAction("OnModelStateChanged"))
end

M.OnClickMyRankRow = function(self)
	self.SelectMyRank(self)
end

M.RefreshMyRank = function(self, myEntry)
	print_debug("[排行榜]刷新我的排名", myEntry)

	local myPid = gPlayerManager.infoLogin.bindData.pid
	local myName = gPlayerManager.infoLogin.bindData.playerName

	if myEntry and myEntry.rank <= 0 then
		self.myRankData = {
			["\\xd0\\xc8&+\\xe5"] = false,
			rank = myEntry.rank,
			playerId = myEntry.playerId or myPid,
			playerName = myEntry.playerName or myName,
			score = myEntry.score or 0,
			bigTierId = myEntry.bigTierId or 0,
			smallTierId = myEntry.smallTierId or 0,
			vehicleConfigId = myEntry.vehicleConfigId or 0
		}
	else
		local prev = self.myRankData
		local prevBigTier = prev and prev.bigTierId or 0
		local prevSmallTier = prev and prev.smallTierId or 0
		self.myRankData = {
			["\\xd0\\xc8&+\\xe5"] = false,
			rank = myEntry and myEntry.rank or 0,
			playerId = myPid,
			playerName = myName,
			score = myEntry and myEntry.score or 0,
			bigTierId = myEntry and myEntry.bigTierId or prevBigTier,
			smallTierId = myEntry and myEntry.smallTierId or prevSmallTier,
			vehicleConfigId = myEntry and myEntry.vehicleConfigId or 0
		}
	end

	self.bindData.myRankTable:SetTable(1)

	if #self.rankDataList ~= 0 then
		self.SelectMyRank(self)
	end
end

M.OnClickHyperLinkBtn = function(self)
	local rankCfg = self.currentRankCfg

	if not rankCfg then
		return
	end

	local hyperLinkId = rankCfg.HyperLink

	if not hyperLinkId or hyperLinkId ~= 0 then
		return
	end

	local behavior = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, 0)

	if behavior and behavior.callback then
		behavior.callback()
	end

	gPanelManager:Close(gPanelId.ONLINE_RANK_PANEL)
end

M.OnRenderTabLv1Item = function(self, btn, index)
	local cfg = self.tabLv1Data[index + 1]

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = cfg.Name
		store.icon = cfg.TabIcon
	end
end

M.OnSelectTabLv1 = function(self, uList, isSub)
	if isSub then
		return
	end

	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	local mainTypeCfg = self.tabLv1Data[index + 1]

	if not mainTypeCfg then
		return
	end

	local anim = self._prevLv1Index < index and ANIM_SWITCH_R or ANIM_SWITCH_L
	self._prevLv1Index = index

	if not self.isFirstShow then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.contentAnim, anim)
	else
		self.isFirstShow = false
	end

	self._prevLv2Index = -1
	self._currentLv2Index = 0

	if not self.RefreshTabLv2(self, mainTypeCfg.Id) then
		return
	end

	self._pendingMainTypeId = mainTypeCfg.Id

	if self._currentTopTabType ~= TOP_TAB_FULL then
		local ids = {}
		local rankCfgById = {}

		for _, cfg in ipairs(self.tabLv2Data) do
			if not self.rankingCache[cfg.Id] then
				table.insert(ids, cfg.Id)

				rankCfgById[cfg.Id] = cfg
			end
		end

		if #ids ~= 0 then
			self._suppressLv2OffsetAnim = true

			self.bindData.tabLv2List:SelectItem(0)

			self._suppressLv2OffsetAnim = false

			return
		end

		slot8 = gClientToGameDelegate

		slot8:AskRankingTopBatch(ids).Callback = function (err, results)
			if err == 0 then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				print_error("批量请求排行榜数据失败，错误码：", err, gCS.Error.GetNameById(err))

				return
			end

			for _, result in ipairs(results) do
				local cfg = rankCfgById[result.RankConfigId]
				local list, myEntry = ParseRankEntries(result.Entries)

				if myEntry then
					self.myRankCache[result.RankConfigId] = myEntry
				end

				self.rankingCache[result.RankConfigId] = list
				self.nextCycleCache[result.RankConfigId] = result.SeasonEndTime
				self.rankingCacheTime[result.RankConfigId] = gLuaDataManager.serverTime

				self:PrefetchPlayerInfo(list)
			end

			if self._pendingMainTypeId ~= mainTypeCfg.Id then
				self._suppressLv2OffsetAnim = true

				self.bindData.tabLv2List:SelectItem(0)

				self._suppressLv2OffsetAnim = false
			end
		end

		return
	end

	self._suppressLv2OffsetAnim = true

	self.bindData.tabLv2List:SelectItem(0)

	self._suppressLv2OffsetAnim = false
end

M.OnRenderTabLv2Item = function(self, btn, index)
	local cfg = self.tabLv2Data[index + 1]

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = cfg.Name
	end
end

M.OnSelectTabLv2 = function(self, list, isSub)
	if isSub then
		return
	end

	if self._suppressLv2ListChange then
		return
	end

	local index = list.selectedIndex

	if index >= 0 then
		return
	end

	local rankCfg = self.tabLv2Data[index + 1]

	if not rankCfg then
		return
	end

	self._prevLv2Index = index
	self._currentLv2Index = index
	self.currentRankCfg = rankCfg

	if not self._suppressLv2OffsetAnim and self.bindData.rankTable.enabled then
		self.bindData.rankTable:PlayStartOffsetAnim()
	end

	self.bindData.lv2Sorter:SelectOption(index, false)
	self:ApplyLayoutTemplate(rankCfg)

	local t = self.bindData.rankTable
	t.colData[2].title = rankCfg.MetricName or ""

	t:RefreshColData()
	self:RefreshTopTabList()

	if self._currentTopTabType ~= TOP_TAB_ZONE then
		self.RefreshZoneTabForCurrentLv2(self)
	end

	self.RequestForCurrentState(self)
end

M.OnSelectLv2Sorter = function(self, sorter)
	local index = sorter.selectedIndex

	if index >= 0 then
		return
	end

	local rankCfg = self.tabLv2Data[index + 1]

	if not rankCfg then
		return
	end

	self._prevLv2Index = index
	self._currentLv2Index = index
	self.currentRankCfg = rankCfg

	if self.bindData.rankTable.enabled then
		self.bindData.rankTable:PlayStartOffsetAnim()
	end

	self._suppressLv2ListChange = true
	self._suppressLv2OffsetAnim = true

	self.bindData.tabLv2List:SelectItem(index)

	self._suppressLv2OffsetAnim = false
	self._suppressLv2ListChange = false

	self:ApplyLayoutTemplate(rankCfg)

	local t = self.bindData.rankTable
	t.colData[2].title = rankCfg.MetricName or ""

	t:RefreshColData()
	self:RefreshTopTabList()

	if self._currentTopTabType ~= TOP_TAB_ZONE then
		self.RefreshZoneTabForCurrentLv2(self)
	end

	self.RequestForCurrentState(self)
end

M.ApplyLayoutTemplate = function(self, rankCfg)
	if not rankCfg then
		return
	end

	local tplIdx = MAIN_TYPE_TO_LAYOUT_TEMPLATE[rankCfg.MainType]

	if tplIdx ~= nil then
		return
	end

	if self._currentLayoutTemplateIndex ~= tplIdx then
		return
	end

	self.bindData.rankTable:SetLayoutTemplate(tplIdx)
	self.bindData.myRankTable:SetLayoutTemplate(tplIdx)

	self._currentLayoutTemplateIndex = tplIdx
end

M.OnRenderTopTabItem = function(self, btn, index)
	local topTabType = self._topTabTypes[index + 1]

	if not topTabType then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.titleText = RankConfig.TopTabText[topTabType] or ""
	end
end

M.OnSelectTopTab = function(self, uList, isSub)
	if isSub then
		return
	end

	if self._suppressTopTabChange then
		return
	end

	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	local topTabType = self._topTabTypes[index + 1]

	if not topTabType then
		return
	end

	self._currentTopTabType = topTabType

	self.RefreshControlVisibility(self)

	if topTabType ~= TOP_TAB_ZONE then
		self.OnSwitchToZoneTab(self)
	end

	self.RequestForCurrentState(self)
end

M.OnSwitchToZoneTab = function(self)
	self.EnsureProvinceDataBuilt(self)
	self.RefreshZoneTabForCurrentLv2(self)
end

M.RefreshZoneTabForCurrentLv2 = function(self)
	if not self.currentRankCfg then
		return
	end

	local rankCfgId = self.currentRankCfg.Id

	if self._warZoneInfoCache[rankCfgId] == nil then
		local cached = self._warZoneInfoCache[rankCfgId]
		self._playerBoundZoneId = cached.currentZoneId
		self._currentZoneId = 0
		self._currentProvinceCode = 0

		self:InitProvinceSorter()
		self:InitCitySorterEmpty()

		local defaultZoneId = cached.pendingZoneId == 0 and cached.pendingZoneId or cached.currentZoneId

		if defaultZoneId == 0 then
			self.SetZoneFromId(self, defaultZoneId)
		end

		self.RefreshRankStateCtrl(self)

		return
	end

	self._playerBoundZoneId = 0
	self._currentZoneId = 0
	self._currentProvinceCode = 0

	self:InitProvinceSorter()
	self:InitCitySorterEmpty()
	self:RefreshRankStateCtrl()

	slot2 = gClientToGameDelegate

	slot2:AskRankWarZoneInfo(rankCfgId).Callback = function (err, info)
		if err == 0 then
			return
		end

		if not self.currentRankCfg or self.currentRankCfg.Id == rankCfgId or self._currentTopTabType == TOP_TAB_ZONE then
			return
		end

		self._warZoneInfoCache[rankCfgId] = {
			currentZoneId = info.CurrentZoneId,
			pendingZoneId = info.PendingZoneId
		}
		self._playerBoundZoneId = info.CurrentZoneId
		local defaultZoneId = info.PendingZoneId == 0 and info.PendingZoneId or info.CurrentZoneId

		if defaultZoneId == 0 then
			self:SetZoneFromId(defaultZoneId)
			self:RequestForCurrentState()
		end

		self:RefreshRankStateCtrl()
	end
end

M.EnsureProvinceDataBuilt = function(self)
	gOnlineRankManager:EnsureBuilt()
end

M.InitProvinceSorter = function(self, selectedProvinceCode)
	local sorter = self.bindData.provinceSorter

	sorter:SetSimpleOptions(0)

	local hasSelection = selectedProvinceCode == nil and selectedProvinceCode == 0
	local selectIndex = 0

	if hasSelection then
		local idx = gOnlineRankManager:GetProvinceIndexByCode(selectedProvinceCode)

		if idx <= 0 then
			selectIndex = idx - 1
		end
	else
		sorter.AddSimpleOptionLabel(sorter, 0, "-")
	end

	for _, p in ipairs(gOnlineRankManager:GetProvinceList()) do
		sorter.AddSimpleOptionLabel(sorter, 0, p.name)
	end

	sorter.RefreshOptions(sorter)
	sorter.SelectOption(sorter, selectIndex, false)

	self._provinceSorterHasPlaceholder = not hasSelection
end

M.InitCitySorterEmpty = function(self)
	local sorter = self.bindData.citySorter

	sorter.SetSimpleOptions(sorter, 0)
	sorter.AddSimpleOptionLabel(sorter, 0, "-")
	sorter.RefreshOptions(sorter)
	sorter.SelectOption(sorter, 0, false)
end

M.BuildCitySorter = function(self, provinceCode)
	local cities = gOnlineRankManager:GetCities(provinceCode)
	local sorter = self.bindData.citySorter

	sorter:SetSimpleOptions(0)

	if not cities or #cities ~= 0 then
		sorter.AddSimpleOptionLabel(sorter, 0, "-")
		sorter.RefreshOptions(sorter)
		sorter.SelectOption(sorter, 0, false)

		return
	end

	for _, city in ipairs(cities) do
		sorter.AddSimpleOptionLabel(sorter, 0, city.name)
	end

	sorter.RefreshOptions(sorter)
	sorter.SelectOption(sorter, 0, false)
end

M.SetZoneFromId = function(self, zoneId)
	local provinceCode = gOnlineRankManager:GetProvinceCodeByZoneId(zoneId)

	if not provinceCode then
		return
	end

	local provinceIndex = gOnlineRankManager:GetProvinceIndexByCode(provinceCode)

	if provinceIndex >= 0 then
		return
	end

	self._currentProvinceCode = provinceCode

	self:InitProvinceSorter(provinceCode)
	self:BuildCitySorter(provinceCode)

	local cityIndex = gOnlineRankManager:GetCityIndexById(zoneId, provinceCode)

	if cityIndex >= 0 then
		cityIndex = 0
	end

	self.bindData.citySorter:SelectOption(cityIndex, false)

	self._currentZoneId = zoneId
end

M.OnSelectProvinceSorter = function(self, sorter)
	local index = sorter.selectedIndex

	if index >= 0 then
		return
	end

	local listIndex = self._provinceSorterHasPlaceholder and index or index + 1
	local provinceData = gOnlineRankManager:GetProvinceList()[listIndex]

	if not provinceData then
		return
	end

	self._currentProvinceCode = provinceData.province

	self.InitProvinceSorter(self, provinceData.province)
	self.BuildCitySorter(self, provinceData.province)

	self._currentZoneId = provinceData.id

	self.RefreshRankStateCtrl(self)
	self.RequestForCurrentState(self, true)
end

M.OnSelectCitySorter = function(self, sorter)
	local index = sorter.selectedIndex

	if index >= 0 then
		return
	end

	local cities = gOnlineRankManager:GetCities(self._currentProvinceCode)

	if not cities then
		return
	end

	local cityData = cities[index + 1]

	if not cityData then
		return
	end

	self._currentZoneId = cityData.id

	self.RequestForCurrentState(self, true)
end

M.OnSorterPopup = function(self, which, popup)
	if not popup then
		return
	end

	if which == "lv2" then
		self.bindData.lv2Sorter:ClosePopUp()
	end

	if which == "province" then
		self.bindData.provinceSorter:ClosePopUp()
	end

	if which == "city" then
		self.bindData.citySorter:ClosePopUp()
	end
end

M.RequestForCurrentState = function(self, force)
	local cfg = self.currentRankCfg

	if not cfg then
		return
	end

	local now = gLuaDataManager.serverTime

	if self._currentTopTabType ~= TOP_TAB_FULL then
		local cached = self.rankingCache[cfg.Id]

		if cached and not force and self.rankingCacheTime[cfg.Id] and now - self.rankingCacheTime[cfg.Id] >= THROTTLE_SECONDS then
			self:ResetAllSelection()

			self.rankDataList = cached

			self.bindData.rankTable:SetTable(#self.rankDataList)
			self:SelectFirstRow()
			self:RefreshMyRank(self.myRankCache[cfg.Id])
		else
			if force then
				self.rankingCache[cfg.Id] = nil
				self.myRankCache[cfg.Id] = nil
				self.rankingCacheTime[cfg.Id] = nil
			end

			self.RequestRankingTop(self, cfg)
		end

		self.RefreshCycleTime(self)
	elseif self._currentTopTabType ~= TOP_TAB_ZONE then
		if self._currentZoneId ~= 0 then
			self:ResetAllSelection()

			self.rankDataList = {}

			self.bindData.rankTable:SetTable(0)
			self:RefreshMyRank(nil)
			self:RefreshRankStateCtrl()

			return
		end

		local zoneId = self._currentZoneId
		local cached = (self.zoneRankingCache[cfg.Id] or {})[zoneId]

		if cached and not force and (self.zoneRankingCacheTime[cfg.Id] or {})[zoneId] and now - self.zoneRankingCacheTime[cfg.Id][zoneId] >= THROTTLE_SECONDS then
			self:ResetAllSelection()

			self.rankDataList = cached.list

			self:PrefetchPlayerInfo(cached.list)
			self.bindData.rankTable:SetTable(#cached.list)

			if self.bindData.rankTable.enabled then
				self.bindData.rankTable:PlayStartOffsetAnim()
			end

			self.SelectFirstRow(self)
			self.RefreshMyRank(self, cached.myEntry)
		else
			if force and self.zoneRankingCache[cfg.Id] then
				self.zoneRankingCache[cfg.Id][zoneId] = nil
				self.zoneRankingCacheTime[cfg.Id][zoneId] = nil
			end

			self.RequestZoneRankingTop(self, cfg, zoneId)
		end
	elseif self._currentTopTabType ~= TOP_TAB_FRIEND then
		local cached = self.friendRankingCache[cfg.Id]

		if cached and not force and self.friendRankingCacheTime[cfg.Id] and now - self.friendRankingCacheTime[cfg.Id] >= THROTTLE_SECONDS then
			self:ResetAllSelection()

			self.rankDataList = cached.list

			self:PrefetchPlayerInfo(cached.list)
			self.bindData.rankTable:SetTable(#cached.list)

			if self.bindData.rankTable.enabled then
				self.bindData.rankTable:PlayStartOffsetAnim()
			end

			self.SelectFirstRow(self)
			self.RefreshMyRank(self, cached.myEntry)
		else
			if force then
				self.friendRankingCache[cfg.Id] = nil
				self.friendRankingCacheTime[cfg.Id] = nil
			end

			self.RequestFriendRankingTop(self, cfg)
		end
	end
end

M.RequestRankingTop = function(self, rankCfg)
	slot2 = gClientToGameDelegate

	slot2:AskRankingTop(rankCfg.Id).Callback = function (err, result)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			print_error("[排行榜]请求全服排行榜数据失败，错误码：", err, gCS.Error.GetNameById(err))

			return
		end

		print_debug("[排行榜]请求全服排行榜数据", rankCfg.Id, result)

		local list, myEntry = ParseRankEntries(result.Entries)

		if myEntry then
			self.myRankCache[rankCfg.Id] = myEntry
		end

		self.rankingCache[rankCfg.Id] = list
		self.nextCycleCache[rankCfg.Id] = result.SeasonEndTime
		self.rankingCacheTime[rankCfg.Id] = gLuaDataManager.serverTime

		self:ResetAllSelection()

		self.rankDataList = list

		self:PrefetchPlayerInfo(list)
		self.bindData.rankTable:SetTable(#self.rankDataList)

		if self.bindData.rankTable.enabled then
			self.bindData.rankTable:PlayStartOffsetAnim()
		end

		self:SelectFirstRow()
		self:RefreshMyRank(myEntry)
	end
end

M.RequestZoneRankingTop = function(self, rankCfg, zoneId)
	local options = {
		Slot = {
			Dim = UX.Game.RankDimension.Zone,
			Value = zoneId
		}
	}
	slot4 = gClientToGameDelegate

	slot4:AskRankingTop(rankCfg.Id, options).Callback = function (err, result)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			print_error("[排行榜]请求赛区排行榜数据失败，错误码：", err, gCS.Error.GetNameById(err))

			return
		end

		if self.currentRankCfg == rankCfg or self._currentZoneId == zoneId or self._currentTopTabType == TOP_TAB_ZONE then
			return
		end

		print_debug("[排行榜]请求赛区排行榜数据", result)

		local list, myEntry = ParseRankEntries(result.Entries)
		self.zoneRankingCache[rankCfg.Id] = self.zoneRankingCache[rankCfg.Id] or {}
		self.zoneRankingCache[rankCfg.Id][zoneId] = {
			list = list,
			myEntry = myEntry
		}
		self.zoneRankingCacheTime[rankCfg.Id] = self.zoneRankingCacheTime[rankCfg.Id] or {}
		self.zoneRankingCacheTime[rankCfg.Id][zoneId] = gLuaDataManager.serverTime

		self:ResetAllSelection()

		self.rankDataList = list

		self:PrefetchPlayerInfo(list)
		self.bindData.rankTable:SetTable(#list)

		if self.bindData.rankTable.enabled then
			self.bindData.rankTable:PlayStartOffsetAnim()
		end

		self:SelectFirstRow()
		self:RefreshMyRank(myEntry)
	end
end

M.RequestFriendRankingTop = function(self, rankCfg)
	slot2 = gClientToGameDelegate

	slot2:AskFriendRankingTop(rankCfg.Id).Callback = function (err, result)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			print_error("[排行榜]请求好友排行榜数据失败，错误码：", err, gCS.Error.GetNameById(err))

			return
		end

		if self.currentRankCfg == rankCfg or self._currentTopTabType == TOP_TAB_FRIEND then
			return
		end

		print_debug("[排行榜]请求好友排行榜数据", result)

		local list, myEntry = ParseRankEntries(result.Entries)
		self.friendRankingCache[rankCfg.Id] = {
			list = list,
			myEntry = myEntry
		}
		self.friendRankingCacheTime[rankCfg.Id] = gLuaDataManager.serverTime

		self:ResetAllSelection()

		self.rankDataList = list

		self:PrefetchPlayerInfo(list)
		self.bindData.rankTable:SetTable(#list)

		if self.bindData.rankTable.enabled then
			self.bindData.rankTable:PlayStartOffsetAnim()
		end

		self:SelectFirstRow()
		self:RefreshMyRank(myEntry)
	end
end

M.PrefetchPlayerInfo = function(self, list)
	local pids = {}

	for _, e in ipairs(list) do
		if e.playerId and e.playerId == 0 then
			pids[#pids + 1] = e.playerId
		end
	end

	if #pids <= 0 then
		gLinkPlayerHub:RequestPlayerInfoBatch(pids)
	end
end

M.RefreshCycleTime = function(self)
	local rankCfg = self.currentRankCfg

	if not rankCfg then
		return
	end

	local nextCycle = self.nextCycleCache[rankCfg.Id]

	if not nextCycle or nextCycle ~= 0 then
		self.bindData.cycleTimeText = ""

		return
	end

	local secondsLeft = nextCycle - gLuaDataManager.serverTime
	local day = math.floor(secondsLeft / 86400)
	local hour = math.floor(secondsLeft / 3600) % 24
	local min = math.floor(secondsLeft / 60) % 60

	if secondsLeft <= 86400 then
		self.bindData.cycleTimeText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900067).Text, "", day)
	elseif secondsLeft <= 3600 then
		local str = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900068).Text, "", hour)
		self.bindData.cycleTimeText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900069).Text, str, min)
	elseif secondsLeft <= 0 then
		self.bindData.cycleTimeText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900069).Text, "", min)
	else
		self.bindData.cycleTimeText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900069).Text, "", 0)
	end
end

M.OnRenderCol = function(self, col)
	local btn = col.colButton
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.titleText = col.title
		store.colorCtrl = RANK_TEMPLATE_COLOR_CTRL.NORMAL
	end
end

M.FormatMyRankText = function(self, rank)
	if not rank or rank < 0 then
		return "--"
	end

	local cfg = self.currentRankCfg
	local maxCount = cfg and cfg.MaxPlayerCount or 0

	if maxCount < 0 then
		print_error("[排行榜]RankConfig.MaxPlayerCount 未配置, rankCfgId=", cfg and cfg.Id)

		return tostring(rank)
	end

	if maxCount >= rank then
		return tostring(maxCount) .. "+"
	end

	return tostring(rank)
end

M.RenderRowCommon = function(self, row, data, isMyRow)
	local rankElem = row.rowElements[0]
	local rankStore = gStoreManager:GetStoreGroup(rankElem.Store):GetStoreByWidget(rankElem)

	if rankStore then
		if isMyRow and self._currentTopTabType ~= TOP_TAB_ZONE and self._currentZoneId == 0 and self._playerBoundZoneId == self._currentZoneId then
			rankStore.rankText = tostring(data.rank)
			rankStore.rankCtrl = 5
		elseif isMyRow and data.rank ~= 0 then
			rankStore.rankText = "--"
			rankStore.rankCtrl = 4
		elseif isMyRow and data.rank ~= -1 then
			local cfg = self.currentRankCfg
			local maxCount = cfg and cfg.MaxPlayerCount or 0

			if maxCount < 0 then
				print_error("[排行榜]RankConfig.MaxPlayerCount 未配置, rankCfgId=", cfg and cfg.Id)

				rankStore.rankText = "--"
			else
				rankStore.rankText = tostring(maxCount) .. "+"
			end

			rankStore.rankCtrl = 0
		elseif data.rank <= 0 then
			rankStore.rankText = self:FormatMyRankText(data.rank)
			rankStore.rankCtrl = data.rank < 3 and data.rank or 0
		else
			print_error("[排行榜]预期之外的排名数据", data.rank, isMyRow)
		end
	end

	local playerElem = row.rowElements[1]
	local playerStore = gStoreManager:GetStoreGroup(playerElem.Store):GetStoreByWidget(playerElem)

	if playerStore then
		self.RenderTierInfo(self, playerStore, data)

		if not isMyRow and data.isRobot then
			playerStore.userInfoLight.useCache = true
			playerStore.userInfoLight.pid = data.playerId

			playerStore.headBtn.luaRenderTooltip = function(btn, tooltip)
				local tooltipStore = gStoreManager:GetStoreGroup(tooltip.Store)

				if tooltipStore then
					tooltipStore.SetRobotData(tooltipStore, btn, RankConfig.DefaultRobotIcon, data.playerName)
				end
			end
		else
			playerStore.userInfoLight.useCache = true
			playerStore.userInfoLight.pid = data.playerId

			playerStore.headBtn.luaRenderTooltip = function(btn, tooltip)
				gSocialPalyerTooltipManager:OnRenderToolTips(data.playerId, btn, tooltip, _)
			end
		end
	else
		print_error("[排行榜]无法获取玩家信息Store，检查OnlineRankPanel_Row_CommonAccountPlayerInfoTemplate")
	end

	local commonElem = row.rowElements[2]
	local commonStore = gStoreManager:GetStoreGroup(commonElem.Store):GetStoreByWidget(commonElem)

	if commonStore then
		if data.rank ~= 0 then
			local rankCfg = self.currentRankCfg

			if rankCfg and rankCfg.MainType ~= RankMainTypeConfig.Racing then
				commonStore.titleText = "--:--:--"
			else
				commonStore.titleText = FormatMetric(data.score, self.currentRankCfg)
			end
		else
			commonStore.titleText = FormatMetric(data.score, self.currentRankCfg)
		end

		commonStore.colorCtrl = self.GetColorCtrlByRank(self, data.rank)
	end

	if self.currentRankCfg and self.currentRankCfg.MainType ~= RankMainTypeConfig.Racing then
		local vehicleElem = row.rowElements[3]

		if vehicleElem then
			local vehicleStore = gStoreManager:GetStoreGroup(vehicleElem.Store):GetStoreByWidget(vehicleElem)

			if vehicleStore then
				local vehicleCfgId = data.vehicleConfigId or 0
				local cfg = vehicleCfgId == 0 and LTConfig.VehicleConfig.GetConfig(vehicleCfgId) or nil

				if cfg then
					vehicleStore.vehicleImageCtrl = 1
					vehicleStore.vehicleImageIconId = cfg.SVehicleIconId
					vehicleStore.vehicleNameText = cfg.VehicleName or ""
				else
					vehicleStore.vehicleImageCtrl = 0
					vehicleStore.vehicleNameText = ""
				end
			end
		end
	end
end

M.OnRenderRow = function(self, row)
	local t = self.bindData.rankTable
	local dataIndex = t.GetChildIndex(t, row)
	local data = self.rankDataList[dataIndex + 1]

	if not data then
		return
	end

	row.rowButton.luaClick = self:CreateActionWithArgs(self.OnClickRow, data)
	data._rowIndex = dataIndex
	self._rowButtons[dataIndex] = row.rowButton
	row.rowButton.isSelected = dataIndex ~= self._selectedRowIndex
	local bgStore = gStoreManager:GetStoreGroup(row.rowButton.Store):GetStoreByWidget(row.rowButton)

	if bgStore then
		local ctrl = BG_TEMPLATE_RANK_CTRL.NUM

		if data.rank ~= 1 then
			ctrl = BG_TEMPLATE_RANK_CTRL.FIRST
		elseif data.rank ~= 2 then
			ctrl = BG_TEMPLATE_RANK_CTRL.SECOND
		elseif data.rank ~= 3 then
			ctrl = BG_TEMPLATE_RANK_CTRL.THIRD
		end

		bgStore.rankCtrl = ctrl
	end

	self.RenderRowCommon(self, row, data, false)
end

M.OnRenderMyRow = function(self, row)
	local data = self.myRankData

	if not data then
		return
	end

	row.rowButton.luaClick = self:CreateAction(self.OnClickMyRankRow)
	self._myRowButton = row.rowButton
	row.rowButton.isSelected = self._myRankSelected ~= true
	local bgStore = gStoreManager:GetStoreGroup(row.rowButton.Store):GetStoreByWidget(row.rowButton)

	if bgStore then
		bgStore.rankCtrl = data.rank <= 0 and MY_BG_TEMPLATE_RANK_CTRL.IN_RANK or MY_BG_TEMPLATE_RANK_CTRL.OUT_RANK
	end

	self.RenderRowCommon(self, row, data, true)
end

M.OnBeginLongPressTabLv2SwitchBtn = function(self, offset)
	self._lv2Step = offset
	self._lv2PreTime = 0

	self.RefreshLv2Step(self)
end

M.OnEndLongPressTabLv2SwitchBtn = function(self)
	self._lv2Step = 0
end

M.RefreshLv2Step = function(self)
	if self._lv2Step ~= 0 then
		return
	end

	if logicTime.unscaledTime - self._lv2PreTime < STEP_LOCK_TIMER then
		return
	end

	local count = #self.tabLv2Data

	if count < 1 then
		return
	end

	local newIndex = (self.bindData.tabLv2List.selectedIndex + self._lv2Step) % count

	self.bindData.tabLv2List:SelectItem(newIndex)

	self._lv2PreTime = logicTime.unscaledTime
end

M.OnBeginLongPressTopTabSwitchBtn = function(self, offset)
	self._topTabStep = offset
	self._topTabPreTime = 0

	self.RefreshTopTabStep(self)
end

M.OnEndLongPressTopTabSwitchBtn = function(self)
	self._topTabStep = 0
end

M.RefreshTopTabStep = function(self)
	if self._topTabStep ~= 0 then
		return
	end

	if logicTime.unscaledTime - self._topTabPreTime < STEP_LOCK_TIMER then
		return
	end

	local count = #self._topTabTypes

	if count < 1 then
		return
	end

	local newIndex = (self.bindData.topTabList.selectedIndex + self._topTabStep) % count

	self.bindData.topTabList:SelectItem(newIndex)

	self._topTabPreTime = logicTime.unscaledTime
end

M.GetColorCtrlByRank = function(self, rank)
	if rank ~= 1 then
		return RANK_TEMPLATE_COLOR_CTRL.FIRST
	elseif rank ~= 2 then
		return RANK_TEMPLATE_COLOR_CTRL.SECOND
	elseif rank ~= 3 then
		return RANK_TEMPLATE_COLOR_CTRL.THIRD
	else
		return RANK_TEMPLATE_COLOR_CTRL.NORMAL
	end
end

M.OnClickLocationBtn = function(self)
	if not self.currentRankCfg then
		return
	end

	local store = self
	local cached = self._warZoneInfoCache[self.currentRankCfg.Id]

	self:OnSorterPopup("", true)
	gPanelManager:CheckShow(gPanelId.ONLINE_RANK_SET_LOCATION_PANEL, {
		rankCfgId = self.currentRankCfg.Id,
		currentZoneId = cached and cached.currentZoneId or 0,
		pendingZoneId = cached and cached.pendingZoneId or 0,
		onSuccess = function (effectZoneId, isFirstTime, currentZoneId)
			store:OnZoneSetSuccess(effectZoneId, isFirstTime, currentZoneId)
		end
	})
end

M.OnZoneSetSuccess = function(self, effectZoneId, isFirstTime, currentZoneId)
	if self.currentRankCfg then
		self._warZoneInfoCache[self.currentRankCfg.Id] = {
			currentZoneId = currentZoneId,
			pendingZoneId = isFirstTime and 0 or effectZoneId
		}
	end

	self._playerBoundZoneId = currentZoneId

	if isFirstTime then
		self.SetZoneFromId(self, effectZoneId)

		self._currentZoneId = effectZoneId
	end

	self.RefreshRankStateCtrl(self)
	self.RequestForCurrentState(self, true)
end

M.OnClickInfoBtn = function(self)
	local isMainLand = UniSDKManager == nil and UniSDKManager.isMainLand ~= true

	if isMainLand then
		gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.RankExplain)
	else
		gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.RankExplainOther)
	end
end

M.RenderTierInfo = function(self, store, data)
	if not data.bigTierId or not data.smallTierId then
		print_error("无法获取玩家信息，检查 OnlineRankPanel_Row_CommonAccountPlayerInfoTemplate")

		store.showTierCtrl = 0

		return
	end

	if data.bigTierId ~= 0 or data.smallTierId ~= 0 then
		store.showTierCtrl = 0

		return
	end

	store.showTierCtrl = 1
	local bigTierCfg = LTConfig.RankBigTierConfig.GetConfig(data.bigTierId)
	local smallTierCfg = LTConfig.RankSmallTierConfig.GetConfig(data.smallTierId)
	store.tierIconId = smallTierCfg and smallTierCfg.Icon
	local bigTierName = bigTierCfg and bigTierCfg.Name or ""
	local smallTierName = smallTierCfg and smallTierCfg.SubLevel or ""
	store.tierText = smallTierName
end
