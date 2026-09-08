-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\BeggarJob\BeggarManager.lua
-- Decompiled from: 00555_BeggarManager.lua_038cf42a323c.luajit

local M = gBeggarManager or {}
M.IsInit = M.IsInit or false
M.BeggarStoreName = "BeggarPanelStore"
M.BeggarHUDStoreName = "BeggarHudPanelStore"
local MyPlayerManager = gCS.MyPlayerManager
local BeggarStyleConfig = LTConfig.BeggarStyleConfig
local BeggarTypeConfig = LTConfig.BeggarTypeConfig
local BeggarConfig = LTConfig.BeggarConfig
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local BeggarDrawConfig = LTConfig.BeggarDrawConfig
local AgentConfig = LTConfig.AgentConfig

M.OnInit = function(self)
	if self.IsInit then
		return
	end

	self.fuxiBridge = L50.Beggar.BeggarBridge
	self.PAINTING_RES_LEVEL = {
		["\\xacIB"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 1,
		["j\\x9c\\x87\\x8e\\x82"] = 0
	}
	self.IsInit = true
	self.cs = L18.Gameplay.BeggarManager.Instance
end

M.GetBeggarPanelStore = function(self)
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and beggarPanel.isShow then
		return beggarPanel
	end

	return nil
end

M.OnStateTreeEnterWaitLoop = function(self)
	local beggarPanel = self:GetBeggarPanelStore()

	if beggarPanel then
		beggarPanel:OnStateTreeEnterWaitLoop()
	else
		FrameTimer.New(function ()
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarEnd)
		end, 1):Start()
	end
end

M.OnStateTreeEnterBeggingLoop = function(self)
	local beggarPanel = self:GetBeggarPanelStore()

	if beggarPanel and not beggarPanel:IsEndBegging() then
		beggarPanel:OnStateTreeEnterBeggingLoop()
	else
		FrameTimer.New(function ()
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.BeggarSwitch)
		end, 1):Start()
	end
end

M.OnSyncSpiritBeggarJobData = function(self, spiritId, data)
	local beggarPanel = self:GetBeggarPanelStore()

	if beggarPanel then
		beggarPanel:OnSyncData(data)
	end

	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:OnSyncData(data)
	end

	if not self.isInBeggar then
		self:StartPopUp(data)
	end
end

M.OnSpotDataChange = function(self, spotId, npcLimit, npcProbability, npcIds)
	if MassAI.MassAIManager.Instance == nil then
		MassAI.MassAIManager.Instance:OnSpotDataChange(spotId, npcLimit, npcProbability, npcIds)
	end
end

M.DonationPlayer = function(self, param)
	if param then
		self.donationPlayerId = param
	else
		local selfPid = gPlayerManager:GetLoginRolePid()
		local find = false

		for k, _ in pairs(gLinkManager.LinkMember) do
			if k == selfPid and not find then
				find = true
				self.donationPlayerId = k
			end
		end
	end

	if self.donationPlayerId then
		gMainPhoneUtils.ShowPhoneAppContent({
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Beggar,
			secondShowType = gClientConst.BEGGAR_APP_SHOW_TYPE.PAY
		})
	end
end

M.OnOtherPlayerEndBegging = function(self, pid)
	if pid and self.donationPlayerId and self.donationPlayerId ~= pid and self.payPanel and self.payPanel.isShow then
		self.payPanel:OnExecuteExitAction()
	end
end

M.ActivateRelatedAP = function(self, spotId)
	if MassAI.MassAIManager.Instance == nil then
		MassAI.MassAIManager.Instance:ActiveBeggarAP(spotId)
	end
end

M.InactivateRelatedAP = function(self, spotId)
	if MassAI.MassAIManager.Instance == nil then
		MassAI.MassAIManager.Instance:InactiveAp(spotId)
	end
end

M.OnAPNpcNumChanged = function(self, spotId, changedCount, totalCount)
	local beggarPanel = gStoreManager:GetStoreGroup(self.BeggarStoreName)

	if beggarPanel and beggarPanel.spot ~= spotId then
		gClientToGameDelegate:AskOnNpcAttractedByBeg(changedCount, totalCount)
	end
