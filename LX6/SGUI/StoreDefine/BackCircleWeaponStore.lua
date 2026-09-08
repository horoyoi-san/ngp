-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleWeaponStore.lua
-- Decompiled from: 01917_BackCircleWeaponStore.lua_f82777a95095.luajit

local CategoryType = LTConfig.SceneitemConfig.CategoryType
local SceneitemConfig = LTConfig.SceneitemConfig
C_BackCircleWeaponStore = DefClass("C_BackCircleWeaponStore", C_BackCircleWeaponStore, C_BackCircleBase)
GroupName2Class.BackCircleWeaponStore = C_BackCircleWeaponStore
local M = C_BackCircleWeaponStore

M.DefineAllVariables = function(self)
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.WARN_TEXT = {
		["h\\x83\\x92\\x9b\\x8f"] = 0,
		["˵&\\xd38$\\xd4:ȡ\\xc1\\xab"] = 2,
		[">z\\xbe\\xa5\\xa6o"] = 3,
		["\\xf7\\xf4+9,\\xc1"] = 1
	}
	self.TAG_TEMPLATE = {
		["\\xbaIA"] = 0,
		["NM~"] = 1
	}
	self.circleOpen = false
	self.storeReady = false
	self.weaponReady = false
	self.WeaponSwitchAnimeDown = "S_vx_CircleWeaponPanel_cut_d"
	self.WeaponSwitchAnimeUp = "S_vx_CircleWeaponPanel_cut_u"
	self.weaponItemMap = {}
	self.weaponTabList = {}
	self.weaponItemStore = {}
	self.privateWeaponMinIndex = 0
	self.MAX_SLOT_COUNT = 8
	self.weaponGuideIndex = -1
	self.weaponGuideIsTask = false
	self.weaponGuideID = nil
	self.SelectIndex = 0
	self.SelectDataIndex = 0
	self.isInProwlArea = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.weaponStartSelectEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ShowWeaponDetailCtrlEnum = {
		["\\xa9}h"] = 3,
		["\\xfd\\xde(\\xe5"] = 0,
		S6xV = 2,
		["+M\\x90\\x9e\\x8cO"] = 1,
		["c\\xa1\\x97\\xbc\\xb3"] = 4
	}
	self.WarningTextCtrlEnum = {
		["2G\\xb5\\x9c\\x8cQ"] = 1,
		["Nz\\xa0x[\\x81\\xe6BkvjD"] = 5,
		[".\\xecH\\xc2\\xb4H\\xad_\\xa4\\xaf"] = 2,
		["$\\xecM.\\xd4/\\xa2D\\xa0Z\\xa4\\xbe"] = 4,
		[":G\\x83\\x8c\\x8aE"] = 6,
		[">Z\\x9e\\x85\\x86O"] = 3,
		["h\\xa3\\xb2\\xbb\\xaf"] = 0
	}
	self.QualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.WheelTypeCtrlEnum = {
		["\\x98\\xa5\\xa5n?\\xec7"] = 0,
		["\\xf4\\xd2+\\xff"] = 1
	}
	self.ShowTooltipCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.weaponHasElemtensCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showDetailBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.SelectingActiveCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.IsEmptyCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.UsingCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.TypeCtrlEnum = {
		["N#nP"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.ShowBgCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.DropStateCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.BrokenCtrlEnum = {
		[">Z\\x9e\\x85\\x86O"] = 2,
		["As\\xade@\\xab\\xd0Ueq{B"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.IsLockedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.forbidStealthCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.WeaponTypeCtrlEnum = {
		["\\xa9}h"] = 1,
		["\"?\\x96쾫\\xfc\\x99\\x93\\x9c\\xd8\\xefӗ\"\\x9a\\xf0"] = 0,
		["\\xe9\\xde*\\xe5"] = 2,
		["\n$&\\xed}\\x91\\xe31\\x98*\\xf4\\xf1\\xe3z\\xef"] = 5,
		["\\0x^"] = 3,
		["Fx\\xaa~B\\xbb\\xe6BKwsC"] = 4
	}
	self.tipShowModeCtrlEnum = {
		["pU\\xc0\\xae\\x91\\xb9\\xc5\\xed"] = 1,
		["+M\\x90\\x9e\\x8cO"] = 0,
		["Xs\\xadgC\\xbc\\xdcHIrw\\"] = 2
	}
	self.tipQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.tipForbidStealthCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.tipBulletCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isValiadCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.weaponStartSelectEnum = nil
	self.ShowWeaponDetailCtrlEnum = nil
	self.WarningTextCtrlEnum = nil
	self.QualityCtrlEnum = nil
	self.WheelTypeCtrlEnum = nil
	self.ShowTooltipCtrlEnum = nil
	self.weaponHasElemtensCtrlEnum = nil
	self.showDetailBtnCtrlEnum = nil
	self.SelectingActiveCtrlEnum = nil
	self.IsEmptyCtrlEnum = nil
	self.UsingCtrlEnum = nil
	self.TypeCtrlEnum = nil
	self.ShowBgCtrlEnum = nil
	self.DropStateCtrlEnum = nil
	self.BrokenCtrlEnum = nil
	self.IsLockedCtrlEnum = nil
	self.forbidStealthCtrlEnum = nil
	self.WeaponTypeCtrlEnum = nil
	self.tipShowModeCtrlEnum = nil
	self.tipQualityCtrlEnum = nil
	self.tipForbidStealthCtrlEnum = nil
	self.tipBulletCtrlEnum = nil
	self.isValiadCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.circleOpen = false
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.toolTipStore = self:GetStoreByWidget(self.bindData.weaponTooltipRoot)
	self.toolTipStore.tipTagList.luaSimpleRenderItem = self:CreateAction("OnWeaponTagListRenderItem")
	self.toolTipStore.tipAttrList.luaSimpleRenderItem = self:CreateAction("OnWeaponAttrListRenderItem")
	self.toolTipStore.tipAttrList.onGetTIndex = self:CreateAction("OnWeaponAttrGetTIndex")
	self.toolTipStore.tipChipList.luaSimpleRenderItem = self:CreateAction("OnWeaponChipListRenderItem")
	self.toolTipStore.tipChipList.luaSimpleClick = self:CreateAction("OnChipListClick")
	self.toolTipStore.MAEnableCtrl = self.MAEnable and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
	self.toolTipStore.MASwitchEnableCtrl = self.SELECT_MODE.FALSE

	table.clear(self.weaponItemStore)
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem1))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem2))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem3))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem4))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem5))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem6))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem7))
	table.insert(self.weaponItemStore, self:GetStoreByWidget(self.bindData.weaponItem8))

	self.storeReady = true

	self:RebuildCircleView()
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.storeReady = false
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CURRENT_WEAPON_SLOT_REMOVE] = self.CreateAction(self, "RemoveWeaponSlot"),
		[gEventConstants.CURRENT_WEAPON_SLOT_ADD] = self.CreateAction(self, "AddWeaponSlot"),
		[gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE] = self.CreateAction(self, "OnCurrentWeaponChange"),
		[gEventConstants.ON_GAMEPLAY_TAG_UI_REFRESH] = self.CreateAction(self, "OnGameplayTagChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.weaponDropBtnPC.luaClick = self.CreateAction(self, "WeaponDropCurrentSelect")
	self.bindData.weaponDropBtnPad.luaClick = self.CreateAction(self, "WeaponDropCurrentSelect")
	self.bindData.weaponDropBtnMobile.luaClick = self.CreateAction(self, "WeaponDropCurrentSelect")
	self.bindData.weaponCloseBtnPC.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.weaponCloseBtnPad.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.weaponConfirmBtnPC.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.weaponConfirmBtnPad.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.mouseScrollRespond.luaGamePadInputChanged = self.CreateAction(self, "OnWeaponMouseScroll")
	self.bindData.weaponMouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.weaponRightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickMove")
	self.bindData.switchBtnPad.luaClick = self.CreateAction(self, "SwitchWeaponTypeLoop")
	self.bindData.weaponTagList.luaSimpleRenderItem = self.CreateAction(self, "OnWeaponTagListRenderItem")
	self.bindData.weaponTagList.onGetTIndex = self.CreateAction(self, "OnWeaponTagListGetTIndex")
	self.bindData.weaponTabList.luaSimpleRenderItem = self.CreateAction(self, "OnWeaponTabListRenderItem")
	self.bindData.weaponTabList.luaSelectedChanged = self.CreateAction(self, "OnSwitchWeaponPage")
	self.bindData.detailsBtn.luaClick = self.CreateAction(self, "OnDetailsBtnClick")
end

M.DefineInitVector = function(self)
	self.InitVector = Vector2.New(-math.sin(math.pi / 4), -math.cos(math.pi / 4))
	self.EachAngle = 45
end

M.OnCircleOpen = function(self, data)
	self.localCircleInfo = data.localInfo
	self.circleOpen = true
	self.weaponReady = false
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.needSave = false
	self.weaponShowToolTip = self.localCircleInfo.SHOW_WEAPON_CIRCLE_TOOLTIP or false

	self.bindData.detailsBtn:SetSelected(self.weaponShowToolTip)
	self.bindData.tooltipDescBtnPc:SetSelected(self.weaponShowToolTip)
	self.bindData.tooltipDescBtnPad:SetSelected(self.weaponShowToolTip)

	self.isInProwlArea = gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.IsProwlArea)
	self.showDetail = not gLinkManager:CheckIsInHideAndSeek()
	self.bindData.showDetailBtnCtrl = self.showDetail and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
	self.targetPageIndex = 1
	self.MAEnable = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FightSkill)

	if self.toolTipStore and not self.MAEnable then
		self.toolTipStore.MAWidget:SetActive(false)
	end

	self.RebuildCircleView(self)
