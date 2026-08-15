C_GuideFullScreenStore = DefClass("C_GuideFullScreenStore", C_GuideFullScreenStore, C_StoreGroup)
GroupName2Class.GuideFullScreenStore = C_GuideFullScreenStore
local M = C_GuideFullScreenStore
local TextConfig = LTConfig.GuideGuideTextConfig
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
		print_error("GuideFullScreenStore:OnShow - data is nil")
		gPanelManager:Close(panelId)

		return
	end

	self.data = data

	if not data.pageDatas or #data.pageDatas == 0 then
		print_error("GuideFullScreenStore:OnShow - pageData is nil or empty")
		gPanelManager:Close(panelId)

		return
	end

	self.pageNum = #data.pageDatas

	self:ChangeIndex(1)
end

function M:OnClose()
	self.data.onClose()

	self.currentPageData = nil
	self.data = nil
	self.currentIndex = nil
	self.pageNum = nil
end

function M:OnActiveDeviceChange(device)
	self:RefreshText()
end

function M:OnLanguageChange(lang)
	self:RefreshText()
end

local DOT_HIGHLIGHT = 0
local DOT_NORMAL = 5

function M:ChangeIndex(index)
	if index < 1 or self.pageNum < index then
		print_error("GuideFullScreenStore:OnChangeIndex - index out of range")

		return
	end

	self.currentIndex = index
	self.currentPageData = self.data.pageDatas[index]
	local txtCfg = TextConfig.GetConfig(self.currentPageData.title)

	if not txtCfg then
		print_error("GuideFullScreenStore: TextConfig Id:" .. self.currentPageData.title .. " not found")

		return
	end

	self.bindData.title = txtCfg.Text
	self.bindData.leftArrowCtrl = self.currentIndex > 1 and SHOW or HIDE
	self.bindData.rightArrowCtrl = self.currentIndex < self.pageNum and SHOW or HIDE

	if self.currentPageData.textureId ~= 0 then
		self.bindData.imageId = self.currentPageData.textureId
		self.bindData.infoMode = TEXTURE_MODE
	elseif self.currentPageData.videoId ~= 0 then
		self.bindData.infoMode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(self.currentPageData.videoId, true, nil, nil)
	else
		print_error("GuideFullScreenStore:OnChangeIndex - currentPageData has no valid textureId or videoId")
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
	self.bindData.descText = gGuideGlyph:GetGuideRichText(self.currentPageData)
end

function M:OnClickNext()
	if self.currentIndex < self.pageNum then
		self:ChangeIndex(self.currentIndex + 1)
	end
end

function M:OnClickLast()
	if self.currentIndex > 1 then
		self:ChangeIndex(self.currentIndex - 1)
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
