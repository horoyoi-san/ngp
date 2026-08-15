local GameObject = UnityEngine.GameObject
C_HintInfosHudStore = DefClass("C_HintInfosHudStore", C_HintInfosHudStore, C_StoreGroup)
GroupName2Class.HintInfosHudStore = C_HintInfosHudStore
local M = C_HintInfosHudStore
local GameConfig = LTConfig.GameConfig
local MindButtonTypeType = LTConfig.BattleMindPowerInteractConfig.MindButtonTypeType
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local DestructibleConfig = LTConfig.DestructibleConfig
local QueryUnitUtils = LX6.Utils.QueryUnitUtils
local Vector3One = Vector3.one
local Vector3Zero = Vector3.zero
local Vector3Forward = Vector3.forward
local Vector3Up = Vector3.up
M.pcBtns = {}
M.mobileBtns = {}
M.indicateList = {}
M.minScale = 0.5
M.testMobile = false
M.state = nil
M.showSelectVX = nil
M.showStrengthenIcon = nil
M.selectVXTimer = nil
M.isPlayingAnim = false
M.animDelay = nil
M.waitSwitchIsDrag = false
M.isDrag = nil
M.currentMindType = MindPowerConst.MindObjType.None
M.currentMindId = 0
M.curMindEnemyPid = 0
M.totalPcNum = 0
M.mindIconId = 28001165
M.hackSkillListData = {}
M.isController = false
M.lockEffectTargetInfo = {
	isUnit = false,
	pid = 0
}
local IconShowMode = {
	HalfAlpha = 1,
	Hide = 0,
	Show = 2
}
local PanelState = {
	Press = 3,
	Click = 1,
	Drag = 4,
	None = 0
}
M.MindInteractionType = {
	Press = 2,
	Click = 1,
	Drag = 3,
	None = 0
}
local EnvironmentalKillIconCtrl = {
	MouseLeft = 1,
	Text = 0,
	MouseRight = 2
}
local MindObjType = MindPowerConst.MindObjType
M.showMindIcon = nil
M.showMode = IconShowMode.Hide
M.ellipseScaleX = 0.0317
M.ellipseScaleY = 0.046
M.ellipseX = 200
M.ellipseY = 100
M.ellipseOffsetX = 0
M.ellipseOffsetY = 10

function M:ctor()
	self.msgEvents = {
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("BeforeSwitchScene"),
		[gEventConstants.NEW_INTERACT_CHANGE] = self:CreateAction("OnNewBtnChange"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self:CreateAction("OnControllerSettingChange"),
		[gEventConstants.UNIT_HAS_REWARD_REFRESH] = self:CreateAction("OnUnitHasRewardOrFansRefresh"),
		[gEventConstants.UNIT_HAS_FANS_REFRESH] = self:CreateAction("OnUnitHasRewardOrFansRefresh")
	}
end

function M:OnAwake()
	gInteractionManager.hintInfosHudStore = self
	self.bindData.interactionBtnList.luaSimpleRenderItem = self:CreateAction("OnRenderInteractionItem")
	self.bindData.interactionBtnList.luaSimpleClick = self:CreateAction("OnInteractionTempClick")
	self.bindData.interactionBtn1.luaClick = self:CreateAction("OnInteractionBtn1Click")
	self.bindData.interactionBtn2.luaClick = self:CreateAction("OnInteractionBtn2Click")
	self.bindData.interactionBtn3.luaClick = self:CreateAction("OnInteractionBtn3Click")
	self.bindData.interactionTipBtn1.luaClick = self:CreateAction("OnInteractionBtn1Click")
	self.bindData.interactionTipBtn2.luaClick = self:CreateAction("OnInteractionBtn2Click")
	self.bindData.interactionTipBtn3.luaClick = self:CreateAction("OnInteractionBtn3Click")
	self.bindData.controllerInteractBtn.luaPress = self:CreateAction("OnInteractionControllerBtnPress")
	self.bindData.controllerInteractBtn.luaRelease = self:CreateAction("OnInteractionControllerBtnRelease")
	self.bindData.showLockEffect = false
	self.isPlayingAnim = false

	self:CancelMindPowerAnim()

	self.waitSwitchIsDrag = false
	self.isDrag = nil
	self.state = nil
	self.showSelectVX = nil
	self.showStrengthenIcon = nil
	self.currentMindType = MindPowerConst.MindObjType.None
	self.currentMindId = 0
	self.isInSwitching = true
	self.isInInteraction = false
	self.ellipseX = GameConfig.HintInfosHudPanelEllipseX
	self.ellipseY = GameConfig.HintInfosHudPanelEllipseY
	self.ellipseScaleX = GameConfig.HintInfosHudPanelEllipseScaleX
	self.ellipseScaleY = GameConfig.HintInfosHudPanelEllipseScaleY
	self.ellipseOffsetX = GameConfig.HintInfosHudPanelEllipseOffsetX
	self.ellipseOffsetY = GameConfig.HintInfosHudPanelEllipseOffsetY

	QueryUnitUtils.PrepareHintsHudStoreEllipse(self.ellipseX, self.ellipseY, self.ellipseScaleX, self.ellipseScaleY, self.ellipseOffsetX, self.ellipseOffsetY)

	self.showMode = IconShowMode.Hide
end

function M:OnStart()
	self.controllerAnim = self.bindData.controllerInteractBtnTrans:GetComponent(typeof(UnityEngine.Animation))
	self.bindData.activePcInteractBtn = 0
	self.bindData.isPc = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 0
	self.tempGo = self.bindData.temp.gameObject
	self.tempRoot = self.tempGo.transform.parent

	for i, data in ipairs(gInteractionManager.registerInteractIndicateList) do
		self:RegisterIndicateTarget(data)
	end

	gInteractionManager.registerInteractIndicateList = {}
	self.showPlayerHint = {}

	self:ShowOrHidePlayerHint(false, false, 0)
	self:ShowOrHidePlayerHint(false, false, 1)
	self:ShowEnemyExecuteHint(false)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:OnControllerSettingChange(_, gameProfile.isNewControllerSetting)
	end
end

local frameCount = 0
local isXBoxHideMindPower = false
local pcBtnIsNotNil = false

function M:OnCameraUpdate()
	MindObjType = MindPowerConst.MindObjType
	isXBoxHideMindPower = self:XBoxHideMindPower()
	pcBtnIsNotNil = #self.pcBtns ~= 0
	local myPlayer = gCS.MyPlayerManager.PlayerUnit

	self:UpdateLockEffectPos()
	self:UpdatePlayerHintPos()
	self:UpdateExecuteHintPos()

	if not myPlayer or not myPlayer.PlayerObj or not self.bindData.pcBtn then
		return
	end

	local myPlayerPos = myPlayer.LocalPosition
	local mainCam = gCS.CameraDataMgr.MainCamera

	if QueryUnitUtils.PrepareMainCamera ~= nil then
		QueryUnitUtils.PrepareMainCamera(mainCam, myPlayerPos)
	end

	frameCount = frameCount + 1

	if frameCount >= 30 then
		frameCount = 0
		self.bindData.isPc = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 0
		self.isController = gClientUtils.IsControllerMode()

		if self.testMobile then
			self.bindData.isPc = 0
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("NormalUpdate")
	end

	self:NormalUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("InteractUpdate")
	end

	self:InteractUpdate()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
		gCS.LuaUtils.BeginSample("RefreshHackInteractView")
	end

	self:RefreshHackInteractView()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:NormalUpdate()
	if self.bindData.isPc == 1 then
		self.bindData.clickPlatform = 1
		self.bindData.pressPlatform = 1
		self.bindData.dragPlatform = 1
	end

	if self.isInSwitching then
		self:MindPowerUpdate()
	end

	self:RefreshHackSkillPos()
end

function M:InteractUpdate(force)
	if not gCS.MyPlayerManager.PlayerUnit or gCS.LuaUtils.IsNull(gCS.MyPlayerManager.PlayerUnit.PlayerObj) then
		return
	end

	for pid, list in pairs(self.indicateList) do
		for index, data in pairs(list) do
			if gLogicTime.frameCount % 3 == 0 then
				self.mindAbleStatic = gPlayerManager.main.bindData.isMindPowerStaticActive

				self:RefreshIndicateTempShow(data)
			end

			self:RefreshIndicateTempState(data)
		end
	end

	if self.bindData.isPc == 1 then
		self:RefreshPcBtnShow()
		self:RefreshControllerBtn()
		self:RefreshActivePcInteractBtn()
	end
end

function M:XBoxHideMindPower()
	return gClientUtils.IsControllerMode()
end

function M:OnDestroy()
	if self.selectVXTimer then
		self.selectVXTimer:Stop()

		self.selectVXTimer = nil
	end

	self:CancelMindPowerAnim()

	gInteractionManager.hintInfosHudStore = nil

	if self.btnLoopTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.btnLoopTimer)
	end
