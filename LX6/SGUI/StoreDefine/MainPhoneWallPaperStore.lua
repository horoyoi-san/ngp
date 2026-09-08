-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPhoneWallPaperStore.lua
-- Decompiled from: 01972_MainPhoneWallPaperStore.lua_0218c4c83782.luajit

C_MainPhoneWallPaperStore = DefClass("C_MainPhoneWallPaperStore", C_MainPhoneWallPaperStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.MainPhoneWallPaperStore = C_MainPhoneWallPaperStore
local M = C_MainPhoneWallPaperStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.wallPaperButton.luaClick = self.CreateActionWithArgs(self, "OnBottomTabClick", gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper)
	self.bindData.decorationButton.luaClick = self.CreateActionWithArgs(self, "OnBottomTabClick", gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration)
	self.bindData.pendantButton.luaClick = self.CreateActionWithArgs(self, "OnBottomTabClick", gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant)
	self.bindData.suitButton.luaClick = self.CreateActionWithArgs(self, "OnBottomTabClick", gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.resetButton.luaClick = self.CreateAction(self, "OnResetClick")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.list.luaLayoutSet = self.CreateAction(self, "OnLayoutSet")
	self.bindData.list.luaBeginDrag = self.CreateAction(self, "OnBeginDrag")
	self.bindData.list.luaEndDrag = self.CreateAction(self, "OnEndDrag")
	self.bindData.list.luaDrag = self.CreateAction(self, "OnDrag")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = self.CreateAction(self, "OnActionDeviceChanged")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.navigationMap = {}
	self.mainPhonePageIndex = self.panelArgs and self.panelArgs.mainPhonePageIndex
	self.HORIZONTAL_LIST_TEMPLATE_TYPE = {
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper] = 1,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration] = 0,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant] = 2,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit] = 3
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.initLocalPosition = self.bindData.bottomBackgroundTransform.localPosition
	self.isBottomTabClick = nil
	self.isPlayingAnimation = nil
	self.playAnimationCallback = nil
	self.bottomWidgetMap = {
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper] = {
			normalButton = self.bindData.wallPaperButton,
			selectedButton = self.bindData.sWallPaperButton,
			selectedAnimation = self.bindData.sWallPaperAnimation
		},
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration] = {
			normalButton = self.bindData.decorationButton,
			selectedButton = self.bindData.sDecorationButton,
			selectedAnimation = self.bindData.sDecorationAnimation
		},
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant] = {
			normalButton = self.bindData.pendantButton,
			selectedButton = self.bindData.sPendantButton,
			selectedAnimation = self.bindData.sPendantAnimation
		},
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit] = {
			normalButton = self.bindData.suitButton,
			selectedButton = self.bindData.sSuitButton,
			selectedAnimation = self.bindData.sSuitAnimation
		}
	}
	self.isGamePadMode = gClientUtils.CheckIsGamePadMode()
	self.currentShowType = gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper

	self.bindData.list:RegisterToScrollEvent(self:CreateAction("OnListOnScroll"))
	self:RefreshPanelView()

	self.lastShowType = self.currentShowType
end

