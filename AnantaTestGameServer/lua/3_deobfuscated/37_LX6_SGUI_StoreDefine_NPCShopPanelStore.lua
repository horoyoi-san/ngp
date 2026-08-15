local NpcShopConfig = LTConfig.ShopConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local CommodityType = LTConfig.ShopCommodityConfig.TypeType
local MessageConfig = LTConfig.MessageConfig
local FactionConfig = LTConfig.FactionConfig
local WeaponConfig = LTConfig.WeaponConfig
local time = Time
C_NPCShopPanelStore = DefClass("C_NPCShopPanelStore", C_NPCShopPanelStore, C_StoreGroup)
GroupName2Class.NPCShopPanelStore = C_NPCShopPanelStore
local M = C_NPCShopPanelStore

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.commodityList.luaSimpleRenderItem = self:CreateAction("OnRenderCommodityItem")
	self.bindData.commodityList.luaSelectedChanged = self:CreateAction("OnCommodityChangeSelect")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRenderTabItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabChangeSelect")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabListPad.luaSimpleRenderItem = self:CreateAction("OnRenderTabItem")
		self.bindData.tabListPad.luaSelectedChanged = self:CreateAction("OnTabChangeSelectPad")
		self.bindData.btnL1Pad.luaPress = self:CreateActionWithArgs("OnTabSwitchChange", -1)
		self.bindData.btnR1Pad.luaPress = self:CreateActionWithArgs("OnTabSwitchChange", 1)
	end

	self.msgEvents = {
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self:CreateAction("OnCommodityInfoChange"),
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("OnPackItemChanged"),
		[gEventConstants.FACTION_LEVEL_CHANGE] = self:CreateAction("OnFactionLevelChange"),
		[gEventConstants.ARMORY_WEAPON_ADD] = self:CreateAction("OnArmoryWeaponAdd"),
		[gEventConstants.CURRENT_WEAPON_SLOT_ADD] = self:CreateAction("OnCurrentWeaponSlotAdd")
	}
	self.ShowType = {
		FALSE = 0,
		TRUE = 1
	}
	self.FACTION_ATTITUDE = {
		COLD = "Hostile",
		WARM = "Friendly",
		NORMAL = "Neutral"
	}
	self.ACTION_TYPE = {
		WELCOME = "Welcome",
		FAREWELL = "Farewell",
		PURCHASE = "Purchase"
	}
	self.factionAttitude = self.FACTION_ATTITUDE.NORMAL

	self:RegisterMessageEvents(self.msgEvents)

	self.scrollInit = false
	self.tipEffectDesc = ""
	self.tipStoryDesc = ""
	self.toolTipStore = self:GetStoreByWidget(self.bindData.toolTipRoot)
	self.toolTipRenderData = {}
	self.updateRefreshStoreList = {}
	self.tabList = {}
	self.hasNpc = false
	self.needRevertCam = false
	self.needUpdateBubble = false
	self.needUpdateStep = false
	self.totalTime = 0
	self.step = 0
	self.cd = false
	self.e = math.exp(1)
	self.commodityRenderData = {}
	self.needUpdateRefresh = false
	self.needUpdateTabRefresh = false
	self.tabRefreshTime = nil
	self.openAnime = "S_vx_NPCShopPanel_open"
	self.closeAnime = "S_vx_NPCShopPanel_close"
	self.weaponPrepared = false
	self.pWeaponQuality = nil
	self.pWeaponName = nil
	self.pWeaponNum = nil
	self.pWeaponId = 0
end

function M:OnGroupEnable()
	self.toolTipStore = self:GetStoreByWidget(self.bindData.toolTipRoot)
	self.toolTipStore.minusBtn.luaLongPress = self:CreateActionWithArgs("OnMinusBtnClick", -1)
	self.toolTipStore.minusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnBtnBeginLongPress", -1)
	self.toolTipStore.minusBtn.luaEndLongPress = self:CreateAction("OnBtnEndLongPress")
	self.toolTipStore.plusBtn.luaLongPress = self:CreateActionWithArgs("OnPlusBtnClick", 1)
	self.toolTipStore.plusBtn.luaBeginLongPress = self:CreateActionWithArgs("OnBtnBeginLongPress", 1)
	self.toolTipStore.plusBtn.luaEndLongPress = self:CreateAction("OnBtnEndLongPress")
	self.toolTipStore.maxBtn.luaClick = self:CreateAction("OnMaxBtnClick")
	self.toolTipStore.buyBtn.luaClick = self:CreateAction("OnBuyBtnClick")
	self.toolTipStore.tagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTagListItem")

	if self.toolTipStore.scrollRect.content then
		self:OnInitContent(self.toolTipStore.scrollRect.content)
	else
		self.toolTipStore.scrollRect.luaInitContent = self:CreateAction("OnInitContent")
	end

	self.toolTipStore.inputField.luaEndEdit = self:CreateAction("OnEndEdit")
	self.toolTipStore.inputField.digitalMax = LTConfig.ShopConfig.BuyLimitOnceMaxNum
