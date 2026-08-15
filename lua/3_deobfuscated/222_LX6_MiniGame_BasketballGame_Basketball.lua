local static_props = {
	BASKETBALL_TYPE = {
		BONUS = 3,
		NORMAL = 1,
		TIME = 2
	}
}

local function Randomize(v)
	local length = v.magnitude
	local randX = UnityEngine.Random.Range(-0.2, 0.2)
	local randY = UnityEngine.Random.Range(-0.1, 0.1)
	local randZ = UnityEngine.Random.Range(-0.2, 0.2)
	v = v.normalized + Vector3.Fetch(randX, randY, randZ)

	return v.normalized * length
end

gBasketball = DefClass("Basketball", gBasketball, nil, static_props)
local Basketball = gBasketball

function Basketball:ctor(args)
	self:InitData(args)
	self:SpawnBasketball()
end

function Basketball:InitData(args)
	self.basketballType = args.basketballType
	self.lanQiuJiaPosition = args.lanQiuJiaPoint
	self.lanWangCenterTransform = args.lanWangCenterPoint
	self.lanBanCenterTransform = args.lanBanCenterPoint
	self.parentTransform = args.pointTransform
	self.jumpTime = LTConfig.PoiGameConfig.Basket_Jump_Time
	self.jumpPowerMin = LTConfig.PoiGameConfig.Basket_Jump_Power_Min
	self.jumpPowerMax = LTConfig.PoiGameConfig.Basket_Jump_Power_Max
	self.basketballWidth = LTConfig.PoiGameConfig.Basket_Ball_Width
	self.lanKuanWidth = LTConfig.PoiGameConfig.Basket_LanKuan_Width
end

function Basketball:SpawnBasketball()
	local ballPath = self:GetBasketballPath(self.basketballType)
	self.loadOp = gResourceManager:LoadAssetWithCallBack(ballPath, typeof(GameObject), function (loadOp)
		if not self.hasDestroy then
			local basketballGameObject = GameObject.Instantiate(loadOp.asset)

			basketballGameObject:SetActive(true)
			self:InitNode(basketballGameObject)
			self:SetTriggerEvents()
		end
	end)
end

function Basketball:InitNode(basketballGameObject)
	self.transform = basketballGameObject.transform
	self.rigidbody = basketballGameObject:GetComponent("Rigidbody")
	local meshRenderer = basketballGameObject:GetComponentInChildren(typeof(UnityEngine.MeshRenderer))
	self.material = meshRenderer.material

	self.transform:SetParent(self.parentTransform)
	gClientUtils.ResetLocalTransform(self.transform)

	self.initPosition = self.transform.position
end

function Basketball:SetTriggerEvents()
	local trigger = self.transform.gameObject:GetOrAddComponent(typeof(L18.MiniGame.TriggerLuaDelegate))

	function trigger.OnTriggerEnterHandler(other)
		self:OnTriggerEnter(other)
	end
end

function Basketball:OnTriggerEnter(other)
	if other.gameObject.name == "BasketballGameGround" then
		gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_Backboard_hit_weak, self.transform.position)
	end
end

function Basketball:ExecuteBasketballShoot(shootType, callback)
	local function shootCallback()
		if gBasketballGameUtils.CheckMakeAShootByType(shootType) then
			if shootType == gBasketballCharacter.SHOOT_TYPE.THREE then
				gMessageManager:SendMessage(gEventConstants.PLAY_BASKET_GET_THE_BASKET_EFFECT, LTConfig.PoiGameConfig.Basket_ScoreEffect_Net_Bonus)
				self:StopEffects()
			end

			local soundId = self:GetSoundId()

			gSoundMgr:PlaySoundByTid(soundId, self.transform.position)
			gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_basketball_net, self.transform.position)
		end

		callback()
	end

	self:PlayShoot(shootType, shootCallback)
	self:PlayEffects(shootType)
end

function Basketball:PlayShoot(shootType, callback)
	if shootType == gBasketballCharacter.SHOOT_TYPE.THREE then
		return self:PlayThreePointShoot(callback)
	elseif shootType == gBasketballCharacter.SHOOT_TYPE.TWO_A then
		return self:PlayTwoPointAShoot(callback)
	elseif shootType == gBasketballCharacter.SHOOT_TYPE.TWO_B then
		return self:PlayTwoPointBShoot(callback)
	elseif shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_A then
		return self:PlayZeroAShoot(callback)
	elseif shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_B then
		return self:PlayZeroBShoot(callback)
	elseif shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_C then
		return self:PlayZeroCShoot(callback)
	end
