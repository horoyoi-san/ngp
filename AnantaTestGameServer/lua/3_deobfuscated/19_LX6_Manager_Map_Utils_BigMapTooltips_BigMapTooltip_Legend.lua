local LegendConfig = LTConfig.LegendaryInvestigatorConfig
local BlockConfig = LTConfig.CollectionBlockConfig
local TextConfig = LTConfig.LegendaryInvestigatorTextConfig
C_BigMapTooltip_Legend = DefClass("C_BigMapTooltip_Legend", C_BigMapTooltip_Legend, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Legend
local NOT_UPLOADED = 0
local UPLOADED = 1

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("legendInfo") then
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

function M:SetUpScroll(store, info)
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
		table.insert(self.descInfos, {
			descType = descInfo.descType,
			id = descInfo.descId
		})
	end

	store.descList.onGetTIndex = self.bigMap:CreateAction("OnGetDescTIndex", self)
	store.descList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderDescItem", self)

	store.descList:SetSimpleList(#self.descInfos)
	self:SetUpDropsWithId(info.dropId, store.rewardList)

	store.clickShowRewards = self.bigMap:CreateAction("OnClickShowReward", self)
end

function M:OnActive()
	self:TryRegisterNavArea()

	self._uploadCoroutine = nil
end

function M:OnInActive()
	self:TryUnRegisterNavArea()
	self:CancelCoroutine()
end

function M:RefreshUploadState(store, info)
	self.store.isUploaded = info.uploaded and UPLOADED or NOT_UPLOADED
	self.store.unlockTime = os.date("%Y/%m/%d", info.unlockTime)

	if not info.uploaded then
		store.showUploadBtn = 1
		store.clickUpload = self.bigMap:CreateAction("OnClickUpload", self)
	end
end

function M:SetUpActions(store, actions, blockReason)
	return
end

function M:PretendClick(blockReason, actions)
	self:OnClickUpload()
end

function M:OnClickUpload()
	gMapSubSystem_Legend:UploadArchive(self.tooltipInfo.legendInfo.legendId)

	self.store.showUploadBtn = 0
	self.store.isUploaded = UPLOADED

	self.store.uploadAnim:Play("S_vx_LegendMapTooltip_get")

	self._pendingScrollToBottom = true
end

function M:OnGetDescTIndex(index)
	index = index + 1
	local data = self.descInfos[index]

	return data.descType - 1
end

function M:OnRenderDescItem(btn, index)
	index = index + 1
	local data = self.descInfos[index]

	if data.descType == 1 then
		local store = gStoreManager:GetStoreGroup("LegendListTextStore"):GetStoreByWidget(btn)
		store.descText = TextConfig.GetConfig(data.id).Text
	elseif data.descType == 2 then
		local store = gStoreManager:GetStoreGroup("LegendMapPicStore"):GetStoreByWidget(btn)
		store.iconId = data.id
	elseif data.descType == 3 then
		local store = gStoreManager:GetStoreGroup("LegendMapVideoStore"):GetStoreByWidget(btn)

		store.videoPlayer:Init()
		store.videoPlayer:PlayVideo(data.id, true)
	end
end

local UPDATE_ANIM = "S_Vx_NewCommonItem108_Have"

function M:OnLayoutDescScroll()
	if self._pendingScrollToBottom then
		self._pendingScrollToBottom = false
		self._uploadStartTime = Time.unscaledTime

		gCoroutineManager:StartCoroutine(function ()
			coroutine.yield(gWaitableUtils.WaitTime(0.2))

			if self and self.store and self.store.descScroll then
				self.store.descScroll:GoToPos(Vector2.New(0, 0), true)
				self.store.descScroll:GoToPos(Vector2.New(0, 10000), false)

				local attempts = 0
				local scrollStore = gStoreManager:GetStoreGroup("LegendMapDescStore"):GetStoreByWidget(self.store.descScroll.content)

				while attempts < 600 and self:CheckPanelAlive() and scrollStore.rewardRefRT.position.y < self.store.bottomRefRT.position.y do
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

function M:OnClickShowReward()
	local info = self.tooltipInfo.legendInfo

	self:ShowGamePadItemPanelWithId(info.dropId)
end

function M:TryRegisterNavArea()
	if not self.store then
		return
	end

	if self.source ~= EBigMapSelectSource.LegendListSelect then
		self.store.navArea.enabled = true
		self.navAreaRegistered = true
	else
		self.store.navArea.enabled = false
		self.navAreaRegistered = true
	end
end

function M:TryUnRegisterNavArea()
	if not self.store then
		return
	end

	if self.navAreaRegistered then
		self.store.navArea.enabled = false
	end

	self.navAreaRegistered = false
end

function M:CancelCoroutine()
	if self._uploadCoroutine then
		gCoroutineManager:CancelCoroutine(self._uploadCoroutine)

		self._uploadCoroutine = nil
	end
end

function M:PlayRewardGetAnim()
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
			local itemStore = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(itemWidget)
			itemStore.isOwned = 1

			itemStore.ownAnim:Play(UPDATE_ANIM)
		end
	end
end

function M:CheckPanelAlive()
	return not gCS.LuaUtils.IsNull(self.store.bottomRefRT) and not self.store.descScroll.content.bDestroy
end

function M:SetUpDropsWithIds(dropIds, dropList)
	local simpleDropRewards = {}

	if dropIds and #dropIds > 0 then
		local dropListParam = {}

		for i = 1, #dropIds do
			table.insert(dropListParam, {
				dropId = dropIds[i]
			})
		end

		simpleDropRewards = gCommonItemManager:GetSingleSortedListRenderData(dropListParam)
	end

	if not table.isNilOrEmpty(simpleDropRewards) then
		function dropList.luaSimpleRenderItem(item, index)
			gCommonItemManager:OnCommonItemRender(item, index, simpleDropRewards[index + 1])

			local itemStore = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(item)
			itemStore.isOwned = 1
		end

		dropList:SetSimpleList(#simpleDropRewards)
	end
end
