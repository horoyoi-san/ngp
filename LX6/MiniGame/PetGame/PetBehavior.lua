-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetBehavior.lua
-- Decompiled from: 02134_PetBehavior.lua_42d317735427.luajit

local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local PetAniEnum = PetGameEnum.PetAniEnum
local PetAnimation = PetGameEnum.PetAnimation
local petBehaviorState = PetGameConst.Behavior
local EffectType = PetGameEnum.EffectType
local FurniturePoint = PetGameEnum.FurniturePoint
local FurnitureType = PetGameEnum.FurnitureType
local InteractionDatas = require("LX6/MiniGame/PetGame/data/tbinteraction")
PetFadeState = DefClass("PetFadeState", PetFadeState)

PetFadeState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetFadeState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.idle)

	self.stayTime = 0.1
	self.nextState = self.petEntity:GetNextState()
end

PetFadeState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.petEntity:ChangeState(self.nextState)
	end
end

PetFadeState.OnExit = function(self)
end

PetIdleState = DefClass("PetIdleState", PetIdleState)

PetIdleState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetIdleState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.idle)
end

PetIdleState.OnUpdate = function(self)
end

PetIdleState.OnExit = function(self)
end

PetBirthState = DefClass("PetBirthState", PetBirthState)

PetBirthState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetBirthState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.birth)

	self.stayTime = PetGameConst.PET_BIRTH_STAY_TIME
end

PetBirthState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.petEntity:ChangeState(PetGameConst.Behavior.idle)
	end
end

PetBirthState.OnExit = function(self)
end

PetWalkingState = DefClass("PetWalkingState", PetWalkingState)

PetWalkingState.ctor = function(self, petEntity)
	self.petEntity = petEntity
	self.moveSpeed = 10
end

PetWalkingState.OnEnter = function(self)
	self.petTransform = self.petEntity:GetTransform()

	if not self.petTransform then
		self.petEntity:ChangeState(PetGameConst.Behavior.idle)

		return
	end

	local petInfo = self.petEntity:GetPetInfo()
	self.moveSpeed = petInfo.speed or 10
	local pos = self.petTransform.localPosition
	self.originalPos = Vector3.New(pos.x, pos.y, pos.z)
	self.randomPos = self.petEntity:GenerateRandomWalkPos()
	local currentPos = self.originalPos
	self.direction = (self.randomPos - currentPos).normalized
	local runAni = PetAniEnum.runL

	if self.direction.x <= 0 then
		runAni = PetAniEnum.runR
	end

	self.petEntity:PlayAni(runAni)
end

PetWalkingState.UpdateDirection = function(self)
	if not self.petTransform then
		return
	end

	local pos = self.petTransform.localPosition
	self.originalPos = Vector3.New(pos.x, pos.y, pos.z)
	self.randomPos = self.petEntity:GenerateRandomWalkPos()
	self.direction = (self.randomPos - self.originalPos).normalized
	local runAni = PetAniEnum.runL

	if self.direction.x <= 0 then
		runAni = PetAniEnum.runR
	end

	self.petEntity:PlayAni(runAni)
end

PetWalkingState.OnUpdate = function(self)
	if not self.petTransform then
		return
	end

	local currentPos = self.petTransform.localPosition
	local distanceToTarget = Vector3.Distance(currentPos, self.randomPos)
	local moveDistance = self.moveSpeed * Time.deltaTime

	if distanceToTarget <= 1 or distanceToTarget < moveDistance then
		self.petTransform:SetLocalPosition(self.randomPos.x, self.randomPos.y, 0)
		self.petEntity:ChangeState(petBehaviorState.idle)

		return
	end

	local moveDeltaX = self.direction.x * moveDistance
	local moveDeltaY = self.direction.y * moveDistance
	local newPosX = currentPos.x + moveDeltaX
	local newPosY = currentPos.y + moveDeltaY

	self.petTransform:SetLocalPosition(newPosX, newPosY, 0)
end

PetWalkingState.OnExit = function(self)
end

PetSleepingState = DefClass("PetSleepingState", PetSleepingState)

PetSleepingState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetSleepingState.OnEnter = function(self)
	self.petEntity:PlayQueued(PetAniEnum.sleep, PetAniEnum.sleepLoop)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ENTER_SLEEP)
end

PetSleepingState.OnUpdate = function(self)
end

PetSleepingState.OnExit = function(self)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_WAKE_UP)
end

PetEatingState = DefClass("PetEatingState", PetEatingState)

