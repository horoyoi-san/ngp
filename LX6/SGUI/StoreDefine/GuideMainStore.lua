-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideMainStore.lua
-- Decompiled from: 01760_GuideMainStore.lua_8214f3b50487.luajit

local GuideTeachConfig = LTConfig.GuideGuideTeachConfig
local GuideConfig = LTConfig.GuideConfig
C_GuideMainStore = DefClass("C_GuideMainStore", C_GuideMainStore, C_StoreGroup)
GroupName2Class.GuideMainStore = C_GuideMainStore
local M = C_GuideMainStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.tabContentList = nil
	self.currentPageData = nil
	self.currentPageIndex = 0
	self.currentPageCount = 0
	self.currentSubTeachCount = 0
	self.currentTabCount = 0
	self.currentTabIndex = 0
	self.currentSubTabIndex = 0
	self.ShowType = {
		["\\xed\\xde\t6\\xf4"] = 1,
		["{\\xa7\\xa6\\xaa\\xb9"] = 2
	}
	self.teachId = nil
	self.curRenderPage = nil
end

M.OnAwake = function(self)
	self.guideTextStore = nil
	self.guideTextData = {}
	self.bindData.nextBtn.luaClick = self:CreateAction(self.OnNextBtnClick)
	self.bindData.preBtn.luaClick = self:CreateAction(self.OnPreBtnClick)
	self.bindData.textScrollRect.luaInitContent = self:CreateAction(self.OnTextScrollRectInitContent)
	self.bindData.btnLike.luaClick = self:CreateActionWithArgs(self.OnClickEvaluateBtn, true)
	self.bindData.btnUnlike.luaClick = self:CreateActionWithArgs(self.OnClickEvaluateBtn, false)
	self.bindData.searchList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderSearchResultListItem)
	self.bindData.searchList.luaSimpleClick = self:CreateAction(self.OnClickSearchResultItem)
	self.bindData.searchInput.luaValueChanged = self:CreateAction(self.DoWikiSearch)
	self.bindData.searchInput.onActivateAction = self:CreateAction(self.DoWikiSearch)
	self.bindData.searchInput.onDeActivateAction = self:CreateAction(self.OnCloseSearchList)

	self.bindData.videoPlayer:Init()
