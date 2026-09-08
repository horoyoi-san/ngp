-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PoliceJob\PoliceExamineManager.lua
-- Decompiled from: 00550_PoliceExamineManager.lua_0ee272666ee3.luajit

if not gPoliceJobManager or not gPoliceJobManager.examineMgr then
	local PoliceExamineManager = {
		actionMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceGameplayActions")
	}
end

local this = PoliceExamineManager
PoliceExamineManager.ExamineType = this.actionMgr.ExamineType
PoliceExamineManager.VMSignalType = this.actionMgr.VMSignalType
local PoliceCfg = LTConfig.PoliceConfig
local PoliceFineConfig = LTConfig.PoliceFineConfig
local ExitType = LTConfig.PoliceExamReactionConfig.ExitType
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

PoliceExamineManager.Init = function(self)
	if self.init then
		return
	end

	self.subOptions = {}
	self.searchOptions = {}
	local count = PoliceCfg.count

	for i = 0, count - 1 do
		local cfg = PoliceCfg.LoadAt(i)
		local menu = cfg.Menu

		if menu == 0 then
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

		if cfg.DrugType and cfg.DrugType == 0 then
			self.drugTypeToFines[cfg.DrugType] = cfg.Id
		end

		if cfg.ItemType and cfg.ItemType == 0 then
			self.itemTypeToFines[cfg.ItemType] = cfg.Id
		end
	end

	self.crimeType2Fine = {}
	count = PoliceFineConfig.count

	for i = 0, count - 1 do
		local cfg = PoliceFineConfig.LoadAt(i)

		if cfg and cfg.CrimeType <= 0 then
			self.crimeType2Fine[cfg.CrimeType] = cfg.Id
		end
	end

	self.init = true
end

PoliceExamineManager.InitExamineData = function(self, unit)
	local pid = unit.Pid
	self.unit = unit

	if self.unitPid ~= pid then
		self.SetNotFree(self)

		return
	end

	self.unitPid = pid
	self.module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
	self.component = self.module.Component
	self.attachData = self.module.ClientExtraData

	if self.attachData ~= nil then
		self.attachData = {}
		self.module.ClientExtraData = self.attachData
	end

	self.SetNotFree(self)

	if self.attachData.mgrInit then
		return
	end

	if not self.attachData.isServerSynced then
		self.attachData.fineInfoDict = {}
		self.attachData.fineTimes = 0
	end

	self.attachData.fineList = {}
	self.attachData.triggeredOptions = {}
	self.attachData.basicBodyInfo = {
		["BI~K;:"] = false,
		["RTݪ\\x81\\x96\\xc4\\xed"] = false
	}
	self.attachData.successPoliceEffect = false
	self.attachData.foldTopRightMenu = false
	self.attachData.customOptions = nil
	self.attachData.customFines = nil
	self.attachData.isInMission = false
	self.attachData.hideExamineSuggestion = false
	self.attachData.hintOpts = {
		["S,tO"] = false
	}
	self.attachData.mgrInit = true
end

PoliceExamineManager.OnSyncExamineData = function(self, pid, data)
	local unit = SceneDataMgr.GetUnit(pid)

	if unit then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)
		local attachData = module.ClientExtraData

		if attachData ~= nil then
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
					["\\xd0\\xc82!\\xf5"] = true
				}
			end
		end

		attachData.isServerSynced = true
	end
end

PoliceExamineManager.GetFineIdByDrugType = function(self, drugType)
	return self.drugTypeToFines[drugType]
end

PoliceExamineManager.GetFineIdByItemType = function(self, ItemType)
	return self.itemTypeToFines[ItemType]
end

PoliceExamineManager.GetOptionResSuggestion = function(self, optionId)
	if self.attachData.hideExamineSuggestion then
		return nil
	end

	local optionCfg = PoliceCfg.GetConfig(optionId)
	local res = nil

	if optionCfg and optionCfg.FineId and #optionCfg.FineId <= 0 then
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

