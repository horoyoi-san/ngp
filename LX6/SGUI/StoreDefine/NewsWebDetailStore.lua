-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewsWebDetailStore.lua
-- Decompiled from: 00960_NewsWebDetailStore.lua_a87bcbdf4690.luajit

local DailyNewsConfig = LTConfig.WebpageDailyNewsConfig
local ResourceConfig = LTConfig.WebpageResourceConfig
C_NewsWebDetailStore = DefClass("C_NewsWebDetailStore", C_NewsWebDetailStore, C_StoreGroup)
GroupName2Class.NewsWebDetailStore = C_NewsWebDetailStore
local M = C_NewsWebDetailStore
M.listCnt = 1
M.PlayIconCtl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
M.VideoStatusCtl = {
	["\\xe9\\xd7*\\xf6"] = 1,
	["\\xee\\xda\t*\\xf6"] = 3,
	["}\\xaf\\xb7\\xbc\\xb3"] = 2,
	["T-s^"] = 0
}

M.ctor = function(self)
	self.newsId = nil
	self.videoPlayerPanelStore = nil
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderList)
end

M.RefreshPage = function(self, newsId)
	if newsId then
		self.newsId = newsId
	end

	self:LoadData()
	self.bindData.list:SetSimpleList(self.listCnt)
end

M.OnShow = function(self, panelId, data)
end

M.LoadData = function(self)
	local page = DailyNewsConfig.GetConfig(self.newsId)

	if not page then
		gWebManager:GoToNotFoundPage()

		return
	end

	local resourceId = page.SubResources[1]

	if not resourceId then
		gWebManager:GoToNotFoundPage()

		return
	end

	local resource = ResourceConfig.GetConfig(resourceId)

	if not resource then
		gWebManager:GoToNotFoundPage()

		return
	end

	self.data = {
		title = resource.Name,
		detail = resource.Desc,
		resourceId = resourceId,
		subtitle = page.SubTitle
	}
end

M.OnSimpleRenderList = function(self, widget, _)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	store.title.text = self.data.title
	store.detail.text = self.data.detail
	store.subtitle.text = self.data.subtitle

	if self.data.resourceId and self.data.resourceId == 0 then
		store.resource.resourceId = self.data.resourceId
	end
end

M.OnClickVideoPlayPauseBtn = function(self)
end
