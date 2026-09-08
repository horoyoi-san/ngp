-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeTopTemplateStore.lua
-- Decompiled from: 01577_BaikeTopTemplateStore.lua_708864f67dba.luajit

C_BaikeTopTemplateStore = DefClass("C_BaikeTopTemplateStore", C_BaikeTopTemplateStore, C_StoreGroup)
GroupName2Class.BaikeTopTemplateStore = C_BaikeTopTemplateStore
local M = C_BaikeTopTemplateStore

M.ctor = function(self)
	self.searchResultListData = {}
	self.onSearchItemClick = nil
	self.currentActiveAreaCo = nil
	self.switchSearchNodeAreaCo = nil
	self.switchToRootArea = nil
	self.onBeforeOpenPlayFashion = nil
	self.fashionFirstClassId = nil
	self.vehicleFirstClassId = nil
	self.curFirstClassId = nil
end

M.OnAwake = function(self)
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputValueChanged")
	self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputFieldActivate")
	self.bindData.searchResultList.luaSimpleRenderItem = self.CreateAction(self, "OnSearchResultRenderItem")
	self.bindData.searchResultList.onGetTIndex = self.CreateAction(self, "OnGetSearchResultListTIndex")
	self.bindData.searchMaskButton.luaClick = self.CreateAction(self, "OnSearchMaskClick")
	self.bindData.searchExitButton.luaClick = self.CreateAction(self, "OnSearchExitClick")
	local count = LTConfig.CityPediaFirstClassConfig.count

	for i = 0, count - 1 do
		local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.LoadAt(i)

		if cityPediaFirstClassCfg.Type ~= 3 then
			self.fashionFirstClassId = cityPediaFirstClassCfg.Id
		elseif cityPediaFirstClassCfg.Type ~= 4 then
			self.vehicleFirstClassId = cityPediaFirstClassCfg.Id
		end
	end

	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.RegisterMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_BAIKE_CREDIT_INFO_CHANGE] = self.CreateAction(self, "OnCreditInfoChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}

	for eventId, handler in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(eventId, handler)
	end
end

M.ClearMessageEvents = function(self)
	if self.msgEvents then
		for eventId, handler in pairs(self.msgEvents) do
			gMessageManager:RemoveMessageListener(eventId, handler)
		end
	end
end

M.OnCreditInfoChange = function(self)
	self.RefreshPlayerFashionHeadRedDot(self)
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.PLAY_FASHION_PANEL and self.bindData.inputField then
		self.bindData.inputField.interactable = true
	end
end

M.SetData = function(self, data)
	if not data then
		return
	end

	self.onSearchItemClick = data.onSearchItemClick
	self.switchToRootArea = data.switchToRootArea
	self.onBeforeOpenPlayFashion = data.onBeforeOpenPlayFashion
	self.bindData.searchNodeActive = false

	if data.firstClassId then
		self.RefreshUnlockProgress(self, data.firstClassId)
	end
end

M.RefreshUnlockProgress = function(self, firstClassId)
	self.curFirstClassId = firstClassId or self.curFirstClassId

	if not self.curFirstClassId then
		return
	end

	local unlockNum, allNum = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(self.curFirstClassId)
	self.bindData.unlockNum = unlockNum
	self.bindData.allNum = allNum
end

M.InitPlayerFashionHead = function(self)
	local playerFashionHead = self.bindData.playerFashionHead

	if not playerFashionHead then
		return
	end

	self.playerFashionHead = gStoreManager:GetStoreGroup(playerFashionHead.Store):GetStoreByWidget(playerFashionHead)
	local currentCredit = gBaiKeArchiveManager.GetCityPediaCredit()
	local currentLevel = gBaiKeArchiveManager.GetCityPediaCreditLevel()
	local nextLevelCfg = LTConfig.CityPediaCollectionLevelConfig.GetConfig(currentLevel + 1)
	local nextLevelPoint = nextLevelCfg and nextLevelCfg.value or currentCredit
	self.playerFashionHead.fillPercent = currentCredit / nextLevelPoint
	local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
	local cfg = LTConfig.ImageNewAvatarConfig.GetConfig(path)
	self.playerFashionHead.headIcon = (cfg or LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH)).SguiImageId

	self.playerFashionHead.button.luaClick = function()
		if self.onBeforeOpenPlayFashion then
			if self.bindData.inputField then
				self.bindData.inputField.interactable = false
			end

			self.onBeforeOpenPlayFashion()
		end

		gPanelManager:CheckShow(gPanelId.PLAY_FASHION_PANEL)
	end

	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()
	self.playerFashionHead.button.redKey = redDotKey

	self:RefreshPlayerFashionHeadRedDot()