end

M.OnCircleClose = function(self)
	self.circleOpen = false

	if self.needSave then
		self.needSave = false

		gUIUtils:SaveLuaTableToJsonWithPid(self.LOCAL_CIRCLE_INFO_PATH, self.localCircleInfo)
	end

	self.SetWeaponSelect(self, 0)
	table.clear(self.weaponItemMap)
	table.clear(self.weaponTabList)
end

M.CloseTrigger = function(self)
	if self.SelectIndex <= 0 then
		local item = self.weaponItemMap[self.SelectDataIndex]

		self.weaponItemStore[self.SelectIndex].btn:LuaSimulateClick()

		if item then
			if item.Using then
				return
			end

			gClientToGameSceneDelegate:AskSwitchWeapon(item.Index)
		end
	end
end

M.DoUpdate = function(self)
	self.UpdateArrowSelect(self)
end

M.UpdateArrowSelect = function(self)
	if self.updateSelect then
		self.UpdateSmoothMoveVector(self)

		local index, angle = self.GetArrowSelect(self, self.moveVector)
		self.bindData.weaponStartSelect = self.SELECT_MODE.TRUE

		self.SetWeaponSelect(self, index)

		self.bindData.weaponArrowAngle = -angle
	end
end

M.RebuildCircleView = function(self)
	if not self.storeReady or not self.circleOpen then
		return
	end

	local SelectIndex = 0

	self:RefreshWeaponCircle()
	self:RebuildWeaponPageView()
	self:RebuildWeaponCircleView()

	local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

	for i = startIdx + 1, endIdx do
		if self.weaponItemMap[i] and self.weaponItemMap[i].Using then
			SelectIndex = i - startIdx

			break
		end
	end

	self:SetWeaponSelect(SelectIndex, true)

	self.bindData.weaponStartSelect = self.SELECT_MODE.FALSE

	self.bindData.weaponTabList:SelectItem(self.targetPageIndex - 1, false)

	if self.SelectIndex ~= 0 then
		self.moveVector.x = 0
		self.moveVector.y = 1
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	else
		local angle = self.EachAngle * (self.SelectIndex + 0.5)
		self.moveVector.x = -math.sin(angle / 180 * math.pi)
		self.moveVector.y = -math.cos(angle / 180 * math.pi)
		self.accumulateMoveVector.x = 0
		self.accumulateMoveVector.y = 0
	end

	self.ClearSmoothMove(self)
