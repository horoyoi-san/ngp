local UNavigationMgr = SGUI.UNavigationMgr
local MessageConfig = LTConfig.MessageConfig
local WeaponConfig = LTConfig.WeaponConfig
local CategoryType = LTConfig.WeaponConfig.CategoryType
local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local FightSkillConfig = LTConfig.FightSkillConfig
C_WeaponArmoryMainPanelStore = DefClass("C_WeaponArmoryMainPanelStore", C_WeaponArmoryMainPanelStore, C_StoreGroup)
GroupName2Class.WeaponArmoryMainPanelStore = C_WeaponArmoryMainPanelStore
local M = C_WeaponArmoryMainPanelStore

function M:DefineAllVariables()
	self.mgr = gWeaponManager
	self.durabilityLowPoint = WeaponConfig.WeaponDurabilityLow * 100
	self.CONTROL = {
		FALSE = 0,
		TRUE = 1
	}
	self.SHOW_MODE = {
		CONTENT = 1,
		CHARACTER = 2,
		NONE = 0
	}
	self.TIP_SHOW_MODE = {
		ITEM = 1,
		MA = 2,
		WEAPON = 0
	}
	self.MA_CIRCLE_STATE = {
		EMPTY = 1,
		DISPLAY = 0,
		FIXED = 2
	}
	self.SELECT_MODE = {
		CIRCLE_MA = 2,
		CIRCLE_WEAPON = 1,
		ARMORY_MA = 4,
		ARMORY_WEAPON = 3,
		NONE = 0
	}
	self.CONTENT_TYPE = {
		MA = 1,
		NONE = 2,
		WEAPON = 0
	}
	self.MA_RESULT = {
		FAIL = -1,
		SUCCESS_EMPTY = 1,
		SUCCESS_SWITCH = 0
	}
	self.TIP_NAME_DISPLAY = {
		AUTO_EQUIP = 2,
		EQUIP = 0,
		EXCHANGE = 1,
		BACK = 3
	}
	self.tabList = {}
	self.tabFightStyleAll = {}
	self.currFightStyleDict = {}
	self.selectedTabIndex = 0
	self.currPageIndex = self.mgr.WEAPON_TYPE.PAGE1
	self.characterList = {}
	self.selectedCharacterIndex = 0
	self.selectedCharacterCfg = nil
	self.currShowMode = self.SHOW_MODE.CONTENT
	self.characterWeaponList = {}
	self.MAX_SLOT_COUNT = 8

	for i = 1, 16 do
		table.insert(self.characterWeaponList, {
			Empty = true
		})
	end

	self.characterWeaponList[1].IsPrivate = true
	self.characterWeaponList[2].IsPrivate = true
	self.circleWeaponBtnStore = {}
	self.characterMAList = {}

	for i = 1, 16 do
		table.insert(self.characterMAList, {
			r_State = self.MA_CIRCLE_STATE.EMPTY
		})
	end

	self.circleMABtnStore = {}
	self.weaponList = {}
	self.weaponListForRender = {}
	self.weaponListForFilterTemp = {}
	self.maList = {}
	self.maListForRender = {}
	self.sortIncrease = false
	self.SORT_KEY = {
		"Quality",
		"Type",
		"AttackPower",
		"MaxDurability",
		"TemplateId",
		"DurablePercentValue",
		"ReceivedTimeStamp"
	}
	self.sortIndex = {
		1,
		2,
		3,
		4,
		5,
		6,
		7
	}
	self.SORT_REVERSE = {
		false,
		true,
		false,
		false,
		true,
		false,
		false
	}

	function self.sortFunc(a, b)
		if a.Warn ~= b.Warn then
			return a.Warn < b.Warn
		end

		if a.TaskTop ~= b.TaskTop then
			return b.TaskTop < a.TaskTop
		end

		if a.Equipped ~= b.Equipped then
			return a.Equipped < b.Equipped
		end

		if a.RedDot ~= b.RedDot then
			return b.RedDot < a.RedDot
		end

		for i = 1, #self.sortIndex do
			local key = self.SORT_KEY[self.sortIndex[i]]

			if a[key] ~= b[key] then
				if self:boolXor(self.sortIncrease, self.SORT_REVERSE[self.sortIndex[i]]) then
					return a[key] < b[key]
				else
					return b[key] < a[key]
				end
			end
		end

		if self.sortIncrease then
			return ulong.Less(a.InstanceId, b.InstanceId)
		else
			return ulong.Greater(a.InstanceId, b.InstanceId)
		end
	end

	function self.maSortFunc(a, b)
		if a.Warn ~= b.Warn then
			return a.Warn < b.Warn
		end

		if a.Quality ~= b.Quality then
			return b.Quality < a.Quality
		end

		if a.FightSkillType ~= b.FightSkillType then
			return a.FightSkillType < b.FightSkillType
		end

		return a.Id < b.Id
	end

	self.currContentType = self.CONTENT_TYPE.WEAPON
	self.currSelectModeCircle = self.CONTENT_TYPE.NONE
	self.currSelectIndexCircle = 0
	self.maBoxCircleItem = nil
	self.currSelectModeTooltip = self.SELECT_MODE.NONE
	self.currSelectIndexTooltip = 0
	self.toolTipSource = self.SELECT_MODE.NONE
	self.toolTipRenderData = {}
	self.toolTipData = nil
	self.currSelectIndexCirclePad = 0
	self.currMouseHoverMode = self.SELECT_MODE.NONE
	self.currMouseHoverIndex = 0
	self.moneyConfig = LTConfig.ConsumableConfig.GetConfig(LTConfig.WeaponConfig.WeaponRepairMoney)
	self.PAD_MODE = {
		RIGHT = 2,
		LEFT = 1,
		NONE = 0
	}
	self.updateSelect = false
	self.moveVector = Vector2.New(0, 1)
	self.weaponInitVector = Vector2.New(-math.sin(math.pi / 4), -math.cos(math.pi / 4))
	self.weaponEachAngle = 45
	self.weaponSelectIndex = 0
	self.padLeftControlMode = 0
	self.SMOOTH_TIME = 0.1
	self.smoothStartTime = 0
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
	self.OP_Add_To_Circle = {}
	self.OP_Add_To_Armory = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
	table.clear(self.circleWeaponBtnStore)
	table.clear(self.circleMABtnStore)

	self.circleStore = self:GetStoreByWidget(self.bindData.circleRoot)
	self.circleStore.page1Btn.luaClick = self:CreateAction("OnCirclePage1Click")
	self.circleStore.page2Btn.luaClick = self:CreateAction("OnCirclePage2Click")
	self.circleStore.deleteBtn.luaClick = self:CreateAction("OnDeleteBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.circleStore.pcMouseDeleteBtn.luaClick = self:CreateAction("OnMouseDeleteClick")
		self.circleStore.mouseScrollCustomRespond.luaGamePadInputChanged = self:CreateAction("OnMouseScroll")
		self.circleStore.padReturnAllBtn.luaLongPress = self:CreateAction("OnReturnCircleAllBtnClick")
		self.circleStore.padReturnSingleBtn.luaLongPress = self:CreateAction("OnReturnBtnClick")
		self.circleStore.padSwitchPageBtn.luaClick = self:CreateAction("OnSwitchPageBtnClick")
		self.circleStore.padRightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
		self.circleStore.padSwitchContentBtn.luaClick = self:CreateAction("OnSwitchContentBtnClick")
	end

	self.circleDragEndCb = self:CreateAction("OnCircleWeaponDragEnd")

	for i = 1, self.MAX_SLOT_COUNT do
		local btn = "weaponItem" .. i
		self.circleStore[btn].luaClick = self:CreateActionWithArgs("OnCircleWeaponBtnClick", i)
		self.circleStore[btn].luaEnterDropWidget = self:CreateActionWithArgs("OnCircleWeaponEnterDropWidget", i)
		self.circleStore[btn].luaBeginDrag = self:CreateActionWithArgs("OnCircleWeaponDragBegin", i)
		self.circleStore[btn].luaEndDrag = self.circleDragEndCb
		self.circleStore[btn].luaHover = self:CreateActionWithArgs("OnCircleWeaponBtnHover", i)
		self.circleStore[btn].luaUnhover = self:CreateActionWithArgs("OnCircleWeaponBtnUnHover", i)
		self.circleWeaponBtnStore[i] = self:GetStoreByWidget(self.circleStore[btn])
		self.circleWeaponBtnStore[i].CRCIndex = i
		self.circleWeaponBtnStore[i].CRCType = self.CONTENT_TYPE.WEAPON
		btn = "maItem" .. i
		self.circleStore[btn].luaClick = self:CreateActionWithArgs("OnCircleMABtnClick", i)
		self.circleMABtnStore[i] = self:GetStoreByWidget(self.circleStore[btn])
		self.circleMABtnStore[i].CRCIndex = i
		self.circleMABtnStore[i].CRCType = self.CONTENT_TYPE.MA
	end

	self.toolTipStore = self:GetStoreByWidget(self.bindData.toolTipRoot)
	self.toolTipStore.tipTagList.luaSimpleRenderItem = self:CreateAction("OnTipTagListRenderItem")
	self.toolTipStore.tipModeButton.luaClick = self:CreateAction("OnTipModeBtnClick")
	self.toolTipStore.tipRepairButton.luaClick = self:CreateAction("OnTipRepairBtnClick")
	self.toolTipStore.tipMASwitchButton.luaClick = self:CreateAction("OnTipMASwitchBtnClick")
	self.toolTipStore.tipMADetailBtn.luaClick = self:CreateAction("OnTipMADetailBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.toolTipStore.tipModeButtonPad.luaClick = self:CreateAction("OnTipRepairBtnClick")
		self.toolTipStore.tipMASwitchButtonPad.luaClick = self:CreateAction("OnTipMASwitchBtnClick")
		self.toolTipStore.tipDeleteButton.luaClick = self:CreateAction("OnTipDeleteBtnClick")
	end

	LX6.TouchNew.TouchProxy.SetForceHide(true)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()

	self.circleStore = nil
	self.toolTipStore = nil
	self.circleDragBeginCb = nil
	self.circleDragEndCb = nil

	LX6.TouchNew.TouchProxy.SetForceHide(false)
end

function M:OnShow(panelId, data)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.mobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.currTaskId = gTaskNodeManager:GetNowDoingTask()

	self:InitCharacterList()
	self:InitTab()
	self:InitWeaponData()
	self:InitMAData()
	self:InitFilterAndSorter()
	self:InitView()

	self.bindData.HideFilterCtrl = self.gamepadMode and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:OnUpdate()
	if self.currShowMode == self.SHOW_MODE.CHARACTER or not self.gamepadMode then
		return
	end

	if self.currContentType == self.CONTENT_TYPE.WEAPON then
		self:UpdateWeaponArrowSelect()
	else
		self:UpdateMAArrowSelect()
	end
end

function M:UpdateWeaponArrowSelect()
	if self.gamepadMode and self.updateSelect then
		self:UpdateSmoothMoveVector()

		local index, angle = self:GetWeaponSelect(self.moveVector)

		self:SetWeaponBoxSelectPad(index)
	end
end

function M:SetWeaponBoxSelectPad(index)
	if index ~= self.currSelectIndexCircle then
		self:SetCurrSelectCircle(self.CONTENT_TYPE.WEAPON, index)
		self:RefreshWeaponView()

		if #self.weaponListForRender > 0 then
			self.bindData.weaponList:SelectItem(0, false)
			self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
		end
	end
end

function M:UpdateMAArrowSelect()
	if self.gamepadMode and self.updateSelect then
		self:UpdateSmoothMoveVector()

		local index, angle = self:GetWeaponSelect(self.moveVector)

		self:SetMABoxSelectPad(index)
	end
end

function M:SetMABoxSelectPad(index)
	if index ~= self.currSelectIndexCircle then
		self:SetCurrSelectCircle(self.CONTENT_TYPE.MA, index)
		self:RefreshMAView()

		if #self.maListForRender > 0 then
			self.bindData.maList:SelectItem(0, false)
			self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, 1, true)
		end
	end
end

function M:GetWeaponSelect(moveVector)
	local angle = self:CalculateAngle(self.weaponInitVector, moveVector)

	if angle < 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.weaponEachAngle) + 1

	return index, angle
end

function M:CalculateAngle(initVec, endVec)
	local angle = Vector2.SignedAngle(endVec, initVec)

	return angle
end

function M:OnClose()
	self.mgr = nil
	self.tabList = nil
	self.selectedTabIndex = nil
	self.currPageIndex = nil
	self.CONTROL = nil
	self.SHOW_MODE = nil
	self.characterList = nil
	self.selectedCharacterIndex = nil
	self.selectedCharacterCfg = nil
	self.characterWeaponList = nil
	self.weaponList = nil
	self.weaponListForRender = nil
	self.weaponListForFilterTemp = nil
	self.circleWeaponBtnStore = nil
	self.sortIncrease = nil
	self.SORT_KEY = nil
	self.sortIndex = nil
	self.SORT_REVERSE = nil
	self.sortFunc = nil
	self.toolTipSource = nil
	self.characterData = nil
	self.toolTipData = nil
	self.toolTipRenderData = nil
	self.guideItemDict = nil
	self.guideMAItemDict = nil
	self.guideInstanceDict = nil
	self.guideMAInstanceDict = nil
	self.OP_Add_To_Circle = nil
	self.OP_Add_To_Armory = nil

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	gWeaponManager:PushRedDotQueue()
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	self.SubGroup.FilterSorterComponentStore:ResetFilter(true)

	self.bindData.HideFilterCtrl = self.gamepadMode and self.CONTROL.TRUE or self.CONTROL.FALSE

	if self.gamepadMode and self.currShowMode == self.SHOW_MODE.CONTENT then
		self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_WEAPON)
		self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_MA)

		if self.currContentType == self.CONTENT_TYPE.WEAPON then
			self:SetWeaponBoxSelectPad(1)
		elseif self.currContentType == self.CONTENT_TYPE.MA then
			self:SetMABoxSelectPad(1)
		end
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SPIRIT_WEAPON_SLOT_ADD] = self:CreateAction("OnSpiritWeaponSlotAdd"),
		[gEventConstants.ARMORY_WEAPON_ADD] = self:CreateAction("OnArmoryWeaponAdd"),
		[gEventConstants.WEAPON_DURABILITY_CHANGE] = self:CreateAction("OnWeaponDurabilityChange"),
		[gEventConstants.CURRENT_WEAPON_OPERATORFLAGS_CHANGED] = self:CreateAction("OnWeaponOperatorFlagsChange")
	}
end

