if not gPoliceJobManager or not gPoliceJobManager.examineMgr then
	local PoliceExamineManager = {
		actionMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceGameplayActions"),
		policeQuestionInfos = {},
		_signalFailWatchdogList = {},
		_signalPidList = {},
		baseQuestionList = {
			1,
			2,
			3
		}
	}
end

local this = PoliceExamineManager
PoliceExamineManager.ExamineType = this.actionMgr.ExamineType
PoliceExamineManager.VMSignalType = this.actionMgr.VMSignalType
local PoliceCfg = LTConfig.PoliceConfig
local PoliceFineConfig = LTConfig.PoliceFineConfig
local InteractCfg = LTConfig.PoliceExamInteractConfig
local ExitType = LTConfig.PoliceExamReactionConfig.ExitType
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

function PoliceExamineManager:Init()
	if self.init then
		return
	end

	self.subOptions = {}
	self.searchOptions = {}
	local count = PoliceCfg.count

	for i = 0, count - 1 do
		local cfg = PoliceCfg.LoadAt(i)
		local menu = cfg.Menu

		if menu ~= 0 then
			local attachList = self.subOptions[menu] or {}

			table.insert(attachList, cfg.Id)

			self.subOptions[menu] = attachList
		end
	end

	self.drugTypeToFines = {}
	self.itemTypeToFines = {}
	count = PoliceFineConfig.count

	for i = 0, count - 1 do
		local cfg = PoliceFineConfig.LoadAt(i)

		if cfg.DrugType and cfg.DrugType ~= 0 then
			self.drugTypeToFines[cfg.DrugType] = cfg.Id
		end

		if cfg.ItemType and cfg.ItemType ~= 0 then
			self.itemTypeToFines[cfg.ItemType] = cfg.Id
		end
	end

	self.crimeType2Fine = {}
	count = PoliceFineConfig.count

	for i = 0, count - 1 do
		local cfg = PoliceFineConfig.LoadAt(i)

		if cfg and cfg.CrimeType > 0 then
			self.crimeType2Fine[cfg.CrimeType] = cfg.Id
		end
	end

	self.init = true
end

function PoliceExamineManager:InitExamineData(unit)
	local pid = unit.Pid
	self.unit = unit

	if self.unitPid == pid then
		self:SetNotFree()

		return
	end

	self.unitPid = pid
	self.module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
	self.component = self.module.Component
	self.attachData = self.module.ClientExtraData

	if self.attachData == nil then
		self.attachData = {}
		self.module.ClientExtraData = self.attachData
	end

	self:SetNotFree()

	local questionInfos = self.policeQuestionInfos[pid]

	if self.attachData.mgrInit then
		self:SyncPoliceQuestionInfo(questionInfos)

		return
	end

	if not self.attachData.isServerSynced then
		self.attachData.fineInfoDict = {}
		self.attachData.fineTimes = 0
	end

	self.attachData.fineList = {}
	self.attachData.triggeredOptions = {}
	self.attachData.triggeredQuestions = {}
	self.attachData.extraQuestionList = {}
	self.attachData.basicBodyInfo = {
		answerJob = false,
		answerName = false
	}
	self.attachData.successPoliceEffect = false
	self.attachData.foldTopRightMenu = false
	self.attachData.customOptions = nil
	self.attachData.customFines = nil
	self.attachData.isInMission = false
	self.attachData.hideExamineSuggestion = false
	self.attachData.hintOpts = {
		Init = false
	}

	self:SyncPoliceQuestionInfo(questionInfos)

	self.attachData.mgrInit = true
end

function PoliceExamineManager:OnSyncExamineData(pid, data)
	local unit = SceneDataMgr.GetUnit(pid)

	if unit then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
		local attachData = module.ClientExtraData

		if attachData == nil then
			attachData = {}
			module.ClientExtraData = attachData
		end

		attachData.fineTimes = data.FineTimes
		attachData.fineInfoDict = {}

		for k, v in pairs(data.Fines) do
			if attachData.fineInfoDict[k] then
				attachData.fineInfoDict[k].isFined = true
			else
				attachData.fineInfoDict[k] = {
					isFined = true
				}
			end
		end

		attachData.isServerSynced = true
	end
end

function PoliceExamineManager:GetFineIdByDrugType(drugType)
	return self.drugTypeToFines[drugType]
end

function PoliceExamineManager:GetFineIdByItemType(drugType)
	return self.itemTypeToFines[drugType]
end

function PoliceExamineManager:GetOptionResSuggestion(optionId)
	if self.attachData.hideExamineSuggestion then
		return nil
	end

	local optionCfg = PoliceCfg.GetConfig(optionId)
	local res = nil

	if optionCfg and optionCfg.FineId and #optionCfg.FineId > 0 then
		local fines = optionCfg.FineId

		for i = 1, #fines do
			local fineId = fines[i]

			if fineId and self.attachData.fineInfoDict[fineId] then
				local fineCfg = PoliceFineConfig.GetConfig(fineId)

				if fineCfg and fineCfg.Title then
					if res then
						res = string.format("%s %s", res, fineCfg.Title)
					else
						res = string.format("%s", fineCfg.Title)
					end
				end
			end
		end
	end

	return res
end

function PoliceExamineManager:CommonReactionDeal(reactionCfg, signal, delayTime, skipGetUpWait)
	if not reactionCfg then
		print_error("PoliceExamineManager CommonReactionDeal failed, config is nil, signal is ", signal)

		return
	end

	if reactionCfg.Dialog and reactionCfg.Dialog > 0 then
		local emotionType = self.module.Emotion
		local personality = self.module.Personality

		L18.Gameplay.PoliceJobUtils.ShowAIDialog(reactionCfg.Dialog, emotionType, personality, 0, self.attachData.useCustomDialogs)
	end

	if reactionCfg.IsEndMultiInteract then
		gPoliceJobManager.cs:TryStopMultiInteract()
	end

	self:ClearCachedGameplayEvent()

	local getup = self:GetGetUpEvent()

	if getup and not skipGetUpWait then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager NPC需要先播起身 开始延迟动作， Signal " .. tostring(signal) .. " 主角动作 " .. tostring(reactionCfg.GameplayEvent))
		end

		self.cachedGameplayEvent = reactionCfg.GameplayEvent
		self.cachedGameplaySignal = reactionCfg.NPCGameplaySignal

		if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
			self.cachedSignal = reactionCfg.Exit == ExitType.None and signal
			self.cachedDelayTime = delayTime
		end

		self:SendGameplayInwardSignal(self.unit, getup)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager signal " .. tostring(getup) .. " : 开始NPC起身动作" .. tostring(getup))
		end
	else
		if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
			self:SendGameplayEvent(reactionCfg.GameplayEvent)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager signal " .. tostring(signal) .. " : 开始主角动作" .. tostring(reactionCfg.GameplayEvent))
			end

			if signal and reactionCfg.Exit == ExitType.None then
				self:StartSignalFailWatchdog(signal, delayTime or 7)
			end
		end

		if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.unit then
			self:SendGameplayInwardSignal(self.unit, reactionCfg.NPCGameplaySignal)
			gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, self.unit.Pid)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager signal " .. tostring(signal) .. " : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
			end
		end
	end

	if reactionCfg.Exit ~= ExitType.None then
		self:NpcBadReaction(reactionCfg, self.unit)
	end
end

function PoliceExamineManager:CheckCanClickOption(optionId)
	if gPoliceJobManager.currentStage ~= gPoliceJobManager.POLICE_STAGE.EXAMINE then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : CheckCanClickOption failed! Stage is not in Examine, cur stage is" .. tostring(gPoliceJobManager.currentStag))
		end

		return false
	end

	if gPoliceJobManager.waitForReactionCallback ~= nil then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : CheckCanClickOption failed! WaitForReactionCallback is allReady exist.")
		end

		return false
	end

	if self.cachedGameplayEvent or self.cachedSignal or self.cachedMultiInteractType then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : CheckCanClickOption failed! cachedGameplayEvent " .. tostring(self.cachedGameplayEvent) .. " cachedSignal " .. tostring(self.cachedSignal) .. " cachedMultiInteractType " .. tostring(self.cachedMultiInteractType))
		end

		return false
	end

	local signal = self:GetCurSignalFailWatchDog()

	if signal then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : CheckCanClickOption failed! Wait VM timer is allReady exist. Signal is " .. tostring(signal))
		end

		return false
	end

	return true
end

function PoliceExamineManager:ClickOption(optionId)
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self:ClickOption_Story(optionId)
	else
		if not self:CheckCanClickOption() then
			return
		end

		local optionCfg = PoliceCfg.GetConfig(optionId)

		if optionCfg.DialogId == 0 then
			self:DoClickOption(optionId)
		else
			self.currentDialog = optionCfg.DialogId

			gDialogManager:ShowGeneralDialog(optionCfg.DialogId, gDialogSource.Police)
			self:DoClickOption(optionId)
		end
	end
end

function PoliceExamineManager:DoClickOption(optionId)
	if not gPoliceJobManager.IsUnitValid(self.unit) then
		print_error("PoliceExamineManager cached unit is nil")

		return
	end

	local pid = self.unit.Pid
	local optionCfg = PoliceCfg.GetConfig(optionId)

	self:OnClickOption(optionCfg)

	if optionCfg.Interact > 0 then
		gPoliceJobManager:CheckWaitOutwardSignal()

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : 请求服务器交互 Interact " .. tostring(optionCfg.Interact) .. " pid " .. ulong.tostring(pid))
		end

		self:AskPoliceExamInteract(pid, optionCfg.Interact).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gPoliceJobManager:ClearWaitForReactionCallback()
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if self.panel and self.panel.isShow then
					self.panel:RefreshList()
				end

				return
			end
		end
	end

	if not string.is_null_or_empty(optionCfg.Message) then
		local action = self.OptionAction[optionCfg.Message]

		if action then
			action(self, optionCfg)
		else
			print_error_without_stack("PoliceExamineManager:ClickOption ", optionCfg.Message, " action not found")
		end
	end
