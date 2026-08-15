local MessageConfig = LTConfig.MessageConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local LingSettingConfig = LTConfig.LingSettingConfig
local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local TaskRoleConfig = LTConfig.TaskRoleConfig
local SpiritCaseConfig = LTConfig.SpiritCaseConfig
local M = {
	SkillTypeName = {}
}

setmetatable(M.SkillTypeName, {
	__index = function (t, k)
		if k == 1 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900673).Text
		elseif k == 2 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900826).Text
		elseif k == 3 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900827).Text
		elseif k == 4 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900828).Text
		elseif k == 5 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900829).Text
		elseif k == 6 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900830).Text
		elseif k == 7 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900831).Text
		elseif k == 8 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900832).Text
		elseif k == 9 then
			return LTConfig.TextScriptTextConfig.GetConfig(89900833).Text
		else
			return "None"
		end
	end
})

local SpiritViewData = {}

function M:OnInit()
	self.maxDomain = LingSettingConfig.MaxDomain
	self.maxLevel = 60
	self.spiritViewDatas = {}
	self.cardGroups = {}
	self.spiritTempGroups = {}
	self.currentGroupIndex = 0
	self.LastRequestSpiritFightAttrTime = {}
	self.CachedModelDict = {}
	self.CachedModelLoadOpDict = {}
	self.spiritUrbanAttrs = {}
	self.needCheckGroupName = false
	self.sceneLoading = true
	self.DebugMode = false
	self.taskRoleTeam = {}
	self.taskTipRoleId = 0
	self.enableSwitchChar = true

	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, function (eventId, switchType)
		self:OnBeforeSwitchScene(switchType)
	end)
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, function (eventId, switchType)
		self.sceneLoading = false
	end)
	gMessageManager:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, function (eventId, lang)
		self:OnLanguageChange(lang)
	end)

	self.fight2Cultivation = {}

	for i = 0, NpcCultivationConfig.count - 1 do
		local cfg = NpcCultivationConfig.LoadAt(i)
		self.fight2Cultivation[cfg.FightSpiritID] = cfg.Id
	end
end

function M:OnBeforeSwitchScene(switchType)
	self.sceneLoading = true

	if switchType == gSwitchSceneType.KickToLogin then
		self:ClearSpiritViewData()

		gUrbanAbilityManager.SpiritPanelData = nil

		table.clear(self.spiritTempGroups)
		table.clear(self.taskRoleTeam)

		self.taskTipRoleId = 0
		self.enableSwitchChar = true
	end
end

function M:OnLanguageChange(lang)
	for i, v in pairs(self.spiritViewDatas) do
		self:FillFrequentlyUsedFields(v)
	end
end

function M:SyncPlayerInfoSpirit(infoSpirit)
	self.currentGroupIndex = 0
	self.needCheckGroupName = true

	self:ClearSpiritViewData()

	for i = 1, infoSpirit.Spirits.Count do
		local addSpiritId = infoSpirit.Spirits[i].TemplateId
		local cfg = FightSpiritConfig.GetConfig(infoSpirit.Spirits[i].TemplateId)
		local spiritInfo = infoSpirit.Spirits[i]
		spiritInfo.InfoBadge.Badges = self:FilterBadge(spiritInfo.InfoBadge.Badges)
		self.spiritViewDatas[addSpiritId] = {
			SpiritInfo = spiritInfo,
			config = cfg
		}

		self:FillFrequentlyUsedFields(self.spiritViewDatas[addSpiritId])
	end
end

function M:SyncPlayerAllSpirits(allSpirits)
	self.currentGroupIndex = 0
	self.needCheckGroupName = true

	self:ClearSpiritViewData()

	for i = 1, allSpirits.Count do
		local addSpiritId = allSpirits[i].TemplateId
		local cfg = FightSpiritConfig.GetConfig(allSpirits[i].TemplateId)
		local spiritInfo = allSpirits[i]
		spiritInfo.InfoBadge.Badges = self:FilterBadge(spiritInfo.InfoBadge.Badges)
		self.spiritViewDatas[addSpiritId] = {
			SpiritInfo = spiritInfo,
			config = cfg
		}

		self:FillFrequentlyUsedFields(self.spiritViewDatas[addSpiritId])
	end
end