function M:InitCharacterList()
	table.clear(self.characterList)

	local spiritList = gUrbanAbilityManager:GetAllLingList()

	for i, v in pairs(spiritList) do
		local cfg = LTConfig.FightSpiritConfig.GetConfig(v.Id)

		if cfg then
			local info = {
				cfg = cfg,
				isCurrent = cfg.Id == gBattleSpiritMgr.currentSpiritTemplateId
			}

			if info.isCurrent then
				table.insert(self.characterList, 1, info)
			else
				table.insert(self.characterList, info)
			end
		else
			print_error("SetSpiritList Not Find FightSpirit  Id = " .. v.Id)
		end
	end

	self.characterDataReady = false
	self.bindData.ShowBattleInfoCtrl = self.CONTROL.FALSE

	gClientToGameDelegate:AskAllSpiritPanelData().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			if self.STATE_OnShowOnce then
				self.characterDataReady = true
				self.characterData = data

				if self.selectedCharacterCfg then
					local charData = self:GetCharacterData(self.selectedCharacterCfg.Id)

					if charData then
						self.bindData.ShowBattleInfoCtrl = self.CONTROL.TRUE
						self.bindData.trAtkValue = math.floor(charData.Dam)
						self.bindData.trHpValue = math.floor(charData.MaxHp)
						self.bindData.trDefValue = math.floor(charData.DefDeduct)
					else
						self.bindData.ShowBattleInfoCtrl = self.CONTROL.FALSE
					end
				end
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:InitWeaponData()
	table.clear(self.weaponList)

	local ArmoryWeapons = gPlayerManager.infoSpirit.bindData.ArmoryWeapons

	for _, weapon in pairs(ArmoryWeapons) do
		local info, _ = self:ProcessArmoryWeapon(weapon)

		table.insert(self.weaponList, info)
	end
end

function M:RefreshArmoryWeaponWarning()
	for i = 1, #self.weaponList do
		local data = self.weaponList[i]
		local warn = false

		if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
			if not self.maBoxCircleItem.fake then
				if self.maBoxCircleItem.r_State == self.MA_CIRCLE_STATE.FIXED then
					if self.maBoxCircleItem.r_WeaponTid ~= data.TemplateId then
						warn = true
					end
				elseif data.FixedFightSkill then
					if data.FightSkillId > 0 and self.maBoxCircleItem.r_Cfg and self.maBoxCircleItem.r_Cfg.Id ~= data.FightSkillId then
						warn = true
					end
				else
					warn = self.maBoxCircleItem.r_SkillType > 0 and data.FightSkillType ~= self.maBoxCircleItem.r_SkillType
				end
			else
				warn = data.FixedFightSkill and true or self.maBoxCircleItem.f_SkillType > 0 and data.FightSkillType ~= self.maBoxCircleItem.f_SkillType
			end
		end

		data.Warn = warn and self.CONTROL.TRUE or self.CONTROL.FALSE
	end
end

function M:RefreshArmoryWeaponMAInfo()
	for i = 1, #self.weaponList do
		local data = self.weaponList[i]

		self:UpdateWeaponMaInfo(data)
	end
end

function M:InitMAData()
	table.clear(self.maList)

	local skills = gCS.FightStyleManager.Instance:GetAllUnlockedFightStyles()

	for i = 0, skills.Length - 1 do
		local cfg = FightSkillConfig.GetConfig(skills[i])

		if cfg and cfg.IsShowInArmony and cfg.FightSkillType > 0 and self.tabFightStyleAll[cfg.FightSkillType] then
			local info = self:ProcessArmoryMA(cfg)

			table.insert(self.maList, info)
		end
	end
end

function M:ProcessArmoryMA(cfg, default)
	local item = default or {}
	item.Cfg = cfg
	item.Id = cfg.Id
	item.FightSkillType = cfg.FightSkillType
	local spiritId = cfg and cfg.SpiritId

	if not table.isNilOrEmpty(spiritId) then
		item.FightSkillSpiritId = spiritId
	else
		item.FightSkillSpiritId = nil
	end

	item.Quality = cfg.Quality
	item.IconId = cfg.IconId
	item.Warn = self.CONTROL.FALSE
	item.Name = cfg.Name
	local typeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(item.FightSkillType)
	local typeSpiritId = typeCfg and typeCfg.SpiritId

	if not table.isNilOrEmpty(typeSpiritId) then
		item.FightSkillTypeSpiritId = typeSpiritId
	else
		item.FightSkillTypeSpiritId = nil
	end

	return item
end

function M:RefreshArmoryMAWarning()
	for i = 1, #self.maList do
		local data = self.maList[i]
		local warn = false

		if self.currSelectModeCircle == self.CONTENT_TYPE.MA then
			warn = self.maBoxCircleItem.r_State == self.MA_CIRCLE_STATE.FIXED and true or self.maBoxCircleItem.r_SkillType > 0 and self.maBoxCircleItem.r_SkillType ~= data.FightSkillType
		end

		data.Warn = warn and self.CONTROL.TRUE or self.CONTROL.FALSE
	end
end

function M:InitTab()
	table.clear(self.tabList)
	table.clear(self.tabFightStyleAll)
	table.clear(self.currFightStyleDict)

	local cfg = LTConfig.WeaponFightStyleConfig.GetConfig(LTConfig.WeaponFightStyleConfig.count)

	table.insert(self.tabList, cfg)

	for i = 1, LTConfig.WeaponFightStyleConfig.count - 1 do
		cfg = LTConfig.WeaponFightStyleConfig.GetConfig(i)

		if cfg then
			table.insert(self.tabList, cfg)

			if cfg.FightSkillTypes then
				for i = 1, #cfg.FightSkillTypes do
					self.tabFightStyleAll[cfg.FightSkillTypes[i]] = #self.tabList
				end
			end
		end
	end

	self.selectedTabIndex = 0
end

function M:InitFilterAndSorter()
	self.qualityFilter = {}
	self.categoryFilter = {}
	self.sorterList = {}
	local sortItemTitle = WeaponConfig.SortName

	for i = 1, #sortItemTitle do
		local view = {
			title = sortItemTitle[i],
			id = self.SORT_KEY[i <= 4 and i or i + 1]
		}

		table.insert(self.sorterList, view)
	end

	self.filterList = {}
	local qualityFilter = {
		id = "quality",
		title = WeaponConfig.FilterTypeName[1],
		type = 2
	}
	local qualitySubList = {}
	qualityFilter.subList = qualitySubList

	for i = 1, #WeaponConfig.QualityName do
		table.insert(qualitySubList, {
			selected = false,
			id = 7 - i,
			title = WeaponConfig.QualityName[i]
		})
	end

	table.insert(self.filterList, qualityFilter)

	local categoryFilter = {
		id = "category",
		title = WeaponConfig.FilterTypeName[2],
		type = 2
	}
	local categorySubList = {}
	categoryFilter.subList = categorySubList

	for i = 1, #WeaponConfig.CategoryName do
		table.insert(categorySubList, {
			selected = false,
			id = i - 1,
			title = WeaponConfig.CategoryName[i]
		})
	end

	table.insert(self.filterList, categoryFilter)
	self.SubGroup.FilterSorterComponentStore:SetData({
		sortList = self.sorterList,
		onSortChanged = self:CreateAction("OnSortChanged"),
		isAscending = self.sortIncrease,
		filterList = self.filterList,
		onFilterChanged = self:CreateAction("OnFilterChanged"),
		onFilterMenuClose = self:CreateAction("OnFilterMenuClose"),
		onFilterMenuShow = self:CreateAction("OnFilterMenuShow"),
		onDropSelectorClick = self:CreateAction("OnDropSelectorClick")
	})
end

function M:InitView()
	self.bindData.characterList:SetSimpleList(#self.characterList)
	self.bindData.characterList:SelectItem(0, false)

	local idx = self:OnCharacterSelect(1)

	self:RefreshArmoryWeaponMAInfo()
	self:FilterMARenderList()

	self.currContentType = 0

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SelectItem(0, false)

	self.selectedTabIndex = 1
	self.sortKey = self.SORT_KEY[1]
	self.sortIncrease = false

	self:FilterWeaponRenderList()
	self:SortRenderWeapon()
	self:InitGuideInfo()
	self:SetTooltipInfo(self.SELECT_MODE.NONE)

	self.bindData.ShowToolTipCtrl = self.CONTROL.FALSE

	self:SetShowMode(self.SHOW_MODE.CONTENT, true)
	self:RebuildWeaponView()
	self:AutoSwitchPage(idx)

	self.currContentType = self.CONTENT_TYPE.WEAPON
	self.bindData.ContentTypeCtrl = self.CONTENT_TYPE.WEAPON
	self.circleStore.MAShowCtrl = self.CONTENT_TYPE.WEAPON
	self.MAEnable = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FightSkill)
	self.circleStore.MAlockCtrl = self.MAEnable and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:GetCharacterData(spiritId)
	if not self.characterDataReady then
		return
	end

	for i, v in ipairs(self.characterData) do
		if v.FightSpiritId == spiritId then
			return v
		end
	end
end

function M:ProcessArmoryWeapon(weapon, default)
	local item = default or {}
	item.TemplateId = weapon.TemplateId
	item.InstanceId = weapon.InstanceId
	item.Durability = weapon.Durability
	item.DurablePercentValue = 0
	item.EventId = weapon.EventId
	item.OperatorFlags = weapon.OperatorFlags
	item.WeaponFlags = weapon.WeaponFlags
	item.IsTask = gWeaponManager:GetFlag(weapon.OperatorFlags, 2) == 1
	item.CantDiscard = gWeaponManager:GetFlag(weapon.OperatorFlags, 1) == 1
	item.Cfg = WeaponConfig.GetConfig(item.TemplateId)
	item.TaskTop = gWeaponManager:CheckCanUseByTask(self.currTaskId, item.Cfg) and 1 or 0
	item.ShowRedDot = weapon.WeaponFlags.ShowRedDot
	item.RedDot = 0
	item.Equipped = self.CONTROL.FALSE
	item.Quality = 0
	item.SixDimName = ""
	item.SixDimIcon = 0
	item.AttackFill = 0
	item.SpeedFill = 0
	item.Type = 0
	item.AttackPower = 0
	item.MaxDurability = 0
	item.ReceivedTimeStamp = weapon.ReceivedTimeStamp
	item.GuideId = nil
	item.BrokenState = 0
	item.FightSkillType = 0
	item.FixedFightSkill = false
	item.FightSkillId = 0
	item.Warn = self.CONTROL.FALSE

	if item.Cfg then
		item.Quality = item.Cfg.Quality

		self.mgr:GetWeaponDurability(item, weapon)

		item.tags = {}

		for j = 1, #item.Cfg.Tags do
			table.insert(item.tags, {
				TagType = item.Cfg.Tags[j]
			})
		end

		local cfg = UrbanAttributeConfig.GetConfig(item.Cfg.sixDimBonus)
		item.SixDimName = cfg and cfg.Name or ""
		item.SixDimIcon = cfg and cfg.SIcon or 0
		item.Type = item.Cfg.Type
		item.AttackPower = item.Cfg.AttackPower
		item.MaxDurability = item.Cfg.Durability
		local taskGuide = gWeaponManager:CheckStoreTaskGuide(self.currTaskId, item.Cfg)

		if taskGuide then
			item.GuideId = item.Cfg.GuideId
		end

		item.RedDot = item.ShowRedDot and LTConfig.WeaponConfig.StoreTopQuality <= item.Quality and 1 or 0

		if item.RedDot > 0 then
			SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
		end
	else
		print_error("Weapon配表找不到配置,TemplateId=", item.TemplateId, "InstanceId=", item.InstanceId)
	end

	item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon

	if item.CategoryType == CategoryType.Weapon then
		if item.DurablePercentValue == 0 then
			item.BrokenState = 2
		elseif item.DurablePercentValue <= self.durabilityLowPoint then
			item.BrokenState = 1
		end
	end

	return item, item.CategoryType
end

function M:ProcessSpiritWeapon(spiritCfg, weapon, slotIndex, default)
	local item = default or {}
	item.TemplateId = weapon.TemplateId
	item.InstanceId = weapon.InstanceId
	item.EventId = weapon.EventId
	item.Durability = weapon.Durability
	item.DurablePercentValue = 0
	item.OperatorFlags = weapon.OperatorFlags
	item.WeaponFlags = weapon.WeaponFlags
	item.IsTask = gWeaponManager:GetFlag(weapon.OperatorFlags, 2) == 1
	item.CantDiscard = gWeaponManager:GetFlag(weapon.OperatorFlags, 1) == 1
	item.Quality = 0
	item.SixDimName = ""
	item.SixDimIcon = 0
	item.AttackPower = 0
	item.MaxDurability = 0
	item.Cfg = WeaponConfig.GetConfig(item.TemplateId)
	item.TaskTop = gWeaponManager:CheckCanUseByTask(self.currTaskId, item.Cfg) and 1 or 0
	item.ShowRedDot = weapon.WeaponFlags.ShowRedDot
	item.ReceivedTimeStamp = weapon.ReceivedTimeStamp
	item.RedDot = 0
	item.GuideId = nil
	item.BrokenState = 0
	item.FixedFightSkill = false
	item.FightSkillType = 0
	item.FightSkillId = 0
	item.Warn = self.CONTROL.FALSE

	if item.Cfg then
		item.Quality = item.Cfg.Quality

		self.mgr:GetWeaponDurability(item, weapon)

		item.tags = {}

		for j = 1, #item.Cfg.Tags do
			table.insert(item.tags, {
				TagType = item.Cfg.Tags[j]
			})
		end

		local cfg = UrbanAttributeConfig.GetConfig(item.Cfg.sixDimBonus)
		item.SixDimName = cfg and cfg.Name or ""
		item.SixDimIcon = cfg and cfg.SIcon or 0
		item.AttackPower = item.Cfg.AttackPower
		item.MaxDurability = item.Cfg.Durability
		local taskGuide = gWeaponManager:CheckStoreTaskGuide(self.currTaskId, item.Cfg)

		if taskGuide then
			item.GuideId = item.Cfg.GuideId
		end

		item.RedDot = item.ShowRedDot and LTConfig.WeaponConfig.StoreTopQuality <= item.Quality and 1 or 0

		if item.RedDot > 0 then
			SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
		end
	else
		print_error("Weapon配表找不到配置,TemplateId=", item.TemplateId, "InstanceId=", item.InstanceId)
	end

	item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon
	item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId == gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false

	if item.CategoryType == CategoryType.Weapon then
		if item.DurablePercentValue == 0 then
			item.BrokenState = 2
		elseif item.DurablePercentValue <= self.durabilityLowPoint then
			item.BrokenState = 1
		end
	end

	self:AddEquipInfo(item, spiritCfg, slotIndex)

	return item, item.CategoryType
end

function M:UpdateWeaponMaInfo(item)
	if item.Cfg then
		if item.Cfg.FixedFightSkill and item.Cfg.FixedFightSkill > 0 then
			item.FixedFightSkill = true
			item.FightSkillId = item.Cfg.FixedFightSkill
		else
			item.FixedFightSkill = false
			item.FightSkillType = item.Cfg.FightSkillType or 0
			item.FightSkillId = gCS.FightStyleManager.Instance:GetFightStyleByTemplateAndFightStyleCat(self.selectedCharacterCfg.Id, item.FightSkillType)
		end
	else
		item.FixedFightSkill = false
		item.FightSkillType = 0
		item.FightSkillId = 0
	end
end

function M:AddEquipInfo(weapon, spiritCfg, slotIndex)
	weapon.Equipped = self.CONTROL.TRUE
	weapon.BelongSpirit = spiritCfg.Id
	weapon.BelongSpiritName = spiritCfg.Name
	weapon.HeadIcon = spiritCfg.SHeadIconID
	weapon.SlotIndex = slotIndex
end

