-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\NpcHUDCtrl.lua
-- Decompiled from: 02288_NpcHUDCtrl.lua_a3a616fa60a6.luajit

local AgentConfig = LTConfig.AgentConfig
local PetAnimalConfig = LTConfig.PetAnimalConfig
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_NpcHUDCtrl = DefClass("C_NpcHUDCtrl", C_NpcHUDCtrl, HUDCtrl)
local NpcHUDCtrl = C_NpcHUDCtrl

NpcHUDCtrl.ctor = function(self)
	self.tType = gHudMgr.HUDTargetType.Npc
	self.npcName = nil
	self.npcPid = nil
	self.npcTitle = nil
	self.npcIcon = nil
	self.allowName = true
	self.allowTitle = true
	self.allowIcon = true
	self.iconDisallowReasons = {}
	self.nameRecord = true
	self.titleRecord = true
	self.iconRecord = true
	self.topAnimQueue = {}
	self.OnLanguageChangeHandler = nil
	self.cfg = nil
end

NpcHUDCtrl.RegisterBindHandlers = function(self)
	NpcHUDCtrl.base.RegisterBindHandlers(self)

	if not self.unitDataSet then
		print_error("NpcHUD对应unit数据不存在!")

		return
	end

	self.eventSet:BindHandler2({
		self.unitDataSet,
		"t#p^",
		self.unitDataSet,
		"Y\\xa7\\xb6\\xa3\\xb3"
	}, self.OnForceRefreshNameString, self)

	if self.cfg ~= nil then
		print_error("NPC Config不存在, agentId = ", self.unit.ClientData.AgentId)
	elseif self.cfg.Tag then
		for _, v in ipairs(self.cfg.Tag) do
			if v ~= LTConfig.AgentConfig.TagType.StealthNPC then
				if self.unitDataSet.detectionValue ~= nil then
					self.unitDataSet.detectionValue = 0
				end

				self.eventSet:BindHandler(self.unitDataSet, "detectionValue", self.OnRefreshDetectionValue, self)

				break
			end
		end
	end
end

NpcHUDCtrl.RegisterEventListener = function(self)
	self.OnLanguageChangeHandler = function()
		self.OnForceRefreshNameString({
			param = self
		})
	end

	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self.OnLanguageChangeHandler)
end

NpcHUDCtrl.RefreshData = function(self)
	if not self.unit then
		print_error("NpcHUD对应unit不存在!", self.uniId)
	end

	local cfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId) or PetAnimalConfig.GetConfig(self.unit.ClientData.SubType)
	self.cfg = cfg
end

NpcHUDCtrl.CustomProcedure = function(self)
	local pid = self.unit.Pid
	local npcCfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId)

	if npcCfg == nil then
		if npcCfg.NameDisplay and npcCfg.NameDisplay <= 0 then
			local dataSet = self.unitDataSet
			self.npcName = dataSet.name
			self.npcTitle = dataSet.title

			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcName, self.unit.Pid)
		end

		if npcCfg.HudIconId and npcCfg.HudIconId <= 0 then
			self.npcIcon = npcCfg.HudIconId

			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcIcon, self.unit.Pid)
		end
	end

	gMessageManager:SendMessage(gEventConstants.NPC_HUD_ROOT_READY, pid)
end

NpcHUDCtrl.OnCreateNpcName = function(self)
	self.template.npcName.npcNameText = self.npcName
end

NpcHUDCtrl.SetNpcNameVisibility = function(self, show)
	if not self.template.npcName then
		return
	end

	self.nameRecord = show

	if self.allowName then
		self.template.npcName.template:SetTemplateVisibility(show)
	else
		self.template.npcName.template:SetTemplateVisibility(false)
	end
end

NpcHUDCtrl.SetNpcNameAllow = function(self, allow)
	self.allowName = allow

	if allow then
		self.SetNpcNameVisibility(self, self.nameRecord)
	else
		self.SetNpcNameVisibility(self, false)
	end
end

NpcHUDCtrl.OnCreateNpcTitle = function(self)
	self.template.npcTitle.npcTitleText = self.npcTitle
end

NpcHUDCtrl.SetNpcTitleVisibility = function(self, show)
	if not self.template.npcTitle then
		return
	end

	self.titleRecord = show

	if self.allowTitle then
		self.template.npcTitle.template:SetTemplateVisibility(show)
	else
		self.template.npcTitle.template:SetTemplateVisibility(false)
	end
end

NpcHUDCtrl.SetNpcTitleAllow = function(self, allow)
	self.allowTitle = allow

	if allow then
		self.SetNpcTitleVisibility(self, self.titleRecord)
	else
		self.SetNpcTitleVisibility(self, false)
	end
end