PoliceExamineManager.ClickOption = function(self, optionId)
	if optionId ~= PoliceCfg.Ask then
		if self.attachData.askDialogId and self.attachData.askDialogId <= 0 then
			if self.BlockInteract then
				return
			end

			slot2 = self.panel

			slot2:HideAll(true)

			slot2 = gDialogManager

			slot2:ShowGeneralDialog(self.attachData.askDialogId, gDialogSource.Police, nil, , function (_, _, state, nextDialogId)
				if nextDialogId ~= 0 and state ~= 0 and self.panel and self.panel.isShow then
					self.panel:RefreshList()
				end
			end)
		end
	else
		self.ClickOption_Story(self, optionId)
	end
end

PoliceExamineManager.CanOptionShowInMain = function(self, optionId)
	local optionCfg = PoliceCfg.GetConfig(optionId)

	if optionId ~= PoliceCfg.Ask then
		if not self.attachData.askDialogId or self.attachData.askDialogId < 0 then
			return false
		end
	else
		if optionCfg.ShowType == PoliceCfg.ShowTypeType.Main and optionCfg.ShowType == PoliceCfg.ShowTypeType.All then
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

PoliceExamineManager.GetCurrentTopRightOptions = function(self)
	local options = {}

	if self.attachData.foldTopRightMenu then
		return options
	end

	if self.attachData.basicBodyInfo then
		local nameCfg = PoliceCfg.GetConfig(PoliceCfg.Name)
		local jobCfg = PoliceCfg.GetConfig(PoliceCfg.Job)

		if nameCfg and jobCfg then
			local info = self.attachData.basicBodyInfo
			local name, job = self.GetNpcNameAndJob(self)
			local nameLabel = nil

			if info.answerName then
				nameLabel = string.format(PoliceCfg.TopLeftFormat, nameCfg.Option, name)
			else
				nameLabel = string.format(PoliceCfg.TopLeftFormat, nameCfg.Option, PoliceCfg.HideNameJobText)
			end

			local nameOption = {
				["\\xca\\xd3\n?7\\xfa"] = true,
				["a\\x9f\\x8a\\x86Y"] = 0,
				optionId = nameCfg.Id,
				fineId = PoliceCfg.NameAIDialogFineId,
				label = nameLabel,
				iconId = nameCfg.Icon
			}

			table.insert(options, nameOption)
		end
	end

	local emotionId = gPoliceJobManager.cs:GetExamEmotionIdByUnit(self.unit)

	if emotionId <= 0 then
		local emotionCfg = LTConfig.PoliceEmotionConfig.GetConfig(emotionId)
		local emotionOption = {
			["K\\x9e\\x80\\xaaE"] = 0,
			["\\xca\\xd3\n?7\\xfa"] = false,
			["A\\x9f\\x8b\\xaaE"] = 0,
			["\\xa4\\xa1\\xa2e0\\xd77"] = 0,
			["a\\x9f\\x8a\\x86Y"] = 1,
			label = emotionCfg and emotionCfg.Des or ""
		}

		table.insert(options, emotionOption)
	end

	if self.attachData.triggeredOptions then
		for id, state in pairs(self.attachData.triggeredOptions) do
			if state then
				local cfg = PoliceCfg.GetConfig(id)

				if cfg and (cfg.ShowType ~= PoliceCfg.ShowTypeType.All or cfg.ShowType ~= PoliceCfg.ShowTypeType.TopRight) then
					local crimed = false

					for i = 1, #self.attachData.fineList do
						local fineId = self.attachData.fineList[i]
						local fineCfg = PoliceFineConfig.GetConfig(fineId)

						if fineCfg and table.contains(cfg.FineId, fineId) then
							local option = {
								["\\xca\\xd3\n?7\\xfa"] = true,
								["a\\x9f\\x8a\\x86Y"] = 0,
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
							["\\xca\\xd3\n?7\\xfa"] = false,
							["A\\x9f\\x8b\\xaaE"] = 0,
							["a\\x9f\\x8a\\x86Y"] = 0,
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

PoliceExamineManager.GetCurrentSuggestion = function(self)
	if self.attachData.hideExamineSuggestion then
		return nil
	end

	local searchNum = 0

	for k, v in pairs(self.attachData.triggeredOptions) do
		if v and table.contains(self.searchOptions, k) then
			searchNum = searchNum + 1
		end
	end

	if gPoliceJobManager.cs:IsUnitIsFakePersonByUnit(self.unit) and searchNum <= 0 then
		return PoliceCfg.SuggestionFake, true
	end

	local customOptions = self.attachData.customOptions
	local hasIDCheck = not customOptions or table.contains(customOptions, PoliceCfg.IdCheck)

	if not self.attachData.triggeredOptions[PoliceCfg.IdCheck] and hasIDCheck then
		return PoliceCfg.SuggestionCheck
	end

	local allSearchNum = #self.searchOptions
	local allSearch = searchNum <= 0 and searchNum ~= allSearchNum

	if searchNum <= 0 then
		if searchNum > 0.5 * allSearchNum then
			local fineList = self.attachData.fineList

			if #fineList <= 0 then
				local serious = false
				local crimeType = false

				for i = 1, #fineList do
					local cfg = PoliceFineConfig.GetConfig(fineList[i])

					if cfg then
						if cfg.CrimeType <= 0 then
							crimeType = true
						end

						if cfg.Factor > 3 then
							serious = true
						end
					end
				end

				if crimeType and (not customOptions or table.contains(customOptions, PoliceCfg.Arrest)) then
					return PoliceCfg.SuggestionArrest
				elseif serious and (not customOptions or table.contains(customOptions, PoliceCfg.Arrest) or table.contains(customOptions, PoliceCfg.Fine)) then
					return PoliceCfg.SuggestionArrestOrFine
				elseif not customOptions or table.contains(customOptions, PoliceCfg.Fine) then
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

PoliceExamineManager.SwitchTopRightMenuFold = function(self)
	self.attachData.foldTopRightMenu = not self.attachData.foldTopRightMenu

	self.panel:RefreshList(false, true, true)
end

PoliceExamineManager.IsTopRightMenuFold = function(self)
	return self.attachData.foldTopRightMenu
end

PoliceExamineManager.GetCurrentOptions = function(self)
	local count = PoliceCfg.count
	local options = {}
	self.searchOptions = {}

	for i = 0, count - 1 do
		local cfg = PoliceCfg.LoadAt(i)

		if self.CanOptionShowInMain(self, cfg.Id) then
			self._AddOptionToList(self, options, cfg)

			if cfg.OptionType ~= PoliceCfg.OptionTypeType.Search then
				table.insert(self.searchOptions, cfg.Id)
			end
		end
	end

	for i = #options, 1, -1 do
		local subOptions = options[i].subOptions

		if subOptions and #subOptions ~= 0 then
			table.remove(options, i)
		end
	end

	return options
end

PoliceExamineManager._AddOptionToList = function(self, options, cfg)
	local enable = true
	local condition = cfg.Condition

	if not string.is_null_or_empty(condition) then
		local status, result = self.RunCode(self, "return self:" .. condition)

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

	if menu <= 0 then
		local v, k = table.find_if(options, function (item)
			return item.cfg.Id ~= menu
		end)

		if v ~= nil then
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
		["a\\x9f\\x8a\\x86Y"] = 0,
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

PoliceExamineManager.OnSuccessClickOption = function(self, optionCfg)
	if optionCfg then
		self.attachData.triggeredOptions[optionCfg.Id] = true
		self.attachData.hintOpts[optionCfg.Id] = nil
		local defaultCrimes = self.module.Crimes and self.module.Crimes:ToTable() or {}

		if not table.isNilOrEmpty(optionCfg.FineId) then
			for _, fineId in ipairs(optionCfg.FineId) do
				self.TryAddFine(self, fineId, true, defaultCrimes)
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

			if triggerNum <= 1 then
				slot5 = gClientToGameDelegate

				slot5:AskPoliceEffectiveExam().Callback = function (err, data)
					if err ~= LTConfig.MessageConfig.Ok then
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

PoliceExamineManager.GetFineByCrimeType = function(self, crimeType)
	return self.crimeType2Fine[crimeType]
end

PoliceExamineManager.TryAddFine = function(self, fineId, sync, defaultCrimes)
	if table.contains(defaultCrimes, fineId) then
		self.AddFine(self, fineId, sync)
	end
end

PoliceExamineManager.AddFine = function(self, fineId, sync)
	if self.attachData.fineInfoDict[fineId] then
		return
	end

	if not table.contains(self.attachData.fineList, fineId) then
		table.insert(self.attachData.fineList, fineId)
	end

	self.attachData.fineInfoDict[fineId] = {
		["\\xd0\\xc82!\\xf5"] = false
	}
end

PoliceExamineManager.GetNpcNameAndJob = function(self)
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

PoliceExamineManager.ShowFineResult = function(self)
	local self = this

	if not self.finedIdList then
		self.finedIdList = {}
	end

	slot2 = self.panel

	slot2:ShowFineResult(self.finedIdList, self.fineMoney, self.JobExpInfo, function ()
		self.panel:HideFineResult()
	end)

	self.JobExpInfo = nil
	self.fineMoney = nil
end

PoliceExamineManager.OnDropPoliceJobExp = function(self, reward)
	if self.needShowFineResult and reward and self.panel and self.panel.isShow then
		self.fineMoney = 0

		for _, rewardDetail in pairs(reward) do
			self.fineMoney = self.fineMoney + rewardDetail.Money

			if rewardDetail.JobExpInfo and rewardDetail.JobExpInfo[LTConfig.UrbanJobJobClassConfig.Police] then
				self.JobExpInfo = rewardDetail.JobExpInfo
			end
		end

		if self.JobExpInfo or self.fineMoney <= 0 then
			self.ShowFineResult(self)
		end
	end
end

PoliceExamineManager.ShowAiDialogByFineId = function(self, optionId, fineId)
	local taskDialog = true
	local type = 3
	local dialogId = nil
	local isFakePerson = gPoliceJobManager.cs:IsUnitIsFakePersonByUnit(self.unit)

	if self.attachData.useCustomDialogs then
		dialogId = PoliceJobUtils.GetPoliceTaskAIDialogId(LTConfig.PoliceExamReactionConfig.Question, fineId, isFakePerson)
	end

	if not dialogId or dialogId ~= 0 then
		local emotionType = self.module.Emotion
		local personality = self.module.Personality
		dialogId = PoliceJobUtils.GetAIDialogId(LTConfig.PoliceExamReactionConfig.Question, emotionType, personality, fineId, isFakePerson)
		taskDialog = false
		type = 2
	end

	local callback = nil

	if optionId then
		local bodyInfo = self.attachData.basicBodyInfo

		if optionId ~= PoliceCfg.Name and (not bodyInfo.answerName or not bodyInfo.answerJob) then
			local aiDialogCfg = taskDialog and LTConfig.AIdialogPoliceTaskConfig.GetConfig(dialogId) or LTConfig.AIdialogPoliceConfig.GetConfig(dialogId)

			if aiDialogCfg then
				bodyInfo.answerName = bodyInfo.answerName or string.contains(aiDialogCfg.Message, PoliceCfg.NameAIDialogContainStr)
				bodyInfo.answerJob = bodyInfo.answerJob or string.contains(aiDialogCfg.Message, PoliceCfg.JobAIDialogContainStr)
			end
		elseif optionId ~= PoliceCfg.Job and (not bodyInfo.answerName or not bodyInfo.answerJob) then
			local aiDialogCfg = taskDialog and LTConfig.AIdialogPoliceTaskConfig.GetConfig(dialogId) or LTConfig.AIdialogPoliceConfig.GetConfig(dialogId)

			if aiDialogCfg then
				bodyInfo.answerName = bodyInfo.answerName or string.contains(aiDialogCfg.Message, PoliceCfg.NameAIDialogContainStr)
				bodyInfo.answerJob = bodyInfo.answerJob or string.contains(aiDialogCfg.Message, PoliceCfg.JobAIDialogContainStr)
			end
		end

		callback = function(_, _, state, nextDialogId)
			if nextDialogId ~= 0 and state ~= 0 and self.panel and self.panel.isShow then
				self.panel:RefreshList()
			end
		end
	end

	L50.L50App.Scene.DialogManager:ShowAIDialog(dialogId, type, nil, callback)
end

PoliceExamineManager.SetNotHandsOnHead = function(self)
	self.attachData.handsOnHead = true
	self.attachData.isCrouching = false
	self.attachData.isProne = false
end

PoliceExamineManager.SetNotCrouching = function(self)
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = true
	self.attachData.isProne = false
end

PoliceExamineManager.SetNotProne = function(self)
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = false
	self.attachData.isProne = true
end

PoliceExamineManager.SetNotFree = function(self)
	self.attachData.handsOnHead = false
	self.attachData.isCrouching = false
	self.attachData.isProne = false
end

PoliceExamineManager.GetGetUpEvent = function(self)
	if self.attachData ~= nil then
		return nil
	end

	if self.attachData.handsOnHead or self.attachData.isCrouching or self.attachData.isProne then
		return 1017
	end

	return nil
end

PoliceExamineManager.CheckAgentIsStandUp = function(self, unit)
	if not self.attachData then
		return true
	end

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

	if module then
		local attachData = module.ClientExtraData

		if attachData == nil then
			return not self.attachData.handsOnHead and not self.attachData.isCrouching and not self.attachData.isProne
		end
	end

	return true
end

PoliceExamineManager.HasTriggeredOneOfDialog = function(self, dialogList)
	for _, dialogId in ipairs(dialogList) do
		if self.HasTriggeredOption(self, dialogId) then
			return true
		end
	end

	return false
end

PoliceExamineManager.CanFine = function(self)
	return #self.attachData.fineList >= 0
end

PoliceExamineManager.HasFine = function(self, fineId)
	local fineList = (self.attachData or {}).fineList or {}

	return table.contains(fineList, fineId)
end

PoliceExamineManager.HasTriggeredOption = function(self, optionId)
	if optionId ~= PoliceCfg.Fine then
		return LTConfig.PoliceConfig.MaxFineTimes > self.attachData.fineTimes
	end

	return false
end

PoliceExamineManager.NotCrouching = function(self)
	return not self.attachData.isCrouching
end

PoliceExamineManager.NotProne = function(self)
	return not self.attachData.isProne
end

PoliceExamineManager.NotHandsOnHead = function(self)
	return not self.attachData.handsOnHead
end

PoliceExamineManager.NotFree = function(self)
	local attachData = self.attachData

	return attachData.isCrouching or attachData.isProne or attachData.handsOnHead
end

PoliceExamineManager.SetCustomTaskData = function(self, data)
	if data.customFines and #data.customFines <= 0 then
		self.attachData.customFines = data.customFines
	else
		self.attachData.customFines = nil
	end

	local valid = false

	if data.customOptions and #data.customOptions <= 0 then
		valid = true

		for index = 1, #data.customOptions do
			local id = data.customOptions[index]
			local optionCfg = PoliceCfg.GetConfig(id)

			if optionCfg then
				if optionCfg.Menu and optionCfg.Menu <= 0 and not table.contains(data.customOptions, optionCfg.Menu) then
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

	if data.hideEscortLeaveBtn ~= true then
		self.attachData.hideEscortLeaveBtn = false
		self.attachData.hideEscortReleaseBtn = true
		self.attachData.hideEscortToExamineBtn = true
	else
		self.attachData.hideEscortLeaveBtn = false
		self.attachData.hideEscortReleaseBtn = false
		self.attachData.hideEscortToExamineBtn = false
	end

	if data.guideOptions and #data.guideOptions <= 0 and (not self.attachData.guideOptions or #self.attachData.guideOptions ~= 0) then
		self.attachData.guideOptions = {}

		for i = 1, #data.guideOptions do
			self.attachData.guideOptions[data.guideOptions[i]] = true
		end

		self.attachData.guideIconId = data.guideIconId
	end

	if data.askDialogId and data.askDialogId <= 0 then
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

PoliceExamineManager.CheckHintOptions = function(self)
	if not self.attachData.hintOpts.Init then
		self.attachData.hintOpts.Init = true

		if gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810301) then
			local fines = self.module.Crimes and self.module.Crimes:ToTable()

			if fines and #fines <= 0 then
				local options = {}

				for i = 0, PoliceCfg.count do
					local optionCfg = PoliceCfg.LoadAt(i)

					if optionCfg and optionCfg.FineId and #optionCfg.FineId <= 0 then
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

				if #options <= 0 then
					local index = math.random(#options)
					local optionId = options[index]

					table.remove(options, index)

					self.attachData.hintOpts[optionId] = true
				end
			end
		end

		self.CheckFines(self)
	end
end

PoliceExamineManager.CheckFines = function(self)
	if gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810302) then
		local fines = self.module.Crimes and self.module.Crimes:ToTable()

		if fines and #fines <= 0 then
			math.randomseed(os.time())

			local MaxCount = PoliceCfg.HintOptionCount

			if not MaxCount or MaxCount >= 1 then
				MaxCount = 1
			end

			local count = math.random(1, 4)
			local checkFines = {}

			for _, id in pairs(fines) do
				local fineCfg = PoliceFineConfig.GetConfig(id)

				if fineCfg.IsShow and fineCfg.Type == PoliceFineConfig.TypeType.Vehicle and (not self.attachData.customFines or table.contains(self.attachData.customFines, id)) then
					table.insert(checkFines, id)
				end
			end

			if checkFines and #checkFines <= 0 then
				for i = 1, count do
					local index = math.random(#checkFines)
					local fineId = checkFines[index]

					table.remove(checkFines, index)
					self.AddFine(self, fineId, true)

					if #checkFines ~= 0 then
						break
					end
				end
			end
		end
	end
end

PoliceExamineManager.IsOptionGuide = function(self, optionId)
	if self.attachData.guideOptions and self.attachData.guideOptions[optionId] then
		return true
	end

	return false
end

PoliceExamineManager.GetGuideOptionIconId = function(self)
	return self.attachData.guideIconId or 0
end

PoliceExamineManager.CanShowFine = function(self, fineCfg)
	if not fineCfg.IsShow and not self.attachData.isInMission then
		return false
	end

	if fineCfg.Type ~= PoliceFineConfig.TypeType.Vehicle then
		return false
	end

	if self.attachData.customFines then
		return table.contains(self.attachData.customFines, fineCfg.Id)
	end

	return true
end

PoliceExamineManager.OnExitExamine = function(self)
	self.unit = nil
end

PoliceExamineManager.RunCode = function(self, code)
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

PoliceExamineManager.SendGameplayEvent = function(self, event)
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, event)
end

