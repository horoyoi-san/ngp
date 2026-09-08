-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameStageManager.lua
-- Decompiled from: 02147_PetGameStageManager.lua_6f4b3c83047e.luajit

local xpcall = xpcall
local traceback = tolua.traceback
local GameObject = UnityEngine.GameObject
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local StageShowType = PetGameEnum.StageShowType
local RoomType = PetGameEnum.RoomType
local petBehaviorState = PetGameEnum.Behavior
local MaskAniType = PetGameEnum.MaskAniType
local FurnitureType = PetGameEnum.FurnitureType
local FurniturePoint = PetGameEnum.FurniturePoint
local PetAnimation = PetGameEnum.PetAnimation
local PetAniEnum = PetGameEnum.PetAniEnum
local AccessoryType = PetGameEnum.AccessoryType
local stageConfig = require("LX6/MiniGame/PetGame/data/tbstageconfig")
local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local petData = require("LX6/MiniGame/PetGame/data/tbpet")
local interactionData = require("LX6/MiniGame/PetGame/data/tbinteraction")
local ROOM_STAGE_TYPES = {
	[StageShowType.eating] = true,
	[StageShowType.playToy] = true,
	[StageShowType.bathe] = true,
	[StageShowType.treat] = true
}
C_PetGameStageManager = DefClass("C_PetGameStageManager", C_PetGameStageManager)
local PetGameStageManager = C_PetGameStageManager

PetGameStageManager.ctor = function(self)
end

PetGameStageManager.Clear = function(self)
	self.UnregisterEvent(self)
	self.ClearStageInfo(self)

	self.mainPanel = nil
end

