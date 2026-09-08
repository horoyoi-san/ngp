-- Original chunk: @Lua\LuaFiles\LX6\GUI\Spirit\SpiritManager.lua
-- Decompiled from: 00255_SpiritManager.lua_f47fbae259e8.luajit

local GeneralModelConfig = LTConfig.GeneralModelConfig
local MessageConfig = LTConfig.MessageConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local LingSettingConfig = LTConfig.LingSettingConfig
local UrbanAttributeConfig = LTConfig.UrbanAttributeConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local TaskRoleConfig = LTConfig.TaskRoleConfig
local SpiritCaseConfig = LTConfig.SpiritCaseConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local M = {
	SkillTypeName = {}
}
local getTextConfig = LTConfig.TextScriptTextConfig.GetConfig

setmetatable(M.SkillTypeName, {
	__index = function (t, k)
		if k ~= 1 then
			return getTextConfig(89900673).Text
		elseif k ~= 2 then
			return getTextConfig(89900826).Text
		elseif k ~= 3 then
			return getTextConfig(89900827).Text
		elseif k ~= 4 then
			return getTextConfig(89900828).Text
		elseif k ~= 5 then
			return getTextConfig(89900829).Text
		elseif k ~= 6 then
			return getTextConfig(89900830).Text
		elseif k ~= 7 then
			return getTextConfig(89900831).Text
		elseif k ~= 8 then
			return getTextConfig(89900832).Text
		elseif k ~= 9 then
			return getTextConfig(89900833).Text
		else
			return "None"
		end
	end
})

M.OnInit = function(self)
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
	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		local switchType = switchSceneEventParams.switchSceneType

		self:OnBeforeSwitchScene(switchType)
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		self.sceneLoading = false
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.LANGUAGE_CHANGE, function (eventId, lang)
		self:OnLanguageChange(lang)
	end)

	self.fight2Cultivation = {}

	for i = 0, NpcCultivationConfig.count - 1 do
		local cfg = NpcCultivationConfig.LoadAt(i)
		self.fight2Cultivation[cfg.FightSpiritID] = cfg.Id
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.sceneLoading = true

	if switchType ~= gSwitchSceneType.KickToLogin then
		self.ClearSpiritViewData(self)

		gUrbanAbilityManager.SpiritPanelData = nil

		table.clear(self.spiritTempGroups)
		table.clear(self.taskRoleTeam)

		self.taskTipRoleId = 0
		self.enableSwitchChar = true
	end
end

M.OnLanguageChange = function(self, lang)
	for i, v in pairs(self.spiritViewDatas) do
		self.FillFrequentlyUsedFields(self, v)
	end
end

M.SyncPlayerInfoSpirit = function(self, infoSpirit)
	self.currentGroupIndex = 0
	self.needCheckGroupName = true

	self.ClearSpiritViewData(self)

	for i = 1, infoSpirit.Spirits.Count do
		local addSpiritId = infoSpirit.Spirits[i].TemplateId
		local cfg = FightSpiritConfig.GetConfig(infoSpirit.Spirits[i].TemplateId)
		local spiritInfo = infoSpirit.Spirits[i]
		spiritInfo.InfoBadge.Badges = self.FilterBadge(self, spiritInfo.InfoBadge.Badges)
		self.spiritViewDatas[addSpiritId] = {
			SpiritInfo = spiritInfo,
			config = cfg
		}

		self.FillFrequentlyUsedFields(self, self.spiritViewDatas[addSpiritId])
	end
end

M.SyncPlayerAllSpirits = function(self, allSpirits)
	self.currentGroupIndex = 0
	self.needCheckGroupName = true

	self.ClearSpiritViewData(self)

	for i = 1, allSpirits.Count do
		local addSpiritId = allSpirits[i].TemplateId
		local cfg = FightSpiritConfig.GetConfig(allSpirits[i].TemplateId)
		local spiritInfo = allSpirits[i]
		spiritInfo.InfoBadge.Badges = self.FilterBadge(self, spiritInfo.InfoBadge.Badges)
		self.spiritViewDatas[addSpiritId] = {
			SpiritInfo = spiritInfo,
			config = cfg
		}

		self.FillFrequentlyUsedFields(self, self.spiritViewDatas[addSpiritId])
	end
end

local GetTransitionSexType = function(sexType)
	if sexType ~= UX.Game.SexType.Male then
		return UX.Game.SexType.Female
	elseif sexType ~= UX.Game.SexType.Female then
		return UX.Game.SexType.Male
	else
		return sexType
	end
