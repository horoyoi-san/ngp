-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\HudController.lua
-- Decompiled from: 02286_HudController.lua_f2a212cc92f5.luajit

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

HUDCtrl.ctor = function(self)
	self.updateIndex = 0
	self.__isActiveSelf__ = false
	self.uniId = InvalidId
	self.template = {}
	self.templatesGroup = {}
	self.templatesDic = {}
	self.unitDataSet = nil
	self.eventSet = nil
	self.asyncParamsSave = {}
	self.pendingMissileRemoval = {}
	self.ignoreDistanceSet = {}
	self.offscreenSet = {}
	self.ignoreOcclusionCulledSet = {}
	self.debugCreateParams = {}

	self.SetTemplatesMeta(self)
end

HUDCtrl.RegisterBindHandlers = function(self)
	if self.unit then
		self.unitDataSet = gDataSetManager:TryGetOrCreateUnitData(self.unit.Pid)
		self.eventSet = C_DataEventSet.New()
		local eventSet = self.eventSet
		local dataSet = self.unitDataSet

		if not self.unitDataSet then
			print_error("unitDataSet创建失败！", self.unit.ClientData.AgentId)
		end

		eventSet.BindHandler2(eventSet, {
			dataSet,
			"}\\xef\\xf9/1\\xcae%\\xfbJ\\x81\t`\\xc7\\xf4",
			dataSet,
			"\\xf5\\x9f\\xe05\\xd0\\xf9\\x81\\xec\\x80,-",
			dataSet,
			"s1P^"
		}, self.OnHudVisibleChange, self, true)
	end
end

HUDCtrl.SetTemplatesMeta = function(self)
	setmetatable(self.template, templateMeta)
	setmetatable(self.templatesGroup, templateMeta)
end

HUDCtrl.Init = function(self, uniId, hudUIRoot, unit, data)
	self.uniId = uniId
	self.unit = unit
	self.uiRoot = hudUIRoot
	self.data = data

	self.RefreshData(self)
	self.RegisterBindHandlers(self)
	self.RegisterEventListener(self)
	self.CustomProcedure(self)
	self.HandleDebugProcedure(self)
	self.RegisterBindHandlersDebug(self)
end

HUDCtrl.RegisterEventListener = function(self)
end

HUDCtrl.RefreshData = function(self)
end

HUDCtrl.CustomProcedure = function(self)
end

HUDCtrl.AddHudTemplate = function(self, InstanceId, templateType, templateTag)
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

HUDCtrl.RemoveHudTemplate = function(self, InstanceId)
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

HUDCtrl.GetIsTemplateExist = function(self, templateType)
	return self.template[templateType] or self.templatesGroup[templateType] and table.count(self.templatesGroup[templateType]) >= 0
end

HUDCtrl.GetHudTargetType = function(self)
	return self.tType
end

HUDCtrl.IsNpcHud = function(self)
	return self.tType ~= gHudMgr.HUDTargetType.Npc
end

HUDCtrl.GetUIRoot = function(self)
	return self.uiRoot
end

HUDCtrl.GetUniId = function(self)
	return self.uniId
end

HUDCtrl.SetIgnoreDistance = function(self, enable, templateType)
	if enable then
		self.ignoreDistanceSet[templateType] = true
	else
		self.ignoreDistanceSet[templateType] = false
	end

	local needIgnore = false

	for _, v in pairs(self.ignoreDistanceSet) do
		if v then
			needIgnore = true

			break
		end
	end

	self.uiRoot:SetIgnoreDistance(needIgnore)
end

HUDCtrl.SetEnableOffscreen = function(self, enable, templateType)
	if enable then
		self.offscreenSet[templateType] = true
	else
		self.offscreenSet[templateType] = false
	end

	local needOffscreen = false

	for _, v in pairs(self.offscreenSet) do
		if v then
			needOffscreen = true

			break
		end
	end

	self.uiRoot:SetEnableOffscreen(needOffscreen)
end

HUDCtrl.SetIgnoreOcclusionCulled = function(self, enable, templateType)
	if enable then
		self.ignoreOcclusionCulledSet[templateType] = true
	else
		self.ignoreOcclusionCulledSet[templateType] = false
	end

	local needIgnore = false

	for _, v in pairs(self.ignoreOcclusionCulledSet) do
		if v then
			needIgnore = true

			break
		end
	end

	self.uiRoot.ignoreOcclusionCulled = needIgnore