function M:RemoveEquipInfo(weapon)
	weapon.Equipped = self.CONTROL.FALSE
	weapon.BelongSpirit = nil
	weapon.BelongSpiritName = nil
	weapon.HeadIcon = nil
end

function M:ProcessWeaponMA(weaponCfg, slotIndex, default, info)
	local item = default or {}
	item.SlotIndex = slotIndex
	item.fake = false
	item.InstanceId = info and info.InstanceId
	item.TemplateId = info and info.TemplateId
	item.conflict = false
	item.r_State = self.MA_CIRCLE_STATE.EMPTY
	item.r_Cfg = nil
	item.r_SkillType = 0
	item.r_WeaponTid = 0
	item.f_Cfg = nil
	item.f_State = self.MA_CIRCLE_STATE.EMPTY
	item.f_SkillType = 0
	item.MAGuideId = nil

	if info then
		self:UpdateWeaponMaInfo(info)

		if info.FixedFightSkill then
			item.r_State = self.MA_CIRCLE_STATE.FIXED
			local cfg = FightSkillConfig.GetConfig(info.FightSkillId)

			if cfg then
				item.r_Cfg = cfg
			end
		else
			item.r_SkillType = info.FightSkillType
			local cfg = FightSkillConfig.GetConfig(info.FightSkillId)

			if cfg then
				item.r_Cfg = cfg
				item.r_State = self.MA_CIRCLE_STATE.DISPLAY
			end
		end
	end

	if weaponCfg then
		item.r_WeaponTid = weaponCfg.Id
		local taskGuide = gWeaponManager:CheckStoreTaskGuide(self.currTaskId, weaponCfg)

		if taskGuide then
			item.MAGuideId = weaponCfg.MAGuideId
		end
	end

	return item
end

function M:RegisterWidget()
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabSelectedChange")
	self.bindData.weaponList.luaSimpleRenderItem = self:CreateAction("OnRenderWeaponListItem")
	self.bindData.weaponList.luaSelectedChanged = self:CreateAction("OnWeaponSelectedChange")
	self.bindData.maList.luaSimpleRenderItem = self:CreateAction("OnRenderMAListItem")
	self.bindData.maList.luaSelectedChanged = self:CreateAction("OnMASelectedChange")
	self.bindData.characterList.luaSimpleRenderItem = self:CreateAction("OnRenderCharacterListItem")
	self.bindData.characterList.luaSelectedChanged = self:CreateAction("OnCharacterSelectedChange")
	self.bindData.characterBtn.luaClick = self:CreateAction("OnCharacterBtnClick")
	self.bindData.characterBackBtn.luaClick = self:CreateAction("OnCharacterBackBtnClick")
	self.bindData.characterBackBtnMobile.luaClick = self:CreateAction("OnCharacterBackBtnClick")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.groupDeleteBtn.luaClick = self:CreateAction("OnGroupDeleteBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.padBackBtn.luaLongPress = self:CreateAction("OnBackBtnClick")
		self.bindData.tabLeftBtn.luaBeginLongPress = self:CreateActionWithArgs("OnSwitchTab", -1)
		self.bindData.tabRightBtn.luaBeginLongPress = self:CreateActionWithArgs("OnSwitchTab", 1)
	end
end

function M:OnRenderTabListItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.weaponTypeIcon = data.Icon
		store.guideID = data.GuideId
		local warn = false

		if self.currSelectModeCircle == self.CONTENT_TYPE.MA then
			local idx = self.tabFightStyleAll[self.maBoxCircleItem.r_SkillType]
			warn = idx and idx ~= index + 1 and index ~= 0
		elseif self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
			local idx = self.tabFightStyleAll[self.maBoxCircleItem.fake and self.maBoxCircleItem.f_SkillType or self.maBoxCircleItem.r_SkillType]
			warn = idx and idx ~= index + 1 and index ~= 0
		end

		store.WarningCtrl = warn and self.CONTROL.TRUE or self.CONTROL.FALSE
	end
end

function M:OnTabSelectedChange()
	local index = self.bindData.tabList.selectedIndex + 1
	self.selectedTabIndex = index

	table.clear(self.currFightStyleDict)

	if index > 1 then
		local cfg = self.tabList[index]

		if cfg.FightSkillTypes then
			for i = 1, #cfg.FightSkillTypes do
				self.currFightStyleDict[cfg.FightSkillTypes[i]] = true
			end
		end
	end

	if self.currContentType == self.CONTENT_TYPE.WEAPON then
		self:RefreshWeapon()

		if self.gamepadMode and #self.weaponListForRender > 0 then
			self.bindData.weaponList:SelectItem(0, false)
			self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
		end
	else
		self:RefreshMA()

		if self.gamepadMode and #self.maListForRender > 0 then
			self.bindData.maList:SelectItem(0, false)
			self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, 1, true)
		end
	end
end

function M:OnSwitchTab(dir)
	local idx = self.bindData.tabList.selectedIndex + dir

	if idx < 0 then
		idx = #self.tabList - 1
	elseif idx >= #self.tabList then
		idx = 0
	end

	self.bindData.tabList:SelectItem(idx, true)
	self.bindData.tabList:GoToIndex(idx, true)
end

function M:OnRenderWeaponListItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.weaponListForRender[index + 1]

	if store and data then
		btn.luaHover = self:CreateActionWithArgs("OnWeaponBtnHover", index + 1)
		btn.luaUnhover = self:CreateActionWithArgs("OnWeaponBtnUnHover", index + 1)
		store.weaponIcon = data.Cfg.SWeaponWheelsIconId or 0
		store.durability = data.DurablePercent
		store.qualityCtrl = data.Quality
		store.equippedCtrl = data.Equipped
		store.headIcon = data.HeadIcon or 0
		store.BrokenCtrl = data.BrokenState
		btn.luaEnterDropWidget = self:CreateActionWithArgs("OnWeaponEnterDropWidget", index + 1)

		if data.TaskTop > 0 then
			store.redKey = ""
			store.taskTopCtrl = self.CONTROL.TRUE
		else
			store.taskTopCtrl = self.CONTROL.FALSE
			store.redKey = data.RedDot > 0 and "weapon." .. data.InstanceId or ""
		end

		if data.Equipped == 1 then
			local guide = self.guideInstanceDict[data.InstanceId] and data.GuideId or ""

			if not string.is_null_or_empty(guide) then
				guide = guide .. "_PAD"
			end

			store.guideID = guide
		else
			store.guideID = self.guideInstanceDict[data.InstanceId] and data.GuideId or ""
		end

		store.WarningCtrl = data.Warn
	end
end

function M:OnWeaponSelectedChange()
	local index = self.bindData.weaponList.selectedIndex + 1

	self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, index)
end

function M:OnRenderCharacterListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("DressAvatarStore"):GetStoreByWidget(btn)
	local data = self.characterList[index + 1]

	if store and data then
		store.iconId = data.cfg and data.cfg.SHeadIconID
	end
end

function M:OnCharacterSelectedChange()
	local index = self.bindData.characterList.selectedIndex + 1
	local idx = self:OnCharacterSelect(index)

	self:AutoSwitchPage(idx)
end

function M:OnRenderMAListItem(btn, index)
	local store = self:GetStoreByWidget(btn)
	local data = self.maListForRender[index + 1]

	if store and data then
		btn.luaHover = self:CreateActionWithArgs("OnMABtnHover", index + 1)
		btn.luaUnhover = self:CreateActionWithArgs("OnMABtnUnHover", index + 1)
		store.maIcon = data.IconId or 0
		store.maName = data.Name or ""
		btn.luaEnterDropWidget = self:CreateActionWithArgs("OnMAEnterDropWidget", index + 1)
		store.guideID = data.Cfg.GuideId or ""
		store.QualityCtrl = data.Quality or 0
		store.WarningCtrl = data.Warn
	end
end

function M:OnMASelectedChange()
	local index = self.bindData.maList.selectedIndex + 1

	self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, index)
end

function M:OnTipTagListRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local data = self.toolTipRenderData[index + 1]

	if store and data then
		store.TypeCtrl = data.TagType
	end
end

function M:OnReturnBtnClick()
	if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
		self:DropCircleToArmory(self.currSelectIndexCircle)
	end
end

function M:OnTipModeBtnClick()
	if self.toolTipStore.btnModeDisplayNameCtrl == self.TIP_NAME_DISPLAY.EQUIP then
		local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
		local weapon = self.characterWeaponList[idx]

		self:LoadWeaponToCircle(self.selectedCharacterCfg, self.toolTipData, weapon)
	elseif self.toolTipStore.btnModeDisplayNameCtrl == self.TIP_NAME_DISPLAY.EXCHANGE then
		local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
		local weapon = self.characterWeaponList[idx]

		if self.toolTipData.Equipped == 1 then
			self:DropCircleSwitchByItem(self.toolTipData, weapon)
		else
			self:LoadWeaponToCircle(self.selectedCharacterCfg, self.toolTipData, weapon)
		end
	elseif self.toolTipStore.btnModeDisplayNameCtrl == self.TIP_NAME_DISPLAY.AUTO_EQUIP then
		self:OnTipAutoEquipBtnClick()
	elseif self.toolTipStore.btnModeDisplayNameCtrl == self.TIP_NAME_DISPLAY.BACK then
		self:OnTipReturnBtnClick()
	end
end

function M:OnTipRepairBtnClick()
	if self.toolTipData and ulong.Greater(self.toolTipData.InstanceId, 0) then
		local fixMoney = (100 - self.toolTipData.DurablePercentValue) / 100 * self.toolTipData.Cfg.FixMoney

		gDisplayMessageMgr:ShowMessage(MessageConfig.ArmoryConfirmFix, function ()
			gClientToGameSceneDelegate:AskRepairWeaponDurability(self.toolTipData.InstanceId)
		end, nil, fixMoney, self.moneyConfig and self.moneyConfig.Name, self.toolTipData.Cfg.Name)
	end
end

function M:OnTipAutoEquipBtnClick()
	if self.mgr.banOperation then
		print_error("#NoCreateIssue Equip In Cd Wait For Rpc Back")

		return
	end

	if not self.selectedCharacterCfg then
		print_error("#NoCreateIssue Equip Failed Cd selectedCharacterCfg is nil")

		return
	end

	for i = 1, 16 do
		local weapon = self.characterWeaponList[i]

		if not weapon or weapon.Empty and not weapon.IsPrivate then
			self:LoadWeaponToCircle(self.selectedCharacterCfg, self.toolTipData, weapon)

			if i <= 8 then
				self:OnCirclePage1Click()

				break
			end

			self:OnCirclePage2Click()

			break
		end
	end
end

function M:OnTipReturnBtnClick()
	if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_WEAPON then
		self:DropCircleToArmory(self.currSelectIndexTooltip)
	end
end

function M:OnTipMASwitchBtnClick()
	if self.currSelectModeCircle == self.CONTENT_TYPE.MA then
		local toIndex = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
		local toMACircle = self.characterMAList[toIndex]

		self:LoadMAToCircle(self.selectedCharacterCfg, self.toolTipData, toMACircle)
	end
end

function M:OnTipMADetailBtnClick()
	if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_MA then
		if self.toolTipData.fake then
			gPanelManager:CheckShowSync(gPanelId.WEAPON_MA_DETAIL_PANEL, self.toolTipData.f_Cfg.Id)
		else
			gPanelManager:CheckShowSync(gPanelId.WEAPON_MA_DETAIL_PANEL, self.toolTipData.r_Cfg.Id)
		end
	elseif self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA then
		gPanelManager:CheckShowSync(gPanelId.WEAPON_MA_DETAIL_PANEL, self.toolTipData.Id)
	end
end

function M:OnTipDeleteBtnClick()
	if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and self.toolTipData then
		if self.toolTipData.Equipped == 1 then
			if not self.toolTipData.Empty and not self.toolTipData.IsPrivate and not self.toolTipData.CantDiscard then
				local instId = self.toolTipData.InstanceId

				gClientToGameSceneDelegate:AskDiscardWeaponByInstanceId(instId, self.selectedCharacterCfg.Id, true).Callback = function (err)
					if err == MessageConfig.Ok then
						self:HandleCircleWeaponDelete(instId)

						if self.currContentType == self.CONTENT_TYPE.WEAPON and #self.weaponListForRender > 0 then
							self.bindData.weaponList:SelectItem(0, false)
							self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
						end
					end
				end
			end
		elseif not self.toolTipData.CantDiscard then
			local instId = self.toolTipData.InstanceId

			gClientToGameDelegate:AskDiscardArmoryWeapon(instId, true).Callback = function (err)
				if err == MessageConfig.Ok then
					self:HandleArmoryWeaponDelete(instId)

					if self.currContentType == self.CONTENT_TYPE.WEAPON and #self.weaponListForRender > 0 then
						self.bindData.weaponList:SelectItem(0, false)
						self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
					end
				end
			end
		end
	end
end

function M:OnCirclePage1Click(force)
	if not force and self.currPageIndex == self.mgr.WEAPON_TYPE.PAGE1 then
		return
	end

	self.currPageIndex = self.mgr.WEAPON_TYPE.PAGE1
	self.circleStore.ShowLockCtrl = self.CONTROL.TRUE

	self.circleStore.page1Btn:SetSelected(true)
	self.circleStore.page2Btn:SetSelected(false)
	self:RebuildCircleWeaponView()
	self:RebuildCircleMAView()
	self:ClearCurrSelectCircle()

	if self.currShowMode == self.SHOW_MODE.CONTENT then
		if not self.gamepadMode then
			self:ClearCurrSelectTooltip()

			if self.currContentType == self.CONTENT_TYPE.WEAPON then
				self:RefreshWeaponView()
			elseif self.currContentType == self.CONTENT_TYPE.MA then
				self:RefreshMAView()
			end
		else
			self:SetCurrSelectCircle(self.currContentType, 1)

			if self.currContentType == self.CONTENT_TYPE.WEAPON then
				self:RefreshWeaponView()

				if #self.weaponListForRender > 0 then
					self.bindData.weaponList:SelectItem(0, false)
					self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
				else
					self:ClearCurrSelectTooltip()
				end
			elseif self.currContentType == self.CONTENT_TYPE.MA then
				self:RefreshMAView()

				if #self.maListForRender > 0 then
					self.bindData.maList:SelectItem(0, false)
					self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, 1, true)
				else
					self:ClearCurrSelectTooltip()
				end
			end
		end
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.circleAnime, "S_vx_CircleWeaponPanel_cut_u")
end

function M:OnCirclePage2Click(force)
	if not force and self.currPageIndex == self.mgr.WEAPON_TYPE.PAGE2 then
		return
	end

	self.currPageIndex = self.mgr.WEAPON_TYPE.PAGE2
	self.circleStore.ShowLockCtrl = self.CONTROL.FALSE

	self.circleStore.page1Btn:SetSelected(false)
	self.circleStore.page2Btn:SetSelected(true)
	self:RebuildCircleWeaponView()
	self:RebuildCircleMAView()
	self:ClearCurrSelectCircle()

	if self.currShowMode == self.SHOW_MODE.CONTENT then
		if not self.gamepadMode then
			self:ClearCurrSelectTooltip()

			if self.currContentType == self.CONTENT_TYPE.WEAPON then
				self:RefreshWeaponView()
			elseif self.currContentType == self.CONTENT_TYPE.MA then
				self:RefreshMAView()
			end
		else
			self:SetCurrSelectCircle(self.currContentType, 1)

			if self.currContentType == self.CONTENT_TYPE.WEAPON then
				self:RefreshWeaponView()

				if #self.weaponListForRender > 0 then
					self.bindData.weaponList:SelectItem(0, false)
					self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
				else
					self:ClearCurrSelectTooltip()
				end
			elseif self.currContentType == self.CONTENT_TYPE.MA then
				self:RefreshMAView()

				if #self.maListForRender > 0 then
					self.bindData.maList:SelectItem(0, false)
					self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, 1, true)
				else
					self:ClearCurrSelectTooltip()
				end
			end
		end
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.circleAnime, "S_vx_CircleWeaponPanel_cut_d")
end