end

M.SyncSpiritSexTransition = function(self, oldSpiritId, newSpiritId, sexTransitionLastTime)
	local currentSexType = gPlayerManager.infoLogin.bindData.sexType
	local spirit = self.spiritViewDatas[oldSpiritId]

	if spirit and spirit.SpiritInfo then
		self.spiritViewDatas[oldSpiritId] = nil
		spirit.SpiritInfo.TemplateId = newSpiritId
		spirit.config = FightSpiritConfig.GetConfig(newSpiritId)

		self.FillFrequentlyUsedFields(self, spirit)

		self.spiritViewDatas[newSpiritId] = spirit
		self.spiritUrbanAttrs[newSpiritId] = self.spiritUrbanAttrs[oldSpiritId]
		self.spiritUrbanAttrs[oldSpiritId] = nil
		self.LastRequestSpiritFightAttrTime[newSpiritId] = self.LastRequestSpiritFightAttrTime[oldSpiritId]
		self.LastRequestSpiritFightAttrTime[oldSpiritId] = nil
		self.CachedModelDict[oldSpiritId] = nil
		self.CachedModelLoadOpDict[oldSpiritId] = nil
	elseif not self.spiritViewDatas[newSpiritId] then
		print_error("SpiritManager: SyncSpiritSexTransition找不到战灵 oldSpiritId=", oldSpiritId, "newSpiritId=", newSpiritId)
	end

	local newSexType = GetTransitionSexType(currentSexType)

	gCS.MyPlayerManager.ResetPlayerInfoSexType(newSexType)
	LX6.Audio.AudioManager.Instance:RefreshPlayerGenderState()
	gImageManager:GetMyHeadIconInfo()

	gPlayerManager.infoLogin.bindData.sexType = newSexType
	gPlayerManager.infoSpirit.bindData.SexTransitionLastTime = sexTransitionLastTime
	gHomeInteractionManager.sexTransitionLastTime = sexTransitionLastTime

	self:RefreshMainSpiritName()

	gBattleSpiritMgr.currentSpiritTemplateId = newSpiritId

	gMessageManager:SendMessage(gEventConstants.SYNC_CURRENT_SPIRIT, newSpiritId)
end

M.FilterBadge = function(self, badges)
	local filterBadge = {}

	for i, v in pairs(badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)

		if cfg and not cfg.OnlyServer then
			filterBadge[v.TemplateId] = v
		end
	end

	return filterBadge
end

M.SyncPlayerTempSpirit = function(self, tempSpirits)
	table.clear(self.spiritTempGroups)

	for i = 1, tempSpirits.Count do
		local tempSpirit = tempSpirits[i]
		local fid = LTConfig.SpiritCaseConfig.GetConfig(tempSpirit).FightSpiritId

		table.insert(self.spiritTempGroups, fid)
	end
end

M.SyncReturnOverflowMaterial = function(self, overflowMaterials)
	if not overflowMaterials or overflowMaterials.Count ~= 0 then
		return
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.OverflowMaterials)
end

M.SyncTaskRoleTeam = function(self, roleTeam, enableRoleIds, tipRoleId, enableSwitch)
	table.clear(self.taskRoleTeam)

	if roleTeam.Count <= 0 then
		self.enableSwitchChar = enableSwitch
	else
		self.enableSwitchChar = true
	end

	gCoreHudUIManager:AddDirtySkillType(gCoreHudUIManager.skillType.SwitchCharacterWheels)

	if tipRoleId <= 0 then
		gMessageManager:SendMessage(gEventConstants.TASK_ROLE_TIP_REFRESH, true)
		gPanelManager:CheckShow(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL)
	else
		gMessageManager:SendMessage(gEventConstants.TASK_ROLE_TIP_REFRESH, false)
		gPanelManager:Close(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL)
	end

	if enableRoleIds.Count < 0 then
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
		elseif cfg.FightSpiritId <= 0 and self.GetSpiritById(self, cfg.FightSpiritId) then
			role.FightSpiritId = cfg.FightSpiritId
			role.isCase = false
		elseif cfg.SpiritCaseId <= 0 then
			role.SpiritCaseId = cfg.SpiritCaseId
			local fid = SpiritCaseConfig.GetConfig(role.SpiritCaseId).FightSpiritId
			role.FightSpiritId = fid
			role.isCase = true
		else
			role.FightSpiritId = cfg.FightSpiritId
			role.isCase = false
		end

		role.isGuide = tipRoleId ~= role.Id

		table.insert(self.taskRoleTeam, role)

		self.tipRoleId = tipRoleId
	end