end

HUDCtrl.Clear = function(self)
	self.ClearEventListener(self)
	self.CustomClearProcedure(self)

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
	table.clear(self.ignoreDistanceSet)
	table.clear(self.offscreenSet)
	table.clear(self.ignoreOcclusionCulledSet)
end

HUDCtrl.ClearEventListener = function(self)
end

HUDCtrl.CustomClearProcedure = function(self)
end

HUDCtrl.IsHideState = function(self)
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

HUDCtrl.IsHpBarNeverShow = function(self)
	return self.unit.IsMe
end

HUDCtrl.RefreshMissileAttackMarker = function(self, uuid, show)
	local unit = self.unit
	local DAM = gHudMgr.HUDTemplateType.DistanceAttackMarker

	if show then
		self.pendingMissileRemoval[uuid] = nil

		if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
			HUDManager.AddHUDTemplate(DAM, unit.Pid, uuid)
		end
	else
		if self.templatesGroup.missileLock and self.templatesGroup.missileLock[uuid] then
			local instanceId = self.templatesGroup.missileLock[uuid].wgtId

			self.RemoveHudTemplate(self, instanceId)
		else
			self.pendingMissileRemoval[uuid] = true
		end

		if self.asyncParamsSave[DAM] then
			self.asyncParamsSave[DAM][uuid] = nil
		end
	end
end

HUDCtrl.PlayDistanceAttackMarkerStepOneAni = function(self, time, uuid)
	local ani = self.templatesGroup.missileLock[uuid].ani
	local startAniTime = ani.GetClip(ani, "S_vx_S_DistanceAttackMarkerV02Template_01").length

	ani.Play(ani, "S_vx_S_DistanceAttackMarkerV02Template_01")

	if time >= startAniTime then
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

HUDCtrl.OnCreateDistanceAttackMarker = function(self, uuid)
	local DAM = gHudMgr.HUDTemplateType.DistanceAttackMarker

	if self.pendingMissileRemoval[uuid] then
		self.pendingMissileRemoval[uuid] = nil

		if self.asyncParamsSave[DAM] then
			self.asyncParamsSave[DAM][uuid] = nil
		end

		if self.templatesGroup.missileLock and self.templatesGroup.missileLock[uuid] then
			local instanceId = self.templatesGroup.missileLock[uuid].wgtId

			self.RemoveHudTemplate(self, instanceId)
		end

		return
	end

	if self.asyncParamsSave[DAM] and self.asyncParamsSave[DAM][uuid] then
		local time = self.asyncParamsSave[DAM][uuid]

		self.PlayDistanceAttackMarkerStepOneAni(self, time, uuid)

		self.asyncParamsSave[DAM][uuid] = nil
	end
end

HUDCtrl.PlayLockStateAni = function(self, uuid, show, time)
	if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
		local DAM = gHudMgr.HUDTemplateType.DistanceAttackMarker

		if not self.asyncParamsSave[DAM] then
			self.asyncParamsSave[DAM] = {}
		end

		self.asyncParamsSave[DAM][uuid] = time
	else
		self.PlayDistanceAttackMarkerStepOneAni(self, time, uuid)
	end
end

HUDCtrl.PlayAttackStateAni = function(self, uuid, show, time)
	if not self.templatesGroup.missileLock or not self.templatesGroup.missileLock[uuid] then
		return
	end

	local ani = self.templatesGroup.missileLock[uuid].ani
	local startAniTime = ani.GetClip(ani, "S_vx_S_DistanceAttackMarkerV02Template_03").length

	ani.Play(ani, "S_vx_S_DistanceAttackMarkerV02Template_03")

	if time >= startAniTime then
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

HUDCtrl.AddBuffHeadIcon = function(self, buffId)
	local unit = self.unit

	if not unit then
		return
	end

	if self.templatesGroup.buffIcon and self.templatesGroup.buffIcon[buffId] then
		return
	end

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.BuffHeadIcon, unit.Pid, tostring(buffId))
end