PetGameStageManager.RegisterEvent = function(self)
	if self.eventHandle then
		return
	end

	self.eventHandle = {
		[gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN] = function (eventId, args)
			if args and self:CanHandleStage(args.type) then
				self:BeginStageShow(args)
			end
		end,
		[gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_END] = function ()
			if self:IsPlaying() then
				self:EndStageShow()
			end
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

PetGameStageManager.UnregisterEvent = function(self)
	if not self.eventHandle then
		return
	end

	gMessageManager:UnregisterEventHandlers(self.eventHandle)

	self.eventHandle = nil
end

PetGameStageManager.InitStageInfo = function(self, mainPanel)
	self.mainPanel = mainPanel

	self.RegisterEvent(self)
end

PetGameStageManager.CanHandleStage = function(self, stageType)
	return self.mainPanel == nil and ROOM_STAGE_TYPES[stageType] ~= true
end

PetGameStageManager.BeginStageShow = function(self, args)
	if not args then
		print_error("BeginStageShow: args is nil")

		return
	end

	local type = args.type
	local itemId = args.itemId

	if self.isPlayingOutSide then
		if type ~= StageShowType.passStool then
			self.AddPoo2CurrentRoom(self)
		end

		return
	end

	if type ~= StageShowType.passStool and self.curChildPanel then
		self.AddPoo2CurrentRoom(self)

		return
	end

	if self.isStageShowing then
		if type ~= StageShowType.passStool then
			self.AddPoo2CurrentRoom(self)
		elseif type ~= StageShowType.levelUp then
			self.cacheLevelUpArgs = args
		end

		return
	end

	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local pet = currentGame and currentGame.pet

	if not pet or not pet.petGo then
		print_warn("BeginStageShow: pet or pet.petGo is nil")

		return
	end

	self.isStageShowing = true
	self.curStageType = type
	self.itemId = itemId

	self.EnterStageMode(self, type)
	self.PlayStageMaskFadeIn(self)
	self.ClearStagePetInfo(self)

	if type == StageShowType.levelUp and type == StageShowType.clearUpPoop then
		self.stagePetGo, self.stagePetAni, self.acessoryAniDict = self.ClonePetGo(self, pet)
	end

	if type ~= StageShowType.eating then
		self.PlayEating(self, type, itemId)
	elseif type ~= StageShowType.playToy then
		self.PlayToy(self, type, itemId)
	elseif type ~= StageShowType.bathe then
		self.PlayBathe(self, type, itemId)
	elseif type ~= StageShowType.treat then
		pet.OnTreatFinish(pet)
		self.PlayTreat(self, type, itemId)
	elseif type ~= StageShowType.passStool then
		self.PlayPassStool(self, type, itemId)
	elseif type ~= StageShowType.clearUpPoop then
		pet.OnPoopCleaned(pet)
		self.PlayClearUpPoop(self, type, itemId)
	elseif type ~= StageShowType.levelUp then
		local beforeId = args.beforePetId
		local afterId = args.afterPetId

		self.PlayLevelUp(self, type, beforeId, afterId)
	end
end

PetGameStageManager.EndStageShow = function(self, showType)
	if not self.isStageShowing then
		return
	end

	showType = showType or self.curStageType
	self.curStageType = nil

	self:ClearInteractTimer()
	self:ClearStageMaskFadeOutTimer()

	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local pet = currentGame and currentGame.pet

	if pet then
		pet.ChangeState(pet, petBehaviorState.idle)
	end

	self.stageMaskFadeOutTimer = Timer.New(function ()
		self.stageMaskFadeOutTimer = nil
		self.isStageShowing = false

		if showType ~= StageShowType.eating then
			self:OnPetEatFinish(self.itemId)
		elseif showType ~= StageShowType.playToy then
			self:OnPetPlayingFinish(self.itemId)
		elseif showType ~= StageShowType.treat or showType ~= StageShowType.bathe or showType ~= StageShowType.clearUpPoop then
			self:OnPetCleaningFnish()
		elseif showType ~= StageShowType.levelUp then
			self:OnLevelUpFinish()
		end

		self.itemId = nil

		self:ExitStageMode()
		self:ClearStagePetInfo()
	end, 0.4, 1, false, false)
	slot4 = self.stageMaskFadeOutTimer

	slot4:Start()
	self:PlayStageMaskFadeOut(function ()
		if self.cacheLevelUpArgs then
			self:BeginStageShow(self.cacheLevelUpArgs)

			self.cacheLevelUpArgs = nil
		end
	end)
end

PetGameStageManager.ForceEndStage = function(self)
	local curStageType = self.curStageType

	if not self.isStageShowing or not curStageType then
		return
	end

	local canSkip = stageConfig[curStageType] and stageConfig[curStageType].canSkip

	if not canSkip then
		return
	end

	self.ClearStageMaskTimer(self)
	self.ClearInteractTimer(self)
	self.EndStageShow(self, curStageType)
end

PetGameStageManager.PlayStageMaskFadeIn = function(self)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_SHOW_UI_MASK, MaskAniType.StageFadeIn)
end

PetGameStageManager.PlayStageMaskFadeOut = function(self, callback)
	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_SHOW_UI_MASK, MaskAniType.StageFadeOut)

	self.stageMaskTimer = Timer.New(function ()
		self.stageMaskTimer = nil

		if callback then
			callback(self)
		end
	end, 1.15, 1, false, false)

	self.stageMaskTimer:Start()
end

PetGameStageManager.ClonePetGo = function(self, pet)
	local petGo = pet.petGo
	local parent = petGo.transform.parent
	local clone = GameObject.Instantiate(petGo, parent)
	local roomManager = gPetGameManager.currentGame.roomManager
	local petFollow = roomManager.GetPetFollow(roomManager)

	if petFollow then
		clone.transform.position = petFollow.position
	else
		clone.transform:SetLocalPosition(0, 0, 0)
	end

	clone:SetActive(true)

	local cloneShadow = clone.transform:Find("shadow")

	if cloneShadow then
		cloneShadow.gameObject:SetActive(true)
	end

	pet:SetActive(false)
	self:ClearPetEffect(clone.transform)

	local animator = clone.transform:GetComponent("Animation")
	local acessoryAniDict = table.clone(pet.acessoryAniDict)

	return clone, animator, acessoryAniDict
end

PetGameStageManager.ClearPetEffect = function(self, petTrans)
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

	local effects_dirty = petTrans.Find(petTrans, PetGameEnum.DirtyEffectPath)

	if effects_dirty then
		effects_dirty.gameObject:SetActive(false)
	end