function M:OnMouseDeleteClick()
	if self.currMouseHoverMode == self.SELECT_MODE.CIRCLE_WEAPON then
		self:DeleteCircleWeapon(self.currMouseHoverIndex)
	elseif self.currMouseHoverMode == self.SELECT_MODE.ARMORY_WEAPON then
		self:DeleteArmoryWeapon(self.currMouseHoverIndex)
	end
end

function M:OnDeleteBtnClick()
	if self.toolTipData then
		if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_WEAPON then
			if not self.toolTipData.Empty and not self.toolTipData.IsPrivate and not self.toolTipData.CantDiscard then
				local instanceId = self.toolTipData.InstanceId

				gClientToGameSceneDelegate:AskDiscardWeaponByInstanceId(self.toolTipData.InstanceId, self.selectedCharacterCfg.Id, true).Callback = function (err)
					if err == MessageConfig.Ok then
						self:HandleCircleWeaponDelete(instanceId)
					end
				end
			end
		elseif self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and not self.toolTipData.CantDiscard then
			local instId = self.toolTipData.InstanceId

			gClientToGameDelegate:AskDiscardArmoryWeapon(self.toolTipData.InstanceId, true).Callback = function (err)
				if err == MessageConfig.Ok then
					self:HandleArmoryWeaponDelete(instId)
				end
			end
		end
	end
end

function M:HandleArmoryWeaponDelete(instId)
	for i = 1, #self.weaponList do
		local weapon = self.weaponList[i]

		if weapon.InstanceId == instId then
			table.remove(self.weaponList, i)

			break
		end
	end

	for i = 1, #self.weaponListForRender do
		local weapon = self.weaponListForRender[i]

		if weapon.InstanceId == instId then
			table.remove(self.weaponListForRender, i)
			self:RebuildWeaponView()

			if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and self.currSelectIndexTooltip == i then
				self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
			end

			break
		end
	end
end

function M:OnMouseScroll(context)
	if context.performed then
		local zoom = context:ReadValueVector2().y

		if zoom > 0 then
			self:OnCirclePage1Click()
		elseif zoom < 0 then
			self:OnCirclePage2Click()
		end
	end
end

function M:OnCharacterBtnClick()
	self:SetShowMode(self.SHOW_MODE.CHARACTER)
	self:RefreshCircleInteract()

	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.characterArea

	self:ClearCurrSelectTooltip()
	self:ClearCurrSelectCircle()

	if self.currContentType == self.CONTENT_TYPE.WEAPON then
		self:RefreshWeaponView()
	elseif self.currContentType == self.CONTENT_TYPE.MA then
		self:RefreshMAView()
	end
end

function M:OnCharacterBackBtnClick()
	self:SetShowMode(self.SHOW_MODE.CONTENT)
	self:RefreshCircleInteract()

	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.rootArea

	if self.gamepadMode then
		if self.currContentType == self.CONTENT_TYPE.WEAPON then
			self:SetCurrSelectCircle(self.CONTENT_TYPE.WEAPON, 1)
			self:RefreshArmoryWeaponMAInfo()
			self:RefreshWeapon()

			if #self.weaponListForRender > 0 then
				self.bindData.weaponList:SelectItem(0, false)
				self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON, 1, true)
			end

			self:RebuildCircleWeaponView()
		elseif self.currContentType == self.CONTENT_TYPE.MA then
			self:SetMABoxSelectPad(1)
			self:RefreshMA()

			if #self.maListForRender > 0 then
				self.bindData.maList:SelectItem(0, false)
				self:SetCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA, 1, true)
			end

			self:RebuildCircleMAView()
		end
	elseif self.currContentType == self.CONTENT_TYPE.WEAPON then
		self:RefreshArmoryWeaponMAInfo()
		self:RefreshWeapon()
		self:RebuildCircleWeaponView()
	elseif self.currContentType == self.CONTENT_TYPE.MA then
		self:RefreshMA()
		self:RebuildCircleMAView()
	end
end

function M:OnBackBtnClick()
	if self.circleStore.WarningCtrl == self.CONTROL.TRUE then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FightStyleNotMatch, function ()
			gPanelManager:Close(gPanelId.S_WEAPON_ARMORY_MAIN_PANEL)
		end, nil)
	else
		gPanelManager:Close(gPanelId.S_WEAPON_ARMORY_MAIN_PANEL)
	end
end

function M:OnGroupDeleteBtnClick()
	gDisplayMessageMgr:ShowMessage(65401046)
end

function M:SelectCircleWeaponPad(index)
	if self.currSelectIndexCirclePad == index then
		return
	end

	self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
	self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

	self.currSelectIndexCirclePad = index

	if self.currSelectIndexCirclePad > 0 and self.currSelectIndexCirclePad <= self.MAX_SLOT_COUNT then
		self.circleWeaponBtnStore[self.currSelectIndexCirclePad].controllerSwitchIcon = self.toolTipData and self.toolTipData.Cfg.SWeaponWheelsIconId or 0
	end
end

