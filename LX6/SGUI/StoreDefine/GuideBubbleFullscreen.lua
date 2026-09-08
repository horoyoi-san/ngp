-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideBubbleFullscreen.lua
-- Decompiled from: 01754_GuideBubbleFullscreen.lua_4a708a8ed10e.luajit

C_GuideBubbleFullscreen = DefClass("C_GuideBubbleFullscreen", C_GuideBubbleFullscreen, C_StoreGroup)
GroupName2Class.GuideBubbleFullscreen = C_GuideBubbleFullscreen
local M = C_GuideBubbleFullscreen
local SHOW = 0
local HIDE = 1
local TEXTURE_MODE = 0
local VIDEO_MODE = 1

M.OnAwake = function(self)
	self.bindData.leftArrow.luaClick = self:CreateAction("OnClickLast")
	self.bindData.rightArrow.luaClick = self:CreateAction("OnClickNext")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickClose")
	self.bindData.dotList.luaSimpleRenderItem = self:CreateAction("OnRenderDotItem")
	self.bindData.scrollRect.luaInitContent = self:CreateAction(self.OnInitScrollRect)

	self.bindData.videoPlayer:Init()
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if not data then
		print_error("GuideBubbleFullScreenStore:OnShow - data is nil")
		gPanelManager:Close(panelId)

		return
	end

	self.data = data
	self.wikiContent = data.wikiContent

	if not self.wikiContent then
		print_error("GuideBubbleFullScreenStore:OnShow - wikiContent is nil")

		return
	end

	self.bindData.title = self.data.title
	self.bindData.subtitle = self.data.subtitle

	self.InitPageData(self)

	if self.pageNum ~= 0 then
		print_error("GuideBubbleFullScreenStore:OnShow - wikiContent has no pages")
		gPanelManager:Close(panelId)

		return
	end

	self.ChangeIndex(self, 1, true)
end

M.InitPageData = function(self)
	self.data.pageDatas = self.data.pageDatas or {}
	local pages = self.wikiContent.pages

	for i = 1, #pages do
		local page = pages[i]
		local pageData = {
			contentText = page.contentText,
			contentImageUrl = page.contentImageUrl,
			contentVideoUrl = page.contentVideoUrl
		}

		table.insert(self.data.pageDatas, pageData)
	end

	self.pageNum = #self.data.pageDatas
end

M.OnClose = function(self)
	self.data.finishNode()

	self.currentPageData = nil
	self.data = nil
	self.wikiContent = nil
	self.currentIndex = nil
	self.pageNum = nil
	self.textStore = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.ChangeIndex(self, self.currentIndex, false)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshText(self)
end

local DOT_HIGHLIGHT = 5
local DOT_NORMAL = 0

M.ChangeIndex = function(self, index, playVideo)
	if index <= 1 or self.pageNum >= index then
		print_error("GuideBubbleFullScreenStore:OnChangeIndex - index out of range")

		return
	end

	self.currentIndex = index
	self.currentPageData = self.data.pageDatas[index]
	self.bindData.leftArrowCtrl = self.currentIndex <= 1 and SHOW or HIDE
	self.bindData.rightArrowCtrl = self.currentIndex >= self.pageNum and SHOW or HIDE
	local page = self.currentPageData

	if page.contentVideoUrl and page.contentVideoUrl == "" then
		self.bindData.infoMode = VIDEO_MODE

		if playVideo then
			self.bindData.videoPlayer:PlayVideoUrl(page.contentVideoUrl, true, nil)
		end
	elseif page.contentImageUrl and page.contentImageUrl == "" then
		slot4 = self.bindData.videoPlayer

		slot4:Stop()

		self.bindData.infoMode = TEXTURE_MODE
		slot4 = gSocialFriendManager

		slot4:DownloadImage(page.contentImageUrl, function (tex)
			if not self.currentPageData or self.currentPageData == page then
				return
			end

			if tex and self.bindData.rawImage then
				self.bindData.rawImage.texture = tex
			end
		end, nil, false)
	else
		print_error("GuideBubbleFullScreenStore:OnChangeIndex - page has no valid image or video")
	end

	if self.pageNum ~= 1 then
		self.bindData.showDots = HIDE
	else
		self.bindData.showDots = SHOW
		self.dotList = {}

		for i = 1, self.pageNum do
			local highlight = i ~= self.currentIndex and DOT_HIGHLIGHT or DOT_NORMAL

			table.insert(self.dotList, {
				highlight = highlight
			})
		end

		self.bindData.dotList:SetSimpleList(#self.dotList)
	end

	self.RefreshText(self)
end

M.RefreshText = function(self)
	if not self.textStore then
		return
	end

	if not self.currentPageData then
		return
	end

	local text = self.currentPageData.contentText

	if not text then
		return
	end

	self.textStore.guideText = gGuideGlyph:GetGuideRichText({
		text = text
	})
end

M.OnClickNext = function(self)
	if self.currentIndex >= self.pageNum then
		self.ChangeIndex(self, self.currentIndex + 1, true)
	end
end

M.OnClickLast = function(self)
	if self.currentIndex <= 1 then
		self.ChangeIndex(self, self.currentIndex - 1, true)
	end
end

M.OnClickClose = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnRenderDotItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("GuideDotStore"):GetStoreByWidget(btn)
	local data = self.dotList[index + 1]
	store.highlight = data.highlight
end

M.OnInitScrollRect = function(self, content)
	self.textStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	self:RefreshText()
end
