-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetEntity.lua
-- Decompiled from: 02133_PetEntity.lua_f0359a3c6ab1.luajit

local UpdateBeat = UpdateBeat
local GameObject = UnityEngine.GameObject
local UXTime = LTUtils.UXTime
local petAttributeData = require("LX6/MiniGame/PetGame/data/tbattribute")
local petData = require("LX6/MiniGame/PetGame/data/tbpet")
local petGameConstData = require("LX6/MiniGame/PetGame/data/tbconstants")
local petEvolution = require("LX6/MiniGame/PetGame/data/tbevolution")
local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local accessoryDatas = require("LX6/MiniGame/PetGame/data/tbaccessories")
local petAccessoriesAni = require("LX6/MiniGame/PetGame/data/tbpetaccessoryani")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local petBehaviorState = PetGameConst.Behavior
local petEmotion = PetGameConst.Emotion
local StageShowType = PetGameConst.StageShowType
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local PetAnimation = PetGameEnum.PetAnimation
local PetAniEnum = PetGameEnum.PetAniEnum
local AccessoryPoint = PetGameEnum.AccessoryPoint
local AccessoryType = PetGameEnum.AccessoryType
local EffectType = PetGameEnum.EffectType
local FurnitureType = PetGameEnum.FurnitureType
local FurniturePoint = PetGameEnum.FurniturePoint
local MaskAniType = PetGameEnum.MaskAniType
local RoomType = PetGameEnum.RoomType
local ItemType = PetGameConst.ItemType
local accessoryAttributeByType = {
	[AccessoryType.hat] = "hatId",
	[AccessoryType.face] = "faceAccId",
	[AccessoryType.back] = "backAccId"
}
local accessorySlotsByType = {
	[AccessoryType.hat] = {
		AccessoryPoint.hat
	},
	[AccessoryType.face] = {
		AccessoryPoint.face
	},
	[AccessoryType.back] = {
		AccessoryPoint.back_1,
		AccessoryPoint.back_2
	}
}
local accessoryTypes = {
	AccessoryType.hat,
	AccessoryType.face,
	AccessoryType.back
}
C_PetEntity = DefClass("C_PetEntity", C_PetEntity)
local PetEntity = C_PetEntity

local GeneratePetUuid = function()
	local timePart = math.floor(os.time()) % 4294967296.0

	return string.format("%08x-%04x-4%03x-%04x-%04x%08x", timePart, math.random(0, 65535), math.random(0, 4095), 32768 + math.random(0, 16383), math.random(0, 65535), math.random(0, 2147483647))
end

PetEntity.ctor = function(self, args)
	self.attributes = {
		uuid = type(args.uuid) ~= "string" and args.uuid == "" and args.uuid or GeneratePetUuid(),
		socialFavorByUuid = type(args.socialFavorByUuid) ~= "table" and args.socialFavorByUuid or {},
		socialPlayRewardCount = math.max(0, math.floor(tonumber(args.socialPlayRewardCount) or 0)),
		socialPlayRewardDayKey = args.socialPlayRewardDayKey,
		socialPlayCount = math.max(0, math.floor(tonumber(args.socialPlayCount) or 0)),
		accessoryNum = math.max(0, math.floor(tonumber(args.accessoryNum) or 0)),
		id = args.id or petGameConstData.data.InitialPetId
	}

	if args.reborn == nil then
		self.attributes.reborn = args.reborn
	elseif self.attributes.id ~= petGameConstData.data.rebornPetId then
		self.attributes.reborn = 1
	else
		self.attributes.reborn = 0
	end

	local hasClaimedPet = args.hasClaimedPet

	if hasClaimedPet ~= nil then
		hasClaimedPet = args.id == nil
	end

	self.attributes.hasClaimedPet = hasClaimedPet
	self.attributes.regionId = args.regionId or 1001
	self.attributes.age = args.age or 0
	local curTimeSeconds = gPetGameTime:Now()
	self.attributes.birthdate = args.birthdate or curTimeSeconds
	self.attributes.lastUpdateAgeTime = args.lastUpdateAgeTime or curTimeSeconds
	self.attributes.hungerValue = args.hungerValue or gPetAttributeUtils:GetDefualtAttr("hungerValue")
	self.attributes.moodValue = args.moodValue or gPetAttributeUtils:GetDefualtAttr("moodValue")
	self.attributes.cleanlinessValue = args.cleanlinessValue or gPetAttributeUtils:GetDefualtAttr("cleanlinessValue")
	self.attributes.healthValue = args.healthValue or gPetAttributeUtils:GetDefualtAttr("healthValue")
	self.attributes.happinessValue = args.happinessValue or gPetAttributeUtils:GetDefualtAttr("happinessValue")
	self.attributes.satiationCount = args.satiationCount or gPetAttributeUtils:GetDefualtAttr("satiationCount")
	self.attributes.pleasureCount = args.pleasureCount or gPetAttributeUtils:GetDefualtAttr("pleasureCount")
	self.attributes.careMistakeCount = args.careMistakeCount or gPetAttributeUtils:GetDefualtAttr("careMistakeCount")
	self.attributes.evolutionGene = args.evolutionGene or {}
	self.attributes.foodCharacteristics1 = args.foodCharacteristics1 or gPetAttributeUtils:GetDefualtAttr("foodCharacteristics1")
	self.attributes.foodCharacteristics2 = args.foodCharacteristics2 or gPetAttributeUtils:GetDefualtAttr("foodCharacteristics2")
	self.attributes.foodCharacteristics3 = args.foodCharacteristics3 or gPetAttributeUtils:GetDefualtAttr("foodCharacteristics3")
	self.attributes.foodCharacteristics4 = args.foodCharacteristics4 or gPetAttributeUtils:GetDefualtAttr("foodCharacteristics4")
	self.attributes.foodCharacteristics5 = args.foodCharacteristics5 or gPetAttributeUtils:GetDefualtAttr("foodCharacteristics5")
	self.attributes.customName = args.customName or ""
	self.attributes.poopNum = args.poopNum or 0
	self.attributes.aheadOfSleep = args.aheadOfSleep or false
	self.attributes.aheadOfWakeUp = args.aheadOfWakeUp or false
	self.attributes.isSicked = args.isSicked or false
	self.attributes.hatId = args.hatId or 0
	self.attributes.faceAccId = args.faceAccId or 0
	self.attributes.backAccId = args.backAccId or 0
	self.attributes.deathAchievementRecorded = args.deathAchievementRecorded ~= true

	if args.alive == nil then
		self.attributes.alive = args.alive
	else
		self.attributes.alive = true
	end

	self:InitBag(args.bagData)

	self.curStatus = args.status or petBehaviorState.idle
	self.emotion = args.emotion or petEmotion.normal
	self.active = true
	self.accessoryRequestVersion = {}
	self.isDestroyed = false
	self.Inited = false

	self:AddUpdateEvent()
	self:InitState()

	if not self.attributes.alive then
		self.OnPetDie(self)
	end
end

PetEntity.SetRegion = function(self, regionId)
	self.attributes.regionId = regionId
	self.attributes.hasClaimedPet = true
end

PetEntity.GetRegion = function(self)
	return self.attributes.regionId or 1001
end

PetEntity.HasClaimedPet = function(self)
	return self.attributes.hasClaimedPet ~= true
end

PetEntity.InitBag = function(self, bagData)
	self.petBag = PetBag.new(bagData)

	if self.attributes.age >= 1 then
		local initData = petGameConstData.data.initBag

		for _, item in pairs(initData) do
			if self.petBag:GetItemCount(item.id) >= 1 then
				self.petBag:AddItem(item.id, item.num)
			end
		end
	end

	self.petBag:PrintContents()
end

PetEntity.GetPetId = function(self)
	return self.attributes.id
end

