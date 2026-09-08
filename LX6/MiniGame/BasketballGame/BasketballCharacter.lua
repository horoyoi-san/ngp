-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BasketballGame\BasketballCharacter.lua
-- Decompiled from: 00586_BasketballCharacter.lua_24b6ee0bed0e.luajit

local UnitModelManager = LX6.Units.UnitModelManager
local FightManager = LX6.Engine.FightManager
local static_props = {
	SHOOT_TYPE = {
		["y\\x86\\x90\\x8a\\x93"] = 6,
		["&m\\xa3\\xa1\\xbcb"] = 3,
		["y\\x99\\x8d\\x90\\x94"] = 5,
		["&m\\xa3\\xa1\\xbcc"] = 2,
		["y\\x99\\x8d\\x90\\x97"] = 4,
		["&m\\xa3\\xa1\\xbc`"] = 1
	},
	CHARACTER_STATUS = {
		["W\rK~"] = 4,
		["\\xabFB"] = 6,
		["]S\\x8fRe\\x84\\xd7xH[R`"] = 2,
		["~\\x86\\x8d\\x80\\x82"] = 5,
		["SQ~"] = 1,
		["\\x8b\\x83\\x8b\\x8f"] = 3
	},
	GAME_STATUS = {
		["}\\x8f\\x97\\x9c\\x93"] = 3,
		["\\xabFB"] = 3,
		["~\\x9a\\x83\\x9d\\x82"] = 2,
		["T\rS~"] = 1
	}
}
gBasketballCharacter = DefClass("BasketballCharacter", gBasketballCharacter, nil, static_props)
local BasketballCharacter = gBasketballCharacter

BasketballCharacter.ctor = function(self, args)
	self.InitData(self, args)
	self.InitCharacter(self)
end

BasketballCharacter.InitCharacter = function(self)
	self.InitAnimatorController(self, function ()
		self:LoadCharacterModel()
	end)
end

BasketballCharacter.OnCharacterLoadCompleted = function(self, baseUnit)
	if self.hasDestroy then
		baseUnit = baseUnit and baseUnit:DestroyUnit(true)

		return
	end

	self.baseUnit = baseUnit
	self.transform = baseUnit.ModelSlot.transform

	baseUnit:SetDynamicBone(true, true)
	UnitModelManager.SetShadow(baseUnit, true)
	self:InitNodes()
	self:InitPosition()
	self:LookAtLanWangCenter()
	self:InitAnimationEvents()
	self.stimMgr:AddPlayer(self.playerIndex, self.transform)

	local animancer = self.transform:GetComponentInChildren(typeof(Animancer.AnimancerComponent))

	if animancer then
		animancer.enabled = false
	end
end

BasketballCharacter.InitPosition = function(self)
	local targetPosition = self.GetCurrentRackInfo(self).slotPosition
	local offsetPosition = targetPosition + Vector3.Fetch(0, 1, 0)
	self.transform.position = FightManager.GetPhysicsLandPosWithNormalGravity(offsetPosition)
end

BasketballCharacter.InitNodes = function(self)
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

		local weaponNode = self.FindRecursively(self, self.playerNode.transform, basketballShootConfig.WeaponResourceId)

		if weaponNode then
			self.weaponAnimator = weaponNode.gameObject:GetOrAddComponent(typeof(UnityEngine.Animator))
			self.weaponAnimator.runtimeAnimatorController = self.animatorWeaponController
		end
	else
		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(self.baseUnit, false)
	end
end