PoliceExamineManager.SendGameplayInwardSignal = function(self, unit, event)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, event)
end

PoliceExamineManager.ClickOption_Story = function(self, optionId)
	if self.BlockInteract or self.unit ~= nil then
		return
	end

	self.PreOptionId = optionId

	gPoliceJobManager.cs:ClickOption_Story(self.unit.Pid, optionId)

	local count = LTConfig.PoliceFineConfig.count
	local defaultCrimes = self.module.Crimes and self.module.Crimes:ToTable() or {}

	for i = 0, count - 1 do
		local fineCfg = LTConfig.PoliceFineConfig.LoadAt(i)

		if fineCfg.IsDefault ~= false and fineCfg.Type ~= PoliceFineConfig.TypeType.Npc then
			self.TryAddFine(self, fineCfg.Id, true, defaultCrimes)
		end
	end
end

PoliceExamineManager.SetBlockInteract_Story = function(self, flag)
	self.BlockInteract = flag
end

PoliceExamineManager.OnSectionEnable_Story = function(self, optionId)
	local optionCfg = PoliceCfg.GetConfig(optionId)

	if optionCfg.Message ~= "Command" then
		self.panel:RefreshList(true, true)
	else
		self.panel:HideAll(true)
	end
end

PoliceExamineManager.VMSingal_Story = function(self, optionId, eventId)
	print_notice("PoliceExamineManager Story: vmsignal!!!!" .. eventId)

	local optionCfg = PoliceCfg.GetConfig(optionId)

	if eventId ~= self.VMSignalType.DrugTestResult then
		self:SetNotFree()

		slot4 = self.panel

		slot4:ShowDrugTestContent(function ()
			self:SendGameplayEvent(GameplayEvent.PoliceExitDrugTest)
			self.panel:RefreshList()
		end)
	elseif eventId ~= self.VMSignalType.BreathCheckResult then
		self:SetNotFree()

		slot4 = self.panel

		slot4:ShowBreathCheckContent(function ()
			self:SendGameplayEvent(GameplayEvent.PoliceExitAlcoholTest)
			self.panel:RefreshList()
		end)
	elseif eventId ~= self.VMSignalType.CommandFinish then
		if optionCfg.Condition then
			self.RunCode(self, "self:Set" .. optionCfg.Condition)
		end

		self.panel:RefreshList(false, true, true)
	elseif eventId ~= self.VMSignalType.IdentityCheckResult then
		self:SetNotFree()

		slot4 = self.panel

		slot4:ShowCheckIdContent(function ()
			self.panel:HideAll(true)
			self.panel:RefreshList()
			self:SendGameplayEvent(GameplayEvent.PoliceExitIDCheck)
			gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceIDCheck)
		end)
	elseif eventId ~= self.VMSignalType.SearchBodyResult then
		self:SetNotFree()

		slot4 = self.panel

		slot4:ShowSearchBodyContent(function ()
			self.panel:RefreshList()
			gNewGuideMgr:NotifySignal(EGuideSignal.ClosePoliceSearchResult)
		end)
	elseif eventId ~= self.VMSignalType.FineChoice then
		self.FineChoice_Story(self)
	elseif eventId ~= self.VMSignalType.FineResult then
		self:SetNotFree()
		self.panel:RefreshList()
	end
