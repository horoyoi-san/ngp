-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BattlePassPanelStore.lua
-- Decompiled from: 01664_BattlePassPanelStore.lua_218a01f24d6f.luajit

local BattlePassConfig = LTConfig.BattlePassConfig
local BattlePassType = UX.Game.BattlePassType
local BattlePassGoodsConfig = LTConfig.BattlePassGoodsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local ChallengeTaskState = UX.Game.ChallengeTaskState
local GoodsType = LTConfig.BattlePassGoodsConfig.TypeType
local TextConfig = LTConfig.TextConfig
local bit = require("bit")
C_BattlePassPanelStore = DefClass("C_BattlePassPanelStore", C_BattlePassPanelStore, C_StoreGroup)
GroupName2Class.BattlePassPanelStore = C_BattlePassPanelStore
local M = C_BattlePassPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.hasShownEmptyStoreMsg = false
	self.ps5StoreIconPanelId = nil
	self.bpData = nil
end

M.DefineAllVariables = function(self)
	self.isDebug = false
	self.offsetIndex = 3
	self.rewardTabContent = BattlePassConfig.TabTitle
	self.taskTabContent = BattlePassConfig.TaskTabTitle
	self.curGrandPrizeLevel = 0
	self.rewardShowEnum = {
		["j\\xbc\\xa3\\xa1\\xb2"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.taskEnum = {
		["`OmeB="] = 1,
		["+M\\x94\\x85\\x8fX"] = 0
	}
	self.buyLevelRewardEnum = {
		["\\xafdj"] = 4,
		["T-s^"] = 3,
		["\\0x^"] = 0,
		["\\x8a\\xb5\\xaad=\\xfb7"] = 1,
		["0M\\x96\\x8f\\x80X"] = 2
	}
	self.buyPassChargeEnum = {
		["?,\\xe8C\\x8a\\xfe7\\xad\\xe3\\xf5\\xe7w\\xe2"] = 10,
		["\\x8a\\xb5\\xaad=\\xfb7"] = 8,
		["#&\\xe2C\\x8a\\xfe7\\xad\\xe3\\xf5\\xe7w\\xe2"] = 9
	}
	self.RewardClaimStateEnum = {
		["n\\xa2\\xa3\\xa6\\xbb"] = 1,
		["\\x85\\xbe\\x88f?\\xf7>"] = 0,
		["0G\\x92\\x85\\x86E"] = 2
	}
	self.goodsTypeToIndex = {
		[GoodsType.Fashion] = 2,
		[GoodsType.Vehicle] = 1,
		[GoodsType.Money] = 2,
		[GoodsType.Big] = 2
	}
	self.unlockTitle = {
		[BattlePassType.Legacy] = 73977034,
		[BattlePassType.Free] = 73977032,
		[BattlePassType.Advanced] = 73977033
	}
	self.normalRewardList = {}
	self.advancedRewardList = {}
	self.rewardTabContentTabList = {}
	self.significantPrizeRules = {}
	self.curMainReward = nil
	self.curMainRewardNum = 1
	self.mainItemToolTipStore = nil
	self.knownMaximumAllClaimedOrHaveLockedLevel = 0
	self.modelCameraEnabled = false
	self.currPreviewModelKind = nil
	self.recentTooltipBtn = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = {
		["aRuEK+"] = 3,
		[" \\xf6F\\xc4\\xbaD\\x91W\\xa3\\xa5"] = 2,
		["\\xeb\\xde \\xe2"] = 0,
		["\\xf4\\xd2+\\xff"] = 1
	}
	self.hideAllUICtlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = nil
	self.hideAllUICtlEnum = nil
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
	self.StopShowingModels(self)
	self.CleanUp(self)

	self.recentTooltipBtn = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	self.rewardLevelStore = self.GetStoreByWidget(self, self.bindData.rewardLevel)
	self.taskLevelStore = self.GetStoreByWidget(self, self.bindData.taskLevel)
	self.grandPrizeStore = self.GetStoreByWidget(self, self.bindData.grandPrizeBtn)

	if self.bindData.mainItemToolTip then
		self.mainItemToolTipStore = gStoreManager:GetStoreGroup("BattlePassToolTipTemplate"):GetStoreByWidget(self.bindData.mainItemToolTip)
	end
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.rewardLevelStore = nil
	self.taskLevelStore = nil
	self.mainItemToolTipStore = nil
end

M.OnShow = function(self, panelId, data)
	if gCS.LuaUtils.IsOnPS5 then
		self.hasShownEmptyStoreMsg = false
		self.ps5StoreIconPanelId = nil
	end

	self.bpData = gBattlePassMgr:GetSeasonalData()

	if not self.bpData then
		return
	end

	self.bpCfg = BattlePassConfig.GetConfig(self.bpData.bpId)

	self:RefreshTaskProgress()

	self.taskType = self.taskEnum.Weekly

	self:SwitchPage(self.pageCtrlEnum.Rewards)

	local currentTime = gLuaDataManager.serverTime
	local seasonId = BattlePassConfig.GetConfig(self.bpData.bpId).SeasonId
	local startTime = LTConfig.OnlineSeasonProgressSeasonConfig.GetConfig(seasonId).StartTime
	local endTime = LTConfig.OnlineSeasonProgressSeasonConfig.GetConfig(seasonId).EndTime
	local endUnixTime = gTimeUtils:GetUnixTime(endTime.year or 0, endTime.month or 0, endTime.day or 0, endTime.hour or 0, endTime.minute or 0, endTime.second or 0)
	local startUnixTime = gTimeUtils:GetUnixTime(startTime.year or 0, startTime.month or 0, startTime.day or 0, startTime.hour or 0, startTime.minute or 0, startTime.second or 0)

	if startUnixTime < currentTime then
		self.bindData.countDown:Play(endUnixTime - gCS.TimeManager.ServerUnixTime)
	end

	self.bindData.proTagText = TextConfig.GetConfig(73977035).Text

	self.bindData.camera.transform:GetChild(0).gameObject:SetActive(true)

	self.bindData.camera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.bindData.camera.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation
	self.prevMallVCamera = gMallSceneManager.mallVCamera

	gMallSceneManager:SetMallVCamera(self.bindData.VCamera)
end

M.OnClose = function(self)
	if gCS.LuaUtils.IsOnPS5 and self.ps5StoreIconPanelId then
		gPanelManager:RemovePS5StoreIconPanel(self.ps5StoreIconPanelId)

		self.ps5StoreIconPanelId = nil
	end

	self.normalRewardList = nil
	self.advancedRewardList = nil
	self.bpData = nil

	self.CleanUp(self)
end

M.CleanUp = function(self)
	if self.bindData and self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)
	end

	if self.prevMallVCamera then
		gMallSceneManager:SetMallVCamera(self.prevMallVCamera)
	else
		gMallSceneManager:ReleaseMallScene()
		gMallSceneManager:ClearCharacterModel()
		gMallSceneManager:ClearVehicle()
		gMallSceneManager:ClearWeapon()
		gMallSceneManager:ClearMallVCamera()
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.BUY_BATTLEPASS] = self.CreateAction(self, "OnBattlePassTypeChange"),
		[gEventConstants.BATTLEPASS_CLAIM_REWARD] = self.CreateAction(self, "OnClaimRewards"),
		[gEventConstants.BATTLEPASS_CLAIM_TASK] = self.CreateAction(self, "OnRefreshTaskInfo")
	}
