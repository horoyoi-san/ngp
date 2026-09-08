-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewsWebScollStore.lua
-- Decompiled from: 00942_NewsWebScollStore.lua_e43bde8717a8.luajit

local DailyNewsConfig = LTConfig.WebpageDailyNewsConfig
local DailyNewType = LTConfig.WebpageDailyNewsConfig.TypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
local WebpageConfig = LTConfig.WebpageConfig
C_NewsWebScollStore = DefClass("C_NewsWebScollStore", C_NewsWebScollStore, C_StoreGroup)
GroupName2Class.NewsWebScollStore = C_NewsWebScollStore
local M = C_NewsWebScollStore
M.Regions = {
	["\\xbagv"] = 1,
	["W+y\n"] = 2,
	[">G\\x85\\x9a\\x8cL"] = 4,
	["W+y\t"] = 3
}
M.RegionCnt = 4

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderList)

	self.bindData.list.onGetTIndex = function(index)
		return index
	end

	self.renderFuncs = {
		[self.Regions.Top] = self.RenderList_Top,
		[self.Regions.Mid1] = self.RenderList_Mid1,
		[self.Regions.Mid2] = self.RenderList_Mid2,
		[self.Regions.Bottom] = self.RenderList_Bottom
	}
	self.dataMapping = {
		[DailyNewType.banner] = {
			self.Regions.Top,
			self.Regions.Mid1,
			self.Regions.Mid1,
			self.Regions.Mid1
		},
		[DailyNewType.recommend] = {
			self.Regions.Mid2,
			self.Regions.Bottom,
			self.Regions.Bottom,
			self.Regions.Bottom,
			self.Regions.Bottom
		}
	}
	self.OnSimpleRenderListAction_Mid = self.CreateAction(self, self.OnSimpleRenderList_Mid)
	self.OnSimpleRenderListAction_Bottom = self.CreateAction(self, self.OnSimpleRenderList_Bottom)
end

M.RefreshPage = function(self)
	self:LoadData()
	self.bindData.list:SetSimpleList(self.RegionCnt)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnSimpleRenderList = function(self, widget, index)
	local renderFunc = self.renderFuncs[index + 1]

	if renderFunc then
		renderFunc(self, widget)
	end
end

M.RenderList_Top = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.datas[self.Regions.Top]

	if not data or not store then
		return
	end

	store.title.text = data.title or ""
	store.detail.text = data.detail or ""

	if data.image then
		store.Commit(store, "image", data.image, COMMIT_FORCE)
	end

	if data.url then
		store.resource.clickUrlOverride = data.url
	end
end

M.RenderList_Mid1 = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.datas[self.Regions.Mid1]

	if not data or not store then
		return
	end

	store.list.luaSimpleRenderItem = self.OnSimpleRenderListAction_Mid

	store.list:SetSimpleList(#data)
end

M.RenderList_Mid2 = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.datas[self.Regions.Mid2]

	if not data or not store then
		return
	end

	if data.image then
		store.Commit(store, "image", data.image, COMMIT_FORCE)
	end

	if data.url then
		store.resource.clickUrlOverride = data.url
	end
end

M.RenderList_Bottom = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local list = self.datas[self.Regions.Bottom]

	if not list or not store then
		return
	end

	local cnt = #list

	if cnt ~= 0 then
		return
	end

	local firstItem = list[1]
	store.title.text = firstItem.title or ""
	store.detail.text = firstItem.detail or ""

	if firstItem.image then
		store.Commit(store, "image", firstItem.image, COMMIT_FORCE)
	end

	if firstItem.url then
		store.resource.clickUrlOverride = firstItem.url
	end

	if cnt ~= 1 then
		return
	end

	store.list.luaSimpleRenderItem = self.OnSimpleRenderListAction_Bottom

	store.list:SetSimpleList(#list - 1)
end

M.LoadData = function(self)
	self.datas = {
		[self.Regions.Top] = nil,
		[self.Regions.Mid1] = {},
		[self.Regions.Mid2] = nil,
		[self.Regions.Bottom] = {}
	}

	for i = 0, DailyNewsConfig.count - 1 do
		local page = DailyNewsConfig.LoadAt(i)
		local resourceId = page.SubResources[1]

		if resourceId then
			local resource = ResourceConfig.GetConfig(resourceId)
			local regionType = self.dataMapping[page.Type][page.NewsId]
			local url = nil

			if resource.Url and resource.Url == 0 then
				local linkTargetWebPage = WebpageConfig.GetConfig(resource.Url)
				url = linkTargetWebPage and linkTargetWebPage.Url
			end

			if resource and regionType then
				if not self.datas[regionType] then
					self.datas[regionType] = {
						title = resource.Name,
						detail = resource.Desc,
						image = resource.ImageId,
						url = url
					}
				else
					table.insert(self.datas[regionType], {
						title = resource.Name,
						detail = resource.Desc,
						image = resource.ImageId,
						url = url
					})
				end
			end
		end
	end
end

M.OnSimpleRenderList_Mid = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.datas[self.Regions.Mid1][index + 1]

	if store and data then
		store.title.text = data.title
		store.detail.text = data.detail

		if data.image then
			store.Commit(store, "image", data.image, COMMIT_FORCE)
		end

		if data.url then
			store.resource.clickUrlOverride = data.url
		end
	end
end

M.OnSimpleRenderList_Bottom = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.datas[self.Regions.Bottom][index + 2]

	if store and data then
		store.title.text = data.title
		store.detail.text = data.detail

		if data.image then
			store.Commit(store, "image", data.image, COMMIT_FORCE)
		end

		if data.url then
			store.resource.clickUrlOverride = data.url
		end
	end
end