end

function PoliceExamineManager:CanOptionShowInMain(optionId)
	local optionCfg = PoliceCfg.GetConfig(optionId)

	if optionId == PoliceCfg.Ask then
		if not self.attachData.askDialogId or self.attachData.askDialogId <= 0 then
			return false
		end
	else
		if optionCfg.ShowType ~= PoliceCfg.ShowTypeType.Main and optionCfg.ShowType ~= PoliceCfg.ShowTypeType.All then
			return false
		end

		if self.attachData.customOptions and not table.contains(self.attachData.customOptions, optionId) then
			return false
		end
	end

	local jobCondition = optionCfg.JobId

	if not table.isNilOrEmpty(jobCondition) then
		local jobId = gSpiritJobManager:GetCurJobId()

		if not table.contains(jobCondition, jobId) then
			return false
		end
	end

	return true
end

function PoliceExamineManager:GetCurrentTopRightOptions()
	local options = {}

	if self.attachData.foldTopRightMenu then
		return options
	end

	if self.attachData.basicBodyInfo then
		local nameCfg = PoliceCfg.GetConfig(PoliceCfg.Name)
		local jobCfg = PoliceCfg.GetConfig(PoliceCfg.Job)

		if nameCfg and jobCfg then
			local info = self.attachData.basicBodyInfo
			local name, job = self:GetNpcNameAndJob()
			local nameLabel = nil

			if info.answerName then
				nameLabel = string.format(PoliceCfg.TopLeftFormat, nameCfg.Option, name)
			else
				nameLabel = string.format(PoliceCfg.TopLeftFormat, nameCfg.Option, PoliceCfg.HideNameJobText)
			end

			local nameOption = {
				showAsk = true,
				optionId = nameCfg.Id,
				fineId = PoliceCfg.NameAIDialogFineId,
				label = nameLabel,
				iconId = nameCfg.Icon
			}

			table.insert(options, nameOption)

			local jobLabel = nil

			if info.answerJob then
				jobLabel = string.format(PoliceCfg.TopLeftFormat, jobCfg.Option, job)
			else
				jobLabel = string.format(PoliceCfg.TopLeftFormat, jobCfg.Option, PoliceCfg.HideNameJobText)
			end

			local jobOption = {
				showAsk = false,
				optionId = jobCfg.Id,
				fineId = PoliceCfg.JobAIDialogFineId,
				label = jobLabel,
				iconId = jobCfg.Icon
			}

			table.insert(options, jobOption)
		end
	end

	if self.attachData.triggeredOptions then
		for id, state in pairs(self.attachData.triggeredOptions) do
			if state then
				local cfg = PoliceCfg.GetConfig(id)

				if cfg and (cfg.ShowType == PoliceCfg.ShowTypeType.All or cfg.ShowType == PoliceCfg.ShowTypeType.TopRight) then
					local crimed = false

					for i = 1, #self.attachData.fineList do
						local fineId = self.attachData.fineList[i]
						local fineCfg = PoliceFineConfig.GetConfig(fineId)

						if fineCfg and table.contains(cfg.FineId, fineId) then
							local option = {
								showAsk = true,
								optionId = id,
								fineId = fineId,
								label = string.format(PoliceCfg.TopLeftFormat, cfg.Option, fineCfg.Title),
								iconId = cfg.Icon
							}

							table.insert(options, option)

							crimed = true
						end
					end

					if not crimed then
						local option = {
							showAsk = false,
							fineId = 0,
							optionId = id,
							label = string.format(PoliceCfg.TopLeftFormat, cfg.Option, PoliceCfg.NoCrimeText),
							iconId = cfg.Icon
						}

						table.insert(options, option)
					end
				end
			end
		end
	end

	return options
end

function PoliceExamineManager:GetCurrentSuggestion()
	if self.attachData.hideExamineSuggestion then
		return nil
	end

	local searchNum = 0
	local hasIDCheck = not self.attachData.customOptions or table.contains(self.attachData.customOptions, PoliceCfg.IdCheck)

	if not self.attachData.triggeredOptions[PoliceCfg.IdCheck] and hasIDCheck then
		return PoliceCfg.SuggestionCheck
	end

	for k, v in pairs(self.attachData.triggeredOptions) do
		if v and table.contains(self.searchOptions, k) then
			searchNum = searchNum + 1
		end
	end

	local allSearchNum = #self.searchOptions
	local allSearch = searchNum > 0 and searchNum == allSearchNum

	if searchNum > 0 then
		if searchNum >= 0.5 * allSearchNum then
			if #self.attachData.fineList > 0 then
				local serious = false
				local crimeType = false

				for i = 1, #self.attachData.fineList do
					local cfg = PoliceFineConfig.GetConfig(self.attachData.fineList[i])

					if cfg then
						if cfg.CrimeType > 0 then
							crimeType = true
						end

						if cfg.Factor >= 3 then
							serious = true
						end
					end
				end

				if crimeType and (not self.attachData.customOptions or table.contains(self.attachData.customOptions, PoliceCfg.Arrest)) then
					return PoliceCfg.SuggestionArrest
				elseif serious and (not self.attachData.customOptions or table.contains(self.attachData.customOptions, PoliceCfg.Arrest) or table.contains(self.attachData.customOptions, PoliceCfg.Fine)) then
					return PoliceCfg.SuggestionArrestOrFine
				elseif not self.attachData.customOptions or table.contains(self.attachData.customOptions, PoliceCfg.Fine) then
					return PoliceCfg.SuggestionFine
				end

				return nil
			elseif allSearch then
				return PoliceCfg.SuggestionRelease
			else
				return PoliceCfg.SuggestionSearchDeep
			end
		else
			return PoliceCfg.SuggestionSearch
		end
	elseif hasIDCheck then
		return PoliceCfg.SuggestionCheck
	end

	return nil
end

function PoliceExamineManager:SwitchTopRightMenuFold()
	self.attachData.foldTopRightMenu = not self.attachData.foldTopRightMenu

	self.panel:RefreshList(false, true, true)
end

function PoliceExamineManager:IsTopRightMenuFold()
	return self.attachData.foldTopRightMenu
end

function PoliceExamineManager:GetCurrentOptions()
	local count = PoliceCfg.count
	local options = {}
	self.searchOptions = {}

	for i = 0, count - 1 do
		local cfg = PoliceCfg.LoadAt(i)

		if self:CanOptionShowInMain(cfg.Id) then
			self:_AddOptionToList(options, cfg)

			if cfg.OptionType == PoliceCfg.OptionTypeType.Search then
				table.insert(self.searchOptions, cfg.Id)
			end
		end
	end

	for i = #options, 1, -1 do
		local subOptions = options[i].subOptions

		if subOptions and #subOptions == 0 then
			table.remove(options, i)
		end
	end

	return options
end

function PoliceExamineManager:_AddOptionToList(options, cfg)
	local enable = true
	local condition = cfg.Condition

	if not string.is_null_or_empty(condition) then
		local status, result = self:RunCode("return self:" .. condition)

		if not status then
			print_error("PoliceExamineManager M.RunTaskFunc ", condition, "Failed: ", result, "Status:", status)
		end

		if not result then
			enable = false
		end
	end

	local hint = false

	if self.attachData.hintOpts and self.attachData.hintOpts[cfg.Id] then
		hint = true
	end

	local menu = cfg.Menu

	if menu > 0 then
		local v, k = table.find_if(options, function (item)
			return item.cfg.Id == menu
		end)

		if v == nil then
			return
		end

		local item = {
			index = #v.subOptions + 1,
			cfg = cfg,
			optionCfgId = cfg.Id,
			enable = enable,
			hint = hint
		}

		table.insert(v.subOptions, item)

		return
	end

	local item = {
		tIndex = 0,
		cfg = cfg,
		enable = enable,
		hint = hint
	}

	if self.subOptions and self.subOptions[cfg.Id] then
		item.tIndex = 1
		item.subOptions = {}
	end

	table.insert(options, item)
end

function PoliceExamineManager:GetCurrentQuestions()
	return self.attachData.extraQuestionList
end

function PoliceExamineManager:OnClickOption(optionCfg)
	local count = LTConfig.PoliceFineConfig.count
	local defaultCrimes = self.module.Crimes and self.module.Crimes:ToTable() or {}

	for i = 0, count - 1 do
		local fineCfg = LTConfig.PoliceFineConfig.LoadAt(i)

		if fineCfg.IsDefault == false and fineCfg.Type == PoliceFineConfig.TypeType.Npc then
			self:TryAddFine(fineCfg.Id, true, defaultCrimes)
		end
	end
end

function PoliceExamineManager:OnSuccessClickOption(optionCfg)
	if optionCfg then
		self.attachData.triggeredOptions[optionCfg.Id] = true
		self.attachData.hintOpts[optionCfg.Id] = nil
		local defaultCrimes = self.module.Crimes and self.module.Crimes:ToTable() or {}

		if not table.isNilOrEmpty(optionCfg.FineId) then
			for _, fineId in ipairs(optionCfg.FineId) do
				self:TryAddFine(fineId, true, defaultCrimes)
			end
		end

		if not self.attachData.successPoliceEffect then
			local table = {
				PoliceCfg.IdCheck,
				PoliceCfg.BodySearch,
				PoliceCfg.AlcoholTest,
				PoliceCfg.DrugTest
			}
			local triggerNum = 0

			for i = 1, #table do
				if self.attachData.triggeredOptions[table[i]] then
					triggerNum = triggerNum + 1
				end
			end

			if triggerNum > 1 then
				gClientToGameDelegate:AskPoliceEffectiveExam().Callback = function (err, data)
					if err == LTConfig.MessageConfig.Ok then
						self.attachData.successPoliceEffect = true
					else
						gDisplayMessageMgr:DisplayServerMessageId(err)
					end
				end
			end
		end

		if self.attachData.guideOptions then
			self.attachData.guideOptions[optionCfg.Id] = false
		end
	end