end

function M:OnGroupEnable()
	self.hack = gStoreManager:GetStoreGroup("HackerSkillNotify"):GetStoreByWidget(self.bindData.HackerSkillNotify)
	self.hack.skillList.luaRenderItem = self:CreateAction("OnRenderHackSkillItem")
	self.hack.skillList.onGetTIndex = self:CreateAction("OnGetTIndex")

	self:RegisterMessageEvents(self.msgEvents)
	self:RefreshClickPCText()
	self:RefreshMindIcon()
	self:HideEnvironmentalKill()
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:BeforeSwitchScene(eventId, switchType)
	if switchType == gSwitchSceneType.Reconnect then
		return
	end

	for pid, list in pairs(self.indicateList) do
		for index, data in pairs(list) do
			if not gCS.LuaUtils.IsNull(data.instanceObj) then
				GameObject.Destroy(data.instanceObj.gameObject)
			end
		end
	end

	table.clear(self.indicateList)
	self:ClearAllHackSkill()
end

M.isInDis = nil
M.isTargetNull = nil
M.mindDir = nil

function M:RefreshIndicateTempShow(data)
	if data.enable then
		if data.GetTarget and type(data.GetTarget) == "userdata" then
			local originalGetTarget = data.GetTarget

			function data.GetTarget()
				return originalGetTarget:DynamicInvoke()
			end
		end

		if data.InDis and type(data.InDis) == "userdata" then
			local originalInDis = data.InDis

			function data.InDis()
				return originalInDis:DynamicInvoke()
			end
		end

		if data.IndicateDisRate and type(data.IndicateDisRate) == "userdata" then
			local originalIndicateDisRate = data.IndicateDisRate

			function data.IndicateDisRate()
				return originalIndicateDisRate:DynamicInvoke()
			end
		end

		self.isTargetNull = gCS.LuaUtils.IsNull(data.GetTarget())

		if not data.isMindPower and self.isTargetNull then
			return
		end

		if data.isMindPower then
			if not gClientUtils.CheckCurrentIsDefaultSpirit() then
				self:SetIndicateIsShow(data, false)

				return
			end

			local playerIsInFight = false
			playerIsInFight = gCS.MindPowerMgr:PlayerIsInFight()
			self.isInDis = (not playerIsInFight or data.showInBattle) and data.InDis()
		else
			self.isInDis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, data.GetTarget():GetPosition()) < data.dis
		end

		if self.isInDis and data.isMindPower and not self.isTargetNull then
			self.isInDis = self.isInDis and not self:IsCurAimGadget(data.pid)
			self.mindDir = data.GetTarget().forward
			self.mindDir.y = 0

			if self.mindDir:Magnitude() < 1e-06 then
				self.mindDir = Vector3Forward
			end

			if data.isAllDirPress then
				local delta = gCS.MyPlayerManager.PlayerUnit.LocalPosition - data.GetTarget():GetPosition()

				if delta.x * delta.x + delta.z * delta.z < data.tooNearRadius * data.tooNearRadius and math.abs(delta.y) < data.exDisH then
					self.isInDis = true
				end
			else
				local size = data.tooNearRange
				local localPoint = Quaternion.Inverse(Quaternion.LookRotation(self.mindDir)) * (gCS.MyPlayerManager.PlayerUnit.LocalPosition - data.GetTarget().position)
				local inRange = localPoint.z > 0 and Mathf.Abs(localPoint.x) <= size.x and Mathf.Abs(localPoint.y) <= size.y and Mathf.Abs(localPoint.z) <= size.z

				if inRange then
					self.isInDis = true
				end
			end

			if not self.mindAbleStatic then
				self.isInDis = false
			end
		end

		if self.isInDis and gCS.MindPowerMgr.AimItem and gCS.MindPowerMgr.AimItem:IsAccumulating() and data.pid == gCS.MindPowerMgr.AimItem.EntityInstanceId then
			self.isInDis = false
		end

		if self.isInDis and data.isHack then
			if data.pid == gGadgetManager.hackInfoTargetId then
				self.isInDis = false
			elseif gGadgetManager.HackInteractTarget and gGadgetManager.HackInteractTarget.entityId == data.entityId then
				self.isInDis = false
			end
		end

		if self.isInDis then
			if not data.instanceObj then
				data.instanceObj = GameObject.Instantiate(self.tempGo, self.tempRoot).transform

				data.instanceObj:GetComponent(typeof(SGUI.UWidget)):TryInit()

				data.instanceObj.name = "temp_" .. ulong.tostring(data.pid)
				data.strongScaleObj = data.instanceObj:Find("Strong/Scale")
				data.strongWarnObj = data.instanceObj:Find("Strong/TooShort")

				data.instanceObj:Find("Strong").gameObject:SetActive(data.isImportant and not data.isHack)
				data.instanceObj:Find("Light").gameObject:SetActive(not data.isImportant and not data.isHack)
				data.instanceObj:Find("Hack").gameObject:SetActive(data.isHack and not data.isHackLock)
				data.instanceObj:Find("HackLock").gameObject:SetActive(data.isHack and data.isHackLock)
			end

			self:SetIndicateIsShow(data, true)
		else
			self:SetIndicateIsShow(data, false)
		end
	end
end

function M:RefreshHackIndicateState(entityId, index, isLock)
	if not self.indicateList[entityId] then
		return
	end

	local data = self.indicateList[entityId][index]

	if data and data.instanceObj then
		data.instanceObj:Find("Hack").gameObject:SetActive(not isLock)
		data.instanceObj:Find("HackLock").gameObject:SetActive(isLock)
	end
end

function M:IsCurAimGadget(pid)
	if not gCS.MindPowerMgr.AimItem or gCS.MindPowerMgr.AimItem.ItemType ~= MindPowerConst.MindObjType.Slot then
		return false
	end

	return ulong.equals(gCS.MindPowerMgr.AimItem.EntityInstanceId, pid)
end

function M:SetIndicateIsShow(data, show)
	if not data.instanceObj then
		return
	end

	if show and GpsHelper.CheckHasSlotGPSTarget(data.pid) then
		show = false
	end

	show = show and not self:SlotInteractAble(data.pid, data.GetTarget())
	show = show and not self:IndicateHasBlock(data.GetTarget(), data.entityGo)

	if data.isShow == show then
		return
	end

	data.isShow = show

	if not gCS.LuaUtils.IsNull(data.instanceObj) then
		data.instanceObj.gameObject:SetActive(show)
	end
end

function M:IndicateHasBlock(target, go)
	if not target or not go then
		return false
	end

	return not L50.L50App.Scene.HackManager:CheckSlotIndicateVisiable(target, go)
end

function M:SlotInteractAble(pid, trans)
	return L50.L50App.L50Game.InteractBtnMgr:ExistShowBtn(pid, trans)
end

function M:TrySetPickItemAbleByComp(data, enable)
	return
end

