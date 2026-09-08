-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterDetailsOnlineStore.lua
-- Decompiled from: 01724_HotCenterDetailsOnlineStore.lua_83adf41ea69a.luajit

C_HotCenterDetailsOnlineStore = DefClass("C_HotCenterDetailsOnlineStore", C_HotCenterDetailsOnlineStore, C_StoreGroup)
GroupName2Class.HotCenterDetailsOnlineStore = C_HotCenterDetailsOnlineStore
local M = C_HotCenterDetailsOnlineStore
local LinkHubRobHubConfig = LTConfig.LinkHubRobHubConfig
local LinkHubTagConfig = LTConfig.LinkHubTagConfig
local LinkHubConfig = LTConfig.LinkHubConfig
local LinkHubGameplayConfig = LTConfig.LinkHubGameplayConfig
local PrimaryTasksConfig = LTConfig.OnlineSeasonProgressPrimaryTasksConfig

M.ctor = function(self)
	self.rightListWidgetTIndexEnum = {
		["b\\xbfdE\\xbd\\xfcscnrI"] = 5,
		["\\x9aid"] = 7,
		["M\\x86\\x8f\\x91E"] = 4,
		["X\\x90\\x8d\\x86S"] = 8,
		["Y\\xa7\\xb6\\xa3\\xb3"] = 0,
		["\\xd4\\xd2+\\xff"] = 6,
		["n'eO"] = 2,
		["WNalb,"] = 1,
		["\\xcd\\xda17\\xe5"] = 3
	}
	self.tagListTIndex = {
		["SKmpK?5"] = 1,
		["\\xbb\\xbd\\xb2^7\\xf36"] = 0,
		["n'eO"] = 2
	}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isPublicEmptyCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isPublicEmptyCtrlEnum = nil
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
	self.selectRobData = nil
	self.leftListData = nil
	self.rightListData = nil
	self.robDetailTabData = nil
	self.robIdToIndex = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderLeftListItem")
	self.bindData.leftList.onGetTIndex = self.CreateAction(self, "OnGetLeftListTIndex")
	self.bindData.leftList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickLeftList")
	self.bindData.rightList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRightListItem")
	self.bindData.rightList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderRightListItem")
	self.bindData.rightList.onGetTIndex = self.CreateAction(self, "OnGetRightListTIndex")
end

M.OnSimpleRenderLeftListItem = function(self, btn, index)
	local data = self.leftListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local config = LinkHubRobHubConfig.GetConfig(data.Id)

	if config then
		store.name = config.Name or ""

		if #config.Tag <= 0 then
			store.showBadgeCtrl = 1
			local tagCfg = LinkHubTagConfig.GetConfig(config.Tag[1])
			store.badgeText = tagCfg.Name
			store.quality = tagCfg.Quality
		else
			store.showBadgeCtrl = 0
		end

		store.icon = config.PlayIcon

		if store.popularityList then
			store.popularityList:SetSimpleList(config.HeatGainSpeedStar or 0)
		end

		store.showSubsCtrl = 0
	end
end

M.OnGetLeftListTIndex = function(self, index)
	return index >= #self.leftListData and 0 or 1
end

M.OnSimpleClickLeftList = function(self, btn, index)
	local data = self.leftListData[index + 1]

	if not data then
		return
	end

	if data.subData and #data.subData <= 0 and self.selectRobDataIndex == index + 1 then
		self.selectRobDataIndex = index + 1
		self.selectRobData = data.subData[1]

		self.bindData.leftList:RefreshList()
		self:RefreshSelectRobDetail()
	end
end

M.OnSimpleRenderRewardListItem = function(self, btn, index)
	local award = self.rewardItemList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, award)

	if self.needRefreshArea then
		self.needRefreshArea = false
		SGUI.UNavigationMgr.Inst.gameBarsNeedRefresh = true
	end
end