end

function PoliceExamineManager:GetFineByCrimeType(crimeType)
	return self.crimeType2Fine[crimeType]
end

local function RpcCallback(err)
	gDisplayMessageMgr:DisplayServerMessageId(err)
end

function PoliceExamineManager:TryAddFine(fineId, sync, defaultCrimes)
	if table.contains(defaultCrimes, fineId) then
		self:AddFine(fineId, sync)
	end
end

function PoliceExamineManager:AddFine(fineId, sync)
	if self.attachData.fineInfoDict[fineId] then
		return
	end

	if not table.contains(self.attachData.fineList, fineId) then
		table.insert(self.attachData.fineList, fineId)
	end

	self.attachData.fineInfoDict[fineId] = {
		isFined = false
	}
end

function PoliceExamineManager:AddQuestion(questionId)
	if not table.contains(self.attachData.extraQuestionList, questionId) then
		table.insert(self.attachData.extraQuestionList, questionId)
	end
end

function PoliceExamineManager:SyncPoliceQuestionInfo(policeQuestionInfo)
	if policeQuestionInfo == nil then
		return
	end

	if policeQuestionInfo.NpcId == 0 then
		return
	end

	self.policeQuestionInfos[policeQuestionInfo.NpcId] = policeQuestionInfo

	if self.npcId ~= policeQuestionInfo.NpcId then
		return
	end

	if not table.isNilOrEmpty(policeQuestionInfo.Fines) then
		for _, fineId in ipairs(policeQuestionInfo.Fines) do
			self:AddFine(fineId, false)
		end
	end

	if not table.isNilOrEmpty(policeQuestionInfo.Questions) then
		for _, questionId in ipairs(policeQuestionInfo.Questions) do
			self:AddQuestion(questionId)
		end
	end
end

function PoliceExamineManager:NpcBadReaction(reactionCfg, unit)
	if gPoliceJobManager.isDebug then
		print_notice("PoliceExamineManager NpcBadReaction", reactionCfg.Id)
	end

	if self.panel and self.panel.isShow then
		self.isClosingInquirePanel = true
		local waitTime = 7
		self.closeReason = C_PoliceInquiryPanelStore.CloseReason.BattleOrFlee

		if reactionCfg.Exit == ExitType.Battle or reactionCfg.Exit == ExitType.Flee then
			self.closeReason = C_PoliceInquiryPanelStore.CloseReason.BattleOrFlee

			if gPoliceJobManager.IsUnitValid(unit) then
				gCS.BaseUnitUtils.ChangeAuthorityState(unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
				gCS.BaseUnitUtils.MuteUnitServerControl(unit, false)
			end
		elseif reactionCfg.Exit == ExitType.Exit or reactionCfg.Exit == ExitType.Detach then
			if self.targetCloseReason then
				self.closeReason = self.targetCloseReason
				self.targetCloseReason = nil
			else
				self.closeReason = C_PoliceInquiryPanelStore.CloseReason.Leave
				waitTime = 3
			end
		end

		if self.closeReason ~= C_PoliceInquiryPanelStore.CloseReason.Leave and reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
			self.panel:HideAll(true)

			self.waitCloseOutwardSignal = gPoliceJobManager:GetNPCOutwardSignal(reactionCfg.NPCGameplaySignal)
			self.waitSignalUnitPid = unit and unit.Pid or 0
			local inwardSignal = reactionCfg.NPCGameplaySignal

			if self.waitCloseTaskTimer then
				self.waitCloseTaskTimer:Stop()

				self.waitCloseTaskTimer = nil
			end

			self.waitCloseTaskTimer = Timer.New(function ()
				print_notice("PoliceExamineManager 等待task结束失败：" .. inwardSignal)
				self:OnCommandEndClosePanel()

				self.waitCloseTaskTimer = nil
				self.waitSignalUnitPid = nil
			end, waitTime):Start()
		else
			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager npc 逃跑或者战斗、退出 等待序列结束关闭界面")
			end

			self.panel:Close(self.closeReason)
		end
	end

	if gPoliceJobManager.IsUnitValid(self.unit) then
		gPoliceJobManager:SetNpcExitState(self.unit.Pid, gPoliceJobManager.CS_EXIT_STATE.NONE)
	end
end

function PoliceExamineManager:ReportPoliceExamCommandEnd(outwardSignal, npcPid)
	if npcPid ~= self.waitSignalUnitPid and (not gPoliceJobManager.IsUnitValid(self.unit) or self.unit.Pid ~= npcPid) then
		return
	end

	if self.waitCloseOutwardSignal == outwardSignal then
		self.waitCloseOutwardSignal = nil

		if self.waitCloseTaskTimer then
			self.waitCloseTaskTimer:Stop()

			self.waitCloseTaskTimer = nil

			self:OnCommandEndClosePanel()
		end
	elseif self.waitResetStageTaskId == outwardSignal then
		self.waitResetStageTaskId = nil

		if self.waitResetStageTimer then
			self.waitResetStageTimer:Stop()

			self.waitResetStageTimer = nil
		end

		gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
		gPoliceJobManager.cs:ChangeNpcExamineState(self.waitSignalUnitPid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager npc 进入盘查逃跑或者战斗 序列结束重置状态成功！")
		end
	end
end

function PoliceExamineManager:OnCommandEndClosePanel()
	if self.panel and self.panel.isShow and self.closeReason then
		self.panel:Close(self.closeReason)

		self.closeReason = nil

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager npc 逃跑或者战斗 序列结束关闭界面成功！")
		end
	end
end

function PoliceExamineManager:TaskDoExamineAction(optionId)
	if optionId and optionId > 0 then
		if self:CanOptionShowInMain(optionId) then
			if self.panel and self.panel.isShow and self.panel:CanDoAction() then
				self:DoClickOption(optionId)
			else
				self.needAutoDoOptionId = optionId
			end
		elseif gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager 任务自动触发option 但此option不显示在主菜单中或者未解锁 id " .. tostring(optionId))
		end
	end
end

function PoliceExamineManager.SignalAction_ShowExamine()
	return
end

function PoliceExamineManager:OptionAction_Question(optionCfg)
	local askDialogId = self.attachData.askDialogId

	if askDialogId and askDialogId > 0 then
		self.panel:HideAll(true)
		gDialogManager:CloseDialog()
		gDialogManager:ShowGeneralDialog(askDialogId, gDialogSource.Police, nil, nil, function (_, _, state, nextDialogId)
			if nextDialogId == 0 and state == 0 then
				self.panel:RefreshList()
			end
		end)
		self:OnSuccessClickOption(optionCfg)
	end
end

function PoliceExamineManager:OptionAction_CheckId(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.IdentityCheckResult)

		if reactionCfg.Exit == ExitType.None then
			self:OnSuccessClickOption(optionCfg)

			local info = self.attachData.basicBodyInfo
			info.answerName = true
			info.answerJob = true
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ID_CHECK_RES)
end

function PoliceExamineManager.SignalAction_IdentityCheckResult()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.IdentityCheckResult) then
		return
	end

	self:SetNotFree()
	self.panel:ShowCheckIdContent(function ()
		self.panel:HideAll(true)
		self.panel:RefreshList()
		self:SendGameplayEvent(GameplayEvent.PoliceExitIDCheck)
		gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceIDCheck)
	end)
end

function PoliceExamineManager:GetNpcNameAndJob()
	local name = ""
	local job = ""

	if self.module.Component then
		name = self.module.Name
	end

	if self.unit and self.unit.ClientData.AgentId then
		local agentCfg = LTConfig.AgentConfig.GetConfig(self.unit.ClientData.AgentId)
		job = agentCfg and agentCfg.JobFakeTag
	end

	return name, job
end

function PoliceExamineManager:OptionAction_Search(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.SearchBodyResult)

		if reactionCfg.Exit == ExitType.None then
			self:OnSuccessClickOption(optionCfg)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_BODY_SEARCH_RES)
end

function PoliceExamineManager.SignalAction_SearchBodyResult()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.SearchBodyResult) then
		return
	end

	self:SetNotFree()
	self.panel:ShowSearchBodyContent(function ()
		self.panel:RefreshList()
		gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceSearchResult)
	end)
end

function PoliceExamineManager:OptionAction_AlcoholTest(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.BreathCheckResult)

		if reactionCfg.Exit == ExitType.None then
			self:OnSuccessClickOption(optionCfg)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ALCOHOL_TEST_RES)
end

function PoliceExamineManager.SignalAction_BreathCheckResult()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.BreathCheckResult) then
		return
	end

	self:SetNotFree()
	self.panel:ShowBreathCheckContent(function ()
		self:SendGameplayEvent(GameplayEvent.PoliceExitAlcoholTest)
		self.panel:RefreshList()
	end)
end

function PoliceExamineManager:OptionAction_DrugTest(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.DrugTestResult)

		if reactionCfg.Exit == ExitType.None then
			self:OnSuccessClickOption(optionCfg)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_DRUG_TEST_RES)
end

function PoliceExamineManager.SignalAction_DrugTestResult()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.DrugTestResult) then
		return
	end

	self:SetNotFree()
	self.panel:ShowDrugTestContent(function ()
		self:SendGameplayEvent(GameplayEvent.PoliceExitDrugTest)
		self.panel:RefreshList()
	end)
end

function PoliceExamineManager:OptionAction_Fine(optionCfg)
	self.panel:HideAll(true)
	self:ClearCachedGameplayEvent()

	local getup = self:GetGetUpEvent()

	if getup and self.unit then
		self.cachedGameplayEvent = GameplayEvent.PoliceEnterFine
		self.cachedSignal = self.VMSignalType.FineChoice
		self.cachedDelayTime = 7

		self:SendGameplayInwardSignal(self.unit, getup)
	else
		self:SendGameplayEvent(GameplayEvent.PoliceEnterFine)
		self:StartSignalFailWatchdog(self.VMSignalType.FineChoice, 7)
	end
end

