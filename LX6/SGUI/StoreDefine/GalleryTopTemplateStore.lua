-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryTopTemplateStore.lua
-- Decompiled from: 01731_GalleryTopTemplateStore.lua_20940bd4a6b0.luajit

C_GalleryTopTemplateStore = DefClass("C_GalleryTopTemplateStore", C_GalleryTopTemplateStore, C_StoreGroup)
GroupName2Class.GalleryTopTemplateStore = C_GalleryTopTemplateStore
GroupName2Class.GalleryCarTopTemplateStore = C_GalleryTopTemplateStore
GroupName2Class.GalleryWeaponTopTemplateStore = C_GalleryTopTemplateStore
GroupName2Class.GalleryFurnitureTopTemplateStore = C_GalleryTopTemplateStore
GroupName2Class.GalleryClothesTopTemplateStore = C_GalleryTopTemplateStore
local M = C_GalleryTopTemplateStore

M.ctor = function(self)
	self.searchResultListData = {}
	self.onSearchItemClick = nil
	self.currentActiveAreaCo = nil
	self.switchSearchNodeAreaCo = nil
	self.switchToRootArea = nil
	self.curFirstClassId = nil
	self.creditItemType = nil
	self.playerGalleryHead = nil
	self.hostPanelId = nil
end

M.OnAwake = function(self)
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputValueChanged")
	self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputFieldActivate")
	self.bindData.searchResultList.luaSimpleRenderItem = self.CreateAction(self, "OnSearchResultRenderItem")
	self.bindData.searchResultList.onGetTIndex = self.CreateAction(self, "OnGetSearchResultListTIndex")
	self.bindData.searchMaskButton.luaClick = self.CreateAction(self, "OnSearchMaskClick")
	self.bindData.searchExitButton.luaClick = self.CreateAction(self, "OnSearchExitClick")
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
	self.msgEvents = {}

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

M.SetData = function(self, data)
	if not data then
		return
	end

	self.onSearchItemClick = data.onSearchItemClick
	self.switchToRootArea = data.switchToRootArea
	self.creditItemType = data.creditItemType
	self.hostPanelId = data.hostPanelId
	self.bindData.searchNodeActive = false

	self.InitPlayerFashionHead(self)
end

M.InitPlayerFashionHead = function(self)
	local playerGalleryHead = self.bindData.playerGalleryHead

	if not playerGalleryHead then
		return
	end

	self.playerGalleryHead = gStoreManager:GetStoreGroup(playerGalleryHead.Store):GetStoreByWidget(playerGalleryHead)

	if not self.playerGalleryHead then
		return
	end

	local currentCredit = gGalleryManager.GetTotalCredit()
	local nextLevelPoint = gGalleryManager.GetNextLevelPoint(currentCredit)
	self.playerGalleryHead.fillPercent = nextLevelPoint <= 0 and currentCredit / nextLevelPoint or 1
	self.bindData.unlockNum = tostring(currentCredit)
	self.bindData.allNum = tostring(nextLevelPoint)

	self:RefreshPlayerAvatar()

	if self.playerGalleryHead.button then
		self.playerGalleryHead.button.luaClick = function()
			gPanelManager:CheckShow(gPanelId.PLAYER_GALLERY_PANEL)
		end
	end
end

M.RefreshPlayerAvatar = function(self)
	local headStore = self.playerGalleryHead

	if not headStore or not gClientUtils.NotNil(headStore.avatar) then
		return
	end

	local avatarStore = gStoreManager:GetStoreGroup(headStore.avatar.Store):GetStoreByWidget(headStore.avatar)

	if not avatarStore or not avatarStore.userInfoLight then
		return
	end

	avatarStore.userInfoLight.pid = gPlayerManager.infoLogin.bindData.pid
	avatarStore.isSelfCtrl = 1
	avatarStore.isEmptyCtrl = 0
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
	self.searchResultListData = gGalleryManager:SearchGalleryItems(searchText)

	self.bindData.searchResultList:SetSimpleList(#self.searchResultListData)
end

M.OnSearchResultRenderItem = function(self, btn, index)
	local data = self.searchResultListData[index + 1]

	if not data or data.tIndex == 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = gGalleryManager:GetSearchItemDisplayInfo(data)
	store.title = info.title
	store.category = info.category
	store.hasUnlockedControl = info.hasUnlocked and 1 or 0

	store.button.luaClick = function()
		self.lastActiveContent = btn

		self:OnSearchResultClick(info)
	end
end

M.OnSearchResultClick = function(self, info)
	if not info or not info.itemId or not info.panelId then
		return
	end

	self.ClearSearchText(self, true)

	if self.onSearchItemClick and self.onSearchItemClick(info) then
		return
	end

	local hostPanelId = self.hostPanelId
	local targetPanelId = info.panelId

	if hostPanelId and hostPanelId ~= targetPanelId then
		return
	end

	local jumpData = {
		targetItemId = info.itemId,
		targetItemType = info.itemType,
		targetBrandId = info.brandId
	}

	if hostPanelId then
		gPanelManager:Close(hostPanelId)
	end

	gPanelManager:CheckShow(targetPanelId, jumpData)
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

	self.ClearMessageEvents(self)
end