NpcHUDCtrl.AddNpcIcon = function(self, iconId)
	if self.template.npcIcon then
		self.template.npcIcon.npcIconId = iconId

		return
	end

	self.npcIcon = iconId

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcIcon, self.unit.Pid)
end

NpcHUDCtrl.RemoveNpcIcon = function(self)
	if self.template.npcIcon then
		local npcCfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId)

		if npcCfg == nil and npcCfg.HudIconId and npcCfg.HudIconId <= 0 then
			self.npcIcon = npcCfg.HudIconId
			self.template.npcIcon.npcIconId = self.npcIcon

			return
		end

		local instanceId = self.template.npcIcon.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end
end

NpcHUDCtrl.OnCreateNpcIcon = function(self)
	self.template.npcIcon.npcIconId = self.npcIcon
end

NpcHUDCtrl.SetNpcIconVisibility = function(self, show)
	if not self.template.npcIcon then
		return
	end

	self.iconRecord = show

	if self.allowIcon then
		self.template.npcIcon.template:SetTemplateVisibility(show)
	else
		self.template.npcIcon.template:SetTemplateVisibility(false)
	end
end

NpcHUDCtrl.SetNpcIconAllow = function(self, allow, reason)
	reason = reason or "default"

	if allow then
		self.iconDisallowReasons[reason] = nil
	else
		self.iconDisallowReasons[reason] = true
	end

	self.allowIcon = next(self.iconDisallowReasons) ~= nil

	if self.allowIcon then
		self.SetNpcIconVisibility(self, self.iconRecord)
	else
		self.SetNpcIconVisibility(self, false)
	end
end

NpcHUDCtrl.DumpIconAllowState = function(self)
	local pid = self.unit and self.unit.Pid or "nil"
	local reasons = {}

	for reason, _ in pairs(self.iconDisallowReasons) do
		table.insert(reasons, reason)
	end

	local reasonStr = #reasons <= 0 and table.concat(reasons, ",") or "none"

	print(string.format("[NpcHUDCtrl] pid=%s allowIcon=%s iconRecord=%s disallowReasons={%s}", tostring(pid), tostring(self.allowIcon), tostring(self.iconRecord), reasonStr))
end

NpcHUDCtrl.AddCommonHeadIcon = function(self, iconId)
	if self.template.TopIcon then
		self.template.TopIcon.npcIconId = iconId

		return true, "template_active"
	end

	if not self.unit then
		return false, "ctrl_unit_missing"
	end

	if self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] == nil then
		self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = iconId

		return true, "request_pending"
	end

	if self.template.npcIcon then
		self.SetNpcIconAllow(self, false, "topIcon")
	end

	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = iconId

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.TopIcon, self.unit.Pid)

	return true, "request_created"
end

NpcHUDCtrl.RemoveCommonHeadIcon = function(self)
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = nil

	if self.template.npcIcon then
		self.SetNpcIconAllow(self, true, "topIcon")
	end

	if not self.template.TopIcon then
		return
	end

	local instanceId = self.template.TopIcon.wgtId

	self.RemoveHudTemplate(self, instanceId)
end

NpcHUDCtrl.OnCreatCommonTopIcon = function(self)
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] then
		if self.template.TopIcon then
			local instanceId = self.template.TopIcon.wgtId

			self.RemoveHudTemplate(self, instanceId)
		end

		return
	end

	local iconId = self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = nil
	self.template.TopIcon.npcIconId = iconId
	self.isBtnShowNew = false

	self.Update(self)
end

NpcHUDCtrl.SetNpcCommonTopIconVisibility = function(self, show)
	if not self.template.TopIcon then
		return
	end

	self.template.TopIcon.template:SetTemplateVisibility(show)
end

NpcHUDCtrl.CheckSetPriorityTopAnim = function(self)
	local minType = -1
	local minPriority = 10000

	for type, exist in pairs(self.topAnimQueue) do
		if exist then
			local priority = gHudMgr.TopAnimTypePriority[type]

			if priority >= minPriority then
				minType = type
				minPriority = priority
			end
		end
	end

	if minType > 0 then
		self.template.topAnimIcon.tabRect.selectedIndex = minType
	else
		self.RemoveTopAnimHeadIcon(self)
	end
end

NpcHUDCtrl.AddTopAnimHeadIcon = function(self, iconType)
	if self.template.topAnimIcon then
		self.topAnimQueue[iconType] = true

		self.CheckSetPriorityTopAnim(self)

		return true, "template_active"
	end

	if not self.unit then
		return false, "ctrl_unit_missing"
	end

	if self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] == nil then
		self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = iconType

		return true, "request_pending"
	end

	if self.template.npcIcon then
		self.SetNpcIconAllow(self, false, "topAnimIcon")
	end

	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = iconType

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.TopAnimIcon, self.unit.Pid)

	return true, "request_created"
end

