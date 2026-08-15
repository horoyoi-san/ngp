local HUDManager = LX6.GUI.HUDNew.HUDManager
local UnitStateConfig = LTConfig.UnitStateConfig
C_HUDCtrl = DefClass("C_HUDCtrl", C_HUDCtrl)
local HUDCtrl = C_HUDCtrl
local InvalidId = -1
local templateMeta = {
	__index = function (t, k)
		if not rawget(t, k) then
			local tType = gHudMgr.TemplateType2Name[k]

			if not tType then
				print_error("不存在的HUD模板类型名:", k)

				return
			end

			return rawget(t, tType)
		end
	end
}
local templatesMeta = {
	__index = function (t, k)
		return rawget(t, tostring(k))
	end
}

function HUDCtrl:ctor()
	self.updateIndex = 0
	self.__isActiveSelf__ = false
	self.uniId = InvalidId
	self.template = {}
	self.templatesGroup = {}
	self.templatesDic = {}
	self.unitDataSet = nil
	self.eventSet = nil
	self.asyncParamsSave = {}
	self.debugCreateParams = {}

	self:SetTemplatesMeta()
end

function HUDCtrl:RegisterBindHandlers()
	if self.unit then
		self.unitDataSet = gDataSetManager:TryGetOrCreateUnitData(self.unit.Pid)
		self.eventSet = C_DataEventSet.New()
		local eventSet = self.eventSet
		local dataSet = self.unitDataSet

		if not self.unitDataSet then
			print_error("unitDataSet创建失败！", self.unit.ClientData.AgentId)
		end

		eventSet:BindHandler2({
			dataSet,
			"isBuffHideNameBar",
			dataSet,
			"realInVisiable",
			dataSet,
			"isMe"
		}, self.OnHudVisibleChange, self, true)
	end
end

function HUDCtrl:SetTemplatesMeta()
	setmetatable(self.template, templateMeta)
	setmetatable(self.templatesGroup, templateMeta)
end

function HUDCtrl:Init(uniId, hudUIRoot, unit, data)
	self.uniId = uniId
	self.unit = unit
	self.uiRoot = hudUIRoot
	self.data = data

	self:RefreshData()
	self:RegisterBindHandlers()
	self:RegisterEventListener()
	self:CustomProcedure()
	self:HandleDebugProcedure()
	self:RegisterBindHandlersDebug()
end

function HUDCtrl:RegisterEventListener()
	return
end

function HUDCtrl:RefreshData()
	return
end

function HUDCtrl:CustomProcedure()
	return
end

function HUDCtrl:AddHudTemplate(InstanceId, templateType, templateTag)
	local store = gStoreManager:GetStoreGroup(gHudMgr.TemplateType2Store[templateType]):GetStoreById(InstanceId)

	if templateTag then
		if not rawget(self.templatesGroup, templateType) then
			local t = {}

			setmetatable(t, templatesMeta)

			self.templatesGroup[templateType] = t
		end

		if rawget(self.templatesGroup[templateType], templateTag) then
			self.uiRoot:RemoveHUDTemplate(InstanceId)

			return
		end

		self.templatesGroup[templateType][templateTag] = store
	else
		if rawget(self.template, templateType) then
			self.uiRoot:RemoveHUDTemplate(InstanceId)

			return
		end

		self.template[templateType] = store
	end

	self.templatesDic[InstanceId] = {
		templateType = templateType,
		templateTag = templateTag
	}

	if self[gHudMgr.OnCreateFunc[templateType]] then
		self[gHudMgr.OnCreateFunc[templateType]](self, templateTag)
	end
end

function HUDCtrl:RemoveHudTemplate(InstanceId)
	if not self.templatesDic[InstanceId] then
		return
	end

	local templateType = self.templatesDic[InstanceId].templateType
	local templateTag = self.templatesDic[InstanceId].templateTag

	if templateTag then
		self.templatesGroup[templateType][templateTag] = nil
	else
		self.template[templateType] = nil
	end

	self.uiRoot:RemoveHUDTemplate(InstanceId)

	self.templatesDic[InstanceId] = nil
end

function HUDCtrl:GetHudTargetType()
	return self.tType
end

function HUDCtrl:IsNpcHud()
	return self.tType == gHudMgr.HUDTargetType.Npc
end

function HUDCtrl:GetUIRoot()
	return self.uiRoot
end

