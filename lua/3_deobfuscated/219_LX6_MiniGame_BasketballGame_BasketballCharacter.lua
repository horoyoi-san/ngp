local UnitModelManager = LX6.Units.UnitModelManager
local FightManager = LX6.Engine.FightManager
local static_props = {
	SHOOT_TYPE = {
		THREE = 6,
		ZERO_C = 3,
		TWO_B = 5,
		ZERO_B = 2,
		TWO_A = 4,
		ZERO_A = 1
	},
	CHARACTER_STATUS = {
		MOVE = 4,
		END = 6,
		RECEIVE_BALL = 2,
		SHOOT = 5,
		IDLE = 1,
		READY = 3
	},
	GAME_STATUS = {
		PAUSE = 3,
		END = 3,
		START = 2,
		NONE = 1
	}
}
gBasketballCharacter = DefClass("BasketballCharacter", gBasketballCharacter, nil, static_props)
local BasketballCharacter = gBasketballCharacter

function BasketballCharacter:ctor(args)
	self:InitData(args)
	self:InitCharacter()
end

function BasketballCharacter:InitCharacter()
	self:InitAnimatorController(function ()
		self:LoadCharacterModel()
	end)
end

function BasketballCharacter:OnCharacterLoadCompleted(baseUnit)
	if self.hasDestroy then
		baseUnit = baseUnit and baseUnit:DestroyUnit(true)

		return
	end

	self.baseUnit = baseUnit
	self.transform = baseUnit.ModelSlot.transform

	baseUnit:SetDynamicBone(true, true)
	UnitModelManager.SetShadow(baseUnit, true)
	self:InitNodes()
	self:LookAtLanWangCenter()
	self:InitPosition()
	self:InitAnimationEvents()
	self.stimMgr:AddPlayer(self.playerIndex, self.transform)
end

function BasketballCharacter:InitPosition()
	local targetPosition = self:GetCurrentRackInfo().slotPosition
	local offsetPosition = targetPosition + Vector3.Fetch(0, 1, 0)
	self.transform.position = FightManager.GetPhysicsLandPosWithNormalGravity(offsetPosition)
end

function BasketballCharacter:InitNodes()
	self.playerNode = self.transform:Find("player")
	self.rootMotion = self.playerNode.gameObject:GetOrAddComponent(typeof(L18.MiniGame.MiniRootMotion))
	self.rootMotion.enabled = false
	self.animator = self.playerNode:GetOrAddComponent(typeof(UnityEngine.Animator))
	self.animator.runtimeAnimatorController = self.animatorController
	self.animationEvents = self.playerNode.gameObject:GetOrAddComponent(typeof(L18.MiniGame.AnimationEventLuaReceiver))
	self.handPoint = self.baseUnit.ModelSlot.handr
	local basketballShootConfig = self:GetBasketballShootConfig()

	if basketballShootConfig.WeaponResourceId then
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(self.baseUnit, true)

		local weaponNode = self:FindRecursively(self.playerNode.transform, basketballShootConfig.WeaponResourceId)

		if weaponNode then
			self.weaponAnimator = weaponNode.gameObject:GetOrAddComponent(typeof(UnityEngine.Animator))
			self.weaponAnimator.runtimeAnimatorController = self.animatorWeaponController
		end
	else
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(self.baseUnit, false)
	end
end