end

PetGameStageManager.PlayEating = function(self, showType, foodId)
	local itemData = ItemDatas[foodId]
	local interactionConf = itemData and interactionData[itemData.interactionId]

	if not itemData or not interactionConf then
		print_error("PlayEating Error:", foodId)
		self.EndStageShow(self, showType)

		return
	end

	local roomManager = gPetGameManager.currentGame.roomManager
	local diningTable = roomManager.GetRoomFurnitureByType(roomManager, FurnitureType.DiningTable)
	local feedTrans = nil

	if diningTable then
		feedTrans = diningTable.transform:Find(FurniturePoint.food)
	end

	local parentPath = "Assets/Res/SGUI/Panel/PetGame/GameContent/items/%s.prefab"
	local iconPath = itemData.icon
	local prefabPath = string.format(parentPath, iconPath)

	if feedTrans then
		self.LoadItemGo(self, prefabPath, feedTrans, self.OnFoodLoaded)
	else
		print_warn("吃东西演出找不到食物挂点：", foodId)
	end

	self:PlayAniByPetAni(interactionConf.petAni)
	self:ClearInteractTimer()

	local aniTime = interactionConf.duration
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.OnFoodLoaded = function(self, go)
	self.foodGo = go
end

PetGameStageManager.PlayToy = function(self, showType, itemId)
	local itemData = ItemDatas[itemId]
	local interactionConf = itemData and interactionData[itemData.interactionId]

	if not itemData or not interactionConf or not interactionConf.itemParent then
		print_error("PlayToy Error:", itemId)
		self.EndStageShow(self, showType)

		return
	end

	local roomManager = gPetGameManager.currentGame.roomManager
	local currentRoom = roomManager:GetCurrentRoom()
	local toyTrans = currentRoom and currentRoom:GetItemTrans()
	local parentPath = "Assets/Res/SGUI/Panel/PetGame/GameContent/items/%s.prefab"
	local iconPath = itemData.icon
	local prefabPath = string.format(parentPath, iconPath)
	local offsetPos = Vector3.New(itemData.itemPos.x, itemData.itemPos.y, 0)

	if toyTrans then
		self.LoadItemGo(self, prefabPath, toyTrans, function (manager, itemGo)
			manager.toyGo = itemGo

			if not itemGo then
				return
			end

			itemGo.transform.localPosition = offsetPos
			local petFollow = itemGo.transform:Find(FurniturePoint.petFollow)

			if petFollow and manager.stagePetGo then
				manager.stagePetGo.transform:SetParent(petFollow)

				manager.stagePetGo.transform.localPosition = Vector3.zero
			end
		end)
	else
		print_warn("玩玩具演出找不到 stageItemTrans：", itemId)
	end

	self:PlayAniByPetAni(interactionConf.petAni)
	self:ClearInteractTimer()

	local aniTime = interactionConf.duration
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.PlayBathe = function(self, showType, itemId)
	local roomManager = gPetGameManager.currentGame.roomManager
	local bathtub = roomManager.GetRoomFurnitureByType(roomManager, FurnitureType.Bathtub)

	if bathtub then
		local bathtubAni = bathtub.transform:GetComponent("Animation")

		if bathtubAni then
			bathtubAni.Play(bathtubAni)
		end

		local petFollow = bathtub.transform:Find(FurniturePoint.petFollow)

		if petFollow and self.stagePetGo then
			self.stagePetGo.transform:SetParent(petFollow)

			self.stagePetGo.transform.localPosition = Vector3.zero
			self.stagePetGo.transform.localRotation = Quaternion.Euler(Vector3.zero)
			self.stagePetGo.transform.localScale = Vector3.one
		end
	else
		print_warn("洗澡演出找不到浴缸")
	end

	self:PlayAni(PetAniEnum.batheAni)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.PlayTreat = function(self, showType, itemId)
	self:PlayAni(PetAniEnum.treatAni)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.PlayPassStool = function(self, showType, itemId)
	self:PlayAni(PetAniEnum.defecate)
	self:ClearInteractTimer()

	local aniTime = stageConfig[showType].aniLenth
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:AddPoo2CurrentRoom()
		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.PlayClearUpPoop = function(self, showType, itemId)
	self:ClearInteractTimer()
	self:PlayPooCleanAni()

	local delayTime = 1.3
	local aniTime = stageConfig[showType].aniLenth + delayTime
	self.interactTimer = Timer.New(function ()
		self.interactTimer = nil

		self:EndStageShow(showType)
	end, aniTime, 1)

	self.interactTimer:Start()
