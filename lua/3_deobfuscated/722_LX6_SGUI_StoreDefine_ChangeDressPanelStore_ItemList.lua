local M = C_ChangeDressPanelStore
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local RedDotMgr = SGUI.RedDotMgr
local MessageConfig = LTConfig.MessageConfig

function M:InitList()
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabList")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnSelectTab")
	self.bindData.tabList.luaLayoutSet = self:CreateAction("OnTabFinish")
	self.bindData.tabTopList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabTopList")
	self.bindData.tabTopList.luaSelectedChanged = self:CreateAction("OnSelectTabTop")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")
	self.bindData.suitList.luaSimpleRenderItem = self:CreateAction("OnRefreshSuitList")
	self.bindData.suitList.luaSimpleClick = self:CreateAction("OnChangeSuit")
	self.bindData.suitFashionList.luaSimpleRenderItem = self:CreateAction("OnRefreshSuitFashionList")
	self.bindData.suitFashionList.luaSimpleClick = self:CreateAction("OnChangeSuitFashion")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnRefreshTagList")
	self.msgEvents = {
		[gEventConstants.RESET_PLAYER_FASHION_DATA] = self:CreateAction("ResetPlayerFashionData")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow_Item()
	self.finishTabLayOut = false
	self.gotoIndexFashionId = 0
	self.recordItems = {}
	self.itemList = {}
	self.suitRecordItemList = nil

	self:InitFashionItemList()
	self:InitTabList()
	self:InitTabTopList()
	self:InitFashionSuitList()
	self:InitSelectorList()
end

function M:DestroyItemData()
	self:ClearMessageEvents()
end

function M:InitTabList()
	self.tabList = {}
	local FashionChangeTabIcon = FashionConfig.FashionChangeTabIcon
	local FashionChangeTabName = FashionConfig.FashionChangeTabName

	for i = 1, #FashionChangeTabIcon do
		local view = {
			depth = 1,
			Part = FashionChangeTabIcon[i].part,
			id = #self.tabList + 1,
			tabIndex = i,
			IconId = FashionChangeTabIcon[i].IconId,
			PartName = FashionChangeTabName[i].Name
		}

		table.insert(self.tabList, view)
	end

	self.tabIndex = self:GetTabIndex()

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SelectItem(self.tabIndex - 1)
	self.bindData.tabList:SetNavSelectToSelect(true)
end

function M:GetTabIndex()
	local tabIndex = 1
	local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

	print(" 换装界面默认tab为当前上衣（type=1）的item所在的tab")

	if self.taskSuitId and self.taskSuitId > 0 then
		for j = 1, #self.tabList do
			if self.tabList[j].Part == gDressManager.DRESS_PART.SUITS then
				tabIndex = self.tabList[j].tabIndex

				return tabIndex
			end
		end
	end

	if spriteFashionInfo and spriteFashionInfo.WearFashionInfoList then
		for i = 1, #spriteFashionInfo.WearFashionInfoList do
			local fashionId = spriteFashionInfo.WearFashionInfoList[i].FashionId
			local cfg = FashionConfig.GetConfig(fashionId)

			if cfg then
				if cfg.Part == gDressManager.DRESS_PART.TOPS then
					for j = 1, #self.tabList do
						if self.tabList[j].Part == gDressManager.DRESS_PART.TOPS then
							tabIndex = self.tabList[j].tabIndex

							return tabIndex
						end
					end
				elseif cfg.Part == gDressManager.DRESS_PART.BODY_SUIT then
					for j = 1, #self.tabList do
						if self.tabList[j].Part == gDressManager.DRESS_PART.BODY_SUIT then
							tabIndex = self.tabList[j].tabIndex

							return tabIndex
						end
					end
				end
			end
		end
	end

	return tabIndex
end

function M:InitTabTopList()
	self.tabTopList = {}
	local FashionPropTabIcon = FashionConfig.FashionPropTabIcon
	local FashionPropTabName = FashionConfig.FashionPropTabName

	for t = 1, #FashionPropTabIcon do
		local view = {
			depth = 2,
			Part = gDressManager.DRESS_PART.PROP,
			IconId = FashionPropTabIcon[t].IconId,
			PartName = FashionPropTabName[t].Name,
			Type = FashionPropTabIcon[t].type,
			tabTopIndex = t
		}

		table.insert(self.tabTopList, view)
	end

	self.bindData.tabTopList:SetSimpleList(#self.tabTopList)
end

function M:InitFashionItemList()
	self.selectPlayerSex = gDressManager.CurrentSpiritInfo.Sex
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	self.itemList = {}
	self.itemListByPart = {}

	for _, fashionInfo in pairs(fashionInfoDict) do
		local fashionId = fashionInfo.FashionId

		if gDressManager:CheckCurrentSpritShowFashion(fashionId) then
			local fashionCfg = FashionConfig.GetConfig(fashionId)

			if fashionCfg == nil then
				print_warn("当前时装在配表中未找到,时装id来源于服务器PlayerFashionsInfo.FashionInfoDict  fashionId = " .. fashionId)
			end

			local view = {
				fashionId = fashionId
			}
			view.isCollect = gDressManager:IsFashinCollected(view.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			view.isNew = fashionInfo.Status == 1 or false
			view.ExpiredTime = fashionInfo.ExpiredTime
			view.GainTime = fashionInfo.GainTime

			if fashionCfg then
				view.icon = fashionCfg.Icon
				view.quality = fashionCfg.Quality
				view.Part = fashionCfg.Part
				view.Types = fashionCfg.Types
				view.Sex = fashionCfg.Gender
				view.Name = fashionCfg.Name
				view.EditId = fashionCfg.EditId
				view.BelongBrand = fashionCfg.BelongBrand
				view.Coloring = gDressDyeManager.ConvertToColoringType(fashionCfg.Coloring)
				view.isAvailable = (self.selectPlayerSex == fashionCfg.Gender or fashionCfg.Gender == 0) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
				view.Tags = fashionCfg.Tags

				if table.isNilOrEmpty(self.itemListByPart[view.Part]) then
					self.itemListByPart[view.Part] = {}
				end

				if view.isAvailable == self.SELECT_TYPE.TRUE then
					if self.fashionType > 0 then
						if not table.isNilOrEmpty(view.Tags) and table.contains(view.Tags, self.fashionType) then
							table.insert(self.itemListByPart[view.Part], view)
							table.insert(self.itemList, view)
						end
					else
						table.insert(self.itemListByPart[view.Part], view)
						table.insert(self.itemList, view)
					end

					view.id = #self.itemList
				end
			end
		end
	end

	self.suitRecordItemList = table.clone(self.itemList)
end

function M:InitFashionSuitList()
	self.suitFashionItemList = {}

	for i = 1, #self.suitRecordItemList do
		local view = table.clone(self.suitRecordItemList[i])
		view.suitIds = gDressManager:GetSuitIdByFashionId(view.fashionId)

		for t = 1, #view.suitIds do
			local suitId = view.suitIds[t]

			if self.suitFashionItemList[suitId] == nil then
				self.suitFashionItemList[suitId] = {}
			end

			table.insert(self.suitFashionItemList[suitId], view)
		end
	end

	self.suitList = {}

	for suitId, fashionList in pairs(self.suitFashionItemList) do
		local view = {
			suitId = suitId
		}
		local cfg = FashionSuitConfig.GetConfig(view.suitId)

		if cfg and cfg.IsShow then
			view.icon = cfg.Icon
			view.haveFashionCount = #fashionList
			view.fashionList = cfg.FashionIdList
			local isAvailable = self.SELECT_TYPE.TRUE

			for t = 1, #fashionList do
				if fashionList[t].isAvailable == self.SELECT_TYPE.FALSE and isAvailable == self.SELECT_TYPE.TRUE then
					isAvailable = self.SELECT_TYPE.FALSE
				end

				if view.GainTime == nil then
					view.GainTime = 0
				end

				view.GainTime = math.max(view.GainTime, fashionList[t].GainTime)
			end

			view.quality = fashionList[1].quality
			local fashionCfg = FashionConfig.GetConfig(cfg.FashionIdList[1])

			if fashionCfg then
				local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

				if brandCfg then
					view.iconBg = brandCfg.SuitBG
				end
			end

			local gender = self.GENDER.UNKNOWN

			for t = 1, #cfg.FashionIdList do
				local fashionCfg = FashionConfig.GetConfig(cfg.FashionIdList[t])

				if fashionCfg and gender == self.GENDER.UNKNOWN and fashionCfg.Gender ~= self.GENDER.UNKNOWN then
					gender = fashionCfg.Gender
				end
			end

			if gender == self.selectPlayerSex or gender == self.GENDER.UNKNOWN then
				view.isAvailable = isAvailable
				view.Sex = gender
				view.Part = gDressManager.DRESS_PART.SUITS
				view.isCollect = gDressManager:IsFashinSuitCollected(view.suitId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
				view.totalFashionCount = #cfg.FashionIdList
				view.isNew = gDressManager:IsFashionListHasRedDotNew(cfg.FashionIdList)

				if view.totalFashionCount > 0 and view.totalFashionCount == view.haveFashionCount then
					table.insert(self.suitList, view)

					view.id = #self.suitList
				end
			end
		end
	end

	self.suitList = self:FilterItems(self.suitList)

	self.bindData.suitList:SetSimpleList(#self.suitList)
	self.bindData.suitList:PlayStartOffsetAnim()
end

function M:OnRefreshTabList(btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("ClothingTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.IconId

		if btn.isSelected then
			if data.Part == gDressManager.DRESS_PART.SUITS then
				self.bindData.partCount = table.count(self.suitList)
			else
				self.bindData.partCount = table.isNilOrEmpty(self.itemListByPart[data.Part]) and 0 or #self.itemListByPart[data.Part]
			end

			self.bindData.partDes = data.PartName
		end
	end
end

function M:OnTabFinish()
	self.finishTabLayOut = true
end

function M:OnSelectTab(data)
	self.tabIndex = data.selectedIndex + 1
	local tabData = self.tabList[self.tabIndex]

	if tabData then
		self:OnChangeTab(nil, tabData)
	end
end

function M:OnChangeTab(btn, data)
	self.currentTabData = data
	self.bindData.partDes = data.PartName
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.recordItems = {}

	if self.finishTabLayOut then
		self.bindData.tabList:GoToIndex(self.tabIndex - 1, false)
	end

	if self:IsInGamePad() then
		self.bindData.navArea.rightNav = data.Part == gDressManager.DRESS_PART.SUITS and self.bindData.suitList.transform:GetComponent(typeof(SGUI.UNavigationArea)) or self.bindData.itemList.transform:GetComponent(typeof(SGUI.UNavigationArea))
	end

	if data.Part == gDressManager.DRESS_PART.SUITS then
		self.bindData.type = self.OPEN_TYPE.SUIT
		self.suitList = self:FilterItems(self.suitList)

		self.bindData.suitList:SetSimpleList(#self.suitList)

		self.bindData.partCount = table.count(self.suitList)
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.hasSecondTab = 1

		self.bindData:Commit("type", self.OPEN_TYPE.SUIT, COMMIT_IMMEDIATELY)
		self.bindData.suitList:PlayStartOffsetAnim(0)
	elseif data.Part == gDressManager.DRESS_PART.PROP then
		self.bindData.hasSecondTab = 0
		self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		data.Type = FashionConfig.FashionPropTabIcon[1].type
		self.bindData.partDes = FashionConfig.FashionPropTabName[1].Name
		self.bindData.type = self.OPEN_TYPE.FASHION

		self.bindData:Commit("type", self.OPEN_TYPE.FASHION, COMMIT_IMMEDIATELY)

		local itemList = self.itemListByPart[data.Part] or {}
		local propItemList = {}

		for i = 1, #itemList do
			if table.contains(itemList[i].Types, data.Type) then
				table.insert(propItemList, itemList[i])
			end
		end

		self.itemList = self:FilterItems(propItemList) or {}
		self.bindData.partCount = table.count(self.itemList)

		self.bindData.itemList:SetSimpleList(#self.itemList)
		self.bindData.itemList:PlayStartOffsetAnim(0)
		self.bindData.tabTopList:SelectItem(self.tabTopIndex - 1, true)
	else
		self.bindData.hasSecondTab = 1
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.type = self.OPEN_TYPE.FASHION

		self.bindData:Commit("type", self.OPEN_TYPE.FASHION, COMMIT_IMMEDIATELY)

		if not table.isNilOrEmpty(self.itemListByPart) then
			self.itemList = self:FilterItems(self.itemListByPart[data.Part]) or {}
			self.bindData.partCount = table.count(self.itemList)

			self.bindData.itemList:SetSimpleList(#self.itemList)
			self.bindData.itemList:PlayStartOffsetAnim(0)

			self.recordItems = self.itemList

			self:OnItemFinish()
		end
	end
end

function M:OnRefreshTabTopList(btn, index)
	local data = self.tabTopList[index + 1]
	local store = gStoreManager:GetStoreGroup("ClothingTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.IconId

		if self.tabIndex == #self.tabList then
			btn.isSelected = data.tabTopIndex == self.tabTopIndex
		end

		if btn.isSelected then
			if data.Part == gDressManager.DRESS_PART.SUITS then
				self.bindData.partCount = table.count(self.suitList)
			else
				self.bindData.partCount = table.isNilOrEmpty(self.itemListByPart[data.Part]) and 0 or #self.itemListByPart[data.Part]
			end

			self.bindData.partDes = data.PartName
		end
	end
end

function M:OnSelectTabTop(data)
	self.tabTopIndex = data.selectedIndex + 1
	local tabTopData = self.tabTopList[self.tabTopIndex]

	if tabTopData then
		self:OnChangeTabTop(nil, tabTopData)
	end
end

function M:OnChangeTabTop(btn, data)
	self.bindData.showSwitch = self.SELECT_TYPE.TRUE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.bindData.partDes = data.PartName
	self.bindData.type = self.OPEN_TYPE.FASHION

	self.bindData.tabTopList:GoToIndex(self.tabTopIndex - 1, false)

	local itemList = self.itemListByPart[data.Part] or {}
	local propItemList = {}

	for i = 1, #itemList do
		if table.contains(itemList[i].Types, data.Type) then
			table.insert(propItemList, itemList[i])
		end
	end

	self.itemList = self:FilterItems(propItemList) or {}
	self.bindData.partCount = table.count(self.itemList)

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.bindData.itemList:PlayStartOffsetAnim()
end

function M:InitSuitFashionRightList()
	if self.suitId == nil or self.suitId == 0 then
		return
	end

	self.suitFashionRightList = {}
	local cfg = FashionSuitConfig.GetConfig(self.suitId)

	if cfg then
		for i = 1, #cfg.FashionIdList do
			local view = {
				fashionId = cfg.FashionIdList[i]
			}
			local fashionCfg = FashionConfig.GetConfig(view.fashionId)

			if fashionCfg then
				view.icon = fashionCfg.Icon
				view.quality = fashionCfg.Quality
				view.Part = fashionCfg.Part
				view.isLock = gDressManager:IsFashionHaved(view.fashionId)
				view.Types = fashionCfg.Types
			end

			if self.selectPlayerSex == fashionCfg.Gender or fashionCfg.Gender == 0 and cfg.IsShow then
				table.insert(self.suitFashionRightList, view)
			else
				print_error("@hzliuyibing 当前配置套装内的时装与角色性别不一致，请联系策划检查配置，suitId = " .. self.suitId .. "  fashionId = " .. view.fashionId)
			end
		end
	end

	self.bindData.suitFashionList:SetSimpleList(#self.suitFashionRightList)
end

function M:OnRefreshItemList(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplareStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "FashionItemRedDot.pageList:" .. data.id)

		store.icon = data.icon
		store.quality = data.quality
		store.isAvailable = data.isAvailable
		store.dyeType = gDressDyeManager:GetDyeState(data.fashionId)
		store.isCollect = data.isCollect
		btn.isSelected = gDressManager:IsTempWearFashionList({
			data.fashionId
		})

		if btn.isSelected then
			if store.dyeType ~= gDressDyeManager.DYE_STATE.CANOT_DYE and self.fashionType <= 0 then
				self.bindData.showdye = self.SELECT_TYPE.TRUE
			end

			if self.bindData.isShowInfo == self.SELECT_TYPE.FALSE then
				self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

				self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")
			end

			self.bindData.isShowEdit = (data.EditId and data.EditId > 0 or store.dyeType ~= gDressDyeManager.DYE_STATE.CANOT_DYE) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			local fashionCfg = FashionConfig.GetConfig(data.fashionId)

			if fashionCfg then
				self.bindData.isSelect = self.SELECT_TYPE.TRUE
				self.bindData.currentDressName = fashionCfg.Name

				self:SetFashionTagInfo(data.fashionId)
				self:SetDressScroll(fashionCfg.Description)

				local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

				if brandCfg then
					self.bindData.currentDressIcon = brandCfg.BrandLogo
					self.bindData.brandBanner = brandCfg.BrandBG
				end

				self.selectFashionId = data.fashionId
				self.bindData.isCollected = gDressManager:IsFashinCollected(data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

				if self.needRecordFashion then
					self:SetRecordFashion()

					self.needRecordFashion = false
				end
			end
		end

		if not table.isNilOrEmpty(self.taskFashionIdList) then
			store.isShowTask = table.contains(self.taskFashionIdList, data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

			if store.isShowTask then
				store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			end
		else
			store.isShowTask = self.SELECT_TYPE.FALSE
		end

		local conflictItems, addItems = gDressManager:CheckFashionConflict({
			data.fashionId
		})

		table.insert(addItems, data.fashionId)

		if not table.isNilOrEmpty(conflictItems) then
			local isSamePart = true

			for i = 1, #conflictItems do
				local cfg = FashionConfig.GetConfig(conflictItems[i])

				if cfg and cfg.Part ~= data.Part and not cfg.IsDefaultUnderwear and cfg.IsShow then
					isSamePart = false
				end
			end

			store.isAvailable = isSamePart and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		end

		if self.selectFashionId > 0 and gDressManager:IsSamePart(self.selectFashionId, data.fashionId) then
			store.isAvailable = self.SELECT_TYPE.TRUE
		end
	end
end

function M:OnChangeItem(btn, index)
	local data = self.itemList[index + 1]

	if btn.isSelected then
		if data.isNew then
			local redDotFashionList = {}

			table.insert(redDotFashionList, data.fashionId)
			gDressData:AskReadFashions(redDotFashionList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageList:" .. data.id)
				self:RefreshRedDotInfo(redDotFashionList)
			end)
		end

		self.bindData.isShowEdit = data.EditId and data.EditId > 0 and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		if self.bindData.isShowInfo == self.SELECT_TYPE.FALSE then
			self.bindData.isShowInfo = self.SELECT_TYPE.TRUE
		end

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.selectFashionId = data.fashionId
		self.bindData.isCollected = gDressManager:IsFashinCollected(data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

			if brandCfg then
				self.bindData.currentDressIcon = brandCfg.BrandLogo
				self.bindData.brandBanner = brandCfg.BrandBG
			end

			self.bindData.currentDressName = fashionCfg.Name

			self:SetFashionTagInfo(data.fashionId)
			self:SetDressScroll(fashionCfg.Description)
		end

		if data.Part == gDressManager.DRESS_PART.PROP then
			self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		end

		if data.isAvailable == self.SELECT_TYPE.TRUE then
			if gDressManager:IsFashionHaved(data.fashionId) then
				local conflictItems, addItems = gDressManager:CheckFashionConflict({
					data.fashionId
				})

				table.insert(addItems, data.fashionId)

				if not table.isNilOrEmpty(conflictItems) then
					local isSamePart = true
					local conflictName = ""

					for i = 1, #conflictItems do
						local cfg = FashionConfig.GetConfig(conflictItems[i])

						if cfg and cfg.Part ~= data.Part and not cfg.IsDefaultUnderwear and cfg.IsShow then
							isSamePart = false

							if conflictName == "" then
								conflictName = conflictName .. cfg.Name
							else
								conflictName = conflictName .. "," .. cfg.Name
							end
						end
					end

					if not isSamePart then
						local msgConfig = MessageConfig.GetConfig(MessageConfig.FashionConflict)

						if msgConfig then
							self.bindData.isShowMessage = self.SELECT_TYPE.TRUE
							self.bindData.msgDes = string.format(msgConfig.Content, conflictName, data.Name)
							self.timerMsg = Timer.New(function ()
								self.bindData.isShowMessage = self.SELECT_TYPE.FALSE
								self.timerMsg = nil
							end, 2):Start()
						end
					end
				end

				gDressManager:CheckHasPropEdit(data.fashionId)
				gDressManager:CheckMyOotdHiddenPart(data.fashionId)
				gDressManager:SetFashionList(addItems)

				if not gDressManager:CheckFashionConflictIsTakeEffect() then
					return
				end

				gDressManager:ChangeFashionPart(addItems, conflictItems)

				local stepData = {
					fashionList = addItems,
					removeFashionList = conflictItems,
					stepType = gDressManager.STEP_TYPE.ADD_FASHION,
					selectFashionId = self.selectFashionId
				}

				self:AddStep(stepData)
			end
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FashionGenderMismacth)
		end

		if not gDressManager:CheckFashionConflictIsTakeEffect() then
			return
		end

		self.bindData.itemList:RefreshList()
	else
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.showdye = self.SELECT_TYPE.FALSE
		self.bindData.isCollected = self.SELECT_TYPE.FALSE
		self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self:SetDressScroll()

		self.bindData.redoBtnState = 1

		if data.isAvailable == self.SELECT_TYPE.TRUE and gDressManager:IsFashionHaved(data.fashionId) then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict({
				data.fashionId
			})

			if not table.contains(conflictItems, data.fashionId) then
				table.insert(conflictItems, data.fashionId)
			end

			gDressManager:ChangeFashionPart(addItems, conflictItems)
			gDressManager:RemoveFashionPart({
				data.fashionId
			})

			local stepData = {
				selectFashionId = 0,
				fashionList = addItems,
				removeFashionList = conflictItems,
				stepType = gDressManager.STEP_TYPE.REMOVE_FASHION
			}

			self:AddStep(stepData)
		end
	end

	if data.isAvailable == self.SELECT_TYPE.TRUE then
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local minType = fashionCfg.Types[1]

			for i = 1, #fashionCfg.Types do
				if fashionCfg.Types[i] < minType then
					minType = fashionCfg.Types[i]
				end
			end

			gDressManager:PlayDressAction(minType)
		end
	end

	self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
end

function M:OnItemFinish()
	if self.gotoIndexFashionId > 0 and not table.isNilOrEmpty(self.recordItems) then
		for i = 1, #self.recordItems do
			if self.recordItems[i].fashionId == self.gotoIndexFashionId then
				self.bindData.itemList:GoToIndex(i - 1, false)

				self.gotoIndexFashionId = 0

				break
			end
		end
	end
end

function M:OnRefreshSuitList(btn, index)
	local data = self.suitList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplareSuitStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "FashionItemRedDot.pageSuitList:" .. data.id)

		store.icon = data.icon
		store.iconBg = data.iconBg
		store.quality = data.quality
		store.isAvailable = data.isAvailable
		store.isCollect = data.isCollect
		btn.isSelected = gDressManager:IsTempWearFashionList(data.fashionList)

		if self.taskSuitId and self.taskSuitId > 0 then
			store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			store.isShowTask = data.suitId == self.taskSuitId and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		else
			store.isShowTask = self.SELECT_TYPE.FALSE
		end

		if btn.isSelected then
			self.suitId = data.suitId
			self.bindData.isCollected = data.isCollect

			self:SelectSuitInfo(data)

			if data.isNew then
				local redDotSuitList = {}

				table.insert(redDotSuitList, data.suitId)
				gDressData:AskReadFashionSuits(redDotSuitList, function ()
					RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageSuitList:" .. data.id)
					self:RefreshRedDotInfo(nil, redDotSuitList)
				end)
			end
		end
	end
end

function M:OnChangeSuit(btn, index)
	local data = self.suitList[index + 1]

	if btn.isSelected then
		if data.isNew then
			local redDotSuitList = {}

			table.insert(redDotSuitList, data.suitId)
			gDressData:AskReadFashionSuits(redDotSuitList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageSuitList:" .. data.id)
				self:RefreshRedDotInfo(nil, redDotSuitList)
			end)
		end

		self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.suitId = data.suitId
		self.bindData.isCollected = gDressManager:IsFashinSuitCollected(self.suitId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		self:SelectSuitInfo(data)

		if data.isAvailable == self.SELECT_TYPE.TRUE then
			gDressManager:DressSuitFashionList(data.fashionList, true, false, true)

			local stepData = {
				fashionList = data.fashionList,
				stepType = gDressManager.STEP_TYPE.ADD_SUIT,
				selectSuitId = self.suitId
			}

			self:AddStep(stepData)
		end
	else
		self.suitId = 0
		self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
		self.bindData.isCollected = self.SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self:SetDressScroll()

		local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict(data.fashionList)

		for i = 1, #data.fashionList do
			if not table.contains(conflictItems, data.fashionList[i]) then
				table.insert(conflictItems, data.fashionList[i])
			end
		end

		gDressManager:ChangeFashionPart(addItems, conflictItems)
		gDressManager:RemoveFashionPart(data.fashionList)

		local stepData = {
			fashionList = data.fashionList,
			stepType = gDressManager.STEP_TYPE.REMOVE_FASHION,
			selectSuitId = self.suitId
		}

		self:AddStep(stepData)
	end
end

function M:SelectSuitInfo(data)
	self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

	self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

	local fashionCfg = FashionConfig.GetConfig(data.fashionList and data.fashionList[1] or 0)

	if fashionCfg then
		local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

		if brandCfg then
			self.bindData.currentDressIcon = brandCfg.BrandLogo
			self.bindData.brandBanner = brandCfg.BrandBG
		end

		local suitCfg = FashionSuitConfig.GetConfig(data.suitId)

		if suitCfg then
			self.bindData.currentDressName = suitCfg.Name
		end
	end

	self:InitSuitFashionRightList()
	self:SetFashionTagInfo()
end

function M:SetFashionTagInfo(fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

function M:OnRefreshSuitFashionList(btn, index)
	local data = self.suitFashionRightList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplarePreviewStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.quality = data.quality
		store.isLock = data.isLock and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE
	end
end

function M:OnChangeSuitFashion(btn, index)
	local data = self.suitFashionRightList[index + 1]

	if self.itemListByPart[data.Part] then
		for i = 1, #self.itemListByPart[data.Part] do
			if self.itemListByPart[data.Part][i].fashionId == data.fashionId then
				for t = 1, #self.tabList do
					if self.tabList[t].Part == data.Part then
						self.gotoIndexFashionId = data.fashionId

						self.bindData.tabList:SelectItem(self.tabList[t].tabIndex - 1, true)

						if data.Part == gDressManager.DRESS_PART.PROP then
							for m = 1, #self.tabTopList do
								if table.contains(data.Types, self.tabTopList[m].Type) then
									self.bindData.tabTopList:SelectItem(m - 1, true)
								end
							end
						end

						SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.naviArea

						return
					end
				end
			end
		end
	end
end

function M:OnRefreshTagList(btn, index)
	local data = self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
end

function M:FilterItems(itemList)
	local items = {}

	if table.isNilOrEmpty(itemList) then
		return items
	end

	local tag = gDressManager.SelectType.tag
	local collect = gDressManager.SelectType.collect
	local approach = gDressManager.SelectType.approach
	local brand = gDressManager.SelectType.brand

	if table.isNilOrEmpty(collect) and table.isNilOrEmpty(approach) and table.isNilOrEmpty(brand) and table.isNilOrEmpty(tag) then
		if not table.isNilOrEmpty(itemList) then
			self:SortItemList(itemList)
		end

		return itemList
	end

	local tempCollectType = self.COLLECT_TYPE.ALL

	if table.count(collect) == 1 then
		if table.contains(collect, self.COLLECT_TYPE.HAS_COLLECT) then
			tempCollectType = self.COLLECT_TYPE.HAS_COLLECT
		else
			tempCollectType = self.COLLECT_TYPE.NO_COLLECT
		end
	end

	local hasApproach = not table.isNilOrEmpty(approach) or false
	local hasBrand = not table.isNilOrEmpty(brand) or false
	local hasTag = not table.isNilOrEmpty(tag) or false

	for i = 1, #itemList do
		local canAdd = true
		local fashionId = itemList[i].fashionId

		if fashionId == nil then
			fashionId = itemList[i].fashionList[1]
		end

		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg == nil then
			print_warn("当前时装在配表中未找到,时装id来源于服务器PlayerFashionsInfo.FashionInfoDict   fashionId = " .. fashionId)
		end

		if hasTag then
			local canAddTag = false

			for i = 1, #tag do
				if table.contains(cfg.Tags, tag[i]) then
					canAddTag = true

					break
				end
			end

			if not canAddTag then
				canAdd = false
			end
		end

		if tempCollectType == self.COLLECT_TYPE.HAS_COLLECT then
			if itemList[i].isCollect ~= self.SELECT_TYPE.TRUE then
				canAdd = false
			end
		elseif tempCollectType == self.COLLECT_TYPE.NO_COLLECT and itemList[i].isCollect ~= self.SELECT_TYPE.FALSE then
			canAdd = false
		end

		if hasApproach and not table.contains(approach, cfg.Source) then
			canAdd = false
		end

		if hasBrand and not table.contains(brand, cfg.BelongBrand) then
			canAdd = false
		end

		if canAdd then
			table.insert(items, itemList[i])
		end
	end

	if not table.isNilOrEmpty(itemList) then
		self:SortItemList(items)
	end

	return items
end

function M:SortItemList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		return b.id < a.id
	end)
	table.sort(itemList, function (a, b)
		if a.isShowTask == b.isShowTask then
			if a.isAvailable == b.isAvailable then
				if self.selectedSortItemId == self.SELECTOR_SORT_TYPE.QUALITY then
					if self.sortLargeToSmall then
						return b.quality < a.quality
					else
						return a.quality < b.quality
					end
				elseif self.selectedSortItemId == self.SELECTOR_SORT_TYPE.GET_TIME then
					if self.sortLargeToSmall then
						return b.GainTime < a.GainTime
					else
						return a.GainTime < b.GainTime
					end
				end
			end

			return a.isAvailable == self.SELECT_TYPE.TRUE and b.isAvailable == self.SELECT_TYPE.FALSE
		end

		return a.isShowTask and not b.isShowTask
	end)
end

function M:ResetPlayerFashionData(eventId, data)
	if not data then
		return
	end

	gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList = {}

	for i = 1, data.Count do
		if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i]) then
			gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i] = {}
		end

		gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i].FashionId = data[i - 1]
	end
end
