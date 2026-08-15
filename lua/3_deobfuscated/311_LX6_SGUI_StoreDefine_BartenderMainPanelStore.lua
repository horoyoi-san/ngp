C_BartenderMainPanelStore = DefClass("C_BartenderMainPanelStore", C_BartenderMainPanelStore, C_StoreGroup)
GroupName2Class.BartenderMainPanelStore = C_BartenderMainPanelStore
local M = C_BartenderMainPanelStore
local GameInputManager = LX6.Manager.GameInputManager

function M:ctor()
	self.CHECK_CTRL = {
		CHECK = 1,
		NORMAL = 0,
		NONE = 2
	}
end

function M:OnShow(panelId, data)
	self.data = data
	self.startTime = gLogicTime.unscaledTime
	self.showCountDown = true
	self.tipsTarget = nil
	self.tipsTargetFollowPos = nil
	self.tipsTargetScreenPos = nil
	self.tipsCamera = gCS.CameraDataMgr.MainCamera
	self.curTipsData = {
		itemVolumeText = "",
		volumeCtrl = 0,
		infoTypeCtrl = 0,
		itemTitleText = ""
	}
	self.floatingTipsStore = gStoreManager:GetStoreGroup("BartenderTipsPanelStore"):GetStoreByWidget(self.bindData.floatingTips)
	self.fixedTipsStore = gStoreManager:GetStoreGroup("BartenderTipsPanelStore"):GetStoreByWidget(self.bindData.fixedTips)
	self.moveSpeed = LTConfig.BartenderConfig.PlayerMoveSpeed or 2
	self.moveAction = self:CreateAction(self.OnJoyStickMove)

	GameInputManager.RegisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveAction)

	self.isShowHints = true
	self.hintsDic = {}

	for _, v in pairs(gBartendManager.posList) do
		self:OnNpcEnter(v)
	end

	self:SetTipsCtrl(false)
	self:SetPourCtrl(0)
	self:SetShakerCtrl(0)
end

function M:OnDestroy()
	self:ClearMessageEvents()
	GameInputManager.UnregisterInputCallback(gInputActionId.MOVEMENT_MOVE, self.moveAction)
end

function M:OnAwake()
	gBartendManager:OnStoreAwake()

	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.showMenuBtn.luaClick = self:CreateAction(self.OnShowMenuBtnClick)
	self.bindData.useLongPressBtn.luaBeginLongPress = self:CreateAction(self.OnUseBtnBeginLongPress)
	self.bindData.useLongPressBtn.luaEndLongPress = self:CreateAction(self.OnUseBtnEndLongPress)
	self.bindData.cancelClickBtn.luaClick = self:CreateAction(self.OnCancelBtnClick)
	self.bindData.shakeBtn.luaClick = self:CreateAction(self.OnShakeBtnClick)

	self.bindData.shakeBtn:SetActive(false)

	self.bindData.shakeEndBtn.luaClick = self:CreateAction(self.OnShakeBtnClick)
	self.bindData.drinkBtn.luaClick = self:CreateAction(self.OnDrinkBtnClick)
	self.bindData.pourEndBtn.luaClick = self:CreateAction(self.OnPourEndBtnClick)
	self.bindData.volumeList.luaRenderItem = self:CreateAction(self.OnRenderVolumeItem)

	function self.bindData.volumeList.onGetTIndex(_)
		return 0
	end
end

function M:OnEnable()
	self.scrollValue = 0

	self:SetMenu()
end

function M:OnUpdate()
	if self.showCountDown then
		self:RefreshCountDown()
	end

	if gBartendManager:IsPouring() then
		gBartendManager:UpdateVolume()
		self:RefreshVolumeList()
	end

	self:MoveMeUnit()
	self:RefreshAllHintsPosition()
end

function M:RefreshVolumeList()
	self.bindData.volumeList:SetList(gBartendManager:GetVolumeListNum())
end

function M:OnCameraUpdate()
	self:UpdateTipsPosition()
	gBartendManager:OnCameraUpdate()
end

function M:MoveMeUnit()
	if gBartendManager.isLockAction then
		return
	end

	if not self.lastInput or self.lastInput == Vector2.zero then
		return
	end

	local moveDir = self:GetHorDirInCamera(self.lastInput, gCS.CameraDataMgr.MainCamera.transform)
	local movement = moveDir * self.moveSpeed * gLogicTime.deltaTime
	gBartendManager.meUnit.LocalPosition = gBartendManager.meUnit.LocalPosition + Vector3.New(movement.x, 0, movement.y)
end

function M:OnJoyStickMove(e)
	local input = e:ReadValueVector2()
	self.lastInput = input
end

function M:GetHorDirInCamera(inputValue, cameraTrans)
	local cameraRad = math.rad(cameraTrans.eulerAngles.y)
	local inputRad = Mathf.Atan2(inputValue.y, inputValue.x)
	local rad = inputRad - cameraRad
	local result = Vector2.New(math.cos(rad), math.sin(rad))

	return result
end

