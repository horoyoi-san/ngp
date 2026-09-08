-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\NetPetEntity.lua
-- Decompiled from: 02148_NetPetEntity.lua_9ca6bc97665a.luajit

local UpdateBeat = UpdateBeat
local GameObject = UnityEngine.GameObject

require("LX6/MiniGame/PetGame/PetActor")

local petData = require("LX6/MiniGame/PetGame/data/tbpet")
local petAccessoriesAni = require("LX6/MiniGame/PetGame/data/tbpetaccessoryani")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local petBehaviorState = PetGameEnum.Behavior
local EffectType = PetGameEnum.EffectType
local AccessoryType = PetGameEnum.AccessoryType
local PetAniEnum = PetGameEnum.PetAniEnum
local PetAnimation = PetGameEnum.PetAnimation
local accessoryTypes = {
	AccessoryType.hat,
	AccessoryType.face,
	AccessoryType.back
}
C_NetPetEntity = DefClass("C_NetPetEntity", C_NetPetEntity, C_PetActor)
local NetPetEntity = C_NetPetEntity

NetPetEntity.ctor = function(self, args)
	args = args or {}
	self.id = args.id or args.petId
	self.petId = self.id
	self.uuid = args.uuid
	self.parent = args.parent
	self.roomShadowTrans = args.roomShadowTrans
	self.displayName = args.displayName
	self.isHost = args.isHost ~= true
	self.active = true
	self.attributes = {
		["\\xa2\\xa26\\xa2i5\\xfb7"] = false,
		["L\\xa2\\xab\\xb9\\xb3"] = true,
		id = self.id,
		moodValue = args.moodValue or 100,
		hatId = self.hatId,
		faceAccId = self.faceAccId,
		backAccId = self.backAccId
	}

	self:AddUpdateEvent()
	self:InitState()
	self:LoadPetGameObject(self.parent)
end

NetPetEntity.GetUuid = function(self)
	return self.uuid
end

NetPetEntity.IsHost = function(self)
	return self.isHost
end

NetPetEntity.GetPetInfo = function(self)
	return petData[self.id]
end

NetPetEntity.InitState = function(self)
	self.states = {
		[petBehaviorState.idle] = PetIdleState.new(self),
		[petBehaviorState.walking] = PetMoveToPoint.new(self),
		[petBehaviorState.moodEmotion] = NetPetMoodEmotionState.new(self),
		[petBehaviorState.furnitureInteraction] = PetFurnitureInteractionState.new(self),
		[petBehaviorState.blindDate] = PetBlindDateState.new(self)
	}
end

NetPetEntity.ChangeState = function(self, state)
	if self.curStatus ~= state then
		return
	end

	if self.currentState == nil and self.currentState.OnExit then
		self.currentState:OnExit()
	end

	self.currentState = self.states[state]

	if self.currentState == nil and self.currentState.OnEnter then
		self.currentState:OnEnter()

		self.curStatus = state
	end
end

NetPetEntity.Update = function(self)
	if not self.petGo then
		return
	end

	if self.currentState == nil and self.currentState.OnUpdate then
		self.currentState:OnUpdate()
	end
end

NetPetEntity.GetCurState = function(self)
	return self.curStatus
end

NetPetEntity.IsIdle = function(self)
	return self.curStatus ~= petBehaviorState.idle
end

NetPetEntity.AddUpdateEvent = function(self)
	self.updateHandle = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandle)

	self.updateCloneShadowPosHandle = UpdateBeat:CreateListener(self.UpdateCloneShadowPos, self)

	UpdateBeat:AddListener(self.updateCloneShadowPosHandle)
end

NetPetEntity.RemoveUpdateEvent = function(self)
	UpdateBeat:RemoveListener(self.updateHandle)
	UpdateBeat:RemoveListener(self.updateCloneShadowPosHandle)
end

NetPetEntity.LoadPetGameObject = function(self, parent)
	if not parent then
		print_error("NetPetEntity LoadPetGameObject failed, parent is nil")

		return
	end

	self.petGoParentTrans = self.parent
	local petInfo = self.GetPetInfo(self)

	if not petInfo then
		print_error("NetPetEntity LoadPetGameObject failed, petInfo is nil:", self.id)

		return
	end

	local prefabPath = petInfo.prefab
	slot4 = gResourceManager

	slot4:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.isDestroyed then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if loadOp.asset then
			local petGameObject = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not petGameObject then
				error("Failed to instantiate pet prefab: " .. prefabPath)

				return
			end

			self:OnPetGoLoadFinish(petGameObject)

			if self.spawnLocalPosition then
				self:SetLocalPosition(self.spawnLocalPosition)
			end
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