function HUDCtrl:Clear()
	self:ClearEventListener()
	self:CustomClearProcedure()

	self.uniId = InvalidId
	self.unit = nil
	self.uiRoot = nil
	self.unitDataSet = nil

	if self.eventSet then
		self.eventSet:Clear(false)
	end

	table.clear(self.template)
	table.clear(self.templatesGroup)
	table.clear(self.templatesDic)
	table.clear(self.debugCreateParams)
	table.clear(self.asyncParamsSave)
end

function HUDCtrl:ClearEventListener()
	return
end

function HUDCtrl:CustomClearProcedure()
	return
end

function HUDCtrl:IsHideState()
	if gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.CanNotBeClientLocked) or gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.DontbeSelect) then
		return true
	end

	if gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.NearDeath) then
		return true
	end

	if gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.DeadS) then
		return true
	end

	if gCS.UnitStateMgr:HasState(self.unit, 10308) then
		return true
	end

	local dataSet = gDataSetManager:GetUnitData(self.unit.Pid)

	if dataSet and dataSet.beingAssassinated then
		return true
	end

	return false
end

function HUDCtrl:IsHpBarNeverShow()
	return self.unit.IsMe
end

function HUDCtrl:RefreshMissileAttackMarker(uuid, show)
	local unit = self.unit

	if show then
		if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.DistanceAttackMarker, unit.Pid, uuid)
		end
	elseif self.templatesGroup.missileLock and self.templatesGroup.missileLock[uuid] then
		local instanceId = self.templatesGroup.missileLock[uuid].wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function HUDCtrl:PlayDistanceAttackMarkerStepOneAni(time, uuid)
	local ani = self.templatesGroup.missileLock[uuid].ani
	local startAniTime = ani:GetClip("S_vx_S_DistanceAttackMarkerV02Template_01").length

	ani:Play("S_vx_S_DistanceAttackMarkerV02Template_01")

	if time < startAniTime then
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Stop()
		end, time)
	else
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Play("S_vx_S_DistanceAttackMarkerV02Template_02")
		end, startAniTime)
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Stop()
		end, time)
	end
end

function HUDCtrl:OnCreateDistanceAttackMarker(uuid)
	if self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker] and self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker][uuid] then
		local time = self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker][uuid]

		self:PlayDistanceAttackMarkerStepOneAni(time, uuid)

		self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker][uuid] = nil
	end
end

function HUDCtrl:PlayLockStateAni(uuid, show, time)
	if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
		if not self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker] then
			self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker] = {}
		else
			self.asyncParamsSave[gHudMgr.HUDTemplateType.DistanceAttackMarker][uuid] = time
		end
	else
		self:PlayDistanceAttackMarkerStepOneAni(time, uuid)
	end
end

function HUDCtrl:PlayAttackStateAni(uuid, show, time)
	if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
		return
	end

	local ani = self.templatesGroup.missileLock[uuid].ani
	local startAniTime = ani:GetClip("S_vx_S_DistanceAttackMarkerV02Template_03").length

	ani:Play("S_vx_S_DistanceAttackMarkerV02Template_03")

	if time < startAniTime then
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Stop()
		end, time)
	else
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Play("S_vx_S_DistanceAttackMarkerV02Template_04_loop")
		end, startAniTime)
		gLuaTimeMgrUtils.Delay(function ()
			if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
				return
			end

			ani:Stop()
		end, time)
	end
end

function HUDCtrl:AddBuffHeadIcon(buffId)
	local unit = self.unit

	if not unit then
		return
	end

	if self.templatesGroup.buffIcon and self.templatesGroup.buffIcon[buffId] then
		return
	end

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.BuffHeadIcon, unit.Pid, tostring(buffId))
end

function HUDCtrl:OnCreateBuffHeadIcon(buffId)
	if not self.templatesGroup.buffIcon or not self.templatesGroup.buffIcon[buffId] then
		return
	end

	local buffId = tonumber(buffId)
end

function HUDCtrl:RemoveBuffHeadIcon(buffId)
	if not self.templatesGroup.buffIcon or not self.templatesGroup.buffIcon[buffId] then
		return
	end

	local instanceId = self.templatesGroup.buffIcon[buffId].wgtId

	self:RemoveHudTemplate(instanceId)
end

function HUDCtrl.OnHudVisibleChange(cell)
	local self = cell.param
	local unitDataSet = self.unitDataSet
	local hudCanShow = not unitDataSet.isBuffHideNameBar and not unitDataSet.realInVisiable

	if hudCanShow and self.unit.ClientData.isMySpirit and not unitDataSet.isMe then
		hudCanShow = false
	end

	self.uiRoot.ForceHide = not hudCanShow