function M:FilterBadge(badges)
	local filterBadge = {}

	for i, v in pairs(badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)

		if cfg and not cfg.OnlyServer then
			filterBadge[v.TemplateId] = v
		end
	end

	return filterBadge
end

function M:SyncPlayerTempSpirit(tempSpirits)
	table.clear(self.spiritTempGroups)

	for i = 1, tempSpirits.Count do
		local tempSpirit = tempSpirits[i]
		local fid = LTConfig.SpiritCaseConfig.GetConfig(tempSpirit).FightSpiritId

		table.insert(self.spiritTempGroups, fid)
	end
end

function M:SyncReturnOverflowMaterial(overflowMaterials)
	if not overflowMaterials or overflowMaterials.Count == 0 then
		return
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.OverflowMaterials)
end

function M:SyncTaskRoleTeam(roleTeam, enableRoleIds, tipRoleId, enableSwitch)
	table.clear(self.taskRoleTeam)

	if roleTeam.Count > 0 then
		self.enableSwitchChar = enableSwitch
	else
		self.enableSwitchChar = true
	end

	gUIFunctionStateManager:RefreshCharacterSwitchState()

	if tipRoleId > 0 then
		gMessageManager:SendMessage(gEventConstants.TASK_ROLE_TIP_REFRESH, true)
		gPanelManager:CheckShow(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL)
	else
		gMessageManager:SendMessage(gEventConstants.TASK_ROLE_TIP_REFRESH, false)
		gPanelManager:Close(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL)
	end

	if enableRoleIds.Count <= 0 then
		return
	end

	for i = 1, enableRoleIds.Count do
		local role = {
			Id = enableRoleIds[i]
		}
		local cfg = TaskRoleConfig.GetConfig(role.Id)

		if cfg.IsDefault then
			local main = nil
			main = self:GetSpiritById(FightSpiritConfig.DefaultMale)
			main = main or self:GetSpiritById(FightSpiritConfig.DefaultFemale)
			role.FightSpiritId = main.config.Id
			role.isMain = true
		elseif cfg.FightSpiritId > 0 then
			role.FightSpiritId = cfg.FightSpiritId
			role.isCase = false
		else
			role.SpiritCaseId = cfg.SpiritCaseId
			local fid = SpiritCaseConfig.GetConfig(role.SpiritCaseId).FightSpiritId
			role.FightSpiritId = fid
			role.isCase = true
		end

		role.isGuide = tipRoleId == role.Id

		table.insert(self.taskRoleTeam, role)

		self.tipRoleId = tipRoleId
	end
end

function M:AddSpiritViewData(drawViewData)
	if drawViewData then
		local tid = drawViewData.SpiritInfo.TemplateId
		drawViewData.config = FightSpiritConfig.GetConfig(tid)

		self:FillFrequentlyUsedFields(drawViewData)

		self.spiritViewDatas[tid] = drawViewData
	else
		print_debug("AddSpiritViewData error. 出现空灵")
	end
end

function M:RefreshSpiritViewData(spirit)
	local nowTime = Time.time

	if spirit then
		local tid = spirit.SpiritInfo.TemplateId
		spirit.config = FightSpiritConfig.GetConfig(tid)

		if not spirit.config then
			print_error("SpiritManager: Cannot find FightSpiritConfig ", tid)
		end

		self:FillFrequentlyUsedFields(spirit)

		local currentSpirit = self.spiritViewDatas[tid]

		if currentSpirit then
			if not ulong.equals(currentSpirit.SpiritInfo.EquippedWeapon, spirit.SpiritInfo.EquippedWeapon) then
				local cs_unit = gBattleSpiritMgr:GetBattleSpiritUnitByTid(tid)

				if cs_unit then
					gCS.UnitModelManager.ResetChangeModel(cs_unit, true)
				end
			end

			gUtils:Merge(currentSpirit, spirit)
		else
			self.spiritViewDatas[tid] = spirit
			self.LastRequestSpiritFightAttrTime[tid] = nowTime
		end

		gMessageManager:SendMessage(gEventConstants.SPIRIT_INFO_CHANGED, tid)
	else
		print_debug("RefreshSpiritViewData Error. 出现空灵")
	end
end

