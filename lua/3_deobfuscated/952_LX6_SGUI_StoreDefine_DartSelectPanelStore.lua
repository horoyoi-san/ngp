C_DartSelectPanelStore = DefClass("C_DartSelectPanelStore", C_DartSelectPanelStore, C_StoreGroup)
GroupName2Class.DartSelectPanelStore = C_DartSelectPanelStore
local M = C_DartSelectPanelStore
local ConsumableConfig = LTConfig.ConsumableConfig
local Input = UnityEngine.Input
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput

function M:OnAwake()
	self.bindData.ConfirmBtnClick = self:CreateAction("OnConfirm")
	self.bindData.CancelBtnClick = self:CreateAction("OnCancel")
	self.bindData.SelectBtn.luaClick = self:CreateAction("OnSelect")
	self.bindData.DartsList.luaClick = self:CreateAction("OnSelectChange")
	self.bindData.DartsList.luaRenderItem = self:CreateAction("OnRenderTabItem")
	InputActionBind.onLuaActiveDeviceChanged = self:CreateAction("OnActionDeviceChanged")
	self.currentInputDevice = InputActionBind.activeGameDevice
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")
	UCursorInput.onCursorStatusChange = self:CreateAction("onCursorStatusChange")
	self.bindData.txtItemSelectInfo = ""
end

function M:OnActionDeviceChanged()
	self.currentInputDevice = InputActionBind.activeGameDevice
end

function M:onCursorStatusChange(isActive)
	if not isActive then
		self.currentCursorPos = nil

		if gDartsGameManager.currentDartsGame then
			gDartsGameManager.currentDartsGame:IsAimDarts(nil)
		end
	end
end

function M:onCursorPosChange(position)
	self.currentCursorPos = position
end

function M:OnDestroy()
	return
end

function M:OnStart()
	if gDartsGameManager._isMatchMode then
		self.bindData.CancelBtn.gameObject:SetActive(false)
	else
		self.bindData.CancelBtn.gameObject:SetActive(true)
	end
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnUpdate()
	local pos = nil

	if gDartsGameManager.currentDartsGame == nil then
		return
	end

	if self.currentInputDevice == GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		pos = Input.mousePosition
	elseif self.currentInputDevice == GameDevice.PlayStation or self.currentInputDevice == GameDevice.Xbox then
		pos = self.currentCursorPos

		if pos == nil then
			return
		end

		local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
		local width = rect.rect.width
		local height = rect.rect.height
		local worldPos = rect:TransformPoint(Vector3.New(pos.x - width / 2, pos.y - height / 2, 0))
		pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		if Input.touchCount <= 0 then
			pos = nil

			return
		else
			pos = Input.mousePosition
		end
	end

	local hitInfo = gCS.LuaUtils.GetUIToCameraHit(pos)

	if hitInfo.collider == nil then
		return
	end

	local hitGO = hitInfo.collider.transform
	local hitIdx = gDartsGameManager.currentDartsGame:IsAimDarts(hitGO)

	if hitIdx == nil then
		return
	end

	self.currentSelectIndex = hitIdx
end

function M:OnSelect()
	if self.currentSelectIndex then
		self.currentSelectDart = self.dartsDatas[self.currentSelectIndex]
		local str = "A"

		if self.currentSelectDart.ItemQuality == 1 or self.currentSelectDart.ItemQuality == 0 then
			str = "C"
		elseif self.currentSelectDart.ItemQuality == 2 then
			str = "B"
		elseif self.currentSelectDart.ItemQuality == 3 then
			str = "A"
		elseif self.currentSelectDart.ItemQuality == 4 then
			str = "S"
		end

		local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
		self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str

		gDartsGameManager.currentDartsGame:OnSelectDart(self.currentSelectIndex)
	end
end