function PoliceExamineManager:ShowFineResult()
	local self = this

	if not self.finedIdList then
		self.finedIdList = {}
	end

	self.panel:ShowFineResult(self.finedIdList, self.fineMoney, self.JobExpInfo, function ()
		self.panel:HideFineResult()
	end)

	self.JobExpInfo = nil
	self.fineMoney = nil
end

function PoliceExamineManager.SignalAction_FineChoice()
	local self = this

	if not gPoliceJobManager.IsUnitValid(self.unit) then
		print_error("PoliceExamineManager cached unit is nil")

		return
	end

	if not self:StopWatchdog(self.VMSignalType.FineChoice) then
		return
	end

	local function DoFine(fineIdList)
		if table.isNilOrEmpty(fineIdList) then
			self.panel:RefreshList()
			self:SendGameplayEvent(GameplayEvent.PoliceExitFine)
		else
			self.attachData.fineTimes = self.attachData.fineTimes + 1
			self.attachData.fineTimes = LTConfig.PoliceConfig.MaxFineTimes < self.attachData.fineTimes and LTConfig.PoliceConfig.MaxFineTimes or self.attachData.fineTimes

			self.panel:HideAll(true)
			gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
				if not reactionCfg then
					self.panel:RefreshList()

					return
				end

				if reactionCfg.Exit ~= ExitType.None then
					self:NpcBadReaction(reactionCfg, self.unit)
				else
					self:OnSuccessClickOption(PoliceCfg.GetConfig(PoliceCfg.Fine))
				end

				if reactionCfg.Dialog and reactionCfg.Dialog > 0 then
					local emotionType = self.module.Emotion
					local personality = self.module.Personality

					L18.Gameplay.PoliceJobUtils.ShowAIDialog(reactionCfg.Dialog, emotionType, personality, 0, self.attachData.useCustomDialogs)
				end

				if reactionCfg.IsEndMultiInteract then
					gPoliceJobManager.cs:TryStopMultiInteract()
				end

				if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
					self:SendGameplayEvent(reactionCfg.GameplayEvent)

					if gPoliceJobManager.isDebug then
						print_notice("PoliceExamineManager FineChoice : 开始主角动作" .. tostring(reactionCfg.GameplayEvent))
					end

					if reactionCfg.Exit == ExitType.None then
						self:StartSignalFailWatchdog(self.VMSignalType.FineResult, 7)
					end
				else
					self.SignalAction_FineResult()
				end

				if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and gPoliceJobManager.IsUnitValid(self.unit) then
					self:SendGameplayInwardSignal(self.unit, reactionCfg.NPCGameplaySignal)
					gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, self.unit.Pid)

					if gPoliceJobManager.isDebug then
						print_notice("PoliceExamineManager FineChoice : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
					end
				end
			end, gPoliceJobManager.WAIT_REACTION.WAIT_FINE_RES)
			gPoliceJobManager:CheckWaitOutwardSignal()

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager : 请求服务器罚款" .. " pid " .. tostring(self.unit.Pid))
			end

			self:SetNotFree()

			gClientToGameDelegate:AskPoliceFineNpc(self.unit.Pid, fineIdList).Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					if data == true then
						for _, fineId in ipairs(fineIdList) do
							local fine = self.attachData.fineInfoDict[fineId]

							if fine then
								self.attachData.fineInfoDict[fineId].isFined = true
							else
								fine = {
									isFined = true
								}
								self.attachData.fineInfoDict[fineId] = fine
							end
						end

						self.finedIdList = fineIdList
						self.needShowFineResult = true
					else
						self.finedIdList = {}
					end
				else
					self.needShowFineResult = false

					gPoliceJobManager:ClearWaitForReactionCallback(gPoliceJobManager.WAIT_REACTION.WAIT_FINE_RES)
					gDisplayMessageMgr:DisplayServerMessageId(err)

					if self.panel and self.panel.isShow then
						self.panel:RefreshList()
					end

					self:SendGameplayEvent(GameplayEvent.PoliceExitFine)

					return
				end
			end
		end
	end

	self.panel:ShowSelectFinePanel(self.attachData.fineTimes, self.attachData.fineInfoDict, self.attachData.fineList, DoFine)
end

function PoliceExamineManager.SignalAction_FineResult()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.FineResult) then
		return
	end

	self:SetNotFree()
	self.panel:RefreshList()
end

function PoliceExamineManager:OnDropPoliceJobExp(reward)
	if self.needShowFineResult and reward and self.panel and self.panel.isShow then
		self.fineMoney = 0

		for _, rewardDetail in pairs(reward) do
			self.fineMoney = self.fineMoney + rewardDetail.Money

			if rewardDetail.JobExpInfo and rewardDetail.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Police] then
				self.JobExpInfo = rewardDetail.JobExpInfo
			end
		end

		if self.JobExpInfo or self.fineMoney > 0 then
			self:ShowFineResult()
		end
	end
end

function PoliceExamineManager:ShowAiDialogByFineId(optionId, fineId)
	local taskDialog = true
	local type = 3
	local dialogId = nil

	if self.attachData.useCustomDialogs then
		dialogId = PoliceJobUtils.GetPoliceTaskAIDialogId(LTConfig.PoliceExamReactionConfig.Question, fineId)
	end

	if not dialogId or dialogId == 0 then
		local emotionType = self.module.Emotion
		local personality = self.module.Personality
		dialogId = PoliceJobUtils.GetAIDialogId(LTConfig.PoliceExamReactionConfig.Question, emotionType, personality, fineId)
		taskDialog = false
		type = 2
	end

	local callback = nil

	if optionId then
		if optionId == PoliceCfg.Name and (not self.attachData.basicBodyInfo.answerName or not self.attachData.basicBodyInfo.answerJob) then
			local aiDialogCfg = taskDialog and LTConfig.AIdialogPoliceTaskConfig.GetConfig(dialogId) or LTConfig.AIdialogPoliceConfig.GetConfig(dialogId)

			if aiDialogCfg then
				self.attachData.basicBodyInfo.answerName = self.attachData.basicBodyInfo.answerName or string.contains(aiDialogCfg.Message, PoliceCfg.NameAIDialogContainStr)
				self.attachData.basicBodyInfo.answerJob = self.attachData.basicBodyInfo.answerJob or string.contains(aiDialogCfg.Message, PoliceCfg.JobAIDialogContainStr)
			end
		elseif optionId == PoliceCfg.Job and (not self.attachData.basicBodyInfo.answerName or not self.attachData.basicBodyInfo.answerJob) then
			local aiDialogCfg = taskDialog and LTConfig.AIdialogPoliceTaskConfig.GetConfig(dialogId) or LTConfig.AIdialogPoliceConfig.GetConfig(dialogId)

			if aiDialogCfg then
				self.attachData.basicBodyInfo.answerName = self.attachData.basicBodyInfo.answerName or string.contains(aiDialogCfg.Message, PoliceCfg.NameAIDialogContainStr)
				self.attachData.basicBodyInfo.answerJob = self.attachData.basicBodyInfo.answerJob or string.contains(aiDialogCfg.Message, PoliceCfg.JobAIDialogContainStr)
			end
		end

		function callback(_, _, state, nextDialogId)
			if nextDialogId == 0 and state == 0 and self.panel and self.panel.isShow then
				self.panel:RefreshList()
			end
		end
	end

	L18.Script.LX6.Dialog.DialogManager.ShowAIDialog(dialogId, type, nil, callback)
end

function PoliceExamineManager:OptionAction_Arrest(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		if reactionCfg.Dialog and reactionCfg.Dialog > 0 then
			local emotionType = self.module.Emotion
			local personality = self.module.Personality

			L18.Gameplay.PoliceJobUtils.ShowAIDialog(reactionCfg.Dialog, emotionType, personality, 0, self.attachData.useCustomDialogs)
		end

		if reactionCfg.Exit == ExitType.Escort then
			self.isClosingInquirePanel = true
		end

		if reactionCfg.IsEndMultiInteract then
			gPoliceJobManager.cs:TryStopMultiInteract()
		end

		self:ClearCachedGameplayEvent()

		local getup = self:GetGetUpEvent()

		if getup then
			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager NPC需要先播起身 开始延迟动作， Signal " .. tostring(reactionCfg.NPCGameplaySignal) .. " 主角动作 " .. tostring(reactionCfg.GameplayEvent))
			end

			self.cachedGameplayEvent = reactionCfg.GameplayEvent
			self.cachedGameplaySignal = reactionCfg.NPCGameplaySignal

			if reactionCfg.Exit == ExitType.Escort then
				self.cachedSignal = self.VMSignalType.ArrestAnimFinish
				self.cachedDelayTime = 10
			end

			if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				gPoliceJobManager.curWaitMultiInteractType = reactionCfg.MultiInteractType
			else
				self.cachedMultiInteractType = reactionCfg.MultiInteractType
			end

			if self.unit then
				self:SendGameplayInwardSignal(self.unit, getup)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager signal 1017 开始NPC起身动作 1017")
				end
			end
		else
			if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
				self:SendGameplayEvent(reactionCfg.GameplayEvent)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager Arrest: 开始主角动作" .. tostring(reactionCfg.GameplayEvent))
				end
			end

			if reactionCfg.Exit == ExitType.Escort then
				self:StartSignalFailWatchdog(self.VMSignalType.ArrestAnimFinish, 10)
			end

			if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.unit then
				self:SendGameplayInwardSignal(self.unit, reactionCfg.NPCGameplaySignal)
				gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, self.unit.Pid)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager Arrest: 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
				end
			end

			if reactionCfg.MultiInteractType and reactionCfg.MultiInteractType > 0 and gPoliceJobManager.IsUnitValid(self.unit) then
				if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
					gPoliceJobManager.curWaitMultiInteractType = reactionCfg.MultiInteractType
				else
					gPoliceJobManager.cs:TryMultiInteract(reactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, self.unit)

					if gPoliceJobManager.isDebug then
						print_notice("PoliceExamineManager : 开始双人交互" .. tostring(reactionCfg.MultiInteractType))
					end
				end
			end
		end

		if reactionCfg.Exit ~= ExitType.None and reactionCfg.Exit ~= ExitType.Escort then
			self:NpcBadReaction(reactionCfg, self.unit)
		else
			self:OnSuccessClickOption(optionCfg)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ARREST_RES)
