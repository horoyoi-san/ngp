local FashionConfig = LTConfig.FashionConfig
local FashionColorConfig = LTConfig.FashionColorConfig
local FashionColor = UX.Game.EventConditionImplModule.FashionColor
C_DressDyePanelStore = DefClass("C_DressDyePanelStore", C_DressDyePanelStore, C_StoreGroup)
GroupName2Class.DressDyePanelStore = C_DressDyePanelStore
local M = C_DressDyePanelStore
local MessageConfig = LTConfig.MessageConfig
local PLAN_STATE = {
	TEXT = 1,
	COLOR = 2,
	DEFAULT = 0
}
local PAGE_STATE = {
	PLAN = 0,
	DYE = 1
}
local DEFAULT_PLAN_COUNT = 1
local DEFAULT_COLOR = Color.New(1, 1, 1)

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.backToPlanBtn.luaClick = self:CreateAction("OnBackBtnToPlanClick")
	self.bindData.editBtn.luaClick = self:CreateAction("OnEditBtnClick")
	self.bindData.resetBtn.luaClick = self:CreateAction("OnResetBtnClick")
	self.bindData.hideBtn.luaClick = self:CreateAction("OnHideBtnClick")
	self.bindData.saveBtn.luaClick = self:CreateAction("OnSaveBtnClick")
	self.bindData.colorPlanList.luaSimpleRenderItem = self:CreateAction("OnRefreshPlanList")
	self.bindData.colorPlanList.luaSimpleClick = self:CreateAction("OnChangePlan")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabList")
	self.bindData.tabList.luaSimpleClick = self:CreateAction("OnChangeTab")
	self.bindData.colorGroupList.luaSimpleRenderItem = self:CreateAction("OnRefreshColorGroupList")
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	if self.callBack then
		self.callBack()
	end
end

function M:OnShow(panelId, data)
	gDressDyeManager:InitColorList()

	self.fashionId = data and data.fashionId
	self.callBack = data and data.callBack
	self.lastSelectColorInfo = {}
	self.bindData.hidePage = 1

	self:InitData()
	self:SwitchPage(PAGE_STATE.PLAN)

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		cameraParams.rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond
		cameraParams.L2CustomNavRespond = self.bindData.L2CustomNavRespond
		cameraParams.R2CustomNavRespond = self.bindData.R2CustomNavRespond
	end

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)
end

function M:OnClose()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:InitData()
	self.selectPlanId = DEFAULT_PLAN_COUNT
end

function M:SwitchPage(page)
	self.bindData.page = page

	if page == PAGE_STATE.PLAN then
		self.colorPlanList = {}

		self:InitPlanInfo()
	else
		self.lastSelectColorInfo = {}
		self.bindData.saveBtn.interactable = false

		self:InitTabListInfo()
		self:InitColorList()
	end
end

