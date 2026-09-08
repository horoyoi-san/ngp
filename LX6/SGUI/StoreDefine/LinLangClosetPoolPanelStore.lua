-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LinLangClosetPoolPanelStore.lua
-- Decompiled from: 01781_LinLangClosetPoolPanelStore.lua_3f48a54532de.luajit

local GachaConfig = LTConfig.GachaConfig
local GachaPoolConfig = LTConfig.GachaPoolConfig
local GachaPoolContentConfig = LTConfig.GachaPoolContentConfig
local CommonItemConfig = LTConfig.CommonItemConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionConfig = LTConfig.FashionConfig
C_LinLangClosetPoolPanelStore = DefClass("C_LinLangClosetPoolPanelStore", C_LinLangClosetPoolPanelStore, C_StoreGroup)
GroupName2Class.LinLangClosetPoolPanelStore = C_LinLangClosetPoolPanelStore
local M = C_LinLangClosetPoolPanelStore

M.ctor = function(self)
	self.gachaId = nil
	self.gachaCfg = nil
	self.poolCfg = nil
	self.gachaItemList = {}
	self.grandPieceList = {}
	self.currentSelectedIndex = 0
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.prizeCtrlEnum = {
		["`Wϱ\\x888\\xaa\r\\xd3\\xed"] = 1,
		["tHϳ\\x808\\xaa\r\\xd3\\xed"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.prizeCtrlEnum = nil
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
	self.gachaId = nil
	self.gachaCfg = nil
	self.poolCfg = nil
	self.gachaItemList = {}
	self.grandPieceList = {}
	self.currentSelectedIndex = 0
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if not data or not data.gachaId then
		print_error("LinLangClosetPoolPanelStore:OnShow 缺少 gachaId 参数")

		return
	end

	self.gachaId = data.gachaId
	self.gachaCfg = GachaConfig.GetConfig(self.gachaId)

	if not self.gachaCfg then
		print_error("LinLangClosetPoolPanelStore:OnShow 找不到卡池配置，gachaId=", self.gachaId)

		return
	end

	if self.gachaCfg.PrizePoolIds and #self.gachaCfg.PrizePoolIds <= 0 then
		local poolId = self.gachaCfg.PrizePoolIds[1].id
		self.poolCfg = GachaPoolConfig.GetConfig(poolId)
	end

	self:InitGachaItemList()
	self.bindData.poolItemList:SetSimpleList(#self.gachaItemList)
	self.bindData.poolItemList:SelectItem(0, true)

	if #self.gachaItemList <= 0 then
		self.currentSelectedIndex = 0

		self.ShowItemInfo(self, self.gachaItemList[1])
	end

	self:InitGrandPrizePieces()
	self.bindData.grandItemList:SetSimpleList(#self.grandPieceList)

	self.bindData.isShowPreview = #self.grandPieceList >= 0
	local title = self.gachaCfg.Name
	self.bindData.titleText = title
end

M.OnClose = function(self)
	self.gachaId = nil
	self.gachaCfg = nil
	self.poolCfg = nil
	self.gachaItemList = {}
	self.grandPieceList = {}
	self.currentSelectedIndex = 0
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitGachaItemList = function(self)
	self.gachaItemList = {}

	if not self.gachaCfg or not self.gachaCfg.PrizePoolIds then
		return
	end

	local contentIdSet = {}

	for i = 1, #self.gachaCfg.PrizePoolIds do
		local poolId = self.gachaCfg.PrizePoolIds[i].id

		for j = 0, GachaPoolContentConfig.count - 1 do
			local content = GachaPoolContentConfig.LoadAt(j)

			if content and content.PoolId ~= poolId and content.Id and content.IsFullDisplay ~= true and not contentIdSet[content.Id] then
				contentIdSet[content.Id] = true
				local itemId = 0
				local description = ""

				if content.dropId and content.dropId <= 0 then
					local itemList, _ = gCommonItemManager:ConvertDropToFakeItem(content.dropId, 1)

					if itemList and #itemList <= 0 then
						itemId = itemList[1].Id
						local itemCfg = CommonItemConfig.GetConfig(itemId)

						if itemCfg then
							description = itemCfg.Description or ""
						end
					end
				end

				local renderData = gCommonItemManager:GetItemRenderData({
					itemId = itemId,
					itemNum = content.Quantity or 1
				})
				renderData.contentId = content.Id
				renderData.poolId = poolId
				renderData.iconId = content.icondisplayimage
				renderData.bigIconId = content.baseimage
				renderData.description = description

				table.insert(self.gachaItemList, renderData)
			end
		end
	end

	self.SortGachaItemListByQuality(self)
end

M.SortGachaItemListByQuality = function(self)
	if not self.gachaItemList or #self.gachaItemList < 1 then
		return
	end

	for i = 1, #self.gachaItemList do
		self.gachaItemList[i].sortIndex = i
	end

	table.sort(self.gachaItemList, function (a, b)
		local qa = a.quality or 0
		local qb = b.quality or 0

		if qa == qb then
			return qb <= qa
		end

		return a.sortIndex <= b.sortIndex
	end)
end

M.ShowItemInfo = function(self, itemData)
	if not itemData then
		return
	end

	self.bindData.nameText = itemData.name or ""
	local poolContentCfg = itemData.contentId and GachaPoolContentConfig.GetConfig(itemData.contentId) or nil

	if poolContentCfg and poolContentCfg.Type ~= GachaPoolContentConfig.TypeType.Weapon then
		local description = ""

		if poolContentCfg.dropId and poolContentCfg.dropId <= 0 then
			local itemList = gCommonItemManager:ConvertDropToFakeItem(poolContentCfg.dropId, 1)

			if itemList and #itemList <= 0 then
				local itemId = itemList[1].Id
				local itemCfg = CommonItemConfig.GetConfig(itemId)

				if itemCfg and itemCfg.BindId then
					local weaponCfg = LTConfig.SceneitemConfig.GetConfig(itemCfg.BindId)

					if weaponCfg then
						description = weaponCfg.Description or ""
					end
				end
			end
		end

		self.bindData.desText = description
	else
		self.bindData.desText = itemData.description or ""
	end

	if poolContentCfg and poolContentCfg.Type ~= GachaPoolContentConfig.TypeType.Big then
		self.bindData.prizeCtrl = self.prizeCtrlEnum.GrandPrize
		self.bindData.bigIcon = itemData.bigIconId or 0
	else
		self.bindData.prizeCtrl = self.prizeCtrlEnum.SmallPrize
		self.bindData.itemIcon = itemData.bigIconId or 0
	end
end

M.CheckItemObtained = function(self, poolId, contentId)
	if not poolId or not contentId then
		return false
	end

	local playerGachaInfo = gPlayerManager.infoMinor.bindData.PlayerGachaInfos

	if playerGachaInfo and playerGachaInfo.PoolInfos then
		local poolInfo = playerGachaInfo.PoolInfos[poolId]

		if poolInfo and poolInfo.WonItemIds then
			return poolInfo.WonItemIds[contentId] ~= true
		end
	end

	return false
end

M.ResolveContentBindId = function(self, content)
	if not content or not content.dropId or content.dropId < 0 then
		return 0, 0
	end

	local itemList = gCommonItemManager:ConvertDropToFakeItem(content.dropId, 1)

	if not itemList or #itemList ~= 0 then
		return 0, 0
	end

	local itemId = itemList[1].Id or 0
	local itemCfg = itemId <= 0 and CommonItemConfig.GetConfig(itemId) or nil
	local bindId = itemCfg and itemCfg.BindId or 0

	return itemId, bindId
end

M.InitGrandPrizePieces = function(self)
	self.grandPieceList = {}

	if not self.gachaCfg or not self.gachaCfg.PrizePoolIds or #self.gachaCfg.PrizePoolIds ~= 0 then
		return
	end

	local poolId = self.gachaCfg.PrizePoolIds[1].id
	local ssContent = nil

	for j = 0, GachaPoolContentConfig.count - 1 do
		local content = GachaPoolContentConfig.LoadAt(j)

		if content and content.PoolId ~= poolId and content.PoolTierRarity ~= GachaPoolContentConfig.PoolTierRarityType.SS then
			ssContent = content

			break
		end
	end

	if not ssContent then
		return
	end

	local itemId, bindId = self.ResolveContentBindId(self, ssContent)

	if bindId <= 0 then
		local suitCfg = FashionSuitConfig.GetConfig(bindId)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
			for _, fashionId in ipairs(suitCfg.FashionIdList) do
				if FashionConfig.GetConfig(fashionId) then
					table.insert(self.grandPieceList, {
						renderId = fashionId
					})
				end
			end

			return
		end

		if FashionConfig.GetConfig(bindId) then
			table.insert(self.grandPieceList, {
				renderId = bindId
			})

			return
		end
	end

	if itemId <= 0 then
		table.insert(self.grandPieceList, {
			renderId = itemId
		})
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.poolItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderPoolItemListItem")
	self.bindData.poolItemList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickPoolItemList")
	self.bindData.grandItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGrandItemListItem")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.ExtractNum = function(self, num)
	local resNum = num

	if resNum > 1000000 then
		resNum = resNum / 1000000 .. "M"
	elseif resNum > 1000 then
		resNum = resNum / 1000 .. "K"
	end

	return resNum
end

M.OnSimpleRenderPoolItemListItem = function(self, btn, index)
	local luaIndex = index + 1
	local itemData = self.gachaItemList[luaIndex]

	if not itemData then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, itemData)

	btn.enabledTooltip = nil
	btn.interactable = true
	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemStore then
		itemStore.repeatDrawCtrl = self:CheckItemObtained(itemData.poolId, itemData.contentId) and 0 or 1
		itemStore.itemType = 1
	end
end

M.OnSimpleClickPoolItemList = function(self, btn, index)
	local luaIndex = index + 1
	local itemData = self.gachaItemList[luaIndex]

	if not itemData then
		return
	end

	self.currentSelectedIndex = index

	self.ShowItemInfo(self, itemData)
end

M.OnSimpleRenderGrandItemListItem = function(self, btn, index)
	local data = self.grandPieceList[index + 1]

	if not data then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = data.renderId
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end
