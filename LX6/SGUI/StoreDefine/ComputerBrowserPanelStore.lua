-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerBrowserPanelStore.lua
-- Decompiled from: 01545_ComputerBrowserPanelStore.lua_da792658208a.luajit

C_ComputerBrowserPanelStore = DefClass("C_ComputerBrowserPanelStore", C_ComputerBrowserPanelStore, C_StoreGroup)
GroupName2Class.ComputerBrowserPanelStore = C_ComputerBrowserPanelStore
local M = C_ComputerBrowserPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gWebManager
	self.FileType = {
		["\\xee\\xde-#\\xf4"] = 0,
		["\\xbeL@"] = 1
	}
	self.search_result = nil
end

M.OnAwake = function(self)
	self.bindData.webEnterBtn.luaClick = self:CreateAction(self.OnClickWebEnterBtn)
	self.bindData.backBtn.luaClick = self:CreateAction("OnStackBack", self.mgr)
	self.bindData.forwardBtn.luaClick = self:CreateAction("OnStackForward", self.mgr)
	self.bindData.homeBtn.luaClick = self:CreateAction("ReturnToHomePage", self.mgr)
	self.bindData.refreshBtn.luaClick = self:CreateAction(self.OnClickRefreshBtn)
	self.bindData.minBtn.luaClick = self:CreateAction(self.OnClickMinBtn)
	self.bindData.maxBtn.luaClick = self:CreateAction(self.OnClickMaxBtn)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnClickCloseBtn)
	self.bindData.returnTopBtn.luaClick = self:CreateAction(self.OnClickReturnTopBtn)
	self.bindData.escBtn.luaClick = self:CreateAction(self.OnClickEscBtn)
	self.onScrollRectScrollCb = self:CreateAction(self.OnScrollRectScroll)
	slot1 = self.bindData.webContainerRect

	slot1:RegisterToScrollEvent(self.onScrollRectScrollCb)

	self.bindData.webTopInputField.luaValueChanged = self:CreateAction("OnSearchInputChanged")
	self.bindData.searchResultList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderSearchListItem")
	self.bindData.webContainerRect.luaInitContent = self:CreateAction(self.OnInitRect)
	self.OnContainerChangeFunc = self:CreateAction(self.OnChangeContainer)
	self.OnHoverContainerChangeFunc = self:CreateAction(self.OnChangeHoverContainer)
	self.msgEvents = {
		[gEventConstants.WEBSITE_OPEN_URL] = self:CreateAction(self.__OnOpenUrl),
		[gEventConstants.WEBSITE_HOVER_CHANGE] = self:CreateAction(self.__OnHoverChange),
		[gEventConstants.WEBSITE_LAYOUT_RESET] = self:CreateAction(self.RefreshContainer)
	}
	self.bindData.pdfList.luaSimpleRenderItem = self:CreateAction("OnPDFRenderItem")
	self.curretStore = nil
	self.webContainer = nil
	self.hoverContent = nil
end

M.OnInitRect = function(self, container)
	self.webContainer = container
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnChangeContainer = function(self, content)
	local store = gStoreManager:GetStoreGroup(content.Store)

	if not store then
		return
	end

	if self.curretStore ~= store and store.RefreshPage then
		store.RefreshPage(store)

		return
	end

	self.curretStore = store
	self.bindData.hoverActive = BOOL2CTL[false]

	if not store then
		return
	end

	store.parent = self

	if store.OnShow then
		store.OnShow(store)
	end

	local canReturnTop = false

	if store.CanReturnTop then
		local showReturnTop = function(show)
			self:ShowReturnTopBtn(show)
		end

		canReturnTop = store.CanReturnTop(store, showReturnTop)
	end

	self.bindData.returnTopBtnCtl = BOOL2CTL[canReturnTop]

	self.RefreshContainer(self)
end

M.OnChangeHoverContainer = function(self, content)
	if not content then
		return
	end

	self.hoverContent = content

	if self.curretStore and self.curretStore.OnHoverChange then
		self.curretStore:OnHoverChange(content)
	end
end

M.ShowPanel = function(self, computerId, entityId, targetWebpageIndex)
	self.mgr:InitSearchData()

	self.pdfCfg = nil
	local isPdf, cfg = self:IsPdf(computerId)
	self.bindData.webTopInputField.interactable = not isPdf

	if isPdf then
		self.pdfCfg = cfg

		self.InitPDFView(self)

		return
	end

	self.mgr:SetCurrentComputerId(computerId)

	if targetWebpageIndex then
		self.mgr:GoToTargetIndex(targetWebpageIndex)
	elseif self.mgr.showHomePage then
		self.mgr:ReturnToHomePage()
	else
		self.mgr:GoToTargetIndex(self.mgr.homePageList[1])
	end
end

M.IsPdf = function(self, computerId)
	local cfg = LTConfig.ComputerFileConfig.GetConfig(computerId)

	if cfg and cfg.FileType ~= gClientConst.Computer_File_Type.PDF then
		slot3 = gClientToGameDelegate

		slot3:AskComputerFileRead(cfg.Id, false).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return true, cfg
	end

	return false