function BasketballCharacter:FindRecursively(transform, nameStartsWith)
	if string.sub(transform.gameObject.name, 1, #nameStartsWith) == nameStartsWith then
		return transform
	end

	for i = 0, transform.childCount - 1 do
		local child = transform:GetChild(i)
		local found = self:FindRecursively(child, nameStartsWith)

		if found ~= nil then
			return found
		end
	end
end

function BasketballCharacter:InitAnimationEvents()
	self.animationEvents:RegisterEvent("BallGrabbed", function ()
		if self.gameStatus == BasketballCharacter.GAME_STATUS.END then
			return
		end

		if gClientUtils.IsNil(self.handPoint) then
			print_error("BasketballCharacter: handPoint is nil!", gClientUtils.NotNil(self.transform) and self.transform.name)

			return
		end

		gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_basketball_catch, self.handPoint.position)

		self.currentBasketballIndex = self.currentBasketballIndex + 1
		local currentBasketball = self:GetCurrentBasketball()

		if currentBasketball then
			self.currentBasketball = currentBasketball

			self.currentBasketball:SetRigidbodyKinematic(true)
			self.currentBasketball.transform:SetParent(self.handPoint)

			self.currentBasketball.transform.localPosition = Vector3.zero

			self:PlayBallRollsDownAnimation()
		end
	end)
	self.animationEvents:RegisterEvent("BeginRun", function ()
		self.rootMotion.enabled = true
		self.rootMotion.Rotate = true
		self.rootMotion.Move = true
		local nextRackIndex = nil

		if self.currentBasketballIndex == 0 then
			nextRackIndex = self.currentRackIndex
		else
			nextRackIndex = self.currentRackIndex + 1
		end

		local nextRack = self.basketballRackList[nextRackIndex]
		local nextPosition = nextRack.slotPosition
		self.beginRunCo = coroutine.start(function ()
			self.rootMotion.Rotate = false
			local endFrame = 45

			while true do
				coroutine.step()

				local frameNow = self.rootMotion:MatchTargetByFrame(nextPosition, 0, endFrame)

				if endFrame <= frameNow then
					break
				end
			end

			self.rootMotion.Move = false
			local pos = self.transform.position
			pos.x = nextPosition.x
			pos.z = nextPosition.z
			self.transform.position = pos
		end)
	end)
	self.animationEvents:RegisterEvent("Rotate", function ()
		self:LookAtLanWangCenter(1)
	end)
	self.animationEvents:RegisterDefaultEventHandler(function (eventName)
		if string.sub(eventName, 1, 7) == "Rotate " then
			local param = string.sub(eventName, 8)
			local time = tonumber(param)

			if time ~= nil then
				self:LookAtLanWangCenter(time)
			end
		end
	end)
end

function BasketballCharacter:SetAnimatorBool(key, value)
	local animatorList = self:GetAnimatorList()

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetBool(key, value)
		end
	end
end

function BasketballCharacter:SetAnimatorInteger(key, value)
	local animatorList = self:GetAnimatorList()

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetInteger(key, value)
		end
	end
end

function BasketballCharacter:GetAnimatorList()
	return {
		self.animator,
		self.weaponAnimator
	}
end

function BasketballCharacter:PlayShootAnimation()
	self:SetAnimatorBool(self.animConst.bCancelShoot, false)
	self:PlayAnimationByTriggerName(self.animConst.tPrepareShot)

	if self:CheckCurrentRackHasBasketball() then
		self:SetAnimatorInteger(self.animConst.iAfterShoot, self.animConst.AfterShootEnum.takeBall)
	elseif self.currentRackIndex + 1 <= #self.basketballRackList then
		self:SetAnimatorInteger(self.animConst.iAfterShoot, self.animConst.AfterShootEnum.run)

		self.rootMotion.Rotate = false
	else
		self:SetAnimatorInteger(self.animConst.iAfterShoot, self.animConst.AfterShootEnum.idle)
	end
end

function BasketballCharacter:InitAnimatorController(callback)
	local basketballShootConfig = self:GetBasketballShootConfig()
	local animatorControllerPath = basketballShootConfig.AnimatorControllerPath
	self.asyncList = gAsyncActionList.new()

	self.asyncList:Add(function (onFinish)
		self.loadOp = gResourceManager:LoadAssetWithCallBack(animatorControllerPath, typeof(UnityEngine.AnimatorOverrideController), function (loadOp)
			if self.hasDestroy then
				return
			end

			self.animatorController = loadOp.asset

			onFinish()
		end)
	end)

	if basketballShootConfig.WeaponAnimatorControllerPath then
		self.asyncList:Add(function (onFinish)
			self.loadOp = gResourceManager:LoadAssetWithCallBack(basketballShootConfig.WeaponAnimatorControllerPath, typeof(UnityEngine.AnimatorOverrideController), function (loadOp)
				if self.hasDestroy then
					return
				end

				self.animatorWeaponController = loadOp.asset

				onFinish()
			end)
		end)
	end

	self.asyncList:Start(function ()
		callback()
	end)
end

function BasketballCharacter:LookAtLanWangCenter(duration)
	duration = duration or 0
	local positionX = self.lanWangCenterPoint.position.x
	local positionZ = self.lanWangCenterPoint.position.z

	self.playerNode:DOLookAt(Vector3.Fetch(positionX, 0, positionZ), duration)
end

