local AgentConfig = LTConfig.AgentConfig
local PetAnimalConfig = LTConfig.PetAnimalConfig
local HUDManager = LX6.GUI.HUDNew.HUDManager
local HUDCtrl = require("LX6/Manager/HUD/HudController")
C_NpcHUDCtrl = DefClass("C_NpcHUDCtrl", C_NpcHUDCtrl, HUDCtrl)
local NpcHUDCtrl = C_NpcHUDCtrl

function NpcHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Npc
	self.npcName = nil
	self.npcPid = nil
	self.npcTitle = nil
	self.npcIcon = nil
	self.allowName = true
	self.allowTitle = true
	self.allowIcon = true
	self.nameRecord = true
	self.titleRecord = true
	self.iconRecord = true
	self.OnLanguageChangeHandler = nil
	self.cfg = nil
end

function NpcHUDCtrl:RegisterBindHandlers()
	NpcHUDCtrl.base.RegisterBindHandlers(self)

	if not self.unitDataSet then
		print_error("NpcHUD对应unit数据不存在!")

		return
	end

	self.eventSet:BindHandler2({
		self.unitDataSet,
		"name",
		self.unitDataSet,
		"title"
	}, self.OnForceRefreshNameString, self)

	if self.cfg == nil then
		print_error("NPC Config不存在, agentId = ", self.unit.ClientData.AgentId)
	elseif self.cfg.Tag then
		for _, v in ipairs(self.cfg.Tag) do
			if v == LTConfig.AgentConfig.TagType.StealthNPC then
				if self.unitDataSet.detectionValue == nil then
					self.unitDataSet.detectionValue = 0
				end

				self.eventSet:BindHandler(self.unitDataSet, "detectionValue", self.OnRefreshDetectionValue, self)

				break
			end
		end
	end
end

function NpcHUDCtrl:RegisterEventListener()
	function self.OnLanguageChangeHandler()
		self.OnForceRefreshNameString({
			param = self
		})
	end

	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, self.OnLanguageChangeHandler)
end

function NpcHUDCtrl:RefreshData()
	if not self.unit then
		print_error("NpcHUD对应unit不存在!", self.uniId)
	end

	local cfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId) or PetAnimalConfig.GetConfig(self.unit.ClientData.SubType)
	self.cfg = cfg
end

function NpcHUDCtrl:CustomProcedure()
	local pid = self.unit.Pid
	local npcCfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId)

	if npcCfg ~= nil then
		if npcCfg.NameDisplay and npcCfg.NameDisplay > 0 then
			local dataSet = self.unitDataSet
			self.npcName = dataSet.name
			self.npcTitle = dataSet.title

			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcName, self.unit.Pid)
		end

		if npcCfg.HudIconId and npcCfg.HudIconId > 0 then
			self.npcIcon = npcCfg.HudIconId

			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcIcon, self.unit.Pid)
		end
	end

	gMessageManager:SendMessage(gEventConstants.NPC_HUD_ROOT_READY, pid)
end

function NpcHUDCtrl:CustomClearProcedure()
	self.isBtnShowNew = false
end

function NpcHUDCtrl:OnCreateNpcName()
	self.template.npcName.npcNameText = self.npcName
end

function NpcHUDCtrl:SetNpcNameVisibility(show)
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

function NpcHUDCtrl:SetNpcNameAllow(allow)
	self.allowName = allow

	if allow then
		self:SetNpcNameVisibility(self.nameRecord)
	else
		self:SetNpcNameVisibility(false)
	end
end

function NpcHUDCtrl:OnCreateNpcTitle()
	self.template.npcTitle.npcTitleText = self.npcTitle
end

function NpcHUDCtrl:SetNpcTitleVisibility(show)
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

function NpcHUDCtrl:SetNpcTitleAllow(allow)
	self.allowTitle = allow

	if allow then
		self:SetNpcTitleVisibility(self.titleRecord)
	else
		self:SetNpcTitleVisibility(false)
	end
end

function NpcHUDCtrl:AddNpcIcon(iconId)
	if self.template.npcIcon then
		self.template.npcIcon.npcIconId = iconId

		return
	end

	self.npcIcon = iconId

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NpcIcon, self.unit.Pid)
end

function NpcHUDCtrl:RemoveNpcIcon()
	if self.template.npcIcon then
		local npcCfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId)

		if npcCfg ~= nil and npcCfg.HudIconId and npcCfg.HudIconId > 0 then
			self.npcIcon = npcCfg.HudIconId
			self.template.npcIcon.npcIconId = self.npcIcon

			return
		end

		local instanceId = self.template.npcIcon.wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function NpcHUDCtrl:OnCreateNpcIcon()
	self.template.npcIcon.npcIconId = self.npcIcon
end

function NpcHUDCtrl:SetNpcIconVisibility(show)
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

function NpcHUDCtrl:SetNpcIconAllow(allow)
	self.allowIcon = allow

	if allow then
		self:SetNpcIconVisibility(self.iconRecord)
	else
		self:SetNpcIconVisibility(false)
	end
end

function NpcHUDCtrl:AddCommonHeadIcon(iconId)
	if self.template.TopIcon then
		self.template.TopIcon.npcIconId = iconId

		return
	end

	if not self.unit then
		return
	end

	if self.template.npcIcon then
		self:SetNpcIconAllow(false)
	end

	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = iconId

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.TopIcon, self.unit.Pid)
end

function NpcHUDCtrl:RemoveCommonHeadIcon()
	if not self.template.TopIcon then
		return
	end

	if self.template.npcIcon then
		self:SetNpcIconAllow(true)
	end

	local instanceId = self.template.TopIcon.wgtId

	self:RemoveHudTemplate(instanceId)