PetEntity.ChangePetId = function(self, petId)
	if type(petId) == "number" or petId % 1 == 0 or not petData[petId] then
		return false
	end

	if self.attributes.id ~= petId then
		return true
	end

	self.attributes.id = petId
	self.attributes.age = 1

	if self.petGo and self.petGoParentTrans then
		self.LoadPetGameObject(self, self.petGoParentTrans)
	end

	return true
end

PetEntity.GetUuid = function(self)
	return self.attributes.uuid
end

PetEntity.GetSocialFavorByUuid = function(self, petUuid)
	if type(petUuid) == "string" or petUuid ~= "" then
		return 0
	end

	return tonumber(self.attributes.socialFavorByUuid[petUuid]) or 0
end

PetEntity.AddSocialFavorByUuid = function(self, petUuid, value)
	if type(petUuid) == "string" or petUuid ~= "" then
		return 0
	end

	local newValue = math.max(0, self:GetSocialFavorByUuid(petUuid) + (tonumber(value) or 0))
	self.attributes.socialFavorByUuid[petUuid] = newValue

	return newValue
end

PetEntity.GetPetInfo = function(self)
	local id = self.attributes.id
	local petInfo = petData[id]

	return petInfo
end

PetEntity.GetPetLv = function(self)
	local petInfo = self.GetPetInfo(self)

	return petInfo.level
end

PetEntity.IsMatureForm = function(self)
	return PetGameConst.MatureFormLv > self:GetPetLv()
end

PetEntity.GetPetName = function(self)
	if self.attributes.customName and self.attributes.customName == "" then
		return self.attributes.customName
	end

	local petInfo = self.GetPetInfo(self)

	return self.GetLanguageText(self, petInfo.name)
end

PetEntity.SetCustomName = function(self, name)
	self.attributes.customName = name or ""
end

PetEntity.GetLanguageText = function(self, id)
	return gPetGameMultilingual:GetText(id)
end

PetEntity.DelayLoadPet = function(self, parent, delay)
	self.petGoParentTrans = parent
	local petInfo = self:GetPetInfo()
	local prefabPath = petInfo.prefab
	slot5 = gCoroutineManager

	slot5:StartCoroutine(function ()
		local loadOp = gResourceManager:LoadAssetAsync(prefabPath, typeof(UnityEngine.GameObject))

		coroutine.yield(loadOp)
		coroutine.yield(gWaitableUtils.WaitTime(delay or 0))

		if self.isDestroyed then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			print_error("宠物 Prefab 加载失败：", prefabPath)

			return
		end

		local petGameObject = GameObject.Instantiate(loadOp.asset, self.petGoParentTrans or parent)

		if not petGameObject then
			print_error("宠物 Prefab 实例化失败：", prefabPath)

			return
		end

		self:OnPetGoLoadFinish(petGameObject)
	end)
end

PetEntity.LoadPetGameObject = function(self, parent, isLvUp)
	self.petGoParentTrans = parent
	local petInfo = self:GetPetInfo()
	local prefabPath = petInfo.prefab
	slot5 = gResourceManager

	slot5:LoadAssetWithCallBack(prefabPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.isDestroyed then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if loadOp.asset then
			local petGameObject = UnityEngine.GameObject.Instantiate(loadOp.asset, self.petGoParentTrans or parent)

			if not petGameObject then
				error("Failed to instantiate pet prefab: " .. prefabPath)

				return
			end

			self:OnPetGoLoadFinish(petGameObject, isLvUp)
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

PetEntity.OnPetGoLoadFinish = function(self, petGameObject, isLvUp)
	self:ClearPetGo()

	self.petGo = petGameObject

	petGameObject:SetActive(self.active == false)
	self:ClearPetEffects(petGameObject)

	local lastStatus = self.curStatus
	self.curStatus = 0
	self.animator = nil

	if isLvUp then
		self.ChangeState(self, petBehaviorState.idle)
	else
		self.ChangeState(self, lastStatus)
	end

	self.InitTouch(self)
	self.CloneShadow(self)
	self.LoadAccessories(self)
end

PetEntity.ClearPetEffects = function(self, petGo)
	if not petGo then
		return
	end

	local petTrans = petGo.transform
	local effects_treat = petTrans.Find(petTrans, "body/effects_treat")

	if effects_treat then
		effects_treat.gameObject:SetActive(false)
	end

	local effects_sleep = petTrans.Find(petTrans, "body/effects_sleep")

	if effects_sleep then
		effects_sleep.gameObject:SetActive(false)

		local sleepAni = effects_sleep:GetChild(0)

		if sleepAni then
			sleepAni.gameObject:SetActive(false)
		end
	end

	local effects_up = petTrans.Find(petTrans, "body/effects_up")

	if effects_up then
		effects_up.gameObject:SetActive(false)
	end

	local effects_dirty = petTrans.Find(petTrans, "body/effects_dirty")

	if effects_dirty then
		effects_dirty.gameObject:SetActive(false)
	end
end

PetEntity.HideAllEffect = function(self)
	self.ClearPetEffects(self, self.petGo)
end

PetEntity.InitTouch = function(self)
	local petTouchAreaTrans = self.petGo.transform:Find("body/touchArea")

	if not petTouchAreaTrans then
		return
	end

	local uButton = petTouchAreaTrans.GetComponent(petTouchAreaTrans, "UButton")

	uButton.luaClick = function()
		self:OnTouchAreaClick()
	end
end

PetEntity.OnTouchAreaClick = function(self)
	if self.curStatus ~= petBehaviorState.defecatePrepare then
		self.TryUseToilet(self)

		return
	end

	if self.curStatus ~= petBehaviorState.idle or self.curStatus ~= petBehaviorState.walking then
		self.ChangeState(self, petBehaviorState.interaction)
	end
end

PetEntity.AddUpdateEvent = function(self)
	if self.Inited then
		return
	end

	self.Inited = true
	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)

	self.updateCloneShadowPosHandler = UpdateBeat:CreateListener(self.UpdateCloneShadowPos, self)

	UpdateBeat:AddListener(self.updateCloneShadowPosHandler)
end

PetEntity.RemoveUpdateEvent = function(self)
	if not self.Inited then
		return
	end

	self.Inited = nil

	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end

	if self.updateCloneShadowPosHandler then
		UpdateBeat:RemoveListener(self.updateCloneShadowPosHandler)

		self.updateCloneShadowPosHandler = nil
	end
end

PetEntity.SetEmotion = function(self, newEmotion)
	if newEmotion ~= PetGameConst.Emotion.normal or newEmotion ~= PetGameConst.Emotion.happy or newEmotion ~= PetGameConst.Emotion.frustrated then
		self.emotion = newEmotion
	else
		error("Invalid emotion: " .. tostring(newEmotion))
	end
end

PetEntity.GetEmotion = function(self)
	return self.emotion
end

PetEntity.GetPetData = function(self)
	return self.attributes
end

PetEntity.GetPetDataCopy = function(self)
	return table.deepcopy(self.attributes)
end

PetEntity.GetAttribute = function(self, attrName)
	return self.attributes[attrName] or 0
end

PetEntity.GetAttributeById = function(self, attrId)
	local attrName = gPetAttributeUtils:GetAttributeNameById(attrId)

	if not attrName then
		return 0
	end

	return self.attributes[attrName] or 0
end

PetEntity.UpdateAttributeByName = function(self, attrName, val)
	if not self.attributes[attrName] then
		print_error("PetEntity UpdateAttributeByName Error:", attrName)

		return
	end

	local maxVal = gPetAttributeUtils:GetMaxAttr(attrName)
	local oldVal = self.attributes[attrName]
	local curVal = oldVal + val

	if curVal >= 0 then
		curVal = 0
	end

	if maxVal <= curVal then
		self.attributes[attrName] = curVal
	else
		self.attributes[attrName] = maxVal

		if oldVal == maxVal then
			self.OnAttributeArriveMax(self, attrName)
		end
	end