function BasketballCharacter:InitData(args)
	self.basketballRackList = args.basketballRackList
	self.lanWangCenterPoint = args.lanWangCenterPoint
	self.virtualCamera = args.virtualCamera
	self.id = args.id
	self.pid = args.pid
	self.currentRackIndex = 1
	self.currentBasketballIndex = 0
	self.score = 0
	local basketballShootConfig = self:GetBasketballShootConfig()
	self.earlyRangePercent = basketballShootConfig.EarlyRange
	self.soSoRangePercent = basketballShootConfig.SoSoRange
	self.goodRangePercent = basketballShootConfig.GoodRange
	self.perfectRangePercent = basketballShootConfig.PerfectRange
	self.lateRangePercent = basketballShootConfig.LateRange
	self.totalShootTweenTime = basketballShootConfig.ShootTime
	self.countdown = LTConfig.PoiGameConfig.Basket_Time
	self.addTimeInterval = LTConfig.PoiGameConfig.Basket_AddTime

	self:InitAnimationConst()

	self.gameStatus = BasketballCharacter.GAME_STATUS.NONE
	self.shootTypes = {
		{
			BasketballCharacter.SHOOT_TYPE.THREE
		},
		{
			BasketballCharacter.SHOOT_TYPE.TWO_A,
			BasketballCharacter.SHOOT_TYPE.TWO_B
		},
		{
			BasketballCharacter.SHOOT_TYPE.ZERO_A,
			BasketballCharacter.SHOOT_TYPE.ZERO_B,
			BasketballCharacter.SHOOT_TYPE.ZERO_C
		}
	}
	local perfectBeginPercent = self.earlyRangePercent + self.soSoRangePercent + self.goodRangePercent
	local perfectEndPercent = perfectBeginPercent + self.perfectRangePercent
	self.perfectBeginTime = self.totalShootTweenTime * perfectBeginPercent
	self.perfectEndTime = self.totalShootTweenTime * perfectEndPercent
	self.perfectPercent = perfectBeginPercent + self.perfectRangePercent / 2
	self.perfectTime = self.totalShootTweenTime * self.perfectPercent
	self.stimMgr = args.stimMgr
end

function BasketballCharacter:StartGame()
	self.gameStatus = BasketballCharacter.GAME_STATUS.START

	self:PlayAnimationByTriggerName(self.animConst.tTakeBall)
	self:StartCountdown()
end

function BasketballCharacter:StartCountdown()
	self:SendRefreshViewMessage()

	self.countdownCoroutine = coroutine.start(function ()
		while self.countdown > 0 do
			if self.gameStatus == BasketballCharacter.GAME_STATUS.START then
				coroutine.wait(1)

				self.countdown = self.countdown - 1

				self:SendRefreshViewMessage()
			else
				coroutine.wait(0.1)
			end
		end

		self:GameEnd()
	end)
end

function BasketballCharacter:PlayBallRollsDownAnimation()
	if self:CheckCurrentRackHasBasketball() then
		local currentRackInfo = self:GetCurrentRackInfo()
		local startBasketballIndex = self.currentBasketballIndex + 1
		local targetIndex = 1

		for basketballIndex = startBasketballIndex, 5 do
			local basketball = currentRackInfo.basketballList[basketballIndex]
			local targetPosition = currentRackInfo.basketballList[targetIndex].initPosition

			basketball:DoRollsDownAnimation(targetPosition)

			targetIndex = targetIndex + 1
		end
	end
end

function BasketballCharacter:PlayAnimationByTriggerName(triggerName)
	self:ResetAllTrigger()

	local animatorList = self:GetAnimatorList()

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetTrigger(triggerName)
		end
	end
end

function BasketballCharacter:ResetAllTrigger()
	local animatorList = self:GetAnimatorList()

	for _, animator in ipairs(animatorList) do
		if animator then
			animator:ResetTrigger(self.animConst.tPrepareShot)
			animator:ResetTrigger(self.animConst.tTakeBall)
			animator:ResetTrigger(self.animConst.tWin)
			animator:ResetTrigger(self.animConst.tLose)
			animator:ResetTrigger(self.animConst.tGameEnd)
			animator:ResetTrigger(self.animConst.tReset)
		end
	end
end

function BasketballCharacter:GetCurrentBasketball()
	local currentRackInfo = self:GetCurrentRackInfo()

	return currentRackInfo.basketballList[self.currentBasketballIndex]
end

function BasketballCharacter:GetCurrentRackInfo()
	return self.basketballRackList[self.currentRackIndex]
end

