-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NPCShopPanelStore.lua
-- Decompiled from: 00935_NPCShopPanelStore.lua_41ab87717248.luajit

local NpcShopConfig = LTConfig.ShopConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local MessageConfig = LTConfig.MessageConfig
local FactionConfig = LTConfig.FactionConfig
local time = Time
local moneyIconText = "#C(jinyuebi_Text)"
C_NPCShopPanelStore = DefClass("C_NPCShopPanelStore", C_NPCShopPanelStore, C_StoreGroup)
GroupName2Class.NPCShopPanelStore = C_NPCShopPanelStore
local M = C_NPCShopPanelStore

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.factionDiscountBtn.luaRenderTooltip = self.CreateAction(self, "OnFactionDiscountBtnRenderTooltip")
	self.bindData.commodityList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderCommodityItem")
	self.bindData.commodityList.onGetTIndex = self.CreateAction(self, "OnGetCommodityItemTemplate")
	self.bindData.commodityList.luaSelectedChanged = self.CreateAction(self, "OnCommodityChangeSelect")
	self.tabRenderCb = self.CreateAction(self, "OnRenderTabItem")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabListPad.luaSimpleRenderItem = self.tabRenderCb
		self.bindData.tabListPad.luaSelectedChanged = self.CreateAction(self, "OnTabChangeSelectPad")
		self.bindData.btnL1Pad.luaPress = self.CreateActionWithArgs(self, "OnTabSwitchChange", -1)
		self.bindData.btnR1Pad.luaPress = self.CreateActionWithArgs(self, "OnTabSwitchChange", 1)
	end

	self.msgEvents = {
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self.CreateAction(self, "OnCommodityInfoChange"),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.FACTION_LEVEL_CHANGE] = self.CreateAction(self, "OnFactionLevelChange"),
		[gEventConstants.ARMORY_WEAPON_ADD] = self.CreateAction(self, "OnArmoryWeaponAdd"),
		[gEventConstants.CURRENT_WEAPON_SLOT_ADD] = self.CreateAction(self, "OnCurrentWeaponSlotAdd")
	}
	self.ShowType = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.FACTION_ATTITUDE = {
		["Y\rQ"] = "\\xf1\\xd4\t(\\xf4",
		["MOv"] = "\\x8d\\xa3\\xaed:\\xf2*",
		["2g\\xa3\\xa3\\xa2m"] = "\\xf7\\xde\t%\\xfd"
	}
	self.ACTION_TYPE = {
		["\\xee\\xfe8>1\t\\xd4"] = "\\xee\\xde)\\xf4",
		["\\x8d\\x907\\x8e]\\xd2"] = "\\x8d\\xb0\\xae};\\xf2?",
		["\\x9b\\x847\\x88B\\xcd"] = "\\x9b\\xa4\\xa8b?\\xed6"
	}
	self.SHOP_TYPE = {
		["e\\x81\\x97\\x9c\\x93"] = 7,
		["MZ\\x8dTg\\x8d\\xdffXQ[x"] = 6,
		["\\xa9[\\xb1d\\xe6\\x86\\x9d"] = 3,
		["\\xa0XE"] = 1,
		["\\xa9[\\xb1d\\xe6\\x8f\\x8e"] = 4,
		["#\\xa4ߊ\\x84܏\\x95\\xa6\\xe2\\xd1\\xe9\\xb5\\xba\\xd0"] = 8,
		["\\xff\\xfa'57\\xdf"] = 2,
		["BY\\x88^j\\x9b\\xd1f^SQb"] = 5
	}
	self.factionAttitude = self.FACTION_ATTITUDE.NORMAL

	self.RegisterMessageEvents(self, self.msgEvents)

	self.scrollInit = false
	self.tipEffectDesc = ""
	self.tipStoryDesc = ""
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
	self.needUpdateShopRefresh = false
	self.shopRefreshTime = nil
	self.openAnime = "S_vx_NPCShopPanel_open"
	self.closeAnime = "S_vx_NPCShopPanel_close"
	self.weaponPrepared = false
	self.pWeaponQuality = nil
	self.pWeaponName = nil
	self.pWeaponNum = nil
	self.pWeaponId = 0
	self.buyBtnCb = self.CreateAction(self, "OnBuyBtnClick")
	self.luaRenderTooltipCb = self.CreateAction(self, "LuaOnRenderToolTip")
	self.luaTooltipPopupCb = self.CreateAction(self, "LuaOnTooltipPopup")
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local showData = nil

	if not data then
		showData = {}
	elseif type(data) ~= "number" or type(data) ~= "string" then
		showData = {
			shopId = tonumber(data)
		}
	else
		showData = data
	end

	self.shopId = showData.shopId and tonumber(showData.shopId) or tonumber(showData[1])
	showData.shopId = self.shopId

	self:OnInitBefore()

	if not self:CurrShopReady(self.shopId) then
		return
	end

	gShopManager:SetShopIdEnterTime(self.shopId)
	self:OnInitAfter(showData)
	self:RefreshCommodityInfo()

	if self.shopCfg.CanSell then
		self.bindData.showBackBtnCtrl = self.ShowType.FALSE

		gPanelManager:CheckShow(gPanelId.NPC_SHOP_SWITCH_PANEL, showData)
	else
		self.bindData.showBackBtnCtrl = self.ShowType.TRUE
	end

	if showData.ShopSwitch then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, "S_vx_NPCShopPanel_back")
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, "S_vx_NPCShopPanel_open")
	end