end

function PoliceExamineManager.SignalAction_ArrestAnimFinish()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.ArrestAnimFinish) then
		return
	end

	gPoliceJobManager:CheckWaitOutwardSignal()
	self:SetNotFree()

	local pid = nil

	if gPoliceJobManager.IsUnitValid(self.unit) then
		pid = self.unit.Pid
	end

	self.panel:Close(C_PoliceInquiryPanelStore.CloseReason.ArrestNpc)

	if pid then
		gPoliceJobManager.escortMgr:EnterEscortFromExamine(pid, true, false)
	end
end

function PoliceExamineManager:OptionAction_Release(optionCfg)
	self.panel:HideAll(true)
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList()

			return
		end

		self.targetCloseReason = C_PoliceInquiryPanelStore.CloseReason.ReleaseNpc

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.ReleaseAnimFinish)
		self:OnSuccessClickOption(optionCfg)
	end, gPoliceJobManager.WAIT_REACTION.WAIT_RELEASE_RES)
end

function PoliceExamineManager.SignalAction_ReleaseAnimFinish()
	local self = this

	if not self:StopWatchdog(self.VMSignalType.ReleaseAnimFinish) then
		return
	end

	self:SetNotFree()

	if gPoliceJobManager.IsUnitValid(self.unit) then
		gPoliceJobManager:SetNpcExitState(self.unit.Pid, gPoliceJobManager.CS_EXIT_STATE.NONE)
	end

	if self.waitCloseTaskTimer then
		self.waitCloseTaskTimer:Stop()

		self.waitCloseTaskTimer = nil

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager 释放NPC的VM信号关闭界面：")
		end

		self:OnCommandEndClosePanel()
	end
end

function PoliceExamineManager:OptionAction_Leave(optionCfg)
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self:ClickOption_Story(LTConfig.PoliceConfig.Leave)

		return
	end

	if not gPoliceJobManager.IsUnitValid(self.unit) then
		print_error("PoliceExamineManager cached unit is nil")

		return
	end

	if self.panel and self.panel.isShow then
		self.panel:HideAll(true)
	end

	local pid = self.unit.Pid

	gPoliceJobManager:CheckWaitOutwardSignal()
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:Close(C_PoliceInquiryPanelStore.CloseReason.Leave)
			self:SendGameplayEvent(GameplayEvent.PoliceExitExamine)

			return
		end

		self:CommonReactionDeal(reactionCfg, nil, nil, true)
		self:OnSuccessClickOption(optionCfg)
	end, gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_RES)

	if gPoliceJobManager.isDebug then
		print_notice("PoliceExamineManager : 请求服务器暂离" .. " pid " .. tostring(pid))
	end

	self:AskPoliceExamInteract(pid, InteractCfg.Leave).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPoliceJobManager:ClearWaitForReactionCallback(gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_RES)
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self.panel:Close(C_PoliceInquiryPanelStore.CloseReason.Leave)
		end
	end
end

function PoliceExamineManager:OptionAction_Command(optionCfg)
	self.panel:RefreshList(true, true)

	self.currentCondition = optionCfg.Condition

	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			self.panel:RefreshList(false, true)

			return
		end

		self:CommonReactionDeal(reactionCfg, self.VMSignalType.CommandFinish, 7, true)

		if reactionCfg.Exit == ExitType.None then
			self:OnSuccessClickOption(optionCfg)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_COMMAND_RES)
end

function PoliceExamineManager.SignalAction_CommandFinish(optionCfg)
	local self = this

	if not self.panel then
		return
	end

	if self.cachedGameplayEvent or self.cachedGameplaySignal or self.cachedMultiInteractType then
		return
	end

	if not self:StopWatchdog(self.VMSignalType.CommandFinish) then
		return
	end

	if self.currentCondition then
		self:RunCode("self:Set" .. self.currentCondition)

		self.currentCondition = nil
	end

	self.panel:RefreshList(false, true, true)
end

function PoliceExamineManager:SetNotHandsOnHead()
	self.attachData.handsOnHead = true
	self.attachData.isCrouching = false
	self.attachData.isProne = false
end

function PoliceExamineManager:SetNotCrouching()
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = true
	self.attachData.isProne = false
end

function PoliceExamineManager:SetNotProne()
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = false
	self.attachData.isProne = true
end

function PoliceExamineManager:SetNotFree()
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = false
	self.attachData.isProne = false
end

function PoliceExamineManager:GetGetUpEvent()
	if self.attachData == nil then
		return nil
	end

	if self.attachData.handsOnHead or self.attachData.isCrouching or self.attachData.isProne then
		return 1017
	end

	return nil
end

function PoliceExamineManager:CheckAgentIsStandUp(unit)
	if not self.attachData then
		return true
	end

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

	if module then
		local attachData = module.ClientExtraData

		if attachData ~= nil then
			return not self.attachData.handsOnHead and not self.attachData.isCrouching and not self.attachData.isProne
		end
	end

	return true
end

function PoliceExamineManager:StartSignalFailWatchdog(signal, timeout)
	timeout = timeout or 3

	self:StopWatchdog(signal)

	self._signalFailWatchdogList[signal] = Timer.New(function ()
		print_error_without_stack("PoliceExamineManager VM信号失败：" .. signal)

		local action = self.actionMgr.SignalTypeToAction[signal]

		action()

		self._signalFailWatchdogList[signal] = nil
	end, timeout):Start()
	self._signalPidList[signal] = self.unit.Pid
end

function PoliceExamineManager:GetCurSignalFailWatchDog()
	if table.isNilOrEmpty(self._signalFailWatchdogList) then
		return nil
	elseif self.unit then
		for signal, v in pairs(self._signalFailWatchdogList) do
			if self._signalPidList[signal] == self.unit.Pid then
				return signal
			end
		end
	end

	return nil
end

function PoliceExamineManager:StopWatchdog(signal)
	local watchdogTimer = self._signalFailWatchdogList[signal]

	if watchdogTimer then
		watchdogTimer:Stop()

		self._signalFailWatchdogList[signal] = nil
	end

	local equal = true

	if gPoliceJobManager.IsUnitValid(self.unit) and self._signalPidList[signal] ~= nil then
		equal = self._signalPidList[signal] == self.unit.Pid
	end

	self._signalPidList[signal] = nil

	return equal
end

function PoliceExamineManager:StopAllWatchdog()
	for _, v in pairs(self._signalFailWatchdogList) do
		v:Stop()
	end

	self._signalFailWatchdogList = {}
	self._signalPidList = {}
end

function PoliceExamineManager.SignalAction_SwitchCamera1()
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_CAMERA, 1)
end

function PoliceExamineManager.SignalAction_SwitchCamera2()
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_CAMERA, 2)
end

function PoliceExamineManager.SignalAction_SwitchCamera3()
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_CAMERA, 3)
end

function PoliceExamineManager:HasTriggeredOneOfDialog(dialogList)
	for _, dialogId in ipairs(dialogList) do
		if self:HasTriggeredOption(dialogId) then
			return true
		end
	end

	return false
end

function PoliceExamineManager:CanFine()
	return #self.attachData.fineList > 0
end

function PoliceExamineManager:HasFine(fineId)
	local fineList = (self.attachData or {}).fineList or {}

	return table.contains(fineList, fineId)
end

function PoliceExamineManager:HasTriggeredOption(optionId)
	if optionId == PoliceCfg.Fine then
		return LTConfig.PoliceConfig.MaxFineTimes <= self.attachData.fineTimes
	end

	return false
end

function PoliceExamineManager:HasTriggeredAllQuestion()
	for _, questionId in ipairs(self.baseQuestionList) do
		if not self:HasTriggeredQuestion(questionId) then
			return false
		end
	end

	for _, questionId in ipairs(self.attachData.extraQuestionList) do
		if not self:HasTriggeredQuestion(questionId) then
			return false
		end
	end

	return true
end

function PoliceExamineManager:HasTriggeredOneOfQuestion(questionIdList)
	for _, questionId in ipairs(questionIdList) do
		if self:HasTriggeredQuestion(questionId) then
			return true
		end
	end

	return false
end

function PoliceExamineManager:HasTriggeredQuestion(questionId)
	return self.attachData.triggeredQuestions[questionId] or false
end

function PoliceExamineManager:HasOneOfQuestion(list)
	for _, questionId in ipairs(list) do
		if table.contains(self.attachData.extraQuestionList, questionId) then
			return true
		end
	end

	return false
end

function PoliceExamineManager:HasAnyQuestion()
	return true
end

function PoliceExamineManager:NotCrouching()
	return not self.attachData.isCrouching
end

function PoliceExamineManager:NotProne()
	return not self.attachData.isProne
end

function PoliceExamineManager:NotHandsOnHead()
	return not self.attachData.handsOnHead
end

function PoliceExamineManager:NotFree()
	local attachData = self.attachData

	return attachData.isCrouching or attachData.isProne or attachData.handsOnHead
end