function M:RefreshIndicateTempState(data)
	if not data.isShow or gClientUtils.IsNil(data.instanceObj) then
		self:TrySetPickItemAbleByComp(data, false)

		return
	end

	if gCS.LuaUtils.IsNull(data.GetTarget()) then
		return
	end

	local worldPos = data.GetTarget().position

	if data.offsetY then
		worldPos = worldPos + Vector3Up * data.offsetY
	end

	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(worldPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(data.instanceObj.parent, Vector3.New(x, y, 0))

	data.instanceObj:SetLocalPositionXY(UIPos.x, UIPos.y)

	if data.isImportant and data.strongScaleObj then
		local rate = gCS.CurveManager.GetIndicateScaleCurve(data.IndicateDisRate())
		local scale = self.minScale + (GameConfig.InteractionPosNotifyUiFillScale - self.minScale) * rate
		scale = Mathf.Clamp(scale, self.minScale, GameConfig.InteractionPosNotifyUiFillScale)
		data.strongScaleObj.localScale = Vector3One * scale
	end

	if data.isMindPower then
		local inRange = nil

		if data.isAllDirPress then
			local delta = gCS.MyPlayerManager.PlayerUnit.LocalPosition - data.GetTarget():GetPosition()
			inRange = delta.x * delta.x + delta.z * delta.z < data.tooNearRadius * data.tooNearRadius and math.abs(delta.y) < data.exDisH
		else
			local dir = data.GetTarget().forward
			dir.y = 0

			if dir == Vector3Zero then
				dir = Vector3Up
			end

			local localPoint = Quaternion.Inverse(Quaternion.LookRotation(dir)) * (gCS.MyPlayerManager.PlayerUnit.LocalPosition - worldPos)
			local size = data.tooNearRange
			inRange = localPoint.z > 0 and Mathf.Abs(localPoint.x) <= size.x and Mathf.Abs(localPoint.y) <= size.y and Mathf.Abs(localPoint.z) <= size.z
		end

		if inRange then
			data.strongWarnObj.gameObject:SetActive(true)

			data.isTooShort = true

			self:TrySetPickItemAbleByComp(data, true)
		else
			data.strongWarnObj.gameObject:SetActive(false)

			data.isTooShort = false

			self:TrySetPickItemAbleByComp(data, false)
		end
	else
		data.strongWarnObj.gameObject:SetActive(false)

		data.isTooShort = false
	end
end

function M:Angle2(dir1, dir2)
	dir1.y = 0
	dir2.y = 0

	return Vector3.Angle(dir1, dir2)
end

function M:RegisterIndicateTarget(data)
	if data.ToTable then
		data = data:ToTable()
	end

	if self.indicateList[data.pid] and self.indicateList[data.pid][data.index] then
		self:UnRegisterIndicateTarget(data.pid, data.index)
	end

	if not self.indicateList[data.pid] then
		self.indicateList[data.pid] = {}
	end

	self.indicateList[data.pid][data.index] = data

	if data.enable == nil then
		data.enable = true
	end
end

function M:SetMindIndicateTargetEnable(pid, enable)
	if not self.indicateList[pid] then
		return
	end

	for i, v in pairs(self.indicateList[pid]) do
		if v.isMindPower then
			v.enable = enable

			if not enable then
				self:SetIndicateIsShow(v, false)
			end
		end
	end
end

function M:UnRegisterIndicateTarget(pid, index)
	if not self.indicateList[pid] then
		return
	end

	if index == nil then
		for i, v in pairs(self.indicateList[pid]) do
			if not gCS.LuaUtils.IsNull(v.instanceObj) then
				GameObject.Destroy(v.instanceObj.gameObject)
			end
		end

		self.indicateList[pid] = nil
	else
		if self.indicateList[pid][index] and not gCS.LuaUtils.IsNull(self.indicateList[pid][index].instanceObj) then
			GameObject.Destroy(self.indicateList[pid][index].instanceObj.gameObject)
		end

		self.indicateList[pid][index] = nil

		if table.is_empty(self.indicateList[pid]) then
			self.indicateList[pid] = nil
		end
	end
end

function M:RefreshBtn(btns)
	self.pcBtns = btns
	L50.L50App.L50Game.InteractBtnMgr.luaInteracBtnCount = self.pcBtns and #self.pcBtns or 0

	if self.bindData.isPc == 0 then
		self.mobileBtns = self:CombineSameBtns(btns)

		if not self:HasNewBtn() then
			self.interactionBtnListData = self.mobileBtns

			self.bindData.interactionBtnList:SetSimpleList(#self.mobileBtns)
		end
	end

	self:InteractUpdate(true)
end

function M:OnNewBtnChange()
	if self.bindData.isPc == 1 then
		self:RefreshPcBtnShow(true)

		return
	end

	if #self.mobileBtns > 0 then
		return
	end

	local list = {}

	for i = 0, L50.L50App.L50Game.InteractBtnMgr.usefulList.Count - 1 do
		local data = L50.L50App.L50Game.InteractBtnMgr.usefulList[i]

		table.insert(list, {
			iconId = data:GetIconId(),
			name = data.text,
			isGray = data.isGray,
			isAvailable = data.isAvailable == true,
			isEffect = data.isEffect,
			DoClick = function ()
				data:DoClick()
			end
		})
	end

	self.interactionBtnListData = list

	self.bindData.interactionBtnList:SetSimpleList(#list)
end

function M:RefreshPcBtnShow(force)
	for i = 1, 3 do
		self:SetPcInteractBtnShow(nil, i, 0, force)
		self:SetPcInteractTipBtnShow(i, 0)
	end

	self.totalPcNum = L50.L50App.L50Game.InteractBtnMgr.usefulList.Count

	if self.totalPcNum == 0 then
		return
	end

	if L50.L50App.L50Game.InteractBtnMgr.usefulList[0].targetType == 2 then
		self.totalPcNum = 1
	end

	local pos = L50.L50App.L50Game.InteractBtnMgr.usefulList[0].iconPos
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.pcBtn.parent, Vector3.New(x, y, 0))

	self.bindData.pcBtn:SetLocalPositionXY(UIPos.x, UIPos.y)
	self.bindData.controllerInteractBtnTrans:SetLocalPositionXY(UIPos.x, UIPos.y)

	self.bindData.activePcInteractBtn = 1

	for i = 0, self.totalPcNum - 1 do
		local data = L50.L50App.L50Game.InteractBtnMgr.usefulList[i]
		local index = i + 1

		self:SetInteractionTextShow(index, data.pcHideText and 0 or 1)
		self:SetInteractionIconShow(index, data.pcShowIcon and 1 or 0)
		self:SetInteractionBtnText(index, data.text)
		self:SetPcInteractBtnShow(data, index, data.pcHidePos and 0 or 1, force)

		if data.pcHidePos then
			self:SetPcInteractTipBtnShow(index, 1, data.pcKeyInputId)
		end

		if data.isGray then
			self.bindData.OtherStatus = 1
		elseif not data.isAvailable then
			self.bindData.OtherStatus = 2
		else
			self.bindData.OtherStatus = 0
		end
	end
end

M.targetBtn = nil
M.targetBtns = {}
M.oldBtns = {}
local minAngle, curAngle, curPos, targetPos, playerObj, camDir = nil

function M:RefreshActivePcInteractBtn()
	self.isController = gClientUtils.IsControllerMode()
	self.bindData.activePcInteractBtn = self.totalPcNum > 0 and (not self.isController or self.totalPcNum <= 1) and 1 or 0
end

function M:RefreshControllerBtn()
	if self:HasHidePosBtn() then
		gMainMenuMgr:NoUsePowerWhenCanInteractive(true)

		self.bindData.InteractController = 0
	elseif not self.isController or self.totalPcNum == 0 then
		gMainMenuMgr:NoUsePowerWhenCanInteractive(false)

		self.bindData.InteractController = 0
	elseif self.totalPcNum == 1 then
		gMainMenuMgr:NoUsePowerWhenCanInteractive(true)

		self.bindData.InteractController = 4
	else
		gMainMenuMgr:NoUsePowerWhenCanInteractive(true)

		if self.isControllerPress then
			if self.totalPcNum == 2 then
				self.bindData.InteractController = 1
			elseif self.totalPcNum == 3 then
				self.bindData.InteractController = 2
			end
		else
			self.bindData.InteractController = 3
		end
	end
end

function M:SetPcInteractBtnShow(btn, index, show, force)
	if self.bindData["showPcInteractBtn" .. index] ~= show or force then
		if show == 1 then
			self:PlayAnimByIndex(index, btn)
		end

		self.bindData["showPcInteractBtn" .. index] = show
	end
end

local ControllerKeyNameList = {
	6,
	18,
	20
}

function M:SetPcInteractTipBtnShow(index, show, inputId)
	if self.bindData["showInteractTipBtn" .. index] ~= show then
		self.bindData["showInteractTipBtn" .. index] = show
	end

	if show == 1 then
		self.bindData["interactionTipBtn" .. index]:SetPCKeyInfoTipNameId(inputId or 2)

		if self.bindData.naviArea then
			self.bindData.naviArea:ChangeButtonNameByActionId(ControllerKeyNameList[index], inputId or 2)
		end
	end
end

function M:SetInteractionTextShow(index, show)
	self.bindData["ShowInteractionText" .. index] = show
end

function M:SetInteractionGrayShow(info)
	if not info.target or not info.target.data or info.target.unit then
		return
	end

	self.bindData.OtherStatus = info.target.data.IsGray and 1 or 0
end

function M:SetInteractionIconShow(index, show)
	self.bindData["ShowInteractionIcon" .. index] = show
end

function M:SetInteractionBtnText(index, str)
	self.bindData["InteractionBtnText" .. index] = str
end

function M:SetInteractionBtnIcon(index, icon)
	self.bindData["InteractionBtnIcon" .. index] = icon
end

function M:PlayAnimByIndex(index, btn)
	local anim = self.bindData["btnAnim" .. index]
	local two_anim = self.bindData["2btnAnim" .. index]
	local three_anim = self.bindData["3btnAnim" .. index]

	if btn and btn.isEffect then
		if anim then
			anim:Play("S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end

		if two_anim then
			two_anim:Play("S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end

		if three_anim then
			three_anim:Play("S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end
	else
		if anim then
			anim:Play("S_Vx_HintInfosHudPanel_pcconsole_stay")
		end

		if two_anim then
			two_anim:Play("S_Vx_HintInfosHudPanel_pcconsole_stay")
		end

		if three_anim then
			three_anim:Play("S_Vx_HintInfosHudPanel_pcconsole_stay")
		end
	end
end

function M:CombineSameBtns(btns)
	local newBtns = {}
	local textIdList = {}

	for i, data in ipairs(btns) do
		if not textIdList[data.name] then
			data.combineTargets = {}

			table.insert(newBtns, data)

			textIdList[data.name] = data
		end

		table.insert(textIdList[data.name].combineTargets, data)
	end

	return newBtns
end

function M:OnRenderInteractionItem(btn, index)
	local data = self.interactionBtnListData[index + 1]
	local store = gStoreManager:GetStoreGroup("InteractionBtnStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = data.name
	store.iconId = data.iconId
	store.Interact = not data.isGray and data.isAvailable

	if data.isGray then
		store.OtherStatus = 1
	elseif not data.isAvailable then
		store.OtherStatus = 2
	else
		store.OtherStatus = 0
	end

	if data.isEffect then
		store.anim:Play("S_Vx_InteractionTemplate_Mobile_loop")
	else
		store.anim:Stop()
		store.anim:Play("S_Vx_InteractionTemplate_Mobile_close")
	end
end

function M:OnInteractionTempClick(btn, index)
	local data = self.interactionBtnListData[index + 1]

	data.DoClick()
end

function M:GetMinCombineTarget(targets)
	playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj.transform
	camDir = gCS.CameraDataMgr.MainCamera.transform.forward
	curPos = nil
	local minAngle, targetBtn = nil

	for i, btn in ipairs(targets) do
		if btn.target.unit then
			curPos = btn.target.unit.UpBodyBone and btn.target.unit.UpBodyBone.position or btn.target.unit.LocalPosition
		elseif not gCS.LuaUtils.IsNull(btn.target.data.BtnTargetTrans) then
			curPos = btn.target.data.BtnTargetTrans.position + Vector3Up * (btn.target.data.offsetY or 0)
		else
			curPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition + Vector3Up
		end

		curAngle = self:Angle2(camDir, curPos - playerObj.position)

		if not minAngle or curAngle < minAngle then
			minAngle = curAngle
			targetPos = curPos
			targetBtn = btn
		end
	end

	return targetBtn
end

function M:OnInteractionBtn1Click()
	self:OnInteractionBtnClick(1)
end

function M:OnInteractionBtn2Click()
	self:OnInteractionBtnClick(2)
end

function M:OnInteractionBtn3Click()
	self:OnInteractionBtnClick(3)
end

function M:OnInteractionBtnClick(index)
	if self:IsInClickCD() then
		return
	end

	if not self:HasNewBtn() then
		return
	end

	local btn = L50.L50App.L50Game.InteractBtnMgr.usefulList[index - 1]

	if self.isController and not self.isControllerPress and not self:IsHidePosBtn(btn) then
		return
	end

	btn:DoClick()
end

M.clickCDTime = 0.8
M.lastClickTime = 0

function M:IsInClickCD()
	if gLogicTime.time - self.lastClickTime < self.clickCDTime then
		return true
	end

	return false
end

function M:IsHidePosBtn(btn)
	if not btn then
		return false
	end

	return btn.pcHidePos
end

function M:HasHidePosBtn()
	for i, v in ipairs(self.targetBtns) do
		if self:IsHidePosBtn(v) then
			return true
		end
	end

	return false
end

function M:OnInteractionControllerBtnPress()
	self.isControllerPress = true

	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.ControllerInteract, true)
	gBattleMgr.characterControlPanel.characterControlData.dodgeBtn.gameObject:SetActive(false)

	if self.totalPcNum == 1 then
		self:OnInteractionBtnClick(1)
	elseif self.totalPcNum > 1 then
		self:RefreshActivePcInteractBtn()
	end

	if self.totalPcNum == 2 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_two_open")
	elseif self.totalPcNum == 3 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Three_open")
	end
end

function M:OnInteractionControllerBtnRelease()
	self.isControllerPress = false

	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.ControllerInteract, false)
	gBattleMgr.characterControlPanel.characterControlData.dodgeBtn.gameObject:SetActive(true)
	self:RefreshActivePcInteractBtn()

	if self.totalPcNum == 2 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_two_close")
	elseif self.totalPcNum == 3 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Three_close")
	end
end

function M:SetInteractionType(mindInteractionType)
	if self.bindData.mindInteractionType == mindInteractionType then
		return
	end

	self.bindData.mindInteractionType = mindInteractionType

	if mindInteractionType == self.MindInteractionType.Click then
		self.bindData.VXDrag = 0
		self.bindData.dragFill = 0
	elseif mindInteractionType == self.MindInteractionType.Press then
		self.bindData.outPress = 1
		self.bindData.pressFill = 0
	end
end

function M:CalculatePosition(pos)
	if not self.state then
		return
	end

	local state = self.state
	local bindData = self.bindData
	local trans = nil

	if state == PanelState.Click then
		trans = bindData.clickTrans
	elseif state == PanelState.Press then
		trans = bindData.pressTrans
	elseif state == PanelState.Drag then
		trans = bindData.dragTrans
	end

	local isInView, transIsNull, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRectParent(pos, trans, false, _, _, _, _)

	if transIsNull then
		return
	end

	if not isInView then
		if state == PanelState.Click then
			bindData.outClick = 0

			bindData.clickOutAngle:SetLocalEulerAnglesZ(eulerZ)
		elseif state == PanelState.Press then
			bindData.outPress = 0

			bindData.pressOutAngle:SetLocalEulerAnglesZ(eulerZ)
		end

		trans:SetLocalPositionXY(x, y)
	else
		if state == PanelState.Click then
			bindData.outClick = 1
		elseif state == PanelState.Press then
			bindData.outPress = 1
		end

		trans:SetLocalPositionXY(x, y)
	end
end

function M:PlayAnimation(state)
	if not state then
		return
	end

	local name = nil

	if state == PanelState.Press then
		name = "S_Vx_MindPowerNotify_LongPressSuccess"

		self.bindData.pressAnimation:Play(name)

		self.bindData.pressFill = 1

		return gCS.LuaUtils.GetAnimationTime(self.bindData.pressAnimation, name), self.bindData.pressAnimation
	elseif state == PanelState.Click then
		name = "S_Vx_MindPowerNotify_DragSuccess"

		self.bindData.dragAnimation:Play(name)

		self.bindData.dragFill = 1

		return gCS.LuaUtils.GetAnimationTime(self.bindData.dragAnimation, name), self.bindData.dragAnimation
	end
end

function M:ChangeCurrentMindEnemy(pid)
	if ulong.equals(self.curMindEnemyPid, pid) then
		return
	end

	self.curMindEnemyPid = pid

	gMessageManager:SendMessage(gEventConstants.MIND_ICON_ENEMY_CHANGED, pid)
	gLockTargetMgr:CheckShowLockEffectActiveSguiByPid(pid)
end

function M:CancelMindPowerAnim()
	if self.animDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.animDelay)

		self.animDelay = nil
		self.isPlayingAnim = false
	end
end

function M:PlayMindPowerAnim()
	self:CancelMindPowerAnim()

	self.isPlayingAnim = true

	if self.state then
		local time, anim = self:PlayAnimation(self.state)

		if time then
			self.animDelay = gLuaTimeMgrUtils.Delay(function ()
				self.animDelay = nil
				self.isPlayingAnim = false

				if not gCS.LuaUtils.IsNull(anim) then
					anim:Stop()
				end

				self.bindData.mindPowerClick.renderOpacity = 1
				self.bindData.mindPowerLongPress.renderOpacity = 1
				self.bindData.mindPowerDrag.renderOpacity = 1
			end, time)
		else
			self.isPlayingAnim = false
		end
	end
end

function M:IsMindAimItemChangeCS(data)
	if data == nil then
		return self.currentMindType ~= MindObjType.None
	end

	return data.ItemType ~= self.currentMindType or data.ID ~= self.currentMindId
end

function M:NewRefreshMindPowerNotifyCS(data)
	local tmpShowMode = self:CurrentCanShowIconCS(data) and IconShowMode.Show or IconShowMode.Hide

	if tmpShowMode == self.showMode then
		return false
	end

	self.showMode = tmpShowMode

	if self.showMode == IconShowMode.Show then
		self.showMind = true
		self.bindData.showMindPower = 1
	else
		self.showMind = false
		self.bindData.showMindPower = 0
	end

	return true
end

function M:CurrentCanShowIconCS(data)
	if pcBtnIsNotNil and isXBoxHideMindPower then
		return false
	end

	local bindData = gPlayerManager.main.bindData

	if gCS.MindPowerMgr.inHoldMode or bindData.isInMagnetHold or gCS.MyPlayerManager.inRobMobileState then
		return false
	end

	if not bindData.canUseMindPower and not gCS.MindPowerMgr.needShowMindHintIcon then
		return false
	end

	if not data then
		return false
	end

	if not data:IsCurrentCanMind() then
		return false
	end

	if self.showOrHideExecuteHint or self.environmentalShow then
		return false
	end

	local mindInteractCfgId = gCS.MindPowerMgr:GetBattleMindPowerInteractConfig()
	local mindInteractCfg = LTConfig.BattleMindPowerInteractConfig.GetConfig(mindInteractCfgId)

	if mindInteractCfg and not mindInteractCfg.ShowInteractionIcon then
		return false
	end

	return true
end

function M:RefreshGetMindStateCS(data)
	local state = self:GetMindInteractionTypeCS(data)

	if state == self.state then
		return false
	end

	self.state = state

	return true
end

function M:GetMindInteractionTypeCS(data)
	if not self.showMind then
		return PanelState.None
	end

	return data:GetInteractionType()
end

function M:RefreshMindPowerAnimCS(data)
	if data == nil then
		return
	end

	local state = self.state

	if self.showSelectVX then
		self.bindData.VXPress = 1
		self.bindData.VXClick = 1
		self.bindData.VXDrag = 1
		self.showSelectVX = false
	else
		self.bindData.VXPress = 1
		self.bindData.VXClick = 1
		self.bindData.VXDrag = 1
	end

	if self.selectVXTimer then
		self.selectVXTimer:Stop()

		self.selectVXTimer = nil
	end

	if self.showMode ~= IconShowMode.Show then
		return
	end

	if self.bindData.isPc == 1 and (data.ItemType == MindObjType.Enemy or data.ItemType == MindObjType.Effect) then
		self.showSelectVX = true

		if state == PanelState.Click then
			self.bindData.VXClick = 0
		elseif state == PanelState.Press then
			self.bindData.VXPress = 0
		end
	end
end

function M:RefreshPadIconCS(data)
	if not data then
		return
	end

	if isXBoxHideMindPower then
		if not data then
			return
		end

		if data.ItemType == MindObjType.Slot then
			self.bindData.isGadget = 0
		else
			self.bindData.isGadget = 1
		end
	end
end

function M:RefreshMindItemStateCS(data)
	if not data then
		return
	end

	local tmp = 0

	if data.ItemType == MindObjType.Item then
		local cfg = DestructibleConfig.GetConfig(data.DestructibleCfgId)

		if cfg then
			local icon = cfg.ShowStrengthenIcon

			if icon == 1 then
				tmp = 1
			elseif icon == 2 then
				tmp = 2
			end
		end
	elseif data.ItemType == MindObjType.Arm then
		local arm = data
		local cfg = DestructibleConfig.GetConfig(arm.DestructibleCfgId)

		if cfg then
			local icon = cfg.ShowStrengthenIcon

			if icon == 1 then
				tmp = 1
			elseif icon == 2 then
				tmp = 2
			end
		end
	else
		tmp = 0
	end

	if tmp ~= self.showStrengthenIcon then
		if tmp == 0 then
			if self.state == PanelState.Click or self.state == PanelState.Press then
				self.showStrengthenIcon = tmp
				self.bindData.clickPowerUp = 1
				self.bindData.pressPowerUp = 1
			end
		elseif tmp == 1 then
			if self.state == PanelState.Click or self.state == PanelState.Press then
				self.showStrengthenIcon = tmp
				self.bindData.clickPowerUp = 0
				self.bindData.pressPowerUp = 0
			end
		elseif tmp == 2 and (self.state == PanelState.Click or self.state == PanelState.Press) then
			self.showStrengthenIcon = tmp
			self.bindData.clickPowerUp = 2
			self.bindData.pressPowerUp = 2
		end
	end
end

function M:RefreshNewMindPowerNotifyPosCS(data)
	if data == nil then
		return
	end

	local pos = data:GetMindPowerIconPos()

	if not pos then
		return
	end

	self:CalculatePosition(pos)
end

function M:RefreshNewMindPowerNotifyValueCS(data, fill)
	if data then
		self.bindData[fill] = data:GetMindPowerIconAmount()
	else
		self.bindData[fill] = 0
	end
end

function M:MindPowerUpdateCS()
	if self.isPlayingAnim then
		return
	end

	local item = gCS.MindPowerMgr:GetAimItem()
	local targetChanged = self:IsMindAimItemChangeCS(item)

	if targetChanged then
		if item then
			self.currentMindType = item.ItemType
			self.currentMindId = item.ID
		else
			self.currentMindType = MindObjType.None
			self.currentMindId = 0
		end

		gMessageManager:SendMessage(gEventConstants.MIND_POWER_CHANGE)
	end

	local showEnvironmentalKill = false

	if item and item.ItemType == MindObjType.Enemy then
		showEnvironmentalKill = true

		self:UpdateEnvironmentalKill(item)
	else
		self:HideEnvironmentalKill()
	end

	local showModeChanged = self:NewRefreshMindPowerNotifyCS(item) and not showEnvironmentalKill
	local stateChanged = false

	if targetChanged and self.showMode ~= IconShowMode.Hide and item then
		stateChanged = self:RefreshGetMindStateCS(item)
	end

	local anyChanged = showModeChanged or targetChanged or stateChanged

	if anyChanged then
		self:RefreshMindPowerAnimCS(item)
	end

	if self.showMode ~= IconShowMode.Hide then
		self:RefreshPadIconCS(item)

		if anyChanged then
			self:RefreshMindItemStateCS(item)
		end

		if anyChanged or self.waitSwitchIsDrag ~= self.isDrag then
			self.isDrag = self.waitSwitchIsDrag

			self:RefreshMindInteractionType()
		end

		self:RefreshNewMindPowerNotifyPosCS(item)

		if anyChanged then
			self:NewRefreshNotifyText()
		end

		self.bindData.PressDown = 0

		if gBattleMgr.characterControlPanel and gBattleMgr.characterControlPanel.mergeBtnDownCache then
			self.bindData.PressDown = gBattleMgr.characterControlPanel.mergeBtnDownCache[gBattleMgr.SkillBtnType.ControlPower] and 1 or 0
		end
	end

	if not self.state or self.isDrag then
		return
	end

	if self.showMode ~= IconShowMode.Hide then
		if self.state == PanelState.Press then
			self:RefreshNewMindPowerNotifyValueCS(item, "pressFill")
		end

		if self.state == PanelState.Click and self.isDrag then
			self:RefreshNewMindPowerNotifyValueCS(item, "dragFill")
		end
	end

	if showModeChanged or targetChanged then
		if self.showMode == IconShowMode.Hide then
			self:ChangeCurrentMindEnemy(0)
		elseif item then
			if item.ItemType == MindObjType.Enemy then
				self:ChangeCurrentMindEnemy(item.ID)
			else
				self:ChangeCurrentMindEnemy(0)
			end
		else
			self:ChangeCurrentMindEnemy(0)
		end
	end
end

function M:MindPowerUpdate()
	self:MindPowerUpdateCS()
end

function M:SetIsDrag(isDrag)
	if self.waitSwitchIsDrag == isDrag then
		return
	end

	self.waitSwitchIsDrag = isDrag
end

function M:RefreshMindInteractionType()
	if self.state == PanelState.Click then
		if not self.isDrag then
			self:SetInteractionType(self.MindInteractionType.Click)
		else
			self:SetInteractionType(self.MindInteractionType.Drag)
		end
	elseif self.state == PanelState.Press then
		self:SetInteractionType(self.MindInteractionType.Press)
	end
end

function M:NewRefreshNotifyText()
	local text = nil
	text = gCS.MindPowerMgr:TryGetCurrentAimNotifyText()

	if string.is_null_or_empty(text) then
		self.bindData.clickNotifyTextCompEnable = 0
		self.bindData.longPressNotifyTextCompEnable = 0
	else
		self.bindData.clickNotifyTextCompEnable = 1
		self.bindData.longPressNotifyTextCompEnable = 1
		self.bindData.clickNotifyText = text
		self.bindData.longPressNotifyText = text
	end
end

local NormalLockType = {
	Light = 1,
	Strong = 0
}
local NormalLockAniName = {
	open = "S_Vx_EnemyHint_Normal_open",
	loop = "S_Vx_EnemyHint_Normal_loop"
}
local WeakLockAniName = {
	open = "S_Vx_EnemyHint_Weak_open",
	loop = "S_Vx_EnemyHint_Weak_loop"
}

function M:ShowLockEffect(show, hintType, isStrong, targetInfo)
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("ShowLockEffect")
	end

	if show then
		local hint = self:GetStoreByWidget(self.bindData.lockEffect)
		hint.lockType = hintType
		hint.normalLockType = isStrong and NormalLockType.Strong or NormalLockType.Light
		targetInfo = targetInfo or self.lockEffectTargetInfo

		if targetInfo then
			if not self:CheckTargetIsSame(targetInfo) or not self.bindData.showLockEffect then
				self:PlayLockAnimation(hint, hintType)
			end

			self.lockEffectTargetInfo.isUnit = targetInfo.isUnit
			self.lockEffectTargetInfo.pid = targetInfo.pid
			self.lockEffectTargetInfo.target = targetInfo.target
			self.bindData.showLockEffect = true
		end
	else
		if self.bindData.showLockEffect then
			self.lastChangeFrame = Time.frameCount
		end

		self.bindData.showLockEffect = false
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:CheckTargetIsSame(targetInfo)
	if not self.lockEffectTargetInfo then
		return false
	end

	if not targetInfo then
		return true
	end

	if self.lockEffectTargetInfo.isUnit then
		return self.lockEffectTargetInfo == targetInfo.pid
	else
		return self.lockEffectTargetInfo.target == targetInfo.target
	end
end

function M:PlayLockAnimation(hint, hintType)
	if hintType == gLockTargetMgr.LockEnemyHintType.Weak then
		self:PlayWeakAni(hint, true)
	elseif hintType == gLockTargetMgr.LockEnemyHintType.Normal then
		self:PlayWeakAni(hint, false)
	elseif hintType == gLockTargetMgr.LockEnemyHintType.Large then
		self:PlayLargeAni(hint)
	end
end

function M:PlayWeakAni(hint, isWeak)
	if gLockTargetMgr.currentFightStateShowNormalLockEffect then
		return
	end

	gLockTargetMgr.currentFightStateShowNormalLockEffect = true
	local ani = isWeak and hint.weakLockAni or hint.normalLockAni
	local aniName = isWeak and WeakLockAniName or NormalLockAniName

	gBattleMgr:CommonPlayAniTool(ani, aniName.open, 0, 1, false, function ()
		gBattleMgr:CommonPlayAniTool(ani, aniName.loop, 0, 1)
	end)
end

function M:PlayLargeAni(hint)
	if self.largeLockHintTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.largeLockHintTimer)
	end

	hint.largeLockStatus = 1

	if self.lastChangeFrame == Time.frameCount then
		hint.largeLockStatus = 2

		return
	end

	self.largeLockHintTimer = gLuaTimeMgrUtils.Delay(function ()
		hint.largeLockStatus = 2
	end, 0.5)
end

function M:CheckHideLockEffect(hint, unit)
	local flag = false

	if gGadgetManager:AgentExistHackIcon(unit.Pid) then
		flag = true
	elseif self.showOrHideExecuteHint or self.environmentalShow == IconShowMode.Show then
		flag = true
	elseif gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.Perform) then
		flag = true
	end

	hint.lockEffectScale = flag and Vector3Zero or Vector3One

	return flag
end

function M:UpdateLockEffectPos()
	if not self.bindData.showLockEffect or not self.lockEffectTargetInfo then
		return
	end

	local hint = self:GetStoreByWidget(self.bindData.lockEffect)
	local pos = nil

	if self.lockEffectTargetInfo.isUnit then
		local unit = gCS.SceneDataMgr.GetUnit(self.lockEffectTargetInfo.pid)

		if not unit or unit.IsDead then
			self:ShowLockEffect(false)

			return
		end

		if self:CheckHideLockEffect(hint, unit) then
			return
		end

		if self.lockEffectTargetInfo.useTargetPos then
			if not gCS.LuaUtils.IsNull(self.lockEffectTargetInfo.target) then
				pos = self.lockEffectTargetInfo.target.position
			else
				pos = Vector3Zero
				pos.z = -100000
			end
		else
			pos = unit.UpBodyPosition
		end
	elseif not gCS.LuaUtils.IsNull(self.lockEffectTargetInfo.target) then
		pos = self.lockEffectTargetInfo.target.position
	else
		pos = Vector3Zero
		pos.z = -100000
	end

	local isInView, x, y, eulerZ, projX, projY = QueryUnitUtils.GetHintsHudStoreEllipseInfo(pos, _, _, _, _, _)
	local UIPos = Vector3Zero

	if isInView and not gCS.LuaUtils.IsNull(hint.lockEffectTrans) then
		if not hint.lastIsInView then
			hint.lastIsInView = true

			self:PlayLockAnimation(hint, hint.lockType == gLockTargetMgr.LockEnemyHintType.Weak)
		end

		UIPos = gCS.LuaUtils.TransformScreenPointToUI(hint.lockEffectTrans.parent, Vector3.New(projX, projY, 0))

		hint.lockEffectTrans:SetLocalPosition(UIPos.x, UIPos.y, 0)
	else
		hint.lastIsInView = false

		hint.lockEffectTrans:SetLocalPositionZ(-100000)
	end
end

function M:EnableFromInteraction(enable)
	gPanelManager:SetActiveById(gPanelId.S_HINT_INFOS_HUD, enable)
end

M.hackPressTimer = nil

function M:OnPressHackInteract()
	if not gGadgetManager.HackInteractTarget or gGadgetManager.HackInteractTarget.interactType == 2 then
		return
	end

	if self.hackAnimTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.hackAnimTimer)

		self.hackAnimTimer = nil
	end

	if self.hackPressTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.hackPressTimer)

		self.hackPressTimer = nil
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.hackClickAnim:Play("S_Vx_HintInfosHudPanel_Min2_open")
	end

	gGadgetManager.startPressTime = gLogicTime.time

	if gGadgetManager.HackInteractTarget.interactType ~= 3 then
		self:RefreshBattery()

		self.hackPressTimer = gLuaTimeMgrUtils.Delay(function ()
			M.hackPressTimer = nil

			if gGadgetManager.HackInteractTarget then
				if gCS.LuaUtils.IsNonMobileAdaptive() then
					self.bindData.hackPressAnim:Play("S_Vx_HintInfosHudPanel_Min2_loop")

					local time = self.bindData.hackPressAnim:GetClip("S_Vx_HintInfosHudPanel_Min2_loop").length
					self.hackAnimTimer = gLuaTimeMgrUtils.Delay(function ()
						self.bindData.hackPressAnim:Play("S_Vx_HintInfosHudPanel_Min2_loop2")

						self.hackAnimTimer = nil
					end, time)
				end

				gGadgetManager:SetHackInfoPanel(true, gGadgetManager.HackInteractTarget, true)
			end
		end, LTConfig.HackerConfig.HackPressTime)
	end