PetEatingState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetEatingState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.eat)

	self.stayTime = 4
end

PetEatingState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.petEntity:ChangeState(PetGameConst.Behavior.idle)
	end
end

PetEatingState.OnExit = function(self)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_EAT_FINISH)
end

PetDeadState = DefClass("PetDeadState", PetDeadState)

PetDeadState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetDeadState.OnEnter = function(self)
	print("Pet is now dead.")
end

PetDeadState.OnUpdate = function(self)
end

PetDeadState.OnExit = function(self)
	print("Exiting dead state.")
end

PetFullState = DefClass("PetFullState", PetFullState)

PetFullState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetFullState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.eat_full)

	self.stayTime = 2
end

PetFullState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		if self.petEntity:IsSick() then
			self.petEntity:ChangeState(PetGameConst.Behavior.sick)
		else
			self.petEntity:ChangeState(PetGameConst.Behavior.idle)
		end
	end
end

PetFullState.OnExit = function(self)
end

PetLvUpState = DefClass("PetLvUpState", PetLvUpState)

PetLvUpState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetLvUpState.OnEnter = function(self)
	local effectsUpTrans = self.petEntity:GetChildTrans("body/effects_up")

	if effectsUpTrans then
		self.effectGo = effectsUpTrans.gameObject

		self.effectGo:SetActive(true)
	end

	self.stayTime = 2
end

PetLvUpState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.petEntity:ChangeState(PetGameConst.Behavior.idle)
	end
end

PetLvUpState.OnExit = function(self)
	if self.effectGo then
		self.effectGo:SetActive(false)

		self.effectGo = nil
	end
end

PetSickState = DefClass("PetSickState", PetSickState)

PetSickState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetSickState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.ill)
end

PetSickState.OnUpdate = function(self)
end

PetSickState.OnExit = function(self)
end

PetInteractionState = DefClass("PetInteractionState", PetInteractionState)

PetInteractionState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetInteractionState.OnEnter = function(self)
	self.petEntity:PlayAni(PetAniEnum.stroke)

	self.stayTime = 3
end

PetInteractionState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.stayTime = 3

		self.petEntity:ChangeState(PetGameConst.Behavior.idle)
	end
end

PetInteractionState.OnExit = function(self)
end

PetDefecatePrepareState = DefClass("PetDefecatePrepareState", PetDefecatePrepareState)

PetDefecatePrepareState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

PetDefecatePrepareState.OnEnter = function(self)
	self.remainTime = PetGameConst.DEFECATE_PREPARE_TIME
	local animator = self.petEntity:GetAnimator()
	local aniName = PetAnimation[PetAniEnum.defecateLoop]
	local aniState = animator and aniName and animator:get_Item(aniName)

	if aniState then
		aniState.wrapMode = WrapMode.Loop
	end

	self.petEntity:PlayAni(PetAniEnum.defecateLoop)
end

PetDefecatePrepareState.OnUpdate = function(self)
	self.remainTime = self.remainTime - Time.deltaTime

	if self.remainTime <= 0 then
		return
	end

	if self.petEntity then
		self.petEntity:ChangeState(petBehaviorState.idle)
		self.petEntity:PassStoolOnGround()
	end
end

PetDefecatePrepareState.OnExit = function(self)
	self.remainTime = nil

	if self.petEntity then
		self.petEntity:HideDefecateEffect()
	end
end

MoodEmotionState = DefClass("MoodEmotionState", MoodEmotionState)

MoodEmotionState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

MoodEmotionState.OnEnter = function(self)
	local moodValue = self.petEntity:GetAttribute("moodValue")

	if moodValue <= 60 then
		local emotion = math.random(0, 1) >= 0.5 and PetAniEnum.smile or PetAniEnum.happy

		self.petEntity:PlayAni(emotion)
	else
		local emotion = math.random(0, 1) >= 0.5 and PetAniEnum.blues or PetAniEnum.angry

		self.petEntity:PlayAni(emotion)
	end

	self.stayTime = 3
end

MoodEmotionState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.stayTime = 3

		self.petEntity:ChangeState(PetGameConst.Behavior.idle)
	end
end

MoodEmotionState.OnExit = function(self)
end

PetFurnitureInteractionState = DefClass("PetFurnitureInteractionState", PetFurnitureInteractionState)

PetFurnitureInteractionState.ctor = function(self, petEntity)
	self.petEntity = petEntity
	self.moveSpeed = 10
end