end

M.RegisterWidget = function(self)
	self.bindData.unlockPassBtn.luaClick = self.CreateAction(self, "OnClickUnlockPassBtn")
	self.bindData.openTooltipBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderMainTooltip")
	self.bindData.buyPassBtn.luaClick = self.CreateAction(self, "OnClickBuyPassBtn")
	self.bindData.buyLevelBtn.luaClick = self.CreateAction(self, "OnClickBuyLevelBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtn")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeStep", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeStep", 1)
	self.bindData.buyLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeBuyStep", -1)
	self.bindData.buyRightBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeBuyStep", 1)
	self.bindData.toolTipCloseBtn.luaClick = self.CreateAction(self, "OnCloseMainTooltip")

	if self.bindData.backToCurrentLevelBtn then
		self.bindData.backToCurrentLevelBtn.luaClick = self.CreateAction(self, "OnClickBackToCurrentLevel")
	end

	if self.bindData.allClaimBtn then
		self.bindData.allClaimBtn.luaClick = self.CreateAction(self, "AskClaimAllReward")
	end

	if self.bindData.ShowModelBtn then
		self.bindData.ShowModelBtn.luaClick = self.CreateAction(self, "OnClickShowModelBtn")
	end

	if self.bindData.taskTabLeftBtn then
		self.bindData.taskTabLeftBtn.luaClick = self.CreateAction(self, "OnClickTaskTabLeftBtn")
	end

	if self.bindData.taskTabRightBtn then
		self.bindData.taskTabRightBtn.luaClick = self.CreateAction(self, "OnClickTaskTabRightBtn")
	end

	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItemListItem")
	self.bindData.taskTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTaskTabListItem")
	self.bindData.taskTabList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTaskTabList")
	self.bindData.taskList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTaskListItem")
	self.bindData.buyPassTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBuyPassTabListItem")
	self.bindData.buyPassTabList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickBuyPassTabList")
	self.bindData.buyPassTabList.onGetTIndex = self.CreateAction(self, "OnGetBuyPassTabListTIndex")
	self.bindData.buyAdvanceList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBuyAdvanceListItem")
	self.bindData.buyLegacyList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBuyLegacyListItem")
	self.bindData.buyLegacyList.onGetTIndex = self.CreateAction(self, "OnBuyLegacyListGetTIndex")
	self.bindData.normalRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderNormalRewardListItem")
	self.bindData.advanceRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderAdvanceRewardListItem")
	self.bindData.normalRewardList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickNormalRewardList")
	self.bindData.advanceRewardList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickAdvanceRewardList")

	if self.bindData.page01Slider then
		self.bindData.page01Slider.luaValueChanged = self.CreateAction(self, self.OnRewardPageSliderValueChanged)
	end

	if self.bindData.page01Slider then
		self.bindData.page01Slider.luaPress = self.CreateAction(self, self.OnSliderPress)
	end

	if self.bindData.page01Slider then
		self.bindData.page01Slider.luaRelease = self.CreateAction(self, self.OnSliderRelease)
	end
end

M.OnCloseBtn = function(self)
	if self.IsReviewingModel(self) then
		self.StopShowingModels(self)
	elseif not self.TryCloseTooltips(self) then
		self.DoClosePanel(self)
	end
end

M.TryCloseTooltips = function(self)
	if self.bindData.toolTipCloseBtn.isTooltipOpen then
		self.bindData.toolTipCloseBtn:CloseTooltip(true)

		return true
	end

	if self.recentTooltipBtn and not gCS.LuaUtils.IsNull(self.recentTooltipBtn) and (self.recentTooltipBtn:IsTooltipOpen(0) or self.recentTooltipBtn:IsTooltipOpen(1)) then
		self.recentTooltipBtn:CloseTooltip(true)

		return true
	end

	return false
end

M.DoClosePanel = function(self)
	if self.bindData.pageCtrl ~= self.pageCtrlEnum.Rewards then
		gPanelManager:Close(gPanelId.BATTLE_PASS_PANEL)
	elseif self.prePage then
		self.SwitchPage(self, self.prePage)
	else
		self.SwitchPage(self, self.pageCtrlEnum.Rewards)
	end
end

M.OnClickUnlockPassBtn = function(self)
	self.SwitchPage(self, self.pageCtrlEnum.BuyBattlePass)
end

M.OnSimpleClickNormalRewardList = function(self, btn, index)
end

M.OnSimpleClickAdvanceRewardList = function(self, btn, index)
end

M.SwitchPage = function(self, pageNum)
	if not pageNum then
		return
	end

	local oldPageCtrl = self.bindData.pageCtrl

	if gCS.LuaUtils.IsOnPS5 and oldPageCtrl ~= self.pageCtrlEnum.BuyBattlePass and pageNum == self.pageCtrlEnum.BuyBattlePass then
		self.hasShownEmptyStoreMsg = false

		if self.ps5StoreIconPanelId then
			gPanelManager:RemovePS5StoreIconPanel(self.ps5StoreIconPanelId)

			self.ps5StoreIconPanelId = nil
		end
	end

	self.prePage = nil

	if pageNum ~= self.pageCtrlEnum.Rewards then
		self.RefreshRewardPage(self)
	elseif pageNum ~= self.pageCtrlEnum.Mission then
		self.RefreshTaskPage(self)
	elseif pageNum ~= self.pageCtrlEnum.BuyBattlePass then
		if gCS.LuaUtils.IsOnPS5 and not self.ps5StoreIconPanelId then
			self.ps5StoreIconPanelId = self.m_Id * 100 + 2

			gPanelManager:AddPS5StoreIconPanel(self.ps5StoreIconPanelId)
		end

		self.RefreshBuyPassPage(self)
	elseif pageNum ~= self.pageCtrlEnum.BuyLevels then
		if not self.bpData or self.bpData.level ~= self.bpData.maxLevel then
			return
		end

		self.prePage = self.bindData.pageCtrl

		self.RefreshBuyLevelPage(self)
	end

	self.bindData.pageCtrl = pageNum
	self.selectedTabIndex = pageNum

	self.ConditionalShowModelBtn(self, pageNum)
end