function M:RefreshMainSpiritName()
	gMessageManager:SendMessage(gEventConstants.REFRESH_MAIN_SPIRIT_NAME)
	self:SetMainSpiritName(LTConfig.FightSpiritConfig.DefaultMale)
	self:SetMainSpiritName(LTConfig.FightSpiritConfig.DefaultFemale)
	self:SetPlayerName()
end

function M:SetPlayerName()
	if LX6.Engine.ProfileManager.gameProfile.isUsePlayerName then
		gPlayerManager.infoLogin.bindData.name = gPlayerManager.infoLogin.bindData.playerName

		return
	end

	local name = nil

	if gPlayerManager.infoLogin.bindData.sexType == UX.Game.SexType.Male then
		name = LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultMale).Name
	else
		name = LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultFemale).Name
	end

	gPlayerManager.infoLogin.bindData.name = name
end

function M:SetMainSpiritName(id)
	local tid = self:Id_to_Tid(id)

	if tid and self.spiritViewDatas[tid] then
		if LX6.Engine.ProfileManager.gameProfile.isUsePlayerName then
			self.spiritViewDatas[tid].Name = gPlayerManager.infoLogin.bindData.playerName
		else
			local cfg = FightSpiritConfig.GetConfig(id)

			if cfg then
				self.spiritViewDatas[tid].Name = cfg.Name
			end
		end
	end
end

function M:CheckIsMainCharacter()
	return gBattleSpiritMgr.currentSpiritTemplateId == FightSpiritConfig.DefaultMale or gBattleSpiritMgr.currentSpiritTemplateId == FightSpiritConfig.DefaultFemale
end

function M:GetSpirit(tid)
	if tid == nil then
		return nil
	end

	return self.spiritViewDatas[tid]
end

function M:GetSpiritById(id)
	for i, v in pairs(self.spiritViewDatas) do
		if id == v.SpiritInfo.TemplateId then
			return v
		end
	end

	return nil
end

function M:GetAllFightSpirits()
	local ret = {}

	for _, value in pairs(self.spiritViewDatas) do
		if not value.Invisible then
			table.insert(ret, value)
		end
	end

	return ret
end

function M:CheckIsTempSpirit(fid)
	return table.contains(self.spiritTempGroups, fid)
end

function M:CheckHasTaskRole()
	return #self.taskRoleTeam > 0
end

function M:CheckCanTaskRoleSwitch()
	return self.enableSwitchChar
end

function M:GetTaskRoles()
	return self.taskRoleTeam
end

function M:GetCurrentFightSpiritTids()
	local ret = {}

	table.insert(ret, gBattleSpiritMgr.currentSpiritTemplateId)

	return ret
end

function M:GetCurrentFightSpirits()
	local ret = {}
	local id = self:Tid_to_Id(gBattleSpiritMgr.currentSpiritTemplateId)

	table.insert(ret, self.spiritViewDatas[id])

	return ret
end

function M:GetLihui(spirit_tid)
	return spirit_tid
end

function M:Foreach(cb)
	for _, spirit in pairs(self.spiritViewDatas) do
		if not spirit.Invisible then
			cb(spirit)
		end
	end
end

function M:ClearSpiritViewData()
	self.spiritViewDatas = {}

	table.clear(self.spiritTempGroups)
end