end

function M:RefreshBattery()
	if not gCS.MyPlayerManager.PlayerUnit or gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or not gLuaDataManager.isNetworkAvailable then
		return
	end
end

function M:OnReleaseHackInteract(ignoreAction)
	if not gGadgetManager.HackInteractTarget then
		gGadgetManager:SetHackInfoPanel(false)

		return
	end

	if gGadgetManager.HackInteractTarget.interactType == 2 then
		return
	end

	if self.hackPressTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.hackPressTimer)

		self.hackPressTimer = nil
	end

	self.bindData.hackClickAnim:Play("S_Vx_HintInfosHudPanel_Min")

	if gLogicTime.time - gGadgetManager.startPressTime < LTConfig.HackerConfig.HackPressTime or gGadgetManager.HackInteractTarget.interactType == 3 then
		if ignoreAction then
			return
		end

		if gGadgetManager.HackInteractTarget.interactType == 1 then
			return
		end

		if not gGadgetManager.HackInteractTarget or #gGadgetManager.HackInteractTarget.usefulBtns == 0 then
			return
		end

		if not gGadgetManager.HackInteractTarget.hackerId then
			local textId = self.clickAbleBtns[self.curSelect].id
			local unit = gGadgetManager.HackInteractTarget.unit

			gGadgetManager:AskHack(nil, function ()
				local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(unit, textId)

				gInteractionManager.hintInfosHudStore:AddHackSkillIcon(unit, skillType)
			end)

			return
		end

		local realIndex = nil
		local data = gGadgetManager.HackInteractTarget.usefulBtns[1]

		if data.state ~= 0 then
			self.bindData.lockAnim:Play("S_Vx_HackerSkillNotify_Unlock")

			return
		end

		realIndex = data.index - 1
		local target = gGadgetManager.HackInteractTarget

		gGadgetManager:AskHack(data.index, function ()
			gGadgetManager:DoHackClickAction()

			if target.isItem then
				gSpoonClientMgr:ReleaseContextEvent(target.entityId, gSpoonEventType.HackInteractTrigger, {
					index = realIndex
				})
			else
				gClientToGameSceneDelegate:AskHackingNpc(target.entityId, realIndex).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)
						print_error("AskHackingNpc err = ", err, realIndex, target)
					end
				end
			end
		end)
	else
		gGadgetManager:SetHackInfoPanel(false)
	end