end

PoliceExamineManager.FineChoice_Story = function(self)
	print_notice("PoliceExamineManager : finechose!!!!")

	local DoFine = function(fineIdList)
		print_notice("PoliceExamineManager : donfine!!!!")

		if table.isNilOrEmpty(fineIdList) then
			self.panel:RefreshList()
		else
			self.attachData.fineTimes = self.attachData.fineTimes + 1
			self.attachData.fineTimes = LTConfig.PoliceConfig.MaxFineTimes >= self.attachData.fineTimes and LTConfig.PoliceConfig.MaxFineTimes or self.attachData.fineTimes

			self.panel:HideAll(true)

			for _, fineId in ipairs(fineIdList) do
				local fine = self.attachData.fineInfoDict[fineId]

				if fine then
					self.attachData.fineInfoDict[fineId].isFined = true
				else
					fine = {
						["\\xd0\\xc82!\\xf5"] = true
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

PoliceExamineManager.PrepareDataFromSpoon_Story = function(self, data)
	local npcUnit = SceneDataMgr.GetUnit(data.targetPid)

	self.InitExamineData(self, npcUnit)

	data.npcUnit = npcUnit

	self.SetCustomTaskData(self, data)

	self.enterExamData = data
end

PoliceExamineManager.PrepareData_Story = function(self, pid)
	local npcUnit = SceneDataMgr.GetUnit(pid)

	self.InitExamineData(self, npcUnit)

	local data = {
		npcUnit = npcUnit
	}

	self.SetCustomTaskData(self, data)

	self.enterExamData = data
end

PoliceExamineManager.OnReceiveReaction = function(self, reactionId)
	local optionId = self.PreOptionId
	local optionCfg = PoliceCfg.GetConfig(optionId)
	local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(reactionId)

	if optionCfg and reactionCfg then
		self.OnSuccessClickOption(self, optionCfg)
	end

	if optionCfg and optionCfg.Message ~= "ID" and reactionCfg.Exit ~= ExitType.None then
		local info = self.attachData.basicBodyInfo
		info.answerName = true
		info.answerJob = true
	end
end

return PoliceExamineManager
