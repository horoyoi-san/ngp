-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DartSelectPanelStore.lua
-- Decompiled from: 01515_DartSelectPanelStore.lua_c4fbc5a59d12.luajit

C_DartSelectPanelStore = DefClass("C_DartSelectPanelStore", C_DartSelectPanelStore, C_StoreGroup)
GroupName2Class.DartSelectPanelStore = C_DartSelectPanelStore
local M = C_DartSelectPanelStore
local ConsumableConfig = LTConfig.ConsumableConfig
local Input = UnityEngine.Input
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput

M.OnAwake = function(self)
	self.bindData.ConfirmBtnClick = self.CreateAction(self, "OnConfirm")
	self.bindData.CancelBtnClick = self.CreateAction(self, "OnCancel")
	self.bindData.SelectBtn.luaClick = self.CreateAction(self, "OnSelect")
	self.bindData.DartsList.luaClick = self.CreateAction(self, "OnSelectChange")
	self.bindData.DartsList.luaRenderItem = self.CreateAction(self, "OnRenderTabItem")
	InputActionBind.onLuaActiveDeviceChanged = self.CreateAction(self, "OnActionDeviceChanged")
	self.currentInputDevice = InputActionBind.activeGameDevice
	UCursorInput.onCursorPosChange = self.CreateAction(self, "onCursorPosChange")
	UCursorInput.onCursorStatusChange = self.CreateAction(self, "onCursorStatusChange")
	self.bindData.txtItemSelectInfo = ""
end

M.OnActionDeviceChanged = function(self)
	self.currentInputDevice = InputActionBind.activeGameDevice
end

M.onCursorStatusChange = function(self, isActive)
	if not isActive then
		self.currentCursorPos = nil

		if gDartsGameManager.currentDartsGame then
			gDartsGameManager.currentDartsGame:IsAimDarts(nil)
		end
	end
end

M.onCursorPosChange = function(self, position)
	self.currentCursorPos = position
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	if gDartsGameManager._isMatchMode or gTaskUtils:CheckIsInCultivation() then
		self.bindData.CancelBtn.gameObject:SetActive(false)
	else
		self.bindData.CancelBtn.gameObject:SetActive(true)
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnUpdate = function(self)
	local pos = nil

	if gDartsGameManager.currentDartsGame ~= nil then
		return
	end

	if self.currentInputDevice ~= GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		pos = Input.mousePosition
	elseif self.currentInputDevice ~= GameDevice.PlayStation or self.currentInputDevice ~= GameDevice.Xbox then
		pos = self.currentCursorPos

		if pos ~= nil then
			return
		end

		local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
		local width = rect.rect.width
		local height = rect.rect.height
		local worldPos = rect:TransformPoint(Vector3.New(pos.x - width / 2, pos.y - height / 2, 0))
		pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		if Input.touchCount < 0 then
			pos = nil

			return
		else
			pos = Input.mousePosition
		end
	end

	local hitInfo = gCS.LuaUtils.GetUIToCameraHit(pos)

	if hitInfo.transform ~= nil then
		return
	end

	if hitInfo.collider ~= nil then
		return
	end

	local hitGO = hitInfo.collider.transform
	local hitIdx = gDartsGameManager.currentDartsGame:IsAimDarts(hitGO)

	if hitIdx ~= nil then
		self.currentSelectIndex = nil

		return
	end

	self.currentSelectIndex = hitIdx
end

M.OnSelect = function(self)
	if self.currentSelectIndex then
		self.currentSelectDart = self.dartsDatas[self.currentSelectIndex]
		local str = "E"

		if self.currentSelectDart.ItemQuality ~= 1 then
			str = "E"
		elseif self.currentSelectDart.ItemQuality ~= 2 then
			str = "D"
		elseif self.currentSelectDart.ItemQuality ~= 3 then
			str = "C"
		elseif self.currentSelectDart.ItemQuality ~= 4 then
			str = "B"
		elseif self.currentSelectDart.ItemQuality ~= 5 then
			str = "A"
		elseif self.currentSelectDart.ItemQuality ~= 6 then
			str = "S"
		else
			print_error("#NoCreateIssue 该飞镖品质不该显示等级，请检查配表", self.currentSelectDart.ItemQuality)
		end

		local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
		self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str

		gSoundMgr:PlaySoundByTid(70601329)
		gDartsGameManager.currentDartsGame:OnSelectDart(self.currentSelectIndex)
	end
end