M.UpdateLevelInfo = function(self, store)
	if not store then
		return
	end

	local bpData = self.bpData

	if not bpData then
		return
	end

	store.levelNum = bpData.level
	local nextLevel = bpData.level + 1

	if not bpData.rewardMap[nextLevel] then
		nextLevel = bpData.level
	end

	local showExp = bpData.exp

	if bpData.level == 0 then
		showExp = bpData.exp - bpData.rewardMap[bpData.level].exp
	end

	store.expNum = showExp .. "/" .. bpData.rewardMap[nextLevel].exp - bpData.rewardMap[bpData.level].exp
	store.showWeekExp = true
	store.weekExpNum = (bpData.weeklyExp or 0) .. "/" .. bpData.curWeekMaxExp
	store.limitText = TextConfig.GetConfig(73977031).Text
	store.expFill.normalizedValue = math.min(showExp / (bpData.rewardMap[nextLevel].exp - bpData.rewardMap[bpData.level].exp), 1)
	store.buyLevelBtn.luaClick = self:CreateActionWithArgs("SwitchPage", self.pageCtrlEnum.BuyLevels)
	store.buyLevelBtn.interactable = bpData.level == bpData.maxLevel
end

M.RefreshRewardPage = function(self)
	self.bindData.bpTitle = BattlePassConfig.BpTitle[1]
	self.bindData.leftTimeTitle = TextConfig.GetConfig(73977030).Text

	self.UpdateLevelInfo(self, self.rewardLevelStore)

	self.rewardTabContentTabList = {}

	for i, v in ipairs(self.rewardTabContent) do
		table.insert(self.rewardTabContentTabList, {
			title = v,
			id = i,
			Order = i
		})
	end

	self.selectedTabIndex = 0

	self.SubGroup.CommonTabSingleStore:SetData(self.rewardTabContentTabList, nil, 0, nil, self:CreateAction("OnSimpleClickRewardTabList"), self:CreateAction("OnSimpleRenderRewardTabListItem"))

	local bpData = self.bpData

	if not bpData then
		return
	end

	self.bindData.buyInteractable = false
	self.bindData.itemList.luaLayoutSet = self.CreateAction(self, "OnItemListLayoutSet")

	for level, data in pairs(bpData.rewardMap) do
		local allClaimedOrHaveLocked = true

		for i = 1, #data.rewards do
			local claimState = self.SetClaimState(self, data.claimState, data.rewards[i].type, data.level)

			if claimState == self.RewardClaimStateEnum.Claim and claimState == self.RewardClaimStateEnum.Locked then
				allClaimedOrHaveLocked = false
			end
		end

		if allClaimedOrHaveLocked then
			self.knownMaximumAllClaimedOrHaveLockedLevel = level
		else
			break
		end
	end

	self.bindData.showClaimBtnCtl = BOOL2CTL[self.knownMaximumAllClaimedOrHaveLockedLevel <= bpData.level]
	self.significantPrizeRules = {}

	for i = #self.bpCfg.SignificantRewardLevel, 1, -1 do
		local rule = self.bpCfg.SignificantRewardLevel[i]

		if rule then
			table.insert(self.significantPrizeRules, rule)
		end
	end

	self.bindData.itemList:RegisterToScrollEvent(self:CreateAction("OnItemListScroll"))
	self.bindData.itemList:SetSimpleList(#bpData.curRewards)

	if bpData.level - self.offsetIndex < 0 then
		self.bindData.itemList:GoToIndex(0, true)
	else
		self.bindData.itemList:GoToIndex(bpData.level - self.offsetIndex, true)
	end

	self:SetGrandPrizeInfo(bpData.level, true)
	self.bindData:Commit("unlockTitle", TextConfig.GetConfig(self.unlockTitle[bpData.passType]).Text, COMMIT_IMMEDIATELY)

	if gCS.LuaUtils.IsOnPS5 and not self.hasShownEmptyStoreMsg then
		LX6.Utils.PS5Utils.FetchStoreProductDetail(function ()
			local inventory = LX6.Utils.PS5Utils.GetStoreProductInventoryById(self.buyPassChargeEnum.FullPriceLegacy)

			if inventory ~= 0 then
				LX6.Utils.PS5Utils.ShowEmptyStoreMsgBox()

				self.hasShownEmptyStoreMsg = true

				self.bindData.unlockPassBtn:SetActive(false)
			else
				self.bindData.unlockPassBtn:SetActive(true)
			end
		end)
	end

	local showReward = self.GetFirstUnclaimedReward(self)

	if showReward then
		local exchangedShowId = gBattlePassMgr:GetExchangedGoodsId(showReward.id)
		local goodsInfo = BattlePassGoodsConfig.GetConfig(exchangedShowId)
		self.bindData.mainItemTitle = gBattlePassMgr:GetGoodsName(showReward.id)
		self.bindData.mainItemTypeCtrl = BattlePassType.Free >= showReward.type and 1 or 0
		self.bindData.mainItemQualityCtrl = showReward.quality or 0
		self.bindData.mainItemImageCtrl = self.goodsTypeToIndex[goodsInfo.Type] or 2

		if goodsInfo.Type ~= GoodsType.Vehicle then
			self.bindData.carImage = goodsInfo.baseImage
		else
			self.bindData.dressImage = goodsInfo.baseImage
		end

		self.curMainReward = exchangedShowId
		self.curMainRewardNum = goodsInfo.Type ~= GoodsType.Money and gCommonItemManager:GetExchangeRate(showReward.num) or showReward.num
	end

	self.bindData.openToolTipCtrl = 0

	self.ConditionalShowModelBtn(self)
end

M.OnItemListLayoutSet = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	self.bindData.buyInteractable = bpData.passType == BattlePassType.Legacy
end

M.OnItemListScroll = function(self, vec2)
	local bpData = self.bpData

	if not bpData then
		return
	end

	local idx = bpData.level - 1
	local hideReturnCurrLevelBtn = self.bindData.itemList.VirtualStartIndex < idx and idx > self.bindData.itemList.VirtualEndIndex
	self.bindData.showReturnCurrLevelCtl = BOOL2CTL[not hideReturnCurrLevelBtn]

	if not self.bSliderPressed then
		local x = vec2.x

		if x >= 0 then
			x = 0
		end

		if x <= 1 then
			x = 1
		end

		if self.bindData.page01Slider then
			self.bindData.page01Slider:SetValueWithParams(x, 0, 1, 0.01, false)
		end
	end
end

M.GetFirstUnclaimedReward = function(self)
	local bpData = self.bpData

	if not bpData then
		return nil
	end

	local levelData = bpData.rewardMap[bpData.level]
	local needShowReward = nil

	if levelData then
		local targetType = levelData.claimState

		if targetType + 1 < BattlePassType.Legacy then
			for k, v in ipairs(levelData.rewards) do
				if v.type ~= targetType then
					needShowReward = v

					break
				end
			end
		end
	end

	if not needShowReward and bpData.rewardMap[bpData.level + 1] then
		needShowReward = bpData.rewardMap[bpData.level + 1].rewards[1]
	elseif bpData.level ~= bpData.maxLevel then
		needShowReward = bpData.rewardMap[bpData.level].rewards[1]
	end

	return needShowReward
end

M.OnSimpleRenderRewardTabListItem = function(self, btn, index, data, store, isSub, uList)
	if not self.rewardTabContent or not self.rewardTabContent[index + 1] then
		return
	end

	local data = self.rewardTabContent[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = data
end

M.OnSimpleClickRewardTabList = function(self, uList, isSub)
	local index = uList.selectedIndex

	if index ~= self.selectedTabIndex then
		return
	end

	if index > 0 and index >= #self.rewardTabContent then
		self.SwitchPage(self, index)
	end
end

M.OnChangeStep = function(self, step)
	local nextStep = self:RefreshStep(self.SubGroup.CommonTabSingleStore:GetSelectedIndex(), step, #self.rewardTabContent)

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(nextStep, nil, false)
	self:SwitchPage(nextStep)
end

M.OnChangeBuyStep = function(self, step)
	local count = 1

	if self.bpData and self.bpData.passType ~= BattlePassType.Free then
		count = #BattlePassConfig.BuyTitle
	end

	local nextStep = self:RefreshStep(self.bindData.buyPassTabList.selectedIndex, step, count)

	self.bindData.buyPassTabList:SelectItem(nextStep)
	self:OnSimpleClickBuyPassTabList()
end

M.RefreshStep = function(self, curStep, step, maxCount)
	local nextStep = curStep + step

	if nextStep >= 0 then
		nextStep = maxCount - 1
	elseif maxCount < nextStep then
		nextStep = 0
	end

	return nextStep
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local level = index + 1
	local bpData = self.bpData

	if not bpData or not bpData.rewardMap[level] then
		return
	end

	local data = bpData.rewardMap[level]

	if not data or not data.rewards then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.levelNum = index + 1

	for i = 1, #data.rewards do
		store.itemList:SetItemId(i - 1, level .. i)
	end

	store.itemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderRewardItem", data)

	store.itemList:SetSimpleList(#data.rewards)

	local bShowProgressBar = level < self.knownMaximumAllClaimedOrHaveLockedLevel and level > self.bpData.level
	local bHideProgressBar = not bShowProgressBar
	store.allClaim = BOOL2CTL[bHideProgressBar]

	self:SetGrandPrizeInfo(index + 1)
end

M.OnDynamicRenderItemListItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not store.itemList then
		return
	end

	if not self.bpData or not self.bpData.rewardMap[csIndex + 1] then
		return
	end

	local rewardNum = self.bpData.rewardMap[csIndex + 1].rewards
	store.itemList.rectTransform.sizeDelta = Vector2.New(171.9 * (#rewardNum or 1) - 2 * (#rewardNum - 1), store.itemList.rectTransform.sizeDelta.y)
end

M.OnSimpleRenderGrandPrizeItem = function(self, btn, index)
	self:OnSimpleRenderRewardItem(self.bpData and self.bpData.rewardMap[self.curGrandPrizeLevel], btn, self.curGrandPrizeRewardIdx - 1)
end

M.OnSimpleRenderRewardItem = function(self, data, btn, index)
	if not data or not data.rewards or not data.rewards[index + 1] then
		return
	end

	local itemInfo = data.rewards[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not itemInfo then
		return
	end

	store.claimCtrl = self:SetClaimState(data.claimState, itemInfo.type, data.level)
	store.advanceCtrl = BattlePassType.Free >= itemInfo.type and 1 or 0

	if not itemInfo.id then
		return
	end

	local exchangedId = gBattlePassMgr:GetExchangedGoodsId(itemInfo.id)
	local goodsInfo = BattlePassGoodsConfig.GetConfig(exchangedId)
	store.itemIcon = goodsInfo.icon or 0
	local displayNum = itemInfo.num

	if goodsInfo.Type ~= GoodsType.Money then
		displayNum = gCommonItemManager:GetExchangeRate(displayNum)
	end

	store.goodsNum = self:ExtractNum(displayNum)
	store.qualityCtrl = itemInfo.quality
	local canGetReward = store.claimCtrl ~= 0 and data.level > (self.bpData and self.bpData.level or 0)
	local rewardInfo = {
		level = data.level,
		canGetReward = canGetReward,
		icon = goodsInfo.icon,
		baseImage = goodsInfo.baseImage,
		backGround = goodsInfo.Background,
		model = goodsInfo.Model,
		name = gBattlePassMgr:GetGoodsName(itemInfo.id),
		desc = gBattlePassMgr:GetGoodsDesc(itemInfo.id),
		type = itemInfo.type,
		quality = itemInfo.quality,
		mainItemType = goodsInfo.Type,
		id = exchangedId,
		num = displayNum,
		index = index + 1,
		rewardType = goodsInfo.Type
	}
	store.getRewardBtn.luaClick = self:CreateActionWithArgs("OnTryGetReward", rewardInfo)
end

M.SetClaimState = function(self, claimState, itemType, level)
	local state = 0

	if bit.lshift(1, itemType) < claimState then
		state = 1
	elseif (self.bpData and self.bpData.passType or BattlePassType.Free) >= itemType then
		state = 2
	end

	self.Log(self, "[claimState]", state, level)

	return state
end

M.OnTryGetReward = function(self, data)
	if not data then
		return
	end

	self.bindData.mainItemTitle = data.name

	if data.rewardType ~= GoodsType.Vehicle then
		self.bindData.carImage = data.baseImage
	else
		self.bindData.dressImage = data.baseImage
	end

	self.bindData.mainItemTypeCtrl = BattlePassType.Free >= data.type and 1 or 0
	self.bindData.mainItemQualityCtrl = data.quality
	self.bindData.mainItemImageCtrl = self.goodsTypeToIndex[data.mainItemType] or 2
	self.curMainReward = data.id
	self.curMainRewardNum = data.num

	self:ConditionalShowModelBtn()

	if data.canGetReward then
		self.AskClaimAllReward(self)
	end

	if self.bindData.openTooltipBtn.isTooltipOpen then
		self.bindData.openTooltipBtn:CloseTooltip(true)
	end
end

M.GetGrandPrizeLevel = function(self, curLevel)
	local success, min, max = self.bindData.itemList:TryGetVisualRange(0, 0)

	if success then
		curLevel = max + 1
	end

	local grandPrizeLevelList = {}

	for i = #self.significantPrizeRules, 1, -1 do
		local rule = self.significantPrizeRules[i]

		if rule then
			table.insert(grandPrizeLevelList, rule.level)
		end
	end

	for _, level in ipairs(grandPrizeLevelList) do
		if curLevel < level then
			return level
		end
	end
end

M.SetGrandPrizeInfo = function(self, curLevel, isForce)
	local newGrandPrize = self.GetGrandPrizeLevel(self, curLevel)

	if self.curGrandPrizeLevel ~= newGrandPrize and not isForce then
		return
	end

	self.curGrandPrizeLevel = newGrandPrize
	local store = gStoreManager:GetStoreGroup(self.bindData.grandPrizeBtn.Store):GetStoreByWidget(self.bindData.grandPrizeBtn)

	if not store then
		return
	end

	store.levelNum = self.curGrandPrizeLevel
	local rewards = {}

	for i, v in ipairs(self.bpData.curRewards[self.curGrandPrizeLevel].rewards) do
		rewards[v.id] = i
	end

	local showRewardIdx = nil

	for _, rule in ipairs(self.significantPrizeRules) do
		if rule.level < self.curGrandPrizeLevel and rule.itemId and rewards[rule.itemId] then
			showRewardIdx = rewards[rule.itemId]
		end
	end

	self.curGrandPrizeRewardIdx = showRewardIdx
	store.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGrandPrizeItem")

	if self.bpData and self.bpData.curRewards[self.curGrandPrizeLevel] and showRewardIdx then
		store.itemList:SetSimpleList(1)
	else
		store.itemList:SetSimpleList(0)
	end
end

M.OnRenderMainTooltip = function(self, btn, popup, index)
	if not self.curMainReward then
		return
	end

	local rewardInfo = BattlePassGoodsConfig.GetConfig(self.curMainReward)
	local tooltipData = gCommonItemManager:GetItemRenderData({
		["\\xf0\\xc8;\n!\\xf5"] = false,
		itemId = rewardInfo.BindId,
		itemNum = self.curMainRewardNum or 1
	})

	gCommonItemManager:OnRenderToolTips(tooltipData, btn, popup, index)

	self.recentTooltipBtn = btn
end

M.OnClickBackToCurrentLevel = function(self)
	local targetIdx = self.bpData.level - self.offsetIndex

	if targetIdx >= 0 then
		targetIdx = 0
	end

	self.bindData.itemList:GoToIndex(targetIdx, true)

	self.bindData.showReturnCurrLevelCtl = BOOL2CTL[false]

	if self.bindData.giftListAni then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.giftListAni, "S_Vx_BattlePassPanel_giftlist")
	end
end

M.OnClickShowModelBtn = function(self)
	if not self.curMainReward then
		return
	end

	local rewardInfo = BattlePassGoodsConfig.GetConfig(self.curMainReward)
	local commodityId = rewardInfo.CommodityId

	if commodityId and type(commodityId) ~= "table" then
		commodityId = commodityId[1]
	end

	if not commodityId then
		return
	end

	local spiritId = rewardInfo.Model or gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.ClientData.cardId

	self:StopShowingModels()
	self:DisableModelCameraControl()

	self.currPreviewModelKind = gMallSceneManager:PreviewCommodityById(commodityId or 0, {
		spiritId = spiritId,
		onLoaded = function ()
			if rewardInfo.Type ~= LTConfig.BattlePassGoodsConfig.TypeType.Vehicle then
				gMallSceneManager:ApplyMallSceneCamera(true)
			else
				gMallSceneManager:ApplyMallSceneCamera(false)
			end

			self:UpdateModelCameraControl()
		end
	})
end

M.ConditionalShowModelBtn = function(self)
	if not self.curMainReward or self.bindData.pageCtrl == self.pageCtrlEnum.Rewards then
		self.bindData.showModelBtnCtl = BOOL2CTL[false]

		return
	end

	local rewardInfo = BattlePassGoodsConfig.GetConfig(self.curMainReward)
	local type = rewardInfo.Type
	local show = rewardInfo.CommodityId and rewardInfo.CommodityId == 0
	self.bindData.showModelBtnCtl = BOOL2CTL[show]
end

M.DisableModelCameraControl = function(self)
	if not self.modelCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.modelCameraEnabled = false
end

M.UpdateModelCameraControl = function(self)
	local params = self.BuildModelCameraParams(self)

	if not params then
		self.DisableModelCameraControl(self)

		return
	end

	self.bindData.hideAllUICtl = BOOL2CTL[true]

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, params)

	self.modelCameraEnabled = true
end

M.StopShowingModels = function(self)
	gMallSceneManager:ClearCharacterModel()
	gMallSceneManager:ClearVehicle()
	gMallSceneManager:ClearWeapon()
	self:DisableModelCameraControl()

	self.bindData.hideAllUICtl = BOOL2CTL[false]
	self.currPreviewModelKind = nil
end

M.IsReviewingModel = function(self)
	return self.modelCameraEnabled
end

M.BuildModelCameraParams = function(self)
	local modelRoot = self.GetCurrentModelRoot(self)

	if not modelRoot then
		return nil
	end

	local rotateCenter, autoRotateRecenter = nil
	local allowRotateModelAroundAllAxis = false

	if self.currPreviewModelKind ~= gMallSceneManager.LoadingType.Weapon then
		rotateCenter = gCS.LuaUtils.CalcMeshModelCenterGo(gMallSceneManager.currentWeaponGo)
		autoRotateRecenter = true
		allowRotateModelAroundAllAxis = true
	end

	local vCamera = gMallSceneManager and gMallSceneManager.mallVCamera
	local cameraControlConfig = gMallCameraManager:BuildMallCameraControlConfig(self.currPreviewModelKind)

	return {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = vCamera,
		modelRoot = modelRoot,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig,
		rotateCenter = rotateCenter,
		autoRotateRecenter = autoRotateRecenter,
		allowRotateModelAroundAllAxis = allowRotateModelAroundAllAxis
	}
end

M.GetCurrentModelRoot = function(self)
	local target = nil

	if self.currPreviewModelKind ~= gMallSceneManager.LoadingType.Weapon then
		target = gMallSceneManager.currentWeaponGo
	elseif self.currPreviewModelKind ~= gMallSceneManager.LoadingType.Vehicle then
		target = gMallSceneManager.currentVehicle and gMallSceneManager.currentVehicle.gameObject
	else
		target = gMallSceneManager.currentModelUnit and gMallSceneManager.currentModelUnit.PlayerObj
	end

	if target and not gCS.LuaUtils.IsNull(target) then
		return target.transform
	end

	return nil
end

M.OnCloseMainTooltip = function(self)
	if self.bindData.openToolTipCtrl ~= 1 then
		self.bindData.openToolTipCtrl = 0
	end
end

M.GetGoodsName = function(self, goodId)
	local cfg = BattlePassGoodsConfig.GetConfig(goodId)

	if cfg then
		local consumableId = cfg.BindId
		local consumableCfg = ConsumableConfig.GetConfig(consumableId)

		if consumableCfg then
			return consumableCfg.Name
		end
	end

	return cfg.name
end

M.GetGoodsDesc = function(self, goodId)
	local cfg = BattlePassGoodsConfig.GetConfig(goodId)

	if cfg then
		local consumableId = cfg.BindId
		local consumableCfg = ConsumableConfig.GetConfig(consumableId)

		if consumableCfg then
			return consumableCfg.Description or ""
		end
	end

	return ""
end

M.OnRewardPageSliderValueChanged = function(self, value)
	local rectTransform = self.bindData.itemList:GetContentRT()
	local itemListWidth = self.bindData.itemList.rectTransform.rect.width

	self.bindData.itemList:GoToPos(Vector2.New(-(rectTransform.rect.width - itemListWidth) * value, 0), true)
end

M.OnSliderPress = function(self)
	self.bSliderPressed = true
end

M.OnSliderRelease = function(self)
	self.bSliderPressed = false
end

M.RefreshTaskPage = function(self)
	if not self.taskType or self.taskType == self.taskEnum.Weekly and self.taskType == self.taskEnum.Challenge then
		self.taskType = self.taskEnum.Weekly
	end

	self.bindData:Commit("bpBg", self.bpCfg.TaskBackgroundImage, COMMIT_FORCE)
	self:UpdateLevelInfo(self.taskLevelStore)
	self.bindData.taskTabList:SetSimpleList(#self.taskTabContent)
	self.bindData.taskTabList:SetItemSelected(self.taskType, true)

	for i = 1, #self.taskTabContent do
		self.bindData.taskTabList:SetItemId(i - 1, i)
	end

	local bpData = self.bpData

	if not bpData then
		return
	end

	if bpData.curTaskGroups[self.taskEnum.Challenge] then
		table.sort(bpData.curTaskGroups[self.taskEnum.Challenge], function (a, b)
			local wa = a.claimState ~= 1 and 0 or a.claimState ~= 2 and 2 or 1
			local wb = b.claimState ~= 1 and 0 or b.claimState ~= 2 and 2 or 1

			if wa == wb then
				return wa <= wb
			end

			return a.taskId <= b.taskId
		end)
	end

	local taskList = bpData.curTaskGroups[self.taskType] or {}

	self.bindData.taskList:SetSimpleList(#taskList)

	if self.taskType ~= self.taskEnum.Challenge and bpData.curTaskGroups[self.taskType] then
		for i = 1, #bpData.curTaskGroups[self.taskType] do
			local taskId = bpData.curTaskGroups[self.taskType][i].taskId

			self.bindData.taskList:SetItemId(i - 1, taskId)
		end
	end
end

M.OnClickTaskTabLeftBtn = function(self)
	local idx = self.bindData.taskTabList.selectedIndex - 1

	if idx >= 0 then
		idx = #self.taskTabContent - 1
	end

	self.bindData.taskTabList:SelectItem(idx)
	self:OnSimpleClickTaskTabList()
end

M.OnClickTaskTabRightBtn = function(self)
	local idx = self.bindData.taskTabList.selectedIndex + 1

	if idx > #self.taskTabContent then
		idx = 0
	end

	self.bindData.taskTabList:SelectItem(idx)
	self:OnSimpleClickTaskTabList()
end

M.RefreshTaskProgress = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	local allTasks = gEventConditionUtils.GetModuleEventProgressInfo(UX.Game.EventConditionImplModule.BattlePassTask, 0)
	local finishedTasks = allTasks.FinishedTemplateIdList
	local inProgressTasks = allTasks.EventProgressInfoDict

	for _, taskId in ipairs(finishedTasks) do
		if bpData.taskMap[taskId] then
			bpData.taskMap[taskId].curProgress = -1
		end
	end

	for taskId, info in pairs(inProgressTasks) do
		if bpData.taskMap[taskId] then
			bpData.taskMap[taskId].curProgress = info.Value
		end
	end
end

M.OnSimpleRenderTaskListItem = function(self, btn, index)
	local bpData = self.bpData

	if not bpData or not bpData.curTaskGroups[self.taskType] or not bpData.curTaskGroups[self.taskType][index + 1] then
		return
	end

	local data = bpData.curTaskGroups[self.taskType][index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.taskTitle = data.taskName
	store.staticBlur.sourceImage = self.bindData.bpBgRef
	local bShowProgressText = true

	if self.taskType ~= self.taskEnum.Weekly then
		store.taskStateCtrl = data.isShowGoto and 1 or 0
	elseif data.claimState ~= ChallengeTaskState.Claimable or data.claimState ~= -1 and data.curProgress ~= -1 then
		store.taskStateCtrl = 2
		bShowProgressText = false
	elseif data.claimState ~= ChallengeTaskState.Claimed then
		store.taskStateCtrl = 3
		bShowProgressText = false
	else
		store.taskStateCtrl = data.isShowGoto and 1 or 0
	end

	local progressText = ""

	if data.isShowProgress then
		local curProgressText = self:ExtractNum(data.curProgress ~= -1 and 0 or data.curProgress)
		local maxProgressText = self:ExtractNum(data.maxProgress)

		if maxProgressText ~= 1 then
			bShowProgressText = false
		end

		if bShowProgressText then
			progressText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901356).Text, curProgressText, maxProgressText)
		end
	end

	store.descText = data.taskDesc .. progressText
	local completeText = bpData.curTaskGroups[self.taskType][index + 1].completionCount

	if self.taskType ~= self.taskEnum.Challenge then
		store.completeText = ""
	else
		store.completeText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901344).Text, completeText)
	end

	store.claimBtn.luaClick = self.CreateActionWithArgs(self, "OnClaimChallengeTaskReward", data.taskId)
	store.gotoBtn.luaClick = self.CreateActionWithArgs(self, "OnHyperLinkTask", data.hyperLinkId)
	store.numText = data.taskExp
end

M.OnSimpleRenderTaskTabListItem = function(self, btn, index)
	if not self.taskTabContent or not self.taskTabContent[index + 1] then
		return
	end

	local data = self.taskTabContent[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = data
end

M.OnSimpleClickTaskTabList = function(self)
	self.taskType = self.bindData.taskTabList.selectedIndex

	if self.taskType > 0 and self.taskType >= #self.taskTabContent then
		local bpData = self.bpData

		self.bindData.taskList:SetSimpleList(bpData and #bpData.curTaskGroups[self.taskType] or 0)
	end
end

M.OnClaimChallengeTaskReward = function(self, taskId)
	local bpData = self.bpData

	if not bpData then
		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskClaimChallengeTaskReward(bpData.bpId, taskId).Callback = function (err, data)
		if err ~= MessageConfig.Ok and bpData.taskMap[taskId] then
			local previewMaterials = {}

			table.insert(previewMaterials, {
				ItemId = tostring(BattlePassConfig.Exp),
				Count = bpData.taskMap[taskId].taskExp
			})
			gDropManager:ShowRewardWindow({
				Param = previewMaterials
			})
		end
	end
end

M.OnHyperLinkTask = function(self, hyperLinkId)
	if not hyperLinkId or hyperLinkId ~= 0 then
		return
	end

	local hyper, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	if hyper and hyper.callback then
		hyper.callback()
	end
end

M.OnRefreshTaskInfo = function(self)
	if self.bindData.pageCtrl ~= self.pageCtrlEnum.Rewards then
		self.RefreshRewardPage(self)
	else
		self.RefreshTaskProgress(self)
		self.RefreshTaskPage(self)
	end
end

M.RefreshBuyPassPage = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	if bpData.passType ~= BattlePassType.Free then
		self.bindData.buyPassTabList:SetSimpleList(#BattlePassConfig.BuyTitle)

		self.bindData.buyTypeCtrl = 0
		self.curPassChargeType = self.buyPassChargeEnum.Advanced
	else
		self.bindData.buyPassTabList:SetSimpleList(1)

		self.bindData.buyTypeCtrl = 1
		self.curPassChargeType = self.buyPassChargeEnum.DiffPriceLegacy
	end

	self.bindData.buyPassTabList:SetItemSelected(0, true)
	self.bindData.buyAdvanceList:SetSimpleList(#bpData.advanceDisplay)
	self.bindData.buyLegacyList:SetSimpleList(#bpData.legacyDisplay)

	self.bindData.advanceDesc = TextConfig.GetConfig(73977039).Text
	self.bindData.legacyDesc = TextConfig.GetConfig(73977040).Text
	self.bindData.buyPassBtn.interactable = bpData.passType == BattlePassType.Legacy
	local buyTabIndex = self.bindData.buyPassTabList.selectedIndex
	local isFree = bpData.passType ~= BattlePassType.Free
	local buyBtnText, buyTypeCtrl, curPassChargeType = self:GetBuyPassInfo(buyTabIndex, isFree)

	if gCS.LuaUtils.IsOnPS5 then
		local ps5Price = LX6.Utils.PS5Utils.GetStoreProductPriceById(curPassChargeType)

		if ps5Price then
			self.bindData.buyBtnText = ps5Price
		else
			self.bindData.buyBtnText = BattlePassConfig.Money .. buyBtnText
		end
	else
		self.bindData.buyBtnText = BattlePassConfig.Money .. buyBtnText
	end

	self.bindData.buyTypeCtrl = buyTypeCtrl
end

M.OnGetBuyPassTabListTIndex = function(self, index)
	if not self.bpData or self.bpData.passType == BattlePassType.Free then
		index = 1
	end

	return index
end

M.OnSimpleRenderBuyPassTabListItem = function(self, btn, index)
	local _, _, _, titleText = self:GetBuyPassInfo(index, self.bpData and self.bpData.passType ~= BattlePassType.Free)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = titleText
end

M.OnSimpleRenderBuyAdvanceListItem = function(self, btn, index)
	self:RenderBuyListItem(self.bpData and self.bpData.advanceDisplay, btn, index)
end

M.OnBuyLegacyListGetTIndex = function(self, index)
	local legacyItem = self.bpData and self.bpData.legacyDisplay[index + 1]

	if legacyItem and legacyItem.itemId ~= LTConfig.BattlePassConfig.AdvancedPassItemId then
		return 1
	end

	return 0
end

M.OnSimpleRenderBuyLegacyListItem = function(self, btn, index)
	self:RenderBuyListItem(self.bpData and self.bpData.legacyDisplay, btn, index)
end

M.RenderBuyListItem = function(self, data, btn, index)
	if not data or not data[index + 1] then
		return
	end

	local itemInfo = data[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not itemInfo then
		return
	end

	if not itemInfo.itemId then
		return
	end

	local exchangedBuyId = gBattlePassMgr:GetExchangedGoodsId(itemInfo.itemId)
	local goodsInfo = BattlePassGoodsConfig.GetConfig(exchangedBuyId)

	if not goodsInfo then
		return
	end

	local displayBuyNum = itemInfo.num

	if goodsInfo.Type ~= GoodsType.Money then
		displayBuyNum = gCommonItemManager:GetExchangeRate(displayBuyNum)
	end

	store.goodsNum = self:ExtractNum(displayBuyNum)
	store.qualityCtrl = gBattlePassMgr:GetGoodTypeInfo(goodsInfo.Type, goodsInfo.BindId)
	store.itemIcon = goodsInfo.icon or 0
	local tooltipFunc = self:CreateActionWithArgs("OnRenderBuyPassTooltip", {
		itemInfo = itemInfo,
		btn = btn
	})

	if store.openToolTipBtn then
		store.openToolTipBtn.luaRenderTooltip = tooltipFunc
	elseif btn then
		btn.luaRenderTooltip = tooltipFunc
	end
end

M.OnSimpleClickBuyPassTabList = function(self)
	local buyTabIndex = self.bindData.buyPassTabList.selectedIndex
	local isFree = self.bpData and self.bpData.passType ~= BattlePassType.Free
	local buyBtnText, buyTypeCtrl, curPassChargeType = self:GetBuyPassInfo(buyTabIndex, isFree)

	if gCS.LuaUtils.IsOnPS5 then
		local ps5Price = LX6.Utils.PS5Utils.GetStoreProductPriceById(curPassChargeType)

		if ps5Price then
			self.bindData.buyBtnText = ps5Price
		else
			self.bindData.buyBtnText = BattlePassConfig.Money .. buyBtnText
		end
	else
		self.bindData.buyBtnText = BattlePassConfig.Money .. buyBtnText
	end

	self.bindData.buyTypeCtrl = buyTypeCtrl
	self.curPassChargeType = curPassChargeType

	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		self.bindData.buyAdvanceList:SetNavSelectToTop()
		self.bindData.buyLegacyList:SetNavSelectToTop()
	end
end

M.OnRenderBuyPassTooltip = function(self, data, btn, popup, index)
	local itemInfo = data.itemInfo
	self.recentTooltipBtn = btn
	local exchangedTooltipId = gBattlePassMgr:GetExchangedGoodsId(itemInfo.itemId)
	local rewardInfo = BattlePassGoodsConfig.GetConfig(exchangedTooltipId)

	if not rewardInfo then
		return
	end

	local tooltipData = gCommonItemManager:GetItemRenderData({
		["\\xf0\\xc8;\n!\\xf5"] = false,
		itemId = rewardInfo.BindId,
		itemNum = itemInfo.num or 1
	})

	gCommonItemManager:OnRenderToolTips(tooltipData, btn, popup, index)
end

M.GetBuyPassInfo = function(self, buyTabIndex, isFree)
	local buyBtnText, buyTypeCtrl, curPassChargeType, curPassTitleText = nil

	if isFree then
		buyBtnText = buyTabIndex ~= 0 and self.bpData.advancePrice or self.bpData.legacyPrice
		buyTypeCtrl = buyTabIndex ~= 0 and 0 or 1
		curPassChargeType = buyTabIndex ~= 0 and self.buyPassChargeEnum.Advanced or self.buyPassChargeEnum.FullPriceLegacy
		curPassTitleText = buyTabIndex ~= 0 and BattlePassConfig.BuyTitle[1] or BattlePassConfig.BuyTitle[2]
		self.bindData.buyLeftBtn.activation = true
		self.bindData.buyRightBtn.activation = true
		self.bindData.showControllerTabKeyCtrl = 0
	else
		buyBtnText = self.bpData.legacyPrice - self.bpData.advancePrice
		buyTypeCtrl = 1
		curPassChargeType = self.buyPassChargeEnum.DiffPriceLegacy
		curPassTitleText = BattlePassConfig.BuyLegacyTitle
		self.bindData.buyLeftBtn.activation = false
		self.bindData.buyRightBtn.activation = false
		self.bindData.showControllerTabKeyCtrl = 1
	end

	return buyBtnText, buyTypeCtrl, curPassChargeType, curPassTitleText
end

M.OnClickBuyPassBtn = function(self)
	gMallManager:CheckOrder(self.curPassChargeType, 1, "")
end

M.RefreshBuyLevelPage = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	self.SubGroup.CommonBuyNumSliderStore:SetData({
		range = {
			1,
			math.max(bpData.maxLevel - bpData.level, 1)
		},
		data = {
			moneyId = bpData.buyPassCurrencyId,
			price = bpData.buyPassCurrencyNum
		},
		valChangeCallback = self:CreateAction("OnBuyLevelChange")
	})
end

M.OnSimpleRenderNormalRewardListItem = function(self, btn, index)
	self.RenderBuyListItem(self, self.normalRewardList, btn, index)
end

M.OnSimpleRenderAdvanceRewardListItem = function(self, btn, index)
	self.RenderBuyListItem(self, self.advancedRewardList, btn, index)
end

M.OnBuyLevelChange = function(self, data)
	local bpData = self.bpData

	if not bpData then
		return
	end

	if data <= bpData.maxLevel - bpData.level then
		return
	end

	local firstRewardType = {
		self.buyLevelRewardEnum.Free
	}
	local secondRewardType = {
		self.buyLevelRewardEnum.Advanced
	}

	if bpData.passType ~= BattlePassType.Advanced or bpData.passType ~= BattlePassType.Legacy then
		firstRewardType = self.buyLevelRewardEnum.All
		secondRewardType = self.buyLevelRewardEnum.None
	end

	if firstRewardType ~= self.buyLevelRewardEnum.All then
		self.normalRewardList = self.GetBuyLevelDisplayRewards(self, bpData.level, bpData.level + data)
	else
		self.normalRewardList = self.GetBuyLevelDisplayRewards(self, bpData.level, bpData.level + data, firstRewardType)
	end

	if secondRewardType == self.buyLevelRewardEnum.None then
		self.advancedRewardList = self.GetBuyLevelDisplayRewards(self, bpData.level, bpData.level + data, secondRewardType)
	else
		table.clear(self.advancedRewardList)
	end

	if #self.advancedRewardList ~= 0 then
		self.bindData.buyLevelTypeCtrl = 0
	elseif #self.normalRewardList ~= 0 then
		self.bindData.buyLevelTypeCtrl = 2
	else
		self.bindData.buyLevelTypeCtrl = 1
	end

	self.bindData.normalRewardList:SetSimpleList(#self.normalRewardList)
	self.bindData.advanceRewardList:SetSimpleList(#self.advancedRewardList)

	self.bindData.normalRewardText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901345).Text, #self.normalRewardList)
	self.bindData.advanceRewardText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901346).Text, #self.advancedRewardList)
	self.bindData.oldLevelText = bpData.level
	self.bindData.newLevelText = bpData.level + data
	local needPayMoney = data * bpData.buyLevelCurrencyNum
	local playerMoney = gCommonItemManager:GetPackItemNum(bpData.buyLevelCurrencyId)

	if playerMoney >= needPayMoney then
		self.bindData.buyLevelText = gString.Format(TextConfig.GetConfig(73976023).Text, needPayMoney)
	else
		self.bindData.buyLevelText = gString.Format(TextConfig.GetConfig(73976024).Text, needPayMoney)
	end

	self.curBuyLevelNum = data
end

M.GetBuyLevelDisplayRewards = function(self, levelStart, levelEnd, typeLimit)
	if levelEnd >= levelStart then
		return {}
	end

	local bpData = self.bpData

	if not bpData then
		return {}
	end

	local maxLevel = bpData.maxLevel

	if maxLevel >= levelEnd then
		levelEnd = maxLevel
	end

	local startSnapshot = bpData.rewardsCache[levelStart] or {}
	local endSnapshot = bpData.rewardsCache[levelEnd] or {}
	local targetTypes = {}

	if typeLimit ~= nil then
		for tType, _ in pairs(endSnapshot) do
			table.insert(targetTypes, tType)
		end
	else
		targetTypes = typeLimit
	end

	local resultDict = {}

	for _, tType in ipairs(targetTypes) do
		local endTypeMap = endSnapshot[tType]

		if endTypeMap then
			local startTypeMap = startSnapshot[tType] or {}

			for id, endCount in pairs(endTypeMap) do
				local startCount = startTypeMap[id] or 0
				local delta = endCount - startCount

				if delta <= 0 then
					if not resultDict[id] then
						resultDict[id] = {
							["\\x80}k"] = 0,
							itemId = id
						}
					end

					resultDict[id].num = resultDict[id].num + delta
				end
			end
		end
	end

	local resultList = {}

	for _, item in pairs(resultDict) do
		table.insert(resultList, item)
	end

	table.sort(resultList, function (a, b)
		return a.itemId <= b.itemId
	end)

	return resultList
end

M.OnBattlePassTypeChange = function(self)
	self.SwitchPage(self, self.pageCtrlEnum.Rewards)
end

M.OnClaimRewards = function(self)
	if self.bindData.pageCtrl ~= self.pageCtrlEnum.BuyLevels then
		return
	end

	self.SwitchPage(self, self.pageCtrlEnum.Rewards)
end

M.OnClickBuyLevelBtn = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	local buyNum = self.curBuyLevelNum or 1
	local totalPrice = buyNum * bpData.buyLevelCurrencyNum

	local doAskBuy = function(onComplete)
		gClientToGameDelegate:AskBuyBattlePassLevels(bpData.bpId, buyNum).Callback = function (err, data)
			if err ~= MessageConfig.Ok then
				if onComplete then
					onComplete(true)
				end

				local aniName = "S_Vx_BattlePassPanel_page04levelupPC"

				if not gCS.LuaUtils.IsNonMobileAdaptive() then
					aniName = "S_Vx_BattlePassPanel_page04levelup"
				end

				gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, aniName)

				if self.bindData.pageCtrl ~= self.pageCtrlEnum.BuyLevels then
					self:RefreshBuyLevelPage()
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if onComplete then
					onComplete(false)
				end
			end
		end
	end

	gMallManager:TryBuyWithMoneyCheck(totalPrice, bpData.buyLevelCurrencyId, function ()
		doAskBuy(nil)
	end, {
		retryFunc = doAskBuy
	})
end

M.AskClaimAllReward = function(self)
	local bpData = self.bpData

	if not bpData then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskClaimAllBattlePassReward(bpData.bpId).Callback = function (err, data)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.ExtractNum = function(self, num)
	if num > 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num > 1000 then
		return string.format("%.1fK", num / 1000)
	end

	return num
end

M.Log = function(self, ...)
	if self.isDebug then
		print_warn("[BattlePass]", ...)
	end
end