HUDCtrl.OnCreateBuffHeadIcon = function(self, buffId)
	if not self.templatesGroup.buffIcon or not self.templatesGroup.buffIcon[buffId] then
		return
	end

	local buffId = tonumber(buffId)
end

HUDCtrl.RemoveBuffHeadIcon = function(self, buffId)
	if not self.templatesGroup.buffIcon or not self.templatesGroup.buffIcon[buffId] then
		return
	end

	local instanceId = self.templatesGroup.buffIcon[buffId].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.OnHudVisibleChange = function(cell)
	local self = cell.param
	local unitDataSet = self.unitDataSet
	local hudCanShow = not unitDataSet.isBuffHideNameBar and not unitDataSet.realInVisiable

	if hudCanShow and self.unit.ClientData.isMySpirit and not unitDataSet.isMe then
		hudCanShow = false
	end

	self.uiRoot.ForceHide = not hudCanShow
end

HUDCtrl.AddDebugText = function(self, debugTag)
	local tag = nil

	if self.unit then
		tag = self.unit.Pid
	else
		tag = self.uniId
	end

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.DebugText, tag, debugTag)
end

HUDCtrl.OnCreateDebugText = function(self, debugTag)
	local funName = string.format("OnCreateDebug%s", debugTag)

	if self[funName] then
		self[funName](self)
	end
end

HUDCtrl.RemoveDebugText = function(self, debugTag)
	if not self.templatesGroup.debug or not self.templatesGroup.debug[debugTag] then
		return
	end

	local instanceId = self.templatesGroup.debug[debugTag].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.HandleDebugProcedure = function(self)
	if gCS.DebugBoolMgr.debugHpAndShieldNum then
		self.OnShowHpNum(self, true)
		self.OnShowDamAndDefNum(self, true)
	end

	if gCS.DebugBoolMgr.debugUnitLevel then
		self.OnShowLevelNum(self, true)
	end
end

HUDCtrl.RegisterBindHandlersDebug = function(self)
	if not self.unit then
		return
	end

	local eventSet = self.eventSet
	local dataSet = self.unitDataSet

	eventSet.BindHandler2(eventSet, {
		dataSet,
		"",
		dataSet,
		"@\\xaf\\xba\\xa7\\xa6"
	}, self.OnDebugHpChange, self)
	eventSet.BindHandler2(eventSet, {
		dataSet,
		"\\x8aik",
		dataSet,
		"\\x8am`"
	}, self.OnDebugDamAndDefChanged, self)
	eventSet.BindHandler(eventSet, dataSet, "shield", self.OnDebugShieldChange, self)
	eventSet.BindHandler(eventSet, dataSet, "partShieldChanged", self.OnDebugShieldChange, self)
	eventSet.BindHandler2(eventSet, {
		dataSet,
		"\\xf3\\x95\\xeb\\xe3\\xf9\\xbe\\xec\\x8e5-",
		dataSet,
		"`\\xf32\\xeb!9*\\xd0r\r\\xd4S\\xba\rN\\xd3\\xe3"
	}, self.OnDebugToughnessChange, self)
end

HUDCtrl.GenDebugTextWithParams = function(self, debugTag, ...)
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

	self.AddDebugText(self, debugTag)
end

HUDCtrl.CheckDebugTextExist = function(self, debugTag)
	return self.templatesGroup.debug and self.templatesGroup.debug[debugTag]
end

HUDCtrl.CheckDebugParamsEfficient = function(self, debugTag)
	local result = nil

	if self.debugCreateParams[debugTag] and self.debugCreateParams[debugTag].isEfficient then
		result = true
	else
		result = false
	end

	if self.debugCreateParams[debugTag] then
		self.debugCreateParams[debugTag].isEfficient = false
	end

	return result
end

HUDCtrl.OnShowId = function(self, visible, value)
	local Id = gHudMgr.DebugTag.Id

	if not self.CheckDebugTextExist(self, Id) then
		self.GenDebugTextWithParams(self, Id, visible, value)

		return
	end

	self.templatesGroup.debug[Id].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[Id].debugText = value
end