NetPetEntity.OnPetGoLoadFinish = function(self, petGameObject)
	self.ClearPetGo(self)

	self.petGo = petGameObject
	local active = true

	if self.active == nil then
		active = self.active
	end

	petGameObject.SetActive(petGameObject, active)

	self.animator = nil

	self.ChangeState(self, petBehaviorState.idle)
	self.CloneShadow(self)
	self.LoadAccessories(self)
end

NetPetEntity.CloneShadow = function(self)
	local petTrans = self.GetTransform(self)

	if not petTrans or not self.roomShadowTrans then
		return
	end

	local petShadow = petTrans.Find(petTrans, "shadow")

	if not petShadow then
		return
	end

	local cloneShadowGo = GameObject.Instantiate(petShadow.gameObject, self.roomShadowTrans)
	self.cloneShadowTrans = cloneShadowGo.transform
	self.shadowTrans = petShadow

	petShadow.gameObject:SetActive(false)
end

NetPetEntity.Destroy = function(self)
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true
	self.attributes = nil
	self.currentState = nil

	self.RemoveUpdateEvent(self)
	self.ClearPetGo(self)

	if self.aniQueueTimer then
		self.aniQueueTimer:Stop()

		self.aniQueueTimer = nil
	end
end

NetPetEntity.ClearPetGo = function(self)
	NetPetEntity.base.ClearPetGo(self)

	if self.cloneShadowTrans and self.cloneShadowTrans.gameObject then
		GameObject.Destroy(self.cloneShadowTrans.gameObject)
	end

	self.cloneShadowTrans = nil
	self.shadowTrans = nil
end

NetPetEntity.PlayAni = function(self, petAniEnum)
	local animator = self.GetAnimator(self)

	if not animator then
		self.curPlayingAni = PetAniEnum.idle

		return false
	end

	local baseAni = PetAnimation[petAniEnum]

	if not baseAni or not animator.GetClip(animator, baseAni) then
		print_error("NetPetEntity animation clip not found:", petAniEnum)

		return false
	end

	self.curPlayingAni = petAniEnum

	animator.Play(animator, baseAni)

	if not self.acessoryAniDict then
		return true
	end

	for _, accessoryType in ipairs(accessoryTypes) do
		local accessoryAnis = self.acessoryAniDict[accessoryType]
		local accessoryAni = accessoryAnis and accessoryAnis[petAniEnum]

		if accessoryAni then
			animator.Blend(animator, accessoryAni.name)
		end
	end

	return true
end

NetPetEntity.PlayQueued = function(self, petAniEnum, nextPetAniEnum)
	local animator = self:GetAnimator()
	local baseAni = PetAnimation[petAniEnum]
	local baseAniState = baseAni and animator and animator:get_Item(baseAni)

	if not baseAniState then
		print_error("NetPetEntity animation clip not found:", petAniEnum)

		return false
	end

	self.PlayAni(self, petAniEnum)

	if self.aniQueueTimer then
		self.aniQueueTimer:Stop()
	end

	self.aniQueueTimer = Timer.New(function ()
		if not self.isDestroyed then
			self:PlayAni(nextPetAniEnum)
		end
	end, baseAniState.length, 1)

	self.aniQueueTimer:Start()

	return true
end

NetPetEntity._MatchAccessoryCurAniOnLoad = function(self, petAniEnum, accessoryAniName)
	if petAniEnum ~= self.curPlayingAni and self.animator then
		self.animator:Blend(accessoryAniName)
	end
end

NetPetEntity._loadAccessoriesAni = function(self, accessoryId, accessoryType, requestVersion)
	local animationDataId = self.id .. "_" .. accessoryId
	local accessoryAnimationData = petAccessoriesAni[animationDataId]

	if not accessoryAnimationData then
		animationDataId = "common_" .. accessoryId
		accessoryAnimationData = petAccessoriesAni[animationDataId]
	end

	if not accessoryAnimationData then
		print_error("NetPetEntity accessory animation data not found:", animationDataId)

		return
	end

	local animation = self.GetAnimator(self)

	if not animation then
		print_error("NetPetEntity animator not found")

		return
	end

	for petAniEnum, animationPath in pairs(accessoryAnimationData) do
		if petAniEnum == "id" and not string.is_null_or_empty(animationPath) then
			self._loadAccessoryAni(self, accessoryType, petAniEnum, animationPath, animation, requestVersion)
		end
	end
end