end

function M:OnGroupDisable()
	self.toolTipStore = nil
end

function M:OnInitContent(content)
	self.scrollInit = true
	self.scrollStore = self:GetStoreByWidget(content)

	self:RefreshScrollContent()
end

function M:RefreshScrollContent()
	if not self.scrollInit then
		return
	end

	self.scrollStore.tipEffectDesc = self.tipEffectDesc
	self.scrollStore.tipStoryDesc = self.tipStoryDesc
end

function M:SetScrollContent(effect, story)
	self.tipEffectDesc = effect or ""
	self.tipStoryDesc = story or ""

	self:RefreshScrollContent()
end

function M:OnShow(panelId, data)
	self.shopId = data.shopId and tonumber(data.shopId) or tonumber(data[1])

	self:OnInitBefore()

	if not self:CurrShopReady(self.shopId) then
		return
	end

	gShopManager:SetShopIdEnterTime(self.shopId)
	self:OnInitAfter(data)
	self:RefreshCommodityInfo()
end

function M:OnClose()
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	self:ClearWeaponBuyTipsPrepare()
	self:RevertCamera()
	self:PerformTalkAction(self.factionAttitude, self.ACTION_TYPE.FAREWELL)
	gShopManager:NpcShopExitTime(self.shopId)

	self.openTime = nil
	self.isInit = nil
	self.shopId = nil
	self.moneys = nil
	self.factionStore = nil
	self.selectedInfo = nil
	self.selectedGroupId = nil
	self.selectedTabIndex = nil
	self.selectedCommodityIndex = nil
	self.valueChangeCb = nil
	self.buyCb = nil
	self.buyNum = nil
	self.MAX_LIMIT = nil
	self.factionId = nil
	self.hasFaction = nil
	self.FACTION_LEVEL_MAX = nil
	self.scrollInit = nil
	self.scrollStore = nil
	self.tipEffectDesc = nil
	self.tipStoryDesc = nil
	self.commodityRenderData = nil
	self.updateRefreshStoreList = nil
	self.needUpdateRefresh = nil
	self.needUpdateBubble = nil
	self.hasNpc = nil
	self.npcCs = nil
	self.npcTalkCfg = nil
	self.npcActionCfg = nil
	self.npcFocusPoint = nil
	self.toolTipRenderData = nil
	self.needUpdateTabRefresh = false
	self.tabRefreshTime = nil
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.msgEvents = nil
	self.ShowType = nil
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	self:RefreshTabShow()
end

function M:OnUpdate()
	if self.needUpdateRefresh then
		for idx, store in pairs(self.updateRefreshStoreList) do
			store.refreshTime = gShopManager:FormatLeftTime(self.commodityRenderData[idx].RefreshTime)
		end
	end

	if self.needUpdateTabRefresh then
		self.bindData.refreshTime = gShopManager:FormatLeftTime(self.tabRefreshTime)
	end

	if self.needUpdateBuyTips and time.time - self.buyTipsStartTime > 3 then
		self.needUpdateBuyTips = false
		self.bindData.ShowBuyTipsCtrl = self.ShowType.FALSE
		self.bindData.ShowWeaponTipsCtrl = self.ShowType.FALSE
	end

	if self.needUpdateBubble then
		if time.time - self.showBubbleTime > 3 then
			self.needUpdateBubble = false

			gCS.LuaUtils.PlayAnimationByName(self.bindData.bubbleAnime, "S_vx_NPCShopPanel_BUBBLEclose")
		end

		if self.hasNpc then
			local localPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.bubbleRootTrans, self.npcFocusPoint)
			self.bindData.bubbleTrans.localPosition = localPos
		end
	end

	if self.needUpdateStep then
		self:RefreshStep()
	end
end