NpcHUDCtrl.RemoveTopAnimHeadIcon = function(self)
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = nil

	if self.template.npcIcon then
		self.SetNpcIconAllow(self, true, "topAnimIcon")
	end

	if not self.template.topAnimIcon then
		table.clear(self.topAnimQueue)

		return
	end

	self.template.topAnimIcon.tabRect.selectedIndex = -1
	local instanceId = self.template.topAnimIcon.wgtId

	self.RemoveHudTemplate(self, instanceId)
	table.clear(self.topAnimQueue)
end

NpcHUDCtrl.RemoveTopAnimHeadIconByType = function(self, iconType)
	if not self.template.topAnimIcon then
		if self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] ~= iconType then
			self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = nil

			if self.template.npcIcon then
				self.SetNpcIconAllow(self, true, "topAnimIcon")
			end
		end

		return
	end

	self.topAnimQueue[iconType] = false

	self.CheckSetPriorityTopAnim(self)
end

NpcHUDCtrl.OnCreatTopAnimIcon = function(self)
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] then
		if self.template.topAnimIcon then
			local instanceId = self.template.topAnimIcon.wgtId

			self.RemoveHudTemplate(self, instanceId)
		end

		return
	end

	local iconType = self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = nil
	self.topAnimQueue[iconType] = true

	self.CheckSetPriorityTopAnim(self)

	self.isBtnShowNew = false

	self.Update(self, true)
end

NpcHUDCtrl.SetTopAnimIconVisibility = function(self, show)
	if not self.template.topAnimIcon then
		return
	end

	self.topAnimIconVisibility = show

	self.template.topAnimIcon.template:SetTemplateVisibility(show)
end

NpcHUDCtrl.IsTopAnimIconShow = function(self)
	return self.topAnimIconVisibility
end

NpcHUDCtrl.OnCreateStealthDetectValue = function(self)
	local value = self.unitDataSet.detectionValue

	self.RefreshDetectionValue(self, value)
end

NpcHUDCtrl.RefreshDetectionValue = function(self, value)
	if not self.template.detect or not value then
		return
	end

	if self.detectTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.detectTimer)
	end

	local detectVisible = nil

	if value ~= 0 then
		detectVisible = false

		self:SetIgnoreOcclusionCulled(false, gHudMgr.HUDTemplateType.StealthDetectValue)
		self.template.detect.template:SetTemplateVisibility(false)
	elseif value >= 50 then
		detectVisible = true

		self:SetIgnoreOcclusionCulled(true, gHudMgr.HUDTemplateType.StealthDetectValue)
		self.template.detect.template:SetTemplateVisibility(true)
	elseif value >= 100 then
		detectVisible = true

		self:SetIgnoreOcclusionCulled(true, gHudMgr.HUDTemplateType.StealthDetectValue)
		self.template.detect.template:SetTemplateVisibility(true)
	else
		detectVisible = true

		self:SetIgnoreOcclusionCulled(true, gHudMgr.HUDTemplateType.StealthDetectValue)

		slot3 = self.template.detect.template

		slot3:SetTemplateVisibility(true)

		self.detectTimer = gLuaTimeMgrUtils.Delay(function ()
			self:SetIgnoreOcclusionCulled(false, gHudMgr.HUDTemplateType.StealthDetectValue)
			self.template.detect.template:SetTemplateVisibility(false)
			self:SetEnableOffscreen(false, gHudMgr.HUDTemplateType.StealthDetectValue)

			self.unitDataSet.detectionValue = 0
			self.detectTimer = nil
		end, 0.7)
	end

	self.SetEnableOffscreen(self, detectVisible, gHudMgr.HUDTemplateType.StealthDetectValue)

	local fillValue = value / 100

	if self.detectTweenFill then
		self.detectTweenFill:Kill()
	end

	slot4 = DOTween.To(function ()
		if self.template.detect then
			return self.template.detect.fillValue or 0
		end

		return 0
	end, function (v)
		if self.template.detect then
			self.template.detect.fillValue = v

			if v ~= 0 then
				self.template.detect.detectCtrl = 3
			elseif v >= 0.5 then
				self.template.detect.detectCtrl = 0
			elseif v >= 1 then
				self.template.detect.detectCtrl = 1
			else
				self.template.detect.detectCtrl = 2
			end
		end
	end, fillValue, 0.25)
	slot4 = slot4:SetEase(Ease.Linear)
	self.detectTweenFill = slot4:OnKill(function ()
		self.detectTweenFill = nil
	end)
end

NpcHUDCtrl.EnableAIChatHud = function(self, enable)
	if enable then
		if not self.template.npcAIChat then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NPCAIChatting, self.unit.Pid)
		end
	elseif self.template.npcAIChat then
		local instanceId = self.template.npcAIChat.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end
end

NpcHUDCtrl.SetAIChatVisibility = function(self, visible)
	if not self.template.npcAIChat then
		return
	end

	self.template.npcAIChat.template:SetTemplateVisibility(visible)