NetPetEntity.GetAnimator = function(self)
	if self.animator then
		return self.animator
	end

	if self.petGo == nil and self.petGo.transform then
		self.animator = self.petGo.transform:GetComponent("Animation")

		return self.animator
	end
end

NetPetEntity.GetTransform = function(self)
	if self.petGo then
		return self.petGo.transform
	end
end

NetPetEntity.SetActive = function(self, active)
	self.active = active

	if self.petGo then
		self.petGo:SetActive(active)
	end

	if self.cloneShadowTrans and self.cloneShadowTrans.gameObject then
		self.cloneShadowTrans.gameObject:SetActive(active)
	end
end

NetPetEntity.SetPosition = function(self, position)
	if self.petGo then
		self.petGo.transform.position = position
	end
end

NetPetEntity.SetLocalPosition = function(self, localPosition)
	self.spawnLocalPosition = localPosition

	if self.petGo then
		self.petGo.transform.localPosition = localPosition
	end
end

NetPetEntity.SetDestination = function(self, pos)
	self.destination = pos

	self.ChangeState(self, petBehaviorState.walking)
end

NetPetEntity.GetDestination = function(self)
	return self.destination
end

NetPetEntity.GetChildTrans = function(self, name)
	if self.petGo then
		return self.petGo.transform:Find(name)
	end
end

NetPetEntity.StartFurnitureInteraction = function(self, interactionData)
	if not interactionData then
		return
	end

	if self.curStatus ~= petBehaviorState.furnitureInteraction then
		self.ChangeState(self, petBehaviorState.idle)
	end

	self.furnitureInteractionData = interactionData
	self.furnitureInteractionData.interactive = true

	self.ChangeState(self, petBehaviorState.furnitureInteraction)
end

NetPetEntity.GetFurnitureInteractionData = function(self)
	return self.furnitureInteractionData
end

NetPetEntity.ClearFurnitureInteractionData = function(self)
	self.furnitureInteractionData.interactive = nil
	self.furnitureInteractionData = nil
end

NetPetEntity.SetBlindData = function(self, data)
	self.blindDate = data

	self.ChangeState(self, petBehaviorState.blindDate)
end

NetPetEntity.GetBlindData = function(self)
	return self.blindDate
end

NetPetEntity.ClearBlinDate = function(self)
	self.blindDate = nil
end

NetPetEntity.CheckShowMoodEmotion = function(self)
	return false
end

NetPetEntity.UpdateCloneShadowPos = function(self)
	if not self.active then
		return
	end

	if not self.cloneShadowTrans or not self.shadowTrans then
		return
	end

	self.cloneShadowTrans.position = self.shadowTrans.position
end

NetPetEntity.HideAllEffect = function(self)
end

NetPetEntity.SetEmotion = function(self, emotion)
	self.emotion = emotion

	self.ChangeState(self, petBehaviorState.moodEmotion)
end

NetPetEntity.GetEmotion = function(self)
	return self.emotion
end

NetPetEntity.ActiveEffect = function(self, effectType, isShow)
	local effectTrans = self.GetEffectObj(self, effectType)

	if effectTrans then
		effectTrans.SetActive(effectTrans, isShow)
	end
end

NetPetEntity.GetEffectObj = function(self, effectType)
	if effectType ~= EffectType.death then
		if not self.deathEff then
			local trans = self.GetChildTrans(self, "body/effects_death")

			if trans then
				self.deathEff = trans.gameObject
			end
		end

		return self.deathEff
	elseif effectType ~= EffectType.treat then
		if not self.treatEff then
			local trans = self.GetChildTrans(self, "body/effects_treat")

			if trans then
				self.treatEff = trans.gameObject
			end
		end

		return self.treatEff
	elseif effectType ~= EffectType.sleep then
		if not self.sleepEff then
			local trans = self.GetChildTrans(self, "body/effects_sleep")

			if trans then
				self.sleepEff = trans.gameObject
			end
		end

		return self.sleepEff
	elseif effectType ~= EffectType.bathe then
		if not self.batheEff then
			local trans = self.GetChildTrans(self, "body/effects_bathe")

			if trans then
				self.batheEff = trans.gameObject
			end
		end

		return self.batheEff
	elseif effectType ~= EffectType.stroke then
		if not self.strokeEff then
			local trans = self.GetChildTrans(self, "body/effects_stroke")

			if trans then
				self.strokeEff = trans.gameObject
			end
		end

		return self.strokeEff
	elseif effectType ~= EffectType.smile then
		if not self.smaileEff then
			local trans = self.GetChildTrans(self, "body/effects_smile")

			if trans then
				self.smaileEff = trans.gameObject
			end
		end

		return self.smaileEff
	end
end