function M:OnInitBefore()
	self.selectedGroupId = -1
	self.commodityRenderData = nil

	table.clear(self.updateRefreshStoreList)

	self.needUpdateRefresh = false
	self.selectedTabIndex = -1
	self.selectedCommodityIndex = -1
	self.selectedInfo = nil
	self.bindData.showTooltipCtrl = self.ShowType.FALSE
	self.buyCb = self:CreateAction("BuyCallback")
	self.openTime = Time.time
	self.isInit = false
	self.factionId = -1
	self.hasFaction = false
	self.FACTION_LEVEL_MAX = 0

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.openAnime)

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
end

function M:OnInitAfter(data)
	self.bindData.shopName = self.shopCfg.ShopName

	self:BuildTab()
	self:InitFactionInfo()
	self:InitNpcTalkAction(data.focusNpc)
	self:PerformTalkAction(self.factionAttitude, self.ACTION_TYPE.WELCOME)
	self:SetCamera()
end

function M:SetCamera()
	if self.hasNpc then
		self.npcFocusPoint = self.npcCs.PlayerObj.position + Vector3.New(0, self.shopCfg.CameraHeightOffest or 0, 0)

		gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(self.npcFocusPoint, self.shopCfg.CameraActionStatusId or 41, 1)

		self.npcFocusPoint.y = self.npcCs.PlayerObj.position.y + (self.shopCfg.ChatBubbleOffset or 0)
		local localPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.bubbleRootTrans, self.npcFocusPoint)
		self.bindData.bubbleTrans.localPosition = localPos
		self.needRevertCam = true
	end
end

function M:RevertCamera()
	if self.needRevertCam then
		self.needRevertCam = false

		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(1)
	end
end

function M:InitNpcTalkAction(agentNpcCs)
	if agentNpcCs then
		self.hasNpc = true
		self.npcCs = agentNpcCs
		self.npcTalkCfg = LTConfig.ShopNpcTalkConfig.GetConfig(self.shopCfg.TalkId)

		if not self.npcTalkCfg then
			print_error("ShopNpcTalkConfig 取不到配表数据，shopId=", self.shopId, "talkId=", self.shopCfg.TalkId, " 请找策划解决! @zhouxingduan@corp.netease.com")
		end

		self.npcActionCfg = LTConfig.ShopNpcActionConfig.GetConfig(self.shopCfg.ActionId)

		if not self.npcActionCfg then
			print_error("ShopNpcActionConfig 取不到配表数据，shopId=", self.shopId, "actionId=", self.shopCfg.ActionId, " 请找策划解决! @zhouxingduan@corp.netease.com")
		end
	else
		self.hasNpc = false

		print_notice("NpcShop => focusNpc is nil, shopId=", self.shopId)
	end
end

