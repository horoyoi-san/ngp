-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HintInfosHudStore.lua
-- Decompiled from: 01710_HintInfosHudStore.lua_c8f2a5276058.luajit

local GameObject = UnityEngine.GameObject
C_HintInfosHudStore = DefClass("C_HintInfosHudStore", C_HintInfosHudStore, C_StoreGroup)
GroupName2Class.HintInfosHudStore = C_HintInfosHudStore
local M = C_HintInfosHudStore
local GameConfig = LTConfig.GameConfig
local BattleEnemyInteractConfig = LTConfig.BattleEnemyInteractConfig
local MindButtonTypeType = LTConfig.BattleEnemyInteractConfig.MindButtonTypeType
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local SceneItemConfig = LTConfig.SceneitemConfig
local QueryUnitUtils = LX6.Utils.QueryUnitUtils
local Vector3One = Vector3.one
local Vector3Zero = Vector3.zero
local Vector3Forward = Vector3.forward
local Vector3Up = Vector3.up
local PcInteractBtnShowKeys = {
	"2\\x9f\\xfa\\x9b\\xa4\\xc1\\xa8\\xae\\x8d\\xcf\\xe31Ҹ4\\x91\\xb3",
	"2\\x9f\\xfa\\x9b\\xa4\\xc1\\xa8\\xae\\x8d\\xcf\\xe31Ҹ4\\x91\\xb0",
	"2\\x9f\\xfa\\x9b\\xa4\\xc1\\xa8\\xae\\x8d\\xcf\\xe31Ҹ4\\x91\\xb1",
	"2\\x9f\\xfa\\x9b\\xa4\\xc1\\xa8\\xae\\x8d\\xcf\\xe31Ҹ4\\x91\\xb6"
}
local InteractTipBtnShowKeys = {
	"n\\xbd&\\xdew\\xa8h #x\\xb1\\xdc1׶",
	"n\\xbd&\\xdew\\xa8h #x\\xb1\\xdc1׵",
	"n\\xbd&\\xdew\\xa8h #x\\xb1\\xdc1״",
	"n\\xbd&\\xdew\\xa8h #x\\xb1\\xdc1׳"
}
local InteractionTipBtnKeys = {
	"4\\x84蹦벳\\x87\\xd3\\xd6;ָ4\\x91\\xb3",
	"4\\x84蹦벳\\x87\\xd3\\xd6;ָ4\\x91\\xb0",
	"4\\x84蹦벳\\x87\\xd3\\xd6;ָ4\\x91\\xb1",
	"4\\x84蹦벳\\x87\\xd3\\xd6;ָ4\\x91\\xb6"
}
local ShowInteractionTextKeys = {
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xfe$\\xa4\\xdfR",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xfe$\\xa4\\xdfQ",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xfe$\\xa4\\xdfP",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xfe$\\xa4\\xdfW"
}
local ShowInteractionIconKeys = {
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xe3\"\\xb3\\xc5R",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xe3\"\\xb3\\xc5Q",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xe3\"\\xb3\\xc5P",
	"\\xb1'\\xe2\\xabz&\\xd2^\\xc9\\xed7XR\\xe3\"\\xb3\\xc5W"
}
local InteractionBtnTextKeys = {
	"T\\xa64\\xe5x\r\\xb9s.>\\x95\\xfb=Ͷ",
	"T\\xa64\\xe5x\r\\xb9s.>\\x95\\xfb=͵",
	"T\\xa64\\xe5x\r\\xb9s.>\\x95\\xfb=ʹ",
	"T\\xa64\\xe5x\r\\xb9s.>\\x95\\xfb=ͳ"
}
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
	["[\\xa4\\x80\\x8aU"] = false,
	["\\x9eab"] = 0
}
local IconShowMode = {
	["kF`oo9"] = 1,
	["R+y^"] = 0,
	["I*rL"] = 2
}
local PanelState = {
	["}\\xbc\\xa7\\xbc\\xa5"] = 3,
	["n\\xa2\\xab\\xac\\xbd"] = 1,
	["^0|\\"] = 4,
	["T-s^"] = 0
}
M.MindInteractionType = {
	["}\\xbc\\xa7\\xbc\\xa5"] = 2,
	["n\\xa2\\xab\\xac\\xbd"] = 1,
	["^0|\\"] = 3,
	["T-s^"] = 0
}
local EnvironmentalKillIconCtrl = {
	["nHyzK2,"] = 1,
	["N'eO"] = 0,
	["~Uۮ\\x81:\\xb1\\xc1\\xfc"] = 2
}
local MindObjType = MindPowerConst.MindObjType
M.showMindIcon = nil
M.showMode = IconShowMode.Hide
M.environmentalShow = IconShowMode.Hide
M.ellipseScaleX = 0.0317
M.ellipseScaleY = 0.046
M.ellipseX = 200
M.ellipseY = 100
M.ellipseOffsetX = 0
M.ellipseOffsetY = 10

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "BeforeSwitchScene"),
		[gEventConstants.NEW_INTERACT_CHANGE] = self.CreateAction(self, "OnNewBtnChange"),
		[gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE] = self.CreateAction(self, "OnControllerSettingChange"),
		[gEventConstants.UNIT_HAS_REWARD_REFRESH] = self.CreateAction(self, "OnUnitHasRewardOrFansRefresh"),
		[gEventConstants.UNIT_HAS_FANS_REFRESH] = self.CreateAction(self, "OnUnitHasRewardOrFansRefresh"),
		[gEventConstants.HACK_CLEAR_ANIM] = self.CreateAction(self, "OnClearHackAnim"),
		[gEventConstants.LONG_PRESS_HACK_REFRESH] = self.CreateAction(self, "OnPressHackTargetChange"),
		[gEventConstants.COMBAT_ART_NOTIFY] = self.CreateAction(self, "ShowEnemyCombatArtNotifyHint")
	}
	self._usefulList = {}
end

M.OnAwake = function(self)
	gInteractionManager.hintInfosHudStore = self
	self.bindData.interactionBtnList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderInteractionItem")
	self.bindData.interactionBtnList.luaSimpleClick = self.CreateAction(self, "OnInteractionTempClick")
	self.bindData.interactionBtn1.luaClick = self.CreateAction(self, "OnInteractionBtn1Click")
	self.bindData.interactionBtn2.luaClick = self.CreateAction(self, "OnInteractionBtn2Click")
	self.bindData.interactionBtn3.luaClick = self.CreateAction(self, "OnInteractionBtn3Click")
	self.bindData.interactionTipBtn1.luaClick = self.CreateAction(self, "OnInteractionBtn1Click")
	self.bindData.interactionTipBtn2.luaClick = self.CreateAction(self, "OnInteractionBtn2Click")
	self.bindData.interactionTipBtn3.luaClick = self.CreateAction(self, "OnInteractionBtn3Click")

	if self.bindData.interactionBtn4 then
		self.bindData.interactionBtn4.luaClick = self.CreateAction(self, "OnInteractionBtn4Click")
		self.bindData.interactionTipBtn4.luaClick = self.CreateAction(self, "OnInteractionBtn4Click")
	end

	self.bindData.controllerInteractBtn.luaPress = self.CreateAction(self, "OnInteractionControllerBtnPress")
	self.bindData.controllerInteractBtn.luaRelease = self.CreateAction(self, "OnInteractionControllerBtnRelease")
	self.bindData.showLockEffect = false
	self.bindData.showSaiMoLock = false
	self.isPlayingAnim = false

	self.CancelMindPowerAnim(self)

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

M.OnStart = function(self)
	self.controllerAnim = self.bindData.controllerInteractBtnTrans:GetComponent(typeof(UnityEngine.Animation))
	self.bindData.activePcInteractBtn = 0
	self.bindData.isPc = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 0
	self.tempGo = self.bindData.temp.gameObject
	self.tempRoot = self.tempGo.transform.parent

	for i, data in ipairs(gInteractionManager.registerInteractIndicateList) do
		self.RegisterIndicateTarget(self, data)
	end

	gInteractionManager.registerInteractIndicateList = {}
	self.showPlayerHint = {}

	self.ShowOrHidePlayerHint(self, false, false, 0)
	self.ShowOrHidePlayerHint(self, false, false, 1)
	self.ShowEnemyExecuteHint(self, false)
	self.ShowEnemyCombatArtNotifyHint(self, false)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.OnControllerSettingChange(self, _, gameProfile.isNewControllerSetting)
	end
end

local frameCount = 0
local isXBoxHideMindPower = false
local pcBtnIsNotNil = false

