local LibraryConfig = LTConfig.WebpageLibraryConfig
local EPageType = LTConfig.WebpageLibraryConfig.TypeType
C_LibraryMainPanelStore = DefClass("C_LibraryMainPanelStore", C_LibraryMainPanelStore, C_StoreGroup)
GroupName2Class.LibraryMainPanelStore = C_LibraryMainPanelStore
local M = C_LibraryMainPanelStore

function M:ctor()
	self.mgr = gWebManager
	self.ListenCookie = "Page"
end

function M:OnAwake()
	self.bindData.subList1.onGetTIndex = self:CreateAction(self.OnGetList1TIndex)
	self.bindData.subList2.onGetTIndex = self:CreateAction(self.OnGetList2TIndex)
	self.bindData.subList1.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderSubList1Item)
	self.bindData.subList2.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderSubList2Item)
	self.bindData.subList1.luaLayoutSet = self:CreateAction(self.OnRefreshLayout)
	self.bindData.subList2.luaLayoutSet = self:CreateAction(self.OnRefreshLayout)
	self.msgs = {
		[gEventConstants.WEBSTIE_COOKIE_CHANGE] = self:CreateAction(self.OnCookieChange)
	}
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgs)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self:RefreshPage()
end

function M:OnCookieChange(eventId, cookie)
	if cookie ~= self.ListenCookie then
		return
	end

	self:RefreshPage()
end

function M:RefreshPage()
	local bookId = self.mgr:GetCurrentParam("book")

	if not bookId then
		bookId = self.mgr:TryGetCookie(self.ListenCookie)

		if not bookId then
			print_error("[C_LibraryMainPanelStore:RefreshPage] bookId is nil")

			return
		end
	end

	self.bookId = tonumber(bookId)
	local cfg = LibraryConfig.GetConfig(self.bookId)

	if not cfg then
		print_error("[C_LibraryMainPanelStore:RefreshPage] cfg is nil, bookId = ", bookId)

		return
	end

	self.bindData.page = cfg.Type
	self.bindData.resourceId = cfg.MainResource
	self.resourceList = {
		{},
		{}
	}

	if self.bindData.page == EPageType.main then
		self.resourceList[1][1] = cfg.SubResName1
		self.resourceList[2][1] = cfg.SubResName2

		for i = 1, #cfg.SubResources1 do
			table.insert(self.resourceList[1], cfg.SubResources1[i])
		end

		for i = 1, #cfg.SubResources2 do
			table.insert(self.resourceList[2], cfg.SubResources2[i])

			if i ~= #cfg.SubResources2 then
				table.insert(self.resourceList[2], 0)
			end
		end

		self.bindData.subList1:SetSimpleList(#self.resourceList[1])
		self.bindData.subList2:SetSimpleList(#self.resourceList[2])
		self.bindData.subList1:SetItemLabel(0, cfg.SubResName1)
		self.bindData.subList2:SetItemLabel(0, cfg.SubResName2)

		return
	end

	self.bindData.bookDetailLabel = cfg.SubResName1

	FrameTimer.New(function ()
		self:OnRefreshLayout()
	end, 0):Start()
end

function M:OnClose()
	return
end

function M:OnSimpleRenderSubList1Item(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.resourceId = self.resourceList[1][index + 1]
end

function M:OnSimpleRenderSubList2Item(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.resourceId = self.resourceList[2][index + 1]
end

function M:OnGetList1TIndex(index)
	return index == 0 and 0 or 1
end

function M:OnGetList2TIndex(index)
	if index == 0 then
		return 0
	end

	return self.resourceList[2][index + 1] == 0 and 2 or 1
end

function M:OnRefreshLayout()
	gMessageManager:SendMessage(gEventConstants.WEBSITE_LAYOUT_RESET)
end