function PoliceExamineManager:EnterPoliceExamine(data)
	self:Init()

	if self.stateTreePlayerInExamine == true then
		print_warn("PoliceExamineManager 当前StateTree正在盘查中，进入盘查失败！")

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	if gPoliceJobManager.currentStage ~= gPoliceJobManager.POLICE_STAGE.NONE then
		if gPoliceJobManager.isDebug then
			if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
				print_warn("PoliceExamineManager 当前正在盘查中，进入盘查失败！")
			elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
				print_warn("PoliceExamineManager 当前正在押送中，进入盘查失败！")
			end
		end

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	if self.waitForMoveEndTimer then
		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	self.showExamineData = nil
	self.showExamineUnit = nil
	local targetPid = data.targetPid
	local selfUnit = MyPlayerManager.PlayerUnit
	local npcUnit = SceneDataMgr.GetUnit(targetPid)
	data.npcUnit = npcUnit

	if not gPoliceJobManager.IsUnitValid(npcUnit) then
		print_warn("PoliceExamineManager: InitScene npcUnit is nil!, targetPid", targetPid, "pid", (targetPid or {}).pid)

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.NpcNotFound)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.NpcNotFound)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(npcUnit)

	if module == nil or module.Component == nil then
		local moduleNil = module == nil
		local componentNil = true

		if not moduleNil then
			componentNil = module.Component == nil
		end

		print_warn("PoliceExamineManager: InitScene npcUnit has not AgentCharacterModule and component!, targetPid", targetPid, "module nil ", moduleNil, "Component nil ", componentNil)

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	gCS.BaseUnitUtils.ChangeAuthorityState(npcUnit.Pid, LX6.Units.Module.AuthorityState.Interacting, true)

	local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(LTConfig.MultiInteractTypeConfig.Examine, selfUnit, npcUnit, nil, nil, nil, nil)
	data.npcTargetDir = interactCoDir

	if not success then
		gCS.BaseUnitUtils.ChangeAuthorityState(npcUnit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
		print_warn("PoliceExamineManager: 获取盘查开始双人交互点位朝向失败!")

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	gCS.BaseUnitUtils.MuteUnitServerControl(npcUnit, true)
	gCS.MindPowerMgr:BreakAll()

	self.checkShowed = false
	self.needAutoDoOptionId = nil

	self:ClearCachedGameplayEvent()

	if not gPoliceJobManager.cs:TryMultiInteract(LTConfig.MultiInteractTypeConfig.Examine, selfUnit, npcUnit) then
		gCS.BaseUnitUtils.ChangeAuthorityState(npcUnit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
		gCS.BaseUnitUtils.MuteUnitServerControl(npcUnit, false)
		print_warn("PoliceEscortManager : 进入盘查双人交互失败")

		if data.closeCallback then
			data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
		end

		gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 开始进入盘查双人交互")
	end

	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.EXAMINE)
	gPoliceJobManager.cs:ChangeNpcExamineState(npcUnit.Pid, gPoliceJobManager.CS_EXAMINE_STAGE.EXAMINING)

	local state = LTConfig.UnitStateConfig.OnlyLook

	gCS.UnitStateMgr:AddClientState(MyPlayerManager.PlayerUnit.Pid, state, 999999)

	self.enterExamData = data
	self.waitForMoveEndTimer = Timer.New(function ()
		self:OnMoveTaskFailed()
	end, 15):Start()

	gClientToGameDelegate:AskPolicePrepareExam(data.targetPid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gCS.BaseUnitUtils.MuteUnitServerControl(self.enterExamData.npcUnit, false)
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function PoliceExamineManager:OnMoveTaskFailed()
	gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)
	gCS.BaseUnitUtils.ChangeAuthorityState(self.enterExamData.npcUnit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
	gCS.BaseUnitUtils.MuteUnitServerControl(self.enterExamData.npcUnit, false)
	self:EnterExamineFail(self.enterExamData.npcUnit.Pid)

	if self.enterExamData.closeCallback then
		self.enterExamData.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
	end

	gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)

	self.waitForMoveEndTimer = nil

	gPoliceJobManager.cs:TryStopMultiInteract()

	gClientToGameDelegate:AskPoliceExitEscortOrExam(self.enterExamData.npcUnit.Pid).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	self.enterExamData = nil
end

function PoliceExamineManager:SetCustomTaskData(data)
	if data.customFines and #data.customFines > 0 then
		self.attachData.customFines = data.customFines
	else
		self.attachData.customFines = nil
	end

	local valid = false

	if data.customOptions and #data.customOptions > 0 then
		valid = true

		for index = 1, #data.customOptions do
			local id = data.customOptions[index]
			local optionCfg = PoliceCfg.GetConfig(id)

			if optionCfg then
				if optionCfg.Menu and optionCfg.Menu > 0 and not table.contains(data.customOptions, optionCfg.Menu) then
					print_error("PoliceExamineManager spoon 中自定义显示的选项id的父选项未显示，id ", id)

					valid = false

					break
				end
			else
				print_error("PoliceExamineManager spoon 中自定义显示的选项id无效，id ", id)

				valid = false

				break
			end
		end
	end

	if valid then
		self.attachData.customOptions = data.customOptions

		if data.hideLeaveBtn then
			data.hideLeaveBtn = table.contains(data.customOptions, PoliceCfg.Release)
		end
	else
		self.attachData.customOptions = nil
	end

	if data.hideEscortLeaveBtn == true then
		self.attachData.hideEscortLeaveBtn = false
		self.attachData.hideEscortReleaseBtn = true
		self.attachData.hideEscortToExamineBtn = true
	else
		self.attachData.hideEscortLeaveBtn = false
		self.attachData.hideEscortReleaseBtn = false
		self.attachData.hideEscortToExamineBtn = false
	end

	if data.guideOptions and #data.guideOptions > 0 and (not self.attachData.guideOptions or #self.attachData.guideOptions == 0) then
		self.attachData.guideOptions = {}

		for i = 1, #data.guideOptions do
			self.attachData.guideOptions[data.guideOptions[i]] = true
		end

		self.attachData.guideIconId = data.guideIconId
	end

	if data.askDialogId and data.askDialogId > 0 then
		self.attachData.askDialogId = data.askDialogId
	end

	if data.useCustomDialogs then
		self.attachData.useCustomDialogs = true
	else
		self.attachData.useCustomDialogs = false
	end

	if data.calledInSpoon then
		self.attachData.isInMission = true
	else
		self.attachData.isInMission = false
	end

	if data.hideSuggestion then
		self.attachData.hideExamineSuggestion = true
	else
		self.attachData.hideExamineSuggestion = false
	end
end

function PoliceExamineManager:CheckHintOptions()
	if not self.attachData.hintOpts.Init then
		self.attachData.hintOpts.Init = true

		if gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810301) then
			local fines = self.module.Crimes and self.module.Crimes:ToTable()

			if fines and #fines > 0 then
				local options = {}

				for i = 0, PoliceCfg.count do
					local optionCfg = PoliceCfg.LoadAt(i)

					if optionCfg and optionCfg.FineId and #optionCfg.FineId > 0 then
						local contain = false

						for _, fineId in pairs(fines) do
							if table.contains(optionCfg.FineId, fineId) then
								contain = true

								break
							end
						end

						if contain then
							table.insert(options, optionCfg.Id)
						end
					end
				end

				if #options > 0 then
					local index = math.random(#options)
					local optionId = options[index]

					table.remove(options, index)

					self.attachData.hintOpts[optionId] = true
				end
			end
		end

		self:CheckFines()
	end
end

function PoliceExamineManager:CheckFines()
	if gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810302) then
		local fines = self.module.Crimes and self.module.Crimes:ToTable()

		if fines and #fines > 0 then
			math.randomseed(os.time())

			local MaxCount = PoliceCfg.HintOptionCount

			if not MaxCount or MaxCount < 1 then
				MaxCount = 1
			end

			local count = math.random(1, 4)
			local checkFines = {}

			for _, id in pairs(fines) do
				local fineCfg = PoliceFineConfig.GetConfig(id)

				if fineCfg.IsShow and fineCfg.Type ~= PoliceFineConfig.TypeType.Vehicle and (not self.attachData.customFines or table.contains(self.attachData.customFines, id)) then
					table.insert(checkFines, id)
				end
			end

			if checkFines then
				for i = 1, count do
					local index = math.random(#checkFines)
					local fineId = checkFines[index]

					table.remove(checkFines, index)
					self:AddFine(fineId, true)

					if #checkFines == 0 then
						break
					end
				end
			end
		end
	end
end

function PoliceExamineManager:IsOptionGuide(optionId)
	if self.attachData.guideOptions and self.attachData.guideOptions[optionId] then
		return true
	end

	return false
end

function PoliceExamineManager:GetGuideOptionIconId()
	return self.attachData.guideIconId or 0
end

function PoliceExamineManager:CanShowFine(fineCfg)
	if not fineCfg.IsShow and not self.attachData.isInMission then
		return false
	end

	if fineCfg.Type == PoliceFineConfig.TypeType.Vehicle then
		return false
	end

	if self.attachData.customFines then
		return table.contains(self.attachData.customFines, fineCfg.Id)
	end

	return true
end

function PoliceExamineManager:OnMoveFinish(data, unit)
	gPoliceJobManager:CheckWaitOutwardSignal()

	gPoliceJobManager.currentWaitAnimationPid = data.targetPid

	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			print_error("PoliceExamineManager OnMoveFinish reaction config is invalid!")
			self:OnMoveTaskFailed()

			return
		end

		if reactionCfg.Exit == ExitType.None then
			if gPoliceJobManager.isDebug then
				print_notice("Police NPC ChangeAuthorityState interacting true, pid " .. tostring(unit.Pid))
			end

			self:InitExamineData(unit)
			self:SetCustomTaskData(data)

			self.isClosingInquirePanel = false
			self.checkShowed = true

			gPanelManager:CheckShow(gPanelId.POLICE_INQUIRY_PANEL, data)

			if reactionCfg.Dialog and reactionCfg.Dialog > 0 then
				local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
				local emotionType = module.Emotion
				local personality = module.Personality

				L18.Gameplay.PoliceJobUtils.ShowAIDialog(reactionCfg.Dialog, emotionType, personality, 0, self.attachData.useCustomDialogs)
			end

			if reactionCfg.IsEndMultiInteract then
				gPoliceJobManager.cs:TryStopMultiInteract()
			end

			if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
				self:SendGameplayEvent(reactionCfg.GameplayEvent)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager OnMoveFinish : 开始主角动作" .. tostring(reactionCfg.GameplayEvent))
				end
			end

			if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				self:SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)
				gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, unit.Pid)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager OnMoveFinish : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
				end
			end

			gPoliceJobManager:SwitchWeaponToHand()
			gPoliceJobManager.cs:ChangeNpcExamineState(unit.Pid, gPoliceJobManager.CS_EXAMINE_STAGE.EXAMINING)
		else
			gCS.BaseUnitUtils.ChangeAuthorityState(unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
			gCS.BaseUnitUtils.MuteUnitServerControl(unit, false)
			gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)

			self.showExamineData = nil
			self.showExamineUnit = nil

			self:EnterExamineFail(unit.Pid, reactionCfg.NPCGameplaySignal)

			local useCustomDialogs = false

			if self.attachData and self.attachData.useCustomDialogs then
				useCustomDialogs = true
			end

			if data.useCustomDialogs then
				useCustomDialogs = true
			end

			if reactionCfg.Dialog and reactionCfg.Dialog > 0 then
				local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
				local emotionType = module.Emotion
				local personality = module.Personality

				L18.Gameplay.PoliceJobUtils.ShowAIDialog(reactionCfg.Dialog, emotionType, personality, 0, useCustomDialogs)
			end

			if reactionCfg.IsEndMultiInteract then
				gPoliceJobManager.cs:TryStopMultiInteract()
			end

			if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
				self:SendGameplayEvent(reactionCfg.GameplayEvent)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager OnMoveFinish : 开始主角动作" .. tostring(reactionCfg.GameplayEvent))
				end
			end

			if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				self:SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)
				gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, unit.Pid)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceExamineManager OnMoveFinish : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
				end
			end

			self:NpcBadReaction(reactionCfg, unit)

			if data.closeCallback then
				data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
			end

			gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_MOVE_FINISH)

	if data.fromEscort then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : 请求服务器押送进盘问" .. " pid " .. tostring(data.targetPid))
		end

		self:AskPoliceExamInteract(data.targetPid, LTConfig.PoliceExamInteractConfig.Examine).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gCS.BaseUnitUtils.ChangeAuthorityState(unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
				gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)
				gPoliceJobManager:ClearWaitForReactionCallback()
				gDisplayMessageMgr:ShowServerMessage(err)
				self:EnterExamineFail(unit.Pid)

				if data.closeCallback then
					data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
				end

				gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
			end
		end
	else
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager : 请求服务器盘问开始" .. " pid " .. tostring(data.targetPid))
		end

		self:AskPoliceExamInteract(data.targetPid, LTConfig.PoliceExamInteractConfig.Start).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gCS.BaseUnitUtils.ChangeAuthorityState(unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
				gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)
				gPoliceJobManager:ClearWaitForReactionCallback()
				gDisplayMessageMgr:ShowServerMessage(err)
				self:EnterExamineFail(unit.Pid)

				if data.closeCallback then
					data.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
				end

				gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
			end
		end
	end