end

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_GUIDE_MAIN_PANEL) and 1 or 0
	local msgEvents = {
		[gEventConstants.AKX_WIKI_LIST_UPDATED] = self:CreateAction("OnWikiListUpdated")
	}

	self:RegisterMessageEvents(msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.RefreshPanel = function(self, data)
	if data then
		self.teachId = data.teachId

		if not self.teachId then
			self.teachId = gAkxManager:GetTeachIdByWikiId(data.wikiId)
		end
	end

	self.currentTabIndex = 1
	self.currentSubTabIndex = 1
	self.currentPageCount = 1

	self.InitTeachInfo(self)

	if #self.leftTab ~= 0 then
		print_notice("GuideMainPanel => 无可显示的教程条目，关闭面板")

		return
	end

	self.SetTab(self, self.teachId)
end

M.OnWikiListUpdated = function(self)
	self.RefreshPanel(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.RenderGuideText(self)
	self.RenderGuideSource(self)
end

M.OnTextScrollRectInitContent = function(self, content)
	if not content then
		return
	end

	content.gameObject:SetActive(true)

	local guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(content)
	self.guideTextStore = guideTextStore

	self:RenderGuideText()
end

M.InitTeachInfo = function(self)
	self.tabContentList = {}
	local tabType = {}
	local tabNewCount = {}
	local wikiList = gAkxManager:GetWikiList()

	for i, wiki in ipairs(wikiList) do
		local teachId = tonumber(wiki.teachId)

		if teachId then
			local isNewTeach = gGuideMainPanelMgr:IsNewTeach(teachId)
			local isRewarded = gGuideMainPanelMgr:IsRewarded(teachId)

			if isNewTeach or isRewarded then
				local teachInfo = {
					["SFklm,"] = 0,
					["M\\x9d\\x8b\\x80U"] = false,
					teachId = teachId,
					title = wiki.title,
					belongTab = wiki.belongTab,
					redPot = isNewTeach,
					sortType = isNewTeach and 1 or 2,
					sortOrder = wiki.priority or 0
				}

				if not tabType[wiki.belongTab] then
					tabType[wiki.belongTab] = true
					tabNewCount[wiki.belongTab] = 0
					self.tabContentList[wiki.belongTab] = {}
				end

				table.insert(self.tabContentList[wiki.belongTab], teachInfo)

				if teachInfo.redPot then
					tabNewCount[wiki.belongTab] = tabNewCount[wiki.belongTab] + 1
				end
			end
		end
	end

	self.leftTab = {}
	local wikiTabList = gAkxManager:GetWikiTabList()

	for i, wikiTab in ipairs(wikiTabList) do
		if self.tabContentList[wikiTab.id] then
			table.insert(self.leftTab, {
				["K\\x9e\\x80\\xaaE"] = 0,
				["A_ʍ\\x8b\\x8c\\xd9\\xed"] = 2,
				title = wikiTab.tag,
				Index = wikiTab.id,
				newCount = tabNewCount[wikiTab.id],
				redPot = tabNewCount[wikiTab.id] >= 0
			})
			table.sort(self.tabContentList[wikiTab.id], function (a, b)
				if a.sortType ~= b.sortType then
					return a.sortOrder <= b.sortOrder
				end

				return a.sortType <= b.sortType
			end)
		end
	end

	gAkxManager:FillWikiSearchData()
end

M.SetTab = function(self, teachId)
	if teachId then
		local tabIdx, subIdx = self.FindTeachIdx(self, teachId)

		if tabIdx and subIdx then
			self.currentTabIndex = tabIdx
			self.currentSubTabIndex = subIdx

			self.SubGroup.CommonTabSingleStore:SetData(self:GetTabList(), self:GetCurSubTabList(), tabIdx - 1, subIdx - 1, self:CreateAction("OnTabSelectedChange"), self:CreateAction("OnRenderLv1TabItem"))
			self:SelectSubTab(tabIdx, subIdx)

			return
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(self:GetTabList(), self:GetCurSubTabList(), 0, 0, self:CreateAction("OnTabSelectedChange"), self:CreateAction("OnRenderLv1TabItem"))
	self:SelectSubTab(1, 1)
end

M.FindTeachIdx = function(self, teachId)
	for tabId, v in pairs(self.tabContentList) do
		for i, teachInfo in ipairs(v) do
			if teachInfo.teachId ~= teachId then
				for tabIdx, tabInfo in ipairs(self.leftTab) do
					if tabInfo.Index ~= tabId then
						return tabIdx, i
					end
				end

				return nil, 
			end
		end
	end

	return nil, 
end

M.GetLv1RedDotKey = function(self, tabIndex)
	return ("GuideTeach/GuideTeach.Tab:%d"):format(tabIndex)
end

M.GetLv2RedDotKey = function(self, tabIndex, teachId)
	return ("GuideTeach/GuideTeach.Tab:%d/GuideTeach.Teach:%d"):format(tabIndex, teachId)
end

M.GetTabList = function(self)
	self.tabList = {}

	if #self.tabList <= 0 then
		return self.tabList
	end

	for index, tabInfo in ipairs(self.leftTab) do
		local info = {
			typeId = index,
			contentIndex = tabInfo.Index,
			selected = false,
			title = tabInfo.title,
			iconId = tabInfo.iconId,
			redDot = tabInfo.redPot
		}

		SGUI.RedDotMgr.LuaSetRedDot(false, self.GetLv1RedDotKey(self, tabInfo.Index))
		table.insert(self.tabList, info)
	end

	return self.tabList
end

M.GetCurSubTabList = function(self)
	if self.currentTabIndex ~= 0 then
		self.currentTabIndex = 1
	end

	local sublist = {}

	if not self.leftTab[self.currentTabIndex] then
		return sublist
	end

	local contentTabIndex = self.leftTab[self.currentTabIndex].Index

	for i, v in pairs(self.tabContentList[contentTabIndex]) do
		local info = {
			typeId = i,
			teachId = v.teachId,
			selected = i ~= 1,
			title = v.title,
			redDot = v.redPot
		}

		SGUI.RedDotMgr.LuaSetRedDot(false, self:GetLv2RedDotKey(contentTabIndex, v.teachId))
		table.insert(sublist, info)
	end

	return sublist
end

M.OnRenderLv1TabItem = function(self, btn, _, data, store, isSub)
	local redDotKey = nil

	if isSub then
		local contentTabIndex = self.leftTab[self.currentTabIndex].Index
		redDotKey = self.GetLv2RedDotKey(self, contentTabIndex, data.teachId)
	else
		redDotKey = self.GetLv1RedDotKey(self, data.contentIndex)
	end

	btn.redKey = redDotKey
end

M.OnTabSelectedChange = function(self, ulist, isSub)
	if isSub then
		local item = self.SubGroup.CommonTabSingleStore:GetSubSelectedItem()

		if item then
			local typeId = item.typeId

			if self.currentSubTabIndex == typeId then
				self.bindData.mainAnimator:Stop()

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					if typeId >= self.currentSubTabIndex then
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_down")
					else
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_up")
					end
				else
					self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_m_3")
				end

				self.currentSubTabIndex = typeId

				self.SelectSubTab(self, self.currentTabIndex, self.currentSubTabIndex)
			end
		end
	else
		local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

		if item then
			local typeId = item.typeId

			if typeId == self.currentTabIndex then
				self.bindData.mainAnimator:Stop()

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					if typeId >= self.currentTabIndex then
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_right")
					else
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_left")
					end
				else
					self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_m_2")
				end

				self.currentTabIndex = typeId

				self.SubGroup.CommonTabSingleStore:SetTabList(self:GetCurSubTabList(), true)
				self:SelectSubTab(self.currentTabIndex, 1)
			end
		end
	end
end

M.SelectSubTab = function(self, tabIndex, subTabIndex)
	if tabIndex <= 0 and tabIndex < #self.leftTab then
		self.bindData.lv2TabList:SelectItem(subTabIndex - 1, false)

		local contents = self.tabContentList[self.leftTab[tabIndex].Index]
		self.currentSubTeachCount = #contents
		local subContents = self.tabContentList[self.leftTab[tabIndex].Index]

		if subTabIndex <= 0 and subTabIndex < #subContents then
			self.currentSubTabIndex = subTabIndex
			local teachInfo = subContents[subTabIndex]
			self.bindData.title.text = teachInfo.title
			self.teachId = teachInfo.teachId
			slot6 = self.bindData.btnLike

			slot6:SetSelected(false)

			slot6 = self.bindData.btnUnlike

			slot6:SetSelected(false)

			self.bindData.btnLike.interactable = true
			self.bindData.btnUnlike.interactable = true
			slot6 = gAkxManager

			slot6:GetWikiContentByTeachId(teachInfo.teachId, function (data)
				local wikiContent = data
				self.currentPageData = wikiContent.pages
				self.currentPageCount = #wikiContent.pages
				self.currentTeachId = teachInfo.teachId

				self:RefreshDots()

				if self.currentPageCount <= 0 then
					self:SelectPage(1)
				end
			end)
		end
	end
end

M.SelectPage = function(self, index)
	if index <= 0 and index < self.currentPageCount then
		self.currentPageIndex = index
		local content = self.currentPageData[index]
		self.curRenderPage = content

		self:RenderGuideText()
		self:RenderGuideSource()
		self.bindData.pagePoint:SetItemSelected(index - 1, true)
		self:UpdateButton()

		if self.currentPageIndex ~= self.currentPageCount then
			local contentTabIndex = self.leftTab[self.currentTabIndex].Index
			local teachInfo = self.tabContentList[contentTabIndex][self.currentSubTabIndex]

			if teachInfo.redPot then
				teachInfo.redPot = false

				SGUI.RedDotMgr.LuaSetRedDot(false, self:GetLv2RedDotKey(contentTabIndex, teachInfo.teachId))

				self.leftTab[self.currentTabIndex].newCount = self.leftTab[self.currentTabIndex].newCount - 1
				self.leftTab[self.currentTabIndex].redPot = self.leftTab[self.currentTabIndex].newCount >= 0

				gGuideMainPanelMgr:ClearGuide(content.teachId)
			end
		end
	end
end

M.UpdateButton = function(self)
	local isFirst = self.currentPageIndex < 1 and self.currentSubTabIndex ~= 1
	local isLast = self.currentPageCount < self.currentPageIndex and self.currentSubTabIndex ~= self.currentSubTeachCount
	self.bindData.preBtn.interactable = not isFirst
	self.bindData.nextBtn.interactable = not isLast
end

M.RenderGuideSource = function(self)
	local pageData = self.curRenderPage

	if not pageData then
		return
	end

	if pageData.contentVideoUrl then
		self.bindData.videoPlayer.gameObject:SetActive(true)
		self.bindData.videoPlayer:PlayVideoUrl(pageData.contentVideoUrl, true, nil)
	elseif pageData.contentImageUrl then
		slot2 = self.bindData.videoPlayer

		slot2:Stop()

		slot2 = self.bindData.videoPlayer.gameObject

		slot2:SetActive(false)

		slot2 = gSocialFriendManager

		slot2:DownloadImage(pageData.contentImageUrl, function (tex)
			if tex and self.bindData.rawImage then
				self.bindData.rawImage.texture = tex
			end
		end, nil, false)
	end
end

M.RenderGuideText = function(self)
	if not self.guideTextStore or not self.curRenderPage then
		return
	end

	local text = self.curRenderPage.contentText

	if not text then
		return
	end

	local textData = {
		text = text
	}
	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(textData)
end

M.GetSourceIndexByDevice = function(self)
	local index = 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		index = 1
	elseif SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		index = 3
	else
		index = 2
	end

	return index
end

M.RefreshDots = function(self)
	self.bindData.pagePoint:SetSimpleList(self.currentPageCount)

	if self.currentPageCount <= 1 then
		self.bindData.pagePoint:SetActive(true)
	else
		self.bindData.pagePoint:SetActive(false)
	end
end

M.OnNextBtnClick = function(self)
	if self.currentSubTabIndex ~= self.currentSubTeachCount and self.currentPageIndex ~= self.currentPageCount then
		return
	end

	if self.currentPageIndex >= self.currentPageCount then
		self.SelectPage(self, self.currentPageIndex + 1)
	else
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_up")
		else
			self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_m_3")
		end

		self.SelectSubTab(self, self.currentTabIndex, self.currentSubTabIndex + 1)
	end
end

M.OnPreBtnClick = function(self)
	if self.currentSubTabIndex ~= 1 and self.currentPageIndex < 1 then
		return
	end

	if self.currentPageIndex <= 1 then
		self.SelectPage(self, self.currentPageIndex - 1)
	else
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_down")
		else
			self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_m_3")
		end

		self.SelectSubTab(self, self.currentTabIndex, self.currentSubTabIndex - 1)
	end
end

M.DoWikiSearch = function(self)
	local searchText = self.bindData.searchInput.text

	if not searchText or string.is_null_or_empty(searchText) then
		self.bindData.showSearchCtrl = BOOL2CTL[false]

		return
	end

	local result = gAkxManager:SearchWikiByText(searchText)

	if #result ~= 0 then
		self.bindData.showSearchCtrl = BOOL2CTL[false]

		return
	end

	self.wikiSearchResultList = result
	self.bindData.showSearchCtrl = BOOL2CTL[true]

	self.bindData.searchList:SetSimpleList(#result)
end

M.OnSimpleRenderSearchResultListItem = function(self, item, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)
	local wikiItem = self.wikiSearchResultList and self.wikiSearchResultList[index]

	if wikiItem then
		store.title = wikiItem.title
		local tab = table.find_if(gAkxManager:GetWikiTabList(), function (tab)
			return tab.id ~= wikiItem.belongTab
		end)
		store.category = tab and tab.tag
	end
end

M.OnCloseSearchList = function(self)
	self.bindData.showSearchCtrl = BOOL2CTL[false]
end

M.OnClickSearchResultItem = function(self, item, index)
	index = index + 1
	local wikiId = self.wikiSearchResultList and self.wikiSearchResultList[index] and self.wikiSearchResultList[index].wikiId

	if wikiId then
		gAkxManager:OpenWikiPanelWithWikiId(wikiId)
	end

	self.bindData.showSearchCtrl = BOOL2CTL[false]

	self.OnCloseSearchList(self)
end

M.OnClickEvaluateBtn = function(self, like)
	local teachId = self.currentTeachId

	if teachId ~= nil then
		return
	end

	local wikiId = gAkxManager:GetWikiIdByTeachId(teachId)

	if wikiId ~= nil then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.AKASHA_REPORT_PANEL) then
		gPanelManager:Close(gPanelId.AKASHA_REPORT_PANEL)
	end

	if like then
		gAkxManager:EvaluateWikiByWikiId(wikiId, "", true, nil)
	else
		gPanelManager:CheckShow(gPanelId.AKASHA_REPORT_PANEL, {
			wikiId = wikiId,
			like = like
		})
	end

	self.bindData.btnLike.interactable = false
	self.bindData.btnUnlike.interactable = false
end