end

PetEntity.OnAttributeArriveMax = function(self, attrName)
	if attrName ~= "hungerValue" then
		self.attributes.satiationCount = self.attributes.satiationCount + 1
	elseif attrName ~= "moodValue" then
		self.attributes.pleasureCount = self.attributes.pleasureCount + 1
	elseif attrName ~= "foodCharacteristics1" or attrName ~= "foodCharacteristics2" or attrName ~= "foodCharacteristics3" or attrName ~= "foodCharacteristics4" or attrName ~= "foodCharacteristics5" then
		self.attributes[attrName] = 0
		local maxNum = gPetAttributeUtils:GetMaxAttr("evolutionGene")
		local evoNum = #self.attributes.evolutionGene

		if maxNum <= evoNum then
			local id = gPetAttributeUtils:GetAttributeIdByName(attrName)

			table.insert(self.attributes.evolutionGene, id)
		end
	end
end

PetEntity.UpdateAttributeByID = function(self, attrId, val)
	local attrName = gPetAttributeUtils:GetAttributeNameById(attrId)

	if not attrName then
		print_error("PetEntity UpdateAttributeByID Error:", attrId)

		return
	end

	self.UpdateAttributeByName(self, attrName, val)
end

PetEntity.IsAttributeMaxVal = function(self, attrName)
	local val = self:GetAttribute(attrName)
	local maxVal = gPetAttributeUtils:GetMaxAttr(attrName)

	print("PetEntity IsAttributeMaxVal:", val, maxVal)

	return maxVal > val
end

PetEntity.IsFull = function(self)
	return self.IsAttributeMaxVal(self, "hungerValue")
end

PetEntity.GetMoney = function(self)
	return self.petBag:GetItemCount(PetGameConst.MoneyItemId)
end

PetEntity.AddMoney = function(self, amount)
	self.petBag:AddItem(PetGameConst.MoneyItemId, amount)
end

PetEntity.ConsumeMoney = function(self, amount)
	self.petBag:RemoveItem(PetGameConst.MoneyItemId, amount)
end

PetEntity.GetFreeFood = function(self)
	local petInfo = self.GetPetInfo(self)

	return petInfo.FreeFood
end

PetEntity.GetAllFood = function(self)
	return self.petBag:GetItemsByType(PetGameConst.ItemType.food)
end

PetEntity.GetFreeSnack = function(self)
	return petGameConstData.data.freeSnack
end

PetEntity.GetAllSnack = function(self)
	return self.petBag:GetItemsByType(ItemType.snack)
end

PetEntity.GetItemCount = function(self, itemID)
	return self.petBag:GetItemCount(itemID)
end

PetEntity.GetFreeToys = function(self)
	local petInfo = self.GetPetInfo(self)

	return petInfo.FreeToys
end

PetEntity.GetAllToys = function(self)
	return self.petBag:GetItemsByType(PetGameConst.ItemType.toy)
end

PetEntity.GetItemsByType = function(self, itemType, subType)
	return self.petBag:GetItemsByType(itemType, subType)
end

PetEntity.RemoveItem = function(self, itemId, count)
	self.petBag:RemoveItem(itemId, count)
end

PetEntity.AddItem = function(self, itemId, count)
	self.petBag:AddItem(itemId, count)
	self:UpdateAccessoryNum()
end

PetEntity.ResetPetTime = function(self)
	local now = gPetGameTime:Now()

	if now >= self.attributes.lastUpdateAgeTime then
		self.attributes.lastUpdateAgeTime = now
	end
end

PetEntity.InitPetBirthTime = function(self)
	self.attributes.lastUpdateAgeTime = gPetGameTime:Now()
end

PetEntity.CalculteOfflineData = function(self)
	if self.isCalOfflineTimeed then
		return
	end

	self.isCalOfflineTimeed = true
	local currentTime = gPetGameTime:Now()
	local offlineTime = currentTime - self.attributes.lastUpdateAgeTime

	if offlineTime <= 0 then
		self.AddLife(self, offlineTime, currentTime, true)
	end
end

PetEntity.UpdatePetLife = function(self)
	local currentTime = gPetGameTime:Now()
	local time = currentTime - self.attributes.lastUpdateAgeTime

	if time >= 1 then
		if time >= 0 then
			self.attributes.lastUpdateAgeTime = currentTime
		end

		return
	end

	self.UpdateAttribute(self, currentTime)
	self.AddLife(self, time, currentTime)
end

PetEntity.UpdateAttribute = function(self, currentTime)
	if not self.costAttr then
		self.costAttr = {
			costHunger = currentTime,
			costHappiness = currentTime,
			costHealth = currentTime,
			growHealth = currentTime
		}

		return
	end

	if self.IsSleeping(self) then
		return
	end

	local petInfo = self.GetPetInfo(self)

	self.CostHungerValue(self, currentTime, petInfo)
	self.CostHappinessValue(self, currentTime, petInfo)
	self.CostHealthValue(self, currentTime, petInfo)
	self.AddHealthValue(self, currentTime, petInfo)
end

PetEntity.CostHungerValue = function(self, currentTime, petInfo)
	local intval = petInfo.hungerCost.intval

	if intval <= currentTime - self.costAttr.costHunger then
		return
	end

	self.costAttr.costHunger = currentTime

	if self.attributes.hungerValue >= 1 then
		self.PassStool(self)

		return
	end

	local cost = petInfo.hungerCost.cost
	self.attributes.hungerValue = self.attributes.hungerValue - cost

	if self.attributes.hungerValue >= 0 then
		self.attributes.hungerValue = 0

		self.AddMistakeCount(self)

		return
	end

	self.PassStool(self)
end

PetEntity.CostHappinessValue = function(self, currentTime, petInfo)
	local intval = petInfo.happinessCost.intval

	if intval <= currentTime - self.costAttr.costHappiness then
		return
	end

	self.costAttr.costHappiness = currentTime

	if self.attributes.moodValue >= 1 then
		return
	end

	local cost = petInfo.happinessCost.cost
	self.attributes.moodValue = self.attributes.moodValue - cost

	if self.attributes.moodValue >= 0 then
		self.attributes.moodValue = 0

		self.AddMistakeCount(self)
	end
end

PetEntity.CostHealthValue = function(self, currentTime, petInfo)
	if self.CheckPetHealth(self) then
		return
	end

	local intval = petInfo.healthCost.intval

	if intval <= currentTime - self.costAttr.costHealth then
		return
	end

	self.costAttr.costHealth = currentTime
	local cost = petInfo.healthCost.cost
	self.attributes.healthValue = self.attributes.healthValue - cost

	if self.attributes.healthValue < 0 then
		self.attributes.healthValue = 0

		self.OnPetDie(self)
	end
end

PetEntity.AddHealthValue = function(self, currentTime, petInfo)
	if not self.CheckPetHealth(self) then
		return
	end

	local intval = petInfo.healthGrow.intval

	if intval <= currentTime - self.costAttr.growHealth then
		return
	end

	self.costAttr.growHealth = currentTime
	local cost = petInfo.healthGrow.grow
	self.attributes.healthValue = self.attributes.healthValue + cost
	local maxVal = gPetAttributeUtils:GetMaxAttr("healthValue")

	if maxVal >= self.attributes.healthValue then
		self.attributes.healthValue = maxVal
	end
end

PetEntity.CheckPetHealth = function(self)
	if self.attributes.isSicked then
		return false
	end

	if self.attributes.hungerValue >= 1 then
		return false
	end

	if self.attributes.moodValue >= 1 then
		return false
	end

	return true
end

PetEntity.AddMistakeCount = function(self)
	local maxVal = gPetAttributeUtils:GetMaxAttr("careMistakeCount")
	self.attributes.careMistakeCount = self.attributes.careMistakeCount + 1

	if maxVal >= self.attributes.careMistakeCount then
		self.attributes.careMistakeCount = maxVal
	end