end

M.RefreshWeaponCircle = function(self)
	if self.weaponReady then
		return
	end

	table.clear(self.weaponItemMap)

	local weapons = gWeaponManager:GetCurrentWeapons()
	self.weaponGuideIndex = -1
	self.weaponGuideIsTask = false
	self.weaponGuideID = nil
	local taskId = gTaskNodeManager:GetNowDoingTask()
	local lowPoint = LTConfig.SceneitemConfig.WeaponDurabilityLow * 100

	for i = 1, weapons.Length do
		local item = self.ProcessWeaponCircle(self, i, weapons[i], lowPoint, taskId)

		table.insert(self.weaponItemMap, item)
	end

	if self.weaponGuideIndex <= 0 then
		self.weaponItemMap[self.weaponGuideIndex].guideID = self.weaponGuideID
	end

	table.clear(self.weaponTabList)

	for i = 1, 2 do
		table.insert(self.weaponTabList, i)
	end

	self.weaponReady = true
end

M.RebuildWeaponCircleView = function(self)
	local startIndex, endIndex = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

	for i = 1, self.MAX_SLOT_COUNT do
		local idx = i + startIndex

		if endIndex > idx then
			local item = self.weaponItemMap[idx]

			self.OnRenderWeaponCircleItem(self, i, item, idx)
		else
			self.OnRenderWeaponCircleItem(self, i, nil, idx)
		end
	end