end

function HUDCtrl:AddDebugText(debugTag)
	local tag = nil

	if self.unit then
		tag = self.unit.Pid
	else
		tag = self.uniId
	end

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.DebugText, tag, debugTag)
end

function HUDCtrl:OnCreateDebugText(debugTag)
	local funName = string.format("OnCreateDebug%s", debugTag)

	if self[funName] then
		self[funName](self)
	end
end

function HUDCtrl:RemoveDebugText(debugTag)
	if not self.templatesGroup.debug or not self.templatesGroup.debug[debugTag] then
		return
	end

	local instanceId = self.templatesGroup.debug[debugTag].wgtId

	self:RemoveHudTemplate(instanceId)
end

function HUDCtrl:HandleDebugProcedure()
	if gCS.DebugBoolMgr.debugHpAndShieldNum then
		self:OnShowHpNum(true)
		self:OnShowDamAndDefNum(true)
	end

	if gCS.DebugBoolMgr.debugUnitLevel then
		self:OnShowLevelNum(true)
	end
end

function HUDCtrl:RegisterBindHandlersDebug()
	if not self.unit then
		return
	end

	local eventSet = self.eventSet
	local dataSet = self.unitDataSet

	eventSet:BindHandler2({
		dataSet,
		"hp",
		dataSet,
		"maxhp"
	}, self.OnDebugHpChange, self)
	eventSet:BindHandler2({
		dataSet,
		"dam",
		dataSet,
		"def"
	}, self.OnDebugDamAndDefChanged, self)
	eventSet:BindHandler(dataSet, "shield", self.OnDebugShieldChange, self)
	eventSet:BindHandler(dataSet, "partShieldChanged", self.OnDebugShieldChange, self)
	eventSet:BindHandler2({
		dataSet,
		"toughnessValue",
		dataSet,
		"toughnessMaxValue"
	}, self.OnDebugToughnessChange, self)
end

function HUDCtrl:GenDebugTextWithParams(debugTag, ...)
	local arg = {
		...
	}

	if not self.debugCreateParams[debugTag] then
		self.debugCreateParams[debugTag] = {}
	else
		table.clear(self.debugCreateParams[debugTag])
	end

	for _, v in ipairs(arg) do
		table.insert(self.debugCreateParams[debugTag], v)
	end

	self.debugCreateParams[debugTag].isEfficient = true

	self:AddDebugText(debugTag)
end

function HUDCtrl:CheckDebugTextExist(debugTag)
	return self.templatesGroup.debug and self.templatesGroup.debug[debugTag]
end

function HUDCtrl:CheckDebugParamsEfficient(debugTag)
	local result = nil

	if self.debugCreateParams[debugTag] and self.debugCreateParams[debugTag].isEfficient then
		result = true
	else
		result = false
	end

	self.debugCreateParams[debugTag].isEfficient = false

	return result
end

function HUDCtrl:OnShowId(visible, value)
	local Id = gHudMgr.DebugTag.Id

	if not self:CheckDebugTextExist(Id) then
		self:GenDebugTextWithParams(Id, visible, value)

		return
	end

	self.templatesGroup.debug[Id].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[Id].debugText = value
end

function HUDCtrl:OnCreateDebugId()
	local Id = gHudMgr.DebugTag.Id

	if not self:CheckDebugParamsEfficient(Id) then
		return
	end

	self:OnShowId(self.debugCreateParams[Id][1], self.debugCreateParams[Id][2])
end

function HUDCtrl:OnRemoveId()
	local Id = gHudMgr.DebugTag.Id

	if not self:CheckDebugTextExist(Id) then
		return
	end

	local instanceId = self.templatesGroup.debug[Id].wgtId

	self:RemoveHudTemplate(instanceId)
end

function HUDCtrl:OnShowHpNum(visible)
	self:OnShowDebugHpNum(visible)
	self:OnShowDebugShieldNum(visible)
	self:OnShowDebugToughnessNum(visible)
end

function HUDCtrl:OnShowDebugHpNum(visible)
	if not self.unit then
		return
	end

	local HpNum = gHudMgr.DebugTag.HpNum

	if not self:CheckDebugTextExist(HpNum) then
		self:GenDebugTextWithParams(HpNum, visible)

		return
	end

	self.templatesGroup.debug[HpNum].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[HpNum].debugText = gString.Format("%s/%s", math.floor(self.unitDataSet.hp), math.floor(self.unitDataSet.maxhp))