end

M.RefreshPlayerFashionHeadRedDot = function(self)
	if not self.playerFashionHead then
		return
	end

	local hasRedDot = gBaiKeArchiveManager.CheckPlayFashionPanelHasRedDot()
	local redDotKey = gBaiKeArchiveManager.GetPlayFashionPanelRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey, true)
end

M.OnRenderRedDot = function(self, redKey, _, widget)
	if redKey ~= "BaikePlayFashionPanelRedDot" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetPlayFashionPanelRedDotCount()
		end
	end
end

M.OnInputValueChanged = function(self)
	local searchText = self.bindData.inputField.text

	if string.is_null_or_empty(searchText) then
		self.bindData.searchNodeActive = false

		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.searchNodeArea)

		if self.suppressSwitchToRoot then
			self.suppressSwitchToRoot = false
		else
			self.currentActiveAreaCo = coroutine.start(function ()
				coroutine.step()

				if self.switchToRootArea then
					self.switchToRootArea()
				end
			end)
		end

		return
	end

	self.bindData.searchNodeActive = true
	self.searchResultListData = gBaiKeArchiveManager:SearchBaikeItems(searchText, self.fashionFirstClassId, self.vehicleFirstClassId)

	self.bindData.searchResultList:SetSimpleList(#self.searchResultListData)
end

M.OnSearchResultRenderItem = function(self, btn, index)
	local data = self.searchResultListData[index + 1]

	if not data or data.tIndex == 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local info = gBaiKeArchiveManager:GetSearchItemDisplayInfo(data)
	store.title = info.title
	store.category = info.category
	store.hasUnlockedControl = info.hasUnlocked and 1 or 0

	store.button.luaClick = function()
		self.lastActiveContent = btn

		if self.onSearchItemClick then
			self.onSearchItemClick(info.firstClassId, info.itemId, info.brandId, info.type)
		end
	end
end

M.OnGetSearchResultListTIndex = function(self, index)
	local data = self.searchResultListData[index + 1]

	return data and data.tIndex or 0
end

M.OnSearchMaskClick = function(self)
	self.bindData.inputField.text = ""
end

M.OnSearchExitClick = function(self)
	if self.bindData.inputField.text ~= "" then
		self.bindData.searchNodeActive = false
		slot1 = SGUI.UNavigationMgr.Inst

		slot1:UnRegisterArea(self.bindData.searchNodeArea)

		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			if self.switchToRootArea then
				self.switchToRootArea()
			end
		end)

		return
	end

	self.bindData.inputField.text = ""
end

M.ClearSearchText = function(self, suppressSwitchArea)
	if suppressSwitchArea then
		self.suppressSwitchToRoot = true
	end

	self.bindData.inputField.text = ""
end

M.IsSearchActive = function(self)
	return self.bindData.searchNodeActive
end

M.SwitchToSearchNodeArea = function(self, rootGo)
	if self.bindData.searchNodeActive then
		self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)
		self.switchSearchNodeAreaCo = coroutine.start(function ()
			coroutine.step()
			coroutine.step()

			if gClientUtils.NotNil(rootGo) then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
			end
		end)
	end
end

M.OnInputFieldActivate = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
end

M.OnDestroy = function(self)
	self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
	self.switchSearchNodeAreaCo = coroutine.stop(self.switchSearchNodeAreaCo)

	if self.redDotAction then
		SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
	end

	self.ClearMessageEvents(self)
end
