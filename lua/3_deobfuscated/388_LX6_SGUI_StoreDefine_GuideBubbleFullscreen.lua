C_GuideBubbleFullscreen = DefClass("C_GuideBubbleFullscreen", C_GuideBubbleFullscreen, C_StoreGroup)
GroupName2Class.GuideBubbleFullscreen = C_GuideBubbleFullscreen
local M = C_GuideBubbleFullscreen
local SHOW = 0
local HIDE = 1
local TEXTURE_MODE = 0
local VIDEO_MODE = 1

function M:OnAwake()
	self.bindData.leftArrow.luaClick = self:CreateAction("OnClickLast")
	self.bindData.rightArrow.luaClick = self:CreateAction("OnClickNext")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickClose")
	self.bindData.dotList.luaSimpleRenderItem = self:CreateAction("OnRenderDotItem")

	self.bindData.videoPlayer:Init()
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	if not data then
		print_error("GuideBubbleFullScreenStore:OnShow - data is nil")
		gPanelManager:Close(panelId)

		return
	end

	self.data = data
	self.teachCfg = data.guideTeachCfg

	if not self.teachCfg then
		print_error("GuideBubbleFullScreenStore:OnShow - teachCfg is nil")
		gPanelManager:Close(panelId)

		return
	end

	self.bindData.title = self.data.title
	self.bindData.subtitle = self.data.subtitle

	self:InitPageData()
	self:ChangeIndex(1, true)
end

function M:InitPageData()
	self.data.pageDatas = self.data.pageDatas or {}

	for i = 1, 5 do
		local descName = "Desc" .. i
		local sourceName = "Source" .. i
		local sources = self.teachCfg[sourceName]

		if not sources or #sources == 0 then
			break
		end

		if #sources ~= #self.teachCfg[descName] then
			print_error("GuideBubbleFullScreenStore:InitPageData - source and desc length mismatch:", #sources, #self.teachCfg[descName])

			break
		end

		local cnt = #sources
		local pageData = {
			hasMultiPlatform = cnt > 1,
			textureIds = {},
			videoIds = {}
		}

		for j = 1, cnt do
			local source = sources[j]

			if source.sourceType == 1 then
				pageData.textureIds[j] = source.sourceId
			elseif source.sourceType == 2 then
				pageData.videoIds[j] = source.sourceId
			else
				print_error("GuideBubbleFullScreenStore:InitPageData - unsupported sourceType:", source.sourceType)

				return
			end
		end

		pageData.contents = self.teachCfg[descName]

		table.insert(self.data.pageDatas, pageData)
	end

	self.pageNum = #self.data.pageDatas
end

function M:OnClose()
	self.data.finishNode()

	self.currentPageData = nil
	self.data = nil
	self.currentIndex = nil
	self.pageNum = nil
end

function M:OnActiveDeviceChange(device)
	self:ChangeIndex(self.currentIndex, false)
end

function M:OnLanguageChange(lang)
	self:RefreshText()
end

local DOT_HIGHLIGHT = 5
local DOT_NORMAL = 0

function M:ChangeIndex(index, playVideo)
	if index < 1 or self.pageNum < index then
		print_error("GuideBubbleFullScreenStore:OnChangeIndex - index out of range")

		return
	end

	self.currentIndex = index
	self.currentPageData = self.data.pageDatas[index]
	local platformId = self:GetPlatformId(self.currentPageData.hasMultiPlatform)
	local texId = self.currentPageData.textureIds[platformId]
	local videoId = self.currentPageData.videoIds[platformId]
	self.bindData.leftArrowCtrl = self.currentIndex > 1 and SHOW or HIDE
	self.bindData.rightArrowCtrl = self.currentIndex < self.pageNum and SHOW or HIDE

	if texId and texId ~= 0 then
		self.bindData.imageId = texId
		self.bindData.infoMode = TEXTURE_MODE
	elseif videoId and videoId ~= 0 then
		self.bindData.infoMode = VIDEO_MODE

		if playVideo then
			self.bindData.videoPlayer:PlayVideo(videoId, true, nil, nil)
		end
	else
		print_error("GuideBubbleFullScreenStore:OnChangeIndex - currentPageData has no valid textureId or videoId")
	end

	if self.pageNum == 1 then
		self.bindData.showDots = HIDE
	else
		self.bindData.showDots = SHOW
		self.dotList = {}

		for i = 1, self.pageNum do
			local highlight = i == self.currentIndex and DOT_HIGHLIGHT or DOT_NORMAL

			table.insert(self.dotList, {
				highlight = highlight
			})
		end

		self.bindData.dotList:SetSimpleList(#self.dotList)
	end

	self:RefreshText()
end

function M:RefreshText()
	local platformId = self:GetPlatformId(self.currentPageData.hasMultiPlatform)
	self.bindData.descText = gGuideGlyph:GetRichTextByGuideStr(self.currentPageData.contents[platformId])
end

function M:OnClickNext()
	if self.currentIndex < self.pageNum then
		self:ChangeIndex(self.currentIndex + 1, true)
	end
end

function M:OnClickLast()
	if self.currentIndex > 1 then
		self:ChangeIndex(self.currentIndex - 1, true)
	end
end

function M:OnClickClose()
	gPanelManager:Close(self.panelId)
end

function M:OnRenderDotItem(btn, index)
	local store = gStoreManager:GetStoreGroup("GuideDotStore"):GetStoreByWidget(btn)
	local data = self.dotList[index + 1]
	store.highlight = data.highlight
end

function M:GetPlatformId(hasMulti)
	if not hasMulti then
		return 1
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return 1
	elseif SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		return 3
	else
		return 2
	end
end