end

function M:RefreshHackInteractView()
	if not gGadgetManager.HackInteractTarget then
		self.hack.mode = 2

		return
	end

	if table.isNilOrEmpty(gGadgetManager.HackInteractTarget.usefulBtns) then
		self.hack.showLabel = 0
		self.hack.lock = 0
	else
		local data = gGadgetManager.HackInteractTarget.usefulBtns[1]

		if self.hack.lock ~= data.state then
			self.hack.lock = data.state

			if self.hack.lock == 1 then
				self.bindData.lockAnim:Play("S_Vx_HackerSkillNotify_Unlock")
			end
		end

		local cfg = LTConfig.TextCommonTextConfig.GetConfig(data.id)
		self.hack.text = cfg and cfg.Text or ""
		self.hack.showLabel = gGadgetManager.HackInteractTarget.interactType == 1 and 0 or 1
	end

	if gHackManager.isShowHackInfoPanel then
		self.hack.mode = 0
	else
		self.hack.mode = 1
	end

	local target = gGadgetManager.HackInteractTarget.target

	if not target and gGadgetManager.HackInteractTarget.GetTarget then
		target = gGadgetManager.HackInteractTarget.GetTarget()
	end

	if gCS.LuaUtils.IsNull(target) then
		return
	end

	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(target.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.hack.root.parent, Vector3.New(x, y, 0))

	self.hack.root:SetLocalPositionXY(UIPos.x, UIPos.y)
