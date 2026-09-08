-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTrialPanelStore.lua
-- Decompiled from: 00793_PoliceTrialPanelStore.lua_c3cdb7a72f14.luajit

C_PoliceTrialPanelStore = DefClass("C_PoliceTrialPanelStore", C_PoliceTrialPanelStore, C_StoreGroup)
GroupName2Class.PoliceTrialPanelStore = C_PoliceTrialPanelStore
local M = C_PoliceTrialPanelStore
local PoliceConfig = LTConfig.PoliceConfig
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.pcKey1Id = 15
	self.mgr = gPoliceJobManager.panelMgr
	self.fuxiBridge = L50.Police.PoliceBridge
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = {
		[">I\\x85\\x9a\\x8fD"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.drawCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = nil
	self.drawCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self:InitRPSBattleInfo(data)
	self:SwitchToFixCamera()
	Timer.New(function ()
		gBlackScreenManager:CloseTransition(gBlackScreenId.POLICE_EXAMINE)
	end, 1):Start()
end

M.OnClose = function(self)
	self.isShow = false
	self.curResult = nil

	self.mgr:TriggerSpoonEndTrial(self.curSettlement)

	self.curSettlement = nil

	gPoliceJobManager.cs:DestroyTrialUnit()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.DIALOG_END] = function (eventId, FirstDialogId)
			if FirstDialogId ~= self.currentWaitDialog then
				self:OnWaitDialogEnd()
			end
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.optionList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderOptionListItem")
	self.bindData.enemyOptionList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderEnemyOptionListItem")
	self.bindData.optionList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickOptionList")
end

M.OnClickBackBtn = function(self)
	if self.curSettlement then
		return
	end

	slot1 = gPanelManager

	slot1:Close(gPanelId.POLICE_TRIAL_PANEL)

	slot1 = gClientToGameDelegate

	slot1:AskInterruptInterrogation(self.caseId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.OnSimpleRenderOptionListItem = function(self, btn, index)
	local data = self.playerCards[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = PoliceConfig.PoliceRPSCardIcon[data.CardType + 1]
	store.name = PoliceConfig.PoliceRPSCardName[data.CardType + 1]
	slot5 = store.starList

	slot5:SetSimpleList(data.StarLevel)

	store.keyText = tostring(index + 1)

	btn:SetPCKeyInfoWithOutTip(self.pcKey1Id + index)

	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	btn:SetEnabledTooltip(isMobile, 0)
	btn:SetEnabledTooltip(not isMobile, 1)

	btn.luaRenderTooltip = function(popBtn, popIns, toolIndex)
		local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

		if not popStore then
			return
		end

		local hit = data.StarLevel * 10
		local formatStr = PoliceConfig["PoliceRPSCardDes" .. data.CardType]
		popStore.text = string.format(formatStr, hit)
	end
end

M.OnSimpleClickOptionList = function(self, btn, index)
	local card = self.playerCards[index + 1]

	if not card then
		return
	end

	self.DoInterrogationOption(self, card)
end

M.OnSimpleRenderEnemyOptionListItem = function(self, btn, index)
	btn.interactable = false
	local data = self.npcCards[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = PoliceConfig.PoliceRPSCardIcon[data.CardType + 1]

	store.starList:SetSimpleList(data.StarLevel)
end

M.InitRPSBattleInfo = function(self, data)
	self.curSettlement = nil
	self.waitOptionResult = false
	self.currentWaitDialog = nil
	self.caseId = data.CaseId
	local battleInfo = data.BattleInfo
	self.maxPlayerHp = battleInfo.Player.HP
	self.maxEnemyHp = battleInfo.Npc.HP
	self.curRound = battleInfo.Round
	self.playerHp = battleInfo.Player.HP
	self.enemyHp = battleInfo.Npc.HP
	self.enemyCards = battleInfo.Npc.Cards
	local caseInfo = self.mgr:GetCaseInfo(self.caseId)
	self.npcCharacter = 0
	self.npcSex = 0
	self.npcIsFake = false
	self.npcCrime = 0

	if caseInfo then
		local agentCfg = LTConfig.AgentConfig.GetConfig(caseInfo.NpcId)

		if agentCfg then
			self.bindData.enemyHeadIcon = agentCfg.HeadIcon
			self.bindData.enemyName = agentCfg.Name
			self.npcCharacter = agentCfg.Personality
			self.npcSex = agentCfg.SexType ~= UX.Game.SexType.Male and 1 or 2
		end

		self.npcIsFake = caseInfo.IsFakePerson
		local seriousCrime, crimes = self.mgr:GetRandomSeriousFinesByCaseId(self.caseId)
		self.npcCrime = seriousCrime or 0
	end

	local curTid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(curTid)

	if spirit then
		self.bindData.playerHeadIcon = spirit.config.SHeadIconID
		self.bindData.playerName = spirit.config.Name
	end

	self.bindData.round = self.curRound

	self.bindData.playerHp:ResetValue(self.playerHp, 0, 0, self.maxPlayerHp)
	self.bindData.enemyHp:ResetValue(self.enemyHp, 0, 0, self.maxEnemyHp)

	self.bindData.playerHpValue = self.playerHp
	self.bindData.enemyHpValue = self.enemyHp
	self.playerCards = {}

	for i = 1, battleInfo.Player.Cards.Count do
		table.insert(self.playerCards, battleInfo.Player.Cards[i])
	end

	self.npcCards = {}
	self.npcDefaultCards = {}

	for i = 1, battleInfo.Npc.Cards.Count do
		table.insert(self.npcCards, battleInfo.Npc.Cards[i])
		table.insert(self.npcDefaultCards, battleInfo.Npc.Cards[i])
	end

	self.bindData.optionList:SetSimpleList(#self.playerCards)
	self.bindData.enemyOptionList:SetSimpleList(#self.npcCards)

	self.isHali = caseInfo.NpcId ~= LTConfig.PoliceConfig.TaskTrailHarryAgentid

	if self.isHali then
		self.ShowHaliOpenDialog(self)
	else
		self.ShowNormalOpenDialog(self)
	end
end

M.ShowNormalOpenDialog = function(self)
	self.currentWaitDialog = PoliceConfig.PoliceTrailOpenningDialog

	gDialogManager:ShowGeneralDialog(PoliceConfig.PoliceTrailOpenningDialog, gDialogSource.Police)
end

M.ShowHaliOpenDialog = function(self)
	gDialogManager:ShowGeneralDialog(PoliceConfig.TaskTrailHarryOpenningDialogRPS, gDialogSource.Police)
end

M.DoInterrogationOption = function(self, playerCard)
	if self.waitOptionResult then
		return
	end

	self.waitOptionResult = true
	slot2 = gClientToGameDelegate

	slot2:AskRPSInterrogationSelectOption(self.caseId, playerCard).Callback = function (errorId, result)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			self.waitOptionResult = false

			return
		end

		self.waitOptionResult = false

		if self.isShow then
			self:DoInterrogationResult(result)
		end
	end
end

M.DoInterrogationResult = function(self, result)
	self.curResult = result
	local playerAction = 0

	if result.PlayerCard.CardType == 3 then
		playerAction = result.PlayerCard.CardType * 5 + result.PlayerCard.StarLevel
	end

	local suspectAction = 0

	if result.NpcCard.CardType == 3 then
		suspectAction = result.NpcCard.CardType * 5 + result.NpcCard.StarLevel
	end

	self.fuxiBridge.InterrogationRps(self.npcCrime, self.npcCharacter, self.npcSex, self.npcIsFake, playerAction, suspectAction, function (data)
		if self.isShow then
			self:ShowInterrogationResult(data)
		end
	end)
end

M.ShowInterrogationResult = function(self, data)
	if self.curResult then
		self.playerMsg = data and data.PlayerMsg or "player AI Error"
		self.npcMsg = data and data.SuspectMsg or "Npc AI Error"
		local result = self.curResult
		self.curResult = nil
		self.curRound = self.curRound + 1
		self.bindData.stateCtrl = self.stateCtrlEnum.Battle
		local decreasePlayerHp = result.PlayerHP - self.playerHp
		self.playerHp = result.PlayerHP
		self.bindData.playerBubbleHp = decreasePlayerHp == 0 and decreasePlayerHp or ""
		local decreaseEnemyHp = result.NpcHP - self.enemyHp
		self.enemyHp = result.NpcHP
		self.bindData.enemyBubbleHp = decreaseEnemyHp == 0 and decreaseEnemyHp or ""

		self.bindData.playerHp:ProgressToValue(result.PlayerHP)

		self.bindData.playerHpValue = result.PlayerHP

		self.bindData.enemyHp:ProgressToValue(result.NpcHP)

		self.bindData.enemyHpValue = result.NpcHP
		self.bindData.playerBattleOptionIcon = PoliceConfig.PoliceRPSCardIcon[result.PlayerCard.CardType + 1]
		self.bindData.enemyBattleOptionIcon = PoliceConfig.PoliceRPSCardIcon[result.NpcCard.CardType + 1]

		self.bindData.playerBattleOptionStarList:SetSimpleList(result.PlayerCard.StarLevel)
		self.bindData.enemyBattleOptionStarList:SetSimpleList(result.NpcCard.StarLevel)

		self.curSettlement = result.Settlement
		self.bindData.drawCtrl = result.RoundResult ~= UX.Game.PoliceRPSRoundResult.Draw and self.drawCtrlEnum._true or self.drawCtrlEnum._false

		if result.RefreshedCards then
			self.playerCards = {}

			for i = 1, result.RefreshedCards.Count do
				table.insert(self.playerCards, result.RefreshedCards[i])
			end

			self.npcCards = {}

			for i = 1, #self.npcDefaultCards do
				table.insert(self.npcCards, self.npcDefaultCards[i])
			end
		else
			for i = 1, #self.playerCards do
				if self.playerCards[i].CardType ~= result.PlayerCard.CardType then
					table.remove(self.playerCards, i)

					break
				end
			end

			for i = 1, #self.npcCards do
				if self.npcCards[i].CardType ~= result.NpcCard.CardType then
					table.remove(self.npcCards, i)

					break
				end
			end
		end

		self.bindData.optionList:SetSimpleList(#self.playerCards)
		self.bindData.enemyOptionList:SetSimpleList(#self.npcCards)

		if decreasePlayerHp == 0 then
			self.bindData.playerBubbleAnim:Play()
		end

		if decreaseEnemyHp == 0 then
			self.bindData.enemyBubbleAnim:Play()
		end

		self:ShowPlayerDialog()

		self.bindData.enemyCardName = PoliceConfig.PoliceRPSCardName[result.NpcCard.CardType + 1]
		self.bindData.playerCardName = PoliceConfig.PoliceRPSCardName[result.PlayerCard.CardType + 1]
		local isSilence = result.PlayerCard.CardType ~= 3
		local isEnemySilence = result.NpcCard.CardType ~= 3

		if isEnemySilence or isSilence then
			self.bindData.battleAnim:Play(isSilence and "vx_S_PoliceTrialPanel_battle_me_slient" or "vx_S_PoliceTrialPanel_battle_Enemy_slient")
		elseif result.RoundResult ~= UX.Game.PoliceRPSRoundResult.PlayerWin then
			self.bindData.battleAnim:Play("vx_S_PoliceTrialPanel_battle_me_win")
		elseif result.RoundResult ~= UX.Game.PoliceRPSRoundResult.NpcWin then
			self.bindData.battleAnim:Play("vx_S_PoliceTrialPanel_battle_Enemy_win")
		elseif result.RoundResult ~= UX.Game.PoliceRPSRoundResult.Draw then
			self.bindData.battleAnim:Play("vx_S_PoliceTrialPanel_battle_Draw")
		else
			gCS.LuaUtils.SampleTargetAnimation(self.bindData.battleAnim, "vx_S_PoliceTrialPanel_battle_me_win", 0)
		end
	end
end

M.NextRound = function(self)
	if self.curSettlement then
		local settlement = self.curSettlement

		self.mgr:DoTrialResult(settlement, self.npcCharacter, self.npcSex, self.npcIsFake, true, self.isHali)
	else
		self.bindData.round = self.curRound
		self.bindData.stateCtrl = self.stateCtrlEnum.Normal

		self.bindData.optionList:SetNavSelectToTop(true)
	end
end

M.ShowPlayerDialog = function(self)
	if self.playerMsg then
		self.currentWaitDialog = PoliceConfig.PoliceTrailPlayerDialog
		local param = gDialogManager:CreateDialogParam()
		param.CustomStr = self.playerMsg

		gDialogManager:ShowGeneralDialog(self.currentWaitDialog, gDialogSource.Police, nil, param)
	else
		self.NextRound(self)
	end
end

M.ShowNpcDialog = function(self)
	if self.npcMsg then
		self.currentWaitDialog = PoliceConfig.PoliceTrailNpcDialog
		local param = gDialogManager:CreateDialogParam()
		param.CustomStr = self.npcMsg

		gDialogManager:ShowGeneralDialog(self.currentWaitDialog, gDialogSource.Police, nil, param)
	end
end

M.OnWaitDialogEnd = function(self)
	if self.currentWaitDialog ~= PoliceConfig.PoliceTrailPlayerDialog then
		self.ShowNpcDialog(self)
	elseif self.currentWaitDialog ~= PoliceConfig.PoliceTrailOpenningDialog then
		PoliceJobUtils.ShowTrailAIDialog(self.mgr.TRIAL_DIALOG_TYPE.RPS_START, self.npcCharacter, self.npcSex, self.npcIsFake)
	else
		self.NextRound(self)
	end
end

M.SwitchToFixCamera = function(self)
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("PoliceTrialPanel")

	if not cmRegister then
		return
	end

	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans.TransformPoint(playerTrans, PoliceConfig.PoliceTrailCameraPos[1], PoliceConfig.PoliceTrailCameraPos[2], PoliceConfig.PoliceTrailCameraPos[3])
	local dir = Quaternion.Euler(PoliceConfig.PoliceTrailCameraRot[1], PoliceConfig.PoliceTrailCameraRot[2], PoliceConfig.PoliceTrailCameraRot[3]) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans.TransformDirection(playerTrans, dir)).eulerAngles
	local cameraName = "FixCam1"
	local cm = cmRegister.GetVcamByName(cmRegister, cameraName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, PoliceConfig.PoliceTrailCameraFoV)
	cmRegister:EnableVCamera(cameraName, LX6.Cinemachine.EVcamPriority.Panel)
end