end

M.GetBeggarTypeInfo = function(self)
	local typeList = {}

	for i = 0, BeggarTypeConfig.count - 1 do
		local cfg = BeggarTypeConfig.LoadAt(i)

		if cfg and cfg.Id == 4 then
			if cfg.BadgeId and cfg.BadgeId <= 0 then
				if gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId) then
					table.insert(typeList, cfg.Id)
				end
			else
				table.insert(typeList, cfg.Id)
			end
		end
	end

	return typeList
end

M.GetBeggarStyleInfo = function(self, beggarType)
	local styleList = {}

	if beggarType and beggarType <= 0 then
		for i = 0, BeggarStyleConfig.count - 1 do
			local cfg = BeggarStyleConfig.LoadAt(i)

			if cfg and cfg.Type ~= beggarType then
				table.insert(styleList, cfg.Id)
			end
		end
	end

	return styleList
end

M.GetBeggarActionInfo = function(self, beggarStyle)
	local action = {}

	if beggarStyle and beggarStyle <= 0 then
		for i = 0, BeggarConfig.count - 1 do
			local cfg = BeggarConfig.LoadAt(i)

			if cfg and cfg.Style ~= beggarStyle then
				if cfg.BadgeId and cfg.BadgeId <= 0 then
					if gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId) then
						table.insert(action, cfg.Id)
					end
				else
					table.insert(action, cfg.Id)
				end
			end
		end
	end

	return action
end

M.OpenBeggarHudPanel = function(self, typeId, styleId, promote)
	self.isInBeggar = true

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		["hw\\xa1r\\\\xbe\\xf3^^cnI"] = "aBknO9<",
		params = {
			typeId = typeId,
			styleId = styleId,
			promote = promote
		}
	})
end

M.CheckNeedEndBeggar = function(self)
	if not self.isInBeggar then
		gMessageManager:SendMessage(gEventConstants.BEGGAR_END, self.spotId or 1)
	end
end

M.PlaySound = function(self, soundId, pos, isMe)
	self:StopSound()

	if soundId and soundId <= 0 then
		self.soundNid = gSoundMgr:PlaySoundByTid(soundId, pos, nil, , , function (CSData)
			if isMe then
				CSData:SetSwitchValue(gSoundMgr.SwitchGroupName.OwnerSwitch, gSoundMgr.SwitchGroupValue.Owner.Player)
			else
				CSData:SetSwitchValue(gSoundMgr.SwitchGroupName.OwnerSwitch, gSoundMgr.SwitchGroupValue.Owner.Other)
			end
		end)
	end
end

M.StopSound = function(self)
	if self.soundNid then
		gSoundMgr:StopSoundByNid(self.soundNid)

		self.soundNid = nil
	end
end

M.StopBeggar = function(self, data)
	self.isInBeggar = false

	self:StopSound()
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.Beggar)
	self:StartPopUp(data)
end

M.EnterBeggarAction = function(self, spotId)
	self.isInBeggar = false

	if gGameSwitch.EnableBeggerStory then
		self.spotId = 1
		self.gadgetId = spotId
	else
		self.spotId = spotId
	end

	if self.spotId and self.spotId <= 0 then
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(true, gBanId.Beggar)
		gMainPhoneUtils.ShowPhoneAppContent({
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Beggar,
			secondShowType = gClientConst.BEGGAR_APP_SHOW_TYPE.ARTIST_HOME
		})
	end
end

M.StopBeggarAction = function(self)
	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:OnBtnBackCallback()
	end
end

