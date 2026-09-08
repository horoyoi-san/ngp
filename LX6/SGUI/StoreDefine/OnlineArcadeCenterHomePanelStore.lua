-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineArcadeCenterHomePanelStore.lua
-- Decompiled from: 01097_OnlineArcadeCenterHomePanelStore.lua_1ae341b1b2cb.luajit

C_OnlineArcadeCenterHomePanelStore = DefClass("C_OnlineArcadeCenterHomePanelStore", C_OnlineArcadeCenterHomePanelStore, C_StoreGroup)
GroupName2Class.OnlineArcadeCenterHomePanelStore = C_OnlineArcadeCenterHomePanelStore
local M = C_OnlineArcadeCenterHomePanelStore
local LinkHubConfig = LTConfig.LinkHubConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local LinkHubTagConfig = LTConfig.LinkHubTagConfig
local TaskEventState = UX.Game.TaskEventState
local DisplayType = {
	["\\x82\\xbf'\\xa4~*\\xf1>"] = 2,
	["5F\\xbc\\x8f\\x8aO"] = 1
}
local MainListTemplateIndex = {
	["a\\xaf\\xb0\\xa8\\xb3"] = 1,
	["~\\xa3\\xa3\\xa3\\xba"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.ShowPanel = function(self, args)
	self:InitListData()
	self.bindData.mainList:SetSimpleList(#self.mainListData)
	self.bindData.bottomList:SetSimpleList(#self.bottomListData)
end

M.OnClose = function(self)
	self.mainListData = nil
	self.bottomListData = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.allGameBtn.luaClick = self.CreateAction(self, "OnClickAllGameBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")

	if self.bindData.goShopBtn then
		self.bindData.goShopBtn.luaClick = self.CreateAction(self, "OnClickGoShopGame")
	end

	self.bindData.mainList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderMainListItem")
	self.bindData.bottomList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBottomListItem")
	self.bindData.mainList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickMainList")
	self.bindData.bottomList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickBottomList")
	self.bindData.mainList.onGetTIndex = self.CreateAction(self, "OnGetMainListTIndex")
	self.bindData.bottomList.onGetTIndex = self.CreateAction(self, "OnGetBottomListTIndex")
end

M.OnClickAllGameBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_ARCADE_CENTER_SHOW_PANEL, {
		["\\x8c</(Y\\x91M\\xfe6\\xa7\\xbc"] = true,
		showType = gClientConst.ArcadeCenterShowType.Info
	})
end

M.OnClickBackBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_ARCADE_CENTER_CLOSE_PANEL)
end

M.OnClickGoShopGame = function(self)
	local shopLinkId = LinkHubConfig.JumpToLinkStore

	if shopLinkId and shopLinkId <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(shopLinkId, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end

		gPanelManager:Close(gPanelId.ONLINE_ARCADE_CENTER_MAIN_PNEL)
	end
end

M.OnGetMainListTIndex = function(self, index)
	local data = self.mainListData[index + 1]

	return data and data.tIndex or 0
end

M.OnSimpleRenderMainListItem = function(self, btn, index)
	local data = self.mainListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local config = LinkHubConfig.GetConfig(data.Id)

	if config then
		store.name = config.Name
		store.icon = config.PlayImage

		if string.is_null_or_empty(config.Description) then
			store.showSubTitleCtrl = 1
		else
			store.showSubTitleCtrl = 0
			store.des = config.Description
		end

		local tagId = config.Tag

		if tagId <= 0 then
			store.badgeCtrl = 1

			self.RefreshTag(self, store.tagWidget, tagId)
		else
			store.badgeCtrl = 0
		end
	end
end

M.OnSimpleClickMainList = function(self, btn, index)
	local data = self.mainListData[index + 1]

	if not data then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_ARCADE_CENTER_SHOW_PANEL, {
		showType = gClientConst.ArcadeCenterShowType.Info,
		gameType = data.gameType
	})
end

M.OnGetBottomListTIndex = function(self, index)
	local data = self.bottomListData[index + 1]

	return data and data.tIndex or 0
end

M.OnSimpleRenderBottomListItem = function(self, btn, index)
	local data = self.bottomListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.showSubTitleCtrl = 1
	local config = LinkHubConfig.GetConfig(data.Id)

	if config and config.GamePlayId <= 0 then
		local LinkConfig = nil

		if config.MainType ~= LinkHubConfig.MainTypeType.Rob then
			LinkConfig = LTConfig.LinkHubRobHubConfig
		elseif config.MainType ~= LinkHubConfig.MainTypeType.MidSize then
			LinkConfig = LTConfig.LinkHubMidSizeHubConfig
		elseif config.MainType ~= LinkHubConfig.MainTypeType.SmallSize then
			LinkConfig = LTConfig.LinkHubSmallSizeHubConfig
		elseif config.MainType ~= LinkHubConfig.MainTypeType.ExtractionShooter then
			LinkConfig = LTConfig.LinkHubExtractionHub
		end

		if LinkConfig then
			local gameConfig = LinkConfig.GetConfig(config.GamePlayId)

			if gameConfig and gameConfig.PlayId then
				store.icon = gameConfig.PlayIcon
				local linkConfig = LinkMultiPlayerConfig.GetConfig(gameConfig.PlayId)

				if linkConfig then
					store.name = linkConfig.Name
				end
			end

			local tagId = config.Tag

			if data.gameType ~= gClientConst.ArcadeCenterGameType.MidSize and config.PublicEvent and config.PublicEvent <= 0 then
				local taskState = gTaskManager:GetTaskEventState(config.PublicEvent)
				tagId = taskState ~= TaskEventState.Accepted and LinkHubConfig.PublicEventOn or LinkHubConfig.PublicEventOff
			end

			if tagId <= 0 then
				store.badgeCtrl = 1

				self.RefreshTag(self, store.tagWidget, tagId)
			else
				store.badgeCtrl = 0
			end
		end
	end
end

M.OnSimpleClickBottomList = function(self, btn, index)
	local data = self.bottomListData[index + 1]

	if not data then
		return
	end

	local config = LinkHubConfig.GetConfig(data.Id)

	if config and config.GamePlayId <= 0 then
		gMessageManager:SendMessage(gEventConstants.ON_ARCADE_CENTER_SHOW_PANEL, {
			showType = gClientConst.ArcadeCenterShowType.Info,
			gameType = data.gameType,
			gamePlayId = config.GamePlayId
		})
	end
end

M.InitListData = function(self)
	self.mainListData = {}
	self.bottomListData = {}
	local count = LinkHubConfig.count

	for i = 0, count - 1 do
		local linkHudCfg = LinkHubConfig.LoadAt(i)

		if linkHudCfg then
			if linkHudCfg.DisplayType ~= DisplayType.InMain then
				local gameType = self:GetGameTypeByConfig(linkHudCfg)
				local tIndex = LinkHubConfig.WeightThreshold >= linkHudCfg.Weight and MainListTemplateIndex.Large or MainListTemplateIndex.Small

				table.insert(self.mainListData, {
					Id = linkHudCfg.Id,
					gameType = gameType,
					weight = linkHudCfg.Weight,
					tIndex = tIndex
				})
			elseif linkHudCfg.DisplayType ~= DisplayType.InBottom then
				local gameType = self.GetGameTypeByConfig(self, linkHudCfg)

				table.insert(self.bottomListData, {
					Id = linkHudCfg.Id,
					gameType = gameType,
					gameplayId = linkHudCfg.GamePlayId,
					weight = linkHudCfg.Weight
				})
			end
		end
	end
end

M.GetGameTypeByConfig = function(self, linkHubConfig)
	if linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.Rob then
		return gClientConst.ArcadeCenterGameType.Rob
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.ExtractionShooter then
		return gClientConst.ArcadeCenterGameType.ExtractionShooter
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.MidSize then
		return gClientConst.ArcadeCenterGameType.MidSize
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.SmallSize then
		return gClientConst.ArcadeCenterGameType.SmallSize
	end

	return gClientConst.ArcadeCenterGameType.Unknown
end

M.RefreshTagList = function(self, list, tags)
	local cachedTags = tags or {}

	list.luaSimpleRenderItem = function(btn, index)
		local tagId = cachedTags[index + 1]

		if tagId then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if store then
				local tagCfg = LinkHubTagConfig.GetConfig(tagId)

				if tagCfg then
					store.quality = tagCfg.Quality or 0
					store.text = tagCfg.Name
				end
			end
		end
	end

	list:SetSimpleList(#tags)
end

M.RefreshTag = function(self, widget, tagId)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if store then
		local tagCfg = LinkHubTagConfig.GetConfig(tagId)

		if tagCfg then
			store.quality = tagCfg.Quality or 0
			store.text = tagCfg.Name
		end
	end
end
