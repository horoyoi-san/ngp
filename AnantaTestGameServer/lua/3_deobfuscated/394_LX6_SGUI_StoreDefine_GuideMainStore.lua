local GuideTeachConfig = LTConfig.GuideGuideTeachConfig
local GuideConfig = LTConfig.GuideConfig
C_GuideMainStore = DefClass("C_GuideMainStore", C_GuideMainStore, C_StoreGroup)
GroupName2Class.GuideMainStore = C_GuideMainStore
local M = C_GuideMainStore

function M:ctor()
	self.tabContentList = nil
	self.currentPageData = nil
	self.currentPageIndex = 0
	self.currentPageCount = 0
	self.currentSubTeachCount = 0
	self.currentTabCount = 0
	self.currentTabIndex = 0
	self.currentSubTabIndex = 0
	self.ShowType = {
		Texture = 1,
		Video = 2
	}
	self.curRenderText = nil
	self.curRenderSource = nil
end

function M:OnAwake()
	self.guideTextData = {}
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.nextBtn.luaClick = self:CreateAction("OnNextBtnClick")
	self.bindData.preBtn.luaClick = self:CreateAction("OnPreBtnClick")
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_GUIDE_MAIN_PANEL) and 1 or 0
end

function M:OnShow(panelId, data)
	self.currentTabIndex = 1
	self.currentSubTabIndex = 1
	self.currentPageCount = 1
	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.bindData.guideTextBase)

	self:InitTeachInfo()
	self:SetTab()
end

function M:OnActiveDeviceChange(device)
	self:RenderGuideText()
	self:RenderGuideSource()
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_GUIDE_MAIN_PANEL)
end

function M:InitTeachInfo()
	self.tabContentList = {}
	local tabType = {}
	local tabNewCount = {}

	for i = 0, GuideTeachConfig.count - 1 do
		local teachCfg = GuideTeachConfig.LoadAt(i)

		if teachCfg then
			local isNewTeach = gGuideMainPanelMgr:IsNewTeach(teachCfg.Id)
			local isRewarded = gGuideMainPanelMgr:IsRewarded(teachCfg.Id)

			if isNewTeach or isRewarded then
				local teachInfo = {
					redPot = false,
					select = false,
					pageCount = 0,
					teachId = teachCfg.Id,
					pageData = {},
					title = teachCfg.Name,
					belongTab = teachCfg.BelongTab,
					sortType = isNewTeach and 1 or 2,
					sortOrder = teachCfg.Sort
				}

				for i = 1, 5 do
					local source = teachCfg["Source" .. i]

					if not table.isNilOrEmpty(source) then
						local page = {
							teachId = teachCfg.Id,
							id = source.sourceId,
							text = teachCfg["Desc" .. i],
							source = source
						}

						table.insert(teachInfo.pageData, page)

						teachInfo.pageCount = teachInfo.pageCount + 1
					end
				end

				if not tabType[teachCfg.BelongTab] then
					tabType[teachCfg.BelongTab] = true
					tabNewCount[teachCfg.BelongTab] = 0
					self.tabContentList[teachCfg.BelongTab] = {}
				end

				table.insert(self.tabContentList[teachCfg.BelongTab], teachInfo)

				if teachInfo.redPot then
					tabNewCount[teachCfg.BelongTab] = tabNewCount[teachCfg.BelongTab] + 1
				end
			end
		else
			print_notice("GuideMainPanel => 第", i + 1, "条数据添加失败，获取cfg失败，Cfg为空")
		end
	end

	self.leftTab = {}

	for i = 1, #GuideConfig.TeachTabName do
		if self.tabContentList[i] then
			table.insert(self.leftTab, {
				redPotType = 2,
				title = GuideConfig.TeachTabName[i],
				iconId = GuideConfig.TeachTabIcon[i],
				Index = i,
				newCount = tabNewCount[i],
				redPot = tabNewCount[i] > 0
			})
			table.sort(self.tabContentList[i], function (a, b)
				if a.sortType == b.sortType then
					return a.sortOrder < b.sortOrder
				end

				return a.sortType < b.sortType
			end)
		else
			print_notice("GuideMainPanel => ", GuideConfig.TeachTabName[i], "下没有添加任何内容，不予显示")
		end
	end
