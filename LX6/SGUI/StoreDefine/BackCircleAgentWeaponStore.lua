-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleAgentWeaponStore.lua
-- Decompiled from: 01923_BackCircleAgentWeaponStore.lua_a9759d387df6.luajit

local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local CategoryType = LTConfig.SceneitemConfig.CategoryType
C_BackCircleAgentWeaponStore = DefClass("C_BackCircleAgentWeaponStore", C_BackCircleAgentWeaponStore, C_BackCircleBase)
GroupName2Class.BackCircleAgentWeaponStore = C_BackCircleAgentWeaponStore
local M = C_BackCircleAgentWeaponStore

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
	self.circleOpen = false
	self.storeReady = false
	self.weaponReady = false
	self.WeaponSwitchAnimeDown = "S_vx_CircleWeaponPanel_cut_d"
	self.WeaponSwitchAnimeUp = "S_vx_CircleWeaponPanel_cut_u"
	self.weaponItemMap = {}
	self.weaponTabList = {}
	self.weaponItemStore = {}
	self.MAX_SLOT_COUNT = 8
	self.SelectIndex = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
	table.clear(self.weaponItemStore)
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem1))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem2))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem3))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem4))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem5))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem6))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem7))
	table.insert(self.weaponItemStore, self.GetStoreByWidget(self, self.bindData.weaponItem8))

	self.storeReady = true

	self.RebuildCircleView(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.weaponItemStore = nil
	self.storeReady = false
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.weaponCloseBtnPC.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.weaponCloseBtnPad.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.weaponConfirmBtnPC.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.weaponConfirmBtnPad.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.mouseScrollRespond.luaGamePadInputChanged = self.CreateAction(self, "OnWeaponMouseScroll")
	self.bindData.weaponMouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.weaponRightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickMove")
	self.bindData.switchBtnPad.luaClick = self.CreateAction(self, "SwitchWeaponTypeLoop")
	self.bindData.weaponTagList.luaSimpleRenderItem = self.CreateAction(self, "OnWeaponTagListRenderItem")
	self.bindData.weaponTabList.luaSimpleRenderItem = self.CreateAction(self, "OnWeaponTabListRenderItem")
	self.bindData.weaponTabList.luaSelectedChanged = self.CreateAction(self, "OnSwitchWeaponPage")
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
	self.targetPageIndex = 1
	local weapons = gAgentWeaponManager:GetAgentWeaponWheel(gBattleMgr.SummonAgentId)
	local curr = gAgentWeaponManager:GetAgentCurrentWeapon(gBattleMgr.SummonAgentId)

	if weapons then
		for i = 1, weapons.Length do
			local weapon = weapons[i]

			if weapon ~= curr then
				if i <= 8 then
					self.targetPageIndex = 2
				end

				break
			end
		end
	end

	self.RebuildCircleView(self)
end

M.OnCircleClose = function(self)
	self.circleOpen = false

	self.SetWeaponSelect(self, 0)
	table.clear(self.weaponItemMap)
	table.clear(self.weaponTabList)
end

M.CloseTrigger = function(self)
	if self.SelectIndex <= 0 then
		local idx = gWeaponManager:ConvertSelectIndex(self.SelectIndex, self.targetPageIndex)
		local item = self.weaponItemMap[idx]

		self.weaponItemStore[self.SelectIndex].btn:LuaSimulateClick()

		if item then
			if item.Using then
				return
			end

			slot3 = gClientToGameDelegate

			slot3:AskAgentChangeWeaponByTemplateId(gBattleMgr.SummonAgentId, item.TemplateId).Callback = function ()
			end
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

	local weapons = gAgentWeaponManager:GetAgentWeaponWheel(gBattleMgr.SummonAgentId)
	local curr = gAgentWeaponManager:GetAgentCurrentWeapon(gBattleMgr.SummonAgentId)

	if weapons then
		for i = 1, weapons.Length do
			local item = self.ProcessWeaponCircle(self, i, weapons[i], curr)

			table.insert(self.weaponItemMap, item)
		end
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

M.ProcessWeaponCircle = function(self, idx, templateId, currWeapon)
	if not templateId then
		return false, -1
	end

	local item = {
		Cfg = LTConfig.SceneitemConfig.GetConfig(templateId)
	}

	if item.Cfg then
		item.TemplateId = templateId
		item.Index = idx - 1
		item.guideID = ""
		item.AttackFill = 0
		item.PoiseFill = 0
		item.tags = {}

		for j = 1, #item.Cfg.Tags do
			table.insert(item.tags, {
				TagType = item.Cfg.Tags[j]
			})
		end

		local cfg = UrbanAttributeConfig.GetConfig(item.Cfg.sixDimBonus)
		item.SixDimName = cfg and cfg.Name or ""
		item.SixDimIcon = cfg and cfg.SIcon or 0
		item.AttackFill = Mathf.Clamp01((item.Cfg.AttackPower or 0) / LTConfig.SceneitemConfig.MaxWeaponAttackPower) * 100
		item.PoiseFill = Mathf.Clamp01((item.Cfg.PoiseAbility or 0) / LTConfig.SceneitemConfig.MaxWeaponPoiseAbility) * 100
		item.Using = currWeapon ~= templateId
		item.CategoryType = item.Cfg and item.Cfg.Category or CategoryType.Weapon

		return item
	else
		print_error("Weapon配表找不到配置,TemplateId=", item.TemplateId, "InstanceId=", item.InstanceId)

		return false, -1
	end

	return false, -1
end

M.OnRenderWeaponCircleItem = function(self, index, item, itemIndex)
	local store = self.weaponItemStore[index]

	if item then
		store.weaponIcon = item.Cfg.SWeaponWheelsIconId
		store.QualityCtrl = item.Cfg.Quality
		store.UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
	else
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		store.QualityCtrl = 0
		store.guideID = ""
	end
end

M.RebuildWeaponPageView = function(self)
	self.bindData.weaponTabList:SetSimpleList(#self.weaponTabList)
end

M.SetWeaponSelect = function(self, index, force)
	if self.SelectIndex == index or force then
		if self.SelectIndex <= 0 then
			self.weaponItemStore[self.SelectIndex].SelectingActiveCtrl = self.SELECT_MODE.FALSE
		end

		self.SelectIndex = index

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
		self.bindData.weaponAttackLevel = gWeaponManager:GetWeaponAttrRank(item.AttackFill)
		self.bindData.weaponPoiseLevel = gWeaponManager:GetWeaponAttrRank(item.PoiseFill)
		self.bindData.QualityCtrl = item.Cfg.Quality
		self.bindData.weaponDescription = item.Cfg.Description or ""

		if #item.tags <= 0 then
			self.bindData.weaponHasElemtensCtrl = self.SELECT_MODE.TRUE

			self.bindData.weaponTagList:SetSimpleList(#item.tags)
		else
			self.bindData.weaponHasElemtensCtrl = self.SELECT_MODE.FALSE
		end
	else
		self.bindData.ShowWeaponDetailCtrl = self.SELECT_MODE.FALSE
	end
end

M.OnWeaponTagListRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local item = self.weaponItemMap[self.SelectIndex]

	if item and item.tags then
		local data = item.tags[index + 1]

		if data and store then
			store.TypeCtrl = data.TagType
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
		if self.targetPageIndex < 1 then
			return
		end

		self.targetPageIndex = self.targetPageIndex - 1

		self.RebuildCircleView(self)
		self.PlaySwitchAnime(self, true)
	else
		if self.targetPageIndex > #self.weaponTabList then
			return
		end

		self.targetPageIndex = self.targetPageIndex + 1

		self.RebuildCircleView(self)
		self.PlaySwitchAnime(self, false)
	end
end

M.OnSwitchWeaponPage = function(self)
	local index = self.bindData.weaponTabList.selectedIndex + 1
	local up = index <= self.targetPageIndex
	self.targetPageIndex = index

	self:RebuildCircleView()
	self:PlaySwitchAnime(up)
end

M.PlaySwitchAnime = function(self, up)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, up and self.WeaponSwitchAnimeUp or self.WeaponSwitchAnimeDown)
end

M.SwitchWeaponTypeLoop = function(self)
	local to = self.targetPageIndex + 1

	if to <= #self.weaponTabList then
		to = 1
	end

	local up = to <= self.targetPageIndex
	self.targetPageIndex = to

	self:RebuildCircleView()
	self:PlaySwitchAnime(up)
end

M.OnCurrentWeaponChange = function(self, eventId)
	if self.STATE_EnableOnce and self.circleOpen then
		local startIdx, endIdx = gWeaponManager:GetWeaponIndexRangeByType(self.targetPageIndex)

		for i = 1, #self.weaponItemMap do
			local item = self.weaponItemMap[i]

			if item then
				item.Using = item.TemplateId ~= gAgentWeaponManager:GetAgentCurrentWeapon(gBattleMgr.SummonAgentId)
				local idx = i - startIdx

				if startIdx >= i and i < endIdx and idx <= 0 and idx < self.MAX_SLOT_COUNT then
					self.weaponItemStore[idx].UsingCtrl = item.Using and self.SELECT_MODE.TRUE or self.SELECT_MODE.FALSE
				end
			end
		end
	end
end