PetFurnitureInteractionState.OnEnter = function(self)
	self.interactionData = self.petEntity:GetFurnitureInteractionData()
	self.petTransform = self.petEntity:GetTransform()

	if not self.interactionData or not self.interactionData.furnitureGo or not self.petTransform then
		self.phase = "finish"

		return
	end

	local petInfo = self.petEntity:GetPetInfo()
	self.moveSpeed = petInfo.speed or 10
	self.targetTrans = self.interactionData.petFollow

	if not self.targetTrans and self.interactionData.furnitureGo.transform then
		self.targetTrans = self.interactionData.furnitureGo.transform:Find(FurniturePoint.petFollow)
	end

	if not self.targetTrans then
		self.phase = "finish"

		return
	end

	local targetPos = self.targetTrans.position
	local parentTrans = self.petTransform.parent

	if parentTrans then
		targetPos = parentTrans.InverseTransformPoint(parentTrans, targetPos)
	end

	self.targetPos = Vector3.New(targetPos.x, targetPos.y, 0)
	local conf = self.interactionData.conf or {}
	self.triggerRadius = math.max(tonumber(conf.triggerRadius) or 0, 0)
	self.finishTrans = self.interactionData.finish

	if not self.finishTrans and self.interactionData.furnitureGo.transform then
		self.finishTrans = self.interactionData.furnitureGo.transform:Find(FurniturePoint.finish)
	end

	self.furnitureAni = self.interactionData.furnitureGo.transform:GetComponent("Animation")
	local currentPos = self.petTransform.localPosition

	if Vector3.Distance(currentPos, self.targetPos) < self.triggerRadius then
		self.StartInteraction(self)
	else
		self.phase = "move"

		self.PlayMoveAnimation(self)
	end
end

PetFurnitureInteractionState.PlayMoveAnimation = function(self)
	if not self.petTransform or not self.targetPos then
		return
	end

	local currentPos = self.petTransform.localPosition
	self.direction = (self.targetPos - currentPos).normalized
	local runAni = PetAniEnum.runL

	if self.direction.x <= 0 then
		runAni = PetAniEnum.runR
	end

	self.petEntity:PlayAni(runAni)
end

PetFurnitureInteractionState.StartInteraction = function(self)
	if self.isInteractived then
		return
	end

	self.isInteractived = true
	self.phase = "interaction"
	local conf = self.interactionData.conf or {}
	self.interactionConf = InteractionDatas[conf.interactionId]

	if not self.interactionConf then
		self.phase = "finish"

		print_error("家具交互配置不存在，interactionId：", conf.interactionId)

		return
	end

	if conf.type ~= FurnitureType.Lamp and gEventConstants.MINIGAME_PET_GAME_LAMP_INTERACTION then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_LAMP_INTERACTION, self.interactionData)
	end

	self.stayTime = self.interactionConf.duration or 0

	if self.stayTime < 0 then
		self.stayTime = 1
	end

	if self.interactionConf.attachToItem and self.petTransform and self.targetTrans then
		self.attachOriginalParent = self.petTransform.parent
		self.attachOriginalLocalRotation = self.petTransform.localRotation
		self.attachOriginalLocalScale = self.petTransform.localScale

		self.petTransform:SetParent(self.targetTrans)

		self.petTransform.localPosition = Vector3.zero
		self.petTransform.localRotation = Quaternion.Euler(Vector3.zero)
		self.petTransform.localScale = Vector3.one
		self.attachedToFurniture = true
	end

	local petAni = PetGameEnum.GetAniEnum(self.interactionConf.petAni)

	if petAni then
		self.petEntity:PlayQueued(petAni, PetAniEnum.idle)
	else
		self.petEntity:PlayAni(PetAniEnum.idle)
	end

	if self.interactionConf.hideShadow then
		self.petEntity:ActiveShadow(false)
	end

	if self.furnitureAni then
		self.furnitureAniName = self.interactionConf.itemAni

		if self.furnitureAniName and self.furnitureAniName == "" then
			self.furnitureAni:Play(self.furnitureAniName)
		else
			self.furnitureAni:Play()
		end
	end
end