end

M.ProcessWeaponCircle = function(self, idx, detail, lowPoint, taskId)
	if not detail then
		return false, -1
	end

	local item = {
		Cfg = SceneitemConfig.GetConfig(detail.TemplateId)
	}

	if item.Cfg then
		lowPoint = lowPoint or LTConfig.SceneitemConfig.WeaponDurabilityLow * 100
		item.TemplateId = detail.TemplateId
		item.InstanceId = detail.InstanceId
		item.EnchantSlots = detail.EnchantSlots
		item.IsEnchanted = gCommonItemManager:IsWeaponEnchanted(detail)
		item.IsTask = gWeaponManager:GetFlag(detail.OperatorFlags, 2) ~= 1
		item.CantDiscard = gWeaponManager:GetFlag(detail.OperatorFlags, 1) ~= 1
		item.RedDot = detail.WeaponFlags.ShowRedDot and 1 or 0

		if item.RedDot <= 0 then
			SGUI.RedDotMgr.LuaSetRedDot(true, "weapon." .. item.InstanceId)
		end

		item.Index = idx - 1
		item.guideID = ""
		item.AttackFill = 0
		item.PoiseFill = 0
		item.IsLocked = false

		if gWeaponManager.TempWeaponMode then
			if detail.IsLocked then
				item.IsLocked = true
			end

			if gWeaponManager.LockMaxSlotCounts <= 0 and gWeaponManager.LockMaxSlotCounts >= idx then
				item.IsLocked = true
			end
		end

		if idx < 1 then
			item.IsPrivate = true
		end

		gWeaponManager:GetWeaponDurabilityData(item, detail)

		item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon
		local fsCfg = gWeaponManager:GetTabConfigByType(item.Cfg.Type)
		item.FSTypeIcon = fsCfg and fsCfg.Icon or 0
		item.tags = {}

		if item.CategoryType ~= CategoryType.Weapon or item.Cfg.Category ~= CategoryType.Gun then
			table.insert(item.tags, {
				tId = self.TAG_TEMPLATE.TYPE,
				iconId = item.FSTypeIcon
			})
		end

		for j = 1, #item.Cfg.Tags do
			table.insert(item.tags, {
				tId = self.TAG_TEMPLATE.TAG,
				TagType = item.Cfg.Tags[j]
			})
		end

		if item.Cfg.Category ~= CategoryType.Weapon then
			item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / SceneitemConfig.MaxWeaponAttackPower) * 100
			item.PoiseFill = Mathf.Clamp01((item.Cfg.PoiseAbility or 0) / SceneitemConfig.MaxWeaponPoiseAbility) * 100
			item.attrInfos = gWeaponManager:GetAttrInfo(item.Cfg)
			item.chipInfos = gWeaponManager:GetChipInfo(item.Cfg, detail)
		elseif item.Cfg.Category ~= CategoryType.Gun then
			item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / SceneitemConfig.GunMaxAtt) * 100
			item.SpeedFill = Mathf.Clamp01((item.Cfg.AttackSpeed or 0) / SceneitemConfig.GunMaxShootSpeed) * 100
			item.attrInfos = gWeaponManager:GetAttrInfo(item.Cfg)
			item.chipInfos = gWeaponManager:GetChipInfo(item.Cfg, detail)
		end

		item.chips = {}
		item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId ~= gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
		local taskCanUse = gWeaponManager:CheckWheelTaskGuide(taskId, item.Cfg)
		local guideSwitchIndex = -1

		if taskCanUse and (self.weaponGuideIndex <= 0 or not self.weaponGuideIsTask and item.IsTask) then
			guideSwitchIndex = self.weaponGuideIndex
			self.weaponGuideIndex = idx
			self.weaponGuideIsTask = item.IsTask
			self.weaponGuideID = item.Cfg.GuideId
		end

		item.IsProwlWeapon = false
		local tkaCfg = LTConfig.SceneitemTakeActionTypeConfig.GetConfig(item.Cfg.TakeActionType)

		if tkaCfg then
			item.IsProwlWeapon = tkaCfg.IsProwlWeapon
		end

		return item, guideSwitchIndex
	else
		print_error("Sceneitem配表找不到配置,TemplateId=", detail.TemplateId, "InstanceId=", detail.InstanceId)

		return false, -1
	end

	return false, -1