end

function M:SetTab()
	self.SubGroup.CommonTabSingleStore:SetData(self:GetTabList(), self:GetCurSubTabList(), 0, 0, self:CreateAction("OnTabSelectedChange"), self:CreateAction("OnRenderLv1TabItem"))
	self:SelectSubTab(1, 1)
end

function M:GetLv1RedDotKey(Id)
	return ("GuideLv1RedDot:%d"):format(Id)
end

function M:GetLv2RedDotKey(Id)
	return ("GuideLv2RedDot:%d"):format(Id)
end

function M:GetTabList()
	self.tabList = {}

	if #self.tabList > 0 then
		return self.tabList
	end

	for index, tabInfo in ipairs(self.leftTab) do
		local info = {
			typeId = index,
			selected = false,
			title = tabInfo.title,
			iconId = tabInfo.iconId,
			redDot = tabInfo.redPot
		}

		SGUI.RedDotMgr.LuaSetRedDot(info.redDot, self:GetLv1RedDotKey(tabInfo.Index))
		table.insert(self.tabList, info)
	end

	return self.tabList
end

function M:GetCurSubTabList()
	if self.currentTabIndex == 0 then
		self.currentTabIndex = 1
	end

	local sublist = {}
	local contentTabIndex = self.leftTab[self.currentTabIndex].Index

	for i, v in pairs(self.tabContentList[contentTabIndex]) do
		local info = {
			typeId = i,
			selected = i == 1,
			title = v.title,
			redDot = v.redPot
		}

		SGUI.RedDotMgr.LuaSetRedDot(info.redDot, self:GetLv2RedDotKey(i))
		table.insert(sublist, info)
	end

	return sublist
end

function M:OnRenderLv1TabItem(btn, _, data, store, isSub)
	local redDotKey = nil

	if isSub then
		redDotKey = self:GetLv2RedDotKey(data.typeId)
	else
		redDotKey = self:GetLv1RedDotKey(data.typeId)
	end

	btn.redKey = redDotKey
end

function M:OnTabSelectedChange(ulist, isSub)
	if isSub then
		local item = self.SubGroup.CommonTabSingleStore:GetSubSelectedItem()

		if item then
			local typeId = item.typeId

			if self.currentSubTabIndex ~= typeId then
				self.bindData.mainAnimator:Stop()

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					if typeId < self.currentSubTabIndex then
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_down")
					else
						self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_PC_up")
					end
				else
					self.bindData.mainAnimator:Play("S_Vx_GuideMainPanel_m_3")
				end

				self.currentSubTabIndex = typeId

				self:SelectSubTab(self.currentTabIndex, self.currentSubTabIndex)
			end
		end
	else
		local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

		if item then
			local typeId = item.typeId

			if typeId ~= self.currentTabIndex then
				self.bindData.mainAnimator:Stop()

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					if typeId < self.currentTabIndex then
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

function M:SelectSubTab(tabIndex, subTabIndex)
	if tabIndex > 0 and tabIndex <= #self.leftTab then
		self.bindData.lv2TabList:SelectItem(subTabIndex - 1, false)

		local contents = self.tabContentList[self.leftTab[tabIndex].Index]
		self.currentSubTeachCount = #contents
		local subContents = self.tabContentList[self.leftTab[tabIndex].Index]

		if subTabIndex > 0 and subTabIndex <= #subContents then
			self.currentSubTabIndex = subTabIndex
			local teachInfo = subContents[subTabIndex]
			self.bindData.title.text = teachInfo.title
			self.currentPageData = teachInfo.pageData
			self.currentPageCount = teachInfo.pageCount
			self.currentTeachId = teachInfo.teachId

			self:RefreshDots()

			if self.currentPageCount > 0 then
				self:SelectPage(1)
			end
		end
	end
end

