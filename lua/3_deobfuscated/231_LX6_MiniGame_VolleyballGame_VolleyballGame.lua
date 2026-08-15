local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local UnitModelManager = LX6.Units.UnitModelManager
local SexType = UX.Game.SexType
local Mgr = gVolleyballGameMgr
local Team = Mgr.Team
C_VolleyballGame = DefClass("C_VolleyballGame", C_VolleyballGame)
local M = C_VolleyballGame

function M:ctor(rootNodeGo)
	self.hasDestroy = false
	self.rootNodeTrans = rootNodeGo.transform
	self.characterPivotSetPrefab = nil
	self.curInitCb = nil
	self.charAllLoadedCb = nil
	self.uiAllLoadedCb = nil
	self.charLoadedCount = 0
	self.uiLoadedCount = 0
	self.animatorControllerPath = "Res/MiniGame/Other/VolleyballGame/Animation/VolleyballAnimController.controller"
	self.animatorController = nil
	self.teamChars = {
		[Team.My] = {},
		[Team.Op] = {}
	}
	self.allCharacters = {}
	self.allControllers = {}
	self.theBall = nil
	self.camMgr = nil
	self.playerController = nil
	self.playerCharacter = nil
	self.processTimer = nil
	self.curTopPanel = nil
	self.curGamePanel = nil
	self.rebornPivotList = {}
	self.charactersNode = nil
	self.scores = {
		[Team.My] = 0,
		[Team.Op] = 0
	}
	self.curPossession = nil
	self.needReset = true
	self.lastScoreTeam = nil
	self.lastLaunchChar = nil
	self.halfLength = 4.2
	self.length = 5.5
	self.halfWidth = 3
	self.moveMinDistance = 0.6
	self.settlementDelay = 2.5
	self.closeupTime = 4
	self.failMovePointWeight = 0.6
	self.kickBackFrontMatchTime = 0.1
	self.kickBackFrontFreeTime = 0.8
	self.kickBackSideMatchTime = 0.25
	self.kickBackSideFreeTime = 0.75
	self.kickBackFailMatchTime = 0.3
	self.kickBackFailFreeTime = 0.6
	self.passMatchTime = 0.4
	self.passFreeTime = 0.5
	self.passFailMatchTime = 0.3
	self.passFailFreeTime = 0.6
	self.launchTossTime = 0.9
	self.launchHitTime = 1.5
	self.launchTotalTime = 2.7
	self.launchTossPower = 2
	self.smashAnimTotalTime = 2.25
	self.smashAnimHitTime = 1
	self.smashAnimJumpTime = 0.6
	self.koushaDistance = 1
	self.smashMoveDistance = 6
	self.koushaCheckRange = 0.05
	self.koushaHeight = 2.4
	self.passKoushaCheckDistance = 6
	self.koushaPerfectRandomRange = 1.5
	self.koushaPerfectDistance = 3.5
	self.koushaMiddleRandomRange = 1
	self.koushaMiddleDistance = 2.8
	self.koushaFakeRandomRange = 0.1
	self.koushaFakeDistance = 1.6
	self.koushaFakeJumpPower = 1.5
	self.koushaFakeDuration = 0.6
	self.launchQTEEarlyTime = 0.05
	self.launchQTENormalTime = 0.85
	self.launchQTEPerfectTime = 1
	self.smashQTEEarlyTime = 0.1
	self.smashQTENormalTime = 0.45
	self.smashQTEPerfectTime = 0.6
	self.defenceEnterDistance = 1.3
	self.defenceCheckDistance = 0.6
	self.defenceCheckStartTime = 0.3
	self.defenceCheckEndTIme = 1.1
	self.defenceDelayFreeTime = 1.2
	self.ReflectVerFactor = 4
	self.ReflectHorFactor = 3
end

function M:Init(callback)
	self.curInitCb = callback

	self:InitStaticData()

	function self.charAllLoadedCb()
		self:InitUI()
	end

	function self.uiAllLoadedCb()
		self:OnAllLoaded()
	end

	self:InitReferences(self.rootNodeTrans)
	self:InitCharacters()
end

function M:InitStaticData()
	return
end

function M:InitReferences(rootNodeTrans)
	self.theBall = C_Volleyball.new(rootNodeTrans:Find("Volleyball").gameObject, self)

	self.theBall:Init()

	self.camMgr = C_VolleyballCameraController.new(rootNodeTrans:Find("CameraSet"))

	self.camMgr:Init()

	self.charactersNode = rootNodeTrans:Find("CharactersNode")
	local scenePivotsNode = rootNodeTrans:Find("ScenePivotsNode")
	self.rebornPivotList = scenePivotsNode:Find("RebornPivots"):GetChildren()
	self.characterPivotSetPrefab = scenePivotsNode:Find("CharacterPivotNode").gameObject