end

M.InitPDFView = function(self)
	self.bindData.fileType = self.FileType.PDF
	self.bindData.webTopInputField.text = self.pdfCfg.FileTitle .. ".pdf"
	self.pdfDataList = self.pdfCfg.SubFileList

	self.bindData.pdfList:SetSimpleList(#self.pdfDataList)
end

M.OnPDFRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.pdfDataList[luaIndex]

	if id ~= nil then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.image = id
end

M.OnClickWebEnterBtn = function(self)
	local url = self.bindData.webTopInputField.text

	self.mgr:GoToTagetUrl(url)
end

M.OnClickRefreshBtn = function(self)
end

M.OnClickMinBtn = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)

	self.mgr.currentUrl = ""
end

M.OnClickMaxBtn = function(self)
end

M.OnClickCloseBtn = function(self)
	if self.pdfCfg then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)

		self.pdfCfg = nil

		return
	end

	self.TryClose(self)
end

M.TryClose = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
	self.mgr:OnExit()
end

M.OnClickEscBtn = function(self)
	local canGoBack, _ = self.mgr:CheckCanGoBackAndForward()

	if canGoBack then
		self.mgr:OnStackBack()
	else
		self.OnClickCloseBtn(self)
	end
end

M.__OnOpenUrl = function(self, _, data)
	if string.is_null_or_empty(data.url) or not self.webContainer or data.url ~= self.mgr.currentUrl and not data.forceReload then
		return
	end

	local url = data.url
	local webH5 = string.contains(url, "https://")

	if webH5 then
		self.bindData.webViewNode:SetActive(true)
	else
		self.bindData.webTopInputField.text = url

		if not data.forceReload and not string.is_null_or_empty(self.mgr.currentUrl) and self.mgr:GetRealUrl(self.mgr.currentUrl) ~= self.mgr:GetRealUrl(url) then
			FrameTimer.New(function ()
				if self.curretStore and self.curretStore.RefreshPage then
					self.curretStore:RefreshPage()
				end
			end, 0):Start()
			self:OnClickReturnTopBtn()
		else
			local pUrl, hUrl, cfg = self.mgr:GetWebPageConfig(url)

			if data.forceReload then
				self.webContainer.url = ""
			end

			self.webContainer:SetUrlWithCallback(pUrl, self.OnContainerChangeFunc)

			if not string.is_null_or_empty(hUrl) then
				if data.forceReload then
					self.bindData.hoverContainer.url = ""
				end

				self.bindData.hoverContainer:SetUrlWithCallback(hUrl, self.OnHoverContainerChangeFunc)
			end
		end

		if not data.noEnterStack then
			self.mgr:PushUrlToStack(url)
		end

		self.mgr.currentUrl = url

		self.RefreshForwardAndBack(self)
	end
end

M.__OnHoverChange = function(self, _, state)
	self.bindData.hoverActive = BOOL2CTL[state]

	if self.hoverContent and self.curretStore and self.curretStore.OnHoverChange then
		self.curretStore:OnHoverChange(self.hoverContent)
	end
end

M.RefreshForwardAndBack = function(self)
	self.bindData.backBtn.interactable, self.bindData.forwardBtn.interactable = self.mgr:CheckCanGoBackAndForward()
end

M.RefreshContainer = function(self)
	if not self.webContainer.content then
		return
	end

	self.webContainer:SetSizeY(self.webContainer.content.rectTransform.rect.height)
	self.webContainer:SetLayoutDirty()
end

M.ShowReturnTopBtn = function(self, show)
	self.bindData.returnTopBtnCtl = BOOL2CTL[show]
end

M.OnClickReturnTopBtn = function(self)
	if self.curretStore and self.curretStore.OnReturnTop then
		self.curretStore:OnReturnTop()
	end

	self.bindData.webContainerRect:GoToPos(Vector2.zero, true)
end

M.OnScrollRectScroll = function(self, delta)
	if self.curretStore and self.curretStore.CanReturnTop then
		return
	end

	local npos = 1 - delta.y

	if npos >= 0.0001 then
		npos = 0
	end

	self:ShowReturnTopBtn(npos == 0)
end

M.OnSearchInputChanged = function(self, text)
	self.search_result = self.mgr:SearchWebpage(text)

	if not self.search_result then
		self.bindData.searchBarCtrl = BOOL2CTL[false]

		return
	end

	self.bindData.searchBarCtrl = BOOL2CTL[true]

	self.bindData.searchResultList:SetSimpleList(#self.search_result)
end

M.OnSimpleRenderSearchListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local result = self.search_result[index + 1]
	store.btn.luaClick = self:CreateActionWithArgs(self.OnClickSearchListItem, result.url or "")
	store.text.text = result.text or ""

	if result.logo then
		store.Commit(store, "logo", result.logo, COMMIT_FORCE)
	end
end

M.OnClickSearchListItem = function(self, targetUrl)
	if string.is_null_or_empty(targetUrl) then
		return
	end

	gWebManager:GoToTagetUrl(targetUrl)
end