end

M.AddSpiritViewData = function(self, drawViewData)
	if drawViewData then
		local tid = drawViewData.SpiritInfo.TemplateId
		drawViewData.config = FightSpiritConfig.GetConfig(tid)

		self.FillFrequentlyUsedFields(self, drawViewData)

		self.spiritViewDatas[tid] = drawViewData
	else
		print_debug("AddSpiritViewData error. 出现空灵")
	end
end

M.RefreshSpiritViewData = function(self, spirit)
	local nowTime = Time.time

	if spirit then
		local tid = spirit.SpiritInfo.TemplateId
		spirit.config = FightSpiritConfig.GetConfig(tid)

		if not spirit.config then
			print_error("SpiritManager: Cannot find FightSpiritConfig ", tid)
		end

		self.FillFrequentlyUsedFields(self, spirit)

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

M.RefreshMainSpiritName = function(self)
	gMessageManager:SendMessage(gEventConstants.REFRESH_MAIN_SPIRIT_NAME)
	self:SetMainSpiritName(LTConfig.FightSpiritConfig.DefaultMale)
	self:SetMainSpiritName(LTConfig.FightSpiritConfig.DefaultFemale)
	self:SetPlayerName()
end

M.SetPlayerName = function(self)
	if gPlayerManager.infoLogin.bindData.UsePlayerName then
		gPlayerManager.infoLogin.bindData.name = gPlayerManager.infoLogin.bindData.playerName

		return
	end

	local name = nil

	if gPlayerManager.infoLogin.bindData.sexType ~= UX.Game.SexType.Male then
		name = LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultMale).Name
	else
		name = LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultFemale).Name
	end

	gPlayerManager.infoLogin.bindData.name = name
end

M.SetMainSpiritName = function(self, id)
	local tid = self.Id_to_Tid(self, id)

	if tid and self.spiritViewDatas[tid] then
		if gPlayerManager.infoLogin.bindData.UsePlayerName then
			self.spiritViewDatas[tid].Name = gPlayerManager.infoLogin.bindData.playerName
		else
			local cfg = FightSpiritConfig.GetConfig(id)

			if cfg then
				self.spiritViewDatas[tid].Name = cfg.Name
			end
		end
	end
end

M.CheckIsMainCharacter = function(self)
	return gBattleSpiritMgr.currentSpiritTemplateId ~= FightSpiritConfig.DefaultMale or gBattleSpiritMgr.currentSpiritTemplateId ~= FightSpiritConfig.DefaultFemale
end

M.GetSpirit = function(self, tid)
	if tid ~= nil then
		return nil
	end

	return self.spiritViewDatas[tid]
end

M.GetSpiritById = function(self, id)
	for i, v in pairs(self.spiritViewDatas) do
		if id ~= v.SpiritInfo.TemplateId then
			return v
		end
	end

	return nil
end

M.GetAllFightSpirits = function(self)
	local ret = {}

	for _, value in pairs(self.spiritViewDatas) do
		if not value.Invisible then
			table.insert(ret, value)
		end
	end

	return ret
end

M.CheckIsTempSpirit = function(self, fid)
	return table.contains(self.spiritTempGroups, fid)
end

M.CheckHasTaskRole = function(self)
	return #self.taskRoleTeam >= 0
end

M.CheckCanTaskRoleSwitch = function(self)
	return self.enableSwitchChar
end

M.GetTaskRoles = function(self)
	return self.taskRoleTeam
end

M.GetCurrentFightSpiritTids = function(self)
	local ret = {}

	table.insert(ret, gBattleSpiritMgr.currentSpiritTemplateId)

	return ret
end

M.GetCurrentFightSpirits = function(self)
	local ret = {}
	local id = self.Tid_to_Id(self, gBattleSpiritMgr.currentSpiritTemplateId)

	table.insert(ret, self.spiritViewDatas[id])

	return ret
end

M.Foreach = function(self, cb)
	for _, spirit in pairs(self.spiritViewDatas) do
		if not spirit.Invisible then
			cb(spirit)
		end
	end
end

M.ClearSpiritViewData = function(self)
	self.spiritViewDatas = {}

	table.clear(self.spiritTempGroups)
end

