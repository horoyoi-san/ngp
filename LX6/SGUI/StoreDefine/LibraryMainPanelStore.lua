-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LibraryMainPanelStore.lua
-- Decompiled from: 01778_LibraryMainPanelStore.lua_be6addda2689.luajit

local LibraryConfig = LTConfig.WebpageLibraryConfig
local EPageType = LTConfig.WebpageLibraryConfig.TypeType
C_LibraryMainPanelStore = DefClass("C_LibraryMainPanelStore", C_LibraryMainPanelStore, C_StoreGroup)
GroupName2Class.LibraryMainPanelStore = C_LibraryMainPanelStore
local M = C_LibraryMainPanelStore

M.ctor = function(self)
	self.mgr = gWebManager
	self.ListenCookie = "Page"
end

M.OnAwake = function(self)
	self.bindData.subList1.onGetTIndex = self.CreateAction(self, self.OnGetList1TIndex)
	self.bindData.subList2.onGetTIndex = self.CreateAction(self, self.OnGetList2TIndex)
	self.bindData.subList1.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSubList1Item)
	self.bindData.subList2.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSubList2Item)
	self.bindData.subList1.luaLayoutSet = self.CreateAction(self, self.OnRefreshLayout)
	self.bindData.subList2.luaLayoutSet = self.CreateAction(self, self.OnRefreshLayout)
	self.msgs = {
		[gEventConstants.WEBSTIE_COOKIE_CHANGE] = self.CreateAction(self, self.OnCookieChange)
	}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgs)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnCookieChange = function(self, eventId, cookie)
	if cookie == self.ListenCookie then
		return
	end

	self.RefreshPage(self)
end

M.RefreshPage = function(self)
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
		gWebManager:GoToNotFoundPage()

		return
	end

	self.bindData.page = cfg.Type
	self.bindData.resourceId = cfg.MainResource
	self.resourceList = {
		{},
		{}
	}

	if self.bindData.page ~= EPageType.main then
		self.resourceList[1][1] = cfg.SubResName1
		self.resourceList[2][1] = cfg.SubResName2

		for i = 1, #cfg.SubResources1 do
			table.insert(self.resourceList[1], cfg.SubResources1[i])
		end

		for i = 1, #cfg.SubResources2 do
			table.insert(self.resourceList[2], cfg.SubResources2[i])

			if i == #cfg.SubResources2 then
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

M.OnClose = function(self)
end

M.OnSimpleRenderSubList1Item = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.resourceId = self.resourceList[1][index + 1]
end

M.OnSimpleRenderSubList2Item = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.resourceId = self.resourceList[2][index + 1]
end

M.OnGetList1TIndex = function(self, index)
	return index ~= 0 and 0 or 1
end

M.OnGetList2TIndex = function(self, index)
	if index ~= 0 then
		return 0
	end

	return self.resourceList[2][index + 1] ~= 0 and 2 or 1
end

M.OnRefreshLayout = function(self)
	gMessageManager:SendMessage(gEventConstants.WEBSITE_LAYOUT_RESET)
end