function BasketballCharacter:CheckCurrentRackHasBasketball()
	local currentRack = self.basketballRackList[self.currentRackIndex]
	local nextBasketballIndex = self.currentBasketballIndex + 1

	return currentRack and currentRack.basketballList[nextBasketballIndex] ~= nil
end

function BasketballCharacter:StartShoot(shootType, performTweenTime)
	self:StartShootPerform(shootType, performTweenTime)
end

function BasketballCharacter:OnExecuteShoot(shootType)
	gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_basketball_shoot, self.handPoint.position)

	local ballTrans = self.currentBasketball.transform

	self.stimMgr:OnBallShoot(self.playerIndex, ballTrans)
end

function BasketballCharacter:StartShootPerform(shootType)
	local isConflict = self:CheckShootConflict()

	if isConflict then
		shootType = BasketballCharacter.SHOOT_TYPE.ZERO_C or shootType
	end

	self.currentBasketball.transform:SetParent(nil)

	local basketballType = self.currentBasketball.basketballType
	self.shootTime = Time.time

	self:OnExecuteShoot(shootType)

	local isValidTime = self.countdown > 0
	local hasNextBall = self:CheckCurrentRackHasBasketball()

	self.currentBasketball:ExecuteBasketballShoot(shootType, function ()
		if self.hasDestroy then
			return
		end

		if isValidTime then
			self:ExecuteAfterShootLogic(shootType, basketballType, isValidTime)
		end

		if self.gameStatus == BasketballCharacter.GAME_STATUS.END then
			return
		end

		if not hasNextBall then
			self:StartMoveNext()
		end
	end)

	self.currentBasketball = nil
end

function BasketballCharacter:CheckCanShoot()
	return self.gameStatus == BasketballCharacter.GAME_STATUS.START and self.currentBasketball and self:IsPlayAnimation(self.animConst.sSquatWithBall)
end

function BasketballCharacter:ExecuteAfterShootLogic(shootType, basketballType, isValidTime)
	local score = gBasketballGameUtils.GetCurOriginalScoreByType(shootType)
	local resultScore, addBonus = gBasketballGameUtils.GetCurResultScore(basketballType, score)

	if score > 0 and basketballType == gBasketball.BASKETBALL_TYPE.TIME and self.countdown > 0 then
		self.countdown = self.countdown + self.addTimeInterval
	end

	self.score = self.score + resultScore

	self:SendRefreshViewMessage(shootType, basketballType, score, isValidTime, addBonus)
	self:SendOnBallHitStim(shootType)
end

function BasketballCharacter:SendOnBallHitStim(shootType)
	self.stimMgr:OnBallHit(self.playerIndex)

	if shootType == gBasketballCharacter.SHOOT_TYPE.THREE then
		self.stimMgr:OnPerfectHit(self.playerIndex)
	end
end

function BasketballCharacter:StartMoveNext()
	if self.currentRackIndex + 1 > #self.basketballRackList then
		self:GameEnd()

		return
	end

	self.currentRackIndex = self.currentRackIndex + 1
	self.currentBasketballIndex = 0
end