end

PetEntity.AddLife = function(self, time, updateTimeStamp, noDieEvent)
	self.attributes.lastUpdateAgeTime = updateTimeStamp
	self.attributes.age = self.attributes.age + time
	local isEvolved = false
	local isDeath = false
	local beforePetId, petId = nil

	while not isDeath and self.CheckEvolution(self) do
		isDeath, beforePetId, petId = self.EvolvePet(self, noDieEvent)
		isEvolved = true
	end

	if isEvolved then
		local petInfo = self.GetPetInfo(self)

		if petInfo.level ~= 2 then
			self.ChangeState(self, petBehaviorState.birth)
		else
			if self.petGo == nil then
				self.LoadPetGameObject(self, self.petGoParentTrans, true)
			end

			if not isDeath then
				local args = {
					type = StageShowType.levelUp,
					beforePetId = beforePetId,
					afterPetId = petId
				}

				gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)
				gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
					["n;m^"] = 1,
					val = petId
				})
			end
		end

		self.ResetArributesByEvolution(self)
	end

	if isDeath then
		self.OnPetDie(self)
	end
end

PetEntity.CheckEvolution = function(self)
	local petInfo = self:GetPetInfo()
	local evolutionAge = petInfo.lifespan or 0

	if evolutionAge <= 0 and evolutionAge < self.attributes.age then
		return true
	end

	return false
end

PetEntity.EvolvePet = function(self, noDieEvent)
	local evoData = self:ChooseEvolutionByWeight()
	evoData = evoData or self:GetDefulatEvolutionData()

	if not evoData then
		return true
	end

	local beforePetId = self.attributes.id
	local petId = evoData.PetId
	self.attributes.id = petId

	return false, beforePetId, petId
end

PetEntity.ChooseEvolutionByWeight = function(self)
	local petInfo = self.GetPetInfo(self)
	local evolutionOptions = petInfo.evolution

	if not evolutionOptions or #evolutionOptions ~= 0 then
		return nil
	end

	local totalWeight = 0
	local evolutionList = {}

	for _, id in pairs(evolutionOptions) do
		local evoData = petEvolution[id]

		if evoData and self.CheckEvolutionPhase(self, evoData.Phase) then
			table.insert(evolutionList, evoData)

			totalWeight = totalWeight + (evoData.weight or 0)
		end
	end

	local randomWeight = math.random() * totalWeight
	local cumulativeWeight = 0

	for _, evoData in ipairs(evolutionList) do
		cumulativeWeight = cumulativeWeight + (evoData.weight or 0)

		if randomWeight < cumulativeWeight then
			return evoData
		end
	end

	return nil
end

PetEntity.CheckEvolutionPhase = function(self, phaseList)
	if not phaseList then
		return true
	end

	for _, phase in ipairs(phaseList) do
		if phase.tAttr ~= 9 then
			return self.CheckEvoGene(self, phase)
		else
			local mTattrVal = self.GetAttributeById(self, phase.tAttr)

			if mTattrVal <= phase.miniVal or phase.maxVal >= mTattrVal then
				return false
			end
		end
	end

	return true
end

PetEntity.CheckEvoGene = function(self, phase)
	local evolutionGene = self.attributes.evolutionGene
	local tGeneId = phase.tSubAttr
	local count = 0

	for i, geneId in pairs(evolutionGene) do
		if tGeneId ~= geneId then
			count = count + 1
		end
	end

	if count <= phase.miniVal or phase.maxVal >= count then
		return false
	end

	return true
end

PetEntity.GetDefulatEvolutionData = function(self)
	local petInfo = self.GetPetInfo(self)
	local evoId = petInfo.defualtEvo

	if evoId ~= 0 then
		return nil
	end

	local evoData = petEvolution[evoId]

	return evoData
end

PetEntity.ResetArributesByEvolution = function(self)
	for key, attrData in pairs(petAttributeData) do
		if attrData.Reset then
			if key ~= "evolutionGene" then
				self.attributes[key] = {}
			else
				self.attributes[key] = attrData.Initial
			end
		end
	end
end

PetEntity.OnPetDie = function(self)
	for _, attributeName in pairs(accessoryAttributeByType) do
		local accessoryId = self.attributes[attributeName] or 0

		if accessoryId <= 0 then
			self.AddItem(self, accessoryId, 1)

			self.attributes[attributeName] = 0
		end
	end

	if not self.attributes.deathAchievementRecorded then
		self.attributes.deathAchievementRecorded = true

		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
			["\\x98ij"] = 1,
			["n;m^"] = 8
		})
	end

	self.attributes.alive = false

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_ON_PET_DIE)
end

PetEntity.IsAlive = function(self)
	return self.attributes.alive
end

PetEntity.GetAnimator = function(self)
	if self.animator then
		return self.animator
	end

	if self.petGo == nil and self.petGo.transform then
		self.animator = self.petGo.transform:GetComponent("Animation")

		return self.animator
	end
end

PetEntity.RefreshAni = function(self)
	if not self.curPlayingAni then
		return
	end

	self.PlayAni(self, self.curPlayingAni)
end

PetEntity.PlayAni = function(self, petAniEnum)
	local animator = self.GetAnimator(self)

	if not animator then
		return
	end

	local baseAni = PetAnimation[petAniEnum]

	if not baseAni or not animator.GetClip(animator, baseAni) then
		print_error("宠物身上找不到动画 clip：", petAniEnum)

		return
	end

	self.curPlayingAni = petAniEnum

	animator.Play(animator, baseAni)

	if self._IsSleepAnimation(self, petAniEnum) then
		self.HideAllAccessories(self)

		return
	end

	for _, accessoryType in ipairs(accessoryTypes) do
		local accessoryAnis = self.acessoryAniDict and self.acessoryAniDict[accessoryType]
		local accessoryAni = accessoryAnis and accessoryAnis[petAniEnum]

		if accessoryAni then
			animator.Blend(animator, accessoryAni.name)
		end
	end
end

PetEntity.PlayAniNextFrame = function(self, petAniEnum, expectedState)
	self.curPlayingAni = petAniEnum

	if self._IsSleepAnimation(self, petAniEnum) then
		self.HideAllAccessories(self)
	end

	slot3 = gCoroutineManager

	slot3:StartCoroutine(function ()
		coroutine.yield(gWaitableUtils.WaitTime(0))

		if self.isDestroyed or expectedState and self.curStatus == expectedState then
			return
		end

		self:PlayAni(petAniEnum)
	end)
end

PetEntity.PlayQueued = function(self, petAniEnum, petAniEnum2)
	local animator = self.GetAnimator(self)

	if not animator then
		return
	end

	local baseAni = PetAnimation[petAniEnum]
	local nextAni = PetAnimation[petAniEnum2]

	if not baseAni or not animator.GetClip(animator, baseAni) then
		print_error("宠物身上找不到动画 clip：", petAniEnum)

		return
	end

	if not nextAni or not animator.GetClip(animator, nextAni) then
		print_error("宠物身上找不到动画 clip：", petAniEnum2)

		return
	end

	animator.PlayQueued(animator, baseAni, 2)
	animator.PlayQueued(animator, nextAni)
end

PetEntity._MatchAccessoryCurAniOnLoad = function(self, petAniEnum, accessoryAniName)
	if petAniEnum == self.curPlayingAni then
		return
	end

	if self._IsSleepAnimation(self, petAniEnum) then
		self.HideAllAccessories(self)

		return
	end

	if self.animator then
		self.animator:Blend(accessoryAniName)
	end
end

PetEntity.Destroy = function(self)
	self.isDestroyed = true

	self._InvalidateAllAccessoryRequests(self)

	self.attributes = nil
	self.currentState = nil
	self.isCalOfflineTimeed = nil

	self.RemoveUpdateEvent(self)
	self.ClearPetGo(self)