HUDCtrl.OnCreateDebugId = function(self)
	local Id = gHudMgr.DebugTag.Id

	if not self.CheckDebugParamsEfficient(self, Id) then
		return
	end

	self.OnShowId(self, self.debugCreateParams[Id][1], self.debugCreateParams[Id][2])
end

HUDCtrl.OnRemoveId = function(self)
	local Id = gHudMgr.DebugTag.Id

	if not self.CheckDebugTextExist(self, Id) then
		return
	end

	local instanceId = self.templatesGroup.debug[Id].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.OnShowHpNum = function(self, visible)
	self.OnShowDebugHpNum(self, visible)
	self.OnShowDebugShieldNum(self, visible)
	self.OnShowDebugToughnessNum(self, visible)
	self.OnShowDebugPoiseNum(self, visible)
end

HUDCtrl.OnShowDebugHpNum = function(self, visible)
	if not self.unit then
		return
	end

	local HpNum = gHudMgr.DebugTag.HpNum

	if not self.CheckDebugTextExist(self, HpNum) then
		self.GenDebugTextWithParams(self, HpNum, visible)

		return
	end

	self.templatesGroup.debug[HpNum].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[HpNum].debugText = gString.Format("%s/%s", math.floor(self.unitDataSet.hp), math.floor(self.unitDataSet.maxhp))
end

HUDCtrl.OnCreateDebugHpNum = function(self)
	local HpNum = gHudMgr.DebugTag.HpNum

	if not self.CheckDebugParamsEfficient(self, HpNum) then
		return
	end

	self.OnShowDebugHpNum(self, self.debugCreateParams[HpNum][1])
end

HUDCtrl.OnShowDebugShieldNum = function(self, visible)
	if not self.unit then
		return
	end

	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self.CheckDebugTextExist(self, ShieldNum) then
		self.GenDebugTextWithParams(self, ShieldNum, visible)

		return
	end

	self.templatesGroup.debug[ShieldNum].template:SetTemplateVisibility(visible)

	local text = nil

	if self.unitDataSet.shield <= 0 then
		text = math.floor(self.unitDataSet.shield)
	else
		text = ""
	end

	if gCS.BattleManager.HasPartShield(self.unit) then
		text = text .. LTConfig.TextScriptTextConfig.GetConfig(89900194).Text
		local dic = gCS.BattleManager.GetPartShieldDic(self.unit)

		for index, info in pairs(dic.ToTable(dic)) do
			local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(self.unit, index)
			text = text .. "index:" .. index .. ":" .. math.floor(info.value) .. "/" .. math.floor(maxPartShieldValue) .. " "
		end
	end

	if text ~= "" then
		self.templatesGroup.debug[ShieldNum].template:SetTemplateVisibility(false)
	end

	self.templatesGroup.debug[ShieldNum].debugText = text
end

HUDCtrl.OnCreateDebugShieldNum = function(self)
	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self.CheckDebugParamsEfficient(self, ShieldNum) then
		return
	end

	self.OnShowDebugShieldNum(self, self.debugCreateParams[ShieldNum][1])
end

HUDCtrl.OnShowDebugToughnessNum = function(self, visible)
	if not self.unit then
		return
	end

	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self.CheckDebugTextExist(self, ToughnessNum) then
		self.GenDebugTextWithParams(self, ToughnessNum, visible)

		return
	end

	self.templatesGroup.debug[ToughnessNum].template:SetTemplateVisibility(visible)

	local text = nil
	local currentToughness = gCS.ToughnessMgr:GetCurrentToughness(self.unit)
	local BaseToughness = gCS.ToughnessMgr:GetBaseToughness(self.unit)
	text = LTConfig.TextScriptTextConfig.GetConfig(89900195).Text .. currentToughness .. "/" .. BaseToughness
	self.templatesGroup.debug[ToughnessNum].debugText = text
end

HUDCtrl.OnCreateDebugToughnessNum = function(self)
	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self.CheckDebugParamsEfficient(self, ToughnessNum) then
		return
	end

	self.OnShowDebugToughnessNum(self, self.debugCreateParams[ToughnessNum][1])
end