function BasketballCharacter:GetShootTypeByHitRateList(hitRateList)
	local randomValue = UnityEngine.Random.Range(0, 1)
	local tmpRatioValue = 0
	local hitRatioCount = #hitRateList

	math.randomseed(os.time())

	for index = 1, hitRatioCount do
		tmpRatioValue = tmpRatioValue + hitRateList[index]

		if randomValue <= tmpRatioValue then
			local shootTypeList = self.shootTypes[index]
			local randomIndex = math.random(#shootTypeList)

			return shootTypeList[randomIndex]
		end
	end
end

function BasketballCharacter:Destroy()
	self:ClearCoroutines()

	self.animatorController = nil
	self.asyncList = self.asyncList and self.asyncList:Stop()
	self.hasDestroy = true
	self.transform = nil
	self.animationEvents = GameObject.Destroy(self.animationEvents)
	self.rootMotion = GameObject.Destroy(self.rootMotion)
	self.handPoint = nil
	self.virtualCamera = nil

	if gClientUtils.NotNil(self.playerNode) then
		self.playerNode:DOKill()
	end

	if gClientUtils.NotNil(self.animator) then
		self.animator.runtimeAnimatorController = nil
	end

	self.playerNode = nil

	if self.baseUnit then
		self.baseUnit:DestroyUnit(true)
	end

	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
end

function BasketballCharacter:ClearCoroutines()
	self.stopShootPerform = coroutine.stop(self.stopShootPerform)
	self.countdownCoroutine = coroutine.stop(self.countdownCoroutine)
	self.beginRunCo = coroutine.stop(self.beginRunCo)
end

function BasketballCharacter:GameEnd()
	self.gameStatus = BasketballCharacter.GAME_STATUS.END
	self.rootMotion.enabled = false

	self:ClearCoroutines()
	self:StopPerform()
end

function BasketballCharacter:StopPerform()
	self.stopShootPerform = coroutine.start(function ()
		while self:IsPlayShootAnimation() do
			coroutine.wait(0.1)
		end

		if self.rootMotion then
			self.rootMotion.enabled = false
			self.beginRunCo = coroutine.stop(self.beginRunCo)
		end

		self:PlayAnimationByTriggerName(self.animConst.tGameEnd)
		self:ResetBasketBall()

		local isGameOver = gBasketballGameManager.currentGame:IsGameOver()

		if isGameOver then
			gBasketballGameManager.currentGame:ExecuteGameResult()
		end
	end)
end

function BasketballCharacter:ResetBasketBall()
	local basketballRack = self:GetCurrentRackInfo()

	for _, basketball in ipairs(basketballRack.basketballList) do
		if gClientUtils.NotNil(basketball.transform) and basketball.transform.parent == self.handPoint then
			basketball.transform:SetParent(nil)
			basketball:SetRigidbodyKinematic(false)
		end
	end
end

function BasketballCharacter:PlayResultAnimation(isWin)
	local triggerName = isWin and self.animConst.tWin or self.animConst.tLose

	self:PlayAnimationByTriggerName(triggerName)
end

function BasketballCharacter:IsGameOver()
	return self.gameStatus == BasketballCharacter.GAME_STATUS.END
end

function BasketballCharacter:Reset()
	self.countdown = LTConfig.PoiGameConfig.Basket_Time * 10000
	self.score = 0
	self.currentRackIndex = 1
	self.currentBasketballIndex = 0
	self.gameStatus = BasketballCharacter.GAME_STATUS.NONE
	self.rootMotion.enabled = false

	self:InitPosition()
	self:LookAtLanWangCenter()
	self:ResetAllTrigger()
	self:PlayAnimationByTriggerName(self.animConst.tReset)
end

function BasketballCharacter:Pause()
	if self.gameStatus == BasketballCharacter.GAME_STATUS.START then
		self.gameStatus = BasketballCharacter.GAME_STATUS.PAUSE
	end
end

function BasketballCharacter:Resume()
	if self.gameStatus == BasketballCharacter.GAME_STATUS.PAUSE then
		self.gameStatus = BasketballCharacter.GAME_STATUS.START
	end
end

function BasketballCharacter:IsPlayAnimation(stateName)
	return gClientUtils.NotNil(self.animator) and self.animator:GetCurrentAnimatorStateInfo(0):IsName(stateName)
end

function BasketballCharacter:IsPlayIdleAnimation()
	return self:IsPlayAnimation(self.animConst.sIdle) or self:IsPlayAnimation(self.animConst.sSquatWithBall) or self:IsPlayAnimation(self.animConst.sSquatWithoutBall)
end

function BasketballCharacter:IsPlayShootAnimation()
	return self:IsPlayAnimation(self.animConst.sPrepareShoot) or self:IsPlayAnimation(self.animConst.sShoot)
end

function BasketballCharacter:InitAnimationConst()
	self.animConst = {
		sTakeBall = "Take Ball",
		bMirror = "Mirror",
		bCancelShoot = "CancelShoot",
		tLose = "Lose",
		tPrepareShot = "PrepareShot",
		tTakeBall = "TakeBall",
		sCancelShoot = "Cancel Shoot",
		sLose = "Lose",
		sWin = "Win",
		tReset = "Reset",
		sSquatWithoutBall = "Squat Without Ball",
		sShoot = "Shoot",
		tGameEnd = "GameEnd",
		sPrepareShoot = "Prepare Shoot",
		sRun = "Run",
		sTakeBallAfterRun = "Take Ball After Run",
		iAfterShoot = "AfterShoot",
		sIdle = "Idle",
		sSquatWithBall = "Squat With Ball",
		tWin = "Win",
		AfterShootEnum = {
			takeBall = 3,
			idle = 2,
			run = 1
		}
	}
end