function M:FillFrequentlyUsedFields(spirit)
	spirit.Id = spirit.SpiritInfo.TemplateId
	spirit.config = spirit.config or FightSpiritConfig.GetConfig(spirit.Id)

	if not spirit.config then
		print_error("SpiritManager: config为空", spirit.Id)

		return
	end

	spirit.Tid = spirit.config.Id
	spirit.Name = spirit.config.Name

	self:RefreshMainSpiritName()

	spirit.Lv = spirit.SpiritInfo.ProficiencyLevel
	spirit.Domain = spirit.SpiritInfo.Domain
	spirit.Quality = 1
	spirit.QualityColor = gUIUtils.LING_QUALITY_COLOR[1]
	spirit.Image = 0
	spirit.ElementType = spirit.config.ElementType
	spirit.Invisible = spirit.config.Invisible
	spirit.Qte = 0

	if spirit.SpiritAttrsBase then
		spirit.FightAtkBase = gLingUtils:GetAttriBaseValue(spirit, LTConfig.AttributeNameConfig.Dam)
		spirit.FightPhyDefBase = gLingUtils:GetAttriBaseValue(spirit, LTConfig.AttributeNameConfig.PhyDef)
		spirit.FightHpBase = gLingUtils:GetAttriBaseValue(spirit, LTConfig.AttributeNameConfig.MaxHp)
	end

	if spirit.SpiritAttrsExtra then
		spirit.FightAtkExtra = gLingUtils:GetAttriExtraValue(spirit, LTConfig.AttributeNameConfig.Dam)
		spirit.FightPhyDefExtra = gLingUtils:GetAttriExtraValue(spirit, LTConfig.AttributeNameConfig.PhyDef)
		spirit.FightHpExtra = gLingUtils:GetAttriExtraValue(spirit, LTConfig.AttributeNameConfig.MaxHp)
	end

	if spirit.SpiritAttrsBase and spirit.SpiritAttrsExtra then
		spirit.FightAtk = gLingUtils:GetAttriFinalValue(spirit, LTConfig.AttributeNameConfig.Dam)
		spirit.FightPhyDef = gLingUtils:GetAttriFinalValue(spirit, LTConfig.AttributeNameConfig.PhyDef)
		spirit.FightHp = gLingUtils:GetAttriFinalValue(spirit, LTConfig.AttributeNameConfig.MaxHp)
	end
end

function M:Tid_to_Id(tid)
	local spirit = self:GetSpirit(tid)

	if spirit == nil then
		return 0
	end

	return spirit.SpiritInfo.TemplateId
end

function M:Id_to_Tid(id)
	local spirit = self:GetSpirit(id)

	if spirit == nil then
		return 0
	end

	return spirit.Tid
end

function M:ShowLingMainPanel()
	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL)
end

function M:GetSpiritNum()
	local num = 0

	for _, v in pairs(self.spiritViewDatas) do
		if not v.Invisible and v.Id ~= FightSpiritConfig.DefaultMale and v.Id ~= FightSpiritConfig.DefaultFemale then
			num = num + 1
		end
	end

	return num
end

function M:SyncSpiritUrbanAttrs(tid, urbanAttrs)
	self.spiritUrbanAttrs[tid] = urbanAttrs
end

function M:GetUrbanAttr(tid)
	local urbanSkill = self.spiritUrbanAttrs[tid]

	if urbanSkill and #urbanSkill == 6 then
		return urbanSkill
	end

	local spirit = self.spiritViewDatas[tid]

	if not spirit then
		print_error("SpiritManager: spirit为空", tid)

		return {}
	end

	urbanSkill = spirit.SpiritInfo.SpiritUrbanSkill

	if urbanSkill and #urbanSkill.UrbanAbilities == 6 then
		return urbanSkill.UrbanAbilities
	end

	local cfg = FightSpiritConfig.GetConfig(tid)

	return cfg.UrbanAttribute
end

function M:GetUrbanRuleList(isSGUI)
	local ret = {}

	for i = 0, UrbanAttributeConfig.count - 1 do
		local cfg = UrbanAttributeConfig.LoadAt(i)
		local ele = {
			attrName = cfg.Name,
			attrDesc = cfg.Effect,
			attrMax = cfg.MaxValue,
			attrHyper = cfg.HyperLink,
			attrIcon = isSGUI == true and cfg.SIcon or cfg.Icon
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:GetCurFirstSpiritTid()
	return gBattleSpiritMgr.currentSpiritTemplateId
end

function M:SyncSpiritAbilityInfo(spiritId, info)
	local tid = self:Id_to_Tid(spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local spiritAbilitiesInfo = data.SpiritInfo.SpiritAbilities[info.TemplateId]

	if not spiritAbilitiesInfo then
		return
	end

	self:CheckAbilityIsPopup(tid, spiritId, info)

	self.spiritViewDatas[tid].SpiritInfo.SpiritAbilities[info.TemplateId] = info

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_SPIRIT_ABILITYINFO)
end

function M:CheckAbilityIsPopup(tid, spiritId, info)
	local lastInfo = self.spiritViewDatas[tid].SpiritInfo.SpiritAbilities[info.TemplateId]
	local upExp = info.Exp - lastInfo.Exp

	if upExp == 0 then
		return
	end

	local upLevel = info.Level - lastInfo.Level

	if upLevel <= 0 then
		local expData = {
			spiritId = spiritId,
			info = info,
			lastInfo = lastInfo
		}

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.UrbanAbilityLUEXP, expData)

		return
	end

	local lvUpData = {
		spiritId = spiritId,
		info = info,
		lastInfo = lastInfo
	}

	if upLevel == 1 then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityLUTips, lvUpData)

		return
	end

	for i = 1, upLevel do
		lvUpData.upLevel = i

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityLUTips, lvUpData)
	end