M.FillFrequentlyUsedFields = function(self, spirit)
	spirit.Id = spirit.SpiritInfo.TemplateId
	spirit.config = spirit.config or FightSpiritConfig.GetConfig(spirit.Id)

	if not spirit.config then
		print_warn("SpiritManager: config为空", spirit.Id)

		return
	end

	spirit.Tid = spirit.config.Id
	spirit.Name = spirit.config.Name

	self.RefreshMainSpiritName(self)

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

M.Tid_to_Id = function(self, tid)
	local spirit = self.GetSpirit(self, tid)

	if spirit ~= nil then
		return 0
	end

	return spirit.SpiritInfo.TemplateId
end

M.Id_to_Tid = function(self, id)
	local spirit = self.GetSpirit(self, id)

	if spirit ~= nil then
		return 0
	end

	return spirit.Tid
end

M.ShowLingMainPanel = function(self)
	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL)
end

M.SyncSpiritUrbanAttrs = function(self, tid, urbanAttrs)
	self.spiritUrbanAttrs[tid] = urbanAttrs

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.ON_SYNC_SPIRIT_URBAN_ATTRS, tid, urbanAttrs)
end

M.GetUrbanAttr = function(self, tid)
	local urbanSkill = self.spiritUrbanAttrs[tid]

	if urbanSkill and #urbanSkill ~= 6 then
		return urbanSkill
	end

	local spirit = self.spiritViewDatas[tid]

	if not spirit then
		print_error("SpiritManager: spirit为空", tid)

		return {}
	end

	urbanSkill = spirit.SpiritInfo.SpiritUrbanSkill

	if urbanSkill and #urbanSkill.UrbanAbilities ~= 6 then
		return urbanSkill.UrbanAbilities
	end

	local cfg = FightSpiritConfig.GetConfig(tid)

	return cfg.UrbanAttribute
end

M.GetUrbanRuleList = function(self, isSGUI)
	local ret = {}

	for i = 0, UrbanAttributeConfig.count - 1 do
		local cfg = UrbanAttributeConfig.LoadAt(i)
		local ele = {
			attrName = cfg.Name,
			attrDesc = cfg.Effect,
			attrMax = cfg.MaxValue,
			attrHyper = cfg.HyperLink,
			attrIcon = isSGUI ~= true and cfg.SIcon or cfg.Icon
		}

		table.insert(ret, ele)
	end

	return ret
end

M.GetCurFirstSpiritTid = function(self)
	return gBattleSpiritMgr.currentSpiritTemplateId
end

M.SyncSpiritAbilityInfo = function(self, spiritId, info)
	local tid = self.Id_to_Tid(self, spiritId)
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

M.CheckAbilityIsPopup = function(self, tid, spiritId, info)
	local lastInfo = self.spiritViewDatas[tid].SpiritInfo.SpiritAbilities[info.TemplateId]
	local upExp = info.Exp - lastInfo.Exp

	if upExp ~= 0 then
		return
	end

	local upLevel = info.Level - lastInfo.Level

	if upLevel < 0 then
		local expData = {
			spiritId = spiritId,
			info = info,
			lastInfo = lastInfo
		}

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.UrbanAbilityLUEXP, expData)

		return
	end

	for i = 1, upLevel do
		local lvUpData = {
			spiritId = spiritId,
			info = info,
			lastInfo = lastInfo,
			upLevel = lastInfo.Level + i
		}

		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityLUTips, lvUpData)
	end
end

M.SyncSpiritJobInfo = function(self, spiritId, availableJobs, currentJob)
	local tid = self.Id_to_Tid(self, spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local isShowPopUp, jobId, lastJobId, isHistoryJob = gSpiritJobManager:CheckJobPopUp(spiritId, availableJobs, currentJob)
	local isShowActivatePanel = gSpiritJobManager:CheckActivateJob(spiritId, currentJob)
	local spiritJobInfo = self.spiritViewDatas[tid].SpiritInfo.SpiritJobInfo
	spiritJobInfo.AvailableJobs = availableJobs
	spiritJobInfo.CurrentJob = currentJob

	if isShowPopUp and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Character) then
		local data = {
			jobId = jobId,
			lastJobId = lastJobId,
			isHistoryJob = isHistoryJob,
			selectedTid = spiritId
		}
		self.occupationTips_JobId = jobId
		self.occupationTips_PopUpId = gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityOccupationTips, data)
	end

	if isShowActivatePanel then
		-- Nothing
	end

	gMessageManager:SendMessage(gEventConstants.On_SYNC_SPIRIT_JOBINFO)
end