end

PetEntity.ClearPetGo = function(self)
	self._InvalidateAllAccessoryRequests(self)

	for _, accessoryType in ipairs(accessoryTypes) do
		self._ClearAccessory(self, accessoryType)
	end

	if self.petGo then
		GameObject.Destroy(self.petGo)

		self.petGo = nil
	end

	self.animator = nil
	self.dirtyEff = nil

	if self.cloneShadowTrans and self.cloneShadowTrans.gameObject then
		GameObject.Destroy(self.cloneShadowTrans.gameObject)
	end

	self.cloneShadowTrans = nil
	self.shadowTrans = nil
	self.acessoryGoDict = nil
	self.acessoryAniDict = nil

	self.ClearEffectObj(self)
end

PetEntity.InitState = function(self)
	self.states = {
		[petBehaviorState.crossState] = PetFadeState.new(self),
		[petBehaviorState.idle] = PetIdleState.new(self),
		[petBehaviorState.birth] = PetBirthState.new(self),
		[petBehaviorState.walking] = PetWalkingState.new(self),
		[petBehaviorState.sleeping] = PetSleepingState.new(self),
		[petBehaviorState.eating] = PetIdleState.new(self),
		[petBehaviorState.playToy] = PetIdleState.new(self),
		[petBehaviorState.bathe] = PetIdleState.new(self),
		[petBehaviorState.treat] = PetIdleState.new(self),
		[petBehaviorState.death] = PetDeadState.new(self),
		[petBehaviorState.fullEmotion] = PetFullState.new(self),
		[petBehaviorState.lvUp] = PetLvUpState.new(self),
		[petBehaviorState.sick] = PetSickState.new(self),
		[petBehaviorState.interaction] = PetInteractionState.new(self),
		[petBehaviorState.moodEmotion] = MoodEmotionState.new(self),
		[petBehaviorState.furnitureInteraction] = PetFurnitureInteractionState.new(self),
		[petBehaviorState.defecatePrepare] = PetDefecatePrepareState.new(self)
	}
end

PetEntity.CrossState = function(self, state)
	self.nextState = state

	self.ChangeState(self, petBehaviorState.crossState)
end

PetEntity.GetNextState = function(self)
	return self.nextState
end

PetEntity.ChangeState = function(self, state)
	if self.curStatus ~= state then
		return
	end

	if self.curStatus ~= petBehaviorState.birth then
		self.LoadPetGameObject(self, self.petGoParentTrans, true)
	end

	if self.attributes.isSicked and state ~= petBehaviorState.idle then
		state = petBehaviorState.sick
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

PetEntity.GetState = function(self)
	return self.curStatus, self.currentState
end

PetEntity.Update = function(self)
	if not self.active or not self.attributes.alive or not self.petGo then
		return
	end

	self.UpdatePetLife(self)
	self.UpdateDirtyEffect(self)

	if self.CheckSleeping(self) then
		return
	elseif self.curStatus ~= petBehaviorState.idle then
		if self.attributes.isSicked then
			self.EnterSickState(self)

			return
		end

		if self.CheckMove(self) then
			self.ChangeState(self, petBehaviorState.walking)

			return
		end

		if self.CheckFurnitureInteraction(self) then
			return
		end

		if self.CheckShowMoodEmotion(self) then
			self.ChangeState(self, petBehaviorState.moodEmotion)

			return
		end
	end

	if self.currentState == nil and self.currentState.OnUpdate then
		self.currentState:OnUpdate()
	end
end

PetEntity.CheckSleeping = function(self)
	local nowDateTime = UXTime.UnixTimeToDateTime(gPetGameTime:Now())
	local isWakeFulneeTime = self:IsWakeFulnessTime(nowDateTime)
	local inSleeping = self:IsSleeping()

	if inSleeping then
		return self.AutoWakeupOnTime(self, inSleeping, isWakeFulneeTime)
	else
		return self.AutoEnterSleepOnTime(self, inSleeping, isWakeFulneeTime)
	end
end

PetEntity.AutoEnterSleepOnTime = function(self, inSleeping, isWakeFulneeTime)
	if inSleeping then
		return false
	end

	if isWakeFulneeTime then
		return false
	end

	self.Go2Sleep(self)

	return true
end

PetEntity.AutoWakeupOnTime = function(self, inSleeping, isWakeFulneeTime)
	if not inSleeping then
		return false
	end

	if not isWakeFulneeTime then
		return false
	end

	self.WakeUp(self)

	return true
end

PetEntity.IsWakeFulnessTime = function(self, curDateTime)
	local wakefulnesstime = petGameConstData.data.Wakefulness
	local startTime = wakefulnesstime.startTime
	local endTime = wakefulnesstime.endTime

	if self.attributes.aheadOfWakeUp then
		startTime = petGameConstData.data.RemindWakeUpTime.startTime
	end

	if self.attributes.aheadOfSleep then
		endTime = petGameConstData.data.RemindSleepTime.startTime
	end

	if startTime < curDateTime.Hour and curDateTime.Hour >= endTime then
		return true
	end

	return false
end

PetEntity.AheadOfGo2Sleep = function(self)
	self.attributes.aheadOfSleep = true

	self.Go2Sleep(self)
end

PetEntity.AheadOfWakeUp = function(self)
	self.attributes.aheadOfWakeUp = true

	self.WakeUp(self)
end

PetEntity.Go2Sleep = function(self)
	self:ChangeState(petBehaviorState.sleeping)

	self.attributes.aheadOfWakeUp = false

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_SHOW_UI_MASK, MaskAniType.StageFadeIn)

	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local roomManager = currentGame and currentGame.roomManager

	if roomManager then
		roomManager:ChangeRoom(RoomType.BedRoom)

		local bed = roomManager:GetRoomFurnitureInfoByType(FurnitureType.Bed, RoomType.BedRoom)
		local petFollow = bed and bed.petFollow

		if not petFollow and bed and bed.furnitureGo then
			petFollow = bed.furnitureGo.transform:Find(FurniturePoint.petFollow)
		end

		if petFollow then
			self.SetPosition(self, petFollow.position)
		end
	end
end

PetEntity.WakeUp = function(self)
	self.ChangeState(self, petBehaviorState.idle)

	self.attributes.aheadOfSleep = false
end

PetEntity.IsSleeping = function(self)
	return self.curStatus ~= petBehaviorState.sleeping
end

PetEntity.CheckMove = function(self)
	local petInfo = self.GetPetInfo(self)

	if petInfo.level ~= 1 then
		return false
	end

	self.lastMoveCheckTime = self.lastMoveCheckTime or os.time()

	if os.time() - self.lastMoveCheckTime >= PetGameConst.moveCheckTime then
		return false
	end

	self.lastMoveCheckTime = os.time()

	return math.random(0, 100) <= PetGameConst.moveRate
end

PetEntity.CheckShowMoodEmotion = function(self)
	local petInfo = self.GetPetInfo(self)

	if petInfo.level ~= 1 or self.attributes.isSicked then
		return false
	end

	self.lastMoodEmotionCheckTime = self.lastMoodEmotionCheckTime or os.time()

	if os.time() - self.lastMoodEmotionCheckTime >= PetGameConst.showMoodEmotionCheckTime then
		return false
	end

	self.lastMoodEmotionCheckTime = os.time()

	return math.random(0, 100) <= PetGameConst.showMoodEmotionRate
end

PetEntity.CheckFurnitureInteraction = function(self)
	local petInfo = self.GetPetInfo(self)

	if petInfo.level ~= 1 or self.attributes.isSicked then
		return false
	end

	self.lastFurnitureInteractionCheckTime = self.lastFurnitureInteractionCheckTime or os.time()

	if os.time() - self.lastFurnitureInteractionCheckTime >= PetGameConst.furnitureInteractionCheckTime then
		return false
	end

	self.lastFurnitureInteractionCheckTime = os.time()

	if PetGameConst.furnitureInteractionRate >= math.random(1, 100) then
		return false
	end

	local interactionData = self.ChooseFurnitureInteraction(self)

	if not interactionData then
		return false
	end

	self.StartFurnitureInteraction(self, interactionData)

	return true
