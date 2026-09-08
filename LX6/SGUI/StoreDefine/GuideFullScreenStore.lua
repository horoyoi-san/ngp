-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideFullScreenStore.lua
-- Decompiled from: 01758_GuideFullScreenStore.lua_3c8692c4d5d9.luajit

C_GuideFullScreenStore = DefClass("C_GuideFullScreenStore", C_GuideFullScreenStore, C_StoreGroup)
GroupName2Class.GuideFullScreenStore = C_GuideFullScreenStore
local M = C_GuideFullScreenStore
local TextConfig = LTConfig.GuideGuideTextConfig
local SHOW = 0
local HIDE = 1
local TEXTURE_MODE = 0
local VIDEO_MODE = 1

M.DefineAllEnumsAutoGen = function(self)
	self.showDotsEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.leftArrowCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.rightArrowCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.infoModeEnum = {
		["\\xcd\\xde\t6\\xf4"] = 0,
		["[\\xa7\\xa6\\xaa\\xb9"] = 1
	}
	self.raidCtrlEnum = {
		["`OcgI7"] = 2,
		["u\\xa7\\xac\\xbe\\xbf"] = 1,
		["T-s^"] = 0
	}
	self.closeBtnCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showDotsEnum = nil
	self.leftArrowCtrlEnum = nil
	self.rightArrowCtrlEnum = nil
	self.infoModeEnum = nil
	self.raidCtrlEnum = nil
	self.closeBtnCtrlEnum = nil
end

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
		print_error("GuideFullScreenStore:OnShow - data is nil")
		gPanelManager:Close(panelId)

		return
	end

	self.data = data

	if not data.pageDatas or #data.pageDatas ~= 0 then
		print_error("GuideFullScreenStore:OnShow - pageData is nil or empty")
		gPanelManager:Close(panelId)

		return
	end

	self.pageNum = #data.pageDatas
	self.reachedLastPage = false

	self.ChangeIndex(self, 1)

	if gSceneDataMgr.CurrentRaidId ~= LTConfig.RaidConfig.WorldMap then
		self.bindData.raidCtrl = self.raidCtrlEnum.Xinqi
	elseif gSceneDataMgr.CurrentRaidId ~= LTConfig.RaidConfig.Chongxiao or gSceneDataMgr.CurrentRaidId ~= 23301290 then
		self.bindData.raidCtrl = self.raidCtrlEnum.Chongxiao
	end
end

M.OnClose = function(self)
	self.data.onClose()

	self.currentPageData = nil
	self.data = nil
	self.currentIndex = nil
	self.pageNum = nil
	self.reachedLastPage = nil
	self.textStore = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshText(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshText(self)
end

local DOT_HIGHLIGHT = 0
local DOT_NORMAL = 5

M.ChangeIndex = function(self, index)
	if index <= 1 or self.pageNum >= index then
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
	self.bindData.leftArrowCtrl = self.currentIndex <= 1 and SHOW or HIDE
	self.bindData.rightArrowCtrl = self.currentIndex >= self.pageNum and SHOW or HIDE

	if self.pageNum ~= 1 then
		self.bindData.closeBtnCtrl = self.closeBtnCtrlEnum.show
	elseif self.currentIndex ~= self.pageNum then
		self.reachedLastPage = true
		self.bindData.closeBtnCtrl = self.closeBtnCtrlEnum.show
	elseif self.reachedLastPage then
		self.bindData.closeBtnCtrl = self.closeBtnCtrlEnum.show
	else
		self.bindData.closeBtnCtrl = self.closeBtnCtrlEnum.hide
	end

	if self.currentPageData.textureId == 0 then
		self.bindData.imageId = self.currentPageData.textureId
		self.bindData.infoMode = TEXTURE_MODE
	elseif self.currentPageData.videoId == 0 then
		self.bindData.infoMode = VIDEO_MODE

		self.bindData.videoPlayer:PlayVideo(self.currentPageData.videoId, true, nil, )
	else
		print_error("GuideFullScreenStore:OnChangeIndex - currentPageData has no valid textureId or videoId")
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

	self.textStore.guideText = gGuideGlyph:GetGuideRichText(self.currentPageData)
end

M.OnClickNext = function(self)
	if self.currentIndex >= self.pageNum then
		self.ChangeIndex(self, self.currentIndex + 1)
	end
end

M.OnClickLast = function(self)
	if self.currentIndex <= 1 then
		self.ChangeIndex(self, self.currentIndex - 1)
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