end

M.OnRenderWeaponCircleItem = function(self, index, item, itemIndex)
	local store = self.weaponItemStore[index]

	if item then
		store.weaponIcon = item.Cfg.SWeaponWheelsIconId
		store.durabilityText1 = item.DurabilityText1
		store.durabilityText2 = item.DurabilityText2
		store.WeaponTypeCtrl = item.WeaponUIType
		store.QualityCtrl = item.Cfg.Quality
		store.UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
		store.IsLockedCtrl = item.IsLocked and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.TypeCtrl = item.IsTask and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.ShowBgCtrl = item.IsPrivate and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = item.guideID
		store.redKey = item.RedDot <= 0 and "weapon." .. item.InstanceId or ""
		store.BrokenCtrl = item.BrokenState
		store.forbidStealthCtrl = self.isInProwlArea and item.IsProwlWeapon and self.SELECT_MODE.FALSE or self.SELECT_MODE.TRUE
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		local locked = false

		if gWeaponManager.TempWeaponMode and gWeaponManager.LockMaxSlotCounts <= 0 and gWeaponManager.LockMaxSlotCounts >= itemIndex then
			locked = true
		end

		store.IsLockedCtrl = locked and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.QualityCtrl = 0
		store.ShowBgCtrl = self.SELECT_MODE.FALSE
		store.DropStateCtrl = self.SELECT_MODE.FALSE
		store.guideID = ""
		store.redKey = ""
		store.forbidStealthCtrl = self.SELECT_MODE.TRUE
	end
end