end

function PoliceExamineManager:EnterExamineFormEscort(data, unit)
	gPoliceJobManager.currentWaitAnimationPid = data.targetPid

	self:InitExamineData(unit)

	self.isClosingInquirePanel = false
	self.checkShowed = true

	gPanelManager:CheckShow(gPanelId.POLICE_INQUIRY_PANEL, data)
	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.EXAMINE)
	gPoliceJobManager.cs:ChangeNpcExamineState(unit.Pid, gPoliceJobManager.CS_EXAMINE_STAGE.EXAMINING)
	gCS.BaseUnitUtils.ChangeAuthorityState(unit.Pid, LX6.Units.Module.AuthorityState.Interacting, true)
end

function PoliceExamineManager:EnterExamineFail(pid, gameplaySignal)
	if gPoliceJobManager.isDebug then
		print_notice("PoliceExamineManager:EnterExamineFail")
	end

	if gameplaySignal and gameplaySignal > 0 then
		self.waitResetStageTaskId = gPoliceJobManager:GetNPCOutwardSignal(gameplaySignal)
		self.waitSignalUnitPid = pid

		if self.waitResetStageTimer then
			self.waitResetStageTimer:Stop()

			self.waitResetStageTimer = nil
		end

		local targetPid = pid
		self.waitResetStageTimer = Timer.New(function ()
			print_notice("PoliceExamineManager 等待盘问开始战斗、逃跑task结束失败：" .. gameplaySignal)
			gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
			gPoliceJobManager.cs:ChangeNpcExamineState(targetPid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)

			self.waitResetStageTimer = nil
			self.waitSignalUnitPid = nil
		end, 15):Start()
	else
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PoliceExitExamine)
		gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
		gPoliceJobManager.cs:ChangeNpcExamineState(pid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
	end

	gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
end

function PoliceExamineManager:StateTreePoliceExamineMoveFinish()
	return
end

function PoliceExamineManager:StateTreePoliceExamineStateChange(targetState)
	self.stateTreePlayerInExamine = targetState

	gPoliceJobManager:RefreshPoliceStage()
end

function PoliceExamineManager:StateTreePoliceExit(pid)
	if self.panel and self.panel.isShow and not self.isClosingInquirePanel and (MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid or self.unit and self.unit.Pid == pid) then
		self:ExitByBadReason()

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager ExitByBadReason by StateTreePoliceExit pid " .. ulong.tostring(pid))
		end
	end
end

function PoliceExamineManager:ReportMutiInteractPrepared()
	if self.waitForMoveEndTimer then
		self.waitForMoveEndTimer:Stop()

		self.waitForMoveEndTimer = nil

		if self.enterExamData then
			self:OnMoveFinish(self.enterExamData, self.enterExamData.npcUnit)
		end

		self.enterExamData = nil
	end
end

function PoliceExamineManager:ReportMutiInteractCancel()
	if self.waitForMoveEndTimer then
		self.waitForMoveEndTimer:Stop()

		self.waitForMoveEndTimer = nil

		if self.enterExamData then
			self:OnMoveTaskFailed()
		end

		self.enterExamData = nil
	end
end

function PoliceExamineManager:OnUnitBeAttacked(pid)
	if MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid or self.unit and self.unit.Pid == pid then
		self:ExitByBadReason()

		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager ExitByBadReason by OnUnitBeAttacked pid " .. ulong.tostring(pid))
		end
	end
end

function PoliceExamineManager:OnUnitBeDestroy(pid)
	if MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid or self.unit and self.unit.Pid == pid then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceExamineManager ExitByBadReason by OnUnitBeDestroy pid " .. ulong.tostring(pid))
		end

		if self.panel and self.panel.isShow or self.checkShowed then
			local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(15001)

			if not reactionCfg then
				return
			end

			if pid ~= MyPlayerManager.PlayerUnit.Pid and reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
				self:SendGameplayEvent(reactionCfg.GameplayEvent)
			end

			if self.unit and pid ~= self.unit.Pid and self.unit and reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				self:SendGameplayInwardSignal(self.unit, reactionCfg.NPCGameplaySignal)
				gCS.BaseUnitUtils.ChangeAuthorityState(self.unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
				gCS.BaseUnitUtils.MuteUnitServerControl(self.unit, false)
			end

			gPoliceJobManager:CancelWaitOutwardSignal()
			self.panel:Close(C_PoliceInquiryPanelStore.CloseReason.Force, pid)
		elseif self.waitForMoveEndTimer then
			self.waitForMoveEndTimer:Stop()

			self.waitForMoveEndTimer = nil

			if self.enterExamData then
				if pid ~= MyPlayerManager.PlayerUnit.Pid then
					gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)
					gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PoliceExitExamine)
				end

				if pid ~= self.enterExamData.npcUnit.Pid then
					gCS.BaseUnitUtils.ChangeAuthorityState(self.enterExamData.npcUnit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
					gCS.BaseUnitUtils.MuteUnitServerControl(self.enterExamData.npcUnit, false)
				end

				gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)

				if self.enterExamData.closeCallback then
					self.enterExamData.closeCallback(C_PoliceInquiryPanelStore.CloseReason.Force)
				end

				gPoliceJobManager.cs:TriggerSpoonFinishExamAction(C_PoliceInquiryPanelStore.CloseReason.Force)
			end

			self.enterExamData = nil

			gPoliceJobManager:CancelWaitOutwardSignal()
		end
	end
end

function PoliceExamineManager:ExitByBadReason(skipReportExit)
	if self.panel and self.panel.isShow or self.checkShowed then
		local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(15001)

		if not reactionCfg then
			return
		end

		if reactionCfg.IsEndMultiInteract then
			gPoliceJobManager.cs:TryStopMultiInteract()
		end

		if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
			self:SendGameplayEvent(reactionCfg.GameplayEvent)
		end

		if self.unit then
			if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				self:SendGameplayInwardSignal(self.unit, reactionCfg.NPCGameplaySignal)
				gCS.BaseUnitUtils.ChangeAuthorityState(self.unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)
				gCS.BaseUnitUtils.MuteUnitServerControl(self.unit, false)
			end

			if not skipReportExit then
				gClientToGameDelegate:AskPoliceExitEscortOrExam(self.unit.Pid).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)
					end
				end
			end
		end

		self.panel:Close(C_PoliceInquiryPanelStore.CloseReason.Force)
	elseif self.waitForMoveEndTimer then
		self.waitForMoveEndTimer:Stop()

		self.waitForMoveEndTimer = nil

		if self.enterExamData then
			local npcPid = nil

			if self.enterExamData.npcUnit then
				npcPid = self.enterExamData.npcUnit.Pid
			end

			self:OnMoveTaskFailed()

			if npcPid and not skipReportExit then
				gClientToGameDelegate:AskPoliceExitEscortOrExam(npcPid).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)
					end
				end
			end
		end

		self.enterExamData = nil
	end
end

function PoliceExamineManager:OnExitExamine()
	self.unit = nil

	if gGameSwitch.EnablePoliceJobStoryLegacy then
		return
	end

	if self.waitForMoveEndTimer then
		self.waitForMoveEndTimer:Stop()

		self.waitForMoveEndTimer = nil
	end
end