M.OnCameraUpdate = function(self)
	MindObjType = MindPowerConst.MindObjType
	isXBoxHideMindPower = self:XBoxHideMindPower()
	pcBtnIsNotNil = #self.pcBtns == 0
	local myPlayer = gCS.MyPlayerManager.PlayerUnit

	self:UpdateLockEffectPos()
	self:UpdatePlayerHintPos()
	self:UpdateExecuteHintPos()
	self:UpdateEnemyCombatArtNotifyPos()
	self:UpdateSaiMoLockPos()

	if not myPlayer or not myPlayer.PlayerObj or not self.bindData.pcBtn then
		return
	end

	local myPlayerPos = myPlayer.LocalPosition
	local mainCam = gCS.CameraDataMgr.MainCamera

	if QueryUnitUtils.PrepareMainCamera == nil then
		QueryUnitUtils.PrepareMainCamera(mainCam, myPlayerPos)
	end

	frameCount = frameCount + 1

	if frameCount > 30 then
		frameCount = 0
		self.bindData.isPc = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 0
		self.isController = gClientUtils.IsControllerMode()

		if self.testMobile then
			self.bindData.isPc = 0
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("NormalUpdate")
	end

	self.NormalUpdate(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("InteractUpdate")
	end

	self.InteractUpdate(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
		gGameManager:BeginSample("RefreshHackInteractView")
	end

	self.RefreshHackInteractView(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.NormalUpdate = function(self)
	if self.bindData.isPc ~= 1 then
		self.bindData.clickPlatform = 1
		self.bindData.pressPlatform = 1
		self.bindData.dragPlatform = 1
	end

	if self.isInSwitching then
		self.MindPowerUpdateCS(self)
	end

	self.RefreshHackSkillPos(self)
	self.RefreshLongPressView(self)
end

M.indicateShowList = {}
M.lastCreateIndicateTime = 0

M.InteractUpdate = function(self, force)
	if not gCS.MyPlayerManager.PlayerUnit or gCS.LuaUtils.IsNull(gCS.MyPlayerManager.PlayerUnit.PlayerObj) then
		return
	end

	local isSouDaChe = gLinkManager:CheckIsExtractionShooter()

	if isSouDaChe then
		table.clear(self.indicateShowList)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("InteractUpdate_Lua")
	end

	if gInteractionManager.enableNewIndicateSystem then
		for _, data in pairs(self.m_IndicateItems) do
			if data.isShow then
				self.RefreshIndicateItemState(self, data)
			end
		end
	else
		local refreshShow = gLogicTime.frameCount % 3 ~= 0

		if refreshShow then
			self.mindAbleStatic = gPlayerManager.main.bindData.isMindPowerStaticActive
		end

		for _, list in pairs(self.indicateList) do
			for _, data in pairs(list) do
				if refreshShow then
					self.RefreshIndicateTempShow(self, data)
				end

				local show = self.RefreshIndicateTempState(self, data)

				if show and isSouDaChe then
					table.insert(self.indicateShowList, data)
				end
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	if isSouDaChe then
		local camTrans = gCS.CameraDataMgr.MainCamera.transform
		local camDir = camTrans.forward
		local camPos = camTrans.position
		local minAngle = 360
		local curData = nil

		for _, data in pairs(self.indicateShowList) do
			if data.isShow and not gClientUtils.IsNil(data.instanceObj) then
				local angle = Vector3.Angle(data.GetTargetPos() - camPos, camDir)

				if angle >= minAngle then
					minAngle = angle

					if curData then
						curData.instanceObj.gameObject:SetActive(false)

						curData.isShow = false
					end

					curData = data
				else
					data.instanceObj.gameObject:SetActive(false)

					data.isShow = false
				end
			end
		end
	end

	if self.IsPC(self) then
		table.clear(self._usefulList)
		L50.L50App.L50Game.InteractBtnMgr:LuaGetUsefulList(self._usefulList)
		self:RefreshPcBtnShow()
		self:RefreshControllerBtn()
		self:RefreshActivePcInteractBtn()
		table.clear(self._usefulList)
	end
end

M.XBoxHideMindPower = function(self)
	return gClientUtils.IsControllerMode()
end

M.OnDestroy = function(self)
	if self.selectVXTimer then
		self.selectVXTimer:Stop()

		self.selectVXTimer = nil
	end

	self.CancelMindPowerAnim(self)

	gInteractionManager.hintInfosHudStore = nil

	if self.btnLoopTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.btnLoopTimer)
	end
end

M.OnGroupEnable = function(self)
	self.hack = gStoreManager:GetStoreGroup("HackerSkillNotify"):GetStoreByWidget(self.bindData.HackerSkillNotify)
	self.hack.skillList.luaRenderItem = self:CreateAction("OnRenderHackSkillItem")
	self.hack.skillList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.hack.hackPressBtn.luaPress = self:CreateAction("OnStartPressHack")
	self.hack.hackPressBtn.luaRelease = self:CreateAction("OnEndPressHack")

	self:RegisterMessageEvents(self.msgEvents)
	self:RefreshClickPCText(self.enemyClickLabel)
	self:RefreshMindIcon(self.enemyMindIconType)
	self:HideEnvironmentalKill()
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.BeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.Reconnect then
		return
	end

	if gInteractionManager.enableNewIndicateSystem then
		for key, data in pairs(self.m_IndicateItems) do
			if data.instanceObj and not gCS.LuaUtils.IsNull(data.instanceObj) then
				GameObject.Destroy(data.instanceObj.gameObject)
			end
		end

		table.clear(self.m_IndicateItems)
	end

	for pid, list in pairs(self.indicateList) do
		for index, data in pairs(list) do
			if not gCS.LuaUtils.IsNull(data.instanceObj) then
				GameObject.Destroy(data.instanceObj.gameObject)
			end
		end
	end

	table.clear(self.indicateList)
	self.ClearAllHackSkill(self)
end

M.OnLanguageChange = function(self, lang)
	self.RefreshHackInteractView(self)

	if self.curPressHackTarget then
		self.hack.longPressHackText = LTConfig.TextCommonTextConfig.GetConfig(self.curPressHackTarget.textId).Text
	end
end

M.isInDis = nil
M.mindDir = nil

M.RefreshIndicateTempShow = function(self, data)
	if data.enable then
		if data.isMindPower then
			if not gClientUtils.CheckCurrentIsDefaultSpirit() then
				self.SetIndicateIsShow(self, data, false)

				return
			end

			local playerIsInFight = false
			playerIsInFight = gCS.MindPowerMgr:PlayerIsInFight()
			self.isInDis = (not playerIsInFight or data.showInBattle) and data.InDis()
		else
			self.isInDis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, data.GetTargetPos()) <= data.dis
		end

		if self.isInDis and data.isMindPower then
			self.isInDis = self.isInDis and not self:IsCurAimGadget(data.pid)
			self.mindDir = data.GetTarget().forward
			self.mindDir.y = 0

			if self.mindDir:Magnitude() >= 1e-06 then
				self.mindDir = Vector3Forward
			end

			if data.isAllDirPress then
				local delta = gCS.MyPlayerManager.PlayerUnit.LocalPosition - data.GetTargetPos()

				if delta.x * delta.x + delta.z * delta.z >= data.tooNearRadius * data.tooNearRadius and math.abs(delta.y) >= data.exDisH then
					self.isInDis = true
				end
			else
				local size = data.tooNearRange
				local localPoint = Quaternion.Inverse(Quaternion.LookRotation(self.mindDir)) * (gCS.MyPlayerManager.PlayerUnit.LocalPosition - data.GetTargetPos())
				local inRange = localPoint.z <= 0 and Mathf.Abs(localPoint.x) < size.x and Mathf.Abs(localPoint.y) < size.y and Mathf.Abs(localPoint.z) > size.z

				if inRange then
					self.isInDis = true
				end
			end

			if not self.mindAbleStatic then
				self.isInDis = false
			end
		end

		if self.isInDis and gCS.MindPowerMgr.AimItem and gCS.MindPowerMgr.AimItem:IsAccumulating() and data.pid ~= gCS.MindPowerMgr.AimItem.EntityInstanceId then
			self.isInDis = false
		end

		if self.isInDis and data.isHack then
			if data.pid ~= gGadgetManager.hackInfoTargetId then
				self.isInDis = false
			elseif gGadgetManager.HackInteractTarget and gGadgetManager.HackInteractTarget.entityId ~= data.entityId then
				self.isInDis = false
			elseif not gGadgetManager:HasGlobalHackAble() then
				self.isInDis = false
			end
		end

		if self.isInDis then
			if not data.instanceObj and not gCS.LuaUtils.IsNull(self.tempGo) and self.lastCreateIndicateTime == gLogicTime.time then
				self.lastCreateIndicateTime = gLogicTime.time
				data.instanceObj = GameObject.Instantiate(self.tempGo, self.tempRoot).transform

				data.instanceObj:GetComponent(typeof(SGUI.UWidget)):TryInit()

				data.instanceObj.name = "temp_" .. ulong.tostring(data.pid)
				data.strongScaleObj = data.instanceObj:Find("Strong/Scale")
				data.strongWarnObj = data.instanceObj:Find("Strong/TooShort")
				data.strongEffectObj = data.instanceObj:Find("Strong/VX_Notify")
				data.lightEffectObj = data.instanceObj:Find("Light/VX_Notify")

				data.instanceObj:Find("Strong").gameObject:SetActive(data.isImportant and not data.isHack)
				data.instanceObj:Find("Light").gameObject:SetActive(not data.isImportant and not data.isHack)
				data.instanceObj:Find("Hack").gameObject:SetActive(data.isHack and not data.isHackLock)
				data.instanceObj:Find("HackLock").gameObject:SetActive(data.isHack and data.isHackLock)
			end

			self.SetIndicateIsShow(self, data, true)
		else
			self.SetIndicateIsShow(self, data, false)
		end
	end
end

M.RefreshIndicateEffectView = function(self, data)
	if data.isHack then
		return
	end

	if data.isImportant then
		if data.strongEffectObj then
			data.strongEffectObj.gameObject:SetActive(self:ExistGadgetEffectBtnByIndex(data.pid, data.index))
		end
	elseif data.lightEffectObj then
		data.lightEffectObj.gameObject:SetActive(self:ExistGadgetEffectBtnByIndex(data.pid, data.index))
	end
end

M.ExistGadgetEffectBtnByIndex = function(self, pid, index)
	return L50.L50App.L50Game.InteractBtnMgr:ExistButtonEffect(pid, index)
end

M.RefreshHackIndicateState = function(self, entityId, index, isLock)
	if not self.indicateList[entityId] then
		return
	end

	local data = self.indicateList[entityId][index]

	if data and data.instanceObj then
		data.instanceObj:Find("Hack").gameObject:SetActive(not isLock)
		data.instanceObj:Find("HackLock").gameObject:SetActive(isLock)
	end
end

M.IsCurAimGadget = function(self, pid)
	if not gCS.MindPowerMgr.AimItem or gCS.MindPowerMgr.AimItem.ItemType == MindPowerConst.MindObjType.Slot then
		return false
	end

	return ulong.equals(gCS.MindPowerMgr.AimItem.EntityInstanceId, pid)
end

M.SetIndicateIsShow = function(self, data, show)
	if not data.instanceObj then
		return
	end

	if show and GpsHelper.CheckHasSlotGPSTarget(data.pid, data.targetId) then
		show = false
	end

	show = show and not self:SlotInteractAble(data.pid, data.GetTarget(), data.index)
	show = show and not self:HasInteractState()
	show = show and not self:IndicateHasBlock(data.GetTargetPos(), data.entityGo, data.selfBlock)

	if show then
		self.RefreshIndicateEffectView(self)
	end

	if data.isShow ~= show then
		return
	end

	data.isShow = show

	if not gCS.LuaUtils.IsNull(data.instanceObj) then
		data.instanceObj.gameObject:SetActive(show)
	end
end

M.IndicateHasBlock = function(self, pos, go, selfBlock)
	local selfObj = nil

	if not selfBlock then
		selfObj = go
	end

	return not L50.L50App.Scene.HackManager:CheckSlotIndicateVisiable(pos, selfObj)
end

M.SlotInteractAble = function(self, pid, trans, index)
	return L50.L50App.L50Game.InteractBtnMgr:ExistShowBtn(pid, 0, trans, index)
end

M.HasInteractState = function(self)
	return table.contains(gMainMenuMgr:GetClientState(), LTConfig.ParkourStateConfig.JiaoHu) or table.contains(gMainMenuMgr:GetClientState(), LTConfig.ParkourStateConfig.P_Automated) or table.contains(gMainMenuMgr:GetClientState(), LTConfig.ParkourStateConfig.JiaoHu02)
end

M.TrySetPickItemAbleByComp = function(self, data, enable)
end

M.RefreshIndicateTempState = function(self, data)
	if not data.isShow or gClientUtils.IsNil(data.instanceObj) then
		self.TrySetPickItemAbleByComp(self, data, false)

		return false
	end

	local targetPos = data.GetTargetPos()
	local worldPos = targetPos

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
			local delta = gCS.MyPlayerManager.PlayerUnit.LocalPosition - targetPos
			inRange = delta.x * delta.x + delta.z * delta.z >= data.tooNearRadius * data.tooNearRadius and math.abs(delta.y) <= data.exDisH
		else
			local dir = data.GetTarget().forward
			dir.y = 0

			if dir ~= Vector3Zero then
				dir = Vector3Up
			end

			local localPoint = Quaternion.Inverse(Quaternion.LookRotation(dir)) * (gCS.MyPlayerManager.PlayerUnit.LocalPosition - worldPos)
			local size = data.tooNearRange
			inRange = localPoint.z <= 0 and Mathf.Abs(localPoint.x) < size.x and Mathf.Abs(localPoint.y) < size.y and Mathf.Abs(localPoint.z) > size.z
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

	return true
end

M.m_IndicateItems = {}

M.OnIndicateChanged = function(self, pid, index, visible)
	if visible then
		local item = LX6.Interact.IndicateManager.Instance:GetItem(pid, index)

		if not item then
			return
		end

		local key = pid .. "_" .. index
		local data = self.m_IndicateItems[key]

		if not data then
			data = {
				pid = pid,
				index = index,
				isImportant = item.config.isImportant,
				isHack = item.config.isHack,
				isHackLock = item.config.isHackLock,
				item = item
			}
			self.m_IndicateItems[key] = data
		else
			data.item = item
		end

		self.CreateIndicateItemObj(self, data)
		self.SetIndicateItemShow(self, data, true)
	else
		local key = pid .. "_" .. index
		local data = self.m_IndicateItems[key]

		if data then
			self.SetIndicateItemShow(self, data, false)
		end
	end
end

M.CreateIndicateItemObj = function(self, data)
	if data.instanceObj then
		return
	end

	if gCS.LuaUtils.IsNull(self.tempGo) then
		return
	end

	if self.lastCreateIndicateTime ~= gLogicTime.time then
		return
	end

	self.lastCreateIndicateTime = gLogicTime.time
	data.instanceObj = GameObject.Instantiate(self.tempGo, self.tempRoot).transform

	data.instanceObj:GetComponent(typeof(SGUI.UWidget)):TryInit()

	data.instanceObj.name = "temp_" .. ulong.tostring(data.pid)
	data.strongScaleObj = data.instanceObj:Find("Strong/Scale")
	data.strongWarnObj = data.instanceObj:Find("Strong/TooShort")

	data.instanceObj:Find("Strong").gameObject:SetActive(data.isImportant and not data.isHack)
	data.instanceObj:Find("Light").gameObject:SetActive(not data.isImportant and not data.isHack)
	data.instanceObj:Find("Hack").gameObject:SetActive(data.isHack and not data.isHackLock)
	data.instanceObj:Find("HackLock").gameObject:SetActive(data.isHack and data.isHackLock)

	data.strongEffectObj = data.instanceObj:Find("Strong/VX_Notify")
	data.lightEffectObj = data.instanceObj:Find("Light/VX_Notify")
end

M.SetIndicateItemShow = function(self, data, show)
	if not data.instanceObj then
		return
	end

	if data.isShow ~= show then
		return
	end

	data.isShow = show

	if not gCS.LuaUtils.IsNull(data.instanceObj) then
		data.instanceObj.gameObject:SetActive(show)
	end
end

M.RefreshIndicateItemState = function(self, data)
	if not data.isShow or gClientUtils.IsNil(data.instanceObj) then
		return false
	end

	local item = data.item

	if not item then
		return false
	end

	local worldPos = item.targetPos
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(worldPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(data.instanceObj.parent, Vector3.New(x, y, 0))

	data.instanceObj:SetLocalPositionXY(UIPos.x, UIPos.y)

	if data.isImportant and data.strongScaleObj then
		local rate = gCS.CurveManager.GetIndicateScaleCurve(item.disRate)
		local scale = self.minScale + (GameConfig.InteractionPosNotifyUiFillScale - self.minScale) * rate
		scale = Mathf.Clamp(scale, self.minScale, GameConfig.InteractionPosNotifyUiFillScale)
		data.strongScaleObj.localScale = Vector3One * scale
	end

	if data.strongWarnObj then
		data.strongWarnObj.gameObject:SetActive(item.isTooShort)

		data.isTooShort = item.isTooShort
	end

	self.RefreshIndicateEffectView(self, data)

	return true
end

M.Angle2 = function(self, dir1, dir2)
	dir1.y = 0
	dir2.y = 0

	return Vector3.Angle(dir1, dir2)
end

M.RegisterIndicateTarget = function(self, data)
	if data.ToTable then
		data = data.ToTable(data)
	end

	if self.indicateList[data.pid] and self.indicateList[data.pid][data.index] then
		self.UnRegisterIndicateTarget(self, data.pid, data.index)
	end

	if not self.indicateList[data.pid] then
		self.indicateList[data.pid] = {}
	end

	self.indicateList[data.pid][data.index] = data

	if data.enable ~= nil then
		data.enable = true
	end
end

M.SetMindIndicateTargetEnable = function(self, pid, enable)
	if not self.indicateList[pid] then
		return
	end

	for i, v in pairs(self.indicateList[pid]) do
		if v.isMindPower then
			v.enable = enable

			if not enable then
				self.SetIndicateIsShow(self, v, false)
			end
		end
	end
end

M.UnRegisterIndicateTarget = function(self, pid, index)
	if not self.indicateList[pid] then
		return
	end

	if index ~= nil then
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

M.IsPC = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive()
end

M.OnNewBtnChange = function(self)
	if self.IsPC(self) then
		self.RefreshPcBtnShow(self, true)

		return
	end

	if #self.mobileBtns <= 0 then
		return
	end

	local list = {}

	table.clear(self._usefulList)
	L50.L50App.L50Game.InteractBtnMgr:LuaGetUsefulList(self._usefulList)

	local UsefulBtn0 = self._usefulList[1]
	local count = #self._usefulList

	if count <= 0 and UsefulBtn0.targetType ~= 2 then
		count = 1
	end

	for i = 1, count do
		local data = self._usefulList[i]

		table.insert(list, {
			iconId = data:GetIconId(),
			name = data.text,
			isGray = data.isGray,
			isAvailable = data.isAvailable ~= true,
			isEffect = data.isEffect,
			DoClick = function ()
				data:DoClick()
			end
		})
	end

	self.interactionBtnListData = list

	self.bindData.interactionBtnList:SetSimpleList(#list)
	table.clear(self._usefulList)
end

M.RefreshPcBtnShow = function(self, force)
	for i = 1, 4 do
		self.SetPcInteractBtnShow(self, nil, i, 0, force)
		self.SetPcInteractTipBtnShow(self, i, 0)
	end

	if force then
		table.clear(self._usefulList)
		L50.L50App.L50Game.InteractBtnMgr:LuaGetUsefulList(self._usefulList)
	end

	self.totalPcNum = #self._usefulList

	if self.totalPcNum ~= 0 then
		return
	end

	local UsefulBtn0 = self._usefulList[1]

	if UsefulBtn0.targetType ~= 2 then
		self.totalPcNum = 1
	end

	self.bindData.showPsnId = UsefulBtn0.psnId and 1 or 0

	if UsefulBtn0.psnId then
		self.bindData.psnId = UsefulBtn0.psnId
	end

	local pos = UsefulBtn0.iconPos
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.pcBtn.parent, Vector3.New(x, y, 0))

	self.bindData.pcBtn:SetLocalPositionXY(UIPos.x, UIPos.y)
	self.bindData.controllerInteractBtnTrans:SetLocalPositionXY(UIPos.x, UIPos.y)

	self.bindData.activePcInteractBtn = 1
	local hideMultiBtn = false

	if gLinkManager:CheckIsExtractionShooter() then
		local extractionModule = L50.Spoon.ExtractionShooterSceneItemModule.Instance
		hideMultiBtn = extractionModule == nil and not extractionModule.CheckHintPanelIsShow(extractionModule)
	end

	self.bindData.hideMultiBtn = hideMultiBtn and 1 or 0

	for index = 1, self.totalPcNum do
		local data = self._usefulList[index]

		self:SetInteractionTextShow(index, data.pcHideText and 0 or 1)
		self:SetInteractionIconShow(index, data.pcShowIcon and 1 or 0)
		self:SetInteractionBtnText(index, data.text)
		self:SetPcInteractBtnShow(data, index, data.pcHidePos and 0 or 1, force)

		if data.pcHidePos then
			self.SetPcInteractTipBtnShow(self, index, 1, data.pcKeyInputId)
		end

		if data.isGray then
			self.bindData.OtherStatus = 1
		elseif not data.isAvailable then
			self.bindData.OtherStatus = 2
		else
			self.bindData.OtherStatus = 0
		end
	end

	if force then
		table.clear(self._usefulList)
	end
end

M.oldBtns = {}
local curAngle, curPos, targetPos, playerObj, camDir = nil

M.RefreshActivePcInteractBtn = function(self)
	self.isController = gClientUtils.IsControllerMode()
	self.bindData.activePcInteractBtn = self.totalPcNum <= 0 and (not self.isController or self.totalPcNum < 1) and 1 or 0
end

M.RefreshControllerBtn = function(self)
	if self.HasHidePosBtn(self) then
		self.bindData.InteractController = 0
	elseif not self.isController or self.totalPcNum ~= 0 then
		self.bindData.InteractController = 0
	elseif self.totalPcNum ~= 1 then
		self.bindData.InteractController = 4
	elseif self.isControllerPress then
		if self.totalPcNum ~= 2 then
			self.bindData.InteractController = 1
		elseif self.totalPcNum ~= 3 then
			self.bindData.InteractController = 2
		elseif self.totalPcNum ~= 4 then
			self.bindData.InteractController = 5
		end
	else
		self.bindData.InteractController = 3
	end
end

M.SetPcInteractBtnShow = function(self, btn, index, show, force)
	local key = PcInteractBtnShowKeys[index] or "showPcInteractBtn" .. index

	if self.bindData[key] == show or force then
		if show ~= 1 then
			self.PlayAnimByIndex(self, index, btn)
		end

		self.bindData[key] = show
	end
end

local ControllerKeyNameList = {
	6,
	1,
	4,
	0
}

M.SetPcInteractTipBtnShow = function(self, index, show, inputId)
	local showKey = InteractTipBtnShowKeys[index] or "showInteractTipBtn" .. index

	if self.bindData[showKey] == show then
		self.bindData[showKey] = show
	end

	if show ~= 1 then
		local tipKey = InteractionTipBtnKeys[index] or "interactionTipBtn" .. index

		self.bindData[tipKey]:SetPCKeyInfoTipNameId(inputId or 2)

		if self.bindData.naviArea then
			self.bindData.naviArea:ChangeButtonNameByActionId(ControllerKeyNameList[index], inputId or 2)
		end
	end
end

M.SetInteractionTextShow = function(self, index, show)
	self.bindData[ShowInteractionTextKeys[index] or "ShowInteractionText" .. index] = show
end

M.SetInteractionIconShow = function(self, index, show)
	self.bindData[ShowInteractionIconKeys[index] or "ShowInteractionIcon" .. index] = show
end

M.SetInteractionBtnText = function(self, index, str)
	self.bindData[InteractionBtnTextKeys[index] or "InteractionBtnText" .. index] = str
end

M.PlayAnimByIndex = function(self, index, btn)
	local anim = self.bindData["btnAnim" .. index]
	local two_anim = self.bindData["2btnAnim" .. index]
	local three_anim = self.bindData["3btnAnim" .. index]
	local four_anim = self.bindData["4btnAnim" .. index]

	if btn and btn.isEffect then
		if anim then
			anim.Play(anim, "S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end

		if two_anim then
			two_anim.Play(two_anim, "S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end

		if three_anim then
			three_anim.Play(three_anim, "S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end

		if four_anim then
			four_anim.Play(four_anim, "S_Vx_HintInfosHudPanel_pcconsole_loop02")
		end
	else
		if anim then
			anim.Play(anim, "S_Vx_HintInfosHudPanel_pcconsole_stay")
		end

		if two_anim then
			two_anim.Play(two_anim, "S_Vx_HintInfosHudPanel_pcconsole_stay")
		end

		if three_anim then
			three_anim.Play(three_anim, "S_Vx_HintInfosHudPanel_pcconsole_stay")
		end

		if four_anim then
			four_anim.Play(four_anim, "S_Vx_HintInfosHudPanel_pcconsole_stay")
		end
	end
end

M.CombineSameBtns = function(self, btns)
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

M.OnRenderInteractionItem = function(self, btn, index)
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
		store.anim:Play("S_Vx_InteractionTemplate_Mobile_Notice_loop")
	else
		store.anim:Stop()
		store.anim:Play("S_Vx_InteractionTemplate_Mobile_Notice_close")
	end
end

M.OnInteractionTempClick = function(self, btn, index)
	local data = self.interactionBtnListData[index + 1]

	data.DoClick()
end

M.GetMinCombineTarget = function(self, targets)
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

		curAngle = self.Angle2(self, camDir, curPos - playerObj.position)

		if not minAngle or curAngle >= minAngle then
			minAngle = curAngle
			targetPos = curPos
			targetBtn = btn
		end
	end

	return targetBtn
end

M.OnInteractionBtn1Click = function(self)
	self.OnInteractionBtnClick(self, 1)
end

M.OnInteractionBtn2Click = function(self)
	self.OnInteractionBtnClick(self, 2)
end

M.OnInteractionBtn3Click = function(self)
	self.OnInteractionBtnClick(self, 3)
end

M.OnInteractionBtn4Click = function(self)
	self.OnInteractionBtnClick(self, 4)
end

M.OnInteractionBtnClick = function(self, index)
	if self.IsInClickCD(self) then
		return
	end

	if not self.HasNewBtn(self) then
		return
	end

	local btn = L50.L50App.L50Game.InteractBtnMgr:GetUsefulBtnAt(index - 1)

	if self.isController and not self.isControllerPress and not self.IsHidePosBtn(self, btn) then
		return
	end

	btn.DoClick(btn)
end

M.clickCDTime = 0.8
M.lastClickTime = 0

M.IsInClickCD = function(self)
	if gLogicTime.time - self.lastClickTime >= self.clickCDTime then
		return true
	end

	return false
end

M.IsHidePosBtn = function(self, btn)
	if not btn then
		return false
	end

	return btn.pcHidePos
end

M.HasHidePosBtn = function(self)
	for i, v in ipairs(self._usefulList) do
		if self.IsHidePosBtn(self, v) then
			return true
		end
	end

	return false
end

M.OnInteractionControllerBtnPress = function(self)
	self.isControllerPress = true

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Dodge, "isControllerInteract", true, true)

	if self.totalPcNum ~= 1 then
		self.OnInteractionBtnClick(self, 1)
	elseif self.totalPcNum <= 1 then
		self.RefreshActivePcInteractBtn(self)
	end

	if self.totalPcNum ~= 2 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_two_open")
	elseif self.totalPcNum ~= 3 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Three_open")
	elseif self.totalPcNum ~= 4 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Four_open")
	end
end

M.OnInteractionControllerBtnRelease = function(self)
	self.isControllerPress = false

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Dodge, "isControllerInteract", false, true)
	self:RefreshActivePcInteractBtn()

	if self.totalPcNum ~= 2 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_two_close")
	elseif self.totalPcNum ~= 3 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Three_close")
	elseif self.totalPcNum ~= 4 then
		self.controllerAnim:Play("S_Vx_HintInfosHudPanel_PC_Controller_Btn_Four_close")
	end
end

M.SetInteractionType = function(self, mindInteractionType)
	if self.bindData.mindInteractionType ~= mindInteractionType then
		return
	end

	self.bindData.mindInteractionType = mindInteractionType

	if mindInteractionType ~= self.MindInteractionType.Click then
		self.bindData.VXDrag = 0
		self.bindData.dragFill = 0
	elseif mindInteractionType ~= self.MindInteractionType.Press then
		self.bindData.outPress = 1
		self.bindData.pressFill = 0
	end
end

M.CalculatePosition = function(self, pos)
	if not self.state then
		return
	end

	local state = self.state
	local bindData = self.bindData
	local trans = nil

	if state ~= PanelState.Click then
		trans = bindData.clickTrans
	elseif state ~= PanelState.Press then
		trans = bindData.pressTrans
	elseif state ~= PanelState.Drag then
		trans = bindData.dragTrans
	end

	local isInView, transIsNull, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRectParent(pos, trans, false, _, _, _, _)

	if transIsNull then
		return
	end

	if not isInView then
		if state ~= PanelState.Click then
			bindData.outClick = 0

			bindData.clickOutAngle:SetLocalEulerAnglesZ(eulerZ)
		elseif state ~= PanelState.Press then
			bindData.outPress = 0

			bindData.pressOutAngle:SetLocalEulerAnglesZ(eulerZ)
		end

		trans.SetLocalPositionXY(trans, x, y)
	else
		if state ~= PanelState.Click then
			bindData.outClick = 1
		elseif state ~= PanelState.Press then
			bindData.outPress = 1
		end

		trans.SetLocalPositionXY(trans, x, y)
	end
end

M.PlayAnimation = function(self, state)
	if not state then
		return
	end

	local name = nil

	if state ~= PanelState.Press then
		name = "S_Vx_MindPowerNotify_LongPressSuccess"

		self.bindData.pressAnimation:Play(name)

		self.bindData.pressFill = 1

		return gCS.LuaUtils.GetAnimationTime(self.bindData.pressAnimation, name), self.bindData.pressAnimation
	elseif state ~= PanelState.Click then
		name = "S_Vx_MindPowerNotify_DragSuccess"

		self.bindData.dragAnimation:Play(name)

		self.bindData.dragFill = 1

		return gCS.LuaUtils.GetAnimationTime(self.bindData.dragAnimation, name), self.bindData.dragAnimation
	end
end

M.ChangeCurrentMindEnemy = function(self, pid)
	if ulong.equals(self.curMindEnemyPid, pid) then
		return
	end

	self.curMindEnemyPid = pid

	gMessageManager:SendMessage(gEventConstants.MIND_ICON_ENEMY_CHANGED, pid)
	gLockTargetMgr:CheckShowLockEffectActiveSguiByPid(pid)
end

M.CancelMindPowerAnim = function(self)
	if self.animDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.animDelay)

		self.animDelay = nil
		self.isPlayingAnim = false
	end
end

M.PlayMindPowerAnim = function(self)
	self.CancelMindPowerAnim(self)

	self.isPlayingAnim = true

	if self.state then
		local time, anim = self.PlayAnimation(self, self.state)

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

M.IsMindAimItemChangeCS = function(self, data)
	if data ~= nil then
		return self.currentMindType == MindObjType.None
	end

	return data.ItemType == self.currentMindType or data.ID == self.currentMindId
end

M.NewRefreshMindPowerNotifyCS = function(self, data)
	local tmpShowMode = self:CurrentCanShowIconCS(data) and IconShowMode.Show or IconShowMode.Hide

	if tmpShowMode ~= self.showMode then
		return false
	end

	self.showMode = tmpShowMode

	if self.showMode ~= IconShowMode.Show then
		self.showMind = true
		self.bindData.showMindPower = 1
	else
		self.showMind = false
		self.bindData.showMindPower = 0
	end

	return true
end

M.CurrentCanShowEnvironmentalKill = function(self, mindInteractCfg)
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

	if self.showOrHideExecuteHint then
		return false
	end

	if mindInteractCfg and not mindInteractCfg.ShowInteractionIcon then
		return false
	end

	return true
end

M.CurrentCanShowIconCS = function(self, data)
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

	if not data.IsCurrentCanMind(data) then
		return false
	end

	if self.showOrHideExecuteHint or self.environmentalShow == IconShowMode.Hide then
		return false
	end

	local mindInteractCfgId = gCS.BattleManager.GetActiveEnemyInteractId()
	local mindInteractCfg = LTConfig.BattleEnemyInteractConfig.GetConfig(mindInteractCfgId)

	if mindInteractCfg and not mindInteractCfg.ShowInteractionIcon then
		return false
	end

	return true
end

M.RefreshGetMindStateCS = function(self, data)
	local state = self.GetMindInteractionTypeCS(self, data)

	if state ~= self.state then
		return false
	end

	self.state = state

	return true
end

M.GetMindInteractionTypeCS = function(self, data)
	if not self.showMind then
		return PanelState.None
	end

	return data.GetInteractionType(data)
end

M.RefreshMindPowerAnimCS = function(self, data)
	if data ~= nil then
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

	if self.showMode == IconShowMode.Show then
		return
	end

	if self.bindData.isPc ~= 1 and (data.ItemType ~= MindObjType.Enemy or data.ItemType ~= MindObjType.Effect) then
		self.showSelectVX = true

		if state ~= PanelState.Click then
			self.bindData.VXClick = 0
		elseif state ~= PanelState.Press then
			self.bindData.VXPress = 0
		end
	end
end

M.RefreshPadIconCS = function(self, data)
	if not data then
		return
	end

	if isXBoxHideMindPower then
		if not data then
			return
		end

		if data.ItemType ~= MindObjType.Slot then
			self.bindData.isGadget = 0
		else
			self.bindData.isGadget = 1
		end
	end
end

M.RefreshMindItemStateCS = function(self, data)
	if not data then
		return
	end

	local tmp = 0

	if data.ItemType ~= MindObjType.Item then
		local cfg = SceneItemConfig.GetConfig(data.SceneItemConfigId)

		if cfg then
			local icon = cfg.ShowStrengthenIcon

			if icon ~= 1 then
				tmp = 1
			elseif icon ~= 2 then
				tmp = 2
			end
		end
	elseif data.ItemType ~= MindObjType.Arm then
		local arm = data
		local cfg = SceneItemConfig.GetConfig(arm.SceneItemConfigId)

		if cfg then
			local icon = cfg.ShowStrengthenIcon

			if icon ~= 1 then
				tmp = 1
			elseif icon ~= 2 then
				tmp = 2
			end
		end
	else
		tmp = 0
	end

	if tmp == self.showStrengthenIcon then
		if tmp ~= 0 then
			if self.state ~= PanelState.Click or self.state ~= PanelState.Press then
				self.showStrengthenIcon = tmp
				self.bindData.clickPowerUp = 1
				self.bindData.pressPowerUp = 1
			end
		elseif tmp ~= 1 then
			if self.state ~= PanelState.Click or self.state ~= PanelState.Press then
				self.showStrengthenIcon = tmp
				self.bindData.clickPowerUp = 0
				self.bindData.pressPowerUp = 0
			end
		elseif tmp ~= 2 and (self.state ~= PanelState.Click or self.state ~= PanelState.Press) then
			self.showStrengthenIcon = tmp
			self.bindData.clickPowerUp = 2
			self.bindData.pressPowerUp = 2
		end
	end
end

M.RefreshNewMindPowerNotifyPosCS = function(self, data)
	if data ~= nil then
		return
	end

	local pos = data.GetMindPowerIconPos(data)

	if not pos then
		return
	end

	self.CalculatePosition(self, pos)
end

M.RefreshNewMindPowerNotifyValueCS = function(self, data, fill)
	if data then
		self.bindData[fill] = data.GetMindPowerIconAmount(data)
	else
		self.bindData[fill] = 0
	end
end

M.MindPowerUpdateCS = function(self)
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
	local mindInteractCfgId = gCS.BattleManager.GetActiveEnemyInteractId()
	local mindInteractCfg = BattleEnemyInteractConfig.GetConfig(mindInteractCfgId)

	if mindInteractCfg then
		showEnvironmentalKill = true

		self.UpdateEnvironmentalKill(self, mindInteractCfg)
	else
		self.HideEnvironmentalKill(self)
	end

	local showModeChanged = self:NewRefreshMindPowerNotifyCS(item) and not showEnvironmentalKill
	local stateChanged = false

	if targetChanged and self.showMode == IconShowMode.Hide and item then
		stateChanged = self.RefreshGetMindStateCS(self, item)
	end

	local anyChanged = showModeChanged or targetChanged or stateChanged

	if anyChanged then
		self.RefreshMindPowerAnimCS(self, item)
	end

	if self.showMode == IconShowMode.Hide then
		self.RefreshPadIconCS(self, item)

		if anyChanged then
			self.RefreshMindItemStateCS(self, item)
		end

		if anyChanged or self.waitSwitchIsDrag == self.isDrag then
			self.isDrag = self.waitSwitchIsDrag

			self.RefreshMindInteractionType(self)
		end

		self.RefreshNewMindPowerNotifyPosCS(self, item)

		if anyChanged then
			self.NewRefreshNotifyText(self)
		end
	end

	if not self.state or self.isDrag then
		return
	end

	if self.showMode == IconShowMode.Hide then
		if self.state ~= PanelState.Press then
			self.RefreshNewMindPowerNotifyValueCS(self, item, "pressFill")
		end

		if self.state ~= PanelState.Click and self.isDrag then
			self.RefreshNewMindPowerNotifyValueCS(self, item, "dragFill")
		end
	end

	if showModeChanged or targetChanged then
		if self.showMode ~= IconShowMode.Hide then
			self.ChangeCurrentMindEnemy(self, 0)
		elseif item then
			if item.ItemType ~= MindObjType.Enemy then
				self.ChangeCurrentMindEnemy(self, item.ID)
			else
				self.ChangeCurrentMindEnemy(self, 0)
			end
		else
			self.ChangeCurrentMindEnemy(self, 0)
		end
	end
end

M.SetIsDrag = function(self, isDrag)
	if self.waitSwitchIsDrag ~= isDrag then
		return
	end

	self.waitSwitchIsDrag = isDrag
end

M.RefreshMindInteractionType = function(self)
	if self.state ~= PanelState.Click then
		if not self.isDrag then
			self.SetInteractionType(self, self.MindInteractionType.Click)
		else
			self.SetInteractionType(self, self.MindInteractionType.Drag)
		end
	elseif self.state ~= PanelState.Press then
		self.SetInteractionType(self, self.MindInteractionType.Press)
	end
end

M.NewRefreshNotifyText = function(self)
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
	["a\\xa7\\xa5\\xa7\\xa2"] = 1,
	["/\\\\x83\\x81\\x8dF"] = 0
}
local NormalLockAniName = {
	u2xU = "0ٱ=/\\xebS'\t\\xa9\\xad-N\\xa9`\\x93k2\\xb5و5\\xc0",
	["v-rK"] = "0ٱ=/\\xebS'\t\\xa9\\xad-N\\xa9`\\x93k2\\xb5ً*\\xde"
}
local WeakLockAniName = {
	u2xU = "\\xdc\\x95\\xfa!¥\\xec\\xf4\\xb5\\xbd\\xea\\x86!ڧ2\\x9d\\xdfm\\x97\\xb6\\x85",
	["v-rK"] = "\\xdc\\x95\\xfa!¥\\xec\\xf4\\xb5\\xbd\\xea\\x86!ڧ2\\x9d\\xdfm\\x94\\xa9\\x9b"
}

M.ShowLockEffect = function(self, show, hintType, isStrong, targetInfo)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("ShowLockEffect")
	end

	if show then
		local hint = self:GetStoreByWidget(self.bindData.lockEffect)
		hint.lockType = hintType
		hint.normalLockType = isStrong and NormalLockType.Strong or NormalLockType.Light
		targetInfo = targetInfo or self.lockEffectTargetInfo

		if targetInfo then
			if not self.CheckTargetIsSame(self, targetInfo) or not self.bindData.showLockEffect then
				self.PlayLockAnimation(self, hint, hintType)
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
		gGameManager:EndSample()
	end
end

M.CheckTargetIsSame = function(self, targetInfo)
	if not self.lockEffectTargetInfo then
		return false
	end

	if not targetInfo then
		return true
	end

	if self.lockEffectTargetInfo.isUnit then
		return self.lockEffectTargetInfo ~= targetInfo.pid
	else
		return self.lockEffectTargetInfo.target ~= targetInfo.target
	end
end

M.PlayLockAnimation = function(self, hint, hintType)
	if hintType ~= gLockTargetMgr.LockEnemyHintType.Weak then
		self.PlayWeakAni(self, hint, true)
	elseif hintType ~= gLockTargetMgr.LockEnemyHintType.Normal then
		self.PlayWeakAni(self, hint, false)
	elseif hintType ~= gLockTargetMgr.LockEnemyHintType.Large then
		self.PlayLargeAni(self, hint)
	end
end

M.PlayWeakAni = function(self, hint, isWeak)
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

M.PlayLargeAni = function(self, hint)
	if self.largeLockHintTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.largeLockHintTimer)
	end

	hint.largeLockStatus = 1

	if self.lastChangeFrame ~= Time.frameCount then
		hint.largeLockStatus = 2

		return
	end

	self.largeLockHintTimer = gLuaTimeMgrUtils.Delay(function ()
		hint.largeLockStatus = 2
	end, 0.5)