end

function M:InitCharacters()
	self.teamChars[Team.My] = {}
	self.teamChars[Team.Op] = {}
	self.loadFinishCount = 0
	self.allCharacters = {}
	self.loadOp = gResourceManager:LoadAssetWithCallBack(self.animatorControllerPath, typeof(UnityEngine.RuntimeAnimatorController), function (loadOp)
		if not self.hasDestroy then
			self.animatorController = loadOp.asset

			self:CreatePlayerCharacter(Team.My, SexType.UnKnow, 86952591, self.rebornPivotList[0])
			self:CreateAICharacter(Team.My, SexType.UnKnow, 86952592, self.rebornPivotList[1])
			self:CreateAICharacter(Team.Op, SexType.UnKnow, 86952593, self.rebornPivotList[2])
			self:CreateAICharacter(Team.Op, SexType.UnKnow, 86952594, self.rebornPivotList[3])
		end
	end)
end

function M:InitUI()
	local function uiFinishCb()
		self.uiLoadedCount = self.uiLoadedCount + 1

		if self.uiLoadedCount == 2 then
			self:OnAllLoaded()
		end
	end

	gPanelManager:CheckShow(gPanelId.S_VOLLEYBALL_TOP_PANEL, {
		myName = gPlayerManager.infoLogin.bindData.name,
		opName = TextScriptTextConfig.GetConfig(89900892).Text,
		curLuaGame = self,
		finishCb = uiFinishCb
	})
	gPanelManager:CheckShow(gPanelId.S_VOLLEYBALL_PANEL, {
		luaPlayerController = self.playerController,
		finishCb = uiFinishCb
	})
end

function M:CreatePlayerCharacter(team, sexType, modelId, rebornPivot)
	self:CreateCharacter(team, sexType, modelId, rebornPivot, function (character)
		character.isPlayer = true
		self.playerCharacter = character
		local controller = C_VolleyballPlayerController.new(character, self)
		self.playerController = controller
		character.controller = controller

		table.insert(self.allControllers, controller)
	end, gBattleSpiritMgr.currentSpiritTemplateId)
end

function M:CreateAICharacter(team, sexType, modelId, rebornPivot)
	self:CreateCharacter(team, sexType, modelId, rebornPivot, function (character)
		local controller = C_VolleyballAIController.new(character, self)
		character.controller = controller

		table.insert(self.allControllers, controller)
	end)
end

function M:CreateCharacter(team, sexType, modelId, rebornPivot, callback, cardId)
	gCS.UnitsManager:GetDialogModel(function (baseUnit, _)
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)
		UnitModelManager.SetShadow(baseUnit, true)
		baseUnit:SetDynamicBone(true, true)

		local characterNode = baseUnit.ModelSlot.transform

		characterNode:SetParent(self.charactersNode)
		characterNode.gameObject:SetActive(false)

		local character = C_VolleyballCharacter.new(baseUnit.ModelSlot.gameObject, self)
		character.curTeam = team
		character.rebornPivot = rebornPivot
		local pivotSetGo = GameObject.Instantiate(self.characterPivotSetPrefab, Vector3.zero, Quaternion.identity, characterNode)

		pivotSetGo:SetActive(true)

		character.pivotSet = pivotSetGo.transform
		character.launchHandPivot = baseUnit.ModelSlot.handl
		character.animator = character.transform:GetChild(0):GetComponent(typeof(UnityEngine.Animator))
		character.animator.runtimeAnimatorController = self.animatorController
		local playerNode = characterNode.transform:Find("player")
		character.rootMotion = playerNode:GetOrAddComponent(typeof(L18.VolleyballGame.VolleyballRootMotion))

		table.insert(self.allCharacters, character)

		if callback then
			callback(character)
		end

		self.loadFinishCount = self.loadFinishCount + 1

		if self.loadFinishCount == 4 and self.charAllLoadedCb then
			self.charAllLoadedCb()
		end
	end, sexType, modelId, false, true, true, cardId)
end

function M:OnAllLoaded()
	for _, char in pairs(self.allCharacters) do
		table.insert(self.teamChars[char.curTeam], char)

		char.gameObject.name = char.curTeam .. "_" .. #self.teamChars[char.curTeam]
	end

	for _, char in pairs(self.allCharacters) do
		char:Init()
		char.gameObject:SetActive(true)
	end

	for _, controller in pairs(self.allControllers) do
		controller:Init()
	end

	self:OnInitFinish()
end

function M:OnInitFinish()
	if self.curInitCb then
		self.curInitCb()
	end
end

