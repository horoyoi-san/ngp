-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoguelikeInGamePanelStore.lua
-- Decompiled from: 00857_RoguelikeInGamePanelStore.lua_23b24e1143a6.luajit

C_RoguelikeInGamePanelStore = DefClass("C_RoguelikeInGamePanelStore", C_RoguelikeInGamePanelStore, C_StoreGroup)
GroupName2Class.RoguelikeInGamePanelStore = C_RoguelikeInGamePanelStore
local M = C_RoguelikeInGamePanelStore
local AttributeNameConfig = LTConfig.AttributeNameConfig
local BuffConfig = LTConfig.BuffConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local RogueRaidConfig = LTConfig.RogueRaidConfig

M.ctor = function(self)
	self.gamepadMode = false
	self.SelectIndex = 0
	self.updateSelect = false
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(0, 0)
	self.MaxVectorLength = 40000
	self.MinVectorLength = 20
	self.SMOOTH_TIME = 0.1
	self.smoothStartTime = 0
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
	self.EachAngle = 45
	self.InitVector = Vector2.New(-math.sin(math.pi / 4), -math.cos(math.pi / 4))
end

M.DefineAllVariables = function(self)
	self.MAX_WEAPON_SLOT = 8
	self.SLOT_FILLED = 0
	self.SLOT_EMPTY = 1
	self.LIST_TEMPLATE = {
		["~\\x9e\\x8e\\x86\\x82"] = 1,
		["SXv"] = 0
	}
	self.playerAttrData = {}
	self.buffData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.showCollectionEmptyCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showCollectionEmptyCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	self:RefreshWeaponWheel()
	gUrbanAbilityManager:GetAllSpiritPanelData()
	self:RefreshRogueLikeBuff()
	self:RefreshRoguelikeMoney()
end

M.OnClose = function(self)
	self.isShow = false
	self.playerAttrData = nil
	self.buffData = nil
	self.moneyView = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnUpdate = function(self)
	self.UpdateArrowSelect(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CURRENT_WEAPON_SLOT_ADD] = self.CreateAction(self, self.OnWeaponSlotChange),
		[gEventConstants.CURRENT_WEAPON_SLOT_REMOVE] = self.CreateAction(self, self.OnWeaponSlotChange),
		[gEventConstants.CURRENT_SPIRIT_WEAPON_CHANGE] = self.CreateAction(self, self.OnWeaponSlotChange),
		[gEventConstants.ON_ASK_ALL_SPIRIT_PANEL_DATA] = self.CreateAction(self, self.RefreshPlayerAttr)
	}
end

M.OnWeaponSlotChange = function(self)
	self.RefreshWeaponWheel(self)
end

M.RegisterWidget = function(self)
	self.bindData.playerAttrList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderPlayerAttrListItem)
	self.bindData.playerAttrList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderPlayerAttrListItem)
	self.bindData.moneyList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMoneyListItem)
	self.bindData.itemList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, self.OnGetListTIndex)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.controllerBtn.luaClick = self.CreateAction(self, self.OnControllerBtnClick)
	self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnStickMove)
end

M.RefreshWeaponWheel = function(self)
	if gRoguelikeManager.weaponGuideIndex ~= nil then
		gRoguelikeManager.weaponGuideIndex = -1
	end

	local taskId = gTaskNodeManager:GetNowDoingTask()
	local lowPoint = SceneitemConfig.WeaponDurabilityLow * 100
	local weapons = gWeaponManager:GetCurrentWeapons()
	local count = weapons and weapons.Length or 0
	self.weaponItemStore = {}

	for i = 1, self.MAX_WEAPON_SLOT do
		local btn = self.bindData["item" .. i]

		if btn then
			self.weaponItemStore[i] = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		end

		local detail = i < count and weapons[i] or nil
		local item = gRoguelikeManager:ProcessWeaponCircle(i, detail, lowPoint, taskId)

		gRoguelikeManager:RenderWeaponSlot(i, item, self.bindData)
	end

	self.SelectIndex = 0
	self.moveVector.x = 0
	self.moveVector.y = 1
	self.accumulateMoveVector.x = 0
	self.accumulateMoveVector.y = 0

	self.ClearSmoothMove(self)
end

M.CalculateAngle = function(self, initVec, endVec)
	local angle = Vector2.SignedAngle(endVec, initVec)

	return angle
end

M.SetVectorLength = function(self, vec, maxLength)
	local length = vec.sqrMagnitude

	if maxLength >= length then
		vec.Mul(vec, maxLength / length)
	end
end

M.SetSmoothMove = function(self, moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

M.UpdateSmoothMoveVector = function(self)
	if not self.updateSelect then
		return
	end

	if self.gamepadMode then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
		self.moveVector.x = x
		self.moveVector.y = y

		if self.SMOOTH_TIME >= Time.unscaledTime - self.smoothStartTime then
			self.ClearSmoothMove(self)
		end
	else
		self.moveVector.x = self.smoothEndVector.x
		self.moveVector.y = self.smoothEndVector.y

		self.ClearSmoothMove(self)
	end
end

M.ClearSmoothMove = function(self)
	self.updateSelect = false
end

M.GetArrowSelect = function(self, moveVector)
	local angle = self.CalculateAngle(self, self.InitVector, moveVector)

	if angle >= 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.EachAngle) + 1

	return index, angle
end

M.UpdateArrowSelect = function(self)
	if self.updateSelect then
		self.UpdateSmoothMoveVector(self)

		local index, angle = self.GetArrowSelect(self, self.moveVector)

		self.SetWeaponWheelSelect(self, index)
	end