end

M.CheckHideLockEffect = function(self, hint, unit)
	local flag = false

	if gGadgetManager:AgentExistHackIcon(unit.Pid) then
		flag = true
	elseif self.showOrHideExecuteHint or self.environmentalShow ~= IconShowMode.Show then
		local interactId = gCS.BattleManager.GetActiveEnemyInteractUnitId()

		if interactId ~= unit.Pid then
			flag = true
		end
	elseif gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.Perform) then
		flag = true
	end

	hint.lockEffectScale = flag and Vector3Zero or Vector3One

	return flag
end

M.UpdateLockEffectPos = function(self)
	if not self.bindData.showLockEffect or not self.lockEffectTargetInfo then
		return
	end

	local hint = self.GetStoreByWidget(self, self.bindData.lockEffect)
	local pos = nil

	if self.lockEffectTargetInfo.isUnit then
		local unit = gCS.SceneDataMgr.GetUnit(self.lockEffectTargetInfo.pid)

		if not unit or unit.IsDead then
			self.ShowLockEffect(self, false)

			return
		end

		if self.CheckHideLockEffect(self, hint, unit) then
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

			self:PlayLockAnimation(hint, hint.lockType ~= gLockTargetMgr.LockEnemyHintType.Weak)
		end

		UIPos = gCS.LuaUtils.TransformScreenPointToUI(hint.lockEffectTrans.parent, Vector3.New(projX, projY, 0))

		hint.lockEffectTrans:SetLocalPosition(UIPos.x, UIPos.y, 0)
	else
		hint.lastIsInView = false

		hint.lockEffectTrans:SetLocalPositionZ(-100000)
	end