end

function HUDCtrl:OnCreateDebugHpNum()
	local HpNum = gHudMgr.DebugTag.HpNum

	if not self:CheckDebugParamsEfficient(HpNum) then
		return
	end

	self:OnShowDebugHpNum(self.debugCreateParams[HpNum][1])
end

function HUDCtrl:OnShowDebugShieldNum(visible)
	if not self.unit then
		return
	end

	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self:CheckDebugTextExist(ShieldNum) then
		self:GenDebugTextWithParams(ShieldNum, visible)

		return
	end

	self.templatesGroup.debug[ShieldNum].template:SetTemplateVisibility(visible)

	local text = nil

	if self.unitDataSet.shield > 0 then
		text = math.floor(self.unitDataSet.shield)
	else
		text = ""
	end

	if gCS.BattleManager.HasPartShield(self.unit) then
		text = text .. LTConfig.TextScriptTextConfig.GetConfig(89900194).Text
		local dic = gCS.BattleManager.GetPartShieldDic(self.unit)

		for index, info in pairs(dic:ToTable()) do
			local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(self.unit, index)
			text = text .. "index:" .. index .. ":" .. math.floor(info.value) .. "/" .. math.floor(maxPartShieldValue) .. " "
		end
	end

	if text == "" then
		self.templatesGroup.debug[ShieldNum].template:SetTemplateVisibility(false)
	end

	self.templatesGroup.debug[ShieldNum].debugText = text
end

function HUDCtrl:OnCreateDebugShieldNum()
	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self:CheckDebugParamsEfficient(ShieldNum) then
		return
	end

	self:OnShowDebugShieldNum(self.debugCreateParams[ShieldNum][1])
end

function HUDCtrl:OnShowDebugToughnessNum(visible)
	if not self.unit then
		return
	end

	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self:CheckDebugTextExist(ToughnessNum) then
		self:GenDebugTextWithParams(ToughnessNum, visible)

		return
	end

	self.templatesGroup.debug[ToughnessNum].template:SetTemplateVisibility(visible)

	local text = nil
	local currentToughness = gCS.ToughnessMgr:GetCurrentToughness(self.unit)
	local BaseToughness = gCS.ToughnessMgr:GetBaseToughness(self.unit)
	text = LTConfig.TextScriptTextConfig.GetConfig(89900195).Text .. currentToughness .. "/" .. BaseToughness
	self.templatesGroup.debug[ToughnessNum].debugText = text
end

function HUDCtrl:OnCreateDebugToughnessNum()
	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self:CheckDebugParamsEfficient(ToughnessNum) then
		return
	end

	self:OnShowDebugToughnessNum(self.debugCreateParams[ToughnessNum][1])
end

function HUDCtrl:OnShowDamAndDefNum(visible)
	if not self.unit then
		return
	end

	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self:CheckDebugTextExist(DamAndDefNum) then
		self:GenDebugTextWithParams(DamAndDefNum, visible)

		return
	end

	self.templatesGroup.debug[DamAndDefNum].template:SetTemplateVisibility(visible)

	if self.unitDataSet.dam == nil or self.unitDataSet.def == nil then
		self.unitDataSet.dam = 0
		self.unitDataSet.def = 0
	end

	self.templatesGroup.debug[DamAndDefNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900196).Text .. math.floor(self.unitDataSet.dam) .. LTConfig.TextScriptTextConfig.GetConfig(89900197).Text .. math.floor(self.unitDataSet.def)
end

function HUDCtrl:OnCreateDebugDamAndDefNum()
	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self:CheckDebugParamsEfficient(DamAndDefNum) then
		return
	end

	self:OnShowDamAndDefNum(self.debugCreateParams[DamAndDefNum][1])
end

function HUDCtrl:OnShowLevelNum(visible)
	if not self.unit then
		return
	end

	local LevelNum = gHudMgr.DebugTag.LevelNum

	if not self:CheckDebugTextExist(LevelNum) then
		self:GenDebugTextWithParams(LevelNum, visible)

		return
	end

	self.templatesGroup.debug[LevelNum].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[LevelNum].debugText = self.unitDataSet.level
end

function HUDCtrl:OnCreateDebugLevelNum()
	local LevelNum = gHudMgr.DebugTag.LevelNum

	if not self:CheckDebugParamsEfficient(LevelNum) then
		return
	end

	self:OnShowLevelNum(self.debugCreateParams[LevelNum][1])