end

M.OnClose = function(self)
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	self:ClearWeaponBuyTipsPrepare()
	self:RevertCamera()
	self:PerformTalkAction(self.factionAttitude, self.ACTION_TYPE.FAREWELL)
	gShopManager:NpcShopExitTime(self.shopId)

	if self.shopId then
		gClientToGameDelegate:AskCloseNpcShop(self.shopId)
	end

	self.openTime = nil
	self.isInit = nil
	self.shopId = nil
	self.shopType = nil
	self.moneys = nil
	self.factionStore = nil
	self.selectedInfo = nil
	self.selectedGroupId = nil
	self.selectedTabIndex = nil
	self.selectedCommodityIndex = nil
	self.valueChangeCb = nil
	self.buyCb = nil
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
	self.needUpdateShopRefresh = false
	self.shopRefreshTime = nil
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.msgEvents = nil
	self.ShowType = nil
	self.luaRenderTooltipCb = nil
	self.luaTooltipPopupCb = nil
	self.tabRenderCb = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	self:RefreshTabShow()
end

M.OnUpdate = function(self)
	if self.needUpdateRefresh then
		for idx, store in pairs(self.updateRefreshStoreList) do
			store.refreshTime = gShopManager:FormatLeftTime(self.commodityRenderData[idx].RefreshTime)
		end
	end

	if self.needUpdateShopRefresh then
		self.bindData.refreshTime = gShopManager:FormatLeftTime(self.shopRefreshTime)
	end

	if self.needUpdateBuyTips and time.time - self.buyTipsStartTime <= 3 then
		self.needUpdateBuyTips = false
		self.bindData.ShowBuyTipsCtrl = self.ShowType.FALSE
		self.bindData.ShowWeaponTipsCtrl = self.ShowType.FALSE
	end

	if self.needUpdateBubble then
		if time.time - self.showBubbleTime <= 3 then
			self.needUpdateBubble = false

			gCS.LuaUtils.PlayAnimationByName(self.bindData.bubbleAnime, "S_vx_NPCShopPanel_BUBBLEclose")
		end

		if self.hasNpc then
			local localPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.bubbleRootTrans, self.npcFocusPoint)
			self.bindData.bubbleTrans.localPosition = localPos
		end
	end

	if self.needUpdateStep then
		self.RefreshStep(self)
	end
end

M.OnInitBefore = function(self)
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

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.OnInitAfter = function(self, data)
	self.bindData.shopName = self.shopCfg.ShopName

	self.BuildTab(self)
	self.InitFactionInfo(self)
	self.InitNpcTalkAction(self, data.focusNpc)
	self.PerformTalkAction(self, self.factionAttitude, self.ACTION_TYPE.WELCOME)
	self.SetCamera(self)
end