end

M.EnableFromInteraction = function(self, enable)
	gPanelManager:SetActiveById(gPanelId.S_HINT_INFOS_HUD, enable)
end

M.hackPressTimer = nil

M.OnPressHackInteract = function(self)
	if not gGadgetManager.HackInteractTarget or gGadgetManager.HackInteractTarget.interactType ~= 2 then
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

	if gGadgetManager.HackInteractTarget.interactType == 3 then
		self.RefreshBattery(self)

		self.hackPressTimer = gLuaTimeMgrUtils.Delay(function ()
			M.hackPressTimer = nil

			if gGadgetManager.HackInteractTarget then
				if gCS.LuaUtils.IsNonMobileAdaptive() then
					slot0 = self.bindData.hackPressAnim

					slot0:Play("S_Vx_HintInfosHudPanel_Min2_open")

					slot0 = self.bindData.hackPressAnim
					local time = slot0:GetClip("S_Vx_HintInfosHudPanel_Min2_open").length
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

M.RefreshBattery = function(self)
	if not gCS.MyPlayerManager.PlayerUnit or gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not gLuaDataManager.isNetworkAvailable then
		return
	end
end

M.OnReleaseHackInteract = function(self, ignoreAction)
	if not gGadgetManager.HackInteractTarget then
		gGadgetManager:SetHackInfoPanel(false)

		return
	end

	if gGadgetManager.HackInteractTarget.interactType ~= 2 then
		return
	end

	if self.hackPressTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.hackPressTimer)

		self.hackPressTimer = nil
	end

	self.bindData.hackClickAnim:Play("S_Vx_HintInfosHudPanel_Min")

	local vehicleTextId = nil
	local isVehicle = gGadgetManager.HackInteractTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle

	if gLogicTime.time - gGadgetManager.startPressTime <= LTConfig.HackerConfig.HackPressTime or gGadgetManager.HackInteractTarget.interactType ~= 3 then
		if ignoreAction then
			return
		end

		if gGadgetManager.HackInteractTarget.interactType ~= 1 then
			if isVehicle then
				local list = L50.L50App.Scene.HackManager:GetVehicleHackBtns(gGadgetManager.HackInteractTarget.vehicle):ToTable()

				if list[1] ~= 74003116 then
					vehicleTextId = list[1]
				else
					return
				end
			else
				return
			end
		end

		if not isVehicle and (not gGadgetManager.HackInteractTarget or #gGadgetManager.HackInteractTarget.usefulBtns ~= 0) then
			return
		end

		if not gGadgetManager.HackInteractTarget.hackerId then
			local textId = vehicleTextId or self.clickAbleBtns[self.curSelect].id or 0
			local target = gGadgetManager.HackInteractTarget

			gGadgetManager:AskHack(nil, function ()
				if target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
					gGadgetManager:DoHackClickAction()

					local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(target.unit, textId)

					gInteractionManager.hintInfosHudStore:AddHackSkillIcon(target.unit, skillType)
				elseif target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
					gGadgetManager:DoHackClickAction()
					L50.L50App.Scene.HackManager:OnClickHackVehicle(target.vehicle, textId)
				end
			end)

			return
		end

		local realIndex = nil
		local data = gGadgetManager.HackInteractTarget.usefulBtns[1]

		if data.state == 0 then
			self.bindData.lockAnim:Play("S_Vx_HackerSkillNotify_Unlock")

			return
		end

		realIndex = data.index - 1
		local target = gGadgetManager.HackInteractTarget
		slot7 = gGadgetManager

		slot7:AskHack(data.index, function ()
			gGadgetManager:DoHackClickAction()

			if target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				gSpoonClientMgr:ReleaseContextEvent(target.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.HackInteractTrigger, {
					index = realIndex
				})
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc then
				slot0 = gReliableRpcManager

				slot0:RegisterRPC(gClientToGameSceneDelegate.AskHackingNpc, target.entityId, realIndex, function (err)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)
						print_error("AskHackingNpc err = ", err, realIndex, target)
					end
				end)
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle then
				L50.L50App.Scene.HackManager:AskHackTaskVehicle(target.entityId, realIndex)
			end
		end)
	else
		gGadgetManager:SetHackInfoPanel(false)
	end