end

NpcHUDCtrl.OnCreatPlayerSurvivalStatus = function(self)
	self.template.survival.statusCtrl = 1
	self.template.survival.rescueFill.fillAmount = 0
	self.template.survival.dyingFill.fillAmount = 0

	self.SetEnableOffscreen(self, true, gHudMgr.HUDTemplateType.PlayerSurvivalStatus)
end

NpcHUDCtrl.RemovePlayerSurvivalStatus = function(self)
	if self.survivalTween then
		self.survivalTween:Kill()

		self.survivalTween = nil
	end

	if self.template.survival then
		local instanceId = self.template.survival.wgtId

		self.RemoveHudTemplate(self, instanceId)
		self.SetEnableOffscreen(self, false, gHudMgr.HUDTemplateType.PlayerSurvivalStatus)
	end
end

NpcHUDCtrl.RefreshPlayerSurvivalStatus = function(self, isRescue, value)
	if not self.template.survival then
		return
	end

	self.template.survival.statusCtrl = isRescue and 0 or 1

	if self.survivalTween then
		self.survivalTween:Kill()

		self.survivalTween = nil
	end

	local fill = isRescue and self.template.survival.rescueFill or self.template.survival.dyingFill

	if isRescue then
		if fill.fillAmount >= value then
			fill.fillAmount = value
		end

		local rescueInfo = LTConfig.LinkSucoorConfig.GetConfig(1000)

		if rescueInfo then
			local target = math.min(value + rescueInfo.SuccorRate / LTConfig.LinkConfig.SuccorMaxValue, 1)
			slot6 = DOTween.To(function ()
				return fill.fillAmount
			end, function (v)
				if fill then
					fill.fillAmount = v
				end
			end, target, 0.95)
			slot6 = slot6:SetEase(Ease.Linear)
			self.survivalTween = slot6:OnKill(function ()
				self.survivalTween = nil
			end)
		end
	else
		fill.fillAmount = value
	end
end

NpcHUDCtrl.SetHeadInfoVisibility = function(self, show)
	self.SetNpcNameVisibility(self, show)
	self.SetNpcIconVisibility(self, show)
	self.SetNpcCommonTopIconVisibility(self, show)
	self.SetTopAnimIconVisibility(self, show)
end

NpcHUDCtrl.SetNpcHeadInfoString = function(self)
	if self.template.npcName then
		self.template.npcName.npcNameText = self.npcName
	end
end

NpcHUDCtrl.ForceRefreshNameString = function(self)
	if not self.unit then
		return
	end

	local cfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId) or PetAnimalConfig.GetConfig(self.unit.ClientData.SubType)

	if cfg then
		self.npcName = cfg.Name

		self.SetNpcHeadInfoString(self)
	end
end

NpcHUDCtrl.OnRefreshHeadInfoVisibility = function(cell)
	local self = cell.param
	local show = true
	show = show and cell.value and not self.isBtnShowNew

	self:SetHeadInfoVisibility(show)
end

NpcHUDCtrl.OnForceRefreshNameString = function(cell)
	local self = cell.param

	self.ForceRefreshNameString(self)
end

NpcHUDCtrl.OnRefreshDetectionValue = function(cell)
	local self = cell.param
	local value = cell.value or 0

	if not self.template.detect then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.StealthDetectValue, self.unit.Pid)
	else
		self.RefreshDetectionValue(self, value)
	end
end

NpcHUDCtrl.ClearEventListener = function(self)
	if self.OnLanguageChangeHandler ~= nil then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.LANGUAGE_CHANGE, self.OnLanguageChangeHandler)
end

NpcHUDCtrl.CustomClearProcedure = function(self)
	if self.detectTweenFill then
		self.detectTweenFill:Kill()

		self.detectTweenFill = nil
	end

	self.isBtnShowNew = false

	table.clear(self.topAnimQueue)

	self.npcName = nil
	self.npcTitle = nil
	self.npcIcon = nil
	self.allowName = true
	self.allowTitle = true
	self.allowIcon = true
	self.nameRecord = true
	self.titleRecord = true
	self.iconRecord = true
	self.cfg = nil
	self.OnLanguageChangeHandler = nil
end

NpcHUDCtrl.SetHudShow = function(self, btnShow)
	local realShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)

	if realShow == btnShow then
		return
	end

	if btnShow == self.isBtnShowNew then
		self.isBtnShowNew = btnShow

		self.OnRefreshHeadInfoVisibility({
			param = self,
			value = not btnShow
		})
	end
end

NpcHUDCtrl.Update = function(self)
	local btnShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)
	self.isBtnShowNew = btnShow

	self.OnRefreshHeadInfoVisibility({
		param = self,
		value = not btnShow
	})
end

return NpcHUDCtrl