BasketballCharacter.FindRecursively = function(self, transform, nameStartsWith)
	if string.sub(transform.gameObject.name, 1, #nameStartsWith) ~= nameStartsWith then
		return transform
	end

	for i = 0, transform.childCount - 1 do
		local child = transform.GetChild(transform, i)
		local found = self.FindRecursively(self, child, nameStartsWith)

		if found == nil then
			return found
		end
	end
end

BasketballCharacter.InitAnimationEvents = function(self)
	slot1 = self.animationEvents

	slot1:RegisterEvent("BallGrabbed", function ()
		if self.gameStatus ~= BasketballCharacter.GAME_STATUS.END then
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

	slot1 = self.animationEvents

	slot1:RegisterEvent("BeginRun", function ()
		self.rootMotion.enabled = true
		self.rootMotion.Rotate = true
		self.rootMotion.Move = true
		local nextRackIndex = nil

		if self.currentBasketballIndex ~= 0 then
			nextRackIndex = self.currentRackIndex
		else
			nextRackIndex = self.currentRackIndex + 1
		end

		local nextRack = self.basketballRackList[nextRackIndex]

		if nextRack ~= nil then
			print_error("BasketballCharacter: nextRack is nil!", gClientUtils.NotNil(self.transform) and self.transform.name)

			return
		end

		local nextPosition = nextRack.slotPosition
		self.beginRunCo = coroutine.start(function ()
			self.rootMotion.Rotate = false
			local endFrame = 45

			while true do
				coroutine.step()

				if self.hasDestroy then
					break
				end

				local frameNow = self.rootMotion:MatchTargetByFrame(nextPosition, 0, endFrame)

				if endFrame < frameNow then
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

	slot1 = self.animationEvents

	slot1:RegisterEvent("Rotate", function ()
		self:LookAtLanWangCenter(1)
	end)

	slot1 = self.animationEvents

	slot1:RegisterDefaultEventHandler(function (eventName)
		if string.sub(eventName, 1, 7) ~= "Rotate " then
			local param = string.sub(eventName, 8)
			local time = tonumber(param)

			if time == nil then
				self:LookAtLanWangCenter(time)
			end
		end
	end)
end

BasketballCharacter.SetAnimatorBool = function(self, key, value)
	local animatorList = self.GetAnimatorList(self)

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetBool(key, value)
		end
	end
end

BasketballCharacter.SetAnimatorInteger = function(self, key, value)
	local animatorList = self.GetAnimatorList(self)

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetInteger(key, value)
		end
	end
end

BasketballCharacter.GetAnimatorList = function(self)
	return {
		self.animator,
		self.weaponAnimator
	}
end

BasketballCharacter.PlayShootAnimation = function(self)
	self.SetAnimatorBool(self, self.animConst.bCancelShoot, false)
	self.PlayAnimationByTriggerName(self, self.animConst.tPrepareShot)

	if self.CheckCurrentRackHasBasketball(self) then
		self.SetAnimatorInteger(self, self.animConst.iAfterShoot, self.animConst.AfterShootEnum.takeBall)
	elseif self.currentRackIndex + 1 < #self.basketballRackList then
		self.SetAnimatorInteger(self, self.animConst.iAfterShoot, self.animConst.AfterShootEnum.run)

		self.rootMotion.Rotate = false
	else
		self.SetAnimatorInteger(self, self.animConst.iAfterShoot, self.animConst.AfterShootEnum.idle)
	end
end

BasketballCharacter.InitAnimatorController = function(self, callback)
	local basketballShootConfig = self:GetBasketballShootConfig()
	local animatorControllerPath = basketballShootConfig.AnimatorControllerPath
	self.asyncList = gAsyncActionList.new()
	slot4 = self.asyncList

	slot4:Add(function (onFinish)
		if self.playerIndex ~= 1 then
			animatorControllerPath = animatorControllerPath:gsub("_mirror%.overrideController", ".overrideController")
		elseif self.playerIndex ~= 2 and not animatorControllerPath:find("_mirror") then
			animatorControllerPath = animatorControllerPath:gsub("%.overrideController", "_mirror.overrideController")
		end

		slot2 = gResourceManager
		self.loadOp = slot2:LoadAssetWithCallBack(animatorControllerPath, typeof(UnityEngine.AnimatorOverrideController), function (loadOp)
			if self.hasDestroy then
				return
			end

			self.animatorController = loadOp.asset

			onFinish()
		end)
	end)

	if basketballShootConfig.WeaponAnimatorControllerPath then
		slot4 = self.asyncList

		slot4:Add(function (onFinish)
			slot2 = gResourceManager
			self.loadOp = slot2:LoadAssetWithCallBack(basketballShootConfig.WeaponAnimatorControllerPath, typeof(UnityEngine.AnimatorOverrideController), function (loadOp)
				if self.hasDestroy then
					return
				end

				self.animatorWeaponController = loadOp.asset

				onFinish()
			end)
		end)
	end

	slot4 = self.asyncList

	slot4:Start(function ()
		callback()
	end)
end

BasketballCharacter.LookAtLanWangCenter = function(self, duration)
	duration = duration or 0
	local playerPosition = self.playerNode.position
	local lanWangCenterPosition = self.lanWangCenterPoint.position
	local lookAtPosition = Vector3.Fetch(lanWangCenterPosition.x, playerPosition.y, lanWangCenterPosition.z)
	local TweenAxisConstraintY = 4

	self.playerNode:DOLookAt(lookAtPosition, duration, TweenAxisConstraintY, nil)
end

BasketballCharacter.InitData = function(self, args)
	self.basketballRackList = args.basketballRackList
	self.lanWangCenterPoint = args.lanWangCenterPoint
	self.virtualCamera = args.virtualCamera
	self.id = args.id
	self.pid = args.pid
	self.currentRackIndex = 1
	self.currentBasketballIndex = 0
	self.score = 0
	local basketballShootConfig = self.GetBasketballShootConfig(self)
	self.earlyRangePercent = basketballShootConfig.EarlyRange
	self.soSoRangePercent = basketballShootConfig.SoSoRange
	self.goodRangePercent = basketballShootConfig.GoodRange
	self.perfectRangePercent = basketballShootConfig.PerfectRange
	self.lateRangePercent = basketballShootConfig.LateRange
	self.totalShootTweenTime = basketballShootConfig.ShootTime
	self.countdown = LTConfig.PoiGameConfig.Basket_Time
	self.addTimeInterval = LTConfig.PoiGameConfig.Basket_AddTime

	self.InitAnimationConst(self)

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

BasketballCharacter.StartGame = function(self)
	self.gameStatus = BasketballCharacter.GAME_STATUS.START

	self.PlayAnimationByTriggerName(self, self.animConst.tTakeBall)
	self.StartCountdown(self)
end

BasketballCharacter.StartCountdown = function(self)
	self.SendRefreshViewMessage(self)

	self.countdownCoroutine = coroutine.start(function ()
		while self.countdown <= 0 do
			if self.gameStatus ~= BasketballCharacter.GAME_STATUS.START then
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

BasketballCharacter.PlayBallRollsDownAnimation = function(self)
	if self.CheckCurrentRackHasBasketball(self) then
		local currentRackInfo = self.GetCurrentRackInfo(self)
		local startBasketballIndex = self.currentBasketballIndex + 1
		local targetIndex = 1

		for basketballIndex = startBasketballIndex, 5 do
			local basketball = currentRackInfo.basketballList[basketballIndex]
			local targetPosition = currentRackInfo.basketballList[targetIndex].initPosition

			basketball.DoRollsDownAnimation(basketball, targetPosition)

			targetIndex = targetIndex + 1
		end
	end
end

BasketballCharacter.PlayAnimationByTriggerName = function(self, triggerName)
	self.ResetAllTrigger(self)

	local animatorList = self.GetAnimatorList(self)

	for _, animator in ipairs(animatorList) do
		if animator then
			self.animator:SetTrigger(triggerName)
		end
	end
end

BasketballCharacter.ResetAllTrigger = function(self)
	local animatorList = self.GetAnimatorList(self)

	for _, animator in ipairs(animatorList) do
		if gClientUtils.NotNil(animator) then
			animator.ResetTrigger(animator, self.animConst.tPrepareShot)
			animator.ResetTrigger(animator, self.animConst.tTakeBall)
			animator.ResetTrigger(animator, self.animConst.tWin)
			animator.ResetTrigger(animator, self.animConst.tLose)
			animator.ResetTrigger(animator, self.animConst.tGameEnd)
			animator.ResetTrigger(animator, self.animConst.tReset)
		end
	end
end

BasketballCharacter.GetCurrentBasketball = function(self)
	local currentRackInfo = self.GetCurrentRackInfo(self)

	return currentRackInfo.basketballList[self.currentBasketballIndex]
end

BasketballCharacter.GetCurrentRackInfo = function(self)
	return self.basketballRackList[self.currentRackIndex]
end

BasketballCharacter.CheckCurrentRackHasBasketball = function(self)
	local currentRack = self.basketballRackList[self.currentRackIndex]
	local nextBasketballIndex = self.currentBasketballIndex + 1

	return currentRack and currentRack.basketballList[nextBasketballIndex] == nil
end

BasketballCharacter.StartShoot = function(self, shootType, performTweenTime)
	self.StartShootPerform(self, shootType, performTweenTime)
end

BasketballCharacter.OnExecuteShoot = function(self, shootType)
	gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_basketball_shoot, self.handPoint.position)

	local ballTrans = self.currentBasketball.transform

	self.stimMgr:OnBallShoot(self.playerIndex, ballTrans)
end

BasketballCharacter.StartShootPerform = function(self, shootType)
	local isConflict = self.CheckShootConflict(self)

	if isConflict then
		shootType = BasketballCharacter.SHOOT_TYPE.ZERO_C or shootType
	end

	self.currentBasketball.transform:SetParent(nil)

	local basketballType = self.currentBasketball.basketballType
	self.shootTime = Time.time

	self:OnExecuteShoot(shootType)

	local isValidTime = self.countdown >= 0
	local hasNextBall = self:CheckCurrentRackHasBasketball()

	self.currentBasketball:ExecuteBasketballShoot(shootType, function ()
		if self.hasDestroy then
			return
		end

		if isValidTime then
			self:ExecuteAfterShootLogic(shootType, basketballType, isValidTime)
		end

		if self.gameStatus ~= BasketballCharacter.GAME_STATUS.END then
			return
		end

		if not hasNextBall then
			self:StartMoveNext()
		end
	end)

	self.currentBasketball = nil
end

BasketballCharacter.CheckCanShoot = function(self)
	return self.gameStatus ~= BasketballCharacter.GAME_STATUS.START and self.currentBasketball and self:IsPlayAnimation(self.animConst.sSquatWithBall)
end

BasketballCharacter.ExecuteAfterShootLogic = function(self, shootType, basketballType, isValidTime)
	local score = gBasketballGameUtils.GetCurOriginalScoreByType(shootType)
	local resultScore, addBonus = gBasketballGameUtils.GetCurResultScore(basketballType, score)

	if score <= 0 and basketballType ~= gBasketball.BASKETBALL_TYPE.TIME and self.countdown <= 0 then
		self.countdown = self.countdown + self.addTimeInterval
	end

	self.score = self.score + resultScore

	self.SendRefreshViewMessage(self, shootType, basketballType, score, isValidTime, addBonus)
	self.SendOnBallHitStim(self, shootType)
end

BasketballCharacter.SendOnBallHitStim = function(self, shootType)
	self.stimMgr:OnBallHit(self.playerIndex)

	if shootType ~= gBasketballCharacter.SHOOT_TYPE.THREE then
		self.stimMgr:OnPerfectHit(self.playerIndex)
	end
end

BasketballCharacter.StartMoveNext = function(self)
	if self.currentRackIndex + 1 <= #self.basketballRackList then
		self.GameEnd(self)

		return
	end

	self.currentRackIndex = self.currentRackIndex + 1
	self.currentBasketballIndex = 0
	local playerScore = gBasketballGameManager.currentGame.playerCharacter.score
	local npcScore = gBasketballGameManager.currentGame.npcCharacter.score
	local timing = npcScore < playerScore and UX.Game.BasketballTiming.PlayerAdv or UX.Game.BasketballTiming.OpponentAdv

	gClientToGameSceneDelegate:TriggerBasketballTiming(timing).Callback = function ()
	end
end

BasketballCharacter.GetShootTypeByHitRateList = function(self, hitRateList)
	local randomValue = UnityEngine.Random.Range(0, 1)
	local tmpRatioValue = 0
	local hitRatioCount = #hitRateList

	math.randomseed(os.time())

	for index = 1, hitRatioCount do
		tmpRatioValue = tmpRatioValue + hitRateList[index]

		if randomValue < tmpRatioValue then
			local shootTypeList = self.shootTypes[index]
			local randomIndex = math.random(#shootTypeList)

			return shootTypeList[randomIndex]
		end
	end
end

BasketballCharacter.Destroy = function(self)
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

BasketballCharacter.ClearCoroutines = function(self)
	self.stopShootPerform = coroutine.stop(self.stopShootPerform)
	self.countdownCoroutine = coroutine.stop(self.countdownCoroutine)
	self.beginRunCo = coroutine.stop(self.beginRunCo)
end

BasketballCharacter.GameEnd = function(self)
	self.gameStatus = BasketballCharacter.GAME_STATUS.END
	self.rootMotion.enabled = false

	self.ClearCoroutines(self)
	self.StopPerform(self)
end

BasketballCharacter.StopPerform = function(self)
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

BasketballCharacter.ResetBasketBall = function(self)
	local basketballRack = self.GetCurrentRackInfo(self)

	for _, basketball in ipairs(basketballRack.basketballList) do
		if gClientUtils.NotNil(basketball.transform) and basketball.transform.parent ~= self.handPoint then
			basketball.transform:SetParent(nil)
			basketball:SetRigidbodyKinematic(false)
		end
	end
end

BasketballCharacter.PlayResultAnimation = function(self, isWin)
	local triggerName = isWin and self.animConst.tWin or self.animConst.tLose

	self:PlayAnimationByTriggerName(triggerName)
end

BasketballCharacter.IsGameOver = function(self)
	return self.gameStatus ~= BasketballCharacter.GAME_STATUS.END
end

BasketballCharacter.Reset = function(self)
	self.ClearCoroutines(self)

	self.countdown = LTConfig.PoiGameConfig.Basket_Time
	self.score = 0
	self.currentRackIndex = 1
	self.currentBasketballIndex = 0
	self.gameStatus = BasketballCharacter.GAME_STATUS.NONE
	self.rootMotion.enabled = false

	self.InitPosition(self)
	self.LookAtLanWangCenter(self)
	self.ResetAllTrigger(self)
	self.PlayAnimationByTriggerName(self, self.animConst.tReset)
end

BasketballCharacter.Pause = function(self)
	if self.gameStatus ~= BasketballCharacter.GAME_STATUS.START then
		self.gameStatus = BasketballCharacter.GAME_STATUS.PAUSE
	end
end

BasketballCharacter.Resume = function(self)
	if self.gameStatus ~= BasketballCharacter.GAME_STATUS.PAUSE then
		self.gameStatus = BasketballCharacter.GAME_STATUS.START
	end
end

BasketballCharacter.IsPlayAnimation = function(self, stateName)
	return gClientUtils.NotNil(self.animator) and self.animator:GetCurrentAnimatorStateInfo(0):IsName(stateName)
end

BasketballCharacter.IsPlayIdleAnimation = function(self)
	return self:IsPlayAnimation(self.animConst.sIdle) or self:IsPlayAnimation(self.animConst.sSquatWithBall) or self:IsPlayAnimation(self.animConst.sSquatWithoutBall)
end

BasketballCharacter.IsPlayShootAnimation = function(self)
	return self:IsPlayAnimation(self.animConst.sPrepareShoot) or self:IsPlayAnimation(self.animConst.sShoot)
end

BasketballCharacter.InitAnimationConst = function(self)
	self.animConst = {
		["PsmbK<4"] = "wFgl<4",
		["\\xdb\\xf6+\\xe3"] = "1A\\x83\\x9c\\x8cS",
		["mU\\xadyO\\xb7\\xfetbuqX"] = "\\xbc5.<}\\x91r\\xd18\\xa5\\xad",
		["Y\\x82\\xad\\xbc\\xb3"] = "V-n^",
		["{F\\xber\\\\xb3\\xe0BYrqX"] = "\\xaf&%/y\\x8fD\\xea?\\xa5\\xad",
		["WsmbK<4"] = "\\x9f\\xb0\\xaeH?\\xf2?",
		["|U\\xadyO\\xb7\\xfetbuqX"] = "Lw\\xa2tI\\xbe\\xb2tbuqX",
		["^\\x82\\xad\\xbc\\xb3"] = "V-n^",
		["itU"] = "\\xb9ah",
		["z\\x94\\x9d\\x86U"] = "\\xab\\xb1\\xaa\\xa2",
		["g\\xcf6\\xf9(#\\xcau(\\xda^\\x98.C\\xca\\xea"] = "5+\\x85\\xec\\xbf\\xe7߯\\xae\\x80\\xd2\\xf7&\\x86\\xb8!\\x93\\xee",
		["{\\x99\\x81\\x8cU"] = "~\\xa6\\xad\\xa0\\xa2",
		["\\xbf\\x96\\xa6o\\xf07"] = "\\xfe\\xda;*\\xf5",
		["\\xd3M)\\xd1\\xb3r\\xa9Y\\xbf\\xa2"] = "2\\xf1Z<\\xc2\\xf6r\\xa9Y\\xbf\\xa2",
		["ihU"] = "\\xbc}h",
		["g\\xc8&\\xe7,.\\xcfm\\xd3_\\x89p\\xd3\\xe8"] = "I\r\\xb94\\xb7[\\xa1va 1>t\\xb3\\xbe\\xcc\\xe9",
		["\\x96&+}\\x8fr\\xd18\\xa5\\xad"] = "r\\ڸ\\x96;\\xb0\\xc6\\xfc",
		["^\\x87\\xa6\\xa3\\xb3"] = "S&q^",
		["\\xf4\\xa9 \\xf9\\xd1\\xfe\\x80σ,$"] = ";5\\xe5g\\xd8\\xc0=\\xbc'\\xa6\\xd0\\xe7x\\xf7",
		["ntU"] = "\\xb9ah",
		AfterShootEnum = {
			["\\xbf\\xb0\\xaeH?\\xf2?"] = 3,
			["s&q^"] = 2,
			["\\x9c}h"] = 1
		}
	}
end