end

PetEntity.ChooseFurnitureInteraction = function(self)
	if not gPetGameManager or not gPetGameManager.currentGame then
		return nil
	end

	local roomManager = gPetGameManager.currentGame:GetRoomManager()

	if not roomManager or not roomManager.ChooseCurrentFurnitureInteraction then
		return nil
	end

	return roomManager.ChooseCurrentFurnitureInteraction(roomManager)
end

PetEntity.StartFurnitureInteraction = function(self, interactionData)
	if not interactionData then
		return
	end

	local needLv = interactionData.conf.unlockLevel
	local petLv = self.GetPetLv(self)

	if petLv >= needLv then
		return
	end

	if self.curStatus ~= petBehaviorState.furnitureInteraction then
		self.ChangeState(self, petBehaviorState.idle)
	end

	self.furnitureInteractionData = interactionData

	self.ChangeState(self, petBehaviorState.furnitureInteraction)
end

PetEntity.GetFurnitureInteractionData = function(self)
	return self.furnitureInteractionData
end

PetEntity.ClearFurnitureInteractionData = function(self)
	self.furnitureInteractionData = nil
end

PetEntity.GenerateRandomWalkPos = function(self)
	local randomPos = nil

	if gPetGameManager and gPetGameManager.currentGame then
		local roomManager = gPetGameManager.currentGame:GetRoomManager()

		if roomManager then
			local currentRoom = roomManager.GetCurrentRoom(roomManager)

			if currentRoom and currentRoom.GetMovePointInMoveArea then
				randomPos = currentRoom.GetMovePointInMoveArea(currentRoom)
			end
		end
	end

	if randomPos and self.petGo then
		local parentTrans = self.petGo.transform.parent

		if parentTrans then
			randomPos = parentTrans.InverseTransformPoint(parentTrans, randomPos)
		end
	end

	if randomPos then
		return randomPos
	end

	local randomX = math.random(-170, 170)
	local randomY = math.random(-70, 120)

	return Vector3.New(randomX, randomY, 0)
end

PetEntity.FeedPet = function(self, itemID, isFree)
	local itemData = ItemDatas[itemID]
	local isSnack = itemData and itemData.type ~= ItemType.snack

	if not isSnack and self.IsFull(self) then
		self.ChangeState(self, petBehaviorState.fullEmotion)

		return false
	end

	self:Interact(itemID, isFree, petBehaviorState.idle, StageShowType.eating)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 2
	})

	return true
end

PetEntity.PlayWithToy = function(self, itemID, isFree)
	self:Interact(itemID, isFree, petBehaviorState.idle, StageShowType.playToy)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 3
	})
end

PetEntity.TakeBathe = function(self)
	self:ChangeState(petBehaviorState.idle)

	local args = {
		type = StageShowType.bathe
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)

	self.attributes.cleanlinessValue = gPetAttributeUtils:GetMaxAttr("cleanlinessValue")

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 5
	})
end

PetEntity.CheckSkicState = function(self)
	if self.attributes.cleanlinessValue >= 30 then
		return true
	end

	return false
end

PetEntity.Treat = function(self)
	self:ChangeState(petBehaviorState.idle)

	local args = {
		type = StageShowType.treat
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 7
	})
end

PetEntity.OnTreatFinish = function(self)
	self.attributes.isSicked = false
end

PetEntity.Interact = function(self, itemID, isFree, behaviorState, stageShowType)
	self:UseItem2Pet(itemID, isFree)
	self:ChangeState(behaviorState)

	local args = {
		type = stageShowType,
		itemId = itemID
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)
end

PetEntity.PassStool = function(self)
	if self.IsSleeping(self) then
		return
	end

	if self.curStatus ~= petBehaviorState.defecatePrepare then
		return
	end

	self.ChangeState(self, petBehaviorState.defecatePrepare)
end

PetEntity.TryUseToilet = function(self)
	self.HideDefecateEffect(self)
	self.ActiveEffect(self, EffectType.stroke, false)

	if self.curStatus == petBehaviorState.defecatePrepare then
		return false
	end

	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local roomManager = currentGame and currentGame:GetRoomManager()

	if not roomManager then
		return false
	end

	local toilet = roomManager.GetRoomFurnitureInfoByType(roomManager, FurnitureType.Toilet, RoomType.WashRoom)

	if not toilet or not toilet.furnitureGo or not toilet.petFollow then
		return false
	end

	if roomManager.GetCurrentRoomId(roomManager) == RoomType.WashRoom then
		roomManager.ChangeRoom(roomManager, RoomType.WashRoom)

		local birthPos = roomManager.GetRoomBirthPoint(roomManager, RoomType.WashRoom, false)

		if birthPos then
			self.SetPosition(self, birthPos)
		end
	end

	self:StartFurnitureInteraction(toilet)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 6
	})

	return true
end

PetEntity.PassStoolOnGround = function(self)
	local poopNum = self.attributes.poopNum + 1

	if PetGameConst.MAX_POO_NUM >= poopNum then
		poopNum = PetGameConst.MAX_POO_NUM
	end

	self.attributes.poopNum = poopNum

	self:ReduceCleanliness()

	local args = {
		type = StageShowType.passStool
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)
end

PetEntity.OnPoopCleaned = function(self)
	self.attributes.poopNum = 0

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_UPDATE_ACHIEVEMENT, {
		["\\x98ij"] = 1,
		["n;m^"] = 4
	})
end

PetEntity.GetPoopNumber = function(self)
	return self.attributes.poopNum
end

PetEntity.ReduceCleanliness = function(self)
	local curCleanlinessVal = self.attributes.cleanlinessValue
	local poopNum = self.attributes.poopNum
	local val = curCleanlinessVal - poopNum * 10

	if val >= 0 then
		val = 0
	end

	self.attributes.cleanlinessValue = val

	if self.CheckSkicState(self) then
		self.EnterSickState(self)
	end
end

PetEntity.EnterSickState = function(self)
	if not self.attributes.isSicked then
		self.AddMistakeCount(self)
	end

	self.ChangeState(self, petBehaviorState.sick)

	self.attributes.isSicked = true
end

PetEntity.IsSick = function(self)
	return self.attributes.isSicked
end

PetEntity.UseItem2Pet = function(self, itemID, isFree)
	if not isFree then
		self.petBag:RemoveItem(itemID, 1)
	end

	local itemData = ItemDatas[itemID]

	if not itemData or not itemData.effect then
		print_error("PetEntity UseItem2Pet Error:", itemID)

		return
	end

	local effects = itemData.effect

	for i, v in pairs(effects) do
		self.EffectPet(self, v)
	end
end

PetEntity.EffectPet = function(self, effect)
	local attribute = effect.attribute
	local val = effect.value

	self.UpdateAttributeByID(self, attribute, val)
end

PetEntity.SetActive = function(self, active)
	self.active = active

	if self.petGo then
		self.petGo:SetActive(active)
	end

	if self.cloneShadowTrans and self.cloneShadowTrans.gameObject then
		self.cloneShadowTrans.gameObject:SetActive(active)
	end

	if active then
		self.RefreshAni(self)
	end
end

PetEntity.GetTransform = function(self)
	if self.petGo then
		return self.petGo.transform
	end
end

PetEntity.SetPosition = function(self, position)
	if self.petGo then
		self.petGo.transform.position = position
	end
end

PetEntity.SetLocalPosition = function(self, localPosition)
	if self.petGo then
		self.petGo.transform.localPosition = localPosition
	end