function M:ResetGame()
	self.lastScoreTeam = Team.My
	self.scores[Team.My] = 0
	self.scores[Team.Op] = 0

	self:NextRound()
end

function M:NextRound()
	self.needReset = false
	self.curPossession = Team.My

	self.camMgr:EndCloseUp()
	self:ResetBall()
	self:ResetCharacters()
	self:ResetLaunchChar()
end

function M:ResetBall()
	self.theBall:ResetPosAndVel()

	self.theBall.localDestination = self.theBall.transform.position
end

function M:ResetCharacters()
	for _, char in pairs(self.allCharacters) do
		char:OnNextRoundStart()
	end
end

function M:ResetLaunchChar()
	local winTeamChar = self.teamChars[self.lastScoreTeam]
	local validList = {}

	for _, char in pairs(winTeamChar) do
		if char ~= self.lastLaunchChar then
			table.insert(validList, char)
		end
	end

	local targetChar = validList[math.random(1, #validList)]
	self.lastLaunchChar = targetChar

	targetChar:SwitchToPreLaunchState()
end

function M:ChangePossession(team)
	self.curPossession = team

	for _, controller in pairs(self.allControllers) do
		controller:OnPossessionChange(team)
	end
end

function M:BallTouchGround(touchPos)
	if self.needReset then
		return
	end

	self:GetScore(touchPos.z >= 0 and Team.My or Team.Op)
end

function M:GetScore(scoreTeam)
	self.needReset = true
	self.scores[scoreTeam] = self.scores[scoreTeam] + 1
	self.lastScoreTeam = scoreTeam

	self:ChangeScoreText()

	for _, char in pairs(self.allCharacters) do
		char:OnSettlement()
	end

	self.playerController.gamePanel:ChangeButtonInteractable(false)
	self:StartProcessTimer(function ()
		self:Settlement()
	end, self.settlementDelay)
end

function M:Settlement()
	local targetChar = self.lastScoreTeam == Team.My and self.teamChars[Team.My][math.random(1, #self.teamChars[Team.My])] or self.teamChars[Team.Op][math.random(1, #self.teamChars[Team.Op])]

	self:SetCloseUpOnCharacter(targetChar)
	self:StartProcessTimer(function ()
		self:OnCloseUpEnd()
	end, self.closeupTime)
end

function M:SetCloseUpOnCharacter(character)
	self:HideOrShowAllObjects(false, character)
	character:SetRandomCloseUpTrigger()
	self.camMgr:StartCloseUp(character.transform)
end

function M:OnCloseUpEnd()
	self:HideOrShowAllObjects(true)

	if self:isNeedContinue() then
		self:NextRound()
	else
		Mgr:OnGameEnd(self.scores[Team.Op] < self.scores[Team.My])
	end
end

function M:DestroyGame()
	self.hasDestroy = true

	self.theBall:OnDestroy()
	gResourceManager:UnloadAssetLoadOp(self.loadOp)

	for _, char in pairs(self.allCharacters) do
		char:OnDestroy()
	end

	for _, controller in pairs(self.allControllers) do
		controller:OnDestroy()
	end

	if self.rootNodeTrans ~= nil then
		self.rootNodeTrans.gameObject:Destroy()
	end

	if self.processTimer then
		self.processTimer:Stop()

		self.processTimer = nil
	end
end

function M:HideOrShowAllObjects(isShow, exceptChar)
	local goList = {}

	for _, char in pairs(self.allCharacters) do
		if char ~= exceptChar then
			table.insert(goList, char.gameObject)
		end
	end

	table.insert(goList, self.ballNetView)

	for _, go in pairs(goList) do
		go:SetActive(isShow)
	end
end

function M:isNeedContinue()
	return self.scores[Team.My] <= 5 and self.scores[Team.Op] <= 5 or math.abs(self.scores[Team.My] - self.scores[Team.Op]) < 2
end

function M:ChangeScoreText()
	self.curTopPanel:RefreshScore(self.scores[Team.My], self.scores[Team.Op])
end

function M:GetRectByTeam(team)
	if team == Team.My then
		return {
			xMin = -self.halfWidth,
			yMin = -self.length,
			xMax = self.halfWidth,
			yMax = -self.moveMinDistance
		}
	else
		return {
			xMin = -self.halfWidth,
			yMin = -self.moveMinDistance,
			xMax = self.halfWidth,
			yMax = self.length
		}
	end
end

function M:StartProcessTimer(func, time)
	self:StopProcessTimer()

	self.processTimer = Timer.New(function ()
		if func then
			func()
		end
	end, time):Start()
end

function M:StopProcessTimer()
	if self.processTimer then
		self.processTimer:Stop()
	end
end