end

function HUDCtrl:OnShowAIAction(msg, fadeOutTime)
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self:CheckDebugTextExist(AIAction) then
		self:GenDebugTextWithParams(AIAction, msg, fadeOutTime)

		return
	end

	self.templatesGroup.debug[AIAction].template:SetTemplateVisibility(true)

	self.templatesGroup.debug[AIAction].debugText = msg

	if fadeOutTime then
		if self.AIActionDebugTimer then
			gLuaTimeMgrUtils.CancelUnitDelay(self.AIActionDebugTimer)
		end

		self.AIActionDebugTimer = gLuaTimeMgrUtils.Delay(function ()
			if self.templatesGroup.debug and self.templatesGroup.debug[AIAction] then
				self.templatesGroup.debug[AIAction].template:SetTemplateVisibility(false)
			end

			self.AIActionDebugTimer = nil
		end, fadeOutTime)
	end
end

function HUDCtrl:OnCreateDebugAIAction()
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self:CheckDebugParamsEfficient(AIAction) then
		return
	end

	self:OnShowAIAction(self.debugCreateParams[AIAction][1], self.debugCreateParams[AIAction][2])
end

function HUDCtrl:OnRemoveAIAction()
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self:CheckDebugTextExist(AIAction) then
		return
	end

	local instanceId = self.templatesGroup.debug[AIAction].wgtId

	self:RemoveHudTemplate(instanceId)
end

function HUDCtrl:OnShowVehicleInfo(msg)
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self:CheckDebugTextExist(vehicleInfo) then
		self:GenDebugTextWithParams(vehicleInfo, msg)

		return
	end

	self.templatesGroup.debug[vehicleInfo].template:SetTemplateVisibility(true)

	self.templatesGroup.debug[vehicleInfo].debugText = msg
end

function HUDCtrl:OnCreateDebugVehicleInfo()
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self:CheckDebugParamsEfficient(vehicleInfo) then
		return
	end

	self:OnShowVehicleInfo(self.debugCreateParams[vehicleInfo][1])
end

function HUDCtrl:OnRemoveVehicleInfo()
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self:CheckDebugTextExist(vehicleInfo) then
		return
	end

	local instanceId = self.templatesGroup.debug[vehicleInfo].wgtId

	self:RemoveHudTemplate(instanceId)
end

function HUDCtrl.OnDebugHpChange(cell)
	local self = cell.param
	local HpNum = gHudMgr.DebugTag.HpNum

	if not self:CheckDebugTextExist(HpNum) then
		return
	end

	self.templatesGroup.debug[HpNum].debugText = gString.Format("%s/%s", math.floor(self.unitDataSet.hp), math.floor(self.unitDataSet.maxhp))
end

function HUDCtrl.OnDebugDamAndDefChanged(cell)
	local self = cell.param
	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self:CheckDebugTextExist(DamAndDefNum) then
		return
	end

	self.templatesGroup.debug[DamAndDefNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900196).Text .. math.floor(self.unitDataSet.dam) .. LTConfig.TextScriptTextConfig.GetConfig(89900197).Text .. math.floor(self.unitDataSet.def)
end

function HUDCtrl.OnDebugShieldChange(cell)
	local self = cell.param
	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self:CheckDebugTextExist(ShieldNum) then
		return
	end

	local text = nil

	if self.unitDataSet.shield > 0 then
		text = math.floor(self.unitDataSet.shield)
	else
		text = ""
	end

	if gCS.BattleManager.HasPartShield(self.unit) then
		text = text .. LTConfig.TextScriptTextConfig.GetConfig(89900194).Text
		local dic = gCS.BattleManager.GetPartShieldDic(self.unit)

		for index, info in pairs(dic:ToTable()) do
			local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(self.unit, index)
			text = text .. "index:" .. index .. ":" .. math.floor(info.value) .. "/" .. math.floor(maxPartShieldValue) .. " "
		end
	end

	self.templatesGroup.debug[ShieldNum].debugText = text
end

function HUDCtrl.OnDebugToughnessChange(cell)
	local self = cell.param
	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self:CheckDebugTextExist(ToughnessNum) then
		return
	end

	self.templatesGroup.debug[ToughnessNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900195).Text .. math.floor(self.unitDataSet.toughnessValue) .. "/" .. math.floor(self.unitDataSet.toughnessMaxValue)
end

return HUDCtrl