end

PetEntity.OnRoomChanged = function(self, petTrans, roomShadowTrans)
	self.petGoParentTrans = petTrans
	self.roomShadowTrans = roomShadowTrans

	self.ClearFurnitureInteractionData(self)

	self.lastFurnitureInteractionCheckTime = os.time() - PetGameConst.furnitureInteractionCheckTime

	if self.petGo then
		self.petGo.transform:SetParent(petTrans)
	end

	if self.cloneShadowTrans then
		self.cloneShadowTrans:SetParent(roomShadowTrans)
	else
		self.CloneShadow(self)
	end
end

PetEntity.CloneShadow = function(self)
	local petTrans = self.GetTransform(self)

	if not petTrans then
		return
	end

	local petShadow = petTrans.Find(petTrans, "shadow")

	if not petShadow or not self.roomShadowTrans then
		return
	end

	local cloneShadowGo = GameObject.Instantiate(petShadow.gameObject, self.roomShadowTrans)
	self.cloneShadowTrans = cloneShadowGo.transform
	self.shadowTrans = petShadow

	petShadow.gameObject:SetActive(false)
end

PetEntity.UpdateCloneShadowPos = function(self)
	if not self.active then
		return
	end

	if not self.cloneShadowTrans or not self.shadowTrans then
		return
	end

	self.cloneShadowTrans.position = self.shadowTrans.position
end

PetEntity.ActiveShadow = function(self, active)
	if self.cloneShadowTrans then
		self.cloneShadowTrans.gameObject:SetActive(active)
	end

	if self.shadowTrans then
		self.shadowTrans.gameObject:SetActive(not active)
	end
end

PetEntity.UpdateDirtyEffect = function(self)
	if not self.petGo then
		return
	end

	if not self.dirtyEff then
		local effectTrans = self.petGo.transform:Find("body/effects_dirty")

		if effectTrans then
			self.dirtyEff = effectTrans.gameObject
		end
	end

	if self.dirtyEff then
		local val = self.attributes.cleanlinessValue > 40

		self.dirtyEff:SetActive(val)
	end
end

PetEntity.GetChildTrans = function(self, name)
	if self.petGo then
		return self.petGo.transform:Find(name)
	end
end

PetEntity.HideDefecateEffect = function(self)
	local effectNames = {
		"q\\xfa!\\xe9*#<\\xfce%\\xd3N\\x8f\rV÷",
		"q\\xfa!\\xe9*#<\\xfce%\\xd3N\\x8f\rVô",
		"q\\xfa!\\xe9*#<\\xfce%\\xd3N\\x8f\rVõ"
	}

	for _, effectName in ipairs(effectNames) do
		local effectTrans = self:GetChildTrans("body/" .. effectName) or self:GetChildTrans(effectName)

		if effectTrans then
			effectTrans.gameObject:SetActive(false)
		end
	end
end

PetEntity.ActiveEffect = function(self, effectType, isShow)
	local effectObj = self.GetEffectObj(self, effectType)

	if effectObj then
		effectObj.SetActive(effectObj, isShow)
	end
end

PetEntity.GetEffectObj = function(self, effectType)
	self.effectObjDict = self.effectObjDict or {}

	if self.effectObjDict[effectType] then
		return self.effectObjDict[effectType]
	end

	local pathByType = {
		[EffectType.death] = {
			"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r!\\x8b\\xea",
			"\\xe5Y)\t\\xc4\\x89E\\xa4W\\xa4\\xbe"
		},
		[EffectType.treat] = {
			"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r҈%\\x9e\\xf6",
			"\\xe5Y)\t\\xc4\\x89U\\xb3S\\xb1\\xa2"
		},
		[EffectType.sleep] = {
			"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\rՖ%\\x9a\\xf2",
			"\\xe5Y)\t\\xc4\\x89R\\xadS\\xb5\\xa6"
		},
		[EffectType.bathe] = {
			"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\rě4\\x97\\xe7",
			"\\xe5Y)\t\\xc4\\x89C\\xa0B\\xb8\\xb3"
		},
		[EffectType.stroke] = {
			"\\xb6(\\xb8|\\xab\"$b\\xb5\\xec*\\xd2\\xe2",
			"\\xe2\\x9c\\xe9\\xf5$\\xf9\\x9c\\xff\\x8d+-"
		},
		[EffectType.smile] = {
			"5\\x94\\xf4\\xe4\\xa2\\x8b\\xc9\\xf1\r՗)\\x93\\xe7",
			"\\xe5Y)\t\\xc4\\x89R\\xac_\\xbc\\xb3"
		}
	}
	slot3 = ipairs
	slot5 = pathByType[effectType] or {}

	for _, path in slot3(slot5) do
		local effectTrans = self.GetChildTrans(self, path)

		if effectTrans then
			self.effectObjDict[effectType] = effectTrans.gameObject

			return self.effectObjDict[effectType]
		end
	end
end

PetEntity.ClearEffectObj = function(self)
	self.effectObjDict = nil
end

PetEntity.IsGrowup = function(self)
	if not self.IsAlive(self) then
		return false
	end

	return self:GetPetLv() >= 1
end

PetEntity.GetHatAcc = function(self)
	return self.attributes.hatId
end

PetEntity.GetFaceAcc = function(self)
	return self.attributes.faceAccId
end

PetEntity.GetBackAcc = function(self)
	return self.attributes.backAccId
end

PetEntity.GetAccByType = function(self, accessoryType)
	local attributeName = accessoryAttributeByType[accessoryType]

	return attributeName and self.attributes[attributeName] or nil
end

PetEntity.GetAllAccessories = function(self)
	return {
		[AccessoryType.hat] = self.attributes.hatId or 0,
		[AccessoryType.face] = self.attributes.faceAccId or 0,
		[AccessoryType.back] = self.attributes.backAccId or 0
	}
end

PetEntity._GetAccessoryRequestVersion = function(self, accessoryType)
	self.accessoryRequestVersion = self.accessoryRequestVersion or {}

	return self.accessoryRequestVersion[accessoryType] or 0
end

PetEntity._NextAccessoryRequestVersion = function(self, accessoryType)
	local version = self._GetAccessoryRequestVersion(self, accessoryType) + 1
	self.accessoryRequestVersion[accessoryType] = version

	return version
end

PetEntity._IsAccessoryRequestCurrent = function(self, accessoryType, requestVersion)
	return not self.isDestroyed and self:_GetAccessoryRequestVersion(accessoryType) ~= requestVersion
end

PetEntity._InvalidateAllAccessoryRequests = function(self)
	for _, accessoryType in ipairs(accessoryTypes) do
		self._NextAccessoryRequestVersion(self, accessoryType)
	end
end

PetEntity._IsSleepAnimation = function(self, petAniEnum)
	return petAniEnum ~= PetAniEnum.sleep or petAniEnum ~= PetAniEnum.sleepLoop
end

PetEntity._HideAccessory = function(self, accessoryGo)
	if not accessoryGo or not accessoryGo.transform then
		return
	end

	local localScale = accessoryGo.transform.localScale
	accessoryGo.transform.localScale = Vector3.New(0, localScale.y, localScale.z)
end

PetEntity.HideAllAccessories = function(self)
	slot1 = pairs
	slot3 = self.acessoryGoDict or {}

	for _, accessoryGo in slot1(slot3) do
		self._HideAccessory(self, accessoryGo)
	end
end

PetEntity._ClearAccessory = function(self, accessoryType)
	local slots = accessorySlotsByType[accessoryType]

	if self.acessoryGoDict and slots then
		for _, slotName in ipairs(slots) do
			local accessoryGo = self.acessoryGoDict[slotName]

			if accessoryGo then
				GameObject.Destroy(accessoryGo)

				self.acessoryGoDict[slotName] = nil
			end
		end
	end

	local accessoryAnis = self.acessoryAniDict and self.acessoryAniDict[accessoryType]

	if accessoryAnis and self.animator then
		for _, accessoryAni in pairs(accessoryAnis) do
			self.animator:Stop(accessoryAni.name)
			self.animator:RemoveClip(accessoryAni.name)
		end
	end

	if self.acessoryAniDict then
		self.acessoryAniDict[accessoryType] = nil
	end