M.RebuildWeaponPageView = function(self)
	self.bindData.weaponTabList:SetSimpleList(#self.weaponTabList)

	self.bindData.WheelTypeCtrl = gWeaponManager.TempWeaponMode and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
end

M.SetWeaponSelect = function(self, index, force)
	if self.SelectIndex == index or force then
		if self.SelectIndex <= 0 then
			self.weaponItemStore[self.SelectIndex].SelectingActiveCtrl = self.SELECT_MODE.FALSE
		end

		self.SelectIndex = index
		self.SelectDataIndex = gWeaponManager:ConvertSelectIndex(index, self.targetPageIndex)

		if self.SelectIndex <= 0 then
			self.weaponItemStore[self.SelectIndex].SelectingActiveCtrl = self.SELECT_MODE.TRUE
		end

		self.SetWeaponDetailInfo(self, self.SelectIndex)
	end
end

M.SetWeaponDetailInfo = function(self, index)
	local idx = gWeaponManager:ConvertSelectIndex(index, self.targetPageIndex)
	local item = self.weaponItemMap[idx]

	if item then
		self.bindData.ShowWeaponDetailCtrl = item.Cfg.Category + 1
		self.bindData.weaponName = item.Cfg.Name or ""

		if item.CategoryType ~= CategoryType.Weapon then
			self.bindData.weaponAttackLevel = gWeaponManager:GetWeaponAttrRank(item.AttackFill)
			self.bindData.weaponPoiseLevel = gWeaponManager:GetWeaponAttrRank(item.PoiseFill)
		elseif item.CategoryType ~= CategoryType.Gun then
			self.bindData.weaponAttackLevel = gWeaponManager:GetGunAttrRank(item.AttackFill)
			self.bindData.weaponSpeedLevel = gWeaponManager:GetGunAttrRank(item.SpeedFill)
		end

		self.bindData.QualityCtrl = item.Cfg.Quality
		self.bindData.weaponDescription = item.Cfg.Description or ""

		if item.CantDiscard or item.IsPrivate then
			self.bindData.weaponDropBtnMobile.interactable = false

			self.bindData.weaponDropBtnPC:SetActive(false)
			self.bindData.weaponDropBtnPad:SetActive(false)
		else
			self.bindData.weaponDropBtnMobile.interactable = true

			self.bindData.weaponDropBtnPC:SetActive(true)
			self.bindData.weaponDropBtnPad:SetActive(true)
		end

		local warn = self.WarningTextCtrlEnum.Empty

		if self.isInProwlArea then
			if item.IsProwlWeapon then
				warn = self.WarningTextCtrlEnum.AllowStealth
			else
				warn = self.WarningTextCtrlEnum.ForbidStealth
			end
		elseif item.CantDiscard or item.IsPrivate then
			warn = self.WARN_TEXT.NO_DROP
		elseif item.CategoryType ~= CategoryType.Weapon and item.BrokenState <= 0 then
			warn = item.BrokenState + 1
		end

		self.bindData.WarningTextCtrl = warn

		if #item.tags <= 0 then
			self.bindData.weaponHasElemtensCtrl = self.SELECT_MODE.TRUE

			self.bindData.weaponTagList:SetSimpleList(#item.tags)
		else
			self.bindData.weaponHasElemtensCtrl = self.SELECT_MODE.FALSE
		end

		if item.RedDot <= 0 then
			self.ClearWeaponRedDot(self, item)
		end
	else
		self.bindData.ShowWeaponDetailCtrl = self.SELECT_MODE.FALSE
		self.bindData.weaponDropBtnMobile.interactable = false

		self.bindData.weaponDropBtnPC:SetActive(false)
		self.bindData.weaponDropBtnPad:SetActive(false)
	end

	self.SetWeaponToolTipInfo(self, item)
end

M.SetWeaponToolTipInfo = function(self, item)
	if item and self.weaponShowToolTip and self.showDetail then
		self.bindData.ShowTooltipCtrl = self.SELECT_MODE.TRUE
		self.toolTipStore.tipWeaponName = item.Cfg.Name or ""

		self.toolTipStore.tipTagList:SetSimpleList(#item.tags)

		self.toolTipStore.tipQualityCtrl = item.Cfg.Quality
		self.toolTipStore.tipForbidStealthCtrl = self.isInProwlArea and not item.IsProwlWeapon and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		self.toolTipStore.moduleTypeIcon = item.FSTypeIcon

		if item.CategoryType ~= CategoryType.Weapon or item.CategoryType ~= CategoryType.Gun then
			local showMa = false

			if self.MAEnable then
				local currentSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

				if currentSpiritId then
					local weaponData = gWeaponManager:GetWeaponByInstanceId(item.InstanceId)
					local FightSkillId = gWeaponManager:GetWeaponFightSkill(currentSpiritId, weaponData)
					local fsCfg = LTConfig.FightSkillConfig.GetConfig(FightSkillId)

					if fsCfg and fsCfg.IsShowInArmony then
						showMa = true
						self.toolTipStore.tipMAName = fsCfg.Name or ""
						self.toolTipStore.tipMAIcon = fsCfg.IconId or 0
					end
				end
			end

			self.toolTipStore.MAWidget:SetActive(showMa)

			self.toolTipStore.tipShowModeCtrl = #item.chipInfos <= 0 and self.tipShowModeCtrlEnum.Weapon or self.tipShowModeCtrlEnum.WeaponNoChip
			self.toolTipStore.tipDescription = item.Cfg.WeaponBuffDescription or ""

			self.toolTipStore.tipAttrList:SetSimpleList(#item.attrInfos)
			self.toolTipStore.tipChipList:SetSimpleList(#item.chipInfos)
		else
			self.toolTipStore.tipBulletCtrl = self.tipBulletCtrlEnum._false
			self.toolTipStore.tipShowModeCtrl = self.tipShowModeCtrlEnum.Consumable

			self.toolTipStore.MAWidget:SetActive(false)

			self.toolTipStore.tipDescription = item.Cfg.Description or ""
		end
	else
		self.bindData.ShowTooltipCtrl = self.SELECT_MODE.FALSE
	end
end

M.SetSkillAndRadarChartInfo = function(self, item)
	local cfg = item.Cfg
	local radarChat = self.toolTipStore.tipRadarChat
	local fill = 0
	local text = ""
	fill = item.AttackFill
	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(0, fill)
	radarChat:SetVertexRankText(0, text)

	fill = Mathf.Clamp01((cfg.AttackRange or 0) / SceneitemConfig.MaxWeaponAttackRange) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(1, fill)
	radarChat:SetVertexRankText(1, text)

	fill = Mathf.Clamp01(cfg.AttackSpeed / SceneitemConfig.MaxWeaponAttackSpeed) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(2, fill)
	radarChat:SetVertexRankText(2, text)

	fill = item.PoiseFill
	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(3, fill)
	radarChat:SetVertexRankText(3, text)

	fill = Mathf.Clamp01(cfg.ImpactForce / SceneitemConfig.MaxWeaponImpactForce) * 100
	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(4, fill)
	radarChat:SetVertexRankText(4, text)

	if cfg.Durability < 0 then
		fill = 100
	elseif cfg.ShootId and cfg.ShootId <= 0 then
		fill = Mathf.Clamp01(cfg.Durability / SceneitemConfig.MaxGunDurability) * 100
	else
		fill = Mathf.Clamp01(cfg.Durability / SceneitemConfig.MaxWeaponDurability) * 100
	end

	text = gWeaponManager:GetWeaponAttrRank(fill)

	radarChat:SetVertexValue(5, fill)
	radarChat:SetVertexRankText(5, text)
end

M.ClearWeaponRedDot = function(self, item)
	item.RedDot = 0

	SGUI.RedDotMgr.LuaSetRedDot(false, "weapon." .. item.InstanceId)

	local weapons = gWeaponManager:GetCurrentWeapons()

	for i = 1, weapons.Length do
		if weapons[i] and weapons[i].InstanceId ~= item.InstanceId then
			weapons[i].WeaponFlags.ShowRedDot = false

			break
		end
	end

	gWeaponManager:ClearWeaponRedDot(item.InstanceId)
end

M.OnWeaponTagListGetTIndex = function(self, index)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.tags then
		local data = item.tags[index + 1]

		return data and data.tId or 0
	end

	return 0
end

M.OnWeaponTagListRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.tags then
		local data = item.tags[index + 1]

		if data and store then
			if data.tId ~= self.TAG_TEMPLATE.TAG then
				store.TypeCtrl = data.TagType
			elseif data.tId ~= self.TAG_TEMPLATE.TYPE then
				store.iconId = data.iconId
			end
		end
	end
end

M.OnWeaponTabListRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local item = self.weaponTabList[index + 1]

	if item and store then
		store.text = item
	end
end

M.OnWeaponAttrListRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.attrInfos then
		local data = item.attrInfos[index + 1]

		if data and store then
			if data.template ~= 0 then
				store.name = data.name
				store.value = data.value
				store.valueFill = data.valueFill
			else
				store.name = data.name
				store.value = data.value
			end
		end
	end
end

M.OnWeaponAttrGetTIndex = function(self, index)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.attrInfos then
		local data = item.attrInfos[index + 1]

		if data then
			return data.template
		end
	end

	return 0
end

M.OnWeaponChipListRenderItem = function(self, btn, index)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.chipInfos then
		local store = self.GetStoreByWidget(self, btn)
		local data = item.chipInfos[index + 1]

		if data and store then
			if data.valid then
				local cfg = LTConfig.DecorationConfig.GetConfig(data.info.DecorationId)
				store.isValiadCtrl = self.SELECT_MODE.TRUE
				store.iconId = cfg and cfg.Icon or 0
				store.QualityCtrl = cfg and cfg.Quality or 0
			else
				store.isValiadCtrl = self.SELECT_MODE.FALSE
			end
		end
	end
end

M.OnChipListClick = function(self, btn, index)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item and item.chipInfos then
		local data = item.chipInfos[index + 1]

		if data then
			print_error("Open Chip Panel, valid=", data.valid, " index=", index + 1)
		end
	end
end

M.WeaponDropCurrentSelect = function(self)
	local item = self.weaponItemMap[self.SelectDataIndex]

	if item then
		if item.IsPrivate or item.CantDiscard then
			return
		end

		gClientToGameSceneDelegate:AskDiscardWeapon(item.Index)
	end
end

M.OnWeaponMouseScroll = function(self, context)
	if context.performed then
		local zoom = context.ReadValueVector2(context).y

		if zoom <= 0 then
			self.ScrollWeaponType(self, true)
		elseif zoom >= 0 then
			self.ScrollWeaponType(self, false)
		end
	end
end

M.ScrollWeaponType = function(self, up)
	if up then
		return
	else
		gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):SwitchCircleType(gCircleType.SUMMON)
	end
end

M.OnSwitchWeaponPage = function(self)
	local index = self.bindData.weaponTabList.selectedIndex + 1

	if index ~= self.targetPageIndex then
		return
	end

	if self.targetPageIndex >= index then
		gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):SwitchCircleType(gCircleType.SUMMON)
	end
end

M.PlaySwitchAnime = function(self, up)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, up and self.WeaponSwitchAnimeUp or self.WeaponSwitchAnimeDown)
end

M.SwitchWeaponTypeLoop = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):SwitchCircleType(gCircleType.SUMMON)
end

M.OnDetailsBtnClick = function(self)
	self.weaponShowToolTip = not self.weaponShowToolTip

	self.bindData.detailsBtn:SetSelected(self.weaponShowToolTip)
	self.bindData.tooltipDescBtnPc:SetSelected(self.weaponShowToolTip)
	self.bindData.tooltipDescBtnPad:SetSelected(self.weaponShowToolTip)

	self.localCircleInfo.SHOW_WEAPON_CIRCLE_TOOLTIP = self.weaponShowToolTip
	self.needSave = true
	local item = self.weaponItemMap[self.SelectDataIndex]

	self:SetWeaponToolTipInfo(item)
end

M.RemoveWeaponSlot = function(self, eventId, data)
	local index = data.SlotIndex

	if self.STATE_EnableOnce and self.circleOpen then
		self.weaponItemMap[index] = false
		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)
		local idx = index - startIdx

		if startIdx >= index and index < endIdx and idx <= 0 and idx < self.MAX_SLOT_COUNT then
			self.weaponItemStore[idx].IsEmptyCtrl = self.SELECT_MODE.TRUE
			self.weaponItemStore[idx].DropStateCtrl = self.SELECT_MODE.TRUE
			self.weaponItemStore[idx].QualityCtrl = 0
			self.weaponItemStore[idx].guideID = ""
			self.weaponItemStore[idx].redKey = ""

			if idx ~= self.SelectIndex then
				self.bindData.ShowWeaponDetailCtrl = self.SELECT_MODE.FALSE
				self.bindData.ShowTooltipCtrl = self.SELECT_MODE.FALSE
			end
		end
	end