end

PetGameStageManager.PlayPooCleanAni = function(self, clonePooTrans)
	local roomManager = gPetGameManager.currentGame:GetRoomManager()

	if not roomManager then
		return
	end

	roomManager.ClearAllPoo(roomManager)
end

PetGameStageManager.PlayLevelUp = function(self, showType, beforeId, afterId)
	local stayTime = stageConfig[showType].aniLenth or 5

	self:ClearLevelUpTimer()

	self.levelUpTimer = Timer.New(function ()
		self:EndStageShow(showType)
	end, stayTime, 1)

	self.levelUpTimer:Start()
end

PetGameStageManager.OnLevelUpFinish = function(self)
	self.ClearLevelUpTimer(self)
end

PetGameStageManager.ClearLevelUpTimer = function(self)
	if self.levelUpTimer then
		self.levelUpTimer:Stop()
	end

	self.levelUpTimer = nil
end

PetGameStageManager.LoadItemGo = function(self, prefabPath, parent, callback)
	slot4 = gResourceManager

	slot4:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local itemGo = GameObject.Instantiate(loadOp.asset, parent)

			if not itemGo then
				error("Failed to instantiate food prefab: " .. prefabPath)

				return
			end

			if not self.isStageShowing then
				GameObject.Destroy(itemGo)

				return
			end

			if callback then
				xpcall(callback, traceback, self, itemGo)
			end
		else
			error("Failed to load pet prefab: " .. prefabPath)
		end
	end)
end

PetGameStageManager.ClearStageInfo = function(self)
	local wasStageShowing = self.isStageShowing

	self.ClearStageMaskTimer(self)
	self.ClearInteractTimer(self)
	self.ClearStageMaskFadeOutTimer(self)

	if wasStageShowing then
		self.ExitStageMode(self)
	end

	self.isStageShowing = false
	self.curStageType = nil
	self.itemId = nil
	self.clearPoopPreviousRoomId = nil

	self.ClearStagePetInfo(self)
end

PetGameStageManager.ClearStageMaskTimer = function(self)
	if self.stageMaskTimer then
		self.stageMaskTimer:Stop()
	end

	self.stageMaskTimer = nil
end

PetGameStageManager.ClearInteractTimer = function(self)
	if self.interactTimer then
		self.interactTimer:Stop()
	end

	self.interactTimer = nil
end

PetGameStageManager.ClearStageMaskFadeOutTimer = function(self)
	if self.stageMaskFadeOutTimer then
		self.stageMaskFadeOutTimer:Stop()

		self.stageMaskFadeOutTimer = nil
	end
end

PetGameStageManager.ClearStagePetInfo = function(self)
	if self.foodGo then
		GameObject.Destroy(self.foodGo)

		self.foodGo = nil
	end

	if self.toyGo then
		GameObject.Destroy(self.toyGo)

		self.toyGo = nil
	end

	if self.stagePetGo then
		GameObject.Destroy(self.stagePetGo)

		self.stagePetGo = nil
		self.stagePetAni = nil
		self.acessoryAniDict = nil
	end
end