HUDCtrl.OnShowDebugPoiseNum = function(self, visible)
	if not self.unit then
		return
	end

	local PoiseNum = gHudMgr.DebugTag.PoiseNum

	if not self.CheckDebugTextExist(self, PoiseNum) then
		self.GenDebugTextWithParams(self, PoiseNum, visible)

		return
	end

	self.templatesGroup.debug[PoiseNum].template:SetTemplateVisibility(visible)
	self:OnShowPoiseNumValue()
end

HUDCtrl.OnShowPoiseNumValue = function(self)
	local text = nil
	local currentDisarmRate = self.unit.ClientData.DisarmRate
	local maxDisarmValue = self.unit.ClientData.MaxPoiseValue
	text = LTConfig.TextCommonTextConfig.GetConfig(74009780).Text .. math.floor(currentDisarmRate * maxDisarmValue) .. "/" .. maxDisarmValue
	self.templatesGroup.debug[gHudMgr.DebugTag.PoiseNum].debugText = text
end

HUDCtrl.OnCreateDebugPoiseNum = function(self)
	local PoiseNum = gHudMgr.DebugTag.PoiseNum

	if not self.CheckDebugParamsEfficient(self, PoiseNum) then
		return
	end

	self.OnShowDebugPoiseNum(self, self.debugCreateParams[PoiseNum][1])
end

HUDCtrl.OnShowDamAndDefNum = function(self, visible)
	if not self.unit then
		return
	end

	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self.CheckDebugTextExist(self, DamAndDefNum) then
		self.GenDebugTextWithParams(self, DamAndDefNum, visible)

		return
	end

	self.templatesGroup.debug[DamAndDefNum].template:SetTemplateVisibility(visible)

	if self.unitDataSet.dam ~= nil or self.unitDataSet.def ~= nil then
		self.unitDataSet.dam = 0
		self.unitDataSet.def = 0
	end

	self.templatesGroup.debug[DamAndDefNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900196).Text .. math.floor(self.unitDataSet.dam) .. LTConfig.TextScriptTextConfig.GetConfig(89900197).Text .. math.floor(self.unitDataSet.def)
end

HUDCtrl.OnCreateDebugDamAndDefNum = function(self)
	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self.CheckDebugParamsEfficient(self, DamAndDefNum) then
		return
	end

	self.OnShowDamAndDefNum(self, self.debugCreateParams[DamAndDefNum][1])
end

HUDCtrl.OnShowLevelNum = function(self, visible)
	if not self.unit then
		return
	end

	local LevelNum = gHudMgr.DebugTag.LevelNum

	if not self.CheckDebugTextExist(self, LevelNum) then
		self.GenDebugTextWithParams(self, LevelNum, visible)

		return
	end

	self.templatesGroup.debug[LevelNum].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[LevelNum].debugText = self.unitDataSet.level
end

HUDCtrl.OnCreateDebugLevelNum = function(self)
	local LevelNum = gHudMgr.DebugTag.LevelNum

	if not self.CheckDebugParamsEfficient(self, LevelNum) then
		return
	end

	self.OnShowLevelNum(self, self.debugCreateParams[LevelNum][1])
end

HUDCtrl.OnShowAIAction = function(self, msg, fadeOutTime)
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self.CheckDebugTextExist(self, AIAction) then
		self.GenDebugTextWithParams(self, AIAction, msg, fadeOutTime)

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

HUDCtrl.OnCreateDebugAIAction = function(self)
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self.CheckDebugParamsEfficient(self, AIAction) then
		return
	end

	self.OnShowAIAction(self, self.debugCreateParams[AIAction][1], self.debugCreateParams[AIAction][2])
end

HUDCtrl.OnRemoveAIAction = function(self)
	local AIAction = gHudMgr.DebugTag.AIAction

	if not self.CheckDebugTextExist(self, AIAction) then
		return
	end

	local instanceId = self.templatesGroup.debug[AIAction].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.OnShowVehicleInfo = function(self, msg)
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self.CheckDebugTextExist(self, vehicleInfo) then
		self.GenDebugTextWithParams(self, vehicleInfo, msg)

		return
	end

	self.templatesGroup.debug[vehicleInfo].template:SetTemplateVisibility(true)

	self.templatesGroup.debug[vehicleInfo].debugText = msg
end