end

M.RefreshHackInteractView = function(self)
	if not gGadgetManager.HackInteractTarget then
		self.hack.mode = 2

		return
	end

	if table.isNilOrEmpty(gGadgetManager.HackInteractTarget.usefulBtns) then
		self.hack.showLabel = 0
		self.hack.lock = 0
	else
		local data = gGadgetManager.HackInteractTarget.usefulBtns[1]

		if self.hack.lock == data.state then
			self.hack.lock = data.state

			if self.hack.lock ~= 1 then
				self.bindData.lockAnim:Play("S_Vx_HackerSkillNotify_Unlock")
			end
		end

		local cfg = LTConfig.TextCommonTextConfig.GetConfig(data.id)
		self.hack.text = cfg and cfg.Text or ""
		self.hack.showLabel = gGadgetManager.HackInteractTarget.interactType ~= 1 and 0 or 1
	end

	if gHackManager:IsShowHackInfoPanel() then
		self.hack.mode = 0
	else
		self.hack.mode = 1
	end

	local pos = gGadgetManager.HackInteractTarget.GetTargetPos()
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

	if (z <= 0 or x <= 0 or UnityEngine.Screen.width <= x or y <= 0 or UnityEngine.Screen.height >= y) and gPanelManager:IsPanelShowing(gPanelId.HACKER_INFO) then
		gGadgetManager:SetHackInfoPanel(false)
	end

	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.hack.root.parent, Vector3.New(x, y, 0))

	self.hack.root:SetLocalPositionXY(UIPos.x, UIPos.y)

	if L50.L50App.Scene then
		L50.L50App.Scene.HackManager:RefreshHackEffect(pos)
	end
