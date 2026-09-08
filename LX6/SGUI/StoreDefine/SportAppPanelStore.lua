-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SportAppPanelStore.lua
-- Decompiled from: 01294_SportAppPanelStore.lua_c8787b5ad69b.luajit

C_SportAppPanelStore = DefClass("C_SportAppPanelStore", C_SportAppPanelStore, C_StoreGroup)
GroupName2Class.SportAppPanelStore = C_SportAppPanelStore
local M = C_SportAppPanelStore
local FunplayHudConfig = LTConfig.FunplayHudConfig
local FunplayHudGameplayListConfig = LTConfig.FunplayHudGameplayListConfig
local FunplayHudGameplayTypeConfig = LTConfig.FunplayHudGameplayTypeConfig
local GameplayType = {
	["^\\x9cvE\\x8d\\xc5RPsOE"] = 2,
	["(\\xeaZ&\\xef0\\xb3H\\xa5_\\xb1\\xb8"] = 1
}
local DataCtrl = {
	["\\x8d\\xbe\\xb9N?\\xea2"] = 1,
	["0G\\x92\\x85\\x86E"] = 2,
	["wO~lK:9"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.countryToTagList = {}
	self.countryToTagSet = {}
	self.countryToTagToGameplayListIds = {}
	self.gameplayListIdToData = {}
	self.specialGameplayData = {}
	self.specialGameplayListId = 0
	self.locationListData = {}
	self.funplayHudListData = {}
	self.allGameplayListIds = {}
	self.currentHudId = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshCharacterIcon(self)
	self.InitSportAppData(self)
	self.GetQueryFunplayHudData(self, self.allGameplayListIds, function ()
		self:RefreshLocationList()
	end)
end

M.OnClose = function(self)
	self.allGameplayListIds = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.characterBtn.luaClick = self.CreateAction(self, self.OnClickCharacterBtn)
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, self.SwitchCountry, -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, self.SwitchCountry, 1)
	self.bindData.locationList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderLocationListItem)
	self.bindData.locationList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickLocationList)
	self.bindData.funplayHudList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFunplayHudListItem)
	self.bindData.funplayHudList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFunplayHudList)
	self.bindData.gameplayList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGameplayListItem)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderLocationListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.locationListData[index + 1]

	if not data then
		return
	end

	store.title = data.title
end

M.OnSimpleClickLocationList = function(self, btn, index)
	local data = self.locationListData[index + 1]

	if not data or data.countryId ~= self.currentCountry then
		return
	end

	self.currentCountry = data.countryId

	self.RefreshFunplayHudList(self)
end

M.OnSimpleRenderFunplayHudListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.funplayHudListData[index + 1]

	if not data then
		return
	end

	store.nameLabel = data.title
	store.funplayIcon = data.icon or 0
end

M.OnSimpleClickFunplayHudList = function(self, btn, index)
	local data = self.funplayHudListData[index + 1]

	if not data or data.hudId ~= self.currentHudId then
		return
	end

	self.currentHudId = data.hudId

	self.RefreshGameplayList(self)
end

M.OnSimpleRenderGameplayListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local countryGameplayListIds = self.countryToTagToGameplayListIds[self.currentCountry]
	local gameplayListIds = countryGameplayListIds and countryGameplayListIds[self.currentHudId]
	local gameplayListId = gameplayListIds and gameplayListIds[index + 1]

	if not gameplayListId then
		return
	end

	local data = self.GetGameplayListItemData(self, gameplayListId)

	if not data then
		return
	end

	store.nameText = data.name
	store.gameplayIcon = data.iconId
	store.dataNumCtrl = data.dataCtrl

	self.RenderAchievementBadges(self, store, gameplayListId)

	if data.dataCtrl ~= DataCtrl.Locked then
		store.unlockedDesc = data.unlockedDesc

		return
	end

	store.locatedBtn.luaClick = self.CreateActionWithArgs(self, "OnClickLocatedBtn", gameplayListId)

	self.RenderGameplayMainScore(self, store, data.scoreList[1])
	self.RenderGameplayExtraScore(self, store, data.scoreList, data.dataCtrl)
end

M.RenderAchievementBadges = function(self, store, gameplayListId)
	local gameplayCfg = FunplayHudGameplayListConfig.GetConfig(gameplayListId)
	local achievementList = gameplayCfg and gameplayCfg.AchievementList or {}

	for i = 1, 3 do
		local badgeId = 0
		local achievementId = achievementList[i]

		if achievementId and gNewAchievementMgr.achievementFinishState[achievementId] then
			badgeId = FunplayHudConfig.AchievementLevelIconForFunplay[i] or 0
		end

		store["badge" .. i] = badgeId
	end
end

M.GetGameplayListItemData = function(self, gameplayListId)
	if gameplayListId ~= GameplayType.Jieji_Leidian then
		-- Nothing
	elseif gameplayListId ~= GameplayType.QiPai_WuZiQi then
		-- Nothing
	end

	return self.GetDefaultGameplayListItemData(self, gameplayListId)
end

