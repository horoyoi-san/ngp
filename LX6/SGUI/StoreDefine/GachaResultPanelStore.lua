-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GachaResultPanelStore.lua
-- Decompiled from: 01875_GachaResultPanelStore.lua_417637e5d3c7.luajit

local ShopBrandConfig = LTConfig.ShopBrandConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local CommonItemConfig = LTConfig.CommonItemConfig
local NORMAL_BG_VIDEO_ID = 24104359
local TEN_ITEM_ANIM_NORMAL = "S_Vx_BoxitemTemplate_openNormal"
local TEN_ITEM_ANIM_PURPLE = "S_Vx_BoxitemTemplate_openPurple"
local TEN_ITEM_ANIM_GOLDEN = "S_Vx_BoxitemTemplate_openGolden"
local TEN_ITEM_ANIM_NORMAL_BOTTOM = "S_Vx_BoxitemTemplate_openNormal2"
local TEN_ITEM_ANIM_PURPLE_BOTTOM = "S_Vx_BoxitemTemplate_openPurple2"
local TEN_ITEM_ANIM_GOLDEN_BOTTOM = "S_Vx_BoxitemTemplate_openGolden2"
local TEN_GRID_TOP_ROW_COUNT = 5
local TEN_ITEM_STAGGER_DELAY = 0.06
C_GachaResultPanelStore = DefClass("C_GachaResultPanelStore", C_GachaResultPanelStore, C_StoreGroup)
GroupName2Class.GachaResultPanelStore = C_GachaResultPanelStore
local M = C_GachaResultPanelStore