end

M.hackSkillIconList = {}

M.AddHackSkillIcon = function(self, unit, skillType)
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

	self.RefreshHackSkillList(self)
end

M.RemoveHackSkillIcon = function(self, pid)
	local data = self.hackSkillIconList[pid]

	if not data then
		return
	end

	if data.timer then
		gLuaTimeMgrUtils.CancelUnitDelay(data.timer)
	end

	self.hackSkillIconList[pid] = nil

	self.RefreshHackSkillList(self)
end

M.RefreshHackSkillList = function(self)
	self.hackSkillListData = {}

	for _, data in pairs(self.hackSkillIconList) do
		table.insert(self.hackSkillListData, data)
	end

	self.hack.skillList:SetList(#self.hackSkillListData)
	self:RefreshHackSkillPos()
end

M.hackSkillIconMinDis = 5
M.hackSkillIconScale = Vector3.one

M.RefreshHackSkillPos = function(self)
	if gCS.LuaUtils.IsNull(gCS.CameraDataMgr.MainCamera.transform) then
		return
	end

	for _, data in ipairs(self.hackSkillListData) do
		if not gCS.LuaUtils.IsNull(data.UIObj) then
			if not gCS.LuaUtils.IsNull(data.obj) then
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
end

M.OnRenderHackSkillItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("HackerSkillTempStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.skillType = self.hackSkillListData[index + 1].skillType
	self.hackSkillListData[index + 1].UIObj = btn.transform
end

M.OnGetTIndex = function(self, _)
	return 0
end

M.ClearAllHackSkill = function(self)
	for pid, data in pairs(self.hackSkillIconList) do
		self.RemoveHackSkillIcon(self, pid)
	end

	self.hackSkillIconList = {}
end

M.OnClearHackAnim = function(self)
	if self.bindData.hackClickAnim then
		self.bindData.hackClickAnim:Play("S_Vx_HintInfosHudPanel_Min")
	end
end

M.HasNewBtn = function(self)
	if not L50.L50App.L50Game.InteractBtnMgr then
		return false
	end

	return L50.L50App.L50Game.InteractBtnMgr:HasUsefulBtn()
end

M.ShowOrHidePlayerHint = function(self, enable, isSucc, hintKey)
	local store = self.GetStoreByWidget(self, self.bindData.playerHint)

	if not store then
		return
	end

	self.playerHintKey = hintKey

	if enable then
		local _, rootCmp = self.GetPlayerHintCmp(self, store, self.playerHintKey)

		if rootCmp ~= nil then
			print_error("rootCmp is nil", self.playerHintKey)

			return
		end

		rootCmp.gameObject:SetActive(true)
		rootCmp:SetActive(enable)

		self.showPlayerHint[hintKey] = enable

		self:UpdatePlayerHintPos()
	else
		if not self.showPlayerHint or not self.showPlayerHint[self.playerHintKey] then
			return
		end

		self.PlayPlayerHintAni(self, isSucc)
	end
end

M.ShowOrHidePlayerHintQTE = function(self, enable, hintKey)
	local store = self.GetStoreByWidget(self, self.bindData.playerHint)

	if not store then
		return
	end

	local hintQTERoot = store.hintQTERoot

	if hintQTERoot ~= nil then
		print_error("hintQTERoot is nil")

		return
	end

	hintQTERoot.SetActive(hintQTERoot, enable)

	self.GetStoreByWidget(self, hintQTERoot).keyTypeCtrl = hintKey
end

M.UpdatePlayerHintPos = function(self)
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

M.PlayPlayerHintAni = function(self, succ)
	local store = self.GetStoreByWidget(self, self.bindData.playerHint)

	if not store then
		return
	end

	local key = self.playerHintKey
	local aniCmp, rootCmp = self.GetPlayerHintCmp(self, store, key)

	if key ~= 0 then
		aniCmp = store.ani
		rootCmp = store.shakeStiffRoot
	elseif key ~= 1 then
		aniCmp = store.moveHintAni
		rootCmp = store.moveHintRoot
	else
		return
	end

	self.PlayPlayerHintAni_(self, succ, aniCmp, rootCmp, key)
end

M.GetPlayerHintCmp = function(self, store, key)
	local aniCmp, rootCmp = nil

	if key ~= 0 then
		aniCmp = store.ani
		rootCmp = store.shakeStiffRoot
	elseif key ~= 1 then
		aniCmp = store.moveHintAni
		rootCmp = store.moveHintRoot
	else
		return
	end

	return aniCmp, rootCmp
end

M.PlayPlayerHintAni_ = function(self, succ, aniCmp, rootCmp, key)
	local aniName = "S_Vx_PlayerHint_Success"

	if not succ then
		if key ~= 1 then
			aniName = "S_Vx_PlayerHint_Failure2"
		else
			aniName = "S_Vx_PlayerHint_Failure"
		end
	end

	slot6 = gBattleMgr

	slot6:CommonPlayAniTool(aniCmp, aniName, 0, 1, true, function ()
		rootCmp:SetActive(false)

		self.showPlayerHint[key] = false

		self:UpdatePlayerHintPos()
	end)
end

M.ShowEnemyExecuteHint = function(self, enable)
	local store = self.GetStoreByWidget(self, self.bindData.executeHint)

	if not store then
		return
	end

	store.root:SetActive(false)
	store.root:SetActive(enable)

	self.showExecuteHint = enable

	self:UpdateExecuteHintPos()
end

M.ShowEnemyCombatArtNotifyHint = function(self, eventId, enable, pid)
	local store = self.GetStoreByWidget(self, self.bindData.combatArtNotify)

	if not store then
		return
	end

	store.root:SetActive(enable)

	if enable then
		self.enemyCombatArtId = pid
	end

	self.showCombatArtNotify = enable

	self.UpdateEnemyCombatArtNotifyPos(self)
end

M.ShowOrHideExecuteHint = function(self, show)
	if self.showOrHideExecuteHint == show then
		self.showOrHideExecuteHint = show

		self.bindData.executeHint:SetWidgetFaraway(not show)
	end
end

M.ShowOrHideCombatArtNotify = function(self, show, enemyId)
	if self.showCombatArtNotify == show then
		self.showCombatArtNotify = show

		if show then
			self.enemyCombatArtId = enemyId
		end

		self.bindData.combatArtNotify:SetWidgetFaraway(not show)
	end
end

M.UpdateExecuteHintPos = function(self)
	if not self.showExecuteHint then
		return
	end

	if not gCS.BattleManager or not gCS.BattleManager.GetActiveEnemyInteractId then
		return
	end

	local mindInteractCfgId = gCS.BattleManager.GetActiveEnemyInteractId()
	local mindInteractCfg = BattleEnemyInteractConfig.GetConfig(mindInteractCfgId)

	if not mindInteractCfg then
		self.ShowOrHideExecuteHint(self, false)

		return
	end

	local pos = gCS.BattleManager.GetActiveEnemyInteractIconPos(true)
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	z = self.bindData.executeHint.rectTransform.localPosition.z
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.executeHint.transform.parent, Vector3.New(x, y, 0))

	self.bindData.executeHint.rectTransform:SetLocalPosition(UIPos.x, UIPos.y, z)
end

M.UpdateEnemyCombatArtNotifyPos = function(self)
	if not self.showCombatArtNotify then
		return
	end

	local unit = gCS.SceneDataMgr.GetUnit(self.enemyCombatArtId)

	if unit ~= nil then
		return
	end

	local pos = unit:GetDisarmIconPosition()
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	z = self.bindData.combatArtNotify.rectTransform.localPosition.z
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.combatArtNotify.transform.parent, Vector3.New(x, y, 0))

	self.bindData.combatArtNotify.rectTransform:SetLocalPosition(UIPos.x, UIPos.y, z)