end

function Basketball:GetSoundId()
	local soundId = nil

	if self.basketballType == Basketball.BASKETBALL_TYPE.TIME then
		soundId = gBasketballGame.SoundId.Play_basketball_extra_ball_ui
	elseif self.basketballType == Basketball.BASKETBALL_TYPE.BONUS then
		soundId = gBasketballGame.SoundId.Play_basketball_huaqiu_ui
	elseif self.basketballType == Basketball.BASKETBALL_TYPE.NORMAL then
		soundId = gBasketballGame.SoundId.Play_basketball_common_ui
	end

	return soundId
end

function Basketball:PlayEffects(shootType)
	if shootType == gBasketballCharacter.SHOOT_TYPE.THREE then
		local ballTransform = self.transform
		local effect1 = 0
		effect1 = gCS.EffectMgr:PlayEffectsOnTransform(LTConfig.PoiGameConfig.Basket_ScoreEffect_Ball_Tail, ballTransform, ballTransform.position)
		local effect2 = gCS.EffectMgr:PlayGameObjectMaterialEffect(LTConfig.PoiGameConfig.Basket_ScoreEffect_Highlight, "BasketballGameEffect" .. self.transform.gameObject:GetInstanceID(), self.transform.gameObject)
		self.playingEffects = {
			effect1,
			effect2
		}
	end
end

function Basketball:StopEffects()
	if self.playingEffects then
		for _, effect in ipairs(self.playingEffects) do
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(effect)
		end

		table.clear(self.playingEffects)
	end
end

function Basketball:SetRigidbodyKinematic(value)
	self.rigidbody.isKinematic = value
end

function Basketball:GetBasketballPath(BasketballType)
	if BasketballType == Basketball.BASKETBALL_TYPE.NORMAL then
		return LTConfig.PoiGameConfig.Basket_BallRes1
	elseif BasketballType == Basketball.BASKETBALL_TYPE.TIME then
		return LTConfig.PoiGameConfig.Basket_BallRes2
	elseif BasketballType == Basketball.BASKETBALL_TYPE.BONUS then
		return LTConfig.PoiGameConfig.Basket_BallRes3
	end
end

function Basketball:Reset()
	self:DestroyGameObject()
	self:SpawnBasketball()
end

function Basketball:Destroy()
	self:StopEffects()

	self.hasDestroy = true
	self.doFadeOutCo = coroutine.stop(self.doFadeOutCo)

	self:DestroyGameObject()

	self.transform = nil
	self.basketballType = nil
end

function Basketball:DoRollsDownAnimation(targetPosition)
	local duration = 1

	self.transform:DOMove(targetPosition, duration):SetEase(DG.Tweening.Ease.Linear)
	self.transform:DORotate(Vector3.New(-360, 0, 0), duration, DG.Tweening.RotateMode.LocalAxisAdd)
end

function Basketball:UpdateVelocity()
	if self.prevTime then
		local deltaTime = Time.time - self.prevTime

		if deltaTime > 0.001 then
			local prevVelocity = self.velocity
			self.velocity = (self.transform.position - self.prevPosition) / deltaTime

			if prevVelocity then
				self.velocity = self.velocity * 0.7 + prevVelocity * 0.3
			end
		end
	end

	self.prevPosition = self.transform.position
	self.prevTime = Time.time
end

function Basketball:PlayZeroAShoot(callback)
	self.rigidbody.isKinematic = true
	local pointA = self.transform.position
	local pointB = self.lanWangCenterTransform.position
	local directionAB = (pointB - pointA).normalized
	local randomOffset = UnityEngine.Random.Range(0.3, 0.7)
	local dotResult = Vector3.Dot(Vector3.New(directionAB.x, 0, directionAB.z), self.lanBanCenterTransform.right)
	local offsetX = dotResult > 0 and randomOffset or -randomOffset
	local targetLocalPosition = Vector3.New(offsetX, 0, self.basketballWidth / 2)
	local pointC = self.lanBanCenterTransform:TransformPoint(targetLocalPosition)
	local jumpPower = self:GetJumpPower()
	local tweener = self.transform:DOJump(pointC, jumpPower, 1, self.jumpTime):SetEase(DG.Tweening.Ease.Linear)

	tweener:OnUpdate(function ()
		self:UpdateVelocity()
	end)
	tweener:OnComplete(function ()
		self.rigidbody.isKinematic = false

		gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_backboard_hit, self.transform.position)

		if self.velocity then
			local reflection = Vector3.Reflect(self.velocity, self.lanBanCenterTransform.forward)
			self.rigidbody.velocity = reflection
		end

		self:DoFadeOut()
		callback()
	end)
	self:DoRotateBall()

	return self.jumpTime