function M:DeselectCircleWeaponPad(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleWeaponBtnStore[index].controllerSwitchIcon = 0
	end
end

function M:SelectCircleMAPad(index)
	if self.currSelectIndexCirclePad == index then
		return
	end

	self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
	self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

	self.currSelectIndexCirclePad = index

	if self.currSelectIndexCirclePad > 0 and self.currSelectIndexCirclePad <= self.MAX_SLOT_COUNT then
		self.circleMABtnStore[self.currSelectIndexCirclePad].controllerSwitchIcon = self.toolTipData and self.toolTipData.IconId or 0
	end
end

function M:DeselectCircleMAPad(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleMABtnStore[index].controllerSwitchIcon = 0
	end
end

function M:OnCircleWeaponBtnClick(index)
	self:SetCurrSelectCircle(self.CONTENT_TYPE.WEAPON, index)
	self:SetCurrSelectTooltip(self.SELECT_MODE.CIRCLE_WEAPON, index)
end

function M:RefreshWeaponView()
	self:RefreshArmoryWeaponWarning()
	self:SortRenderWeapon()
	self.bindData.tabList:RefreshList()
	self.bindData.weaponList:RefreshList()
end

function M:OnCircleWeaponDragBegin(index)
	self.circleStore["weaponItem" .. index]:InstantClearState()

	self.dragPage = self.currPageIndex
	self.bindData.DragCircleCtrl = self.CONTROL.TRUE

	self:ClearCurrSelectTooltip()
end

function M:OnCircleWeaponDragEnd()
	self.bindData.DragCircleCtrl = self.CONTROL.FALSE
end

function M:OnCircleWeaponBtnHover(index)
	self.currMouseHoverMode = self.SELECT_MODE.CIRCLE_WEAPON
	self.currMouseHoverIndex = index
end

function M:OnCircleWeaponBtnUnHover(index)
	if self.currMouseHoverMode == self.SELECT_MODE.CIRCLE_WEAPON then
		self.currMouseHoverMode = self.SELECT_MODE.NONE

		if self.currMouseHoverIndex == index then
			self.currMouseHoverIndex = 0
		end
	end
end

function M:OnCircleMABtnClick(index)
	self:SetCurrSelectCircle(self.CONTENT_TYPE.MA, index)
	self:SetCurrSelectTooltip(self.SELECT_MODE.CIRCLE_MA, index)
end

function M:RefreshMAView()
	self:RefreshArmoryMAWarning()
	self:SortRenderMA()
	self.bindData.tabList:RefreshList()
	self.bindData.maList:RefreshList()
end

function M:OnWeaponBtnHover(index)
	self.currMouseHoverMode = self.SELECT_MODE.ARMORY_WEAPON
	self.currMouseHoverIndex = index
end

function M:OnWeaponBtnUnHover(index)
	if self.currMouseHoverMode == self.SELECT_MODE.ARMORY_WEAPON then
		self.currMouseHoverMode = self.SELECT_MODE.NONE

		if self.currMouseHoverIndex == index then
			self.currMouseHoverIndex = 0
		end
	end
end

function M:OnReturnCircleAllBtnClick()
	if self.currPageIndex == self.mgr.WEAPON_TYPE.PAGE1 then
		for i = 3, 8 do
			self:DropCircleToArmory(i)
		end
	else
		for i = 9, 16 do
			self:DropCircleToArmory(i - 8)
		end
	end
end

function M:OnSwitchPageBtnClick()
	if self.currPageIndex == self.mgr.WEAPON_TYPE.PAGE1 then
		self:OnCirclePage2Click()
	else
		self:OnCirclePage1Click()
	end
end

function M:OnSwitchContentBtnClick()
	if self.currContentType == self.CONTENT_TYPE.WEAPON then
		if not self.MAEnable then
			return
		end

		self:SwitchCurrentSelectCircle(self.CONTENT_TYPE.MA)
		self:SwitchContentType(self.CONTENT_TYPE.MA)
		self.bindData.rootArea:SetStartNavContent(self.bindData.maList, true)

		if #self.maListForRender > 0 then
			self.bindData.maList:SelectItem(0, true)
		else
			self:ClearCurrSelectTooltip()
		end
	else
		self:SwitchCurrentSelectCircle(self.CONTENT_TYPE.WEAPON)
		self:SwitchContentType(self.CONTENT_TYPE.WEAPON)
		self.bindData.rootArea:SetStartNavContent(self.bindData.weaponList, true)

		if #self.weaponListForRender > 0 then
			self.bindData.weaponList:SelectItem(0, true)
		else
			self:ClearCurrSelectTooltip()
		end
	end
end

function M:OnRightStickControl(context)
	if context.performed then
		local value = context:ReadValueVector2()

		self:UpdateSmoothMoveVector()
		self:SetSmoothMove(value)
	elseif context.canceled then
		self:ClearSmoothMove()
	end
end

function M:SetSmoothMove(moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

function M:ClearSmoothMove()
	self.updateSelect = false
end

function M:UpdateSmoothMoveVector()
	if not self.updateSelect then
		return
	end

	local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
	self.moveVector.x = x
	self.moveVector.y = y

	if self.SMOOTH_TIME < Time.unscaledTime - self.smoothStartTime then
		self:ClearSmoothMove()
	end
end

function M:SortPriority(sortKey)
	for i = 1, #self.sortIndex do
		self.sortIndex[i] = i
	end

	for i = 1, #self.SORT_KEY do
		if self.SORT_KEY[i] == sortKey then
			table.remove(self.sortIndex, i)
			table.insert(self.sortIndex, 1, i)

			break
		end
	end

	table.sort(self.weaponListForRender, self.sortFunc)
end

function M:boolXor(a, b)
	return a ~= b
end

function M:OnSortChanged(data, sortIncrease)
	self.sortKey = data
	self.sortIncrease = sortIncrease

	self:SortRenderWeapon()
	self:RebuildWeaponView()
end

function M:OnFilterChanged(data)
	self:FilterWeaponRenderList(data)
	self:RefreshArmoryWeaponWarning()
	self:SortRenderWeapon()
	self:RebuildWeaponView()
end

function M:OnFilterMenuClose()
	if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON or self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA then
		self:ClearCurrSelectTooltip()
	end
end

function M:OnDropSelectorClick()
	if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON or self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA then
		self:ClearCurrSelectTooltip()
	end
end

function M:OnFilterMenuShow()
	if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON or self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA then
		self:ClearCurrSelectTooltip()
	end
end

function M:RefreshWeapon()
	self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
	self:FilterWeaponRenderList()
	self:RefreshArmoryWeaponWarning()
	self:SortRenderWeapon()
	self:RebuildWeaponView()
end

function M:FilterWeaponRenderList(data)
	self.qualityFilter = data and data.quality or self.qualityFilter
	self.categoryFilter = data and data.category or self.categoryFilter

	table.clear(self.weaponListForRender)
	table.clear(self.weaponListForFilterTemp)

	for i = 1, #self.weaponList do
		table.insert(self.weaponListForRender, self.weaponList[i])
	end

	for i = 1, #self.characterWeaponList do
		local item = self.characterWeaponList[i]

		if item and not item.Empty then
			table.insert(self.weaponListForRender, item)
		end
	end

	if self.selectedTabIndex > 1 then
		self.typeFilter = self.tabList[self.selectedTabIndex].Id

		if self.typeFilter > 0 then
			for i = 1, #self.weaponListForRender do
				local weapon = self.weaponListForRender[i]

				if self.typeFilter == weapon.Type then
					table.insert(self.weaponListForFilterTemp, weapon)
				end
			end

			local tmp = self.weaponListForFilterTemp
			self.weaponListForFilterTemp = self.weaponListForRender
			self.weaponListForRender = tmp

			table.clear(self.weaponListForFilterTemp)
		end
	end

	if not table.is_empty(self.qualityFilter) then
		for i = 1, #self.weaponListForRender do
			local weapon = self.weaponListForRender[i]

			if self.qualityFilter[weapon.Quality] then
				table.insert(self.weaponListForFilterTemp, weapon)
			end
		end

		local tmp = self.weaponListForFilterTemp
		self.weaponListForFilterTemp = self.weaponListForRender
		self.weaponListForRender = tmp

		table.clear(self.weaponListForFilterTemp)
	end

	if not table.is_empty(self.categoryFilter) then
		for i = 1, #self.weaponListForRender do
			local weapon = self.weaponListForRender[i]

			if self.categoryFilter[weapon.CategoryType] then
				table.insert(self.weaponListForFilterTemp, weapon)
			end
		end

		local tmp = self.weaponListForFilterTemp
		self.weaponListForFilterTemp = self.weaponListForRender
		self.weaponListForRender = tmp

		table.clear(self.weaponListForFilterTemp)
	end

	self.bindData.weaponNum = #self.weaponListForRender
end

function M:FilterSingleWeapon(weapon)
	if not table.is_empty(self.qualityFilter) and not self.qualityFilter[weapon.Quality] then
		return false
	end

	if not table.is_empty(self.categoryFilter) and not self.categoryFilter[weapon.CategoryType] then
		return false
	end

	if self.selectedTabIndex > 1 and weapon.Type ~= self.tabList[self.selectedTabIndex].Id then
		return false
	end

	return true
end

function M:SortRenderWeapon()
	self:SortPriority(self.sortKey)
end

function M:RebuildWeaponView()
	self.bindData.weaponList:SetSimpleList(#self.weaponListForRender)
	self.bindData.weaponList:GoToIndex(0, true)

	self.bindData.weaponNum = #self.weaponListForRender
	self.bindData.EmptyWeaponCtrl = #self.weaponListForRender == 0 and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:OnWeaponEnterDropWidget(index, circleWidget)
	if self.mgr.banOperation then
		return
	end

	if not self.selectedCharacterCfg then
		return
	end

	local charCfg = self.selectedCharacterCfg
	local circleStore = self:GetStoreByWidget(circleWidget)

	if circleStore and circleStore.CRCType == self.CONTENT_TYPE.WEAPON then
		local toIndex = gWeaponManager:ConvertSelectIndex(circleStore.CRCIndex, self.currPageIndex)
		local toCircleItem = self.characterWeaponList[toIndex]
		local fromWeapon = self.weaponListForRender[index]

		if fromWeapon.Equipped == 1 then
			self:DropCircleSwitchByItem(fromWeapon, toCircleItem)
		else
			self:LoadWeaponToCircle(charCfg, fromWeapon, toCircleItem)
		end
	end
end

function M:LoadWeaponToCircle(charCfg, fromWeapon, toCircleItem)
	local id = fromWeapon.InstanceId
	self.OP_Add_To_Circle[id] = true
	local toId = toCircleItem.InstanceId

	if toId then
		self.OP_Add_To_Armory[toId] = true
	end

	self.mgr:AskLoadWeaponToSlot(charCfg.Id, fromWeapon.InstanceId, toCircleItem.SlotIndex, function (success)
		if not self.STATE_OnShowOnce then
			self.OP_Add_To_Circle[id] = false

			if toId then
				self.OP_Add_To_Armory[toId] = false
			end

			return
		end

		if success then
			self:HandleWeaponToCircle(charCfg, fromWeapon, toCircleItem)
		else
			self.OP_Add_To_Circle[id] = false

			if toId then
				self.OP_Add_To_Armory[toId] = false
			end
		end
	end)
end

function M:HandleWeaponToCircle(charCfg, fromWeapon, toCircleItem)
	local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)
	local crcIndex = toCircleItem.SlotIndex + 1 - startIndex

	if toCircleItem.Empty then
		if self.selectedCharacterCfg.Id == charCfg.Id and toCircleItem then
			local SlotIndex = toCircleItem.SlotIndex

			table.clear(toCircleItem)

			local info = self:ProcessSpiritWeapon(self.selectedCharacterCfg, fromWeapon, SlotIndex, toCircleItem)
			info.Empty = false

			if SlotIndex < 2 then
				info.IsPrivate = true
				info.DurablePercent = ""
			else
				info.IsPrivate = false
			end

			if crcIndex > 0 and crcIndex <= 8 then
				self:OnRenderCircleWeaponItem(crcIndex, info)
			end

			local toMACircle = self.characterMAList[SlotIndex + 1]

			if toMACircle.fake or toMACircle.r_State ~= self.MA_CIRCLE_STATE.EMPTY then
				local preMaItem = {
					Cfg = toMACircle.fake and toMACircle.f_Cfg or toMACircle.r_Cfg
				}

				self:ProcessWeaponMA(info.Cfg, SlotIndex, toMACircle, info)
				self:LoadMAToCircle(self.selectedCharacterCfg, preMaItem, toMACircle)
			else
				self:ProcessWeaponMA(info.Cfg, SlotIndex, toMACircle, info)

				if crcIndex > 0 and crcIndex <= 8 then
					self:OnRenderCircleMAItem(crcIndex, toMACircle)
					self:RefreshMAConflict()
				end
			end
		end

		for i = 1, #self.weaponList do
			local weapon = self.weaponList[i]

			if weapon.InstanceId == toCircleItem.InstanceId then
				table.remove(self.weaponList, i)

				break
			end
		end

		for i = 1, #self.weaponListForRender do
			local weapon = self.weaponListForRender[i]

			if weapon.InstanceId == toCircleItem.InstanceId then
				self.weaponListForRender[i] = toCircleItem

				self.bindData.weaponList:RefreshElement(i - 1)

				break
			end
		end
	else
		local toAdd = self:ProcessArmoryWeapon(toCircleItem)

		self:UpdateWeaponMaInfo(toAdd)

		local fromIdx = 0
		local toIdx = 0

		for i = 1, #self.weaponListForRender do
			local weapon = self.weaponListForRender[i]

			if weapon.InstanceId == fromWeapon.InstanceId then
				fromIdx = i
			end

			if weapon.InstanceId == toCircleItem.InstanceId then
				toIdx = i
			end
		end

		if self.selectedCharacterCfg.Id == charCfg.Id and toCircleItem then
			local SlotIndex = toCircleItem.SlotIndex

			table.clear(toCircleItem)

			local info = self:ProcessSpiritWeapon(self.selectedCharacterCfg, fromWeapon, SlotIndex, toCircleItem)
			info.Empty = false

			if SlotIndex < 2 then
				info.IsPrivate = true
				info.DurablePercent = ""
			else
				info.IsPrivate = false
			end

			if crcIndex > 0 and crcIndex <= 8 then
				self:OnRenderCircleWeaponItem(crcIndex, toCircleItem)
			end

			local toMACircle = self.characterMAList[SlotIndex + 1]

			if toMACircle.fake or toMACircle.r_State ~= self.MA_CIRCLE_STATE.EMPTY then
				local preMaItem = {
					Cfg = toMACircle.fake and toMACircle.f_Cfg or toMACircle.r_Cfg
				}

				self:ProcessWeaponMA(info.Cfg, SlotIndex, toMACircle, info)
				self:LoadMAToCircle(self.selectedCharacterCfg, preMaItem, toMACircle)
			else
				self:ProcessWeaponMA(info.Cfg, SlotIndex, toMACircle, info)

				if crcIndex > 0 and crcIndex <= 8 then
					self:OnRenderCircleMAItem(crcIndex, toMACircle)
					self:RefreshMAConflict()
				end
			end
		end

		for i = 1, #self.weaponList do
			local weapon = self.weaponList[i]

			if weapon.InstanceId == toCircleItem.InstanceId then
				table.remove(self.weaponList, i)

				break
			end
		end

		table.insert(self.weaponList, toAdd)

		self.weaponListForRender[fromIdx] = toCircleItem
		self.weaponListForRender[toIdx] = toAdd
	end

	self:RefreshCurrSelectTooltip()
	self:RefreshWarningView()
end

function M:OnArmoryWeaponAdd(eventId, addInfo)
	local weapon = addInfo.Weapon

	if self.OP_Add_To_Armory[weapon.InstanceId] then
		self.OP_Add_To_Armory[weapon.InstanceId] = nil
	else
		self:HandleArmoryWeaponAdd(weapon)
	end
end

function M:HandleArmoryWeaponAdd(weapon)
	local info, _ = self:ProcessArmoryWeapon(weapon)

	self:UpdateWeaponMaInfo(info)
	table.insert(self.weaponList, info)

	if self:FilterSingleWeapon(info) then
		table.insert(self.weaponListForRender, info)
		self:RebuildWeaponView()

		if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON then
			self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
		end
	end
end

function M:HandleCircleToArmory(weapon)
	local info, _ = self:ProcessArmoryWeapon(weapon)

	self:UpdateWeaponMaInfo(info)
	table.insert(self.weaponList, info)

	if self:FilterSingleWeapon(info) then
		for i = 1, #self.weaponListForRender do
			local item = self.weaponListForRender[i]

			if item.InstanceId == info.InstanceId then
				self.weaponListForRender[i] = info

				self.bindData.weaponList:RefreshElement(i - 1)

				if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and self.currSelectIndexTooltip == i then
					self:RefreshCurrSelectTooltip()
				end

				break
			end
		end
	end

	local slotIndex = weapon.SlotIndex

	table.clear(weapon)
	self:AddEquipInfo(weapon, self.selectedCharacterCfg, slotIndex)

	weapon.Empty = true

	if slotIndex < 2 then
		weapon.IsPrivate = true
	end

	self:ProcessWeaponMA(nil, slotIndex, self.characterMAList[slotIndex + 1])

	local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

	if startIndex < slotIndex + 1 and endIndex >= slotIndex + 1 then
		local idx = slotIndex + 1 - startIndex

		self:OnRenderCircleWeaponItem(idx)
		self:OnRenderCircleMAItem(idx)

		if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_WEAPON and self.currSelectIndexTooltip == idx then
			self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_WEAPON)
		end

		if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_MA and self.currSelectIndexTooltip == idx then
			self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_MA)
		end

		if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and self.currSelectIndexTooltip == idx then
			self:RefreshCurrSelectTooltip()
		end

		if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA and self.currSelectIndexTooltip == idx then
			self:RefreshCurrSelectTooltip()
		end

		self:RefreshMAConflict()
		self:RefreshWarningView()
	end
end

function M:RefreshWarningView()
	self:RefreshCurrSelectCircle()

	if self.currContentType == self.CONTENT_TYPE.WEAPON then
		self:RefreshArmoryWeaponWarning()
		self.bindData.tabList:RefreshList()
		self.bindData.weaponList:RefreshList()
	elseif self.currContentType == self.CONTENT_TYPE.MA then
		self:RefreshArmoryMAWarning()
		self.bindData.tabList:RefreshList()
		self.bindData.maList:RefreshList()
	end
end

function M:DeleteArmoryWeapon(index)
	if self.currShowMode == self.SHOW_MODE.CONTENT and index > 0 then
		local item = self.weaponListForRender[index]

		if item and not item.CantDiscard then
			gClientToGameDelegate:AskDiscardArmoryWeapon(item.InstanceId, true).Callback = function ()
				return
			end
		end
	end
end

function M:OnWeaponDurabilityChange(eventId, data)
	local weaponId = data.weaponId

	for i = 1, #self.characterWeaponList do
		local weapon = self.characterWeaponList[i]

		if weapon and not weapon.Empty and weapon.InstanceId == weaponId then
			weapon.Durability = data.durability
			weapon.DurablePercentValue = 0
			weapon.BrokenState = 0

			if weapon.Cfg then
				self.mgr:GetWeaponDurability(weapon, weapon)
			end

			if weapon.CategoryType == CategoryType.Weapon then
				if weapon.DurablePercentValue == 0 then
					weapon.BrokenState = 2
				elseif weapon.DurablePercentValue <= self.durabilityLowPoint then
					weapon.BrokenState = 1
				end
			end

			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < i and i <= endIndex then
				local idx = i - startIndex
				self.circleWeaponBtnStore[idx].durability = weapon.DurablePercent
				self.circleWeaponBtnStore[idx].BrokenCtrl = weapon.BrokenState
			end

			if self.toolTipData and self.toolTipData.InstanceId == weaponId then
				local hideRepair = weapon.DurablePercentValue and weapon.DurablePercentValue == 100
				self.toolTipStore.tipRepairButton.interactable = not hideRepair
				self.toolTipStore.tipRepairButtonPad.interactable = not hideRepair
			end

			break
		end
	end

	for i = 1, #self.weaponList do
		local weapon = self.weaponList[i]

		if weapon.InstanceId == weaponId then
			weapon.Durability = data.durability
			weapon.DurablePercentValue = 0
			weapon.BrokenState = 0

			if weapon.Cfg then
				self.mgr:GetWeaponDurability(weapon, weapon)
			end

			if weapon.CategoryType == CategoryType.Weapon and weapon.DurablePercentValue == 0 then
				weapon.BrokenState = 2

				break
			end

			if weapon.DurablePercentValue <= self.durabilityLowPoint then
				weapon.BrokenState = 1
			end

			break
		end
	end

	for i = 1, #self.weaponListForRender do
		local weapon = self.weaponListForRender[i]

		if weapon.InstanceId == weaponId then
			weapon.Durability = data.durability
			weapon.DurablePercentValue = 0
			weapon.BrokenState = 0

			if weapon.Cfg then
				self.mgr:GetWeaponDurability(weapon, weapon)
			end

			if weapon.CategoryType == CategoryType.Weapon then
				if weapon.DurablePercentValue == 0 then
					weapon.BrokenState = 2
				elseif weapon.DurablePercentValue <= self.durabilityLowPoint then
					weapon.BrokenState = 1
				end
			end

			self.bindData.weaponList:RefreshElement(i - 1)

			if self.toolTipData and self.toolTipData.InstanceId == weaponId then
				local hideRepair = weapon.DurablePercentValue and weapon.DurablePercentValue == 100
				self.toolTipStore.tipRepairButton.interactable = not hideRepair
				self.toolTipStore.tipRepairButtonPad.interactable = not hideRepair
			end

			break
		end
	end
end

function M:FilterMARenderList()
	table.clear(self.maListForRender)

	local tId = self.selectedCharacterCfg.Id or 0

	for i = 1, #self.maList do
		local data = self.maList[i]

		if self:CheckMASuitableForChracter(tId, data) and (self.selectedTabIndex == 1 or self.currFightStyleDict[data.Cfg.FightSkillType]) then
			table.insert(self.maListForRender, data)
		end
	end
end

function M:CheckMASuitableForChracter(tid, data)
	if data.FightSkillSpiritId and not table.contains(data.FightSkillSpiritId, tid) then
		return false
	end

	if data.FightSkillTypeSpiritId and not table.contains(data.FightSkillTypeSpiritId, tid) then
		return false
	end

	return true
end

function M:SortRenderMA()
	table.sort(self.maListForRender, self.maSortFunc)
end

function M:RebuildMAView()
	self.bindData.maList:SetSimpleList(#self.maListForRender)
	self.bindData.maList:GoToIndex(0, true)

	self.bindData.EmptyMACtrl = #self.maListForRender == 0 and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:RefreshMA()
	self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_MA)
	self:FilterMARenderList()
	self:RefreshArmoryMAWarning()
	self:SortRenderMA()
	self:RebuildMAView()
end

function M:SetFake(item, cfg, conflict)
	item.fake = true
	item.f_Cfg = cfg
	item.f_State = self.MA_CIRCLE_STATE.DISPLAY
	item.f_SkillType = cfg and cfg.FightSkillType or 0
	item.conflict = conflict
end

function M:ClearFake(item)
	item.fake = false
	item.f_Cfg = nil
	item.f_State = self.MA_CIRCLE_STATE.EMPTY
	item.f_SkillType = 0
	item.conflict = false
end

function M:OnMAEnterDropWidget(index, circleWidget)
	if self.mgr.banOperation then
		return
	end

	if not self.selectedCharacterCfg then
		return
	end

	local charCfg = self.selectedCharacterCfg
	local circleStore = self:GetStoreByWidget(circleWidget)

	if circleStore and circleStore.CRCType == self.CONTENT_TYPE.MA then
		local fromMAItem = self.maListForRender[index]
		local toIndex = gWeaponManager:ConvertSelectIndex(circleStore.CRCIndex, self.currPageIndex)
		local toMACircle = self.characterMAList[toIndex]

		self:LoadMAToCircle(charCfg, fromMAItem, toMACircle)
	end
end

function M:LoadMAToCircle(charCfg, fromMAItem, toMACircle)
	local function cb(result)
		if not self.STATE_OnShowOnce then
			return
		end

		if result == self.MA_RESULT.FAIL then
			self:SetFake(toMACircle, fromMAItem.Cfg, true)

			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < toMACircle.SlotIndex + 1 and endIndex >= toMACircle.SlotIndex + 1 then
				local idx = toMACircle.SlotIndex + 1 - startIndex

				self:OnRenderCircleMAItem(idx, toMACircle)
				self:RefreshMAConflict()
			end
		elseif result == self.MA_RESULT.SUCCESS_SWITCH then
			local r_SkillType = toMACircle.r_SkillType

			self:ClearFake(toMACircle)

			toMACircle.r_Cfg = fromMAItem.Cfg
			toMACircle.r_State = self.MA_CIRCLE_STATE.DISPLAY
			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < toMACircle.SlotIndex + 1 and endIndex >= toMACircle.SlotIndex + 1 then
				local idx = toMACircle.SlotIndex + 1 - startIndex

				self:OnRenderCircleMAItem(idx, toMACircle)
			end

			if r_SkillType > 0 then
				for i = 1, #self.characterMAList do
					local maInfo = self.characterMAList[i]

					if maInfo ~= toMACircle and maInfo.r_SkillType == r_SkillType then
						maInfo.r_Cfg = fromMAItem.Cfg
						maInfo.r_State = self.MA_CIRCLE_STATE.DISPLAY

						if startIndex < i and i <= endIndex then
							local idx = i - startIndex

							self:OnRenderCircleMAItem(idx, maInfo)
						end
					end
				end
			end

			self:RefreshMAConflict()
		elseif result == self.MA_RESULT.SUCCESS_EMPTY then
			self:SetFake(toMACircle, fromMAItem.Cfg, false)

			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < toMACircle.SlotIndex + 1 and endIndex >= toMACircle.SlotIndex + 1 then
				local idx = toMACircle.SlotIndex + 1 - startIndex

				self:OnRenderCircleMAItem(idx, toMACircle)
				self:RefreshMAConflict()
			end
		end

		self:RefreshCurrSelectTooltip()
		self:RefreshCurrSelectCircle()

		if self.currContentType == self.CONTENT_TYPE.WEAPON then
			self:RefreshArmoryWeaponWarning()
			self.bindData.tabList:RefreshList()
			self.bindData.weaponList:RefreshList()
		elseif self.currContentType == self.CONTENT_TYPE.MA then
			self:RefreshArmoryMAWarning()
			self.bindData.tabList:RefreshList()
			self.bindData.maList:RefreshList()
		end
	end

	if toMACircle.r_State == self.MA_CIRCLE_STATE.FIXED then
		cb(self.MA_RESULT.FAIL)
	elseif toMACircle.r_State == self.MA_CIRCLE_STATE.EMPTY then
		cb(self.MA_RESULT.SUCCESS_EMPTY)
	elseif toMACircle.r_SkillType ~= fromMAItem.Cfg.FightSkillType then
		cb(self.MA_RESULT.FAIL)
	else
		self.mgr:AskSwitchFightStyle(charCfg.Id, toMACircle.r_SkillType, fromMAItem.Cfg.Id, cb, self.MA_RESULT.SUCCESS_SWITCH, self.MA_RESULT.FAIL)
	end
end

function M:OnCharacterSelect(index)
	if self.selectedCharacterIndex == index then
		return 0
	end

	local data = self.characterList[index]

	if data then
		self.selectedCharacterIndex = index
		self.selectedCharacterCfg = data.cfg
		self.bindData.trHeadIconId = data.cfg and data.cfg.SHeadIconID
		local charData = self:GetCharacterData(data.cfg.Id)

		if charData then
			self.bindData.ShowBattleInfoCtrl = self.CONTROL.TRUE
			self.bindData.trAtkValue = math.floor(charData.Dam)
			self.bindData.trHpValue = math.floor(charData.MaxHp)
			self.bindData.trDefValue = math.floor(charData.DefDeduct)
		else
			self.bindData.ShowBattleInfoCtrl = self.CONTROL.FALSE
		end

		local idx = self:RefreshCharacterWeapons()

		return idx
	end

	return 0
end

function M:RefreshCharacterWeapons()
	local cfg = self.selectedCharacterCfg
	local weaponSlots = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[cfg.Id]

	if not weaponSlots then
		print_error("没有角色的轮盘武器数据，角色ID=", cfg.Id)
	end

	local currIndex = 0

	for i = 1, weaponSlots.Count do
		if weaponSlots[i] then
			local info = self:ProcessSpiritWeapon(cfg, weaponSlots[i], i - 1, self.characterWeaponList[i])
			info.Empty = false

			if i <= 2 then
				info.IsPrivate = true
				info.DurablePercent = ""
			else
				info.IsPrivate = false
			end

			if info.Using then
				currIndex = i
			end

			self:ProcessWeaponMA(info.Cfg, i - 1, self.characterMAList[i], info)
		else
			local info = self.characterWeaponList[i]

			table.clear(info)
			self:AddEquipInfo(info, cfg, i - 1)

			info.Empty = true

			if i <= 2 then
				info.IsPrivate = true
			end

			self:ProcessWeaponMA(nil, i - 1, self.characterMAList[i])
		end
	end

	return currIndex
end

function M:AutoSwitchPage(idx)
	for i = 1, #self.characterWeaponList do
		local item = self.characterWeaponList[i]

		if item and not item.Empty and self.guideInstanceDict[item.InstanceId] then
			idx = i

			break
		end
	end

	if idx > 0 then
		local btnIdx = idx

		if idx > 8 then
			self:OnCirclePage2Click(true)

			btnIdx = idx - 8
		else
			self:OnCirclePage1Click(true)
		end
	else
		self:OnCirclePage1Click(true)
	end
end

function M:RebuildCircleWeaponView()
	local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

	for i = 1, self.MAX_SLOT_COUNT do
		local idx = i + startIndex

		if endIndex >= idx then
			local item = self.characterWeaponList[idx]

			self:OnRenderCircleWeaponItem(i, item)
		else
			self:OnRenderCircleWeaponItem(i)
		end
	end
end

function M:OnRenderCircleWeaponItem(index, item)
	if item and not item.Empty then
		self.circleWeaponBtnStore[index].weaponIcon = item.Cfg.SWeaponWheelsIconId
		self.circleWeaponBtnStore[index].durability = item.DurablePercent
		self.circleWeaponBtnStore[index].QualityCtrl = item.Quality
		self.circleWeaponBtnStore[index].IsEmptyCtrl = self.CONTROL.FALSE
		self.circleWeaponBtnStore[index].TypeCtrl = item.IsTask and self.CONTROL.TRUE or self.CONTROL.FALSE
		local canChange = self.currShowMode == self.SHOW_MODE.CONTENT and not item.IsPrivate and not item.IsTask and not item.CantDiscard
		self.circleWeaponBtnStore[index].draggable = canChange
		self.circleWeaponBtnStore[index].dropable = canChange
		self.circleWeaponBtnStore[index].dragActionHover = canChange
		self.circleWeaponBtnStore[index].redKey = item.RedDot > 0 and "weapon." .. item.InstanceId or ""
		self.circleWeaponBtnStore[index].guideID = self.guideInstanceDict[item.InstanceId] and item.GuideId or ""
		self.circleWeaponBtnStore[index].UsingCtrl = item.Using and self.CONTROL.TRUE or self.CONTROL.FALSE
		self.circleWeaponBtnStore[index].BrokenCtrl = item.BrokenState
	else
		self.circleWeaponBtnStore[index].IsEmptyCtrl = self.CONTROL.TRUE
		self.circleWeaponBtnStore[index].draggable = false
		self.circleWeaponBtnStore[index].dropable = true
		self.circleWeaponBtnStore[index].dragActionHover = true
		self.circleWeaponBtnStore[index].QualityCtrl = 0
		self.circleWeaponBtnStore[index].redKey = ""
		self.circleWeaponBtnStore[index].guideID = ""
		self.circleWeaponBtnStore[index].UsingCtrl = self.CONTROL.FALSE
		self.circleWeaponBtnStore[index].BrokenCtrl = 0
	end
end

function M:RefreshCircleInteract()
	local interactable = self.currShowMode == self.SHOW_MODE.CONTENT

	for i = 1, self.MAX_SLOT_COUNT do
		self.circleWeaponBtnStore[i].interactable = interactable
		self.circleMABtnStore[i].interactable = interactable
	end
end

function M:OnSpiritWeaponSlotAdd(eventId, addInfo)
	local instId = addInfo.Weapon.InstanceId

	if self.OP_Add_To_Circle[instId] then
		self.OP_Add_To_Circle[instId] = nil
	else
		self:HandleCircleWeaponAdd(addInfo)
	end
end

function M:DeleteCircleWeapon(index, tabType)
	if self.currShowMode == self.SHOW_MODE.CONTENT and index > 0 then
		local idx = gWeaponManager:ConvertSelectIndex(index, tabType or self.currPageIndex)
		local item = self.characterWeaponList[idx]

		if item and not item.Empty and not item.IsPrivate and not item.CantDiscard then
			local instId = item.InstanceId

			gClientToGameSceneDelegate:AskDiscardWeaponByInstanceId(item.InstanceId, self.selectedCharacterCfg.Id, true).Callback = function (err)
				if err == MessageConfig.Ok then
					self:HandleCircleWeaponDelete(instId)
				end
			end
		end
	end
end

function M:HandleCircleWeaponDelete(instId)
	local removeIndex = -1

	for i = 1, #self.weaponListForRender do
		local weapon = self.weaponListForRender[i]

		if weapon.InstanceId == instId then
			table.remove(self.weaponListForRender, i)

			removeIndex = i

			if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON and self.currSelectIndexTooltip == i then
				self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
			end

			break
		end
	end

	for i = 1, #self.characterWeaponList do
		local weapon = self.characterWeaponList[i]

		if weapon and not weapon.Empty and weapon.InstanceId == instId then
			table.clear(weapon)
			self:AddEquipInfo(weapon, self.selectedCharacterCfg, i - 1)

			weapon.Empty = true

			if i <= 2 then
				weapon.IsPrivate = true
			end

			self:ProcessWeaponMA(nil, i - 1, self.characterMAList[i])

			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < i and i <= endIndex then
				local idx = i - startIndex

				self:OnRenderCircleWeaponItem(idx)
				self:OnRenderCircleMAItem(idx)

				if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_WEAPON and self.currSelectIndexTooltip == idx then
					self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_WEAPON)
				end

				if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_MA and self.currSelectIndexTooltip == idx then
					self:RemoveCurrSelectTooltip(self.SELECT_MODE.CIRCLE_MA)
				end

				self:RefreshMAConflict()
			end

			break
		end
	end

	if removeIndex > 0 then
		self:RefreshCurrSelectCircle()
		self.bindData.tabList:RefreshList()

		if self.currContentType == self.CONTENT_TYPE.WEAPON then
			self:RefreshArmoryWeaponWarning()
			self:RebuildWeaponView()
		end
	else
		self:RefreshWarningView()
	end