end

M.SetClickPCText = function(self, text)
	self.clickLabel = text
end

M.RefreshClickPCText = function(self, text)
	self.enemyClickLabel = text

	if self.STATE_EnableOnce then
		local store = self.GetStoreByWidget(self, self.bindData.environmentalKill)

		if not store then
			return
		end

		store.label = self.enemyClickLabel
	end
end

M.SetMindIcon = function(self, type)
	self.mindIconType = type
	self.showMindIcon = EnvironmentalKillIconCtrl.Text

	if type ~= MindButtonTypeType.NormalSkillBtn then
		self.showMindIcon = EnvironmentalKillIconCtrl.MouseLeft
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.normalAttack
	elseif type ~= MindButtonTypeType.InteractBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.interact
	elseif type ~= MindButtonTypeType.MindPowerBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.mindPower
	elseif type ~= MindButtonTypeType.EBtn then
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.eBtn
	elseif type ~= MindButtonTypeType.MouseRight then
		self.showMindIcon = EnvironmentalKillIconCtrl.MouseRight
		self.mindIconId = GameConfig.MindPowerInteractMobileIcon.mouseRight
	end
end

M.RefreshMindIcon = function(self, type)
	self.enemyMindIconType = type
	self.enemyShowMindIcon = EnvironmentalKillIconCtrl.Text

	if type ~= MindButtonTypeType.NormalSkillBtn then
		self.enemyShowMindIcon = EnvironmentalKillIconCtrl.MouseLeft
		self.enemyMindIconId = GameConfig.MindPowerInteractMobileIcon.normalAttack
	elseif type ~= MindButtonTypeType.InteractBtn then
		self.enemyMindIconId = GameConfig.MindPowerInteractMobileIcon.interact
	elseif type ~= MindButtonTypeType.MindPowerBtn then
		self.enemyMindIconId = GameConfig.MindPowerInteractMobileIcon.mindPower
	elseif type ~= MindButtonTypeType.EBtn then
		self.enemyMindIconId = GameConfig.MindPowerInteractMobileIcon.eBtn
	elseif type ~= MindButtonTypeType.MouseRight then
		self.enemyShowMindIcon = EnvironmentalKillIconCtrl.MouseRight
		self.enemyMindIconId = GameConfig.MindPowerInteractMobileIcon.mouseRight
	end

	if self.STATE_EnableOnce then
		local store = self.GetStoreByWidget(self, self.bindData.environmentalKill)

		if not store then
			return
		end

		store.pcKeyIconCtrl = self.enemyShowMindIcon or EnvironmentalKillIconCtrl.Text
		store.icon = self.enemyMindIconId
		local btnId, style = self:GetMindPowerNotifyBtnIdAndStyle(self.enemyMindIconType)

		store.controllerIcon:ChangeDeviceGamePadAction("GamePad", btnId, style)
	end