end

function Basketball:PlayZeroBShoot(callback)
	self.rigidbody.isKinematic = true
	local pointA = self.transform.position
	local pointB = self.lanWangCenterTransform.position
	local directionAB = (pointB - pointA).normalized
	directionAB = Vector3.New(directionAB.x, 0, directionAB.z)
	local pointC = pointB - directionAB * self.lanKuanWidth / 2 + Vector3.up * 0.1 - directionAB.normalized * 0.1
	local jumpPower = self:GetJumpPower()
	local tweener = self.transform:DOJump(pointC, jumpPower, 1, self.jumpTime):SetEase(DG.Tweening.Ease.Linear)

	tweener:OnUpdate(function ()
		self:UpdateVelocity()
	end)
	tweener:OnComplete(function ()
		self.rigidbody.isKinematic = false

		gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_basketball_rim, self.transform.position)

		if self.velocity then
			self.rigidbody.velocity = Randomize(self.velocity * -0.5)
		end

		self:DoFadeOut()
		callback()
	end)
	self:DoRotateBall(self.jumpTime)

	return self.jumpTime
end

function Basketball:PlayZeroCShoot(callback)
	self.rigidbody.isKinematic = true
	local point = self.lanWangCenterTransform.position
	local lanQiuJiaPointY = self.lanQiuJiaPosition.y
	local endX = point.x
	local endY = lanQiuJiaPointY + 1
	local endZ = point.z
	local endPosition = Vector3.New(endX, endY, endZ)
	endPosition = endPosition + (endPosition - self.transform.position).normalized * self.lanKuanWidth
	local tweenTime = LTConfig.PoiGameConfig.Basket_Three_Misses_Tween_Time
	local tweener = self.transform:DOJump(endPosition, 3, 1, tweenTime):SetEase(DG.Tweening.Ease.Linear)

	tweener:OnUpdate(function ()
		self:UpdateVelocity()
	end)
	tweener:OnComplete(function ()
		self.rigidbody.isKinematic = false

		if self.velocity then
			self.rigidbody.velocity = self.velocity
		end

		self:DoFadeOut()
		callback()
	end)
	self:DoRotateBall(self.jumpTime)

	return self.jumpTime
end

function Basketball:PlayTwoPointAShoot(callback)
	self.rigidbody.isKinematic = true
	local pointA = self.transform.position
	local pointB = self.lanWangCenterTransform.position
	local directionAB = (pointB - pointA).normalized
	local minOffsetHeight = 0.1
	local maxOffsetHeight = 0.3
	local offsetY = UnityEngine.Random.Range(minOffsetHeight, maxOffsetHeight)
	local angle = Vector3.Angle(Vector3.New(directionAB.x, 0, directionAB.z), self.lanBanCenterTransform.right)
	local offsetX = self:MapDegree(angle, 0, 180, -0.6, 0.6)
	local targetLocalPosition = Vector3.New(offsetX, offsetY, self.basketballWidth / 2)
	local pointC = self.lanBanCenterTransform:TransformPoint(targetLocalPosition)
	local jumpPower = self:GetJumpPower()
	local tweener1 = self.transform:DOJump(pointC, jumpPower, 1, self.jumpTime)

	tweener1:SetEase(DG.Tweening.Ease.Linear):OnComplete(function ()
		gSoundMgr:PlaySoundByTid(gBasketballGame.SoundId.Play_backboard_hit, self.transform.position)
	end)

	local duration = 0.2
	local tweener2 = self.transform:DOMove(pointB, duration):SetEase(DG.Tweening.Ease.InQuad)

	tweener2:OnUpdate(function ()
		self:UpdateVelocity()
	end)

	self.sequence = DOTween.Sequence()

	self.sequence:Append(tweener1)
	self.sequence:Append(tweener2)
	self.sequence:AppendCallback(function ()
		self.sequence = nil
		self.rigidbody.isKinematic = false

		if self.velocity then
			self.rigidbody.velocity = self.velocity * 0.9
		end

		self:DoFadeOut()
		callback()
	end)
	self:DoRotateBall()

	return self.jumpTime + duration
end