M.SetCamera = function(self)
	if self.hasNpc then
		self.npcFocusPoint = self.npcCs.PlayerObj.position + Vector3.New(0, self.shopCfg.CameraHeightOffest or 0, 0)

		gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(self.npcFocusPoint, self.shopCfg.CameraActionStatusId or 41, 1)

		self.npcFocusPoint.y = self.npcCs.PlayerObj.position.y + (self.shopCfg.ChatBubbleOffset or 0)
		local localPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.bubbleRootTrans, self.npcFocusPoint)
		self.bindData.bubbleTrans.localPosition = localPos
		self.needRevertCam = true
	end
end

M.RevertCamera = function(self)
	if self.needRevertCam then
		self.needRevertCam = false

		gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook(1)
	end
end

M.InitNpcTalkAction = function(self, agentNpcCs)
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

M.PerformTalkAction = function(self, attitude, actionType)
	if not self.hasNpc then
		return
	end

	if self.npcTalkCfg then
		local dialogs = self.npcTalkCfg[attitude .. actionType]

		if dialogs and #dialogs <= 0 then
			local dialogId = dialogs[math.random(#dialogs)]

			if dialogId <= 0 then
				local dialogCfg = LTConfig.DialogConfig.GetConfig(dialogId)

				if dialogCfg then
					if actionType == self.ACTION_TYPE.FAREWELL then
						self.bindData:Commit("ShowBubbleCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)

						self.needUpdateBubble = true
						self.showBubbleTime = time.time
						self.bindData.bubbleDialog = dialogCfg.Message or ""

						gCS.LuaUtils.PlayAnimationByName(self.bindData.bubbleAnime, "S_vx_NPCShopPanel_BUBBLEopen")
					end

					local externalVoiceId = gDialogManager:GetExternalVoiceId(dialogCfg.Id)

					gShopManager:PlayVoice(externalVoiceId)
				else
					print_error("对话配表取不到商店对话数据，shopId=", self.shopId, "dialogId=", dialogId, " 请找策划解决! @zhouxingduan@corp.netease.com")
				end
			end
		end
	end

	if self.npcActionCfg then
		local actions = self.npcActionCfg[attitude .. actionType .. "Action"]

		if actions and #actions <= 0 then
			local actionId = actions[math.random(#actions)]

			if actionId <= 0 and self.npcCs then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(self.npcCs, actionId)
			end
		end
	end
end

M.BuildTab = function(self)
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

			table.insert(self.tabList, tab)
		end
	end

	if #self.tabList <= 1 and self.shopCfg.ShowGroupAll then
		table.insert(self.tabList, 1, {
			["\\xde\\xc9\r\\xf5"] = -999,
			title = NpcShopConfig.GroupAllName,
			icon = NpcShopConfig.GroupAllIcon
		})
	end

	self.SubGroup.CommonTabSingleStore:SetSimpleData(#self.tabList, nil, , , self:CreateAction("OnTabChangeSelect"), self.tabRenderCb)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.tabListPad:SetSimpleList(#self.tabList)
	end

	self.RefreshTabShow(self)
end

M.RefreshTabShow = function(self)
	local padHasTab = self.gamepadMode and #self.tabList >= 1
	self.bindData.PadHasTabCtrl = padHasTab and self.ShowType.TRUE or self.ShowType.FALSE
	local hideTab = self.gamepadMode or #self.tabList > 1
	self.bindData.HideTabCtrl = hideTab and self.ShowType.TRUE or self.ShowType.FALSE
end

M.CurrShopReady = function(self, shopId)
	self.shopCfg = NpcShopConfig.GetConfig(shopId)

	if not self.shopCfg then
		print_error("NPC商店配置错误，找不到商店配表，请策划 @zhouxingduan@corp.netease.com 检查商店id是否存在，shopId=", shopId)

		return false
	end

	if not gEventConditionUtils.CheckHasUnlocked(self.shopCfg, UX.Game.EventConditionImplModule.Shop) then
		print_error("NPC商店还未解锁，请策划 @zhouxingduan@corp.netease.com 检查商店入口条件配置，shopId=", shopId)

		return false
	end

	self.shopType = self.shopCfg.ShopType or 0

	self:InitShopRefreshTime()

	return true
end

M.InitShopRefreshTime = function(self)
	local cronExpr = self.shopCfg.ManualRefreshCountResetTime
	local hasShopRefresh = cronExpr and cronExpr == ""
	self.needUpdateShopRefresh = hasShopRefresh

	if hasShopRefresh then
		self.shopRefreshTime = gCS.LuaUtils.GetNextTime(cronExpr)
	else
		self.shopRefreshTime = nil
	end

	self.bindData.ShowRefreshTimeCtrl = hasShopRefresh and self.ShowType.TRUE or self.ShowType.FALSE
end

M.InitFactionInfo = function(self)
	self.factionId = self.shopCfg.BelongFactionId or -1
	self.factionAttitude = self.FACTION_ATTITUDE.NORMAL

	if self.factionId <= 0 then
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

	self.RefreshFactionAttitude(self)
end

M.RefreshFactionAttitude = function(self)
	if self.hasFaction then
		local factionInfo = gPlayerManager.infoAchievement.bindData.FactionInfoDic[self.factionId]

		if factionInfo then
			if factionInfo.DispositionLevel >= 3 then
				self.factionAttitude = self.FACTION_ATTITUDE.COLD
			elseif factionInfo.DispositionLevel <= 3 then
				self.factionAttitude = self.FACTION_ATTITUDE.WARM
			end

			self.bindData.FactionCtrl = factionInfo.DispositionLevel - 1
		end
	end
end

M.InitMoneyInfo = function(self, moneys)
	self.moneys = moneys
	local MoneyTemplateData = {}

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)

		table.insert(MoneyTemplateData, {
			Type = consumableId
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(MoneyTemplateData)
end

local COMMODITY_TEMPLATE_DEFAULT = 0

M.OnGetCommodityItemTemplate = function(self, index)
	local data = self.commodityRenderData[index + 1]

	return data and data.tIndex or COMMODITY_TEMPLATE_DEFAULT
end

M.OnRenderCommodityItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.commodityRenderData[index + 1]

	if store and data then
		store.qualityCtrl = data.Quality
		store.showCountLimitCtrl = data.NoLimit and self.ShowType.FALSE or self.ShowType.TRUE
		store.showNumberCtrl = self.ShowType.FALSE
		store.showTaskWarningCtrl = data.IsTask and self.ShowType.TRUE or self.ShowType.FALSE
		store.singleMoneyLackCtrl = self.moneys[data.Money] >= data.PriceCurrent and self.ShowType.TRUE or self.ShowType.FALSE
		store.stateCtrl = data.State
		store.hasDiscountCtrl = data.HasDiscount and self.ShowType.TRUE or self.ShowType.FALSE
		store.discount = data.DiscountDesc
		store.name = data.Name
		store.iconId = data.ShopIconId
		store.priceCurrent = (data.MoneyRichTextIcon or moneyIconText) .. data.PriceCurrent
		store.countLimit = data.RemainByLimit
		store.taskIconId = data.TaskIconId
		store.typeCtrl = data.CommodityType - 1
		store.discountTypeCtrl = data.Discount <= 100 and self.ShowType.FALSE or self.ShowType.TRUE

		if data.Unlocked and data.SoldOut and data.RefreshTime <= 0 then
			store.showRefreshTimeCtrl = self.ShowType.TRUE
			self.updateRefreshStoreList[index + 1] = store
			self.needUpdateRefresh = true
		else
			store.showRefreshTimeCtrl = self.ShowType.FALSE
		end

		btn.luaRenderTooltip = self.luaRenderTooltipCb
		btn.luaTooltipPopup = self.luaTooltipPopupCb
	end
end

M.OnCommodityChangeSelect = function(self)
	self.selectedCommodityIndex = self.bindData.commodityList.selectedIndex + 1
	self.selectedInfo = self.commodityRenderData[self.selectedCommodityIndex]
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.icon = data.icon
	end
end

M.OnTabChangeSelect = function(self)
	self.selectedTabIndex = self.SubGroup.CommonTabSingleStore:GetSelectedIndex() + 1

	if self.isInit and self.selectedTabIndex <= 0 and self.selectedTabIndex < #self.tabList then
		local tabInfo = self.tabList[self.selectedTabIndex]
		self.selectedGroupId = tabInfo.groupId
		self.bindData.tabTitle = tabInfo.title

		if self.selectedGroupId ~= -999 then
			self.commodityRenderData = {}

			for k, v in pairs(self.groupList) do
				for i = 1, #v do
					table.insert(self.commodityRenderData, v[i])
				end
			end

			gShopManager:SortCommodityList(self.commodityRenderData)
		else
			self.commodityRenderData = self.groupList[self.selectedGroupId] or {}

			gShopManager:SortCommodityList(self.commodityRenderData)
		end

		table.clear(self.updateRefreshStoreList)

		self.needUpdateRefresh = false
		local firstItem = self.commodityRenderData[1]
		local newListTypeCtrl = firstItem and firstItem.tIndex or 0

		self.bindData:Commit("listTypeCtrl", newListTypeCtrl, COMMIT_IMMEDIATELY)
		self.bindData.commodityList:SetSimpleList(#self.commodityRenderData)
		self.bindData.commodityList:GoToIndex(0, true)

		if #self.commodityRenderData ~= 0 then
			self.bindData.commodityList:TryCloseToolTip(true)
			print_error("商店分页配置异常，没有配置任何商品，找策划查bug!!! CommodityGroupId=", self.selectedGroupId)
		else
			self.bindData.commodityList:SelectItem(0, true)
			self.bindData.commodityList:TryCloseToolTip(true)
			self.bindData.commodityList:TryOpenSelectedToolTip()
		end

		self.bindData.commodityList:PlayStartOffsetAnim()
	else
		self.selectedGroupId = -1
		self.commodityRenderData = nil

		table.clear(self.updateRefreshStoreList)

		self.needUpdateRefresh = false
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.tabListPad and self.bindData.tabListPad.selectedIndex == self.selectedTabIndex - 1 then
		self.bindData.tabListPad:SelectItem(self.selectedTabIndex - 1, false)
	end
end

M.OnTabChangeSelectPad = function(self)
	local index = self.bindData.tabListPad.selectedIndex

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(index, true, false)
end

M.ForceSelectTab = function(self, index)
	if not self.STATE_EnableOnce then
		return
	end

	if index > 0 and index >= #self.tabList then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(index, false, false)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.tabListPad:SelectItem(index, false)
		end
	end
end

M.OnTabSwitchChange = function(self, dir)
	if dir <= 0 then
		local idx = self.selectedTabIndex + 1

		if idx <= #self.tabList then
			idx = 1
		end

		if idx > 1 and idx < #self.tabList then
			self.bindData.tabListPad:SelectItem(idx - 1, true)
		end
	else
		local idx = self.selectedTabIndex - 1

		if idx >= 1 then
			idx = #self.tabList
		end

		if idx > 1 and idx < #self.tabList then
			self.bindData.tabListPad:SelectItem(idx - 1, true)
		end
	end
end

M.RefreshTooltip = function(self)
	if self.shopType ~= 0 then
		print_error("@lujunlin：当前商店类型配置为0，请检查！")
		self.bindData.commodityList:TryCloseToolTip(true)

		return
	end

	if not self.selectedInfo then
		self.bindData.commodityList:TryCloseToolTip(true)

		return
	end
end

M.LuaOnRenderToolTip = function(self, btn, popup)
	local data = self.selectedInfo
	local toolTipStore = gStoreManager:GetStoreGroup(popup.Store)

	if data and toolTipStore then
		local maxNum = data.LimitOnceNum
		local canAfford = math.floor(self.moneys[data.Money] / data.PriceCurrent)
		maxNum = math.min(maxNum, canAfford)

		if not data.NoLimit then
			maxNum = math.min(maxNum, data.RemainNum)
		end

		if data.LimitHaveNum then
			local consumeCfg = LTConfig.ConsumableConfig.GetConfig(data.ConsumableID)
			local typeCfg = consumeCfg and LTConfig.ConsumableTypeConfig.GetConfig(consumeCfg.SubType)
			local maxHaveNum = typeCfg and typeCfg.MaxHaveNum and typeCfg.MaxHaveNum <= 0 and typeCfg.MaxHaveNum or nil

			if maxHaveNum then
				local currentHaveNum = gCommonItemManager:GetPackItemNum(data.ConsumableID)
				maxNum = math.min(maxNum, maxHaveNum - currentHaveNum)
			end
		end

		maxNum = math.max(0, maxNum)
		data.range = {
			0,
			maxNum
		}

		toolTipStore:SetSelectedNpcShopItem(data, self.moneys, self.buyBtnCb, data.MoneyRichTextIcon or moneyIconText)
	end
end

M.LuaOnTooltipPopup = function(self, toolTipsBtn, toolTipsPopup, toolTipsIndex)
	if not toolTipsPopup then
		self.bindData.commodityList:DeselectAll(false)
	end
end

M.OnBuyBtnClick = function(self, data, val, btn)
	if not self.selectedInfo then
		print_error("商品信息不存在，selectedGroupId=", self.selectedGroupId, "selectedCommodityIndex=", self.selectedCommodityIndex)

		return
	end

	self.buyNum = val or 1

	if self.selectedInfo.SoldOut then
		return
	elseif self.buyNum <= 0 then
		local totalBuy = self.buyNum * self.selectedInfo.PriceCurrent

		if self.moneys[self.selectedInfo.Money] >= totalBuy then
			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyNotEnoughMoney)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, self.buyCb, nil, self.selectedInfo.MoneyRichTextIcon, totalBuy, string.format(" %s x %s ", self.selectedInfo.Name, self.buyNum))
		end
	end
end

M.BuyCallback = function(self)
	if self.selectedInfo and self.buyNum <= 0 and self.buyNum * self.selectedInfo.PriceCurrent < self.moneys[self.selectedInfo.Money] then
		local name = self.selectedInfo.Name
		local num = self.buyNum
		local quality = self.selectedInfo.Quality
		local isWeapon = self.selectedInfo.CommodityType ~= CommodityTypeConfig.Weapon

		if isWeapon and self.selectedInfo.BindId and self.selectedInfo.BindId <= 0 then
			self.WeaponBuyTipsPrepare(self, name, num, quality, self.selectedInfo.BindId)
		end

		local commodityId = self.selectedInfo.CommodityId
		slot6 = gClientToGameDelegate

		slot6:AskBuyCommodity(self.shopId, commodityId, num).Callback = function (err)
			if err ~= MessageConfig.Ok then
				if self.STATE_EnableOnce then
					if not isWeapon then
						self:ClearWeaponBuyTipsPrepare()
						self:ShowBuyTips(name, num, quality)
					end

					self:RefreshMoneyInfo()
					self:PerformTalkAction(self.factionAttitude, self.ACTION_TYPE.PURCHASE)
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

M.ShowBuyTips = function(self, name, num, quality)
	self.needUpdateBuyTips = true
	self.buyTipsStartTime = Time.time

	self.bindData:Commit("ShowBuyTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)
	self.bindData:Commit("ShowWeaponTipsCtrl", self.ShowType.FALSE, COMMIT_IMMEDIATELY)

	self.bindData.buyTipsName = name .. " x" .. num
	self.bindData.QualityCtrl = quality
	self.bindData.quality = quality

	gCS.LuaUtils.PlayAnimation(self.bindData.buyTipAnime)
end

M.WeaponBuyTipsPrepare = function(self, name, num, quality, weaponTemplateId)
	self.weaponPrepared = true
	self.pWeaponName = name
	self.pWeaponNum = num
	self.pWeaponQuality = quality
	self.pWeaponId = weaponTemplateId
end

M.ClearWeaponBuyTipsPrepare = function(self)
	self.weaponPrepared = false
	self.pWeaponName = nil
	self.pWeaponNum = nil
	self.pWeaponQuality = nil
	self.pWeaponId = 0
end

M.ShowWeaponBuyTips = function(self, name, num, quality, weaponText)
	self.needUpdateBuyTips = true
	self.buyTipsStartTime = Time.time

	self.bindData:Commit("ShowBuyTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)
	self.bindData:Commit("ShowWeaponTipsCtrl", self.ShowType.TRUE, COMMIT_IMMEDIATELY)

	self.bindData.buyTipsName = name .. " x" .. num
	self.bindData.weaponTipsName = weaponText
	self.bindData.QualityCtrl = quality
	self.bindData.quality = quality

	gCS.LuaUtils.PlayAnimation(self.bindData.buyTipAnime)
end

M.OnBackBtnClick = function(self)
	if self.closeTimer then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.closeAnime)

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		gPanelManager:Close(gPanelId.S_NPC_SHOP_PANEL)
		gPanelManager:Close(gPanelId.NPC_SHOP_SWITCH_PANEL)
		gPanelManager:Close(gPanelId.S_NEW_INVENTORY_PANEL_FRONT_FS)
	end, self.bindData.anime:GetClip(self.closeAnime).length):Start()
end

M.OnFullScreenCloseBtnClick = function(self)
	self.bindData.showTooltipCtrl = self.ShowType.FALSE

	self.bindData.commodityList:DeselectAll(false)
end

M.OnFactionDiscountBtnRenderTooltip = function(self, btn, popup, index)
	local store = gStoreManager:GetStoreGroup(popup.Store)

	if not store then
		return
	end

	local sourceList = gShopManager:GetDiscountSourceList(self.shopId)

	store:SetSelectedDiscount(sourceList)
end

M.RefreshCommodityInfo = function(self)
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("OnRefreshCommodityInfo"))
end

M.OnRefreshCommodityInfo = function(self, success, groupList, groupDict, data)
	if success then
		if not self.isInit then
			self.isInit = true

			self.InitMoneyInfo(self, data.Moneys)
			self.ForceSelectTab(self, 0)
		end

		local discount = data.CurrentDiscount
		self.currentDiscount = discount
		self.bindData.factionDiscount, self.bindData.factionAttitudeIcon = gShopManager:GetDiscountTextAndIcon(discount, self.shopId)
		self.groupList = groupList
		self.groupDict = {}

		for _, dict in pairs(groupDict) do
			for k, v in pairs(dict) do
				self.groupDict[k] = v
			end
		end

		self.OnTabChangeSelect(self)
	end
end

M.RefreshMoneyInfo = function(self)
	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
	end
end

M.OnPackItemChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshMoneyInfo(self)

	if self.bindData.commodityList then
		self.bindData.commodityList:RefreshList()
	end

	self.RefreshTooltip(self)
end

M.OnFactionLevelChange = function(self, eventId, factionId)
	if self.STATE_EnableOnce and self.factionId ~= factionId then
		self.RefreshFactionAttitude(self)
	end
end

M.OnCommodityInfoChange = function(self, eventId, shopId, infos)
	if self.STATE_OnShowOnce and self.shopId ~= shopId and self.groupDict then
		local dirty = false

		for i = 1, infos.Length do
			local info = infos[i]

			if self.groupDict[info.TemplateId] then
				dirty = true

				gShopManager:UpdateCommodityInfoSingle(self.groupDict[info.TemplateId], info)
			end
		end

		if dirty then
			table.clear(self.updateRefreshStoreList)

			self.needUpdateRefresh = false

			self.bindData.commodityList:RefreshList()
			self:RefreshTooltip()
		end
	end
end

M.OnArmoryWeaponAdd = function(self, eventId, data)
	if self.weaponPrepared and self.pWeaponId ~= data.TemplateId then
		self.ShowWeaponBuyTips(self, self.pWeaponName, self.pWeaponNum, self.pWeaponQuality, NpcShopConfig.WeaponStoredText)
		self.ClearWeaponBuyTipsPrepare(self)
	end
end

M.OnCurrentWeaponSlotAdd = function(self, eventId, data)
	if self.weaponPrepared and self.pWeaponId ~= data.Weapon.TemplateId then
		self.ShowWeaponBuyTips(self, self.pWeaponName, self.pWeaponNum, self.pWeaponQuality, NpcShopConfig.WeaponAddedToWheelText)
		self.ClearWeaponBuyTipsPrepare(self)
	end
end