function M:PerformTalkAction(attitude, actionType)
	if not self.hasNpc then
		return
	end

	if self.npcTalkCfg then
		local dialogs = self.npcTalkCfg[attitude .. actionType]

		if dialogs and #dialogs > 0 then
			local dialogId = dialogs[math.random(#dialogs)]

			if dialogId > 0 then
				local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)

				if dialogCfg then
					if actionType ~= self.ACTION_TYPE.FAREWELL then
						self.bindData:Commit("ShowBubbleCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)

						self.needUpdateBubble = true
						self.showBubbleTime = time.time
						self.bindData.bubbleDialog = dialogCfg.Message or ""

						gCS.LuaUtils.PlayAnimationByName(self.bindData.bubbleAnime, "S_vx_NPCShopPanel_BUBBLEopen")
					end

					gShopManager:PlayVoice(dialogCfg.ExternalVoiceId)
				else
					print_error("对话配表取不到商店对话数据，shopId=", self.shopId, "dialogId=", dialogId, " 请找策划解决! @zhouxingduan@corp.netease.com")
				end
			end
		end
	end

	if self.npcActionCfg then
		local actions = self.npcActionCfg[attitude .. actionType .. "Action"]

		if actions and #actions > 0 then
			local actionId = actions[math.random(#actions)]

			if actionId > 0 then
				print_notice("NpcShop => SendGameplayInwardSignal", self.npcCs, actionId)
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.npcCs, actionId)
			end
		end
	end
end

function M:BuildTab()
	local group = self.shopCfg.CommodityGroupIdList

	table.clear(self.tabList)

	for _, groupId in ipairs(group) do
		local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg then
			local tab = {
				groupId = groupId,
				title = groupCfg.GroupName,
				icon = groupCfg.Icon
			}

			if not string.is_null_or_empty(groupCfg.RefreshTime) then
				tab.needRefresh = true
				tab.refreshTime = gCS.LuaUtils.GetNextTime(groupCfg.RefreshTime)
			else
				tab.needRefresh = false
			end

			table.insert(self.tabList, tab)
		end
	end

	if #self.tabList > 1 and self.shopCfg.ShowGroupAll then
		table.insert(self.tabList, 1, {
			groupId = -999,
			needRefresh = false,
			title = NpcShopConfig.GroupAllName,
			icon = NpcShopConfig.GroupAllIcon
		})
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabListPad:SetSimpleList(#self.tabList)
	end

	self:RefreshTabShow()
end

function M:RefreshTabShow()
	local padHasTab = self.gamepadMode and #self.tabList > 1
	self.bindData.PadHasTabCtrl = padHasTab and self.ShowType.TRUE or self.ShowType.FALSE
	local hideTab = self.gamepadMode or #self.tabList <= 1
	self.bindData.HideTabCtrl = hideTab and self.ShowType.TRUE or self.ShowType.FALSE
end

function M:CurrShopReady(shopId)
	self.shopCfg = NpcShopConfig.GetConfig(shopId)

	if not self.shopCfg then
		print_error("NPC商店配置错误，找不到商店配表，请策划 @zhouxingduan@corp.netease.com 检查商店id是否存在，shopId=", shopId)

		return false
	end

	if not gEventConditionUtils.CheckHasUnlocked(self.shopCfg, UX.Game.EventConditionImplModule.Shop) then
		print_error("NPC商店还未解锁，请策划 @zhouxingduan@corp.netease.com 检查商店入口条件配置，shopId=", shopId)

		return false
	end

	return true
end

function M:InitFactionInfo()
	self.factionId = self.shopCfg.BelongFactionId or -1
	self.factionAttitude = self.FACTION_ATTITUDE.NORMAL

	if self.factionId > 0 then
		local factionCfg = FactionConfig.GetConfig(self.factionId)

		if factionCfg then
			self.hasFaction = true
			self.bindData.factionIconId = factionCfg.imageId
		else
			print_error("商店势力找不到势力配表的配置,请策划 @zhouxingduan@corp.netease.com 检查配置 shopId=", self.shopId, "factionId=", self.factionId or "nil")
		end
	else
		print_notice("商店不存在势力 shopId=", self.shopId, "factionId=", self.factionId or "nil")
	end

	self:RefreshFactionAttitude()
end

function M:RefreshFactionAttitude()
	local attitudeIcon = 0

	if self.hasFaction then
		local factionInfo = gPlayerManager.infoAchievement.bindData.FactionInfoDic[self.factionId]

		if factionInfo then
			if factionInfo.DispositionLevel < 3 then
				self.factionAttitude = self.FACTION_ATTITUDE.COLD
			elseif factionInfo.DispositionLevel > 3 then
				self.factionAttitude = self.FACTION_ATTITUDE.WARM
			end

			local cfg = LTConfig.FactionDispositionConfig.GetConfig(factionInfo.DispositionLevel)

			if cfg then
				attitudeIcon = cfg.DispositionIcon or 0
			end

			self.bindData.FactionCtrl = factionInfo.DispositionLevel - 1
		end
	end

	self.bindData.factionAttitudeIcon = attitudeIcon
end

function M:InitMoneyInfo(moneys)
	self.moneys = moneys
	local MoneyTemplateData = {}

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gPlayerItemManager:GetPackItemNum(consumableId)

		table.insert(MoneyTemplateData, {
			Type = consumableId
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(MoneyTemplateData)
end

function M:OnRenderCommodityItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.commodityRenderData[index + 1]

	if store and data then
		store.qualityCtrl = data.Quality
		store.showCountLimitCtrl = data.NoLimit and self.ShowType.FALSE or self.ShowType.TRUE
		store.showNumberCtrl = self.ShowType.FALSE
		store.showTaskWarningCtrl = data.IsTask and self.ShowType.TRUE or self.ShowType.FALSE
		store.singleMoneyLackCtrl = self.moneys[data.Money] < data.PriceCurrent and self.ShowType.TRUE or self.ShowType.FALSE
		store.stateCtrl = data.State
		store.hasDiscountCtrl = data.HasDiscount and self.ShowType.TRUE or self.ShowType.FALSE
		store.discount = data.DiscountDesc
		store.name = data.Name
		store.iconId = data.IconId
		store.priceCurrent = data.PriceCurrent
		store.countLimit = data.RemainByLimit
		store.taskIconId = data.TaskIconId
		store.moneyIconId = data.MoneyIconId
		store.typeCtrl = data.Type
		store.discountTypeCtrl = data.Discount > 100 and self.ShowType.FALSE or self.ShowType.TRUE

		if data.Unlocked and data.SoldOut and data.RefreshTime > 0 then
			store.showRefreshTimeCtrl = self.ShowType.TRUE
			self.updateRefreshStoreList[index + 1] = store
			self.needUpdateRefresh = true
		else
			store.showRefreshTimeCtrl = self.ShowType.FALSE
		end
	end
end

function M:OnCommodityChangeSelect()
	self.selectedCommodityIndex = self.bindData.commodityList.selectedIndex + 1
	self.selectedInfo = self.commodityRenderData[self.selectedCommodityIndex]

	self:RefreshTooltip()
end

function M:OnRenderTabItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.icon = data.icon
	end
end

function M:OnTabChangeSelect()
	self.selectedTabIndex = self.bindData.tabList.selectedIndex + 1

	if self.isInit and self.selectedTabIndex > 0 and self.selectedTabIndex <= #self.tabList then
		local tabInfo = self.tabList[self.selectedTabIndex]
		self.selectedGroupId = tabInfo.groupId
		self.bindData.tabTitle = tabInfo.title
		self.bindData.ShowRefreshTimeCtrl = tabInfo.needRefresh and self.ShowType.TRUE or self.ShowType.FALSE

		if self.selectedGroupId == -999 then
			self.commodityRenderData = {}

			for k, v in pairs(self.groupList) do
				for i = 1, #v do
					table.insert(self.commodityRenderData, v[i])
				end
			end

			gShopManager:SortCommodityList(self.commodityRenderData)
		else
			self.commodityRenderData = self.groupList[self.selectedGroupId] or {}
		end

		table.clear(self.updateRefreshStoreList)

		self.needUpdateRefresh = false
		self.needUpdateTabRefresh = tabInfo.needRefresh
		self.tabRefreshTime = tabInfo.refreshTime

		self.bindData.commodityList:SetSimpleList(#self.commodityRenderData)
		self.bindData.commodityList:GoToIndex(0, true)

		if #self.commodityRenderData == 0 then
			self.bindData.showTooltipCtrl = self.ShowType.FALSE

			print_error("商店分页配置异常，没有配置任何商品，找策划查bug!!! CommodityGroupId=", self.selectedGroupId)
		else
			self.bindData.commodityList:SelectItem(0, true)
		end

		self.bindData.commodityList:PlayStartOffsetAnim()
	else
		self.selectedGroupId = -1
		self.commodityRenderData = nil

		table.clear(self.updateRefreshStoreList)

		self.needUpdateRefresh = false
		self.bindData.ShowRefreshTimeCtrl = self.ShowType.FALSE
		self.needUpdateTabRefresh = false
		self.tabRefreshTime = nil
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.tabListPad.selectedIndex ~= self.selectedTabIndex - 1 then
		self.bindData.tabListPad:SelectItem(self.selectedTabIndex - 1, false)
	end
end

function M:OnTabChangeSelectPad()
	local index = self.bindData.tabListPad.selectedIndex

	self.bindData.tabList:SelectItem(index, true)
end

function M:ForceSelectTab(index)
	if not self.STATE_OnShowOnce then
		return
	end

	if index >= 0 and index < #self.tabList then
		self.bindData.tabList:SelectItem(index, false)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.tabListPad:SelectItem(index, false)
		end
	end
end

function M:OnTabSwitchChange(dir)
	if dir > 0 then
		if self.selectedTabIndex >= #self.tabList then
			return
		end

		self.bindData.tabListPad:SelectItem(self.selectedTabIndex, true)
	else
		if self.selectedTabIndex <= 1 then
			return
		end

		local idx = self.selectedTabIndex - 2

		if idx >= 0 and idx < #self.tabList then
			self.bindData.tabListPad:SelectItem(idx, true)
		end
	end
end

function M:OnSimpleRenderTagListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local data = self.toolTipRenderData[index + 1]

	if store and data then
		store.TypeCtrl = data.TagType
	end
end

function M:RefreshTooltip()
	self.bindData.showTooltipCtrl = self.ShowType.TRUE
	self.toolTipStore.stateCtrl = self.selectedInfo.State
	self.toolTipStore.showCounterCtrl = self.selectedInfo.ShowCount and 1 or 0
	self.toolTipStore.showNumCtrl = self.selectedInfo.ShowNum and 1 or 0

	if self.selectedInfo.ShowNum then
		self.toolTipStore.haveNum = gCommonItemManager:GetItemNum(self.selectedInfo.BindId)
	end

	self.toolTipStore.name = self.selectedInfo.Name
	self.toolTipStore.priceIconId = self.selectedInfo.MoneyIconId
	self.toolTipStore.unlockDescription = self.selectedInfo.UnlockDesc

	self:SetScrollContent(self.selectedInfo.Description, self.selectedInfo.Story)
	self:OnBuyNumChange(1, true)
	table.clear(self.toolTipRenderData)

	if self.selectedInfo.Type == CommodityType.Weapon and self.selectedInfo.Cfg then
		local showCfg = self.selectedInfo.Cfg

		if showCfg.Category == LTConfig.WeaponConfig.CategoryType.Weapon then
			self.toolTipStore.TypeCtrl = self.ShowType.TRUE

			for i = 1, #showCfg.Tags do
				table.insert(self.toolTipRenderData, {
					TagType = showCfg.Tags[i]
				})
			end

			local sixCfg = LTConfig.UrbanAttributeConfig.GetConfig(showCfg.sixDimBonus)
			self.toolTipStore.sixDimName = sixCfg and sixCfg.Name or ""
			self.toolTipStore.sixDimIcon = sixCfg and sixCfg.SIcon or 0

			self.toolTipStore.tagList:SetSimpleList(#self.toolTipRenderData)
			self:SetSkillAndRadarChartInfo(showCfg)
		elseif showCfg.Category == LTConfig.WeaponConfig.CategoryType.Item then
			self.toolTipStore.TypeCtrl = self.ShowType.FALSE
		end
	else
		self.toolTipStore.TypeCtrl = self.ShowType.FALSE
	end
end

function M:SetSkillAndRadarChartInfo(cfg)
	local fill = 0
	local text = ""
	fill = Mathf.Clamp01((cfg.AttackPower or 0) / WeaponConfig.MaxWeaponAttackPower) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(0, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(0, text)

	fill = Mathf.Clamp01((cfg.AttackRange or 0) / WeaponConfig.MaxWeaponAttackRange) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(1, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(1, text)

	fill = Mathf.Clamp01(cfg.AttackSpeed / WeaponConfig.MaxWeaponAttackSpeed) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(2, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(2, text)

	fill = Mathf.Clamp01((cfg.PoiseAbility or 0) / WeaponConfig.MaxWeaponPoiseAbility) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(3, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(3, text)

	fill = Mathf.Clamp01(cfg.ImpactForce / WeaponConfig.MaxWeaponImpactForce) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(4, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(4, text)

	if cfg.Durability <= 0 then
		fill = 100
	elseif cfg.ShootId and cfg.ShootId > 0 then
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxGunDurability) * 100
	else
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxWeaponDurability) * 100
	end

	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(5, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(5, text)
end

function M:OnBuyNumChange(val, changeInputText)
	if changeInputText then
		self.toolTipStore.inputField.text = val
	end

	self.buyNum = val

	if val <= 1 then
		self.toolTipStore.minusBtn.interactable = false

		self:OnBtnEndLongPress()
	else
		self.toolTipStore.minusBtn.interactable = true
	end

	if val == self.selectedInfo.LimitOnceNum or val == self.selectedInfo.RemainNum then
		self.toolTipStore.plusBtn.interactable = false

		self:OnBtnEndLongPress()
	else
		self.toolTipStore.plusBtn.interactable = true
	end

	local totalBuy = self.buyNum * self.selectedInfo.PriceCurrent
	self.toolTipStore.price = totalBuy
	local enough = totalBuy <= self.moneys[self.selectedInfo.Money]
	self.toolTipStore.MoneyNotEnoughCtrl = enough and self.ShowType.FALSE or self.ShowType.TRUE

	if self.selectedInfo.NoLimit then
		self.toolTipStore.buyBtn.interactable = enough
	else
		self.toolTipStore.buyBtn.interactable = enough and val <= self.selectedInfo.RemainNum
	end

	gSoundMgr:PlaySoundByTid(70601314)
end

function M:OnMinusBtnClick(step)
	step = math.ceil(step)
	local toNum = self.buyNum + step

	if toNum < 1 then
		toNum = 1
	end

	if self.buyNum ~= toNum then
		self:OnBuyNumChange(toNum, true)
	end
end

function M:OnBtnBeginLongPress(step)
	self.totalTime = 0
	self.step = step
	self.cd = false

	self:RefreshStep()

	self.needUpdateStep = true
end

function M:OnBtnEndLongPress()
	self.totalTime = 0
	self.step = 0
	self.needUpdateStep = false
end

function M:RefreshStep()
	self.totalTime = self.totalTime + Time.deltaTime

	if self.totalTime < 0.5 then
		if self.cd == false then
			if self.step < 0 then
				self:OnMinusBtnClick(self.step)
			else
				self:OnPlusBtnClick(self.step)
			end

			self.cd = true
		end

		return
	end

	local step = self.step * self.e^(self.totalTime * 0.2)

	if self.step < 0 then
		self:OnMinusBtnClick(step)
	else
		self:OnPlusBtnClick(step)
	end
end

function M:OnPlusBtnClick(step)
	step = math.floor(step)
	local toNum = self.buyNum + step
	toNum = math.min(toNum, self.selectedInfo.LimitOnceNum)

	if not self.selectedInfo.NoLimit then
		toNum = math.min(toNum, self.selectedInfo.RemainNum)
	end

	if self.buyNum ~= toNum then
		self:OnBuyNumChange(toNum, true)
	end
end

function M:OnMaxBtnClick()
	local buyNum = self.selectedInfo.LimitOnceNum
	local tempNum = math.floor(self.moneys[self.selectedInfo.Money] / self.selectedInfo.PriceCurrent)

	if tempNum < buyNum then
		buyNum = tempNum
	end

	if not self.selectedInfo.NoLimit then
		tempNum = self.selectedInfo.RemainNum

		if tempNum < buyNum then
			buyNum = tempNum
		end
	end

	if buyNum < 1 then
		buyNum = 1
	end

	self:OnBuyNumChange(buyNum, true)
end

function M:OnBuyBtnClick()
	if not self.selectedInfo then
		print_error("商品信息不存在，selectedGroupId=", self.selectedGroupId, "selectedCommodityIndex=", self.selectedCommodityIndex)

		return
	end

	if self.selectedInfo.SoldOut then
		return
	elseif self.buyNum > 0 then
		local totalBuy = self.buyNum * self.selectedInfo.PriceCurrent

		if self.moneys[self.selectedInfo.Money] < totalBuy then
			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyNotEnoughMoney)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, self.buyCb, nil, totalBuy, string.format(" %s x %s ", self.buyNum, self.selectedInfo.Name))
		end
	end
end

function M:BuyCallback()
	if self.selectedInfo and self.buyNum > 0 and self.buyNum * self.selectedInfo.PriceCurrent <= self.moneys[self.selectedInfo.Money] then
		local name = self.selectedInfo.Name
		local num = self.buyNum
		local quality = self.selectedInfo.Quality
		local isWeapon = self.selectedInfo.Type == CommodityType.Weapon

		if isWeapon and self.selectedInfo.BindId and self.selectedInfo.BindId > 0 then
			self:WeaponBuyTipsPrepare(name, num, quality, self.selectedInfo.BindId)
		end

		gClientToGameDelegate:AskBuyCommodity(self.selectedInfo.CommodityId, self.buyNum).Callback = function (err)
			if err == MessageConfig.Ok then
				if self.STATE_OnShowOnce then
					if not isWeapon then
						self:ClearWeaponBuyTipsPrepare()
						self:ShowBuyTips(name, num, quality)
					end

					self:RefreshMoneyInfo()
					self:RefreshCommodityInfo()
					self:PerformTalkAction(self.factionAttitude, self.ACTION_TYPE.PURCHASE)
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

function M:ShowBuyTips(name, num, quality)
	self.needUpdateBuyTips = true
	self.buyTipsStartTime = Time.time

	self.bindData:Commit("ShowBuyTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)
	self.bindData:Commit("ShowWeaponTipsCtrl", self.ShowType.FALSE, COMMIT_IMMEDIATELY)

	self.bindData.buyTipsName = name .. " x" .. num
	self.bindData.QualityCtrl = quality

	gCS.LuaUtils.PlayAnimation(self.bindData.buyTipAnime)
end

function M:WeaponBuyTipsPrepare(name, num, quality, weaponTemplateId)
	self.weaponPrepared = true
	self.pWeaponName = name
	self.pWeaponNum = num
	self.pWeaponQuality = quality
	self.pWeaponId = weaponTemplateId
end

function M:ClearWeaponBuyTipsPrepare()
	self.weaponPrepared = false
	self.pWeaponName = nil
	self.pWeaponNum = nil
	self.pWeaponQuality = nil
	self.pWeaponId = 0
end

function M:ShowWeaponBuyTips(name, num, quality, weaponText)
	self.needUpdateBuyTips = true
	self.buyTipsStartTime = Time.time

	self.bindData:Commit("ShowBuyTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)
	self.bindData:Commit("ShowWeaponTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)

	self.bindData.buyTipsName = name .. " x" .. num
	self.bindData.weaponTipsName = weaponText
	self.bindData.QualityCtrl = quality

	gCS.LuaUtils.PlayAnimation(self.bindData.buyTipAnime)
end

function M:OnEndEdit(text)
	local val = tonumber(text) or 1

	self:OnBuyNumChange(val, text ~= tostring(val))
end

function M:OnBackBtnClick()
	if self.closeTimer then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.closeAnime)

	gClientToGameDelegate:AskCloseNpcShop(self.shopId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		gPanelManager:Close(gPanelId.S_NPC_SHOP_PANEL)
	end, self.bindData.anime:GetClip(self.closeAnime).length):Start()
end

function M:RefreshCommodityInfo()
	gShopManager:GetGroupCommodityInfo(self.shopId, self:CreateAction("OnRefreshCommodityInfo"))
end

function M:OnRefreshCommodityInfo(success, groupList, groupDict, data)
	if not self.STATE_OnShowOnce then
		return
	end

	if success then
		if not self.isInit then
			self.isInit = true

			self:InitMoneyInfo(data.Moneys)
			self:ForceSelectTab(0)
		end

		local currDiscount = ""

		if data.CurrentDiscount then
			if data.CurrentDiscount < NpcShopConfig.ShopFactionDiscountTextSeparatedValue then
				currDiscount = gString.Format(NpcShopConfig.FactionDiscountText[1], NpcShopConfig.ShopFactionDiscountTextSeparatedValue - data.CurrentDiscount)
			elseif data.CurrentDiscount == NpcShopConfig.ShopFactionDiscountTextSeparatedValue then
				currDiscount = NpcShopConfig.FactionDiscountText[2]
			else
				currDiscount = gString.Format(NpcShopConfig.FactionDiscountText[3], data.CurrentDiscount - NpcShopConfig.ShopFactionDiscountTextSeparatedValue)
			end
		end

		self.bindData.factionDiscount = currDiscount
		self.groupList = groupList
		self.groupDict = groupDict

		self:OnTabChangeSelect()
	end
end

function M:RefreshMoneyInfo()
	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gPlayerItemManager:GetPackItemNum(consumableId)
	end
end

function M:OnPackItemChanged()
	if not self.STATE_OnShowOnce then
		return
	end

	self:RefreshMoneyInfo()
	self.bindData.commodityList:RefreshList()
	self:OnBuyNumChange(self.buyNum, true)
end

function M:OnFactionLevelChange(eventId, factionId)
	if self.STATE_OnShowOnce and self.factionId == factionId then
		self:RefreshCommodityInfo()
		self:RefreshFactionAttitude()
	end
end

function M:OnCommodityInfoChange(eventId, infos)
	if self.STATE_OnShowOnce then
		self:RefreshCommodityInfo()
	end
end

function M:OnArmoryWeaponAdd(eventId, data)
	if self.weaponPrepared and self.pWeaponId == data.TemplateId then
		self:ShowWeaponBuyTips(self.pWeaponName, self.pWeaponNum, self.pWeaponQuality, NpcShopConfig.WeaponStoredText)
		self:ClearWeaponBuyTipsPrepare()
	end
end

function M:OnCurrentWeaponSlotAdd(eventId, data)
	if self.weaponPrepared and self.pWeaponId == data.Weapon.TemplateId then
		self:ShowWeaponBuyTips(self.pWeaponName, self.pWeaponNum, self.pWeaponQuality, NpcShopConfig.WeaponAddedToWheelText)
		self:ClearWeaponBuyTipsPrepare()
	end
end