end

M.AddWeaponSlot = function(self, eventId, data)
	local index = data.SlotIndex
	local weapon = data.Weapon

	if self.STATE_EnableOnce and self.circleOpen then
		local item, preIndex = self:ProcessWeaponCircle(index, weapon, nil, gTaskNodeManager:GetNowDoingTask())
		self.weaponItemMap[index] = item

		if item then
			local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)
			local idx = index - startIdx

			if preIndex <= 0 then
				self.weaponItemMap[preIndex].guideID = ""
				idx = preIndex - startIdx

				if startIdx >= preIndex and preIndex < endIdx and idx <= 0 and idx < self.MAX_SLOT_COUNT then
					self.weaponItemStore[idx].guideID = ""
				end
			end

			if self.weaponGuideIndex <= 0 then
				self.weaponItemMap[self.weaponGuideIndex].guideID = self.weaponGuideID
			end

			if startIdx >= index and index < endIdx and idx <= 0 and idx < self.MAX_SLOT_COUNT then
				self.OnRenderWeaponCircleItem(self, idx, item, index)

				if idx ~= self.SelectIndex then
					self.SetWeaponDetailInfo(self, idx)
				end
			end
		end
	end
end

M.OnCurrentWeaponChange = function(self, eventId)
	if self.STATE_EnableOnce and self.circleOpen then
		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

		for i = 1, #self.weaponItemMap do
			local item = self.weaponItemMap[i]

			if item then
				item.Using = gPlayerManager.infoSpirit.bindData.currentWeapon and item.InstanceId ~= gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId or false
				local idx = i - startIdx

				if startIdx >= i and i < endIdx and idx <= 0 and idx < self.MAX_SLOT_COUNT then
					self.weaponItemStore[idx].UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				end
			end
		end
	end
end

M.OnGameplayTagChange = function(self, eventId, queryId, stateRes)
	if self.STATE_EnableOnce and self.circleOpen and queryId ~= LTConfig.GameplayTagQueryConfig.IsProwlArea then
		local isInProwlArea = gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.IsProwlArea)

		self.SetInProwlArea(self, isInProwlArea)
	end
end

M.SetInProwlArea = function(self, isInProwlArea, force)
	if self.isInProwlArea == isInProwlArea or force then
		self.isInProwlArea = isInProwlArea

		self.RebuildWeaponCircleView(self)
		self.SetWeaponSelect(self, self.SelectIndex, true)
	end
end