end

M.hackSkillIconList = {}

function M:AddHackSkillIcon(unit, skillType)
	local data = self.hackSkillIconList[unit.Pid]

	if not data then
		data = {
			unit = unit,
			obj = unit.UpBodyBone
		}
		self.hackSkillIconList[unit.Pid] = data
	end

	if data.timer then
		gLuaTimeMgrUtils.CancelUnitDelay(data.timer)
	end

	local pid = unit.Pid
	data.timer = gLuaTimeMgrUtils.Delay(function ()
		self:RemoveHackSkillIcon(pid)
	end, 2)
	data.skillType = skillType

	self:RefreshHackSkillList()
end

function M:RemoveHackSkillIcon(pid)
	local data = self.hackSkillIconList[pid]

	if not data then
		return
	end

	if data.timer then
		gLuaTimeMgrUtils.CancelUnitDelay(data.timer)
	end

	self.hackSkillIconList[pid] = nil

	self:RefreshHackSkillList()
end

function M:RefreshHackSkillList()
	self.hackSkillListData = {}

	for _, data in pairs(self.hackSkillIconList) do
		table.insert(self.hackSkillListData, data)
	end

	self.hack.skillList:SetList(#self.hackSkillListData)
	self:RefreshHackSkillPos()
end

M.hackSkillIconMinDis = 5
M.hackSkillIconScale = Vector3.one

function M:RefreshHackSkillPos()
	for _, data in ipairs(self.hackSkillListData) do
		if data.UIObj then
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(data.obj.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
			local UIPos = gCS.LuaUtils.TransformScreenPointToUI(data.UIObj.parent, Vector3.New(x, y, 0))

			data.UIObj:SetLocalPositionXY(UIPos.x, UIPos.y)

			local dis = Mathf.Clamp(Vector3.Distance(gCS.CameraDataMgr.MainCamera.transform.position, data.obj.position), self.hackSkillIconMinDis, LTConfig.HackerConfig.HackNPCDistance)
			local scale = 1 - (dis - self.hackSkillIconMinDis) / (LTConfig.HackerConfig.HackNPCDistance - self.hackSkillIconMinDis)
			self.hackSkillIconScale.x = scale
			self.hackSkillIconScale.y = scale
			data.UIObj.localScale = self.hackSkillIconScale
		end
	end
end

function M:OnRenderHackSkillItem(btn, index)
	local store = gStoreManager:GetStoreGroup("HackerSkillTempStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.skillType = self.hackSkillListData[index + 1].skillType
	self.hackSkillListData[index + 1].UIObj = btn.transform
end

function M:OnGetTIndex(_)
	return 0
end

function M:ClearAllHackSkill()
	for pid, data in pairs(self.hackSkillIconList) do
		self:RemoveHackSkillIcon(pid)
	end

	self.hackSkillIconList = {}
end

function M:HasNewBtn()
	if not L50.L50App.L50Game.InteractBtnMgr then
		return false
	end

	return L50.L50App.L50Game.InteractBtnMgr:HasUsefulBtn()
end

function M:ShowOrHidePlayerHint(enable, isSucc, hintKey)
	local store = self:GetStoreByWidget(self.bindData.playerHint)

	if not store then
		return
	end

	self.playerHintKey = hintKey

	if enable then
		local _, rootCmp = self:GetPlayerHintCmp(store, self.playerHintKey)

		if rootCmp == nil then
			return
		end

		rootCmp:SetActive(enable)

		self.showPlayerHint[hintKey] = enable

		self:UpdatePlayerHintPos()
	else
		self:PlayPlayerHintAni(isSucc)
	end
end

function M:UpdatePlayerHintPos()
	if not self.showPlayerHint or not self.showPlayerHint[self.playerHintKey] then
		return
	end

	local posDelta = Vector3Up * 0.5
	local pos = gCS.MyPlayerManager.PlayerUnit.HeadPos
	pos = pos + posDelta
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.playerHint.transform.parent, Vector3.New(x, y, 0))

	self.bindData.playerHint.rectTransform:SetLocalPosition(UIPos.x, UIPos.y, 0)
end

function M:PlayPlayerHintAni(succ)
	local store = self:GetStoreByWidget(self.bindData.playerHint)

	if not store then
		return
	end

	local key = self.playerHintKey
	local aniCmp, rootCmp = self:GetPlayerHintCmp(store, key)

	if key == 0 then
		aniCmp = store.ani
		rootCmp = store.shakeStiffRoot
	elseif key == 1 then
		aniCmp = store.moveHintAni
		rootCmp = store.moveHintRoot
	else
		return
	end

	self:PlayPlayerHintAni_(succ, aniCmp, rootCmp, key)
end

function M:GetPlayerHintCmp(store, key)
	local aniCmp, rootCmp = nil

	if key == 0 then
		aniCmp = store.ani
		rootCmp = store.shakeStiffRoot
	elseif key == 1 then
		aniCmp = store.moveHintAni
		rootCmp = store.moveHintRoot
	else
		return
	end

	return aniCmp, rootCmp
end

function M:PlayPlayerHintAni_(succ, aniCmp, rootCmp, key)
	local aniName = "S_Vx_PlayerHint_Success"

	if not succ then
		if key == 1 then
			aniName = "S_Vx_PlayerHint_Failure2"
		else
			aniName = "S_Vx_PlayerHint_Failure"
		end
	end

	gBattleMgr:CommonPlayAniTool(aniCmp, aniName, 0, 1, true, function ()
		rootCmp:SetActive(false)

		self.showPlayerHint[key] = false

		self:UpdatePlayerHintPos()
	end)
end

function M:ShowEnemyExecuteHint(enable)
	local store = self:GetStoreByWidget(self.bindData.executeHint)

	if not store then
		return
	end

	store.root:SetActive(false)
	store.root:SetActive(enable)

	self.showExecuteHint = enable

	self:UpdateExecuteHintPos()
end

function M:CheckShowExecuteHint(show)
	local item = gCS.MindPowerMgr:GetAimItem()

	if not item then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(item.ID)

	if not unit then
		return false
	end

	return show
end

function M:ShowOrHideExecuteHint(show)
	show = self:CheckShowExecuteHint(show)

	if self.showOrHideExecuteHint ~= show then
		self.showOrHideExecuteHint = show

		self.bindData.executeHint:SetWidgetFaraway(not show)
	end
end

function M:UpdateExecuteHintPos()
	if not self.showExecuteHint then
		return
	end

	local item = gCS.MindPowerMgr:GetAimItem()

	if not item then
		self:ShowOrHideExecuteHint(false)

		return
	end

	local unit = gCS.SceneDataMgr.GetUnit(item.ID)

	if not unit then
		self:ShowOrHideExecuteHint(false)

		return
	end

	local pos = unit.UpBodyPosition
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	z = self.bindData.executeHint.rectTransform.localPosition.z
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.executeHint.transform.parent, Vector3.New(x, y, 0))

	self.bindData.executeHint.rectTransform:SetLocalPosition(UIPos.x, UIPos.y, z)
end

function M:SetClickPCText(text)
	self.clickLabel = text

	self:RefreshClickPCText()
end

function M:RefreshClickPCText()
	if self.STATE_EnableOnce then
		local store = self:GetStoreByWidget(self.bindData.environmentalKill)

		if not store then
			return
		end

		store.label = self.clickLabel
	end
end

function M:SetMindIcon(type)
	self.mindIconType = type
	self.showMindIcon = EnvironmentalKillIconCtrl.Text

	if type == MindButtonTypeType.NormalSkillBtn then
		self.showMindIcon = EnvironmentalKillIconCtrl.MouseLeft
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.normalAttack
	elseif type == MindButtonTypeType.InteractBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.interact
	elseif type == MindButtonTypeType.MindPowerBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.mindPower
	elseif type == MindButtonTypeType.EBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.eBtn
	elseif type == MindButtonTypeType.MouseRight then
		self.showMindIcon = EnvironmentalKillIconCtrl.MouseRight
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.mouseRight
	end

	self:RefreshMindIcon(type)
end

function M:RefreshMindIcon(type)
	type = type or self.mindIconType

	if self.STATE_EnableOnce then
		local store = self:GetStoreByWidget(self.bindData.environmentalKill)

		if not store then
			return
		end

		store.pcKeyIconCtrl = self.showMindIcon or EnvironmentalKillIconCtrl.Text
		store.icon = self.mindIconId
		local btnId, style = self:GetMindPowerNotifyBtnIdAndStyle(type)

		store.controllerIcon:ChangeDeviceGamePadAction("GamePad", btnId, style)
	end
end

function M:GetMindPowerNotifyBtnIdAndStyle(type)
	if type == MindButtonTypeType.NormalSkillBtn then
		return GameConfig.MindPowerInteractBtnId.normalAttack, GameConfig.MindPowerInteractBtnStyle.normalAttack
	elseif type == MindButtonTypeType.InteractBtn then
		return GameConfig.MindPowerInteractBtnId.interact, GameConfig.MindPowerInteractBtnStyle.interact
	elseif type == MindButtonTypeType.MindPowerBtn then
		return GameConfig.MindPowerInteractBtnId.mindPower, GameConfig.MindPowerInteractBtnStyle.mindPower
	elseif type == MindButtonTypeType.EBtn then
		return GameConfig.MindPowerInteractBtnId.eBtn, GameConfig.MindPowerInteractBtnStyle.eBtn
	elseif type == MindButtonTypeType.MouseRight then
		return GameConfig.MindPowerInteractBtnId.mouseRight, GameConfig.MindPowerInteractBtnStyle.mouseRight
	end

	return GameConfig.MindPowerInteractBtnId.mindPower, GameConfig.MindPowerInteractBtnStyle.mindPower
end

function M:CurrentCanShowEnvironmentalKill(data)
	if pcBtnIsNotNil and isXBoxHideMindPower then
		return false
	end

	local bindData = gPlayerManager.main.bindData

	if gCS.MindPowerMgr.inHoldMode or bindData.isInMagnetHold or gCS.MyPlayerManager.inRobMobileState then
		return false
	end

	if not bindData.canUseMindPower and not gCS.MindPowerMgr.needShowMindHintIcon then
		return false
	end

	if not data then
		return false
	end

	if not data:IsCurrentCanMind() then
		return false
	end

	if self.showOrHideExecuteHint then
		return false
	end

	local mindInteractCfgId = gCS.MindPowerMgr:GetBattleMindPowerInteractConfig()
	local mindInteractCfg = LTConfig.BattleMindPowerInteractConfig.GetConfig(mindInteractCfgId)

	if mindInteractCfg and not mindInteractCfg.ShowInteractionIcon then
		return false
	end

	return true
end

function M:UpdateEnvironmentalKill(data)
	local store = self:GetStoreByWidget(self.bindData.environmentalKill)

	if not store then
		return
	end

	local tmpShowMode = self:CurrentCanShowEnvironmentalKill(data) and IconShowMode.Show or IconShowMode.Hide

	if tmpShowMode ~= self.environmentalShow then
		self.environmentalShow = tmpShowMode

		store.root.gameObject:SetActive(tmpShowMode == IconShowMode.Show)
	end

	self:RefreshEnvironmentalKillNotifyPosCS(data)
end

function M:HideEnvironmentalKill()
	local store = self:GetStoreByWidget(self.bindData.environmentalKill)

	if not store then
		return
	end

	self.environmentalShow = false

	store.root.gameObject:SetActive(false)
end

function M:RefreshEnvironmentalKillNotifyPosCS(data)
	if data == nil then
		return
	end

	local pos = data:GetMindPowerIconPos()

	if not pos then
		return
	end

	self:CalculatePositionEnvironmentalKill(pos)
end

function M:CalculatePositionEnvironmentalKill(pos)
	local store = self:GetStoreByWidget(self.bindData.environmentalKill)

	if not store then
		return
	end

	local trans = store.root
	local isInView, transIsNull, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRectParent(pos, trans, false, _, _, _, _)

	if transIsNull then
		return
	end

	trans:SetLocalPositionXY(x, y)
end

function M:OnControllerSettingChange(eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

function M:OnUnitHasRewardOrFansRefresh(eventId)
	self.bindData.hasFans = L50.L50App.L50Game.InteractBtnMgr.unitHasFans and 1 or 0
	self.bindData.hasReward = self.bindData.hasFans == 0 and L50.L50App.L50Game.InteractBtnMgr.unitHasReward and 1 or 0
end