end

function M:HandleCircleWeaponAdd(addInfo)
	local tId = addInfo.TemplateId
	local slotIndex = addInfo.SlotIndex
	local weapon = addInfo.Weapon
	local instId = weapon.InstanceId

	if self.selectedCharacterCfg.Id == tId then
		local circleWeapon = self.characterWeaponList[slotIndex]

		if circleWeapon then
			table.clear(circleWeapon)

			local info = self:ProcessSpiritWeapon(self.selectedCharacterCfg, weapon, slotIndex, circleWeapon)
			info.Empty = false

			if slotIndex < 2 then
				info.IsPrivate = true
				info.DurablePercent = ""
			else
				info.IsPrivate = false
			end

			self:ProcessWeaponMA(info.Cfg, slotIndex, self.characterMAList[slotIndex], info)

			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < slotIndex + 1 and endIndex >= slotIndex + 1 then
				local idx = slotIndex + 1 - startIndex

				self:OnRenderCircleWeaponItem(idx, info)
				self:OnRenderCircleMAItem(idx, self.characterMAList[slotIndex + 1])
				self:RefreshMAConflict()
			end

			if self.currShowMode == self.SHOW_MODE.CONTENT and self.currContentType == self.CONTENT_TYPE.WEAPON then
				if self.gamepadMode then
					table.insert(self.weaponListForRender, circleWeapon)
					self:RebuildWeaponView()

					if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON then
						self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
					end
				elseif self:FilterSingleWeapon(circleWeapon) then
					table.insert(self.weaponListForRender, circleWeapon)
					self:RebuildWeaponView()

					if self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON then
						self:RemoveCurrSelectTooltip(self.SELECT_MODE.ARMORY_WEAPON)
					end
				end
			end
		end
	end
end