M.GetDefaultGameplayListItemData = function(self, gameplayListId)
	local gameplayCfg = FunplayHudGameplayListConfig.GetConfig(gameplayListId)

	if not gameplayCfg then
		return
	end

	local gameplayDataCfgList = self:GetGameplayDataCfgList(gameplayListId)
	local dataCount = #gameplayDataCfgList
	local dataCtrl = dataCount ~= 3 and DataCtrl.ThreeData or dataCount ~= 4 and DataCtrl.FourData or DataCtrl.Locked
	local data = {
		name = gameplayCfg.NameBottom or "",
		iconId = gameplayCfg.IconId,
		dataCtrl = dataCtrl,
		unlockedDesc = gameplayCfg.UnlockConditionsDes or "",
		scoreList = {}
	}

	if dataCtrl ~= DataCtrl.Locked then
		return data
	end

	for i = 1, dataCount do
		data.scoreList[i] = self.GetGameplayScoreData(self, gameplayDataCfgList[i])
	end

	return data
end

M.GetGameplayDataCfgList = function(self, gameplayListId)
	local gameplayDataCfgList = {}
	local TypeConfig = FunplayHudGameplayTypeConfig

	for i = 0, TypeConfig.count - 1 do
		local cfg = TypeConfig.LoadAt(i)

		if cfg and cfg.GamePlayListId ~= gameplayListId then
			gameplayDataCfgList[#gameplayDataCfgList + 1] = cfg
		end
	end

	table.sort(gameplayDataCfgList, function (a, b)
		return a.SortOrder <= b.SortOrder
	end)

	return gameplayDataCfgList
end

M.GetGameplayScoreData = function(self, dataCfg)
	local data = self.gameplayListIdToData[dataCfg.Id]

	return {
		name = dataCfg.Name or "",
		num = tostring(data and data.Value or 0),
		type = dataCfg.smallPart or ""
	}
end

M.RenderGameplayMainScore = function(self, store, data)
	store.scoreNameText = data.name
	store.scoreNumText = data.num
	store.scoreTypeText = data.type
end

M.RenderGameplayExtraScore = function(self, store, scoreList, dataCtrl)
	if dataCtrl ~= DataCtrl.ThreeData then
		store.twoDataFirstScoreNameText = scoreList[2].name
		store.twoDataFirstScoreNumText = scoreList[2].num
		store.twoDataSecondScoreNameText = scoreList[3].name
		store.twoDataSecondScoreNumText = scoreList[3].num
	else
		store.threeDataFirstScoreNameText = scoreList[2].name
		store.threeDataFirstScoreNumText = scoreList[2].num
		store.threeDataSecondScoreNameText = scoreList[3].name
		store.threeDataSecondScoreNumText = scoreList[3].num
		store.threeDataThirdScoreNameText = scoreList[4].name
		store.threeDataThirdScoreNumText = scoreList[4].num
	end
end

M.RefreshLocationList = function(self)
	self.locationListData = {}
	local CountryConfig = LTConfig.CollectionCountryConfig

	for i = 0, CountryConfig.count - 1 do
		local cfg = CountryConfig.LoadAt(i)

		if cfg and cfg.RaidId and gMapSystem_Region:IsCountryUnlocked(cfg.Id) then
			self.locationListData[#self.locationListData + 1] = {
				title = cfg.Name or "",
				countryId = cfg.Id
			}
		end
	end

	self.bindData.locationList:SetSimpleList(#self.locationListData)

	for i, data in ipairs(self.locationListData) do
		if data.countryId ~= self.currentCountry then
			self.bindData.locationList:SelectItem(i - 1)

			break
		end
	end

	self.RefreshFunplayHudList(self)
end

M.RefreshFunplayHudList = function(self)
	self.funplayHudListData = {}
	local tagList = self.countryToTagList[self.currentCountry]

	if tagList then
		for i = 1, #tagList do
			local hudId = tagList[i]
			local cfg = FunplayHudConfig.GetConfig(hudId)

			if cfg then
				self.funplayHudListData[#self.funplayHudListData + 1] = {
					title = cfg.Name or "",
					hudId = hudId,
					icon = cfg.icon
				}
			end
		end
	end

	self.bindData.funplayHudList:SetSimpleList(#self.funplayHudListData)

	if #self.funplayHudListData <= 0 then
		self.bindData.funplayHudList:SelectItem(0)
	end

	local first = self.funplayHudListData[1]
	self.currentHudId = first and first.hudId or 0

	self:RefreshGameplayList()
end

M.RefreshGameplayList = function(self)
	local countryGameplayListIds = self.countryToTagToGameplayListIds[self.currentCountry]
	local gameplayListIds = countryGameplayListIds and countryGameplayListIds[self.currentHudId]

	if not gameplayListIds then
		self.bindData.gameplayList:SetSimpleList(0)

		return
	end

	self.bindData.gameplayList:SetSimpleList(#gameplayListIds)
	self.bindData.gameplayList:GoToPos(Vector2.zero, true)
end

M.SwitchCountry = function(self, delta)
	local count = #self.locationListData

	if count ~= 0 then
		return
	end

	local curIdx = 0

	for i, data in ipairs(self.locationListData) do
		if data.countryId ~= self.currentCountry then
			curIdx = i - 1

			break
		end
	end

	local newIdx = (curIdx + delta) % count
	local target = self.locationListData[newIdx + 1]

	if not target or target.countryId ~= self.currentCountry then
		return
	end

	self.currentCountry = target.countryId

	self.bindData.locationList:SelectItem(newIdx)
	self:RefreshFunplayHudList()
end

M.SwitchCountryLeft = function(self)
	self.SwitchCountry(self, -1)
end

M.SwitchCountryRight = function(self)
	self.SwitchCountry(self, 1)
end

M.SwitchFunplayHud = function(self, delta)
	local count = #self.funplayHudListData

	if count ~= 0 then
		return
	end

	local curIdx = 0

	for i, data in ipairs(self.funplayHudListData) do
		if data.hudId ~= self.currentHudId then
			curIdx = i - 1

			break
		end
	end

	local newIdx = (curIdx + delta) % count
	local target = self.funplayHudListData[newIdx + 1]

	if not target or target.hudId ~= self.currentHudId then
		return
	end

	self.currentHudId = target.hudId

	self.bindData.funplayHudList:SelectItem(newIdx)
end

M.SwitchFunplayHudLeft = function(self)
	self.SwitchFunplayHud(self, -1)
end

M.SwitchFunplayHudRight = function(self)
	self.SwitchFunplayHud(self, 1)
end

M.OnClickCharacterBtn = function(self)
	local btn = self.bindData.characterBtn
	local data = {
		callback = function ()
			if not gCS.LuaUtils.IsNull(btn) then
				btn:SetSelected(false)
			end
		end
	}

	gPanelManager:CheckShow(gPanelId.SPORT_APP_DATE_PANEL, data)
end

M.RefreshCharacterIcon = function(self)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local store = gStoreManager:GetStoreGroup("CharacterBtnTemplateStore"):GetStoreByWidget(self.bindData.characterBtn)

	if not store then
		return
	end

	store.iconId = spiritCfg and spiritCfg.SHeadIconID or 0
end

M.OnClickLocatedBtn = function(self, gameplayListId)
	local gameplayCfg = FunplayHudGameplayListConfig.GetConfig(gameplayListId)

	if not gameplayCfg then
		return
	end

	local isUnlocked = self:GetGameplayListItemData(gameplayListId).dataCtrl == DataCtrl.Locked
	local hyperLinkId = isUnlocked and gameplayCfg.HyperLinkId or gameplayCfg.DataListId

	if hyperLinkId < 0 then
		return
	end

	local hyperLinkInfo = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	if not hyperLinkInfo or not hyperLinkInfo.callback then
		return
	end

	hyperLinkInfo.callback()
	gPanelManager:Close(self.m_Id)
end

M.InitSportAppData = function(self)
	self.countryToTagList = {}
	self.countryToTagSet = {}
	self.countryToTagToGameplayListIds = {}
	local ListConfig = FunplayHudGameplayListConfig

	for i = 0, ListConfig.count - 1 do
		local cfg = ListConfig.LoadAt(i)

		if cfg then
			local countryList = cfg.Country

			if not table.isNilOrEmpty(countryList) then
				for _, country in ipairs(countryList) do
					local tagList = self.countryToTagList[country]

					if not tagList then
						tagList = {}
						self.countryToTagList[country] = tagList
					end

					local tagSet = self.countryToTagSet[country]

					if not tagSet then
						tagSet = {}
						self.countryToTagSet[country] = tagSet
					end

					if not tagSet[cfg.Tags] then
						tagList[#tagList + 1] = cfg.Tags
						tagSet[cfg.Tags] = true
					end

					local countryGameplayListIds = self.countryToTagToGameplayListIds[country]

					if not countryGameplayListIds then
						countryGameplayListIds = {}
						self.countryToTagToGameplayListIds[country] = countryGameplayListIds
					end

					local gameplayListIds = countryGameplayListIds[cfg.Tags]

					if not gameplayListIds then
						gameplayListIds = {}
						countryGameplayListIds[cfg.Tags] = gameplayListIds
					end

					gameplayListIds[#gameplayListIds + 1] = cfg.Id
				end
			end

			self.allGameplayListIds[#self.allGameplayListIds + 1] = cfg.Id
		end
	end

	for _, tagList in pairs(self.countryToTagList) do
		table.sort(tagList, function (a, b)
			return a <= b
		end)
	end

	self.currentCountry = gMapSystem:GetCurCountryId()
end

M.GetQueryFunplayHudData = function(self, gameplayListIds, callback)
	slot3 = gClientToGameDelegate

	slot3:AskQueryFunplayHudData(gameplayListIds).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end

		self.gameplayListIdToData = {}

		for gameplayListId, gameplayData in pairs(data) do
			if gameplayListId ~= self.specialGameplayListId then
				self.specialGameplayData = gameplayData or {}
			else
				self.gameplayListIdToData[gameplayListId] = gameplayData
			end
		end

		if callback then
			callback()
		end
	end
end