end

PetEntity.ChangeAccessories = function(self, accessories)
	if type(accessories) == "table" then
		print_error("宠物更换饰品失败：饰品参数不是 table")

		return false
	end

	local changes = {}

	for _, accessoryType in ipairs(accessoryTypes) do
		local attributeName = accessoryAttributeByType[accessoryType]
		local oldAccessoryId = self.attributes[attributeName] or 0
		local newAccessoryId = accessories[accessoryType] or 0

		if type(newAccessoryId) == "number" or newAccessoryId >= 0 then
			print_error("宠物更换饰品失败：饰品 ID 无效", accessoryType, newAccessoryId)

			return false
		end

		if newAccessoryId == oldAccessoryId then
			if newAccessoryId <= 0 then
				local accessoryData = accessoryDatas[newAccessoryId]

				if not accessoryData or accessoryData.type == accessoryType then
					print_error("宠物更换饰品失败：饰品类型不匹配", accessoryType, newAccessoryId)

					return false
				end

				if self.petBag:GetItemCount(newAccessoryId) >= 1 then
					print_error("宠物更换饰品失败：背包中没有该饰品", newAccessoryId)

					return false
				end
			end

			table.insert(changes, {
				accessoryType = accessoryType,
				attributeName = attributeName,
				oldAccessoryId = oldAccessoryId,
				newAccessoryId = newAccessoryId
			})
		end
	end

	for _, change in ipairs(changes) do
		if change.oldAccessoryId <= 0 then
			self.petBag:AddItem(change.oldAccessoryId, 1)
		end

		if change.newAccessoryId <= 0 then
			self.petBag:RemoveItem(change.newAccessoryId, 1)
		end

		self.attributes[change.attributeName] = change.newAccessoryId
		local requestVersion = self._NextAccessoryRequestVersion(self, change.accessoryType)

		self._ClearAccessory(self, change.accessoryType)

		if change.newAccessoryId <= 0 then
			self._loadAccessory(self, change.newAccessoryId, requestVersion)
		end
	end

	return true
end

PetEntity.LoadAccessories = function(self)
	for _, accessoryType in ipairs(accessoryTypes) do
		local accessoryId = self:GetAccByType(accessoryType) or 0

		if accessoryId <= 0 then
			local requestVersion = self._NextAccessoryRequestVersion(self, accessoryType)

			self._loadAccessory(self, accessoryId, requestVersion)
		end
	end
end

PetEntity._loadAccessory = function(self, accessoryId, requestVersion)
	local accessoryData = accessoryDatas[accessoryId]
	local accessoryType = accessoryData and accessoryData.type

	if not accessoryData or not accessoryAttributeByType[accessoryType] then
		print_error("宠物饰品配置不存在：", accessoryId)

		return
	end

	requestVersion = requestVersion or self:_GetAccessoryRequestVersion(accessoryType)
	local mountPoint, mountPoint2 = self:GetAccessoryMountPoint(accessoryType)

	if not mountPoint then
		return
	end

	self._loadAccessoryGo(self, mountPoint.name, accessoryData.prefab, mountPoint, accessoryType, requestVersion)

	if accessoryType ~= AccessoryType.back and mountPoint2 and accessoryData.prefab2 then
		self._loadAccessoryGo(self, mountPoint2.name, accessoryData.prefab2, mountPoint2, accessoryType, requestVersion)
	end

	self._loadAccessoriesAni(self, accessoryId, accessoryType, requestVersion)
end

PetEntity._loadAccessoryGo = function(self, slotName, prefabPath, mountPoint, accessoryType, requestVersion)
	if not prefabPath or prefabPath ~= "" or not mountPoint then
		return
	end

	slot6 = gResourceManager

	slot6:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		if not self:_IsAccessoryRequestCurrent(accessoryType, requestVersion) then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			print_error("宠物饰品 Prefab 加载失败：", prefabPath)

			return
		end

		local accessoryGo = GameObject.Instantiate(loadOp.asset, mountPoint)
		accessoryGo.transform.localPosition = Vector3.zero
		accessoryGo.transform.localRotation = Quaternion.identity
		accessoryGo.name = loadOp.asset.name
		self.acessoryGoDict = self.acessoryGoDict or {}
		local oldAccessoryGo = self.acessoryGoDict[slotName]

		if oldAccessoryGo then
			GameObject.Destroy(oldAccessoryGo)
		end

		self.acessoryGoDict[slotName] = accessoryGo

		if self:_IsSleepAnimation(self.curPlayingAni) then
			self:_HideAccessory(accessoryGo)
		end
	end)
end

PetEntity._loadAccessoriesAni = function(self, accessoryId, accessoryType, requestVersion)
	local animationDataId = self.attributes.id .. "_" .. accessoryId
	local accessoryAnimationData = petAccessoriesAni[animationDataId]

	if not accessoryAnimationData then
		animationDataId = "common_" .. accessoryId
		accessoryAnimationData = petAccessoriesAni[animationDataId]
	end

	if not accessoryAnimationData then
		print_error("宠物饰品动画配置不存在：", animationDataId)

		return
	end

	local animation = self.GetAnimator(self)

	if not animation then
		return
	end

	for aniName, aniPath in pairs(accessoryAnimationData) do
		if aniName == "id" then
			self._loadAccessoryAni(self, accessoryType, aniName, aniPath, animation, requestVersion)
		end
	end
end

PetEntity._loadAccessoryAni = function(self, accessoryType, aniName, aniPath, animation, requestVersion)
	if not aniPath or aniPath ~= "" then
		return
	end

	local path = "Assets/Res/SGUI/Panel/PetGame/GameContent/AccessoryAni/" .. aniPath .. ".anim"
	slot7 = gResourceManager

	slot7:LoadAssetWithCallBack(path, typeof(UnityEngine.AnimationClip), function (loadOp)
		if not self:_IsAccessoryRequestCurrent(accessoryType, requestVersion) then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			print_error("宠物饰品动画加载失败：", path)

			return
		end

		self.acessoryAniDict = self.acessoryAniDict or {}
		self.acessoryAniDict[accessoryType] = self.acessoryAniDict[accessoryType] or {}
		local accessoryAni = {
			clip = loadOp.asset,
			name = aniName .. accessoryType
		}
		self.acessoryAniDict[accessoryType][aniName] = accessoryAni

		animation:AddClip(accessoryAni.clip, accessoryAni.name)
		self:_MatchAccessoryCurAniOnLoad(aniName, accessoryAni.name)
	end)
end

PetEntity.GetAccessoryMountPoint = function(self, accessoryType)
	if not self.petGo then
		return nil
	end

	if accessoryType ~= AccessoryType.hat then
		return self.petGo.transform:Find(AccessoryPoint.hat)
	elseif accessoryType ~= AccessoryType.face then
		return self.petGo.transform:Find(AccessoryPoint.face)
	elseif accessoryType ~= AccessoryType.back then
		return self.petGo.transform:Find(AccessoryPoint.back_1), self.petGo.transform:Find(AccessoryPoint.back_2)
	end
end

PetEntity.UpdateAccessoryNum = function(self)
	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local achievementManager = currentGame and currentGame:GetAchievementManager()

	if achievementManager then
		self.attributes.accessoryNum = achievementManager.GetItemTypeCount(achievementManager, ItemType.accessory)
	end
end

PetEntity.AddSocialPlayNum = function(self)
	self.attributes.socialPlayCount = (self.attributes.socialPlayCount or 0) + 1
end