function Basketball:PlayTwoPointBShoot(callback)
	self.rigidbody.isKinematic = true
	local pointA = self.transform.position
	local pointB = self.lanWangCenterTransform.position
	local directionAB = pointB - pointA
	local directionOnPlane = Vector3.New(directionAB.x, 0, directionAB.z).normalized
	local offset = (self.lanKuanWidth - self.basketballWidth) / 2
	local forwardDirection = directionOnPlane * offset
	local pointC = pointB + forwardDirection
	local pointD = pointB - forwardDirection * 0.2 + Vector3.down * 0.15
	local pointE = pointB + forwardDirection * 0.8 + Vector3.down * 0.3
	local pointF = pointB + Vector3.down * 0.45 - Randomize(forwardDirection) * 0.1
	local jumpPower = self:GetJumpPower()
	local tweener1 = self.transform:DOJump(pointC, jumpPower, 1, self.jumpTime):SetEase(DG.Tweening.Ease.Linear)

	tweener1:OnComplete(function ()
		callback()
	end)

	local tweener2 = self.transform:DOMove(pointD, 0.1):SetEase(DG.Tweening.Ease.Linear)
	local tweener3 = self.transform:DOMove(pointE, 0.1):SetEase(DG.Tweening.Ease.Linear)
	local tweener4 = self.transform:DOMove(pointF, 0.1):SetEase(DG.Tweening.Ease.Linear)

	tweener3:OnUpdate(function ()
		self:UpdateVelocity()
	end)
	tweener4:OnUpdate(function ()
		self:UpdateVelocity()
	end)

	self.sequence = DOTween.Sequence()

	self.sequence:Append(tweener1)
	self.sequence:Append(tweener2)
	self.sequence:Append(tweener3)
	self.sequence:Append(tweener4)
	self.sequence:AppendCallback(function ()
		self.sequence = nil
		self.rigidbody.isKinematic = false

		if self.velocity then
			local velocity = self.velocity
			velocity.x = -velocity.x
			velocity.z = -velocity.z
			self.rigidbody.velocity = velocity
		end

		self:DoFadeOut()
	end)
	self:DoRotateBall()

	return self.jumpTime + 0.3
end

function Basketball:PlayThreePointShoot(callback)
	self.rigidbody.isKinematic = true
	local pointB = self.lanWangCenterTransform.position
	local jumpPower = self:GetJumpPower() * 1.3
	local tweener = self.transform:DOJump(pointB, jumpPower, 1, self.jumpTime):SetEase(DG.Tweening.Ease.Linear)

	tweener:OnUpdate(function ()
		self:UpdateVelocity()
	end)
	tweener:OnComplete(function ()
		self.rigidbody.isKinematic = false

		if self.velocity then
			self.rigidbody.velocity = self.velocity
		end

		self:DoFadeOut()
		callback()
	end)
	self:DoRotateBall()

	return self.jumpTime
end

function Basketball:GetJumpPower()
	return UnityEngine.Random.Range(self.jumpPowerMin, self.jumpPowerMax)
end

function Basketball:DoRotateBall(duration)
	duration = duration or self.jumpTime
	local randomX = UnityEngine.Random.Range(0, 360)
	local randomY = UnityEngine.Random.Range(0, 360)
	local randomZ = UnityEngine.Random.Range(0, 360)
	local endValue = Vector3.New(randomX, randomY, randomZ)
	local tweener = self.transform:DORotate(endValue, duration)

	tweener:SetEase(DG.Tweening.Ease.Linear)
end

function Basketball:MapDegree(value, fromSource, toSource, fromTarget, toTarget)
	local normalizedValue = (value - fromSource) / (toSource - fromSource)

	return normalizedValue * (toTarget - fromTarget) + fromTarget
end

function Basketball:DoFadeOut()
	self.doFadeOutCo = coroutine.start(function ()
		coroutine.wait(3)
		self.material:EnableKeyword("_TRANSPARENT_STIPPLE")

		self.materialTweener = self.material:DOFloat(0, "_AlphaVariation", 1):OnComplete(function ()
			self:Destroy()

			self.materialTweener = nil
		end)
	end)
end

function Basketball:DestroyGameObject()
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)

	if self.materialTweener then
		self.material:DOKill()

		self.materialTweener = nil
	end

	if self.sequence then
		self.sequence:Kill()

		self.sequence = nil
	end

	if gClientUtils.NotNil(self.transform) then
		self.transform:DOKill()
		UnityEngine.GameObject.Destroy(self.transform.gameObject)
	end

	self.transform = nil
end