function M:SelectPage(index)
	if index > 0 and index <= self.currentPageCount then
		self.currentPageIndex = index
		local content = self.currentPageData[index]
		self.curRenderText = content.text
		self.curRenderSource = content.source

		self:RenderGuideText()
		self:RenderGuideSource()
		self.bindData.pagePoint:SetItemSelected(index - 1, true)
		self:UpdateButton()

		if self.currentPageIndex == self.currentPageCount and self.tabContentList[self.leftTab[self.currentTabIndex].Index][self.currentSubTabIndex].redPot then
			self.tabContentList[self.leftTab[self.currentTabIndex].Index][self.currentSubTabIndex].redPot = false

			SGUI.RedDotMgr.LuaSetRedDot(false, self:GetLv2RedDotKey(self.currentSubTabIndex))

			self.leftTab[self.currentTabIndex].newCount = self.leftTab[self.currentTabIndex].newCount - 1
			self.leftTab[self.currentTabIndex].redPot = self.leftTab[self.currentTabIndex].newCount > 0

			SGUI.RedDotMgr.LuaSetRedDot(self.leftTab[self.currentTabIndex].newCount > 0, self:GetLv1RedDotKey(self.currentTabIndex))
			gGuideMainPanelMgr:ClearGuide(content.teachId)
		end
	end
end

function M:UpdateButton()
	local isFirst = self.currentPageIndex <= 1 and self.currentSubTabIndex == 1
	local isLast = self.currentPageCount <= self.currentPageIndex and self.currentSubTabIndex == self.currentSubTeachCount
	self.bindData.preBtn.interactable = not isFirst
	self.bindData.nextBtn.interactable = not isLast
end

function M:RenderGuideSource()
	local allSource = self.curRenderSource

	if #allSource ~= 1 and #allSource ~= 3 then
		print_error(" GuideTeach表 source 配置有误 请修改 只能配置一个 或三个    （需求 ： 当单元格中配置了数组或struct结构时，每段分别对应一个端口（手机、PC、controller）；如果只配了一段，表示多端共用这一个描述；）")
		print_debug(self.currentPageData)

		return
	end

	local index = 0
	index = #allSource == 1 and 1 or self:GetSourceIndexByDevice()
	local source = allSource[index]
	self.bindData.type = source.sourceType

	if source.sourceType == self.ShowType.Video then
		self.bindData.videoPlayer.gameObject:SetActive(true)
		self.bindData.videoPlayer:Init()
		self.bindData.videoPlayer:PlayVideo(source.sourceId, true, nil)
	else
		self.bindData.videoPlayer:Stop()
		self.bindData.videoPlayer.gameObject:SetActive(false)

		self.bindData.iconId = source.sourceId
	end
end

function M:RenderGuideText()
	local text = self.curRenderText

	if #text ~= 1 and #text ~= 3 then
		if text[1] then
			print_error(" GuideTeach表 text 配置有误 请修改 只能配置一个 或三个    （需求 ： 当单元格中配置了数组或struct结构时，每段分别对应一个端口（手机、PC、controller）；如果只配了一段，表示多端共用这一个描述；）")
			print_debug(self.currentPageData)

			self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(text[1])
		else
			self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText({
				textId = 0
			})
		end

		return
	end

	local textData = {}
	local index = 0
	index = #text == 1 and 1 or self:GetSourceIndexByDevice()
	textData.text = text[index]
	self.guideTextStore.guideText = gGuideGlyph:GetGuideRichText(textData)
end

function M:GetSourceIndexByDevice()
	local index = 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		index = 1
	elseif SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		index = 3
	else
		index = 2
	end

	return index
end

function M:RefreshDots()
	self.bindData.pagePoint:SetSimpleList(self.currentPageCount)

	if self.currentPageCount > 1 then
		self.bindData.pagePoint:SetActive(true)
	else
		self.bindData.pagePoint:SetActive(false)
	end
end

function M:OnNextBtnClick()
	if self.currentSubTabIndex == self.currentSubTeachCount and self.currentPageIndex == self.currentPageCount then
		return
	end

	if self.currentPageIndex < self.currentPageCount then
		self:SelectPage(self.currentPageIndex + 1)
	else
		self:SelectSubTab(self.currentTabIndex, self.currentSubTabIndex + 1)
	end
end

function M:OnPreBtnClick()
	if self.currentSubTabIndex == 1 and self.currentPageIndex <= 1 then
		return
	end

	if self.currentPageIndex > 1 then
		self:SelectPage(self.currentPageIndex - 1)
	else
		self:SelectSubTab(self.currentTabIndex, self.currentSubTabIndex - 1)
	end
end