PetFurnitureInteractionState.OnUpdate = function(self)
	if self.phase ~= "finish" then
		self.petEntity:ChangeState(petBehaviorState.idle)

		return
	end

	if self.phase ~= "move" then
		if not self.petTransform or not self.targetPos then
			self.petEntity:ChangeState(petBehaviorState.idle)

			return
		end

		local currentPos = self.petTransform.localPosition
		local distanceToTarget = Vector3.Distance(currentPos, self.targetPos)
		local moveDistance = self.moveSpeed * Time.deltaTime
		local distanceToTriggerRange = math.max(distanceToTarget - self.triggerRadius, 0)

		if distanceToTriggerRange < 0 then
			self.StartInteraction(self)

			return
		end

		if distanceToTriggerRange < moveDistance then
			local triggerPos = currentPos + self.direction * distanceToTriggerRange

			self.petTransform:SetLocalPosition(triggerPos.x, triggerPos.y, 0)
			self:StartInteraction()

			return
		end

		local moveDeltaX = self.direction.x * moveDistance
		local moveDeltaY = self.direction.y * moveDistance
		local newPosX = currentPos.x + moveDeltaX
		local newPosY = currentPos.y + moveDeltaY

		self.petTransform:SetLocalPosition(newPosX, newPosY, 0)

		return
	end

	if self.phase ~= "interaction" then
		self.stayTime = self.stayTime - Time.deltaTime

		if self.stayTime < 0 then
			self.isInteractionFinished = true

			self.petEntity:ChangeState(petBehaviorState.idle)
		end
	end
end

PetFurnitureInteractionState.OnExit = function(self)
	if self.attachedToFurniture and self.petTransform then
		self.petTransform:SetParent(self.attachOriginalParent)

		if self.attachOriginalLocalRotation then
			self.petTransform.localRotation = self.attachOriginalLocalRotation
		end

		if self.attachOriginalLocalScale then
			self.petTransform.localScale = self.attachOriginalLocalScale
		end
	end

	if self.isInteractionFinished and self.finishTrans then
		self.petEntity:SetPosition(self.finishTrans.position)
	end

	if self.interactionConf and self.interactionConf.hideShadow then
		self.petEntity:ActiveShadow(true)
	end

	self.petEntity:ClearFurnitureInteractionData()
	self.petEntity:HideAllEffect()

	if self.furnitureAni then
		local aniState = self.furnitureAni:get_Item(self.furnitureAniName)

		if aniState then
			aniState.time = aniState.length
		end

		self.furnitureAni:Sample()
		self.furnitureAni:Stop()

		self.furnitureAni = nil
	end

	self.interactionConf = nil
	self.isInteractived = nil
	self.attachedToFurniture = nil
	self.attachOriginalParent = nil
	self.attachOriginalLocalRotation = nil
	self.attachOriginalLocalScale = nil
	self.phase = nil
	self.targetTrans = nil
	self.targetPos = nil
	self.triggerRadius = nil
	self.finishTrans = nil
	self.isInteractionFinished = nil
	self.interactionData = nil
end

PetMoveToPoint = DefClass("PetMoveToPoint", PetMoveToPoint)

PetMoveToPoint.ctor = function(self, petEntity)
	self.petEntity = petEntity
	self.moveSpeed = 10
end

PetMoveToPoint.OnEnter = function(self)
	self.petTransform = self.petEntity:GetTransform()

	if not self.petTransform then
		self.phase = "finish"

		return
	end

	local petInfo = self.petEntity:GetPetInfo()
	self.moveSpeed = petInfo.speed or 10
	local targetPos = self.petEntity:GetDestination()

	if not targetPos then
		self.phase = "finish"

		return
	end

	local parentTrans = self.petTransform.parent

	if parentTrans then
		targetPos = parentTrans.InverseTransformPoint(parentTrans, targetPos)
	end

	self.targetPos = Vector3.New(targetPos.x, targetPos.y, 0)
	self.phase = "move"

	self.PlayMoveAnimation(self)
end

PetMoveToPoint.PlayMoveAnimation = function(self)
	if not self.petTransform or not self.targetPos then
		return
	end

	local currentPos = self.petTransform.localPosition
	self.direction = (self.targetPos - currentPos).normalized
	local runAni = PetAniEnum.runL

	if self.direction.x <= 0 then
		runAni = PetAniEnum.runR
	end

	self.petEntity:PlayAni(runAni)
end

PetMoveToPoint.OnUpdate = function(self)
	if self.phase ~= "finish" then
		self.petEntity:ChangeState(petBehaviorState.idle)

		return
	end

	if self.phase == "move" or not self.petTransform or not self.targetPos then
		self.petEntity:ChangeState(petBehaviorState.idle)

		return
	end

	local currentPos = self.petTransform.localPosition
	local distanceToTarget = Vector3.Distance(currentPos, self.targetPos)
	local moveDistance = self.moveSpeed * Time.deltaTime

	if distanceToTarget <= 1 or distanceToTarget < moveDistance then
		self.petTransform:SetLocalPosition(self.targetPos.x, self.targetPos.y, 0)

		self.phase = "finish"

		return
	end

	local newPosX = currentPos.x + self.direction.x * moveDistance
	local newPosY = currentPos.y + self.direction.y * moveDistance

	self.petTransform:SetLocalPosition(newPosX, newPosY, 0)