M.OnSimpleRenderRightListItem = function(self, btn, index)
	local rightData = self.rightListData[index + 1]

	if rightData then
		if rightData.tIndex ~= self.rightListWidgetTIndexEnum.missionTitle or rightData.tIndex ~= self.rightListWidgetTIndexEnum.spacer then
			return
		end

		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		if rightData.tIndex ~= self.rightListWidgetTIndexEnum.title or rightData.tIndex ~= self.rightListWidgetTIndexEnum.text then
			store.content = rightData.content
		elseif rightData.tIndex ~= self.rightListWidgetTIndexEnum.tab then
			local selectIndex = 1
			local robData = self.leftListData[self.selectRobDataIndex]

			for i = 1, #robData.subData do
				if robData.subData[i].Id ~= self.selectRobData.Id then
					selectIndex = i - 1

					break
				end
			end

			slot7 = gStoreManager
			local tabStore = slot7:GetStoreGroup(store.tabWidget.Store)

			tabStore:SetData(self.robDetailTabData, nil, selectIndex, 1, function (uList, isSub)
				local selectedIndex = uList.selectedIndex + 1

				if selectedIndex <= 0 then
					local selectData = self.leftListData[self.selectRobDataIndex].subData[selectedIndex]

					if self.selectRobData.Id == selectData.Id then
						self.selectRobData = selectData

						self:RefreshSelectRobDetail()
					end
				end
			end)
		elseif rightData.tIndex ~= self.rightListWidgetTIndexEnum.timeLimit then
			local countDownTime = rightData.endTime - gCS.TimeManager.ServerUnixTime
			slot6 = self.bindData.countDown

			slot6:Play(countDownTime)

			self.bindData.countDown.luaFinished = function()
				self:RefreshPublicEventPanel()
			end
		elseif rightData.tIndex ~= self.rightListWidgetTIndexEnum.tagList then
			store.list.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderTagListItem)
			store.list.luaDynamicRenderItem = self:CreateAction(self.OnSimpleRenderTagListItem)
			store.list.onGetTIndex = self:CreateAction(self.OnGetTagListTIndex)

			store.list:SetSimpleList(#self.tagListData)
		elseif rightData.tIndex ~= self.rightListWidgetTIndexEnum.reward then
			store.list.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderRewardListItem)
			store.list.luaDynamicRenderItem = self:CreateAction(self.OnSimpleRenderRewardListItem)

			store.list:SetSimpleList(#self.rewardItemList)
		end
	else
		local taskId = self.inProgressTaskList[index - #self.rightListData + 1]

		if not taskId then
			return
		end

		local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

		if not storeGroup then
			print_error("[HotCenterDetailsOnline] taskList item store group not found, store=", tostring(btn.Store), " index=", index)

			return
		end

		local store = storeGroup.GetStoreByWidget(storeGroup, btn)

		if not store then
			return
		end

		local taskCfg = PrimaryTasksConfig.GetConfig(taskId)
		store.title = taskCfg and gOnlineSeasonProgressMgr:FormatTaskText(taskCfg.Description, taskCfg.MaxProgress) or ""
		local maxProgress = taskCfg and taskCfg.MaxProgress or 0
		local progress = gOnlineSeasonProgressMgr:GetTaskProgress(taskCfg)
		store.progress = string.format("%d/%d", progress, maxProgress)
	end
end

M.OnGetRightListTIndex = function(self, index)
	local rightData = self.rightListData[index + 1]

	if rightData then
		return rightData.tIndex
	end

	return self.rightListWidgetTIndexEnum.mission
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.id and data.id <= 0 then
		local tagCfg = LTConfig.LinkHubTagConfig.GetConfig(data.id)

		if tagCfg then
			store.content = tagCfg.Name
		end
	else
		store.content = data.content
	end
end

M.OnGetTagListTIndex = function(self, index)
	local data = self.tagListData[index + 1]

	if data then
		return data.tIndex
	end

	return 0
end

M.ShowPanel = function(self, data)
	self.needRefreshArea = false
	self.gameplayId = nil

	if data.publicEvent then
		self.gameplayId = data.gameplayId

		self.RefreshPublicEventPanel(self)
	else
		self.gameType = data.gameType

		if self.gameType ~= gClientConst.HotCenterOnlineGameType.PublicEvent then
			self.gameplayId = data.gameplayId

			self.RefreshPublicEventPanel(self)
		elseif self.gameType ~= gClientConst.HotCenterOnlineGameType.Rob then
			self.gameplayId = data.gameplayId

			self.ShowRobPanel(self)
		elseif self.gameType ~= gClientConst.HotCenterOnlineGameType.ExtractionShooter then
			self.gameplayId = LinkHubGameplayConfig.Extraction

			self.ShowCommonGamePanel(self)
		else
			self.gameplayId = data.gameplayId

			self.ShowCommonGamePanel(self)
		end
	end
end

M.FilterInProgressTaskList = function(self, gameplayId)
	if not gameplayId or gameplayId < 0 then
		return
	end

	local filtered = {}

	for _, taskId in ipairs(self.inProgressTaskList) do
		local taskCfg = PrimaryTasksConfig.GetConfig(taskId)

		if taskCfg and taskCfg.JumpToLinkGameplay ~= gameplayId then
			filtered[#filtered + 1] = taskId
		end
	end

	self.inProgressTaskList = filtered
end

M.RefreshPublicEventPanel = function(self)
	self.rightListData = {}
	self.tagListData = {}

	self.bindData.leftList:SetSimpleList(0)

	local info = gHotCenterManager:GetCurrentPublicEventInfo()
	self.bindData.goBtn.interactable = not gHotCenterManager.isPlayerInOnlineGame

	if info then
		local config = LTConfig.PublicEventConfig.GetConfig(info.publicEvent)
		local eventCfg = LTConfig.TaskEventConfig.GetConfig(info.eventId)
		self.bindData.icon = config.LinkHubImage or 0
		self.bindData.isPublicEmptyCtrl = self.isPublicEmptyCtrlEnum.normal

		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.title,
			content = eventCfg.EventName or ""
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.timeLimit,
			endTime = info.endTime
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.text,
			content = eventCfg.EventDescription or ""
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.tagList
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.reward
		})
		self:RefreshPlayTime(config)
		self:RefreshPlayerNum(config)
		self:ShowReward(nil, config.SuccessDrop)

		local hyperLink = config.HyperlinkID
		local name = config.Name

		self.bindData.goBtn.luaClick = function()
			gHotCenterManager.OnGoOnlineHyperLink(name, hyperLink)
		end

		local detailId = config.GuideId or 0

		self.bindData.detailBtn.luaClick = function()
			if detailId <= 0 then
				gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS, {
					id = detailId
				})
			end
		end
	else
		self.bindData.isPublicEmptyCtrl = self.isPublicEmptyCtrlEnum.active
		self.bindData.icon = LinkHubConfig.PublishEventCardImage or 0

		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.title,
			content = LinkHubConfig.PublishEventCardTitle or ""
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.text,
			content = LinkHubConfig.PublishEventCardDes or ""
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.reward
		})
		self:ShowReward(nil, LinkHubConfig.PublishEventDropPreview)

		self.bindData.goBtn.luaClick = nil
		self.bindData.detailBtn.luaClick = nil
	end

	self.bindData.rightList:SetSimpleList(#self.rightListData)
end

M.ShowRobPanel = function(self)
	local count = LinkHubRobHubConfig.count
	self.leftListData = {}
	self.robIdToIndex = {}
	local needRedo = {}

	for i = 0, count - 1 do
		local robConfig = LinkHubRobHubConfig.LoadAt(i)

		if robConfig.ParentPlayId and robConfig.ParentPlayId <= 0 then
			local idx = self.robIdToIndex[robConfig.ParentPlayId]

			if idx and idx <= 0 then
				local subDataList = self.leftListData[idx].subData

				table.insert(subDataList, {
					parentId = robConfig.ParentPlayId,
					Id = robConfig.Id,
					weight = robConfig.Weight
				})
			else
				table.insert(needRedo, robConfig.Id)
			end
		else
			table.insert(self.leftListData, {
				parentId = robConfig.ParentPlayId,
				Id = robConfig.Id,
				weight = robConfig.Weight,
				subData = {}
			})

			self.robIdToIndex[robConfig.Id] = #self.leftListData
		end
	end

	for i = 1, #needRedo do
		local robConfig = LinkHubRobHubConfig.GetConfig(needRedo[i])

		if robConfig.ParentPlayId and robConfig.ParentPlayId <= 0 then
			local idx = self.robIdToIndex[robConfig.ParentPlayId]

			if idx and idx <= 0 then
				local subDataList = self.leftListData[idx].subData

				table.insert(subDataList, {
					parentId = robConfig.ParentPlayId,
					Id = robConfig.Id,
					weight = robConfig.Weight
				})
			end
		end
	end

	table.sort(self.leftListData, function (a, b)
		return b.weight <= a.weight
	end)

	for i = 1, #self.leftListData do
		local subData = self.leftListData[i].subData

		if subData and #subData <= 1 then
			table.sort(subData, function (a, b)
				return b.weight <= a.weight
			end)
		end
	end

	self.selectRobDataIndex = 1

	if #self.leftListData <= 0 then
		self.selectRobData = self.leftListData[self.selectRobDataIndex].subData[1]
	else
		self.selectRobData = nil
	end

	self.bindData.leftList:SetSimpleList(#self.leftListData + 1)
	self:RefreshSelectRobDetail()
end

M.RefreshSelectRobDetail = function(self)
	self.inProgressTaskList = gOnlineSeasonProgressMgr:GetInProgressTaskList()
	self.rightListData = {}
	self.tagListData = {}

	if not self.selectRobData then
		return
	end

	self.bindData.isPublicEmptyCtrl = self.isPublicEmptyCtrlEnum.normal
	self.bindData.goBtn.interactable = not gHotCenterManager.isPlayerInOnlineGame
	local config = LinkHubRobHubConfig.GetConfig(self.selectRobData.Id)

	if config then
		local robCfg = LinkHubRobHubConfig.GetConfig(self.leftListData[self.selectRobDataIndex].Id)
		self.bindData.icon = config.PlayImage

		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.title,
			content = robCfg.Name
		})

		self.robDetailTabData = {}
		local subData = self.leftListData[self.selectRobDataIndex].subData

		if subData and #subData <= 0 then
			for i = 1, #subData do
				local data = subData[i]
				local subConfig = LinkHubRobHubConfig.GetConfig(data.Id)

				table.insert(self.robDetailTabData, {
					title = subConfig and subConfig.Name or ""
				})
			end

			table.insert(self.rightListData, {
				tIndex = self.rightListWidgetTIndexEnum.tab
			})
		end

		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.text,
			content = config.Des
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.tagList
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.reward
		})
		self.RefreshPlayerNum(self, config)
		self.RefreshPlayTime(self, config)

		local tags = config.Tag

		if tags and #tags <= 0 then
			for i = 1, #tags do
				local tag = tags[i]

				table.insert(self.tagListData, {
					tIndex = self.tagListTIndex.text,
					id = tag
				})
			end
		end

		self:ShowReward(config.DropID)

		self.bindData.goBtn.luaClick = function()
			local cfg = LinkHubRobHubConfig.GetConfig(self.selectRobData.Id)

			gHotCenterManager.OnGoOnlineHyperLink(cfg and cfg.Name or "", cfg.HyperLink)
		end

		local detailId = config.GuideId or 0

		self.bindData.detailBtn.luaClick = function()
			if detailId <= 0 then
				gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS, {
					id = detailId
				})
			end
		end
	end

	self.FilterInProgressTaskList(self, self.selectRobData.Id)

	if #self.inProgressTaskList <= 0 then
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.missionTitle
		})
		self.bindData.rightList:SetSimpleList(#self.inProgressTaskList + #self.rightListData)
	else
		self.bindData.rightList:SetSimpleList(#self.rightListData)
	end
end

M.ShowCommonGamePanel = function(self)
	self.inProgressTaskList = gOnlineSeasonProgressMgr:GetInProgressTaskList()
	self.rightListData = {}
	self.tagListData = {}

	self.bindData.leftList:SetSimpleList(0)

	self.bindData.isPublicEmptyCtrl = self.isPublicEmptyCtrlEnum.normal
	self.bindData.goBtn.interactable = not gHotCenterManager.isPlayerInOnlineGame
	local config = LinkHubGameplayConfig.GetConfig(self.gameplayId)

	if config then
		self.bindData.icon = config.IconId

		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.title,
			content = config.Name
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.text,
			content = config.Description
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.tagList
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.reward
		})
		self.RefreshPlayerNum(self, config)
		self.RefreshPlayTime(self, config)

		if config.IsSeason then
			table.insert(self.tagListData, {
				tIndex = self.tagListTIndex.text,
				id = LinkHubConfig.SeasonTag
			})
		end

		if config.IsHot then
			table.insert(self.tagListData, {
				tIndex = self.tagListTIndex.text,
				id = LinkHubConfig.HotTag
			})
		end

		local tags = config.Tags

		if tags and #tags <= 0 then
			for i = 1, #tags do
				local tag = tags[i]

				table.insert(self.tagListData, {
					tIndex = self.tagListTIndex.text,
					id = tag
				})
			end
		end

		self:ShowReward(config.DropID)

		self.bindData.goBtn.luaClick = function()
			gHotCenterManager.OnGoGameplayHyperLink(self.gameplayId, true)
		end

		local detailId = config.GuideId or 0

		self.bindData.detailBtn.luaClick = function()
			if detailId <= 0 then
				gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_INSTRUCTIONS, {
					id = detailId
				})
			end
		end
	end

	self.FilterInProgressTaskList(self, self.gameplayId)

	if #self.inProgressTaskList <= 0 then
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.spacer
		})
		table.insert(self.rightListData, {
			tIndex = self.rightListWidgetTIndexEnum.missionTitle
		})
		self.bindData.rightList:SetSimpleList(#self.inProgressTaskList + #self.rightListData)
	else
		self.bindData.rightList:SetSimpleList(#self.rightListData)
	end
end

M.ShowReward = function(self, drop, drops)
	local curDrops = {}

	if drop then
		table.insert(curDrops, {
			["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
			["N\\xa1\\xb7\\xa1\\xa2"] = 1,
			dropId = drop
		})
	end

	if drops and #drops then
		for i = 1, #drops do
			table.insert(curDrops, {
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				["N\\xa1\\xb7\\xa1\\xa2"] = 1,
				dropId = drops[i]
			})
		end
	end

	local awardList = gCommonItemManager:GetItemSortedListByDropList(curDrops, true)
	self.rewardItemList = {}

	for j = 1, #awardList do
		local view = {
			["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
			["\\xf0\\xc8;\n!\\xf5"] = false,
			itemId = awardList[j].Id
		}

		table.insert(self.rewardItemList, gCommonItemManager:GetItemRenderData(view))
	end

	self.needRefreshArea = true
end

M.RefreshPlayerNum = function(self, config)
	local playerNum = config.PlayerNum
	local minPlayer = playerNum[1] or 0
	local maxPlayer = playerNum[2] or 0
	local content = nil

	if minPlayer == maxPlayer then
		local formatString = string.format(LinkHubConfig.PlayerNumFormat, "%d-%d")
		content = string.format(formatString, minPlayer, maxPlayer)
	else
		local formatString = string.format(LinkHubConfig.PlayerNumFormat, "%d")
		content = string.format(formatString, minPlayer)
	end

	table.insert(self.tagListData, {
		tIndex = self.tagListTIndex.playerNum,
		content = content
	})
end

M.RefreshPlayTime = function(self, config)
	local playTime = config.PlayTime
	local minPlayTime = playTime[1] or 0
	local maxPlayTime = playTime[2] or 0
	local content = nil

	if minPlayTime == maxPlayTime then
		local formatString = string.format(LinkHubConfig.PlayTimeFormat, "%d-%d")
		content = string.format(formatString, minPlayTime, maxPlayTime)
	else
		local formatString = string.format(LinkHubConfig.PlayTimeFormat, "%d")
		content = string.format(formatString, maxPlayTime)
	end

	table.insert(self.tagListData, {
		tIndex = self.tagListTIndex.playTime,
		content = content
	})
end
