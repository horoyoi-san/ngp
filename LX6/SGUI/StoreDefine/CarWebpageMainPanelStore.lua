-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarWebpageMainPanelStore.lua
-- Decompiled from: 01642_CarWebpageMainPanelStore.lua_cef29dd0366c.luajit

local ProRideConfig = LTConfig.WebpageProRideConfig
local ProRideType = LTConfig.WebpageProRideConfig.TypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
local WebpageConfig = LTConfig.WebpageConfig
C_CarWebpageMainPanelStore = DefClass("C_CarWebpageMainPanelStore", C_CarWebpageMainPanelStore, C_StoreGroup)
GroupName2Class.CarWebpageMainPanelStore = C_CarWebpageMainPanelStore
local M = C_CarWebpageMainPanelStore
M.PageCtl = {
	["8M\\x85\\x8f\\x8aM"] = 1,
	["W#tU"] = 0
}

M.ctor = function(self)
	self.mgr = gWebManager
	self.bannerDatas = nil
	self.carListDatas = nil
	self.detailData = nil
end

M.OnAwake = function(self)
	self.bindData.carList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderCarlistItem)
	self.bindData.carList.luaLayoutSet = self.CreateAction(self, self.OnCarListLayoutSet)
	self.bindData.carousel.luaGetImageId = self.CreateAction(self, self.OnCarouselGetImageId)
	self.bindData.carousel.luaSimpleRenderItem = self.CreateAction(self, self.OnCarouselRender)
	self.bindData.carousel.luaGetClickJumpURL = self.CreateAction(self, self.OnCarouselGetClickJumpURL)
	self.bindData.btnBannerGo.luaClick = self.CreateAction(self, self.OnBannerBtnGoClicked)
	self.bindData.selfWidget.luaSizeChanged = self.CreateAction(self, self.OnSizeChanged)
end

M.OnCarListLayoutSet = function(self)
	FrameTimer.New(function ()
		if self.parent then
			self.parent:RefreshContainer()
		end
	end, 1):Start()
end

M.OnSizeChanged = function(self)
	gMessageManager:SendMessage(gEventConstants.WEBSITE_LAYOUT_RESET)
end

M.RefreshPage = function(self)
	local newsId = self.mgr:GetCurrentParam("news")

	if not newsId then
		self.bindData:Commit("pageCtl", self.PageCtl.Main, COMMIT_IMMEDIATELY)
		self:RefreshMainPage()
	else
		self.bindData:Commit("pageCtl", self.PageCtl.Detail, COMMIT_IMMEDIATELY)
		self:RefreshDetailPage(newsId)
	end

	self.OnCarListLayoutSet(self)
end

M.RefreshMainPage = function(self)
	self:LoadMainPageData()
	self.bindData.carList:SetSimpleList(#self.carListDatas)
	self.bindData.carousel:Play(#self.bannerDatas)
end

M.RefreshDetailPage = function(self, newsId)
	self:LoadDetailPageData(newsId)

	self.bindData.detailTitle.text = self.detailData.title
	self.bindData.detailSubtitle.text = self.detailData.subtitle
	self.bindData.detailDesc.text = self.detailData.desc

	self.bindData:Commit("detailImage", self.detailData.imageDetail, COMMIT_FORCE)
end

M.LoadMainPageData = function(self)
	self.bannerDatas = {}
	self.carListDatas = {}

	for i = 0, ProRideConfig.count - 1 do
		local page = ProRideConfig.LoadAt(i)
		local data = self.LoadItemData(self, page)

		if data.type ~= ProRideType.banner then
			table.insert(self.bannerDatas, data)
		else
			table.insert(self.carListDatas, data)
		end
	end
end

M.LoadDetailPageData = function(self, newsId)
	local page = ProRideConfig.GetConfig(newsId)

	if not page then
		gWebManager:GoToNotFoundPage()

		return
	end

	self.detailData = self.LoadItemData(self, page)
end

M.LoadItemData = function(self, page)
	if not page then
		return nil
	end

	local resourceId = page.MainResource

	if not resourceId or resourceId ~= 0 then
		return nil
	end

	local resource = ResourceConfig.GetConfig(resourceId)
	local url = nil

	if resource.Url and resource.Url == 0 then
		local linkTargetWebPage = WebpageConfig.GetConfig(resource.Url)
		url = linkTargetWebPage and linkTargetWebPage.Url
	end

	local imageDetail = resource.ImageId
	local resourceDetailId = page.DetailPage

	if resourceDetailId and resourceDetailId == 0 then
		local resourceDetail = ResourceConfig.GetConfig(resourceDetailId)

		if resourceDetail.ImageId and resourceDetail.ImageId == 0 then
			imageDetail = resourceDetail.ImageId
		end
	end

	return {
		id = page.ID,
		image = resource.ImageId,
		imageDetail = imageDetail,
		title = resource.Name,
		subtitle = page.SubTitle,
		desc = resource.Desc,
		tag = page.Label,
		url = url,
		type = page.Type
	}
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnSimpleRenderCarlistItem = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local data = self.carListDatas[index + 1]

	if store.title then
		store.title.text = data.title
	end

	if store.detail then
		store.detail.text = data.subtitle
	end

	if store.tag then
		store.tag.text = data.tag
	end

	store.Commit(store, "image", data.image, COMMIT_FORCE)

	if data.url then
		store.resource.clickUrlOverride = data.url
	end
end

M.OnCarouselGetImageId = function(self, idx)
	return self.bannerDatas[idx + 1].image
end

M.OnCarouselRender = function(self, idx)
	if not self.bannerDatas then
		return
	end

	local data = self.bannerDatas[idx + 1]

	if not data then
		return
	end

	if self.bindData.bannerTitle then
		self.bindData.bannerTitle.text = data.title
	end

	if self.bindData.bannerSubtitle then
		self.bindData.bannerSubtitle.text = data.subtitle
	end

	if self.bindData.bannerDetail then
		self.bindData.bannerDetail.text = data.desc
	end
end

M.OnCarouselGetClickJumpURL = function(self, idx)
	if not self.bannerDatas then
		return
	end

	local data = self.bannerDatas[idx + 1]

	if not data then
		return
	end

	return data.url
end

M.OnBannerBtnGoClicked = function(self)
	self.bindData.carousel:DoClick()
end