HUDCtrl.OnCreateDebugVehicleInfo = function(self)
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self.CheckDebugParamsEfficient(self, vehicleInfo) then
		return
	end

	self.OnShowVehicleInfo(self, self.debugCreateParams[vehicleInfo][1])
end

HUDCtrl.OnRemoveVehicleInfo = function(self)
	local vehicleInfo = gHudMgr.DebugTag.VehicleInfo

	if not self.CheckDebugTextExist(self, vehicleInfo) then
		return
	end

	local instanceId = self.templatesGroup.debug[vehicleInfo].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.OnRefreshPoiseNum = function(self)
	local poiseNum = gHudMgr.DebugTag.PoiseNum

	if not self.CheckDebugTextExist(self, poiseNum) then
		return
	end

	self.OnShowPoiseNumValue(self)
end

HUDCtrl.OnShowBasketball = function(self, visible, value)
	local Id = gHudMgr.DebugTag.BasketBall

	if not self.CheckDebugTextExist(self, Id) then
		self.GenDebugTextWithParams(self, Id, visible, value)

		return
	end

	self.templatesGroup.debug[Id].template:SetTemplateVisibility(visible)

	self.templatesGroup.debug[Id].debugText = value
end

HUDCtrl.OnCreateDebugBasketBall = function(self)
	local Id = gHudMgr.DebugTag.BasketBall

	if not self.CheckDebugParamsEfficient(self, Id) then
		return
	end

	self.OnShowBasketball(self, self.debugCreateParams[Id][1], self.debugCreateParams[Id][2])
end

HUDCtrl.OnRemoveBasketBall = function(self)
	local Id = gHudMgr.DebugTag.BasketBall

	if not self.CheckDebugTextExist(self, Id) then
		return
	end

	local instanceId = self.templatesGroup.debug[Id].wgtId

	self.RemoveHudTemplate(self, instanceId)
end

HUDCtrl.OnDebugHpChange = function(cell)
	local self = cell.param
	local HpNum = gHudMgr.DebugTag.HpNum

	if not self.CheckDebugTextExist(self, HpNum) then
		return
	end

	self.templatesGroup.debug[HpNum].debugText = gString.Format("%s/%s", math.floor(self.unitDataSet.hp), math.floor(self.unitDataSet.maxhp))
end

HUDCtrl.OnDebugDamAndDefChanged = function(cell)
	local self = cell.param
	local DamAndDefNum = gHudMgr.DebugTag.DamAndDefNum

	if not self.CheckDebugTextExist(self, DamAndDefNum) then
		return
	end

	self.templatesGroup.debug[DamAndDefNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900196).Text .. math.floor(self.unitDataSet.dam) .. LTConfig.TextScriptTextConfig.GetConfig(89900197).Text .. math.floor(self.unitDataSet.def)
end

HUDCtrl.OnDebugShieldChange = function(cell)
	local self = cell.param
	local ShieldNum = gHudMgr.DebugTag.ShieldNum

	if not self.CheckDebugTextExist(self, ShieldNum) then
		return
	end

	local text = nil

	if self.unitDataSet.shield <= 0 then
		text = math.floor(self.unitDataSet.shield)
	else
		text = ""
	end

	if gCS.BattleManager.HasPartShield(self.unit) then
		text = text .. LTConfig.TextScriptTextConfig.GetConfig(89900194).Text
		local dic = gCS.BattleManager.GetPartShieldDic(self.unit)

		for index, info in pairs(dic.ToTable(dic)) do
			local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(self.unit, index)
			text = text .. "index:" .. index .. ":" .. math.floor(info.value) .. "/" .. math.floor(maxPartShieldValue) .. " "
		end
	end

	self.templatesGroup.debug[ShieldNum].debugText = text
end

HUDCtrl.OnDebugToughnessChange = function(cell)
	local self = cell.param
	local ToughnessNum = gHudMgr.DebugTag.ToughnessNum

	if not self.CheckDebugTextExist(self, ToughnessNum) then
		return
	end

	self.templatesGroup.debug[ToughnessNum].debugText = LTConfig.TextScriptTextConfig.GetConfig(89900195).Text .. math.floor(self.unitDataSet.toughnessValue) .. "/" .. math.floor(self.unitDataSet.toughnessMaxValue)
end

return HUDCtrl