function M:RefreshAllHintsPosition()
	for _, v in pairs(self.hintsDic) do
		if not v or not v.target or gCS.LuaUtils.IsNull(v.target) then
			return
		end

		local worldFollowPos = v.target.position + Vector3.New(0, 2, 0)
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(worldFollowPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local screenPos = gCS.LuaUtils.ScreenPointUI(self.bindData.hintsContainerWidget.rectTransform, Vector2.New(x, y))

		v.widget.rectTransform:SetLocalPositionXY(screenPos.x, screenPos.y)
	end
end

function M:CreateHints()
	local go = UnityEngine.Object.Instantiate(self.bindData.hintsTemplateWidget.gameObject)

	go.transform:SetParent(self.bindData.hintsContainerWidget.rectTransform, false)

	local widget = go:GetComponent(typeof(SGUI.UWidget))

	go:SetActive(true)
	widget:SetActive(self.isShowHints)

	return widget
end

function M:OnNpcEnter(customer)
	if self.hintsDic[pid] then
		print_error("Bartender hints already exists for pid:", ulong.tostring(pid))

		return
	end

	local widget = self:CreateHints()
	local data = {
		widget = widget,
		target = customer.unit.PlayerObj
	}
	self.hintsDic[customer.id] = data
end

function M:OnNpcLeave(customer)
	if not self.hintsDic[customer.id] then
		print_error("Bartender hints not exists for pid:", ulong.tostring(customer.id))

		return
	end

	UnityEngine.Object.Destroy(self.hintsDic[customer.id].widget)

	self.hintsDic[customer.id] = nil
end

function M:SetShowFloatingHints(isShow)
	self.isShowHints = isShow

	for _, v in pairs(self.hintsDic) do
		v.widget:SetActive(isShow)
	end
end

function M:RefreshCountDown()
	self.nowTime = gLogicTime.unscaledTime
	self.bindData.curTime = self:GetFormatCountDownTime(self.nowTime - self.startTime)
end

function M:GetFormatCountDownTime(seconds)
	seconds = math.floor(seconds)
	local hour = math.floor(seconds / 3600)
	local min = math.floor(seconds % 3600 / 60)
	local sec = seconds % 60

	if hour > 0 then
		return gString.Format("%02d:%02d:%02d", hour, min, sec)
	else
		return gString.Format("%02d:%02d", min, sec)
	end
end

function M:SetMenu()
	self.menuCfg = gBartendManager:GetMenuCfg()
	self.startStore = gStoreManager:GetStoreGroup("BartenderProcedureTemplateStore"):GetStoreByWidget(self.bindData.startMenu)
	self.startStore.title = self.menuCfg.DrinkMenuName
	self.startStore.des = self.menuCfg.DrinkMenuDescription
	self.startStore.list.luaSimpleRenderItem = self:CreateAction("OnRenderMenuItem")
	self.menuList = {}

	for i, v in pairs(self.menuCfg.MenuStep) do
		local data = {
			id = v,
			selected = false,
			check = self.CHECK_CTRL.NORMAL
		}
		data.must = gBartendManager:CheckIsNeeded(data.id) and 1 or 0

		table.insert(self.menuList, data)
	end

	self.startStore.list:SetSimpleList(#self.menuList)
end

function M:RefreshMenuList(container)
	self.menuList = {}
	local isChecked = false

	for i, v in pairs(self.menuCfg.MenuStep) do
		isChecked = i <= #container.beforeShakeCheckList and container.beforeShakeCheckList[i] or container.afterShakeCheckList[i]
		local data = {
			id = v,
			selected = false,
			check = isChecked and self.CHECK_CTRL.CHECK or self.CHECK_CTRL.NORMAL
		}
		data.must = gBartendManager:CheckIsNeeded(data.id) and 1 or 0

		table.insert(self.menuList, data)
	end

	self.startStore.list:SetSimpleList(#self.menuList)
end

function M:OnRenderMenuItem(btn, index)
	local store = gStoreManager:GetStoreGroup("BartenderListTemplateStore"):GetStoreByWidget(btn)
	local data = self.menuList[index + 1]
	store.check = data.check
	store.must = data.must
	local cfg = LTConfig.BartenderMenuStepConfig.GetConfig(data.id)
	store.des.text = cfg.StepDescription
end

function M:SetState(type)
	self.bindData.typeCtrl = type
end

function M:SetPourCtrl(type)
	self.bindData.pourCtrl = type
end

function M:SetShakerCtrl(type)
	self.bindData.shakerCtrl = type
end

function M:SetShowDrinkBtn(isShow)
	self.bindData.drinkCtrl = isShow and 1 or 0
end

function M:SetStatusCtrl(type)
	self.bindData.statusCtrl = type
end

function M:SetCrossHairCtrl(isShow)
	self.bindData.crossHairCtrl = isShow and 0 or 1
end

function M:RefreshTemperatureProgress(value)
	self.bindData.temperatureProgress:ProgressToValue(value)
end

function M:SetVolumeCtrl(isShow)
	self.bindData.volumeCtrl = isShow and 1 or 0
end

function M:SetTempCtrl(type)
	self.bindData.tempCtrl = type
end

function M:SetTempPerfectArea(min, max, perfectMin, perfectMax)
	local totalWidth = self.bindData.temperatureProgress.rectTransform.rect.size.x
	local totalTemp = max - min
	local perfectMinX = totalWidth * ((perfectMin - min) / totalTemp - 0.5)
	local perfectMaxX = totalWidth * ((perfectMax - min) / totalTemp - 0.5)
	self.bindData.temperaturePerfectMin.anchoredPosition = Vector2.New(perfectMinX, 0)
	self.bindData.temperaturePerfectMax.anchoredPosition = Vector2.New(perfectMaxX, 0)
end

function M:SetTipsCtrl(isShow)
	self.bindData.floatingTipsCtrl = isShow and 1 or 0

	self:RefreshTipsContent()
end

function M:RefreshTipsContent()
	local store = gBartendManager:IsPourState() and self.fixedTipsStore or self.floatingTipsStore
	store.itemTitleText = self.curTipsData.itemTitleText
	store.infoTypeCtrl = self.curTipsData.infoTypeCtrl
	store.itemVolumeText = self.curTipsData.itemVolumeText
	store.volumeCtrl = self.curTipsData.volumeCtrl
end

function M:SetTipsSimpleContent(title)
	self.curTipsData.itemTitleText = title
	self.curTipsData.infoTypeCtrl = 0
	self.curTipsData.volumeCtrl = 0

	self:RefreshTipsContent()
end

function M:SetTipsOverfillContent()
	self.curTipsData.itemTitleText = ""
	self.curTipsData.infoTypeCtrl = 2

	self:RefreshTipsContent()
end

function M:SetTipsVolumeContent(title, volume, isPerfect)
	self.curTipsData.itemTitleText = title
	self.curTipsData.infoTypeCtrl = 1
	self.curTipsData.itemVolumeText = string.format("%.1f", volume)
	self.curTipsData.volumeCtrl = isPerfect and 1 or 0

	self:RefreshTipsContent()
end

function M:SetTipsTarget(target)
	self.tipsTarget = target
end

function M:UpdateTipsPosition()
	if not self.tipsTarget or gCS.LuaUtils.IsNull(self.tipsTarget) then
		return
	end

	self.tipsTargetWorldFollowPos = self.tipsTarget.transform.position + Vector3.New(0, 0.3, 0)
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(self.tipsTargetWorldFollowPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local screenPos = gCS.LuaUtils.ScreenPointUI(self.bindData.floatingTips.rectTransform.parent, Vector2.New(x, y))

	self.bindData.floatingTips.rectTransform:SetLocalPositionXY(screenPos.x, screenPos.y)
end

function M:OnUseBtnBeginLongPress()
	gBartendManager:OnUseBtnBeginLongPress()
end

function M:OnUseBtnEndLongPress()
	gBartendManager:OnUseBtnEndLongPress()
end

function M:OnCancelBtnClick()
	gBartendManager:OnCancelBtnClick()
end

function M:IsCanPour()
	return gBartendManager:IsPouring() and self.canPour
end

function M:OnRenderVolumeItem(btn, index)
	local store = gStoreManager:GetStoreGroup("BartenderVolumeInfoStore"):GetStoreByWidget(btn)
	local data = gBartendManager:GetVolumeListByIndex(index + 1)

	if not data then
		return
	end

	store.color = data.color
	local height = self.bindData.volumeListRect.rect.height * data.percent
	store.rect.sizeDelta = Vector2.New(self.bindData.volumeListRect.rect.width / 2, height)
	local oz = data.percent * gBartendManager.curHoverContainerData.ozLimit

	if data.percent >= 0.05 then
		store.name = data.name
		store.oz = string.format("%.2f", oz) .. " oz"
	else
		store.name = ""
		store.oz = ""
	end
end

function M:OnBackBtnClick()
	gBartendManager:EndBartend()
end

function M:OnShowMenuBtnClick()
	gPanelManager:CheckShow(gPanelId.S_BARTENDER_INFO_PANEL)
end

function M:OnDrinkBtnClick()
	gBartendManager:OnDrinkBtnClick()
end

function M:OnPourEndBtnClick()
	gBartendManager:OnPourEndBtnClick()
end

function M:OnShakeBtnClick()
	gBartendManager:OnShakeBtnClick()
end

function M:EndGame(accuracyScore, speedScore, temperatureScore)
	self.showCountDown = false
	self.bindData.endCtrl = 1

	self.bindData.radarChart:SetVertexValue(0, accuracyScore * 100)
	self.bindData.radarChart:SetVertexValue(1, speedScore * 100)
	self.bindData.radarChart:SetVertexValue(2, temperatureScore * 100)
end

function M:GetSpeedScore()
	local data = gBartendManager:GetMenuCfg().TimeScoreTiers

	for i, v in pairs(data) do
		if self.nowTime - self.startTime <= v.maxtime then
			return v.score / 100
		end
	end

	return 0
end