function M:OnRenderTabItem(btn, index)
	if self.dartsDatas == nil then
		return
	end

	if index >= #self.dartsDatas then
		return
	end

	local data = self.dartsDatas[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if data.Id == 0 then
		store.Btn.gameObjectActive = false

		return
	end

	store.Id = data.Id
	store.ImageId = data.ImageId
	store.DartName = data.DartName
	store.Index = data.Index

	if self.currentSelectIndex == index + 1 then
		self:OnSelectIdx(self.currentSelectIndex, true)
	end
end

function M:OnShow(panelId, data)
	self.dartsDatas = {}

	for i = 0, LTConfig.PoiGameDartConfig.count - 1 do
		local config = LTConfig.PoiGameDartConfig.LoadAt(i)
		local itemId = config.ItemId
		local packItemInfo = gPlayerItemManager:GetPackItemByTemplateId(itemId)

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
				Id = 0
			})
		end
	end

	self.bindData.DartsList:SetList(#self.dartsDatas)

	if #self.dartsDatas <= 0 then
		self.bindData.txtItemSelectInfo = ""
	end

	gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(true, self.dartsDatas)
end

function M:OnClose()
	return
end

function M:OnSelectIdx(idx, init)
	if init then
		self.currentSelectIndex = -1
	end

	if self.currentSelectIndex ~= idx then
		self.currentSelectIndex = idx
		local have, btn = self.bindData.DartsList:TryGetChildAt(idx - 1, _)

		btn:LuaSimulateClick()

		self.currentSelectDart = self.dartsDatas[idx]
		local str = "A"

		if self.currentSelectDart.ItemQuality == 1 or self.currentSelectDart.ItemQuality == 0 then
			str = "C"
		elseif self.currentSelectDart.ItemQuality == 2 then
			str = "B"
		elseif self.currentSelectDart.ItemQuality == 3 then
			str = "A"
		elseif self.currentSelectDart.ItemQuality == 4 then
			str = "S"
		end

		local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
		self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str
	end
end

function M:OnModelSelect(idx)
	self:OnSelectIdx(idx)
end

function M:OnSelectChange(uBtn, listIndex)
	self.currentSelectDart = self.dartsDatas[listIndex + 1]
	local str = "A"

	if self.currentSelectDart.ItemQuality == 1 or self.currentSelectDart.ItemQuality == 0 then
		str = "C"
	elseif self.currentSelectDart.ItemQuality == 2 then
		str = "B"
	elseif self.currentSelectDart.ItemQuality == 3 then
		str = "A"
	elseif self.currentSelectDart.ItemQuality == 4 then
		str = "S"
	end

	local labelString = LTConfig.TextScriptTextConfig.GetConfig(89901073).Text
	self.bindData.txtItemSelectInfo = self.currentSelectDart.DartName .. "/" .. labelString .. ": " .. str

	gDartsGameManager.currentDartsGame:OnSelectDart(listIndex + 1)
end

function M:OnConfirm(eventId, data, array, arrayIndex)
	if self.currentSelectDart then
		if self.lastClickTime ~= nil and gLogicTime.time - self.lastClickTime < 2 then
			return
		end

		self.lastClickTime = gLogicTime.time

		gDartsGameManager.currentDartsGame:SelectDart(self.currentSelectDart.Id)
	end
end

function M:OnCancel()
	if gDartsGameManager._isSkip then
		gSpoonClientMgr:ReleaseContextEvent(gDartsGameManager._dart_gadgetId, gSpoonEventType.OnDartInterrupt, {
			npcId = gDartsGameManager._dartNpcCfg.Id,
			gadgetId = gDartsGameManager._dart_gadgetId
		})
	end

	gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)
	gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(false, nil, gDartsGameManager._isSkip)
end

function M:InitSnap(snapsGoList)
	if self.bindData.snapTargetTemp == nil then
		return
	end

	if self.snapsRectList ~= nil then
		for i = 1, #self.snapsRectList do
			UnityEngine.GameObject.Destroy(self.snapsRectList[i])
		end
	end

	self.snapsRectList = {}

	for i = 1, #snapsGoList do
		if snapsGoList[i] ~= nil then
			local dartSnap = UnityEngine.GameObject.Instantiate(self.bindData.snapTargetTemp.gameObject, self.bindData.snapTargetTemp.transform.parent)
			self.snapsRectList[i] = dartSnap

			gCS.LuaUtils.SetInScreenRangeRectByBoxCollider(snapsGoList[i].gameObject, self.bindData.RootRect, dartSnap:GetComponent(typeof(UnityEngine.RectTransform)))
		end
	end
end