M.SyncSpiritBadgeInfo = function(self, spiritId, badgeId, badgeInfo)
	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(badgeId)

	if not cfg then
		print_error("SpiritManager: Cannot find UrbanBadgeConfig ", badgeId)

		return
	end

	if cfg.OnlyServer then
		return
	end

	local tid = self.Id_to_Tid(self, spiritId)
	local data = self.spiritViewDatas[tid]

	if not data then
		return
	end

	local curBadgeInfos = self.spiritViewDatas[tid].SpiritInfo.InfoBadge.Badges

	if not curBadgeInfos[badgeId] then
		self.PushPopWait(self, badgeInfo, spiritId)
	end

	if badgeInfo then
		curBadgeInfos[badgeId] = badgeInfo
	else
		curBadgeInfos[badgeId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_URBAN_BADGEINFO)
end

M.PushPopWait = function(self, data, spiritId)
	if not data or not data.TemplateId then
		print_error("SpiritManager: PushPopWait error, data is nil or TemplateId is nil")

		return
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.TemplateId)

	if cfg.NoUnlockUI then
		return
	end

	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Character) then
		return
	end

	if cfg.JobBadgeType and cfg.JobBadgeType ~= LTConfig.UrbanBadgeConfig.JobBadgeTypeType.Upgrade then
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

M.SyncSpiritHistoryJobInfo = function(self, spiritId, historyJobs)
	local tid = self.Id_to_Tid(self, spiritId)
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
		if v.Job ~= self.occupationTips_JobId then
			gNewPopupManager:RemovePopup(self.occupationTips_PopUpId)

			gSpiritManager.occupationTips_JobId = nil
			gSpiritManager.occupationTips_PopUpId = nil
		end
	end
end

M.CheckIsDefaultSpiritId = function(spiritId)
	return spiritId ~= LTConfig.FightSpiritConfig.DefaultMale or spiritId ~= LTConfig.FightSpiritConfig.DefaultFemale
end

M.AskClearAbilityRedPoint = function(self, spiritId, abilityId)
	slot3 = gClientToGameDelegate

	slot3:AskClearAbilityRedPoint(spiritId, abilityId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.spiritViewDatas[spiritId].SpiritInfo.SpiritAbilities[abilityId].NewLevel = false
	end
end

M.UrbanAbilityWeatherTest = function(self, isOpen)
	self.isWeatherTest = isOpen
end

M.DefaultFemale2DefaultMaleSpiritId = function(spiritId)
	if spiritId and spiritId ~= FightSpiritConfig.DefaultFemale then
		return FightSpiritConfig.DefaultMale
	end

	return spiritId
end

M.GetAllSpiritList = function(self)
	local spiritList = {}
	slot2 = gSpiritManager

	slot2:Foreach(function (spirit)
		table.insert(spiritList, self:GenSpiritData(spirit))
	end)

	return spiritList
end

M.GenSpiritData = function(self, spirit)
	if not spirit or not spirit.config then
		return nil
	end

	local agentId = spirit.config.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local modelId = agentConfig and agentConfig.GeneralModelId or 0
	local modelCfg = GeneralModelConfig.GetConfig(modelId)
	local data = {
		["/M\\x9d\\x8b\\x80U"] = false,
		["\\xe8\\xce0\\xe8"] = 0,
		["G\\xf4(\\xfb?.\\xcdf\\xddJ\\x82l\\xd3\\xeb"] = false,
		["R#k^"] = true,
		["\\xd0\\xc810\\xe8"] = false,
		["`Rϳ\\x83+\\xb0\\xc7\\xef"] = false,
		["@c\\xb8{E\\xbc\\xf7devq^"] = 0,
		["1\\xeb^\"\r\\xf3\\xb7O\\xa6x\\xa5\\xbb"] = 0,
		Id = spirit.Id,
		Name = spirit.Name,
		Lv = spirit.Lv,
		LiHui = spirit.Image,
		sIcon = spirit.config and spirit.config.SHeadIconID,
		Domain = spirit.Domain,
		Tid = spirit.Tid,
		QualityColor = spirit.QualityColor,
		FightHp = spirit.FightHp,
		FightAtk = spirit.FightAtk,
		FightPhyDef = spirit.FightPhyDef,
		Star = spirit.Star,
		ElementType = spirit.ElementType,
		Sex = agentConfig and agentConfig.SexType or UX.Game.SexType.Male,
		CameraBodyType = modelCfg and modelCfg.CameraBodyType
	}

	return data
end

gSpiritManager = M
