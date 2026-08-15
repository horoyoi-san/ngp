C_ComputerBrowserPanelStore = DefClass("C_ComputerBrowserPanelStore", C_ComputerBrowserPanelStore, C_StoreGroup)
GroupName2Class.ComputerBrowserPanelStore = C_ComputerBrowserPanelStore
local M = C_ComputerBrowserPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gWebManager
	self.FileType = {
		WebPage = 0,
		PDF = 1
	}
end

function M:OnAwake()
	self.bindData.webEnterBtn.luaClick = self:CreateAction(self.OnClickWebEnterBtn)
	self.bindData.backBtn.luaClick = self:CreateAction("OnStackBack", self.mgr)
	self.bindData.forwardBtn.luaClick = self:CreateAction("OnStackForward", self.mgr)
	self.bindData.homeBtn.luaClick = self:CreateAction("ReturnToHomePage", self.mgr)
	self.bindData.refreshBtn.luaClick = self:CreateAction(self.OnClickRefreshBtn)
	self.bindData.minBtn.luaClick = self:CreateAction(self.OnClickMinBtn)
	self.bindData.maxBtn.luaClick = self:CreateAction(self.OnClickMaxBtn)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.OnClickCloseBtn)
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

function M:OnInitRect(container)
	self.webContainer = container
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnChangeContainer(content)
	local store = gStoreManager:GetStoreGroup(content.Store)

	if self.curretStore == store and store.RefreshPage then
		store:RefreshPage()

		return
	end

	self.curretStore = store
	self.bindData.hoverActive = BOOL2CTL[false]

	if not store then
		return
	end

	if store.OnShow then
		store:OnShow()
	end

	self:RefreshContainer()
end

function M:OnChangeHoverContainer(content)
	if not content then
		return
	end

	self.hoverContent = content

	if self.curretStore and self.curretStore.OnHoverChange then
		self.curretStore:OnHoverChange(content)
	end
end

function M:ShowPanel(computerId, data)
	self.pdfCfg = nil
	local isPdf, cfg = self:IsPdf(computerId)
	self.bindData.webTopInputField.interactable = not isPdf

	if isPdf then
		self.pdfCfg = cfg

		self:InitPDFView()

		return
	end

	self.mgr:SetCurrentComputerId(computerId)

	if self.mgr.showHomePage then
		self.mgr:ReturnToHomePage()
	else
		self.mgr:GoToTargetIndex(self.mgr.homePageList[1])
	end
end

function M:IsPdf(computerId)
	local cfg = LTConfig.ComputerFileConfig.GetConfig(computerId)

	if cfg and cfg.FileType == gClientConst.Computer_File_Type.PDF then
		gClientToGameDelegate:AskComputerFileRead(cfg.Id, false).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		return true, cfg
	end

	return false
end

function M:InitPDFView()
	self.bindData.fileType = self.FileType.PDF
	self.bindData.webTopInputField.text = self.pdfCfg.FileTitle .. ".pdf"
	self.pdfDataList = self.pdfCfg.SubFileList

	self.bindData.pdfList:SetSimpleList(#self.pdfDataList)
end

function M:OnPDFRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local id = self.pdfDataList[luaIndex]

	if id == nil then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.image = id
end

function M:OnClickWebEnterBtn()
	local url = self.bindData.webTopInputField.text

	self.mgr:GoToTagetUrl(url)
end

function M:OnClickRefreshBtn()
	return
end

function M:OnClickMinBtn()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)

	self.mgr.currentUrl = ""
end

function M:OnClickMaxBtn()
	return
end

function M:OnClickCloseBtn()
	if self.pdfCfg then
		gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_PREVIEW_CLOSE)

		self.pdfCfg = nil

		return
	end

	self:TryClose()
end

function M:TryClose()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
	self.mgr:OnExit()
end

function M:__OnOpenUrl(_, data)
	if string.is_null_or_empty(data.url) or not self.webContainer or data.url == self.mgr.currentUrl then
		return
	end

	local url = data.url
	self.bindData.webTopInputField.text = url

	if not string.is_null_or_empty(self.mgr.currentUrl) and self.mgr:GetRealUrl(self.mgr.currentUrl) == self.mgr:GetRealUrl(url) then
		FrameTimer.New(function ()
			if self.curretStore and self.curretStore.RefreshPage then
				self.curretStore:RefreshPage()
			end
		end, 0):Start()
		self.bindData.webContainerRect:GoToPos(Vector2.zero, true)
	else
		local pUrl, hUrl, cfg = self.mgr:GetWebPageConfig(url)

		self.webContainer:SetUrlWithCallback(pUrl, self.OnContainerChangeFunc)

		if not string.is_null_or_empty(hUrl) then
			self.bindData.hoverContainer:SetUrlWithCallback(hUrl, self.OnHoverContainerChangeFunc)
		end
	end

	if not data.noEnterStack then
		self.mgr:PushUrlToStack(url)
	end

	self.mgr.currentUrl = url

	self:RefreshForwardAndBack()
end

function M:__OnHoverChange(_, state)
	self.bindData.hoverActive = BOOL2CTL[state]

	if self.hoverContent and self.curretStore and self.curretStore.OnHoverChange then
		self.curretStore:OnHoverChange(self.hoverContent)
	end
end

function M:RefreshForwardAndBack()
	self.bindData.backBtn.interactable, self.bindData.forwardBtn.interactable = self.mgr:CheckCanGoBackAndForward()
end

function M:RefreshContainer()
	if not self.webContainer.content then
		return
	end

	self.webContainer:SetSizeY(self.webContainer.content.rectTransform.rect.height)
end