function PoliceExamineManager:ClearStatus()
	self.stateTreePlayerInExamine = false

	if self.waitForMoveEndTimer then
		self.waitForMoveEndTimer:Stop()

		self.waitForMoveEndTimer = nil

		gPoliceJobManager.cs:TryStopMultiInteract()
	end
end

function PoliceExamineManager:RunCode(code)
	local f = load(code, nil, "t", {
		self = self
	})

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

PoliceExamineManager.OptionAction = {
	Question = this.OptionAction_Question,
	ID = this.OptionAction_CheckId,
	Search = this.OptionAction_Search,
	Alcohol = this.OptionAction_AlcoholTest,
	Drug = this.OptionAction_DrugTest,
	Fine = this.OptionAction_Fine,
	Arrest = this.OptionAction_Arrest,
	Release = this.OptionAction_Release,
	Leave = this.OptionAction_Leave,
	Command = this.OptionAction_Command
}
local SignalTypeToAction = this.actionMgr.SignalTypeToAction
local VMSignalType = this.actionMgr.VMSignalType
SignalTypeToAction[VMSignalType.ShowExamine] = this.SignalAction_ShowExamine
SignalTypeToAction[VMSignalType.BreathCheckResult] = this.SignalAction_BreathCheckResult
SignalTypeToAction[VMSignalType.DrugTestResult] = this.SignalAction_DrugTestResult
SignalTypeToAction[VMSignalType.SearchBodyResult] = this.SignalAction_SearchBodyResult
SignalTypeToAction[VMSignalType.IdentityCheckResult] = this.SignalAction_IdentityCheckResult
SignalTypeToAction[VMSignalType.FineResult] = this.SignalAction_FineResult
SignalTypeToAction[VMSignalType.ReleaseAnimFinish] = this.SignalAction_ReleaseAnimFinish
SignalTypeToAction[VMSignalType.ArrestAnimFinish] = this.SignalAction_ArrestAnimFinish
SignalTypeToAction[VMSignalType.SwitchCamera1] = this.SignalAction_SwitchCamera1
SignalTypeToAction[VMSignalType.SwitchCamera2] = this.SignalAction_SwitchCamera2
SignalTypeToAction[VMSignalType.SwitchCamera3] = this.SignalAction_SwitchCamera3
SignalTypeToAction[VMSignalType.CommandFinish] = this.SignalAction_CommandFinish
SignalTypeToAction[VMSignalType.FineChoice] = this.SignalAction_FineChoice

function PoliceExamineManager:SendGameplayEvent(event)
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, event)
end

function PoliceExamineManager:SendGameplayInwardSignal(unit, event)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, event)
end

function PoliceExamineManager:ClearCachedGameplayEvent()
	self.cachedGameplayEvent = nil
	self.cachedSignal = nil
	self.cachedDelayTime = nil
	self.cachedGameplaySignal = nil
	self.cachedMultiInteractType = nil
end

function PoliceExamineManager:TriggerCachedGameplayEvent()
	self:SetNotFree()

	local cachedGameplayEvent = self.cachedGameplayEvent
	local cachedSignal = self.cachedSignal
	local cachedDelayTime = self.cachedDelayTime
	local cachedGameplaySignal = self.cachedGameplaySignal
	local cachedMultiInteractType = self.cachedMultiInteractType

	self:ClearCachedGameplayEvent()

	if self.unit then
		if self.isDebug then
			print_notice("PoliceExamineManager TriggerCachedGameplayEvent")
		end

		if cachedGameplayEvent and cachedGameplayEvent > 0 then
			self:SendGameplayEvent(cachedGameplayEvent)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager signal " .. tostring(cachedGameplayEvent) .. " : 开始主角动作" .. tostring(cachedGameplayEvent))
			end
		end

		if cachedSignal and cachedDelayTime then
			self:StartSignalFailWatchdog(cachedSignal, cachedDelayTime or 7)
		end

		if cachedGameplaySignal and cachedGameplaySignal > 0 and self.unit then
			self:SendGameplayInwardSignal(self.unit, cachedGameplaySignal)
			gPoliceJobManager:SetWaitNPCSignal(cachedGameplaySignal, self.unit.Pid)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager signal " .. tostring(cachedGameplaySignal) .. " : 开始NPC动作" .. tostring(cachedGameplaySignal))
			end
		end

		if cachedMultiInteractType and cachedMultiInteractType > 0 and gPoliceJobManager.IsUnitValid(self.unit) then
			gPoliceJobManager.cs:TryMultiInteract(cachedMultiInteractType, MyPlayerManager.PlayerUnit, self.unit)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceExamineManager : 开始双人交互" .. tostring(cachedMultiInteractType))
			end
		end
	end
end

function PoliceExamineManager:AskPoliceExamInteract(pid, interactId)
	return gClientToGameDelegate:AskPoliceExamInteract(pid, interactId)
end

function PoliceExamineManager:ClickOption_Story(optionId)
	if self.BlockInteract then
		return
	end

	self.PreOptionId = optionId

	gPoliceJobManager.cs:ClickOption_Story(self.unit.Pid, optionId)

	local count = LTConfig.PoliceFineConfig.count
	local defaultCrimes = self.module.Crimes and self.module.Crimes:ToTable() or {}

	for i = 0, count - 1 do
		local fineCfg = LTConfig.PoliceFineConfig.LoadAt(i)

		if fineCfg.IsDefault == false and fineCfg.Type == PoliceFineConfig.TypeType.Npc then
			self:TryAddFine(fineCfg.Id, true, defaultCrimes)
		end
	end
end

function PoliceExamineManager:SetBlockInteract_Story(flag)
	self.BlockInteract = flag
end

function PoliceExamineManager:OnSectionEnable_Story(optionId)
	local optionCfg = PoliceCfg.GetConfig(optionId)

	if optionCfg.Message == "Command" then
		self.panel:RefreshList(true, true)
	else
		self.panel:HideAll(true)
	end
end

function PoliceExamineManager:VMSingal_Story(optionId, eventId)
	print_notice("PoliceExamineManager Story: vmsignal!!!!" .. eventId)

	local optionCfg = PoliceCfg.GetConfig(optionId)

	if eventId == self.VMSignalType.DrugTestResult then
		self:SetNotFree()
		self.panel:ShowDrugTestContent(function ()
			self:SendGameplayEvent(GameplayEvent.PoliceExitDrugTest)
			self.panel:RefreshList()
		end)
	elseif eventId == self.VMSignalType.BreathCheckResult then
		self:SetNotFree()
		self.panel:ShowBreathCheckContent(function ()
			self:SendGameplayEvent(GameplayEvent.PoliceExitAlcoholTest)
			self.panel:RefreshList()
		end)
	elseif eventId == self.VMSignalType.CommandFinish then
		if optionCfg.Condition then
			self:RunCode("self:Set" .. optionCfg.Condition)
		end

		self.panel:RefreshList(false, true, true)
	elseif eventId == self.VMSignalType.IdentityCheckResult then
		self:SetNotFree()
		self.panel:ShowCheckIdContent(function ()
			self.panel:HideAll(true)
			self.panel:RefreshList()
			self:SendGameplayEvent(GameplayEvent.PoliceExitIDCheck)
			gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceIDCheck)
		end)
	elseif eventId == self.VMSignalType.SearchBodyResult then
		self:SetNotFree()
		self.panel:ShowSearchBodyContent(function ()
			self.panel:RefreshList()
			gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceSearchResult)
		end)
	elseif eventId == self.VMSignalType.FineChoice then
		self:FineChoice_Story()
	elseif eventId == self.VMSignalType.FineResult then
		self:SetNotFree()
		self.panel:RefreshList()
	end
end

function PoliceExamineManager:FineChoice_Story()
	print_notice("PoliceExamineManager : finechose!!!!")

	local function DoFine(fineIdList)
		print_notice("PoliceExamineManager : donfine!!!!")

		if table.isNilOrEmpty(fineIdList) then
			self.panel:RefreshList()
		else
			self.attachData.fineTimes = self.attachData.fineTimes + 1
			self.attachData.fineTimes = LTConfig.PoliceConfig.MaxFineTimes < self.attachData.fineTimes and LTConfig.PoliceConfig.MaxFineTimes or self.attachData.fineTimes

			self.panel:HideAll(true)

			for _, fineId in ipairs(fineIdList) do
				local fine = self.attachData.fineInfoDict[fineId]

				if fine then
					self.attachData.fineInfoDict[fineId].isFined = true
				else
					fine = {
						isFined = true
					}
					self.attachData.fineInfoDict[fineId] = fine
				end
			end

			self.finedIdList = fineIdList
			self.needShowFineResult = true
		end

		gPoliceJobManager.cs:AskPoliceFine(self.unit.Pid, fineIdList)
	end

	self.panel:ShowSelectFinePanel(self.attachData.fineTimes, self.attachData.fineInfoDict, self.attachData.fineList, DoFine)
end

function PoliceExamineManager:PrepareDataFromSpoon_Story(data)
	local npcUnit = SceneDataMgr.GetUnit(data.targetPid)

	self:InitExamineData(npcUnit)

	data.npcUnit = npcUnit

	self:SetCustomTaskData(data)

	self.enterExamData = data
end

function PoliceExamineManager:PrepareData_Story(pid)
	local npcUnit = SceneDataMgr.GetUnit(pid)

	self:InitExamineData(npcUnit)

	local data = {
		npcUnit = npcUnit
	}

	self:SetCustomTaskData(data)

	self.enterExamData = data
end

function PoliceExamineManager:OnReceiveReaction(reactionId)
	local optionId = self.PreOptionId
	local optionCfg = PoliceCfg.GetConfig(optionId)
	local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(reactionId)

	if optionCfg and reactionCfg then
		self:OnSuccessClickOption(optionCfg)
	end

	if optionCfg and optionCfg.Message == "ID" and reactionCfg.Exit == ExitType.None then
		local info = self.attachData.basicBodyInfo
		info.answerName = true
		info.answerJob = true
	end
end

return PoliceExamineManager