PetGameStageManager.EnterStageMode = function(self, stageType)
	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local roomManager = currentGame and currentGame.roomManager

	if not roomManager then
		return
	end

	if stageType ~= StageShowType.eating then
		roomManager.ChangeRoom(roomManager, RoomType.DiningRoom)
	elseif stageType ~= StageShowType.playToy then
		roomManager.ChangeRoom(roomManager, RoomType.GameRoom)
	elseif stageType ~= StageShowType.bathe then
		roomManager.ChangeRoom(roomManager, RoomType.WashRoom)
	elseif stageType ~= StageShowType.treat then
		roomManager.ChangeRoom(roomManager, RoomType.LivingRoom)
	elseif stageType ~= StageShowType.passStool then
		-- Nothing
	elseif stageType ~= StageShowType.clearUpPoop then
		local targetRoomId = roomManager.GetRoomIdWithPoo(roomManager)
		local currentRoomId = roomManager.GetCurrentRoomId(roomManager)

		if targetRoomId and targetRoomId == currentRoomId then
			self.clearPoopPreviousRoomId = currentRoomId
			local pet = currentGame.pet

			if pet then
				pet.SetActive(pet, false)
			end

			roomManager.ChangeRoom(roomManager, targetRoomId)
		end
	elseif stageType ~= StageShowType.levelUp then
		-- Nothing
	end

	roomManager.SetStageMode(roomManager, true)

	if stageType == StageShowType.clearUpPoop then
		roomManager.HideRoomPoop(roomManager)
	end

	local pet = currentGame.pet

	if pet and stageType == StageShowType.clearUpPoop then
		pet.SetActive(pet, false)
		pet.SetLocalPosition(pet, Vector3.zero)
	end
end

PetGameStageManager.ExitStageMode = function(self)
	local currentGame = gPetGameManager and gPetGameManager.currentGame

	if not currentGame then
		self.clearPoopPreviousRoomId = nil

		return
	end

	local roomManager = currentGame.roomManager

	if roomManager then
		roomManager.SetStageMode(roomManager, false)
		roomManager.ShowRoomPoop(roomManager)

		if self.clearPoopPreviousRoomId then
			roomManager.ChangeRoom(roomManager, self.clearPoopPreviousRoomId)
		end
	end

	local pet = currentGame.pet

	if pet then
		pet.SetActive(pet, true)
	end

	self.clearPoopPreviousRoomId = nil
end

PetGameStageManager.OnPetEatFinish = function(self, itemId)
	if self.mainPanel and self.mainPanel.OnPetEatFinish then
		self.mainPanel:OnPetEatFinish(itemId)
	end
end

PetGameStageManager.OnPetPlayingFinish = function(self, itemId)
	if self.mainPanel and self.mainPanel.OnPetPlayingFinish then
		self.mainPanel:OnPetPlayingFinish(itemId)
	end
end

PetGameStageManager.OnPetCleaningFnish = function(self)
	if self.mainPanel and self.mainPanel.OnPetCleaningFnish then
		self.mainPanel:OnPetCleaningFnish()
	end
end

PetGameStageManager.IsPlaying = function(self)
	return self.isStageShowing
end

PetGameStageManager.AddPoo2CurrentRoom = function(self)
	local roomManager = gPetGameManager.currentGame:GetRoomManager()

	if not roomManager then
		return
	end

	roomManager.AddPoo2CurrentRoom(roomManager)
end

PetGameStageManager.PlayAniByPetAni = function(self, petAni)
	local petAniEnum = PetGameEnum.GetAniEnum(petAni)

	if not petAniEnum then
		return
	end

	self.PlayAni(self, petAniEnum)
end

PetGameStageManager.PlayAni = function(self, petAniEnum)
	if not self.stagePetAni then
		return
	end

	local baseAni = PetAnimation[petAniEnum]

	if not baseAni or not self.stagePetAni:GetClip(baseAni) then
		print_error("no found the animation clip:", petAniEnum)

		return
	end

	self.stagePetAni:Play(baseAni)

	if not self.acessoryAniDict then
		return
	end

	local hatAni = self.acessoryAniDict[AccessoryType.hat]

	if hatAni and hatAni[petAniEnum] then
		self.stagePetAni:Blend(hatAni[petAniEnum].name)
	end

	local faceAni = self.acessoryAniDict[AccessoryType.face]

	if faceAni and faceAni[petAniEnum] then
		self.stagePetAni:Blend(faceAni[petAniEnum].name)
	end

	local backAni = self.acessoryAniDict[AccessoryType.back]

	if backAni and backAni[petAniEnum] then
		self.stagePetAni:Blend(backAni[petAniEnum].name)
	end
end