end

function NpcHUDCtrl:OnCreatCommonTopIcon()
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] then
		return
	end

	local iconId = self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopIcon] = nil
	self.template.TopIcon.npcIconId = iconId
	self.isBtnShowNew = false

	self:Update()
end

function NpcHUDCtrl:SetNpcCommonTopIconVisibility(show)
	if not self.template.TopIcon then
		return
	end

	self.template.TopIcon.template:SetTemplateVisibility(show)
end

function NpcHUDCtrl:AddTopAnimHeadIcon(iconType)
	if self.template.topAnimIcon then
		self.template.topAnimIcon.tabRect.selectedIndex = iconType

		return
	end

	if not self.unit then
		return
	end

	if self.template.npcIcon then
		self:SetNpcIconAllow(false)
	end

	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = iconType

	HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.TopAnimIcon, self.unit.Pid)
end

function NpcHUDCtrl:RemoveTopAnimHeadIcon()
	if not self.template.topAnimIcon then
		return
	end

	if self.template.npcIcon then
		self:SetNpcIconAllow(true)
	end

	self.template.topAnimIcon.tabRect.selectedIndex = -1
	local instanceId = self.template.topAnimIcon.wgtId

	self:RemoveHudTemplate(instanceId)
end

function NpcHUDCtrl:OnCreatTopAnimIcon()
	if not self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] then
		return
	end

	local iconType = self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon]
	self.asyncParamsSave[gHudMgr.HUDTemplateType.TopAnimIcon] = nil
	self.template.topAnimIcon.tabRect.selectedIndex = iconType
	self.isBtnShowNew = false

	self:Update(true)
end

function NpcHUDCtrl:SetTopAnimIconVisibility(show)
	if not self.template.topAnimIcon then
		return
	end

	self.template.topAnimIcon.template:SetTemplateVisibility(show)
end

function NpcHUDCtrl:OnCreateStealthDetectValue()
	local value = self.unitDataSet.detectionValue

	self:RefreshDetectionValue(value)
end

function NpcHUDCtrl:RefreshDetectionValue(value)
	if not self.template.detect or not value then
		return
	end

	if self.detectTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.detectTimer)
	end

	if value <= 0 then
		self.detectTimer = nil

		self.template.detect.template:SetTemplateVisibility(false)
	elseif value < 50 then
		self.template.detect.template:SetTemplateVisibility(true)

		self.template.detect.detectCtrl = 0
	elseif value < 100 then
		self.template.detect.template:SetTemplateVisibility(true)

		self.template.detect.detectCtrl = 1
	else
		self.template.detect.template:SetTemplateVisibility(true)

		self.template.detect.detectCtrl = 2
		self.detectTimer = gLuaTimeMgrUtils.Delay(function ()
			self.detectTimer = nil

			if self.unitDataSet then
				self.unitDataSet.detectionValue = 0
			end
		end, 0.3)
	end
end

function NpcHUDCtrl:EnableAIChatHud(enable)
	if enable then
		if not self.template.npcAIChat then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.NPCAIChatting, self.unit.Pid)
		end
	elseif self.template.npcAIChat then
		local instanceId = self.template.npcAIChat.wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function NpcHUDCtrl:SetAIChatVisibility(visible)
	if not self.template.npcAIChat then
		return
	end

	self.template.npcAIChat.template:SetTemplateVisibility(visible)
end

function NpcHUDCtrl:SetHeadInfoVisibility(show)
	self:SetNpcNameVisibility(show)
	self:SetNpcIconVisibility(show)
	self:SetNpcCommonTopIconVisibility(show)
	self:SetTopAnimIconVisibility(show)
end

function NpcHUDCtrl:SetNpcHeadInfoString()
	if self.template.npcName then
		self.template.npcName.npcNameText = self.npcName
	end
end

function NpcHUDCtrl:ForceRefreshNameString()
	if not self.unit then
		return
	end

	local cfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId) or PetAnimalConfig.GetConfig(self.unit.ClientData.SubType)

	if cfg then
		self.npcName = cfg.Name

		self:SetNpcHeadInfoString()
	end
end

function NpcHUDCtrl.OnRefreshHeadInfoVisibility(cell)
	local self = cell.param
	local show = true
	show = show and cell.value and not self.isBtnShowNew

	self:SetHeadInfoVisibility(show)
end

function NpcHUDCtrl.OnForceRefreshNameString(cell)
	local self = cell.param

	self:ForceRefreshNameString()
end

function NpcHUDCtrl.OnRefreshDetectionValue(cell)
	local self = cell.param
	local value = cell.value

	if not self.template.detect then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.StealthDetectValue, self.unit.Pid)
	else
		self:RefreshDetectionValue(value)
	end
end

function NpcHUDCtrl:ClearEventListener()
	if self.OnLanguageChangeHandler == nil then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.LANGUAGE_CHANGE, self.OnLanguageChangeHandler)
end

function NpcHUDCtrl:CustomClearProcedure()
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

function NpcHUDCtrl:SetHudShow(btnShow)
	local realShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)

	if realShow ~= btnShow then
		return
	end

	if btnShow ~= self.isBtnShowNew then
		self.isBtnShowNew = btnShow

		self.OnRefreshHeadInfoVisibility({
			param = self,
			value = not btnShow
		})
	end
end

function NpcHUDCtrl:Update()
	local btnShow = gInteractionManager:CheckUnitPcBtnShow(self.unit.Pid)
	self.isBtnShowNew = btnShow

	self.OnRefreshHeadInfoVisibility({
		param = self,
		value = not btnShow
	})
end

return NpcHUDCtrl