M.OnRenderTabItem = function(self, btn, index)
	if self.dartsDatas ~= nil then
		return
	end

	if index > #self.dartsDatas then
		return
	end

	local data = self.dartsDatas[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if data.Id ~= 0 then
		store.Btn.gameObjectActive = false

		return
	end

	store.Id = data.Id
	store.ImageId = data.ImageId
	store.DartName = data.DartName
	store.Index = data.Index

	if self.currentSelectIndex ~= index + 1 then
		self.OnSelectIdx(self, self.currentSelectIndex, true)
	end
end

M.OnShow = function(self, panelId, data)
	self.dartsDatas = {}

	for i = 0, LTConfig.PoiGameDartConfig.count - 1 do
		local config = LTConfig.PoiGameDartConfig.LoadAt(i)
		local itemId = config.ItemId
		local packItemInfo = gCommonItemManager:GetPackItemByTemplateId(itemId)

		if packItemInfo then
			local itemConfig = ConsumableConfig.GetConfig(itemId)
			local index = #self.dartsDatas + 1

			table.insert(self.dartsDatas, {
				Id = config.Id,
				ImageId = itemConfig.SItemIconId,
				DartName = itemConfig.Name,
				Index = index,
				ItemQuality = itemConfig.Quality
			})
		else
			table.insert(self.dartsDatas, {
				[")\r"] = 0
			})
		end
	end

	self.bindData.DartsList:SetList(#self.dartsDatas)

	if #self.dartsDatas > 0 then
		self.bindData.txtItemSelectInfo = ""
	end

	gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(true, self.dartsDatas)
end

M.OnClose = function(self)
end

M.OnSelectIdx = function(self, idx, init)
	if init then
		self.currentSelectIndex = -1
	end

	if self.currentSelectIndex == idx then
		self.currentSelectIndex = idx
		local have, btn = self.bindData.DartsList:TryGetChildAt(idx - 1, _)

		btn:LuaSimulateClick()

		self.currentSelectDart = self.dartsDatas[idx]
		local str = "E"

		if self.currentSelectDart.ItemQuality ~= 1 then
			str = "E"
		elseif self.currentSelectDart.ItemQuality ~= 2 then
			str = "D"
		elseif self.currentSelectDart.ItemQuality ~= 3 then
			str = "C"
		elseif self.currentSelectDart.ItemQuality ~= 4 then
			str = "B"
		elseif self.currentSelectDart.ItemQuality ~= 5 then
			str = "A"
		elseif self.currentSelectDart.ItemQuality ~= 6 then
			str = "S"
		else
			print_error("#NoCreateIssue 该飞镖品质不该显示等级，请检查配表", self.currentSelectDart.ItemQuality)
		end

		gSoundMgr:PlaySoundByTid(70601329)

		local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
		self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str
	end
end

M.OnModelSelect = function(self, idx)
	self.OnSelectIdx(self, idx)
end

M.OnSelectChange = function(self, uBtn, listIndex)
	self.currentSelectDart = self.dartsDatas[listIndex + 1]
	local str = "E"

	if self.currentSelectDart.ItemQuality ~= 1 then
		str = "E"
	elseif self.currentSelectDart.ItemQuality ~= 2 then
		str = "D"
	elseif self.currentSelectDart.ItemQuality ~= 3 then
		str = "C"
	elseif self.currentSelectDart.ItemQuality ~= 4 then
		str = "B"
	elseif self.currentSelectDart.ItemQuality ~= 5 then
		str = "A"
	elseif self.currentSelectDart.ItemQuality ~= 6 then
		str = "S"
	else
		print_error("#NoCreateIssue 该飞镖品质不该显示等级，请检查配表", self.currentSelectDart.ItemQuality)
	end

	gSoundMgr:PlaySoundByTid(70601329)

	local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
	self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str

	gDartsGameManager.currentDartsGame:OnSelectDart(listIndex + 1)
end

M.OnConfirm = function(self, eventId, data, array, arrayIndex)
	if self.currentSelectDart then
		if self.lastClickTime == nil and gLogicTime.time - self.lastClickTime >= 2 then
			return
		end

		self.lastClickTime = gLogicTime.time

		gDartsGameManager.currentDartsGame:SelectDart(self.currentSelectDart.Id)

		if gDartsGameManager.currentDartsGame.online then
			self.bindData.onlineCtrl = 1
			self.bindData.SelectBtn.interactable = false
			self.bindData.confirmInteractable = false
		end
	end
end

M.OnCancel = function(self)
	if gDartsGameManager._isSkip then
		gSpoonClientMgr:ReleaseContextEvent(gDartsGameManager._dart_gadgetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnDartInterrupt, {
			npcId = gDartsGameManager._dartNpcCfg.Id,
			gadgetId = gDartsGameManager._dart_gadgetId
		})
	end

	gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)
	gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(false, nil, gDartsGameManager._isSkip)
end

M.InitSnap = function(self, snapsGoList)
	if self.bindData.snapTargetTemp ~= nil then
		return
	end

	if self.snapsRectList == nil then
		for i = 1, #self.snapsRectList do
			UnityEngine.GameObject.Destroy(self.snapsRectList[i])
		end
	end

	self.snapsRectList = {}

	for i = 1, #snapsGoList do
		if snapsGoList[i] == nil then
			local dartSnap = UnityEngine.GameObject.Instantiate(self.bindData.snapTargetTemp.gameObject, self.bindData.snapTargetTemp.transform.parent)
			self.snapsRectList[i] = dartSnap

			gCS.LuaUtils.SetInScreenRangeRectByBoxCollider(snapsGoList[i].gameObject, self.bindData.RootRect, dartSnap.GetComponent(dartSnap, typeof(UnityEngine.RectTransform)))
		end
	end
end