end

PetMoveToPoint.OnExit = function(self)
	self.phase = nil
	self.targetPos = nil
end

NetPetMoodEmotionState = DefClass("NetPetMoodEmotionState", NetPetMoodEmotionState)

NetPetMoodEmotionState.ctor = function(self, petEntity)
	self.petEntity = petEntity
end

NetPetMoodEmotionState.OnEnter = function(self)
	local emotion = self.petEntity:GetEmotion() or 1

	self.petEntity:PlayAni(emotion ~= 1 and PetAniEnum.smile or PetAniEnum.happy)

	self.stayTime = 3
end

NetPetMoodEmotionState.OnUpdate = function(self)
	self.stayTime = self.stayTime - Time.deltaTime

	if self.stayTime < 0 then
		self.petEntity:ChangeState(petBehaviorState.idle)
	end
end

NetPetMoodEmotionState.OnExit = function(self)
	self.petEntity:ActiveEffect(EffectType.smile, false)
end

PetBlindDateState = DefClass("PetBlindDateState", PetBlindDateState)

PetBlindDateState.ctor = function(self, petEntity)
	self.petEntity = petEntity
	self.moveSpeed = 10
end

PetBlindDateState.OnEnter = function(self)
	local blindDate = self.petEntity:GetBlindData()
	self.petTransform = self.petEntity:GetTransform()

	if not blindDate or not self.petTransform then
		self.phase = "finish"

		return
	end

	local petInfo = self.petEntity:GetPetInfo()
	self.moveSpeed = petInfo.speed or 10
	self.blindDate = blindDate
	self.isSuccessed = blindDate.isSuccessed
	self.targetPos = Vector3.New(blindDate.pos[1], blindDate.pos[2], 0)
	self.phase = "move"

	self:PlayMoveAnimation()
end

PetBlindDateState.PlayMoveAnimation = function(self)
	if not self.petTransform or not self.targetPos then
		return
	end

	local currentPos = self.petTransform.localPosition
	self.direction = (self.targetPos - currentPos).normalized

	self.petEntity:PlayAni(self.direction.x <= 0 and PetAniEnum.runR or PetAniEnum.runL)
end

PetBlindDateState.StartBlindDaten = function(self)
	self.phase = "beginBlindDaten"
	self.stayTime = 3
	local petAni = PetAniEnum.love

	if not self.isSuccessed then
		petAni = self.blindDate and self.blindDate.isHost and PetAniEnum.blues or PetAniEnum.angry
	end

	self.petEntity:PlayAni(petAni)

	if self.blindDate and self.blindDate.onResultStarted then
		local onResultStarted = self.blindDate.onResultStarted
		self.blindDate.onResultStarted = nil

		onResultStarted()
	end
end

PetBlindDateState.OnUpdate = function(self)
	if self.phase ~= "finish" then
		self.petEntity:ChangeState(petBehaviorState.idle)

		return
	end

	if self.phase ~= "move" then
		if not self.petTransform or not self.targetPos then
			self.petEntity:ChangeState(petBehaviorState.idle)

			return
		end

		local currentPos = self.petTransform.localPosition
		local distanceToTarget = Vector3.Distance(currentPos, self.targetPos)
		local moveDistance = self.moveSpeed * Time.deltaTime

		if distanceToTarget <= 1 or distanceToTarget < moveDistance then
			self.petTransform:SetLocalPosition(self.targetPos.x, self.targetPos.y, 0)
			self:StartBlindDaten()

			return
		end

		local newPosX = currentPos.x + self.direction.x * moveDistance
		local newPosY = currentPos.y + self.direction.y * moveDistance

		self.petTransform:SetLocalPosition(newPosX, newPosY, 0)

		return
	end

	if self.phase ~= "beginBlindDaten" then
		self.stayTime = self.stayTime - Time.deltaTime

		if self.stayTime < 0 then
			self.petEntity:ChangeState(petBehaviorState.idle)
		end
	end
end

PetBlindDateState.OnExit = function(self)
	self.phase = nil
	self.targetPos = nil
	self.blindDate = nil

	self.petEntity:ClearBlinDate()
	self.petEntity:HideAllEffect()
end