M.OnLayoutSet = function(self)
	self.bottomMaxDistance = self.bindData.suitButton.transform.localPosition.x - self.bindData.wallPaperButton.transform.localPosition.x
	self.localPositionXMin = self.initLocalPosition.x
	self.localPositionXMax = self.initLocalPosition.x + self.bottomMaxDistance
	self.bottomStepWidth = self.bottomMaxDistance / 3
	self.lastPositionX = self.initLocalPosition.x
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	self.itemWidth = btn.transform.sizeDelta.x
	slot5 = gStoreManager
	slot5 = slot5:GetStoreGroup(btn.Store)
	local store = slot5:GetStoreByWidget(btn)
	local contentDataList = gMainPhoneUtils.GetSkinPartViewDataList(data.type)

	store.list.luaSimpleRenderItem = function(childBtn, childCsIndex)
		childBtn.luaFocus = function()
			if data.type == self.currentShowType then
				local lastShowType = self.currentShowType
				local nextShowType = data.type
				self.currentShowType = nextShowType
				local animationSpeed = 1

				self:PlayBottomTabChangeAnimation(lastShowType, nextShowType, nil, animationSpeed)
			end

			self.navigationMap[self.currentShowType] = childCsIndex
		end

		local childLuaIndex = childCsIndex + 1
		local childData = contentDataList[childLuaIndex]
		local childStore = gStoreManager:GetStoreGroup(childBtn.Store):GetStoreByWidget(childBtn)

		if childData.id ~= LTConfig.MobileMenuSkinPartConfig.DefaultPendant then
			childStore.typeControl = 0
		else
			childStore.typeControl = 1
			childStore.iconId = gMainPhoneUtils.GetSkinPartIconId(childData.id)
		end

		local isApplyPart = gMainPhoneUtils.CheckIsApplySkinPart(childData.id)
		childStore.selectedActive = isApplyPart

		childStore.button.luaClick = function()
			gMessageManager:SendMessage(gEventConstants.ON_WALL_PAPER_APP_CONTENT_SHOW, {
				secondShowType = gClientConst.WALL_PAPER_SHOW_TYPE.DETAIL,
				targetId = childData.id,
				showType = self.currentShowType,
				mainPhonePageIndex = self.mainPhonePageIndex
			})
		end
	end

	if csIndex ~= 0 then
		store.list.luaLayoutSet = function()
			if not self.hasSetNavSelectToTop then
				store.list:SetNavSelectToTop()

				self.hasSetNavSelectToTop = true
			end
		end
	end

	store.list:SetSimpleList(#contentDataList)
end

M.OnStep = function(self, step)
	if self.isPlayingAnimation then
		self.playAnimationCallback = self.CreateActionWithArgs(self, "OnStep", step)

		return
	end

	local index = self.currentShowType + step
	local itemCount = gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit + 1

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.OnBottomTabClick(self, index)
end

M.OnListOnScroll = function(self)
	if self.isPlayingAnimation then
		return
	end

	if not self.isGamePadMode then
		local targetPosition = self.bindData.list:GetNearestPageIndex()

		if self.currentShowType == targetPosition then
			local lastShowType = self.currentShowType
			local nextShowType = targetPosition
			self.currentShowType = nextShowType

			self.PlayBottomTabChangeAnimation(self, lastShowType, nextShowType)
		end
	end
end

M.OnBottomTabClick = function(self, showType)
	if self.currentShowType ~= showType or self.isPlayingAnimation then
		self.RefreshBottomSingleButtonView(self, showType)

		return
	end

	local lastShowType = self.currentShowType
	local nextShowType = showType
	self.isBottomTabClick = true
	local rootGo = self.rootGo

	self.PlayBottomTabChangeAnimation(self, lastShowType, nextShowType, function ()
		if gClientUtils.NotNil(rootGo) then
			local _, childListButton = self.bindData.list:TryGetChildAt(self.currentShowType, nil)

			if childListButton then
				local childButtonStore = gStoreManager:GetStoreGroup(childListButton.Store):GetStoreByWidget(childListButton)

				if childButtonStore then
					local focusIndex = self.navigationMap[showType] or 0
					local _, childButton = childButtonStore.list:TryGetChildAt(focusIndex, nil)

					if childButton then
						SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = childButton
					end
				end
			end
		end
	end)
end

M.PlayBottomTabChangeAnimation = function(self, lastShowType, nextShowType, callback, animationSpeed)
	self.isPlayingAnimation = true
	local lastNormalButton, _, lastSelectedAnimation = self:GetTargetSelectedWidgetByShowType(lastShowType)
	local nextNormalButton, nextSelectedButton, nextSelectedAnimation = self:GetTargetSelectedWidgetByShowType(nextShowType)
	local firstNormalButton = self:GetTargetSelectedWidgetByShowType(gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper)
	animationSpeed = animationSpeed or 1
	local animationTime = LTConfig.MobileMenuConfig.WallPaperBottomTweenTime / animationSpeed
	local diff = nextNormalButton.transform.localPosition - firstNormalButton.transform.localPosition
	local targetLocalPosition = self.initLocalPosition + diff

	self.bindData.bottomBackgroundTransform:DOKill()
	self.bindData.bottomBackgroundTransform:DOLocalMove(targetLocalPosition, animationTime):SetEase(LTConfig.MobileMenuConfig.WallPaperBottomTweenEaseType)

	local lastAnimationName = nextShowType >= lastShowType and "S_Vx_MainPhoneWallPaper_ButtonTabTemplent_down_L" or "S_Vx_MainPhoneWallPaper_ButtonTabTemplent_down_R"
	local nextAnimationName = nextShowType >= lastShowType and "S_Vx_MainPhoneWallPaper_ButtonTabTemplent_up_L" or "S_Vx_MainPhoneWallPaper_ButtonTabTemplent_up_R"

	lastSelectedAnimation:Play(lastAnimationName)

	local lastAnimationState = lastSelectedAnimation:get_Item(lastAnimationName)
	lastAnimationState.speed = animationSpeed

	nextNormalButton:SetActive(true)

	nextSelectedButton.isSelected = true

	nextSelectedButton:SetActive(true)
	nextSelectedAnimation:Play(nextAnimationName)

	local nextAnimationState = nextSelectedAnimation:get_Item(nextAnimationName)
	nextAnimationState.speed = animationSpeed

	self.bindData.list:GoToPage(nextShowType, false)

	self.playBottomTabAnimationCo = coroutine.stop(self.playBottomTabAnimationCo)
	self.playBottomTabAnimationCo = coroutine.start(function ()
		coroutine.wait(animationTime / 2)

		self.currentShowType = nextShowType

		self:RefreshBottomButtonsView()
		coroutine.wait(animationTime / 2)

		self.isPlayingAnimation = nil

		if self.playAnimationCallback then
			self.playAnimationCallback()

			self.playAnimationCallback = nil
		end

		if callback then
			callback()
		end
	end)
end

M.RefreshBottomButtonsView = function(self)
	for showType, _ in pairs(self.bottomWidgetMap) do
		self.RefreshBottomSingleButtonView(self, showType)
	end
end

M.RefreshBottomSingleButtonView = function(self, showType)
	local widgetMap = self.bottomWidgetMap[showType]

	if showType ~= self.currentShowType then
		widgetMap.selectedButton:SetActive(true)

		widgetMap.selectedButton.isSelected = true

		widgetMap.normalButton:SetActive(false)
	else
		widgetMap.selectedButton:SetActive(false)
		widgetMap.normalButton:SetActive(true)

		widgetMap.normalButton.isSelected = false
	end
end

M.GetTargetSelectedWidgetByShowType = function(self, showType)
	local widgetList = self.bottomWidgetMap[showType]

	return widgetList.normalButton, widgetList.selectedButton, widgetList.selectedAnimation
end

M.RefreshPanelView = function(self)
	self.skinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
	self.viewDataList = self:GetViewDataList()

	self.bindData.list.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
	self:RefreshBottomButtonsView()
end

M.GetViewDataList = function(self)
	local viewDataList = {}

	table.insert(viewDataList, {
		tIndex = self.HORIZONTAL_LIST_TEMPLATE_TYPE[gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper],
		type = gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper
	})
	table.insert(viewDataList, {
		tIndex = self.HORIZONTAL_LIST_TEMPLATE_TYPE[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration],
		type = gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration
	})
	table.insert(viewDataList, {
		tIndex = self.HORIZONTAL_LIST_TEMPLATE_TYPE[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant],
		type = gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant
	})
	table.insert(viewDataList, {
		tIndex = self.HORIZONTAL_LIST_TEMPLATE_TYPE[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit],
		type = gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit
	})

	return viewDataList
end

M.GetCurrentSpiritSkinId = function(self)
	local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local count = LTConfig.MobileMenuSkinConfig.count

	for i = 0, count - 1 do
		local skinCfg = LTConfig.MobileMenuSkinConfig.LoadAt(i)
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(skinCfg.NpcCultivatitonId)
		local fightSpiritId = npcCultivationCfg and npcCultivationCfg.FightSpiritID

		if fightSpiritId ~= currentSpiritId then
			return skinCfg.Id
		end
	end
end

M.OnResetClick = function(self)
	gMainPhoneUtils.OnExecuteSkinPartReset(self.rootGo)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WALL_PAPER_APP_CONTENT_CLOSE)
end

M.OnBeginDrag = function(self)
	self.lastPositionX = self.bindData.bottomBackgroundTransform.localPosition.x
end

M.OnDrag = function(self)
end

M.OnEndDrag = function(self)
end

M.OnActionDeviceChanged = function(self, _)
	self.isGamePadMode = gClientUtils.CheckIsGamePadMode()
end

M.ClearData = function(self)
	self.bottomWidgetMap = {}
	self.hasSetNavSelectToTop = nil
	self.hasSetCurrentActiveContent = nil
	self.lastShowType = nil
	self.playBottomTabAnimationCo = coroutine.stop(self.playBottomTabAnimationCo)

	if gClientUtils.NotNil(self.bindData.bottomBackgroundTransform) then
		self.bindData.bottomBackgroundTransform:DOKill()
	end
end