end

M.GetMindPowerNotifyBtnIdAndStyle = function(self, type)
	if type ~= MindButtonTypeType.NormalSkillBtn then
		return GameConfig.MindPowerInteractBtnId.normalAttack, GameConfig.MindPowerInteractBtnStyle.normalAttack
	elseif type ~= MindButtonTypeType.InteractBtn then
		return GameConfig.MindPowerInteractBtnId.interact, GameConfig.MindPowerInteractBtnStyle.interact
	elseif type ~= MindButtonTypeType.MindPowerBtn then
		return GameConfig.MindPowerInteractBtnId.mindPower, GameConfig.MindPowerInteractBtnStyle.mindPower
	elseif type ~= MindButtonTypeType.EBtn then
		return GameConfig.MindPowerInteractBtnId.eBtn, GameConfig.MindPowerInteractBtnStyle.eBtn
	elseif type ~= MindButtonTypeType.MouseRight then
		return GameConfig.MindPowerInteractBtnId.mouseRight, GameConfig.MindPowerInteractBtnStyle.mouseRight
	end

	return GameConfig.MindPowerInteractBtnId.mindPower, GameConfig.MindPowerInteractBtnStyle.mindPower
end

M.UpdateEnvironmentalKill = function(self, mindInteractCfg)
	local store = self.GetStoreByWidget(self, self.bindData.environmentalKill)

	if not store then
		return
	end

	local tmpShowMode = self:CurrentCanShowEnvironmentalKill(mindInteractCfg) and IconShowMode.Show or IconShowMode.Hide

	if tmpShowMode == self.environmentalShow then
		self.environmentalShow = tmpShowMode

		store.root.gameObject:SetActive(tmpShowMode ~= IconShowMode.Show)
	end

	self.RefreshEnvironmentalKillNotifyPosCS(self)
end

M.HideEnvironmentalKill = function(self)
	local store = self.GetStoreByWidget(self, self.bindData.environmentalKill)

	if not store then
		return
	end

	self.environmentalShow = IconShowMode.Hide

	store.root.gameObject:SetActive(false)
end

M.RefreshEnvironmentalKillNotifyPosCS = function(self)
	local pos = gCS.BattleManager.GetActiveEnemyInteractIconPos()

	if not pos then
		return
	end

	self.CalculatePositionEnvironmentalKill(self, pos)
end

M.CalculatePositionEnvironmentalKill = function(self, pos)
	local store = self.GetStoreByWidget(self, self.bindData.environmentalKill)

	if not store then
		return
	end

	local trans = store.root
	local isInView, transIsNull, x, y, eulerZ = QueryUnitUtils.GetHintsHudStoreEllipseInfoRectParent(pos, trans, false, _, _, _, _)

	if transIsNull then
		return
	end

	trans.SetLocalPositionXY(trans, x, y)
end

M.curPressHackTarget = nil
M.startPressHackTime = nil
M.hackShakeId = nil

M.OnStartPressHack = function(self)
	if not self.curPressHackTarget then
		return
	end

	local data = L50.L50App.Scene.HackManager.curSelectHackData

	if data and data.locked then
		return
	end

	self.startPressHackTime = gLogicTime.time
	L50.L50App.Scene.HackManager.isLongPressHacking = true

	self.StartHackShake(self)
end

M.OnEndPressHack = function(self)
	self.startPressHackTime = nil
	L50.L50App.Scene.HackManager.isLongPressHacking = false
	self.hack.longPressHackProgress = 0

	self.StopHackShake(self)
end

M.StartHackShake = function(self)
	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		return
	end

	self:StopHackShake()

	self.hackShakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
end

M.StopHackShake = function(self)
	if self.hackShakeId then
		gSoundMgr:StopSoundByNid(self.hackShakeId)

		self.hackShakeId = nil
	end
end

M.OnPressHackTargetChange = function(self)
	local target = L50.L50App.Scene.HackManager.curSelectHackData
	self.startPressHackTime = nil

	if target then
		self.curPressHackTarget = {
			entityId = target.entityId,
			trans = target.trans,
			dis = target.dis,
			textId = target.textId,
			locked = target.locked
		}
		self.hack.longPressHackText = LTConfig.TextCommonTextConfig.GetConfig(self.curPressHackTarget.textId).Text
	else
		self.curPressHackTarget = nil
	end

	self.hack.longPressHackAble = self.curPressHackTarget and 1 or 0
	self.hack.longPressHackLock = self.curPressHackTarget and self.curPressHackTarget.locked and 1 or 0
	self.hack.longPressHackProgress = 0

	self:RefreshLongPressView()

	if not gCS.LuaUtils.IsNonMobileAdaptive() and target and gGadgetManager.HackInteractTarget and L50.L50App.Scene.HackManager.longPressTargetMinAngle >= gGadgetManager.hackTargetMinAngle then
		gGadgetManager.HackInteractTarget = nil
	end

	gMessageManager:SendMessage(gEventConstants.HACK_BTN_REFRESH)
end

M.RefreshLongPressView = function(self)
	if not self.curPressHackTarget then
		self.StopHackShake(self)

		return
	end

	local data = L50.L50App.Scene.HackManager.curSelectHackData
	self.hack.longPressHackLock = data and data.locked and 1 or 0

	if not data then
		self.hack.longPressHackAble = 0
	elseif data.locked then
		self.hack.longPressHackAble = 2
	elseif (SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice() or not gCS.LuaUtils.IsNonMobileAdaptive()) and gGadgetManager.HackInteractTarget and gGadgetManager.hackTargetMinAngle >= L50.L50App.Scene.HackManager.longPressTargetMinAngle then
		self.hack.longPressHackAble = 0
	else
		self.hack.longPressHackAble = 1
	end

	if not gCS.LuaUtils.IsNull(self.curPressHackTarget.trans) then
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(self.curPressHackTarget.trans.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.hack.longPressHackRoot.parent, Vector3.New(x, y, 0))

		self.hack.longPressHackRoot:SetLocalPositionXY(UIPos.x, UIPos.y)
	end

	if self.startPressHackTime then
		local rate = (gLogicTime.time - self.startPressHackTime) / LTConfig.HackerConfig.HackVPressTime

		if rate > 1 then
			gGadgetManager:OnLongPressHackTrigger()
			self:OnEndPressHack()
		else
			self.hack.longPressHackProgress = rate
		end
	end
end

M.OnControllerSettingChange = function(self, eventId, isNewSetting)
	self.bindData.ControllerSettingCtrl = isNewSetting and 0 or 1
end

M.OnUnitHasRewardOrFansRefresh = function(self, eventId)
	self.bindData.hasFans = L50.L50App.L50Game.InteractBtnMgr.unitHasFans and 1 or 0
	self.bindData.hasReward = self.bindData.hasFans ~= 0 and L50.L50App.L50Game.InteractBtnMgr.unitHasReward and 1 or 0
end

M.ShowSaiMoLock = function(self, show)
	self.bindData.showSaiMoLock = show
end

M.UpdateSaiMoLockPos = function(self)
	if not self.bindData.showSaiMoLock then
		return
	end

	local store = self.GetStoreByWidget(self, self.bindData.saiMoLock)
	local root = store.root
	local success, x, y = gCS.BattleManager.GetSaiMoTargetUIPos(root.parent, 0, 0)

	if success then
		root.SetLocalPositionXY(root, x, y)
	end
end