end

M.SetWeaponWheelSelect = function(self, index)
	if self.SelectIndex ~= index then
		return
	end

	if self.SelectIndex <= 0 and self.weaponItemStore[self.SelectIndex] then
		self.weaponItemStore[self.SelectIndex].SelectingActiveCtrl = 0
	end

	self.SelectIndex = index

	if self.SelectIndex <= 0 and self.weaponItemStore[self.SelectIndex] then
		self.weaponItemStore[self.SelectIndex].SelectingActiveCtrl = 1
	end
end

M.RefreshPlayerAttr = function(self)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId or 0
	local panelData = gUrbanAbilityManager:GetUrbanPanelData(spiritId)
	local list = {}

	if panelData then
		local showAttr = RogueRaidConfig.ShowAttrList

		for i = 1, #showAttr do
			local attrId = showAttr[i]
			local value = panelData.Attrs[attrId]

			if value then
				table.insert(list, {
					id = attrId,
					value = value
				})
			end
		end
	end

	self.playerAttrData = list

	self.bindData.playerAttrList:SetSimpleList(#list)
end

M.RefreshRogueLikeBuff = function(self)
	self.bindData.showCollectionEmptyCtrl = self.showCollectionEmptyCtrlEnum.normal
	slot1 = gClientToGameSceneDelegate

	slot1:AskSelectedTempBuffs().Callback = function (err, buffs)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if self.isShow then
				self.bindData.itemList:SetSimpleList(0)
			end

			return
		end

		if self.isShow then
			if buffs and buffs.Count <= 0 then
				local count = buffs.Count

				for i = 1, count do
					table.insert(self.buffData, {
						buffId = buffs[i],
						tIndex = self.LIST_TEMPLATE.ITEM
					})

					if i == count then
						table.insert(self.buffData, {
							tIndex = self.LIST_TEMPLATE.SPLIT
						})
					end
				end
			end

			self.bindData.itemList:SetSimpleList(#self.buffData)

			self.bindData.showCollectionEmptyCtrl = #self.buffData <= 0 and self.showCollectionEmptyCtrlEnum.normal or self.showCollectionEmptyCtrlEnum.active
		end
	end
end

M.RefreshRoguelikeMoney = function(self)
	local view = {
		templateId = ConsumableConfig.RogueMoney,
		disabled = true
	}
	local cfg = ConsumableConfig.GetConfig(view.templateId)

	if cfg then
		view.moneyText = cfg.MoneyRichTextIcon
	end

	view.isShowAdd = false
	local value = gCommonItemManager:GetPackItemNum(view.templateId)
	view.rawCount = value
	view.count = gCommonItemManager:IsMoneyItem(view.templateId) and gCommonItemManager:BuildLargeNum(value) or value
	view.changeCount = ""
	view.tIndex = 0
	self.moneyView = view

	self.bindData.moneyList:SetSimpleList(1)
end

M.OnClickBackBtn = function(self)
	if not self.gamepadMode or not self.TryCloseTooltip(self) then
		gPanelManager:Close(self.m_Id)
	end
end

M.TryCloseTooltip = function(self)
	local close = false

	for i = 1, self.MAX_WEAPON_SLOT do
		local btn = self.bindData["item" .. i]

		if btn.isTooltipOpen then
			close = true

			btn.CloseTooltip(btn)
		end
	end

	return close
end

M.OnControllerBtnClick = function(self)
	for i = 1, self.MAX_WEAPON_SLOT do
		local btn = self.bindData["item" .. i]

		if i == self.SelectIndex then
			btn.CloseTooltip(btn)
		end
	end

	local selectBtn = self.bindData["item" .. self.SelectIndex]

	if selectBtn and selectBtn.enabledTooltip then
		selectBtn.OpenTooltip(selectBtn)
	end
end

M.OnSimpleRenderPlayerAttrListItem = function(self, btn, index)
	local data = self.playerAttrData and self.playerAttrData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = AttributeNameConfig.GetConfig(data.id)
	store.title = cfg and cfg.AttributeName or ""
	store.value = gRoguelikeManager:FormatAttributeValue(data.value, cfg and cfg.ShowType)
end

M.OnSimpleRenderMoneyListItem = function(self, btn, index)
	if index ~= 0 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		gCommonItemManager:OnRenderMoneyItem(btn, self.moneyView.templateId, {
			["n\t\\x8c\\x9f\\xb4ٓ\\xcd:\\xa78\\x93?"] = false,
			changeCount = self.moneyView.changeCount or ""
		})
	end
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local data = self.buffData and self.buffData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.LIST_TEMPLATE.ITEM then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		local buffCfg = BuffConfig.GetConfig(data.buffId)

		if buffCfg then
			store.icon = buffCfg.IconIdSGUI
			store.name = buffCfg.Name
			store.qualityCtrl = buffCfg.Quality

			store:Commit("desc", buffCfg.Description, COMMIT_IMMEDIATELY)
			store.layoutBox:ForceRebuildLayoutImmediate()
		end
	end
end

M.OnGetListTIndex = function(self, index)
	local data = self.buffData and self.buffData[index + 1]

	if not data then
		return self.LIST_TEMPLATE.SPLIT
	end

	return data.tIndex or self.LIST_TEMPLATE.SPLIT
end

M.OnStickMove = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed then
		self.UpdateSmoothMoveVector(self)
		self.SetSmoothMove(self, value)
	elseif context.canceled then
		self.ClearSmoothMove(self)
	end
end