function M:SelectCircleWeapon(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleStore["weaponItem" .. index]:SetSelected(true)
	end
end

function M:DeselectCircleWeapon(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleStore["weaponItem" .. index]:SetSelected(false)
	end
end

function M:SelectCircleWeaponBox(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleWeaponBtnStore[index].SelectBoxCtrl = self.CONTROL.TRUE
		local idx = gWeaponManager:ConvertSelectIndex(index, self.currPageIndex)
		self.maBoxCircleItem = self.characterMAList[idx]
		local weapon = self.characterWeaponList[idx]
		self.circleStore.padReturnSingleBtn.interactable = weapon and not weapon.Empty and not weapon.IsTask and not weapon.IsPrivate
		gGFCondition.isSelectWeaponArmoryWeapon = not string.is_null_or_empty(self.circleWeaponBtnStore[index].guidePad.guideID)
	end
end

function M:DeselectCircleWeaponBox(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleWeaponBtnStore[index].SelectBoxCtrl = self.CONTROL.FALSE
		self.maBoxCircleItem = nil
	end
end

function M:OnCircleWeaponEnterDropWidget(index, widget)
	if self.mgr.banOperation then
		return
	end

	if widget == self.bindData.dropBtnArmory then
		self:DropCircleToArmory(index)
	elseif widget == self.bindData.dropBtnCircle then
		self:DeleteCircleWeapon(index, self.dragPage)
	elseif self.selectedCharacterCfg then
		local circleStore = self:GetStoreByWidget(widget)

		if circleStore then
			self:DropCircleSwitchByIndex(index, circleStore.CRCIndex)
		end
	end
end

function M:DropCircleToArmory(fromIndex)
	if self.selectedCharacterCfg then
		local fromIdx = gWeaponManager:ConvertSelectIndex(fromIndex, self.currPageIndex)
		local item = self.characterWeaponList[fromIdx]
		local char = self.selectedCharacterCfg.Id

		if item and not item.Empty and not item.IsPrivate and not item.IsTask then
			local id = item.InstanceId
			self.OP_Add_To_Armory[id] = true

			self.mgr:AskDepositSpiritWeapon(char, item.SlotIndex, function (success)
				if not self.STATE_OnShowOnce then
					self.OP_Add_To_Armory[id] = false

					return
				end

				if success then
					self:HandleCircleToArmory(item)
				else
					self.OP_Add_To_Armory[id] = false
				end
			end)
		end
	end
end

function M:DropCircleSwitchByIndex(fromIndex, toIndex)
	local fromIdx = gWeaponManager:ConvertSelectIndex(fromIndex, self.dragPage)
	local toIdx = gWeaponManager:ConvertSelectIndex(toIndex, self.currPageIndex)

	if fromIdx == toIdx then
		return
	end

	local fromItem = self.characterWeaponList[fromIdx]
	local toItem = self.characterWeaponList[toIdx]

	if fromItem and toItem then
		self:DropCircleSwitchByItem(fromItem, toItem)
	end
end

function M:DropCircleSwitchByItem(fromItem, toItem)
	if fromItem.SlotIndex == toItem.SlotIndex then
		return
	end

	local fId = fromItem.InstanceId
	local tId = toItem.InstanceId
	self.OP_Add_To_Circle[fId] = true

	if tId then
		self.OP_Add_To_Circle[tId] = true
	end

	self.mgr:AskExchangeWeaponSlot(toItem.BelongSpirit, fromItem, toItem, function (success)
		if not self.STATE_OnShowOnce then
			self.OP_Add_To_Circle[fId] = false

			if tId then
				self.OP_Add_To_Circle[tId] = false
			end

			return
		end

		if success then
			self:Swap(fromItem, toItem, "SlotIndex")

			self.characterWeaponList[fromItem.SlotIndex + 1] = fromItem
			self.characterWeaponList[toItem.SlotIndex + 1] = toItem

			self:RebuildCircleWeaponView()
			self:ProcessWeaponMA(fromItem.Cfg, fromItem.SlotIndex, self.characterMAList[fromItem.SlotIndex + 1], fromItem)
			self:ProcessWeaponMA(toItem.Cfg, toItem.SlotIndex, self.characterMAList[toItem.SlotIndex + 1], toItem)
			self:RebuildCircleMAView()
			self:RefreshWarningView()
		else
			self.OP_Add_To_Circle[fId] = false

			if tId then
				self.OP_Add_To_Circle[tId] = false
			end
		end
	end)
end

function M:Swap(a, b, key)
	local temp = a[key]
	a[key] = b[key]
	b[key] = temp
end

function M:RebuildCircleMAView()
	local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

	for i = 1, self.MAX_SLOT_COUNT do
		local idx = i + startIndex

		if endIndex >= idx then
			local item = self.characterMAList[idx]

			self:OnRenderCircleMAItem(i, item)
		else
			self:OnRenderCircleMAItem(i)
		end
	end

	self:RefreshMAConflict()
end

function M:OnRenderCircleMAItem(index, item)
	if item then
		if item.fake then
			self.circleMABtnStore[index].StateCtrl = item.f_State
			self.circleMABtnStore[index].maIcon = item.f_State == self.MA_CIRCLE_STATE.DISPLAY and item.f_Cfg.IconId or 0
			self.circleMABtnStore[index].QualityCtrl = item.f_State == self.MA_CIRCLE_STATE.DISPLAY and item.f_Cfg.Quality or 0
		else
			self.circleMABtnStore[index].StateCtrl = item.r_State
			self.circleMABtnStore[index].maIcon = item.r_State == self.MA_CIRCLE_STATE.DISPLAY and item.r_Cfg.IconId or 0
			self.circleMABtnStore[index].QualityCtrl = item.r_State == self.MA_CIRCLE_STATE.DISPLAY and item.r_Cfg.Quality or 0
		end

		local guide = self.guideMAInstanceDict[item.InstanceId] and item.MAGuideId or ""
		self.circleMABtnStore[index].guideID = guide

		if not string.is_null_or_empty(guide) then
			guide = guide .. "_PAD"
		end

		self.circleMABtnStore[index].guideIDPad = guide
	else
		self.circleMABtnStore[index].maIcon = 0
		self.circleMABtnStore[index].guideID = ""
		self.circleMABtnStore[index].guideIDPad = ""
		self.circleMABtnStore[index].QualityCtrl = 0
	end

	self.circleMABtnStore[index].dragActionHover = self.currContentType == self.CONTENT_TYPE.MA
	self.circleMABtnStore[index].WarningCtrl = item and item.conflict and self.CONTROL.TRUE or self.CONTROL.FALSE
	self.circleWeaponBtnStore[index].WarningCtrl = item and item.conflict and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:RefreshMAConflict(force)
	local conflict = false

	for i = 1, self.MAX_SLOT_COUNT do
		if self.circleMABtnStore[i].WarningCtrl and self.circleMABtnStore[i].WarningCtrl == self.CONTROL.TRUE then
			conflict = true

			break
		end
	end

	self.circleStore.WarningCtrl = conflict and self.CONTROL.TRUE or self.CONTROL.FALSE
end

function M:SelectCircleMA(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleStore["maItem" .. index]:SetSelected(true)
	end
end

function M:DeselectCircleMA(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleStore["maItem" .. index]:SetSelected(false)
	end
end

function M:SelectCircleMABox(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleMABtnStore[index].SelectBoxCtrl = self.CONTROL.TRUE
		local idx = gWeaponManager:ConvertSelectIndex(index, self.currPageIndex)
		self.maBoxCircleItem = self.characterMAList[idx]
		gGFCondition.isSelectWeaponArmoryMA = not string.is_null_or_empty(self.circleMABtnStore[index].guideID)
	end
end

function M:DeselectCircleMABox(index)
	if index > 0 and index <= self.MAX_SLOT_COUNT then
		self.circleMABtnStore[index].SelectBoxCtrl = self.CONTROL.FALSE
		self.maBoxCircleItem = nil
	end
end

function M:SetToolTipState(source, item)
	self.toolTipData = item

	if self.toolTipSource == source then
		return
	end

	self.toolTipSource = source

	if source == self.SELECT_MODE.NONE then
		self.bindData.ShowToolTipCtrl = self.CONTROL.FALSE
	else
		self.bindData.ShowToolTipCtrl = self.CONTROL.TRUE
	end
end

function M:SetTooltipInfo(mode, index)
	if mode == self.SELECT_MODE.CIRCLE_WEAPON then
		local idx = gWeaponManager:ConvertSelectIndex(index, self.currPageIndex)
		local item = self.characterWeaponList[idx]

		if item and not item.Empty then
			self:SetToolTipState(self.SELECT_MODE.CIRCLE_WEAPON, item)

			local canChange = self.currShowMode == self.SHOW_MODE.CONTENT and not item.IsPrivate and not item.IsTask
			self.toolTipStore.tipModeButton.interactable = canChange
			self.toolTipStore.tipModeButtonPad.interactable = canChange
			self.toolTipStore.btnModeDisplayNameCtrl = self.TIP_NAME_DISPLAY.BACK
			self.toolTipStore.BtnModeEnableCtrl = self.CONTROL.TRUE
			self.toolTipStore.tipWeaponName = item.Cfg.Name or ""
			self.toolTipStore.tipQualityCtrl = item.Quality

			if item.CategoryType == CategoryType.Weapon then
				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.WEAPON
				self.toolTipStore.tipSixDimName = item.SixDimName or ""
				self.toolTipStore.tipSixDimIcon = item.SixDimIcon

				table.clear(self.toolTipRenderData)

				for i = 1, #item.tags do
					table.insert(self.toolTipRenderData, item.tags[i])
				end

				self.toolTipStore.tipTagList:SetSimpleList(#self.toolTipRenderData)
				self:SetSkillAndRadarChartInfo(item)

				self.toolTipStore.weaponMADescription = item.Cfg.WeaponBuffDescription or ""
			else
				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.ITEM
				self.toolTipStore.tipSkillDescription = item.Cfg.Description or ""
			end

			local hideRepair = item.DurablePercentValue and item.DurablePercentValue == 100
			self.toolTipStore.tipRepairButton.interactable = not hideRepair
			self.toolTipStore.tipRepairButtonPad.interactable = not hideRepair

			if item.ShowRedDot then
				self:ClearRedDotCircle(item)
			end
		else
			self:SetToolTipState(self.SELECT_MODE.NONE)
			table.clear(self.toolTipRenderData)
		end
	elseif mode == self.SELECT_MODE.ARMORY_WEAPON then
		local item = self.weaponListForRender[index]

		if item then
			self:SetToolTipState(self.SELECT_MODE.ARMORY_WEAPON, item)

			if item.Equipped == 1 then
				if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
					local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
					local weapon = self.characterWeaponList[idx]

					if weapon and (weapon.Empty or weapon.InstanceId ~= item.InstanceId) then
						self.toolTipStore.btnModeDisplayNameCtrl = self.TIP_NAME_DISPLAY.EXCHANGE
						local change = not weapon.IsTask and not weapon.IsPrivate and not item.IsPrivate and not item.IsTask
						self.toolTipStore.tipModeButton.interactable = change
						self.toolTipStore.tipModeButtonPad.interactable = change
						self.toolTipStore.BtnModeEnableCtrl = self.CONTROL.TRUE
					else
						self.toolTipStore.BtnModeEnableCtrl = self.CONTROL.FALSE
					end
				else
					self.toolTipStore.BtnModeEnableCtrl = self.CONTROL.FALSE
				end
			else
				if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
					local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
					local weapon = self.characterWeaponList[idx]

					if weapon and weapon.Empty then
						self.toolTipStore.btnModeDisplayNameCtrl = self.TIP_NAME_DISPLAY.EQUIP
						local change = not weapon.IsTask and not weapon.IsPrivate
						self.toolTipStore.tipModeButton.interactable = change
						self.toolTipStore.tipModeButtonPad.interactable = change
					elseif weapon and not weapon.Empty then
						self.toolTipStore.btnModeDisplayNameCtrl = self.TIP_NAME_DISPLAY.EXCHANGE
						local change = not weapon.IsTask and not weapon.IsPrivate
						self.toolTipStore.tipModeButton.interactable = change
						self.toolTipStore.tipModeButtonPad.interactable = change
					end
				else
					local canEquip = false

					for i = 1, 16 do
						local weapon = self.characterWeaponList[i]

						if not weapon or weapon.Empty and not weapon.IsPrivate then
							canEquip = true

							break
						end
					end

					self.toolTipStore.btnModeDisplayNameCtrl = self.TIP_NAME_DISPLAY.AUTO_EQUIP
					self.toolTipStore.tipModeButton.interactable = canEquip
					self.toolTipStore.tipModeButtonPad.interactable = canEquip
				end

				self.toolTipStore.BtnModeEnableCtrl = self.CONTROL.TRUE
			end

			self.toolTipStore.tipQualityCtrl = item.Quality
			self.toolTipStore.tipWeaponName = item.Cfg.Name

			if item.CategoryType == CategoryType.Weapon then
				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.WEAPON
				self.toolTipStore.tipSixDimName = item.SixDimName
				self.toolTipStore.tipSixDimIcon = item.SixDimIcon

				table.clear(self.toolTipRenderData)

				for i = 1, #item.tags do
					table.insert(self.toolTipRenderData, item.tags[i])
				end

				self.toolTipStore.tipTagList:SetSimpleList(#self.toolTipRenderData)
				self:SetSkillAndRadarChartInfo(item)

				self.toolTipStore.weaponMADescription = item.Cfg.WeaponBuffDescription or ""
			else
				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.ITEM
				self.toolTipStore.tipSkillDescription = item.Cfg.Description or ""
			end

			local hideRepair = item.DurablePercentValue and item.DurablePercentValue == 100
			self.toolTipStore.tipRepairButton.interactable = not hideRepair
			self.toolTipStore.tipRepairButtonPad.interactable = not hideRepair
			local canDelete = item and not item.Empty and not item.IsPrivate and not item.CantDiscard
			self.toolTipStore.tipDeleteButton.interactable = canDelete

			if item.ShowRedDot then
				self:ClearRedDotArmory(item)
			end
		else
			self:SetToolTipState(self.SELECT_MODE.NONE)
			table.clear(self.toolTipRenderData)

			self.toolTipStore.tipDeleteButton.interactable = false
		end
	elseif mode == self.SELECT_MODE.CIRCLE_MA then
		local idx = gWeaponManager:ConvertSelectIndex(index, self.currPageIndex)
		local item = self.characterMAList[idx]

		if item then
			if not item.fake and item.r_State == self.MA_CIRCLE_STATE.DISPLAY then
				self:SetToolTipState(self.SELECT_MODE.CIRCLE_MA, item)

				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.MA
				self.toolTipStore.BtnMASwitchEnableCtrl = self.CONTROL.FALSE
				self.toolTipStore.tipWeaponName = item.r_Cfg.Name or ""
				self.toolTipStore.tipQualityCtrl = item.r_Cfg.Quality or 0
				self.toolTipStore.tipMAFsTag = item.r_Cfg.Tag or ""
				local rCfg = gWeaponManager:GetFightSkillStyleCfg(item.r_Cfg.Id)
				self.toolTipStore.tipMAFsType = rCfg and rCfg.Name or ""
				self.toolTipStore.tipMAFsDescription = item.r_Cfg.Description or ""
			elseif item.fake and item.f_State == self.MA_CIRCLE_STATE.DISPLAY then
				self:SetToolTipState(self.SELECT_MODE.CIRCLE_MA, item)

				self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.MA
				self.toolTipStore.BtnMASwitchEnableCtrl = self.CONTROL.FALSE
				self.toolTipStore.tipWeaponName = item.f_Cfg.Name or ""
				self.toolTipStore.tipQualityCtrl = item.f_Cfg.Quality or 0
				self.toolTipStore.tipMAFsTag = item.f_Cfg.Tag or ""
				local fCfg = gWeaponManager:GetFightSkillStyleCfg(item.f_Cfg.Id)
				self.toolTipStore.tipMAFsType = fCfg and fCfg.Name or ""
				self.toolTipStore.tipMAFsDescription = item.f_Cfg.Description or ""
			else
				self:SetToolTipState(self.SELECT_MODE.NONE)
				table.clear(self.toolTipRenderData)
			end
		else
			self:SetToolTipState(self.SELECT_MODE.NONE)
			table.clear(self.toolTipRenderData)
		end
	elseif mode == self.SELECT_MODE.ARMORY_MA then
		local item = self.maListForRender[index]

		if item then
			self:SetToolTipState(self.SELECT_MODE.ARMORY_MA, item)

			self.toolTipStore.TipShowModeCtrl = self.TIP_SHOW_MODE.MA

			if self.currSelectModeCircle == self.CONTENT_TYPE.MA then
				self.toolTipStore.BtnMASwitchEnableCtrl = self.CONTROL.TRUE
				local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCircle, self.currPageIndex)
				local ma = self.characterMAList[idx]

				if ma and ma.fake and ma.f_State == self.MA_CIRCLE_STATE.EMPTY or ma.r_State == self.MA_CIRCLE_STATE.EMPTY then
					self.toolTipStore.btnMASwitchDisplayNameCtrl = self.TIP_NAME_DISPLAY.EQUIP
					self.toolTipStore.tipMASwitchButton.interactable = true
					self.toolTipStore.tipMASwitchButtonPad.interactable = true
				else
					self.toolTipStore.btnMASwitchDisplayNameCtrl = self.TIP_NAME_DISPLAY.EXCHANGE
					local cfg = ma.fake and ma.f_Cfg or ma.r_Cfg
					local skillId = cfg and cfg.Id or 0
					local skillBanInteract = false

					if skillId > 0 and skillId == item.Id then
						skillBanInteract = true
					end

					self.toolTipStore.tipMASwitchButton.interactable = not skillBanInteract and ma.r_State ~= self.MA_CIRCLE_STATE.FIXED
					self.toolTipStore.tipMASwitchButtonPad.interactable = not skillBanInteract and ma.r_State ~= self.MA_CIRCLE_STATE.FIXED
				end
			else
				self.toolTipStore.BtnMASwitchEnableCtrl = self.CONTROL.FALSE
			end

			self.toolTipStore.tipWeaponName = item.Name or ""
			self.toolTipStore.tipQualityCtrl = item.Quality or 0
			self.toolTipStore.tipMAFsTag = item.Cfg.Tag or ""
			local cfg = gWeaponManager:GetFightSkillStyleCfg(item.Id)
			self.toolTipStore.tipMAFsType = cfg and cfg.Name or ""
			self.toolTipStore.tipMAFsDescription = item.Cfg.Description or ""
		else
			self:SetToolTipState(self.SELECT_MODE.NONE)
			table.clear(self.toolTipRenderData)
		end
	else
		self:SetToolTipState(self.SELECT_MODE.NONE)
		table.clear(self.toolTipRenderData)
	end
end

function M:SetSkillAndRadarChartInfo(item)
	local cfg = item.Cfg
	local fill = 0
	local text = ""
	fill = Mathf.Clamp01((cfg.AttackPower or 0) / WeaponConfig.MaxWeaponAttackPower) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(0, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(0, text)

	fill = Mathf.Clamp01((cfg.AttackRange or 0) / WeaponConfig.MaxWeaponAttackRange) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(1, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(1, text)

	fill = Mathf.Clamp01(cfg.AttackSpeed / WeaponConfig.MaxWeaponAttackSpeed) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(2, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(2, text)

	fill = Mathf.Clamp01((cfg.PoiseAbility or 0) / WeaponConfig.MaxWeaponPoiseAbility) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(3, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(3, text)

	fill = Mathf.Clamp01(cfg.ImpactForce / WeaponConfig.MaxWeaponImpactForce) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(4, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(4, text)

	if cfg.Durability <= 0 then
		fill = 100
	elseif cfg.ShootId and cfg.ShootId > 0 then
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxGunDurability) * 100
	else
		fill = Mathf.Clamp01(cfg.Durability / WeaponConfig.MaxWeaponDurability) * 100
	end

	text = gWeaponManager:GetWeaponAttrRank(fill)

	self.toolTipStore.tipRadarChat:SetVertexValue(5, fill)
	self.toolTipStore.tipRadarChat:SetVertexRankText(5, text)
end

function M:ClearRedDotCircle(item)
	item.RedDot = 0
	item.ShowRedDot = false

	SGUI.RedDotMgr.LuaSetRedDot(false, "weapon." .. item.InstanceId)

	local weaponSlots = gPlayerManager.infoSpirit.bindData.SpiritWeaponSlotDict[self.selectedCharacterCfg.Id]

	if weaponSlots then
		for i = 1, weaponSlots.Count do
			if weaponSlots[i] and weaponSlots[i].InstanceId == item.InstanceId then
				weaponSlots[i].WeaponFlags.ShowRedDot = false

				break
			end
		end
	end

	gWeaponManager:ClearWeaponRedDot(item.InstanceId)
end

function M:ClearRedDotArmory(item)
	item.RedDot = 0
	item.ShowRedDot = false

	SGUI.RedDotMgr.LuaSetRedDot(false, "weapon." .. item.InstanceId)

	local ArmoryWeapons = gPlayerManager.infoSpirit.bindData.ArmoryWeapons

	for _, weapon in pairs(ArmoryWeapons) do
		if item.InstanceId == weapon.InstanceId then
			weapon.WeaponFlags.ShowRedDot = false

			break
		end
	end

	gWeaponManager:ClearWeaponRedDot(item.InstanceId)
end

function M:InitGuideInfo()
	self.guideItemDict = {}
	self.guideInstanceDict = {}

	for i = 1, #self.characterWeaponList do
		local item = self.characterWeaponList[i]

		if item and not item.Empty and item.GuideId then
			self:UpdateGuideItem(item, true)
		end
	end

	for i = 1, #self.weaponList do
		local item = self.weaponList[i]

		if item and item.GuideId then
			self:UpdateGuideItem(item, false)
		end
	end

	for k, v in pairs(self.guideItemDict) do
		self.guideInstanceDict[v.InstanceId] = true
	end

	self.guideItemDict = nil
	self.guideMAItemDict = {}
	self.guideMAInstanceDict = {}

	for i = 1, #self.characterMAList do
		local item = self.characterMAList[i]

		if item then
			self:UpdateMAGuideItem(item, true)
		end
	end

	for k, v in pairs(self.guideMAItemDict) do
		self.guideMAInstanceDict[v] = true
	end

	self.guideMAItemDict = nil
end

function M:UpdateGuideItem(item, isCircle)
	if not self.guideItemDict[item.TemplateId] then
		local data = {
			IsFull = item.DurablePercentValue == 100,
			InstanceId = item.InstanceId,
			IsCircle = isCircle
		}
		data.Find = not data.IsFull and data.IsCircle
		self.guideItemDict[item.TemplateId] = data
	else
		local data = self.guideItemDict[item.TemplateId]

		if data.Find then
			return
		end

		if data.IsFull and item.DurablePercentValue < 100 or not data.IsCircle and isCircle then
			data.IsFull = item.DurablePercentValue == 100
			data.InstanceId = item.InstanceId
			data.IsCircle = isCircle
			data.Find = not data.IsFull and data.IsCircle
		end
	end
end

function M:UpdateMAGuideItem(item, isCircle)
	if item.TemplateId and not self.guideMAItemDict[item.TemplateId] then
		self.guideMAItemDict[item.TemplateId] = item.InstanceId
	end
end

function M:SetCurrSelectTooltip(mode, index, force)
	if self.currSelectModeTooltip == mode and self.currSelectIndexTooltip == index and not force then
		return
	end

	if self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_WEAPON then
		self:DeselectCircleWeapon(self.currSelectIndexTooltip)
	elseif self.currSelectModeTooltip == self.SELECT_MODE.CIRCLE_MA then
		self:DeselectCircleMA(self.currSelectIndexTooltip)
	elseif self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_WEAPON then
		if self.currSelectModeTooltip ~= mode then
			self.bindData.weaponList:DeselectAll(false)
		end
	elseif self.currSelectModeTooltip == self.SELECT_MODE.ARMORY_MA and self.currSelectModeTooltip ~= mode then
		self.bindData.maList:DeselectAll(false)
	end

	self.currSelectModeTooltip = mode
	self.currSelectIndexTooltip = index

	if mode == self.SELECT_MODE.CIRCLE_WEAPON then
		self:SelectCircleWeapon(index)
		self:SwitchContentType(self.CONTENT_TYPE.WEAPON)
		self:SetTooltipInfo(mode, index)
	elseif mode == self.SELECT_MODE.CIRCLE_MA then
		local idx = gWeaponManager:ConvertSelectIndex(index, self.currPageIndex)
		local maInfo = self.characterMAList[idx]

		self:SelectCircleMA(index)
		self:SwitchContentType(self.CONTENT_TYPE.MA)
		self:SetTooltipInfo(mode, index)
	elseif mode == self.SELECT_MODE.ARMORY_WEAPON then
		self:SetTooltipInfo(mode, index)
	elseif mode == self.SELECT_MODE.ARMORY_MA then
		self:SetTooltipInfo(mode, index)
	else
		self:SetTooltipInfo(self.SELECT_MODE.NONE)
	end
end

function M:RemoveCurrSelectTooltip(mode)
	if self.currSelectModeTooltip == mode then
		if mode == self.SELECT_MODE.ARMORY_WEAPON then
			self.bindData.weaponList:DeselectAll(false)
		elseif mode == self.SELECT_MODE.ARMORY_MA then
			self.bindData.maList:DeselectAll(false)
		elseif mode == self.SELECT_MODE.CIRCLE_WEAPON then
			self:DeselectCircleWeapon(self.currSelectIndexTooltip)
		elseif mode == self.SELECT_MODE.CIRCLE_MA then
			self:DeselectCircleMA(self.currSelectIndexTooltip)
		end

		self.currSelectModeTooltip = self.SELECT_MODE.NONE
		self.currSelectIndexTooltip = 0

		self:SetTooltipInfo(self.SELECT_MODE.NONE)
	end
end

function M:ClearCurrSelectTooltip()
	self:RemoveCurrSelectTooltip(self.currSelectModeTooltip)
end

function M:RefreshCurrSelectTooltip()
	self:SetTooltipInfo(self.currSelectModeTooltip, self.currSelectIndexTooltip)
end

function M:RefreshCurrSelectCircle()
	if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
		self:SelectCircleWeaponBox(self.currSelectIndexCircle)
	elseif self.currSelectModeCircle == self.CONTENT_TYPE.MA then
		self:SelectCircleMABox(self.currSelectIndexCircle)
	end
end

function M:SetCurrSelectCircle(mode, index)
	if self.currSelectModeCircle == mode and self.currSelectIndexCircle == index then
		return
	end

	if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
		self:DeselectCircleWeaponBox(self.currSelectIndexCircle)
	elseif self.currSelectModeCircle == self.CONTENT_TYPE.MA then
		self:DeselectCircleMABox(self.currSelectIndexCircle)
	end

	self.currSelectModeCircle = mode
	self.currSelectIndexCircle = index

	if mode == self.CONTENT_TYPE.WEAPON then
		self:SelectCircleWeaponBox(index)
	elseif mode == self.CONTENT_TYPE.MA then
		self:SelectCircleMABox(index)
	end
end

function M:RemoveCurrSelectCircle(mode)
	if self.currSelectModeCircle == mode then
		if self.currSelectModeCircle == self.CONTENT_TYPE.WEAPON then
			self:DeselectCircleWeaponBox(self.currSelectIndexCircle)
		elseif self.currSelectModeCircle == self.CONTENT_TYPE.MA then
			self:DeselectCircleMABox(self.currSelectIndexCircle)
		end

		self.currSelectModeCircle = self.CONTENT_TYPE.NONE
		self.currSelectIndexCircle = 0
	end
end

function M:ClearCurrSelectCircle()
	self:RemoveCurrSelectCircle(self.currSelectModeCircle)
end

function M:SwitchCurrentSelectCircle(mode)
	if self.currSelectModeCircle ~= self.CONTENT_TYPE.NONE and self.currSelectModeCircle ~= mode then
		self:SetCurrSelectCircle(mode, self.currSelectIndexCircle)
	end
end

function M:SwitchContentType(toType)
	if self.currContentType ~= toType then
		self.currContentType = toType
		self.bindData.ContentTypeCtrl = toType
		self.circleStore.MAShowCtrl = toType

		if toType == self.CONTENT_TYPE.WEAPON then
			self:RefreshWeapon()
			gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, "S_Vx_WeaponArmoryMainPanel_MAswitch")
		elseif toType == self.CONTENT_TYPE.MA then
			self:RefreshMA()
			gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, "S_Vx_WeaponArmoryMainPanel_MAswitch")
		end
	elseif toType == self.CONTENT_TYPE.WEAPON then
		self:RefreshWeaponView()
	elseif toType == self.CONTENT_TYPE.MA then
		self:RefreshMAView()
	end
end

function M:OnSwitchTriggerBtnPress()
	self.switchTriggerPressed = true
	self.bindData.L2TriggerCtrl = self.CONTROL.TRUE
end

function M:OnSwitchTriggerBtnRelease()
	self.switchTriggerPressed = false
	self.bindData.L2TriggerCtrl = self.CONTROL.FALSE

	if self.currSelectIndexCirclePad > 0 and self.currSelectIndexCirclePad <= self.MAX_SLOT_COUNT then
		local idx = gWeaponManager:ConvertSelectIndex(self.currSelectIndexCirclePad, self.currPageIndex)

		if self.currContentType == self.CONTENT_TYPE.WEAPON then
			local circleItem = self.characterWeaponList[idx]

			if circleItem and not circleItem.Empty and (circleItem.IsPrivate or circleItem.IsTask or circleItem.CantDiscard) then
				self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
				self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

				self.currSelectIndexCirclePad = 0

				return
			end

			if self.mgr.banOperation then
				self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
				self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

				self.currSelectIndexCirclePad = 0

				return
			end

			if self.toolTipData and circleItem then
				local charCfg = self.selectedCharacterCfg

				self:LoadWeaponToCircle(charCfg, self.toolTipData, circleItem)
			end

			self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
			self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

			self.currSelectIndexCirclePad = 0
		else
			if self.mgr.banOperation then
				self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
				self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

				self.currSelectIndexCirclePad = 0

				return
			end

			if not self.selectedCharacterCfg then
				self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
				self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

				self.currSelectIndexCirclePad = 0

				return
			end

			local charCfg = self.selectedCharacterCfg

			if self.toolTipData then
				local fromMAItem = self.toolTipData
				local toMACircle = self.characterMAList[idx]

				self:LoadMAToCircle(charCfg, fromMAItem, toMACircle)
			end

			self:DeselectCircleWeaponPad(self.currSelectIndexCirclePad)
			self:DeselectCircleMAPad(self.currSelectIndexCirclePad)

			self.currSelectIndexCirclePad = 0
		end
	end
end

function M:SetShowMode(mode, force)
	if self.currShowMode ~= mode or force then
		self.currShowMode = mode
		self.bindData.ShowModeCtrl = mode
	end
end

function M:OnWeaponOperatorFlagsChange(eventId, data)
	local weaponId = data.weaponId

	for i = 1, #self.characterWeaponList do
		local weapon = self.characterWeaponList[i]

		if weapon and not weapon.Empty and weapon.InstanceId == weaponId then
			weapon.IsTask = gWeaponManager:GetFlag(data.operatorFlags, 2) == 1
			weapon.CantDiscard = gWeaponManager:GetFlag(data.operatorFlags, 1) == 1
			local startIndex, endIndex = self.mgr:GetWeaponIndexRangeByType(self.currPageIndex)

			if startIndex < i and i <= endIndex then
				local idx = i - startIndex
				self.circleWeaponBtnStore[idx].TypeCtrl = weapon.IsTask and self.CONTROL.TRUE or self.CONTROL.FALSE
				local canChange = self.currShowMode == self.SHOW_MODE.CONTENT and not weapon.IsPrivate and not weapon.IsTask and not weapon.CantDiscard
				self.circleWeaponBtnStore[idx].draggable = canChange
				self.circleWeaponBtnStore[idx].dropable = canChange
				self.circleWeaponBtnStore[idx].dragActionHover = canChange
			end

			if self.toolTipData and self.toolTipData.InstanceId == weaponId then
				self:RefreshCurrSelectTooltip()
			end

			return
		end
	end

	for i = 1, #self.weaponList do
		local weapon = self.weaponList[i]

		if weapon.InstanceId == weaponId then
			weapon.IsTask = gWeaponManager:GetFlag(data.operatorFlags, 2) == 1
			weapon.CantDiscard = gWeaponManager:GetFlag(data.operatorFlags, 1) == 1

			break
		end
	end

	for i = 1, #self.weaponListForRender do
		local weapon = self.weaponListForRender[i]

		if weapon.InstanceId == weaponId then
			weapon.IsTask = gWeaponManager:GetFlag(data.operatorFlags, 2) == 1
			weapon.CantDiscard = gWeaponManager:GetFlag(data.operatorFlags, 1) == 1

			if self.toolTipData and self.toolTipData.InstanceId == weaponId then
				self:RefreshCurrSelectTooltip()
			end

			break
		end
	end
end