end

function M:SyncSpiritJobInfo(spiritId, availableJobs, currentJob)
	local tid = self:Id_to_Tid(spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local isShowPopUp, jobId, lastJobId, isHistoryJob = gSpiritJobManager:CheckJobPopUp(spiritId, availableJobs, currentJob)
	local isShowActivatePanel = gSpiritJobManager:CheckActivateJob(spiritId, currentJob)
	local spiritJobInfo = self.spiritViewDatas[tid].SpiritInfo.SpiritJobInfo
	spiritJobInfo.AvailableJobs = availableJobs
	spiritJobInfo.CurrentJob = currentJob

	if isShowPopUp then
		local data = {
			jobId = jobId,
			lastJobId = lastJobId,
			isHistoryJob = isHistoryJob
		}
		self.occupationTips_JobId = jobId
		self.occupationTips_PopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityOccupationTips, data)
	end

	if isShowActivatePanel then
		-- Nothing
	end

	gMessageManager:SendMessage(gEventConstants.On_SYNC_SPIRIT_JOBINFO)
end

function M:SyncSpiritBadgeInfo(spiritId, badgeId, badgeInfo)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(badgeId)

	if not cfg then
		print_error("SpiritManager: Cannot find UrbanBadgeConfig ", badgeId)

		return
	end

	if cfg.OnlyServer then
		return
	end

	local tid = self:Id_to_Tid(spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local curBadgeInfos = self.spiritViewDatas[tid].SpiritInfo.InfoBadge.Badges

	if not curBadgeInfos[badgeId] then
		self:PushPopWait(badgeInfo, spiritId)
	end

	if badgeInfo then
		curBadgeInfos[badgeId] = badgeInfo
	else
		curBadgeInfos[badgeId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_URBAN_BADGEINFO)
end

function M:PushPopWait(data, spiritId)
	if not data or not data.TemplateId then
		print_error("SpiritManager: PushPopWait error, data is nil or TemplateId is nil")

		return
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.TemplateId)

	if cfg.NoUnlockUI then
		return
	end

	if cfg.JobBadgeType and cfg.JobBadgeType == LTConfig.UrbanBadgeConfig.JobBadgeTypeType.Upgrade then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.UrbanAbilityJobBadgeTips, {
			TemplateId = data.TemplateId
		})

		return
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityBadgeTips, {
		list = {
			data
		},
		spiritId = spiritId
	})
end

function M:SyncSpiritHistoryJobInfo(spiritId, historyJobs)
	local tid = self:Id_to_Tid(spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local spiritJobInfo = self.spiritViewDatas[tid].SpiritInfo.SpiritJobInfo
	spiritJobInfo.HistoryJobs = historyJobs

	gMessageManager:SendMessage(gEventConstants.On_SYNC_SPIRIT_JOBINFO)

	if not self.occupationTips_JobId then
		return
	end

	for i, v in pairs(historyJobs) do
		if v.Job == self.occupationTips_JobId then
			gNewPopupManager:RemovePopup(self.occupationTips_PopUpId)

			gSpiritManager.occupationTips_JobId = nil
			gSpiritManager.occupationTips_PopUpId = nil
		end
	end
end

function M.CheckIsDefaultSpiritId(spiritId)
	return spiritId == LTConfig.FightSpiritConfig.DefaultMale or spiritId == LTConfig.FightSpiritConfig.DefaultFemale
end

function M:AskClearAbilityRedPoint(spiritId, abilityId)
	gClientToGameDelegate:AskClearAbilityRedPoint(spiritId, abilityId).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.spiritViewDatas[spiritId].SpiritInfo.SpiritAbilities[abilityId].NewLevel = false
	end
end

function M:UrbanAbilityWeatherTest(isOpen)
	self.isWeatherTest = isOpen
end

function M:SetOpenIsUsePlayerNameFunc(isOpen)
	self.OpenIsUsePlayerNameFunc = isOpen
end

gSpiritManager = M
