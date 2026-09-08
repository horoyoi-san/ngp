-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_Legend.lua
-- Decompiled from: 01018_BigMapTooltip_Legend.lua_2f572e2d816e.luajit

local LegendConfig = LTConfig.LegendaryInvestigatorConfig
local BlockConfig = LTConfig.CollectionBlockConfig
local TextConfig = LTConfig.LegendaryInvestigatorTextConfig
C_BigMapTooltip_Legend = DefClass("C_BigMapTooltip_Legend", C_BigMapTooltip_Legend, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Legend
local NOT_UPLOADED = 0
local UPLOADED = 1

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "legendInfo") then
		return
	end

	local info = self.tooltipInfo.legendInfo

	self:GetStore("MapLegendTooltipStore")
	self:SetUpHeader()
	self:RefreshUploadState(self.store, info)

	local scrollStore = gStoreManager:GetStoreGroup("LegendMapDescStore"):GetStoreByWidget(self.store.descScroll.content)

	self:SetUpScroll(scrollStore, info)

	self.store.descScroll.luaLayoutSet = self.bigMap:CreateAction("OnLayoutDescScroll", self)
end

M.SetUpScroll = function(self, store, info)
	local levelText = LegendConfig.DisasterLevelText[info.level]
	local blockCfg = BlockConfig.GetConfig(info.blockId)
	local blockName = blockCfg and blockCfg.BlockName or ""
	local levelIconId = gMapSubSystem_Legend:GetSIconId(info.level)
	store.name = info.name
	store.numberText = info.numberText
	store.location = blockName
	store.levelName = levelText or ""
	store.levelIcon = levelIconId or 0
	self.descInfos = {}

	for _, descInfo in ipairs(info.describe) do
		if descInfo.descType ~= 1 then
			local text = TextConfig.GetConfig(descInfo.descId).Text

			if string.find(text, "\n") then
				for _, seg in ipairs(string.split(text, "\n")) do
					table.insert(self.descInfos, {
						descType = descInfo.descType,
						text = seg
					})
				end
			else
				table.insert(self.descInfos, {
					descType = descInfo.descType,
					text = text
				})
			end
		elseif descInfo.descType ~= 2 then
			table.insert(self.descInfos, {
				descType = descInfo.descType,
				id = descInfo.descId
			})
		elseif descInfo.descType ~= 3 then
			table.insert(self.descInfos, {
				descType = descInfo.descType,
				id = descInfo.descId
			})
		end
	end

	store.descList.onGetTIndex = self.bigMap:CreateAction("OnGetDescTIndex", self)
	store.descList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderDescItem", self)

	store.descList:SetSimpleList(#self.descInfos)
	self:SetUpDropsWithId(info.dropId, store.rewardList)

	store.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
end

M.OnActive = function(self)
	self.TryRegisterNavArea(self)

	self._uploadCoroutine = nil
end

M.OnInActive = function(self)
	self.TryUnRegisterNavArea(self)
	self.CancelCoroutine(self)
end

M.RefreshUploadState = function(self, store, info)
	self.store.isUploaded = info.uploaded and UPLOADED or NOT_UPLOADED
	self.store.unlockTime = os.date("%Y/%m/%d", info.unlockTime)

	if not info.uploaded then
		store.showUploadBtn = 1
		store.clickUpload = self.bigMap:CreateAction("OnClickUpload", self)
	end
end

M.SetUpActions = function(self, store, actions, blockReason)
end

M.PretendClick = function(self, blockReason, actions)
	self.OnClickUpload(self)
end

M.OnClickUpload = function(self)
	gMapSubSystem_Legend:UploadArchive(self.tooltipInfo.legendInfo.legendId)

	self.store.showUploadBtn = 0
	self.store.isUploaded = UPLOADED

	self.store.uploadAnim:Play("S_vx_LegendMapTooltip_get")

	self._pendingScrollToBottom = true
end

M.OnGetDescTIndex = function(self, index)
	index = index + 1
	local data = self.descInfos[index]

	return data.descType - 1
end

M.OnRenderDescItem = function(self, btn, index)
	index = index + 1
	local data = self.descInfos[index]

	if data.descType ~= 1 then
		local store = gStoreManager:GetStoreGroup("LegendListTextStore"):GetStoreByWidget(btn)
		store.descText = data.text
	elseif data.descType ~= 2 then
		local store = gStoreManager:GetStoreGroup("LegendMapPicStore"):GetStoreByWidget(btn)
		store.iconId = data.id
	elseif data.descType ~= 3 then
		local store = gStoreManager:GetStoreGroup("LegendMapVideoStore"):GetStoreByWidget(btn)

		store.videoPlayer:Init()
		store.videoPlayer:PlayVideo(data.id, true)
	end
end

M.OnLayoutDescScroll = function(self)
	if self._pendingScrollToBottom then
		self._pendingScrollToBottom = false
		self._uploadStartTime = Time.unscaledTime
		slot1 = gCoroutineManager

		slot1:StartCoroutine(function ()
			coroutine.yield(gWaitableUtils.WaitTime(0.2))

			if self and self.store and self.store.descScroll then
				self.store.descScroll:GoToPos(Vector2.New(0, 0), true)
				self.store.descScroll:GoToPos(Vector2.New(0, 10000), false)

				local attempts = 0
				local scrollStore = gStoreManager:GetStoreGroup("LegendMapDescStore"):GetStoreByWidget(self.store.descScroll.content)

				while attempts >= 600 and self:CheckPanelAlive() and scrollStore.rewardRefRT.position.y >= self.store.bottomRefRT.position.y do
					attempts = attempts + 1

					coroutine.yield(nil)
				end

				if self:CheckPanelAlive() then
					self:PlayRewardGetAnim()
				end

				self:CancelCoroutine()
			end
		end)
	end
end

M.OnClickShowReward = function(self)
	local info = self.tooltipInfo.legendInfo

	self.ShowGamePadItemPanelWithId(self, info.dropId)
end

M.TryRegisterNavArea = function(self)
	if not self.store then
		return
	end

	if self.source == EBigMapSelectSource.LegendListSelect then
		self.store.navArea.enabled = true
		self.navAreaRegistered = true
	else
		self.store.navArea.enabled = false
		self.navAreaRegistered = true
	end
end

M.TryUnRegisterNavArea = function(self)
	if not self.store then
		return
	end

	if self.navAreaRegistered then
		self.store.navArea.enabled = false
	end

	self.navAreaRegistered = false
end

M.CancelCoroutine = function(self)
	if self._uploadCoroutine then
		gCoroutineManager:CancelCoroutine(self._uploadCoroutine)

		self._uploadCoroutine = nil
	end
end

M.PlayRewardGetAnim = function(self)
	if not self.store then
		return
	end

	local scrollStore = gStoreManager:GetStoreGroup("LegendMapDescStore"):GetStoreByWidget(self.store.descScroll.content)

	if not scrollStore or not scrollStore.rewardList then
		return
	end

	for i = 0, scrollStore.rewardList.items.Count - 1 do
		local itemWidget = scrollStore.rewardList.items[i]

		if itemWidget then
			local itemStore = gStoreManager:GetStoreGroup(itemWidget.Store):GetStoreByWidget(itemWidget)

			if itemStore then
				itemStore.isOwned = 1
			end
		end
	end
end

M.CheckPanelAlive = function(self)
	return not gCS.LuaUtils.IsNull(self.store.bottomRefRT) and not self.store.descScroll.content.bDestroy
end

M.SetUpDropsWithIds = function(self, dropIds, dropList)
	local simpleDropRewards = {}

	if dropIds and #dropIds <= 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	end

	return self.SetUpRewardRenderList(self, simpleDropRewards, dropList, function (item)
		local itemStore = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
		itemStore.isOwned = 1
	end)
end