M.StartPopUp = function(self, data)
	if not data then
		return
	end

	self.stopBegTime = data.LastUpdateTime or gLuaDataManager.serverTime
	self.startTime = data.StartTime or gLuaDataManager.serverTime
	self.totalReward = data.TotalReward + data.TotalRewardFromPlayer
	self.exp = data.Exp

	if self.popupTimer then
		self.popupTimer:Stop()

		self.popupTimer = nil
	end

	self.popupTimer = Timer.New(function ()
		gBeggarManager:PopUpReward(self.totalReward, self.exp, self.stopBegTime - self.startTime)
	end, 1):Start()
end

M.PopUpReward = function(self, money, jobExp, time)
	local currentJobInfo, levelCfg, cfg = self:GetBeggarJobInfo()

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.BeggarReward, {
		spiritJob = currentJobInfo,
		levelCfg = levelCfg,
		cfg = cfg,
		money = money,
		jobExp = jobExp,
		time = time
	})
end

M.GetBeggarJobInfo = function(self)
	local currentJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Beggar)
	local currentJobInfo = gSpiritJobManager.GetCurSpiritJob(currentJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)
	local _, cfg = gSpiritJobManager:GetAvailableJobByClass(LTConfig.UrbanJobJobClassConfig.Beggar)

	if currentJobInfo and urbanJobCfg then
		local spiritTid = gSpiritManager:GetCurFirstSpiritTid()
		local levelCfg = gSpiritJobManager:GetLevelData(urbanJobCfg, spiritTid)

		return currentJobInfo, levelCfg, cfg
	end
end

M.HasPaintTask = function(self)
	return self.paintTaskInfo
end

M.InPaintingTask = function(self)
	return self.isInPainting
end

M.GetCurPaintTaskInfo = function(self)
	return self.paintTaskInfo
end

M.ResetPaintTaskInfo = function(self)
	self.paintTaskInfo = nil
	self.isInPainting = false
	self.paintAgentCid = nil
	self.paintAgentPid = nil
end

M.OnSyncNewPaintTask = function(self, npcInstanceId, drawThemeId, startTime, endTime)
	local agentCid = 0
	local unit = gCS.SceneDataMgr.GetUnit(npcInstanceId)

	if unit then
		agentCid = unit.ClientData.AgentId

		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, 10425)
	else
		agentCid = self.cs:GetAgentConfigId(npcInstanceId)
	end

	self.paintTaskInfo = {
		npcInsId = npcInstanceId,
		themeId = drawThemeId,
		agentCid = agentCid,
		startTime = startTime,
		finishTime = endTime
	}
	self.isInPainting = false
	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:RefreshPaintingTaskInfo()
	end
end

M.GetPaintingTaskTopic = function(self, themeId, noRichText)
	local cfg = BeggarDrawConfig.GetConfig(themeId)

	if cfg then
		local format = noRichText and BeggarConfig.PaintingQustionDesc2 or BeggarConfig.PaintingQustionDesc

		return string.format(format, cfg.Questions), cfg
	end

	return "", nil
end

M.AskAcceptPaintTask = function(self)
	if self.isInPainting then
		return
	end

	self.isInPainting = true
	self.paintAgentCid = self.paintTaskInfo.agentCid
	self.paintAgentPid = self.paintTaskInfo.npcInsId

	gClientToGameDelegate:AskRespondToPaintRequest(true).Callback = function (errorId, drawStart, drawEnd)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local beggarHudPanel = gStoreManager:GetStoreGroup(gBeggarManager.BeggarHUDStoreName)

		if beggarHudPanel and beggarHudPanel.isShow then
			beggarHudPanel:RefreshPaintingTaskInfo()
		end
	end
end