function M:InitPlanInfo()
	local defaultView = {
		planId = DEFAULT_PLAN_COUNT,
		state = PLAN_STATE.TEXT,
		normalTitle = FashionConfig.ColoringSchemeName
	}

	table.insert(self.colorPlanList, defaultView)

	self.colorPlans, self.selectPlanId = gDressDyeManager:GetColorPlanList(self.fashionId)
	self.selectPlanId = self.selectPlanId + DEFAULT_PLAN_COUNT

	for i = 1, FashionConfig.ColoringSchemeCount do
		local view = {
			planId = i + DEFAULT_PLAN_COUNT,
			state = table.isNilOrEmpty(self.colorPlans[i]) and PLAN_STATE.DEFAULT or PLAN_STATE.COLOR,
			normalTitle = "",
			colorList = {}
		}

		if self.colorPlans[i] and self.colorPlans[i].ColoringType2ColorIdDict then
			view.colorList = self.colorPlans[i].ColoringType2ColorIdDict or {}
		end

		table.insert(self.colorPlanList, view)
	end

	self.bindData.colorPlanList:SetSimpleList(#self.colorPlanList)
end

function M:OnChangePlan(btn, index)
	local data = self.colorPlanList[index + 1]

	if btn.isSelected then
		self.selectPlanId = data.planId

		if data.state == PLAN_STATE.DEFAULT then
			self:SwitchPage(PAGE_STATE.DYE)
		end

		self.bindData.isShowEdit = data.state == PLAN_STATE.TEXT and 1 or 0
		self.colorSchemeInfoList = data.colorList or {}

		if table.isNilOrEmpty(data.colorList) and data.planId == DEFAULT_PLAN_COUNT then
			gDressDyeManager:ResetListColor(self.fashionId)

			return
		end

		local function cb()
			gDressDyeManager:SetColorList(self.fashionId, data.colorList)
		end

		local colorSchemeInfoList = {}
		colorSchemeInfoList = {
			ColoringType2ColorIdDict = self.colorSchemeInfoList
		}
		local colorType = self.selectPlanId - DEFAULT_PLAN_COUNT

		if table.isNilOrEmpty(self.colorSchemeInfoList) then
			self.colorPlans[colorType] = nil
		else
			self.colorPlans[colorType] = colorSchemeInfoList
		end

		local tempColorSchemeInfoList = {
			[colorType] = colorSchemeInfoList
		}

		gDressData:AskApplyFashionColoringSchemeInfos(self.fashionId, data.planId - DEFAULT_PLAN_COUNT, tempColorSchemeInfoList, cb)
	end
end

function M:OnRefreshPlanList(btn, index)
	local data = self.colorPlanList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.state = data.state
		store.normalTitle = data.normalTitle
		store.colorList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshPlanColorList", data.planId)
		btn.isSelected = self.selectPlanId == data.planId

		if btn.isSelected then
			self.bindData.isShowEdit = data.state == PLAN_STATE.TEXT and 1 or 0
			self.colorSchemeInfoList = data.colorList or {}
		end

		self.colorInsidePlanList = self.colorInsidePlanList or {}
		self.colorInsidePlanList[data.planId] = {}

		if not table.isNilOrEmpty(data.colorList) then
			for part, colorId in pairs(data.colorList) do
				local view = {
					color = gDressDyeManager.colorCfgId2Color[colorId]
				}

				table.insert(self.colorInsidePlanList[data.planId], view)
			end

			store.colorList:SetSimpleList(#self.colorInsidePlanList[data.planId])
		end
	end
end

function M:OnRefreshPlanColorList(planId, btn, index)
	local data = self.colorInsidePlanList[planId][index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.color = data.color
	end
end

function M:InitTabListInfo()
	self.tabList = {}
	local colorTab = gDressDyeManager:GetColorTabList(self.fashionId)
	self.selectColorPart = not table.isNilOrEmpty(colorTab) and colorTab[1] or 1
	self.colorSchemeInfoList = self.colorPlans[self.selectPlanId - DEFAULT_PLAN_COUNT] and self.colorPlans[self.selectPlanId - DEFAULT_PLAN_COUNT].ColoringType2ColorIdDict or {}
	self.recordColorSchemeInfoList = table.shallow_clone(self.colorSchemeInfoList)

	for i = 1, #colorTab do
		local view = {
			tabIndex = i,
			colorPart = colorTab[i],
			color = not table.isNilOrEmpty(self.colorSchemeInfoList) and gDressDyeManager.colorCfgId2Color[self.colorSchemeInfoList[2^(colorTab[i] - 1)]] or DEFAULT_COLOR
		}
		view.isShowColor = view.color == DEFAULT_COLOR and 1 or 0
		view.icon = FashionConfig.ColoringPartIcon[i]

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)
end

function M:OnChangeTab(btn, index)
	local data = self.tabList[index + 1]

	if btn.isSelected then
		gDressDyeManager:SetFashionPartSlotHighLight(self.fashionId, data.colorPart)

		self.selectColorPart = data.colorPart

		self.bindData.colorGroupList:RefreshList()

		self.bindData.saveBtn.interactable = not self:IsEnterColorScheme()
	end
end

function M:OnRefreshTabList(btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("DyeTABTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.colorPart = data.colorPart
		store.isShowColor = data.isShowColor
		store.color = data.color
		store.icon = data.icon
		btn.isSelected = self.selectColorPart == data.colorPart
	end
end

function M:SetTabColor(color)
	for i = 1, #self.tabList do
		if self.selectColorPart == self.tabList[i].colorPart then
			self.tabList[i].color = color
			self.tabList[i].isShowColor = color == DEFAULT_COLOR and 1 or 0

			self.bindData.tabList:SetElement(i - 1, self.tabList[i])

			break
		end
	end
end

function M:InitColorList()
	self.colorGroupList = {}

	self.bindData.colorGroupList:SetSimpleList(#gDressDyeManager.colorGroupList)
end

function M:OnRefreshColorGroupList(btn, index)
	local data = gDressDyeManager.colorGroupList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.colorList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshColorList", index + 1)
		store.colorList.luaSimpleClick = self:CreateActionWithArgs("OnChangeColor", index + 1)
		self.colorListByGroup = self.colorListByGroup or {}
		self.colorListByGroup[index + 1] = {}

		for i = 1, #data do
			local cfg = FashionColorConfig.GetConfig(data[i].Id)
			local view = {
				title = cfg.name,
				groupId = data[i].groupId,
				id = i,
				color = data[i].color,
				colorCfgId = data[i].Id,
				isLock = not gEventConditionUtils.CheckHasUnlocked(cfg, FashionColor)
			}

			table.insert(self.colorListByGroup[index + 1], view)
		end

		store.colorList:SetSimpleList(#self.colorListByGroup[index + 1])
	end
end

function M:OnChangeColor(group, btn, index)
	local data = self.colorListByGroup[group][index + 1]

	if data.isLock then
		return
	end

	if btn.isSelected then
		if table.isNilOrEmpty(self.lastSelectColorInfo[self.selectColorPart]) then
			self.lastSelectColorInfo[self.selectColorPart] = {}
		else
			self.lastSelectColorInfo[self.selectColorPart].btn.isSelected = false
		end

		self.lastSelectColorInfo[self.selectColorPart].colorCfgId = data.colorCfgId
		self.lastSelectColorInfo[self.selectColorPart].color = data.color
		self.lastSelectColorInfo[self.selectColorPart].btn = btn

		self:SetTabColor(data.color)

		self.colorSchemeInfoList[2^(self.selectColorPart - 1)] = data.colorCfgId

		gDressDyeManager:SetColor(self.fashionId, self.selectColorPart, data.colorCfgId)
	else
		self.colorSchemeInfoList[2^(self.selectColorPart - 1)] = nil

		self:SetTabColor(DEFAULT_COLOR)
		gDressDyeManager:ResetColor(self.fashionId, {
			self.selectColorPart
		})

		self.lastSelectColorInfo[self.selectColorPart] = nil
	end

	self.bindData.saveBtn.interactable = not self:IsEnterColorScheme()
end

function M:OnRefreshColorList(group, btn, index)
	local data = self.colorListByGroup[group][index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.color = data.color
		store.isLock = data.isLock and 1 or 0
		btn.interactable = not data.isLock
		btn.isSelected = self:IsColorSelect(data)

		if btn.isSelected then
			print_notice("当前已被选中的颜色的groupid = " .. data.groupId .. " , id = " .. data.id)

			if table.isNilOrEmpty(self.lastSelectColorInfo[self.selectColorPart]) then
				self.lastSelectColorInfo[self.selectColorPart] = {
					colorCfgId = data.colorCfgId,
					color = data.color,
					btn = btn
				}
			end
		end
	end
end

function M:IsColorSelect(data)
	local isLastSelect = not table.isNilOrEmpty(self.lastSelectColorInfo[data.groupId]) and self.lastSelectColorInfo[data.groupId].id == data.id and self.lastSelectColorInfo[data.groupId].colorPart == self.selectColorPart and data.colorId == self.selectColorId or false
	local isServerSelect = not table.isNilOrEmpty(self.colorSchemeInfoList) and self.colorSchemeInfoList[2^(self.selectColorPart - 1)] == data.colorCfgId or false

	return isServerSelect or isLastSelect
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.SDYE_PANEL)
end

function M:OnBackBtnToPlanClick()
	if self:IsEnterColorScheme() or self.bindData.page == PAGE_STATE.PLAN then
		self:SwitchPage(PAGE_STATE.PLAN)
	else
		local function callBack()
			local colorList = self.recordColorSchemeInfoList

			if table.isNilOrEmpty(colorList) then
				gDressDyeManager:ResetListColor(self.fashionId)
			else
				gDressDyeManager:SetColorList(self.fashionId, colorList)
			end

			self:SwitchPage(PAGE_STATE.PLAN)
		end

		if self:IsEnterColorScheme() then
			callBack()
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FashionColorEditExitReconfirm, callBack)
		end
	end
end

function M:IsEnterColorScheme()
	if self.recordColorSchemeInfoList == self.colorSchemeInfoList then
		return true
	end

	local isInit = true

	if table.count(self.recordColorSchemeInfoList) == table.count(self.colorSchemeInfoList) then
		for i, v in pairs(self.recordColorSchemeInfoList) do
			if v ~= self.colorSchemeInfoList[2^(i - 1)] then
				isInit = false
			end
		end
	else
		isInit = false
	end

	return isInit
end

function M:OnEditBtnClick()
	self:SwitchPage(PAGE_STATE.DYE)
end

function M:OnResetBtnClick()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionColorResetReconfirm, function ()
		local data = self.colorPlanList[self.selectPlanId]

		if data.state == PLAN_STATE.COLOR then
			local resetColoringTypeList = {}

			table.insert(resetColoringTypeList, self.selectPlanId)

			local function cb()
				gDressDyeManager:ResetListColor(self.fashionId)

				self.lastSelectColorInfo = {}
				self.colorSchemeInfoList = {}
				self.colorPlanList[self.selectPlanId] = {}

				for i = 1, #self.tabList do
					self.tabList[i].color = DEFAULT_COLOR
					self.tabList[i].isShowColor = 1
				end

				self.bindData.colorGroupList:RefreshList()
				self.bindData.tabList:RefreshList()
			end

			gDressData:AskResetFashionColoringSchemeInfos(self.fashionId, self.selectPlanId - 1, cb)
		else
			self:SwitchPage(PAGE_STATE.DYE)
		end
	end)
end

function M:OnHideBtnClick()
	if self.bindData.hidePage == 1 then
		self.bindData.hidePage = 0

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
			self.bindData.navArea.enabled = false
		end
	else
		self.bindData.hidePage = 1

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.navArea.enabled = true
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
		end
	end
end

function M:OnSaveBtnClick()
	local colorSchemeInfoList = {}
	colorSchemeInfoList = {
		ColoringType2ColorIdDict = self.colorSchemeInfoList
	}
	local colorType = self.selectPlanId - DEFAULT_PLAN_COUNT

	if table.isNilOrEmpty(self.colorSchemeInfoList) then
		self.colorPlans[colorType] = nil
	else
		self.colorPlans[colorType] = colorSchemeInfoList
	end

	gDressData:AskSetFashionColoringSchemeInfos(self.fashionId, colorType, self.colorPlans, function ()
		self:SwitchPage(PAGE_STATE.PLAN)
	end)
end