M.ctor = function(self)
	self.rewardMsg = nil
	self.rewardItems = {}
	self.currentRewardIndex = 1
	self.isMultiDraw = false
	self.showTen = false
	self.curBgVideoId = nil
	self.curLuckyVideoId = nil
	self.gachaType = nil
	self.glowAnim = "S_DrawResult_MASKGlow"
	self.normalAnim = "S_DrawResult_normal"
	self.normalAnimPC = "S_DrawResult_normalPC"
	self.purpleAnim = "S_DrawResult_purple"
	self.purpleAnimPC = "S_DrawResult_purplelPC"
	self.goldenAnim = "S_DrawResult_golden"
	self.goldenAnimPC = "S_DrawResult_goldenPC"
	self.luckyAnim = "S_DrawResult_LuckyDraw"
	self.luckyAnimPC = "S_DrawResult_LuckyDrawPC"
	self.isTooltipOpen = false
	self.tooltipBtn = nil
	self.tenItemAnimTimers = {}
	self.tenItemAnimPlayed = {}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.luckyCtrlEnum = {
		["\\xbamh"] = 2,
		["}Uܰ\\x85\\x9c\\xc8\\xff"] = 1,
		["oRobW:/"] = 0
	}
	self.ItemQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.repeatDrawCtrlEnum = {
		["a_޸\\x85\\x9c\\xc8\\xff"] = 0,
		["eN~zZ:/"] = 1
	}
	self.gachaTypeCtrlEnum = {
		["\\xacg~"] = 0,
		["?D\\x9e\\x9d\\x86U"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.luckyCtrlEnum = nil
	self.ItemQualityCtrlEnum = nil
	self.repeatDrawCtrlEnum = nil
	self.gachaTypeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.bindData.CCPlayer:Init()
	self.bindData.LuckyCCPlayer:Init()
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
	self.panelId = panelId

	if data and data.PreLoad then
		self.bindData.CCPlayer:PreLoadVideo(NORMAL_BG_VIDEO_ID)

		local firstReward = data.rewardItems and data.rewardItems[1]

		if firstReward and firstReward.IsGrandPrize and firstReward.BgVideo and firstReward.BgVideo <= 0 then
			self.bindData.LuckyCCPlayer:PreLoadVideo(firstReward.BgVideo)
		end

		gPanelManager:SetActiveById(self.panelId, false)

		return
	end

	gPanelManager:SetActiveById(self.panelId, true)
	self.bindData:EnableImmediatelyCommit(true)

	self.bindData.spine1Active = false
	self.bindData.spine2Active = false

	if self.bindData.nextBtn then
		self.bindData.nextBtn.gameObject:SetActive(true)
	end

	if data and data.rewardItems then
		self.rewardItems = data.rewardItems
	else
		self.rewardMsg = data and data.rewardMsg
	end

	self.gachaType = data and data.gachaType or 2
	self.isMultiDraw = #self.rewardItems >= 1

	if data and data.showTen then
		self.ShowTenResult(self)

		return
	end

	self.currentRewardIndex = 1

	self.ShowRewardInfo(self)
end

M.OnClose = function(self)
	self.bindData.CCPlayer:Stop()
	self.bindData.LuckyCCPlayer:Stop()
	self:CancelTenItemAnimTimers()

	if self.gachaType ~= 1 and self.isMultiDraw and self.rewardItems and #self.rewardItems <= 0 then
		local previewMaterials = {}

		for _, rewardItem in ipairs(self.rewardItems) do
			if rewardItem.ItemId and rewardItem.ItemId <= 0 then
				table.insert(previewMaterials, {
					ItemId = rewardItem.ItemId,
					Count = rewardItem.Count or 1
				})
			end
		end

		if #previewMaterials <= 0 then
			gDropManager:ShowRewardWindow({
				["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
				Param = previewMaterials
			})
		end
	end

	self.rewardMsg = nil
	self.rewardItems = {}
	self.currentRewardIndex = 1
	self.isMultiDraw = false
	self.showTen = false
	self.curBgVideoId = nil
	self.curLuckyVideoId = nil
	self.gachaType = nil
	self.isTooltipOpen = false
	self.tooltipBtn = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.jumpBtn.luaClick = self.CreateAction(self, "OnClickJumpBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")

	if self.bindData.nextBtn then
		self.bindData.nextBtn.luaClick = self.CreateAction(self, "OnClickNextBtn")
	end

	if self.bindData.backBtnTen then
		self.bindData.backBtnTen.luaClick = self.CreateAction(self, "OnClickBackBtnTen")
	end

	self.bindData.resultItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderResultItemListItem")
end

M.OnClickJumpBtn = function(self)
	if self.isMultiDraw and (self.gachaType ~= 2 or self.gachaType ~= 3) then
		self.ShowTenResult(self)
	else
		gPanelManager:Close(self.panelId)
	end
end

M.OnClickBackBtn = function(self)
	if self.isTooltipOpen and self.tooltipBtn then
		self.tooltipBtn:CloseTooltip(true)

		self.isTooltipOpen = false
	else
		gPanelManager:Close(self.panelId)
	end
end

M.OnClickBackBtnTen = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickNextBtn = function(self)
	if self.isTooltipOpen and self.tooltipBtn then
		self.tooltipBtn:CloseTooltip(true)

		self.isTooltipOpen = false
	end

	if not self.isMultiDraw then
		gPanelManager:Close(self.panelId)

		return
	end

	if self.currentRewardIndex >= #self.rewardItems then
		self.currentRewardIndex = self.currentRewardIndex + 1

		self.ShowRewardInfo(self)
	elseif self.gachaType ~= 2 or self.gachaType ~= 3 then
		self.ShowTenResult(self)
	else
		gPanelManager:Close(self.panelId)
	end
end

M.PlayBackgroundVideo = function(self, rewardItem)
	if not rewardItem or not rewardItem.BgVideo or rewardItem.BgVideo < 0 then
		return
	end

	if rewardItem.IsGrandPrize then
		if self.curLuckyVideoId == rewardItem.BgVideo then
			self.curLuckyVideoId = rewardItem.BgVideo

			self.bindData.LuckyCCPlayer:PlayVideo(rewardItem.BgVideo, true)
		end
	else
		if self.curLuckyVideoId then
			self.bindData.LuckyCCPlayer:Stop()

			self.curLuckyVideoId = nil
		end

		if self.curBgVideoId == rewardItem.BgVideo then
			self.curBgVideoId = rewardItem.BgVideo

			self.bindData.CCPlayer:PlayVideo(rewardItem.BgVideo, true)
		end
	end
end

M.SetBrandIcon = function(self, belongBrand)
	if not belongBrand or belongBrand ~= 0 then
		return
	end

	local brandCfg = ShopBrandConfig.GetConfig(belongBrand)

	if brandCfg then
		local brandIconId = brandCfg.BrandBanner or 0

		if brandIconId <= 0 then
			self.bindData.brandIconId = brandIconId
		end
	end
end

M.ShowRewardInfo = function(self)
	if #self.rewardItems ~= 0 then
		return
	end

	local mainReward = self.rewardItems[self.currentRewardIndex]

	if not mainReward then
		return
	end

	self:PlayBackgroundVideo(mainReward)

	local itemId = mainReward.ItemId
	local itemCfg = ConsumableConfig.GetConfig(itemId)
	local quality = mainReward.Quality or itemCfg.Quality or 0
	local itemCount = mainReward.Count or 1
	local isConverted = mainReward.IsConverted ~= true

	if isConverted and mainReward.DuplicateReturnCount then
		itemCount = mainReward.DuplicateReturnCount
	end

	local isLuckyDraw = mainReward.IsGrandPrize or false
	local isPC = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
	local animName = nil

	if isLuckyDraw then
		animName = isPC and self.luckyAnimPC or self.luckyAnim
	elseif quality ~= self.ItemQualityCtrlEnum.gold then
		animName = isPC and self.goldenAnimPC or self.goldenAnim
	elseif quality ~= self.ItemQualityCtrlEnum.purple then
		animName = isPC and self.purpleAnimPC or self.purpleAnim
	else
		animName = isPC and self.normalAnimPC or self.normalAnim
	end

	if self.bindData.itemAnim then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.itemAnim, animName)
	end

	if self.bindData.glowAnim then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.glowAnim, self.glowAnim)
	end

	local iconId = mainReward.DrawResultImage and mainReward.DrawResultImage <= 0 and mainReward.DrawResultImage or itemCfg.SItemIconId
	local itemName = mainReward.ContentName and mainReward.ContentName == "" and mainReward.ContentName or itemCfg.Name
	self.bindData.repeatDrawCtrl = mainReward.IsNew and self.repeatDrawCtrlEnum.FirstDraw or self.repeatDrawCtrlEnum.RepeatDraw

	if isLuckyDraw then
		self.bindData.luckyCtrl = self.luckyCtrlEnum.LuckyDraw
	else
		self.bindData.luckyCtrl = self.luckyCtrlEnum.NormalDraw
		self.bindData.repeatNum = itemCount

		if isConverted and mainReward.DuplicateReturnDropId and mainReward.DuplicateReturnDropId <= 0 then
			local itemList, _ = gCommonItemManager:ConvertDropToFakeItem(mainReward.DuplicateReturnDropId, 1)

			if itemList and #itemList <= 0 then
				local fakeItem = itemList[1]

				if fakeItem and fakeItem.Id then
					local itemCfg = CommonItemConfig.GetConfig(fakeItem.Id)

					if itemCfg and itemCfg.SItemIconId then
						self.bindData.convertItemImageId = itemCfg.SItemIconId
					end
				end
			end
		end
	end

	self.bindData.itemIconId = iconId
	self.bindData.nameText = itemName
	self.bindData.ItemQualityCtrl = quality
	self.bindData.ItemIsNew = mainReward.IsNew or false
	self.bindData.brandIconId = 0

	if self.gachaType ~= 1 and not isLuckyDraw then
		self.bindData.gachaTypeCtrl = self.gachaTypeCtrlEnum.Closet
		self.bindData.numText = itemCount
	else
		self.bindData.gachaTypeCtrl = self.gachaTypeCtrlEnum.Box
	end

	self:SetBrandIcon(mainReward.BelongBrand)

	local qualityTextIdMap = {
		[0] = 73977022,
		73977022,
		73977023,
		73977024,
		73977025,
		73977026
	}
	local qualityTextId = qualityTextIdMap[quality] or 73977026
	self.bindData.qualityText = LTConfig.TextConfig.GetConfig(qualityTextId).Text

	if self.gachaType ~= 1 and isLuckyDraw then
		self.bindData.spine1Active = true
		self.bindData.spine2Active = false
		self.bindData.itemIconId = 0
	elseif self.gachaType ~= 2 and isLuckyDraw then
		self.bindData.spine1Active = false
		self.bindData.spine2Active = true
		self.bindData.itemIconId = 0
	else
		self.bindData.spine1Active = false
		self.bindData.spine2Active = false

		if self.gachaType ~= 3 and isLuckyDraw and mainReward.BaseImage and mainReward.BaseImage <= 0 then
			self.bindData.itemIconId = mainReward.BaseImage
		end
	end
end

M.OnRenderResultItemTooltip = function(self, rewardItem, btn, popup, index)
	if not rewardItem or not rewardItem.ItemId or rewardItem.ItemId < 0 then
		return
	end

	local data = {
		itemId = rewardItem.ItemId
	}

	gCommonItemManager:OnRenderToolTips(data, btn, popup, index)

	if popup then
		self.isTooltipOpen = true
	end
end

M.OnTooltipPopup = function(self, btn, popup, index)
	if not popup then
		self.isTooltipOpen = false

		btn.SetSelected(btn, false)
	end
end

M.ShowTenResult = function(self)
	if self.showTen then
		return
	end

	self.showTen = true

	if self.bindData.nextBtn then
		self.bindData.nextBtn.gameObject:SetActive(false)
	end

	self.bindData.luckyCtrl = self.luckyCtrlEnum.Ten
	self.bindData.titleText = LTConfig.TextConfig.GetConfig(73977006).Text

	self:ShowAllRewards()
	self.bindData.LuckyCCPlayer:Stop()

	self.curLuckyVideoId = nil

	if self.curBgVideoId == NORMAL_BG_VIDEO_ID then
		self.bindData.CCPlayer:PreLoadVideo(NORMAL_BG_VIDEO_ID)

		self.curBgVideoId = NORMAL_BG_VIDEO_ID

		self.bindData.CCPlayer:PlayVideo(NORMAL_BG_VIDEO_ID, true)
	end
end

M.CancelTenItemAnimTimers = function(self)
	if self.tenItemAnimTimers then
		for _, timerId in ipairs(self.tenItemAnimTimers) do
			gLuaTimeMgrUtils.CancelUnitDelay(timerId)
		end
	end

	self.tenItemAnimTimers = {}
end

M.ShowAllRewards = function(self)
	self.CancelTenItemAnimTimers(self)

	self.tenItemAnimPlayed = {}

	if #self.rewardItems ~= 0 then
		self.bindData.resultItemList:SetSimpleList(0)

		return
	end

	self.bindData.resultItemList:SetSimpleList(#self.rewardItems)
end

M.OnSimpleRenderResultItemListItem = function(self, btn, index)
	local rewardItem = self.rewardItems[index + 1]

	if not rewardItem then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local itemCfg = ConsumableConfig.GetConfig(rewardItem.ItemId)

	if not itemCfg then
		return
	end

	local isConverted = rewardItem.IsConverted ~= true
	local isLucky = rewardItem.IsGrandPrize ~= true
	local quality = rewardItem.Quality or itemCfg.Quality or 0
	local itemCount = rewardItem.Count or 1

	if isConverted and rewardItem.DuplicateReturnCount then
		itemCount = rewardItem.DuplicateReturnCount
	end

	local iconId = rewardItem.DrawResultImage and rewardItem.DrawResultImage <= 0 and rewardItem.DrawResultImage or itemCfg.SItemIconId
	local itemName = rewardItem.ContentName and rewardItem.ContentName == "" and rewardItem.ContentName or itemCfg.Name
	itemStore.clotheImageCtrl = isLucky and 1 or 0

	if isLucky then
		itemStore.luckyItemImageId = iconId
	else
		itemStore.normalItemImageId = iconId
	end

	itemStore.itemNameText = itemName
	itemStore.qualityCtrl = quality
	itemStore.goodsNum = tostring(itemCount)
	itemStore.repeatCtrl = isConverted and 0 or 1

	if itemStore.itemAnim then
		local isBottomRow = TEN_GRID_TOP_ROW_COUNT > index
		local colIndex = isBottomRow and index - TEN_GRID_TOP_ROW_COUNT or index
		local animName = nil

		if quality ~= self.ItemQualityCtrlEnum.gold or quality ~= self.ItemQualityCtrlEnum.orange then
			animName = isBottomRow and TEN_ITEM_ANIM_GOLDEN_BOTTOM or TEN_ITEM_ANIM_GOLDEN
		elseif quality ~= self.ItemQualityCtrlEnum.purple then
			animName = isBottomRow and TEN_ITEM_ANIM_PURPLE_BOTTOM or TEN_ITEM_ANIM_PURPLE
		else
			animName = isBottomRow and TEN_ITEM_ANIM_NORMAL_BOTTOM or TEN_ITEM_ANIM_NORMAL
		end

		if self.tenItemAnimPlayed[index] then
			itemStore.renderOpacity = 1
		else
			self.tenItemAnimPlayed[index] = true
			itemStore.renderOpacity = 0
			local timerId = gLuaTimeMgrUtils.Delay(function ()
				if not btn then
					return
				end

				itemStore.renderOpacity = 1

				gCS.LuaUtils.PlayAnimationByName(itemStore.itemAnim, animName)
			end, TEN_ITEM_STAGGER_DELAY * colIndex)

			table.insert(self.tenItemAnimTimers, timerId)
		end
	end

	if isConverted and rewardItem.DuplicateReturnDropId and rewardItem.DuplicateReturnDropId <= 0 then
		local itemList = gCommonItemManager:ConvertDropToFakeItem(rewardItem.DuplicateReturnDropId, 1)
		local fakeItem = itemList and itemList[1]

		if fakeItem then
			local cfg = CommonItemConfig.GetConfig(fakeItem.Id)
			itemStore.convertItemImageId = cfg.SItemIconId
		end
	end

	btn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderTenItemTooltip", rewardItem)
	btn.luaTooltipPopup = self.CreateAction(self, "OnTenItemTooltipClose")
end

M.OnRenderTenItemTooltip = function(self, rewardItem, btn, popup, index)
	if not rewardItem or not rewardItem.ItemId or rewardItem.ItemId < 0 then
		return
	end

	local tooltipData = gCommonItemManager:GetItemRenderData({
		itemId = rewardItem.ItemId
	})

	gCommonItemManager:OnRenderToolTips(tooltipData, btn, popup, index)
end

M.OnTenItemTooltipClose = function(self, btn, popup, index)
	gCommonItemManager:OnToolTipsClose(btn, popup, index)
end