M.AskRefusePaintTask = function(self)
	if self.isInPainting then
		return
	end

	self.paintTaskInfo = nil
	self.isInPainting = false
	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:RefreshPaintingTaskInfo()
	end

	gClientToGameDelegate:AskRespondToPaintRequest(false).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskGiveUpPaintTask = function(self)
	if not self.isInPainting then
		return
	end

	self.paintTaskInfo = nil
	self.isInPainting = false
	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:RefreshPaintingTaskInfo()
	end

	gClientToGameDelegate:AskGiveUpPainting().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.AskCompletePaintTask = function(self, info)
	if not self.isInPainting then
		return
	end

	local topic, cfg = self:GetPaintingTaskTopic(self.paintTaskInfo.themeId, true)
	local mbti = self:GetAgentMbti(self.paintTaskInfo.agentCid)
	self.paintTaskInfo = nil
	self.isInPainting = false
	local beggarHudPanel = gStoreManager:GetStoreGroup(self.BeggarHUDStoreName)

	if beggarHudPanel and beggarHudPanel.isShow then
		beggarHudPanel:RefreshPaintingTaskInfo()
		beggarHudPanel:PaintNPCBeginReview(gBeggarManager.paintAgentPid)
	end

	self.drawOperationNum = info.drawOperationNum
	self.useColorNum = info.useColorNum
	local lang = self:GetCurLanguageAbbreviation()
	local prompt = cfg.AIDescriptionPrompt
	local keywords = cfg.AIRecognitionKeywords
	local ossUrl = #cfg.ImageList <= 0 and LX6.Utils.AliOssManager.Instance:GetDownloadUrl(cfg.ImageList[1]) or ""

	self.fuxiBridge.StreetArtistEvaluate(topic, ossUrl, prompt, keywords, info.base64, mbti, lang, function (data)
		if data and data.NpcMsg then
			local store = gStoreManager:GetStoreGroup(gBeggarManager.BeggarHUDStoreName)

			if store and store.isShow then
				store:ShowPaintResDialog(data.NpcMsg)
				store:PaintNPCFinishReview()
			end
		end

		gClientToGameDelegate:AskEndPainting(data and data.EvaluationId or "", gBeggarManager.drawOperationNum, gBeggarManager.useColorNum).Callback = function (errorId, beggarPaintScore, money)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				if errorId == LTConfig.MessageConfig.NotInPainting then
					local store = gStoreManager:GetStoreGroup(gBeggarManager.BeggarHUDStoreName)

					if store and store.isShow then
						if not self.randomDialogMgr then
							self.randomDialogMgr = C_RandomDialogManager.new(LTConfig.BeggarRandomSelectionConfig, "BeggarRandomSelectionConfig")
						end

						local dialogId = self.randomDialogMgr:GetDialogId(LTConfig.BeggarRandomSelectionConfig.Guarantee)

						if dialogId then
							local config = LTConfig.DialogConfig.GetConfig(dialogId)

							if config then
								store:ShowPaintResDialog(config.Message)
							end
						end

						local defaultMoney = LTConfig.BeggarConfig.PaintRewardWhenServerError or 0

						store:ShowPaintingResult(gBeggarManager.PAINTING_RES_LEVEL.NORMAL, defaultMoney, gBeggarManager.paintAgentCid, gBeggarManager.paintAgentPid)
					end
				end

				return
			end

			local store = gStoreManager:GetStoreGroup(gBeggarManager.BeggarHUDStoreName)

			if store and store.isShow then
				local level = gBeggarManager.PAINTING_RES_LEVEL.BAD

				if beggarPaintScore then
					if BeggarConfig.Scorehigh >= beggarPaintScore.TotalScore then
						level = gBeggarManager.PAINTING_RES_LEVEL.GREAT
					elseif BeggarConfig.Scorelow >= beggarPaintScore.TotalScore then
						level = gBeggarManager.PAINTING_RES_LEVEL.NORMAL
					end
				end

				store:ShowPaintingResult(level, money or 0, gBeggarManager.paintAgentCid, gBeggarManager.paintAgentPid)
			end
		end
	end)
end

M.RefreshPaintingTaskContent = function(self, content)
	if not content then
		return
	end

	local store = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

	if not store then
		return
	end

	if store.acceptBtn then
		store.acceptBtn.luaClick = function()
			self:AskAcceptPaintTask()
		end
	end

	if store.refuseBtn then
		store.refuseBtn.luaClick = function()
			self:AskRefusePaintTask()
		end
	end

	if store.giveUpBtn then
		store.giveUpBtn.luaClick = function()
			self:AskGiveUpPaintTask()
		end
	end

	if store.referOpenBtn then
		store.referOpenBtn.luaClick = function()
			store.openReferenceCtrl = 1
		end
	end

	if store.referCloseBtn then
		store.referCloseBtn.luaClick = function()
			store.openReferenceCtrl = 0
		end
	end

	if store.referCloseBtn2 then
		store.referCloseBtn2.luaClick = function()
			store.openReferenceCtrl = 0
		end
	end

	local taskInfo = self:GetCurPaintTaskInfo()

	if taskInfo.agentCid <= 0 then
		local agentCfg = AgentConfig.GetConfig(taskInfo.agentCid)

		if agentCfg then
			store.agentHeadImg = agentCfg.HeadIcon
			store.agentName = agentCfg.Name
		end
	end

	local topic, cfg = self:GetPaintingTaskTopic(taskInfo.themeId, false)
	store.request = topic
	store.referImg = cfg.NoteImage
	store.openReferenceCtrl = 0
	store.levelCtrl = cfg.DifficultyLevel ~= BeggarDrawConfig.DifficultyLevelType.High and 1 or 0

	if store.countDown then
		store.countDown.luaFinished = function()
			self:AskRefusePaintTask()
		end

		if taskInfo.finishTime - gLuaDataManager.serverTime <= 0 then
			store.countDown:Play(math.max(0, taskInfo.finishTime - gLuaDataManager.serverTime))
		end
	end

	store.drawing = self:InPaintingTask() and 1 or 0
end

M.GetCurLanguageAbbreviation = function(self)
	local langIdx = LX6.Engine.ProfileManager.languageProfile.textLanguage
	local langCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(langIdx)

	return langCfg and langCfg.Abbreviation
end

M.GetAgentMbti = function(self, agentId)
	local mbti = "ENFP"

	if agentId then
		local agentCfg = AgentConfig.GetConfig(agentId)

		if agentCfg then
			if agentCfg.MBTI ~= AgentConfig.MBTIType.ENFJ then
				mbti = "ENFJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ENTJ then
				mbti = "ENTJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ENTP then
				mbti = "ENTP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ESFJ then
				mbti = "ESFJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ESFP then
				mbti = "ESFP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ESTJ then
				mbti = "ESTJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ESTP then
				mbti = "ESTP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.INFJ then
				mbti = "INFJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.INFP then
				mbti = "INFP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.INTJ then
				mbti = "INTJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.INTP then
				mbti = "INTP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ISFJ then
				mbti = "ISFJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ISFP then
				mbti = "ISFP"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ISTJ then
				mbti = "ISTJ"
			elseif agentCfg.MBTI ~= AgentConfig.MBTIType.ISTP then
				mbti = "ISTP"
			end
		end
	end

	return mbti
end

M.OpenSelectPaintingPanel = function(self)
	gPanelManager:CheckShow(gPanelId.COMMON_GAMEPLAY_START_PANEL, {
		playId = LTConfig.GameplayHudDescBeginConfig.Draw,
		refreshRewardCb = refreshRewardCb
	})
end

M.OnSyncBeggarAiPaintingDone = function(self, sourceObjectKey, resultObjectKey, success)
	local paintingPanel = gStoreManager:GetStoreGroup("BeggarPaintingPanelStore")

	if paintingPanel and paintingPanel.isShow then
		paintingPanel:OnSyncBeggarAiPaintingDone(sourceObjectKey, resultObjectKey, success)
	end
end

M.OnSyncBeggarAiPaintingAdd = function(self, info)
end

M.SyncBeggarAiPaintingRemove = function(self, imageIndex)
end

M.GMTestPaintingTask = function(self, drawThemeId, time, pid)
	local testpid = ulong.new(pid, 0)
	local startTime = gLuaDataManager.serverTime
	local endTime = startTime + time

	self:OnSyncNewPaintTask(testpid, drawThemeId, startTime, endTime)
end

gBeggarManager = M
