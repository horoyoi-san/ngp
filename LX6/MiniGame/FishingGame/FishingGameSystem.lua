-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameSystem.lua
-- Decompiled from: 00602_FishingGameSystem.lua_92d2bb8f4470.luajit

C_FishingGameSystem = DefClass("C_FishingGameSystem", C_FishingGameSystem)
local M = C_FishingGameSystem

M.ctor = function(self)
	self.floatPosSpeed = 5
	self.fishingStep = gFishingGameConst.FishingGameStep.None
	self.wasdMap = {}
	self.isAttractFishReelin = false
	self.attractFishReelinType = 0
	self.attractFishReelinPrevType = 0
	self.attractFishReelinHitTime = 0
	self.attractFishReelinDistance = 0
	self.attractFishReelinDirection = nil
	self.isSlipFishReelin = false
	self.slipFishTipTime = 0
	self.slipFishTipDir = 0
	self.isPullFishReelin = false
	self.pullFishRotation = nil
	self.pullFishTime = 0
	self.fish = nil
	self.isHitFish = false
	self.needQte = 0
	self.qteTime = 0
	self.maxLineLoad = 100
	self.lineLoad = 0
	self.durability = 0
	self.maxDurability = 0
	self.cmRegister = nil
	self.rod = C_FishingGameRod.new()
	self.character = C_FishingGameCharacter.new()
	self.fishMgr = C_FishingGameFishMgr.new()
	self.effectMgr = C_FishingGameEffectMgr.new()
	self.isQuestMode = false
	self.successCount = 0
	self.failCount = 0
	self.maxFailCount = 0
	self.entityInstanceId = 0
end

M.SetData = function(self, clearFishing, setKeyboard, setQte, hideLineBar, setGuide, lineDisconnect, setInteractable, isQuestMode, entityInstanceId, spotId, maxFailCount)
	self.clearFishing = clearFishing
	self.setKeyboard = setKeyboard
	self.setQte = setQte
	self.hideLineBar = hideLineBar
	self.setGuide = setGuide
	self.lineDisconnect = lineDisconnect
	self.setInteractable = setInteractable
	self.characterForward = self.character:GetForward()
	self.characterForward.y = 0
	self.isQuestMode = isQuestMode or false
	self.entityInstanceId = entityInstanceId or 0
	self.spotId = spotId or 0
	self.successCount = 0
	self.failCount = 0
	self.maxFailCount = maxFailCount or 0
	local fishingTF = UnityEngine.GameObject.Find("Fishing").transform
	local fishContainer = fishingTF:Find("FishContainer")

	self.fishMgr:Init(self, fishContainer, self.spotId)

	local objPool = fishingTF:Find("ObjPool")

	self.effectMgr:Init(objPool)

	self.floatPosTF = fishingTF:Find("FloatPos")
	self.floatPosY = self.floatPosTF.position.y
	self.floatPosFish = self.floatPosTF:Find("FX_Fish").gameObject
	self.floatPosNoFish = self.floatPosTF:Find("FX_NoFish").gameObject

	self.floatPosFish:SetActive(false)
	self.floatPosNoFish:SetActive(false)
	self:SetFloatPosStatus(false)

	local handleFishing = self.character.transform
	local fishingRod = self.character.transform:Find("YG")
	local fishingRodLine = fishingTF:Find("Line")

	self.rod:SetData(self, handleFishing, fishingRod, fishingRodLine)
	self.rod:Clear()

	self.floatTF = fishingTF:Find("Float")
	self.maxDurability = FishingGameConfig.ConstantsConfig.lineStaminaMax
	self.durability = self.maxDurability
	self.maxLineLoad = FishingGameConfig.ConstantsConfig.linePullValue
	local vCamerasGO = fishingTF:Find("VCameras")
	self.cmRegister = vCamerasGO:GetComponent("RegisterCinemachineCameras")
	self.vcamInitData = {}

	for i = 0, vCamerasGO.childCount - 1 do
		local child = vCamerasGO.GetChild(vCamerasGO, i)
		self.vcamInitData[child.name] = {
			position = child.position,
			localPosition = child.localPosition,
			localRotation = child.localRotation
		}
	end

	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
end

M.Update = function(self)
	self.fishMgr:Update()
	self.effectMgr:Update()

	if self.fishingStep ~= gFishingGameConst.FishingGameStep.None then
		return
	end

	self.rod:Update()
	self.character:Update()
	self:CheckFloatPos()

	if self.fishingStep ~= gFishingGameConst.FishingGameStep.CastFishingRod and self.rod.float == nil then
		local castFloatVcam = self.cmRegister:GetVcamByName("VCamera_CastFloat")
		local vc3 = self.cmRegister:GetVcamByName("VCamera3")

		if castFloatVcam and vc3 then
			vc3.transform.position = castFloatVcam.transform.position
			vc3.transform.rotation = castFloatVcam.transform.rotation
		end
	end

	if self.fishingStep ~= gFishingGameConst.FishingGameStep.AttractFish then
		self.CheckAttractFishReelin(self)
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.FishBite then
		self.CheckFishBite(self)
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.BiteQte then
		self.CheckBiteQte(self)
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.SlipFish then
		self.rod:SetBendTargetPos(self.character.downDir, self.character.isSpace)
		self:CheckSlipFishReelin()
		self:CheckSlipFish()
		self:CheckLineLoad()
		self:CheckDurability()
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.PullFish then
		self.CheckPullFishReelin(self)
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.Finish then
		self.CheckFinish(self)
	elseif self.fishingStep ~= gFishingGameConst.FishingGameStep.Fail then
		self.CheckFail(self)
	end
end

M.Clear = function(self)
	self.castFloatCoroutine = coroutine.stop(self.castFloatCoroutine)
	self.biteCoroutine = coroutine.stop(self.biteCoroutine)
	self.finishCoroutine = coroutine.stop(self.finishCoroutine)
	self.failCoroutine = coroutine.stop(self.failCoroutine)
	self.fishingStep = gFishingGameConst.FishingGameStep.None

	self.rod:Clear()
	self.character:Clear()
	self:SetFloatPosStatus(false)

	self.isHitFish = false
	self.fish = nil
	self.lineLoad = 0
	self.wasdMap = {}
	self.isAttractFishReelin = false
	self.attractFishReelinType = 0
	self.attractFishReelinPrevType = 0
	self.attractFishReelinDirection = nil
	self.isSlipFishReelin = false
	self.slipFishTipDir = 0
	self.isPullFishReelin = false
	self.pullFishRotation = nil
	self.bFinish = false

	self:SetVCamera(gFishingGameConst.FishingGameVCamera.FollowCharacter, self.floatPosTF, nil, true)
	self.fishMgr:ResetAllFish()
	self.effectMgr:Clear()
end

M.Destroy = function(self)
	if self.updateHandler == nil then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end

	self.clearFishing = nil
	self.setQte = nil
	self.setKeyboard = nil
	self.hideLineBar = nil
	self.setGuide = nil
	self.lineDisconnect = nil
	self.cmRegister = nil
	self.setInteractable = nil

	if self.rod == nil then
		self.rod:Destroy()

		self.rod = nil
	end

	if self.character == nil then
		self.character:Destroy()

		self.character = nil
	end

	if self.fishMgr == nil then
		self.fishMgr:Destroy()

		self.fishMgr = nil
	end

	if self.effectMgr == nil then
		self.effectMgr:Destroy()

		self.effectMgr = nil
	end
end

local SafeEnableVCamera = function(cmRegister, vcamName, priority)
	local vcam = cmRegister.GetVcamByName(cmRegister, vcamName)

	if vcam then
		cmRegister.EnableVCamera(cmRegister, vcamName, priority)
	end
end

local VCAMERA_NAMES = {
	[gFishingGameConst.FishingGameVCamera.FollowCharacter] = "VCamera1",
	[gFishingGameConst.FishingGameVCamera.LookFloatPos] = "VCamera2",
	[gFishingGameConst.FishingGameVCamera.FollowFloat] = "VCamera3",
	[gFishingGameConst.FishingGameVCamera.BiteFish] = "VCamera4",
	[gFishingGameConst.FishingGameVCamera.LookFish] = "VCamera5",
	[gFishingGameConst.FishingGameVCamera.TakeFish] = "VCamera6"
}

M.SetVCamera = function(self, index, follow, lookAt, isRotation)
	local vcamName = VCAMERA_NAMES[index]

	if not vcamName then
		return
	end

	SafeEnableVCamera(self.cmRegister, vcamName, 11)

	local vcam = self.cmRegister:GetVcamByName(vcamName)

	if vcam then
		self.character:SetData(self, index, vcam, follow, lookAt, isRotation)
	end
end

M.OnResultClosed = function(self)
	if not self.waitingForResult then
		return
	end

	local data = self.waitingForResult
	self.waitingForResult = nil

	self.character:ClearAction()
	self.character.animator:Play("Idle", 0, 0)

	if data.fishId ~= 1 then
		if data.fish then
			data.fish.isLive = false
		end

		self.fish = nil

		self.rod:SetHoldFishStatus(false)
	elseif data.fishId ~= 2 then
		self.character:Clear()
		self.rod:SetBigFishStatus(false)
	end

	self.clearFishing()
	self.fishMgr:RefreshFish()
end

M.ClearVCamera = function(self)
	self.cmRegister:DisableAllVCamera()
end

M.SetTimelineVCamera = function(self, cameraId, follow, lookAt)
	local vcam = self.cmRegister:GetVcamByName(cameraId)

	if vcam ~= nil then
		return
	end

	vcam.Follow = follow
	vcam.LookAt = lookAt
end

M.SetFloatPosStatus = function(self, status)
	if status then
		self.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatPosFish, self.floatPosFish.transform, Vector3.New(0, 0.4, 0))
		self.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FloatPosNoFish, self.floatPosNoFish.transform, Vector3.New(0, 0.4, 0))
	end

	self.floatPosTF.gameObject:SetActive(status)
end

M.SetKey = function(self, key, status)
	if status then
		self.wasdMap[key] = Time.time
	else
		self.wasdMap[key] = nil
	end
end

M.GetADStatus = function(self)
	local aTime = self.wasdMap[gFishingGameConst.FishingGameQteKey.A] or 0
	local dTime = self.wasdMap[gFishingGameConst.FishingGameQteKey.D] or 0

	if aTime <= 0 and dTime <= 0 then
		return dTime >= aTime and -1 or 1
	elseif aTime <= 0 then
		return -1
	elseif dTime <= 0 then
		return 1
	end

	return 0
end

M.GetWSStatus = function(self)
	local wTime = self.wasdMap[gFishingGameConst.FishingGameQteKey.W] or 0
	local sTime = self.wasdMap[gFishingGameConst.FishingGameQteKey.S] or 0

	if wTime <= 0 and sTime <= 0 then
		return sTime >= wTime and 1 or -1
	elseif wTime <= 0 then
		return 1
	elseif sTime <= 0 then
		return -1
	end

	return 0
end

M.SelectFloatPos = function(self)
	self.fishingStep = gFishingGameConst.FishingGameStep.SelectFloat

	self.SetVCamera(self, gFishingGameConst.FishingGameVCamera.LookFloatPos, nil, , true)
	self.SetFloatPosStatus(self, true)
end

M.CheckFloatPos = function(self)
	if self.fishingStep == gFishingGameConst.FishingGameStep.SelectFloat then
		return
	end

	local floatPos = self.floatPosTF.position
	local pos = Vector3.zero
	local dx = self:GetADStatus()
	local dy = self:GetWSStatus()
	pos.x = floatPos.x + dx * self.floatPosSpeed * Time.deltaTime
	pos.z = floatPos.z + dy * self.floatPosSpeed * Time.deltaTime
	local characterPos = self.character:GetPos()
	local direction = FishingGameUtil.GetDirectionIgnoreY(pos, characterPos)
	local angle = Vector3.Angle(self.characterForward, direction)
	local distance = gUtils:GetXZDistance(pos, characterPos)

	if angle < FishingGameConfig.ConstantsConfig.markAngle then
		if distance >= FishingGameConfig.ConstantsConfig.markDistanceMin then
			if dx ~= 1 then
				pos = self.CalcDirectionFloatPos(self, FishingGameConfig.ConstantsConfig.markDistanceMin, direction)
			elseif dx ~= -1 then
				pos = self.CalcDirectionFloatPos(self, FishingGameConfig.ConstantsConfig.markDistanceMin, direction)
			else
				pos = floatPos
			end
		elseif FishingGameConfig.ConstantsConfig.markDistanceMax >= distance then
			if dx ~= 1 then
				pos = self.CalcDirectionFloatPos(self, FishingGameConfig.ConstantsConfig.markDistanceMax, direction)
			elseif dx ~= -1 then
				pos = self.CalcDirectionFloatPos(self, FishingGameConfig.ConstantsConfig.markDistanceMax, direction)
			else
				pos = floatPos
			end
		end
	else
		distance = distance - 0.1

		if distance >= FishingGameConfig.ConstantsConfig.markDistanceMin then
			distance = FishingGameConfig.ConstantsConfig.markDistanceMin
		end

		local cross = Vector3.Cross(self.characterForward, direction)

		if cross.y <= 0 then
			pos = self.CalcAngleFloatPos(self, distance, FishingGameConfig.ConstantsConfig.markAngle)
		elseif cross.y >= 0 then
			pos = self.CalcAngleFloatPos(self, distance, -FishingGameConfig.ConstantsConfig.markAngle)
		else
			pos = floatPos
		end
	end

	pos.y = self.floatPosY
	self.floatPosTF.position = pos
	local isHaveFish = self.fishMgr:IsFloatPosHaveFish(pos)

	self.floatPosFish:SetActive(isHaveFish)
	self.floatPosNoFish:SetActive(not isHaveFish)
end

M.CalcDirectionFloatPos = function(self, distance, direction)
	local pos = direction * distance

	return pos + self.character:GetPos()
end

M.CalcAngleFloatPos = function(self, distance, angle)
	local rotation = Quaternion.Euler(0, angle, 0)
	local pos = rotation * self.characterForward * distance

	return pos + self.character:GetPos()
end

M.AttractFishReelin = function(self, status)
	self.isAttractFishReelin = status

	if status then
		if self.attractFishReelinDirection ~= nil then
			self.attractFishReelinDistance = 1
			self.attractFishReelinDirection, self.attractFishReelinType = self:GetAttractFishReelinDirection()

			self.rod.float:PlayModelAni()
		elseif self.attractFishReelinHitTime >= Time.time then
			self.attractFishReelinType = 0
		end
	end
end

M.GetAttractFishReelinDirection = function(self)
	local floatPos = self.rod.float:GetPos()
	local floatOffset = Vector3.New(floatPos.x, 0, floatPos.z)
	local characterPos = self.character:GetPos()
	characterPos.y = 0
	local dirType = nil
	local dx = self:GetADStatus()

	if dx ~= 0 then
		dirType = 1
	elseif dx ~= 1 then
		dirType = 2
		floatOffset.x = floatOffset.x - 5
	else
		dirType = 3
		floatOffset.x = floatOffset.x + 5
	end

	return (floatOffset - characterPos).normalized, dirType
end

M.CheckAttractFishReelin = function(self)
	if self.rod.float ~= nil then
		return
	end

	if not self.isAttractFishReelin and self.attractFishReelinDirection ~= nil then
		return
	end

	local floatPos = self.rod.float:GetPos()
	local characterPos = self.character:GetPos()
	characterPos.y = 0
	local deltaPos = nil

	if self.attractFishReelinDirection == nil then
		deltaPos = self.attractFishReelinDirection * Time.deltaTime * 2
		self.attractFishReelinDistance = self.attractFishReelinDistance - deltaPos.magnitude

		self.rod.float:SetModelRotation(Quaternion.LookRotation(self.attractFishReelinDirection, Vector3.up))

		if self.attractFishReelinDistance < 0 then
			self.attractFishReelinDirection = nil
		end
	else
		local direction, dirType = self.GetAttractFishReelinDirection(self)

		if self.attractFishReelinHitTime >= Time.time then
			self.attractFishReelinType = dirType
		end

		deltaPos = direction * Time.deltaTime

		self.rod.float:SetModelRotation(Quaternion.LookRotation(direction, Vector3.up))
	end

	floatPos = floatPos - deltaPos

	self.rod.float:SetPos(floatPos)

	if self.attractFishReelinPrevType == self.attractFishReelinType then
		self.attractFishReelinPrevType = self.attractFishReelinType
		self.attractFishReelinHitTime = Time.time + 0.1
		local attractAdd = FishingGameConfig.ConstantsConfig.attractAdd

		self.fishMgr:AddHit(math.random(attractAdd[1], attractAdd[2]))
	end

	local distance = gUtils:GetXZDistance(floatPos, characterPos)

	if distance >= FishingGameConfig.ConstantsConfig.sideDistance then
		self.fishingStep = gFishingGameConst.FishingGameStep.Fail
	end
end

M.CastFloat = function(self, callback)
	if self.rod.float == nil or self.castFloat then
		return
	end

	self.fishingStep = gFishingGameConst.FishingGameStep.CastFishingRod
	slot2 = self.character

	slot2:ClearAction()

	slot2 = self.character

	slot2:PlayAction(gFishingGameConst.FishingGameAction.CastFloat, true)

	slot2 = self.floatPosFish

	slot2:SetActive(false)

	slot2 = self.floatPosNoFish

	slot2:SetActive(false)

	self.castFloatCoroutine = coroutine.start(function ()
		self:SetVCamera(gFishingGameConst.FishingGameVCamera.LookFloatPos, nil, , true)
		coroutine.wait(1.5)
		SafeEnableVCamera(self.cmRegister, "VCamera_CastFloat", 11)

		local float = C_FishingGameFloat.new(self.floatTF)

		float:SetData(self, self.rod.lineAttachment.position)

		local floatPos = self.floatPosTF.position

		float:MoveTo(floatPos, function ()
			self:SetVCamera(gFishingGameConst.FishingGameVCamera.FollowFloat, nil, , true)

			self.fishingStep = gFishingGameConst.FishingGameStep.AttractFish

			self.setGuide(gFishingGameConst.FishingGameGuideType.None)
			self:SetFloatPosStatus(false)
			self.rod:SetCalculateBend(true)
			self.rod:SetBendTargetPos(0, false)
			self.rod.float:PlayEntryEffect()

			self.isHitFish = true

			callback()
		end)

		local characterPos = self.character:GetPos()
		local direction = FishingGameUtil.GetDirectionIgnoreY(floatPos, characterPos)

		float:SetModelRotation(Quaternion.LookRotation(direction, Vector3.up))

		self.rod.float = float

		self.rod:SetLineStatus(false)
	end)
end

M.CheckFishBite = function(self)
	if self.fish ~= nil then
		return
	end

	if self.biteCoroutine == nil then
		return
	end

	self.biteCoroutine = coroutine.start(function ()
		local fish = self.fish

		if fish ~= nil then
			self.finishCoroutine = nil

			return
		end

		local fishPos = fish:GetPos()
		local floatPos = self.rod.float:GetPos()
		local direction = FishingGameUtil.GetDirection(fishPos, floatPos)
		local targetPos = floatPos + direction * 0.1

		fish:MoveTo(targetPos, 0.3, true, false)
		coroutine.wait(0.2)
		self:ShowBiteQte()
		coroutine.wait(0.1)
		fish:ClearMove()
		fish:PlayAction(gFishingGameConst.FishingGameAction.Bite)
		self.effectMgr:Add(gFishingGameConst.FishingGameEffectType.FishBiteEffect, self.rod.float.transform, Vector3.zero, 1)
		coroutine.wait(0.1)
		self.rod.float:SetDisplay(false)
		coroutine.wait(0.2)
		fish:PlayAction(gFishingGameConst.FishingGameAction.Idle)

		self.biteCoroutine = nil
	end)
end

M.ShowBiteQte = function(self)
	local qteKeys = {
		gFishingGameConst.FishingGameQteKey.W,
		gFishingGameConst.FishingGameQteKey.A,
		gFishingGameConst.FishingGameQteKey.S,
		gFishingGameConst.FishingGameQteKey.D
	}
	local qteIndex = math.random(1, #qteKeys)
	self.needQte = qteKeys[qteIndex]
	self.qteTime = Time.time + 2.5

	self:SetVCamera(gFishingGameConst.FishingGameVCamera.BiteFish)

	local cameraRotation = Quaternion.LookRotation(-self.fish:GetForward(), Vector3.up)
	cameraRotation = Quaternion.Euler(30, cameraRotation.eulerAngles.y, cameraRotation.eulerAngles.z)

	self.character:SetCameraRotation(cameraRotation)

	local cameraOffset = Vector3.New(0, 0.4, -2.5)
	local floatPos = self.rod.float:GetPos()

	self.character:SetCameraPosition(cameraRotation * cameraOffset + floatPos)

	self.fishingStep = gFishingGameConst.FishingGameStep.BiteQte

	self.setQte(gFishingGameConst.FishingGameQte.Show)
end

M.CheckBiteQte = function(self)
	if self.fish ~= nil then
		return
	end

	if self.qteTime >= Time.time then
		self.BiteQteFail(self)

		return
	end

	local pressedKey = gFishingGameConst.FishingGameQteKey.None

	if self.wasdMap[gFishingGameConst.FishingGameQteKey.W] then
		pressedKey = gFishingGameConst.FishingGameQteKey.W
	elseif self.wasdMap[gFishingGameConst.FishingGameQteKey.A] then
		pressedKey = gFishingGameConst.FishingGameQteKey.A
	elseif self.wasdMap[gFishingGameConst.FishingGameQteKey.S] then
		pressedKey = gFishingGameConst.FishingGameQteKey.S
	elseif self.wasdMap[gFishingGameConst.FishingGameQteKey.D] then
		pressedKey = gFishingGameConst.FishingGameQteKey.D
	end

	if pressedKey ~= gFishingGameConst.FishingGameQteKey.None then
		return
	end

	if pressedKey == self.needQte then
		self.wasdMap[pressedKey] = nil

		return
	end

	self.wasdMap = {}

	self.setQte(gFishingGameConst.FishingGameQte.Success)
	self.character:ClearAction()
	self.character:ClearKey()
	self.character:TakeUp(0)

	if self.fish.data.maxHp <= 0 then
		self.fish:PlayAction(gFishingGameConst.FishingGameAction.Idle, true)
	else
		self.PlayFishExhausted(self)
	end

	self.StartSlipFish(self)
end

M.BiteQteFail = function(self)
	self.setQte(gFishingGameConst.FishingGameQte.Fail)

	self.biteCoroutine = coroutine.stop(self.biteCoroutine)

	if self.fish == nil then
		self.fish.isAttract = false

		self.fish:ClearMove()
		self.fish:PlayAction(gFishingGameConst.FishingGameAction.Idle)

		self.fish.aiTime = 0
		local fishData = self.fish.data
		fishData.hit = -1
		fishData.hitCD = Time.time + 300
		self.fish = nil
	end

	self.fishMgr:RevertHitFish()

	self.isHitFish = true
	self.isAttractFishReelin = false
	self.attractFishReelinType = 0
	self.attractFishReelinPrevType = 0
	self.attractFishReelinDirection = nil
	self.fishingStep = gFishingGameConst.FishingGameStep.AttractFish
	local float = self.rod.float

	float:SetDisplay(true)
	self:SetVCamera(gFishingGameConst.FishingGameVCamera.FollowFloat, nil, , true)
end

M.PlayFishExhausted = function(self)
	local fish = self.fish

	if fish ~= nil then
		return
	end

	fish:ClearMove()
	fish:PlayAction(gFishingGameConst.FishingGameAction.Exhausted)
	self.rod:SetBendTargetPos(0, false)
	self.rod.float:SetPos(fish:GetMouthPos())
end

M.StartSlipFish = function(self)
	self.fishingStep = gFishingGameConst.FishingGameStep.SlipFish

	self.setGuide(gFishingGameConst.FishingGameGuideType.SlipFish)

	self.wasdMap = {}

	self.rod:SetLineStatus(true)
	self.rod.float:SetDisplay(false)

	local fish = self.fish

	if fish ~= nil then
		return
	end

	local fishPos = fish:GetPos()
	fishPos.y = fishPos.y - (fish.config.slipFishDepthOffset or 0.5)

	fish:SetPos(fishPos)
	self:SetVCamera(gFishingGameConst.FishingGameVCamera.LookFish, nil, fish.transform, true)

	local characterPos = self.character:GetPos()
	fish.data.distance = gUtils:GetXZDistance(fishPos, characterPos) - FishingGameConfig.ConstantsConfig.sideDistance
	local cdTime = math.random(fish.config.struggleCdMin, fish.config.struggleCdMax)
	fish.data.flounderCDTime = Time.time + cdTime

	if fish.data.maxHp <= 0 then
		fish:PlayAction(gFishingGameConst.FishingGameAction.Swim, true)
		gMessageManager:SendMessage(gEventConstants.MINIGAME_FISHING_GAME_MAIN_SETFISH)
	else
		self.SlipFishReelin(self, true)
		self.CheckSlipFishReelin(self)
	end
end

M.GetSlipFishAngleConfig = function(self, distance)
	local config = nil
	local len = #FishingGameConfig.SlipFishAngleConfig

	for i = 1, len do
		config = FishingGameConfig.SlipFishAngleConfig[i]

		if config.distance < distance then
			return config
		end
	end

	return FishingGameConfig.SlipFishAngleConfig[len]
end

M.GetSlipFishDirectionConfig = function(self, hp)
	local config = nil
	local len = #FishingGameConfig.SlipFishDirectionConfig

	for i = 1, len do
		config = FishingGameConfig.SlipFishDirectionConfig[i]

		if config.hp >= hp then
			return config
		end
	end

	return FishingGameConfig.SlipFishDirectionConfig[len]
end

M.SlipFishReelin = function(self, status)
	self.isSlipFishReelin = status
	self.character.isSpace = status
end

M.GetCharacterFishCross = function(self)
	if self.fish ~= nil then
		return nil
	end

	local fishPos = self.fish:GetPos()
	local characterPos = self.character:GetPos()
	local direction = FishingGameUtil.GetDirectionIgnoreY(fishPos, characterPos)
	local cross = Vector3.Cross(self.characterForward, direction)

	return cross
end

M.CheckSlipFishReelin = function(self)
	if not self.isSlipFishReelin then
		return
	end

	if self.fish ~= nil then
		return
	end

	local fish = self.fish
	local fishData = fish.data

	if fishData.hp < 0 then
		self:PlayFishExhausted()
		self.character:ClearAction()
		self.character:ClearKey()
		self.character:TakeUp(0)

		self.fishingStep = gFishingGameConst.FishingGameStep.PullFish

		self:SetTimelineVCamera(gFishingGameConst.FishingGameTimelineVCamera.Finish, nil, fish.transform)
		SafeEnableVCamera(self.cmRegister, "VCamera_Finish", 11)
		self:PullFishReelin(true)

		return
	end

	local distance = fishData.hp / fishData.maxHp * fishData.distance
	fishData.hp = fishData.hp - FishingGameConfig.ConstantsConfig.hpHarm * Time.deltaTime

	if fishData.hp >= 0 then
		fishData.hp = 0
	end

	local newDistance = fishData.hp / fishData.maxHp * fishData.distance
	local fishPos = fish:GetPos()
	local characterPos = self.character:GetPos()
	local direction = (fishPos - characterPos).normalized
	direction.y = 0

	fish:Reelin(direction * (distance - newDistance))
end

M.CheckSlipFish = function(self)
	if self.fish ~= nil then
		return
	end

	local fish = self.fish
	local fishData = fish.data

	if fishData.hp < 0 then
		return
	end

	if not fish.IsMove(fish) then
		local fishPos = fish:GetPos()
		local characterPos = self.character:GetPos()
		local distance = gUtils:GetXZDistance(fishPos, characterPos) - FishingGameConfig.ConstantsConfig.sideDistance
		local slipFishAngleConfig = self:GetSlipFishAngleConfig(distance)
		local direction = FishingGameUtil.GetDirectionIgnoreY(fishPos, characterPos)
		local angle = Vector3.Angle(self.characterForward, direction)
		local cross = Vector3.Cross(self.characterForward, direction)
		local addAngle = math.random(slipFishAngleConfig.minAddAngle, slipFishAngleConfig.maxAddAngle)
		local hpPercent = math.floor(fishData.hp / fishData.maxHp * 100)
		local slipFishDirectionConfig = self:GetSlipFishDirectionConfig(hpPercent)
		local moveDir = 1

		if fishData.moveDir ~= 0 then
			if math.random(0, 100) <= 50 then
				moveDir = 1
			else
				moveDir = -1
			end
		elseif fishData.moveDir <= 0 then
			if slipFishDirectionConfig.sameDirCount < fishData.moveDir then
				fishData.moveDir = 0
				moveDir = -1
			elseif fishData.moveDir >= slipFishDirectionConfig.minSameDirCount then
				moveDir = 1
			elseif math.random(0, 100) >= slipFishDirectionConfig.probability then
				moveDir = 1
			else
				moveDir = -1
			end
		elseif fishData.moveDir >= 0 then
			if fishData.moveDir < -slipFishDirectionConfig.sameDirCount then
				fishData.moveDir = 0
				moveDir = 1
			elseif slipFishDirectionConfig.minSameDirCount >= fishData.moveDir then
				moveDir = -1
			elseif math.random(0, 100) >= slipFishDirectionConfig.probability then
				moveDir = -1
			else
				moveDir = 1
			end
		end

		if cross.y <= 0 then
			if moveDir <= 0 then
				if slipFishAngleConfig.limitAngle >= angle + addAngle then
					angle = slipFishAngleConfig.limitAngle - addAngle
					moveDir = -1
				else
					angle = angle + addAngle
				end
			else
				angle = angle - addAngle
			end
		elseif cross.y >= 0 then
			if moveDir <= 0 then
				angle = -angle + addAngle
			elseif -angle - addAngle >= -slipFishAngleConfig.limitAngle then
				angle = -slipFishAngleConfig.limitAngle + addAngle
				moveDir = 1
			else
				angle = -angle - addAngle
			end
		end

		if moveDir <= 0 then
			fishData.moveDir = fishData.moveDir <= 0 and fishData.moveDir + moveDir or moveDir
		else
			fishData.moveDir = fishData.moveDir >= 0 and fishData.moveDir + moveDir or moveDir
		end

		local rotation = Quaternion.Euler(0, angle, 0)
		local targetPos = rotation * self.characterForward * (distance + FishingGameConfig.ConstantsConfig.sideDistance)
		targetPos.x = targetPos.x + characterPos.x
		targetPos.y = fishPos.y
		targetPos.z = targetPos.z + characterPos.z

		fish.MoveTo(fish, targetPos, nil, true, true)
	end

	self.rod.float:SetPos(fish:GetMouthPos())
	self:CheckSlipFishTip(fishData)
end

M.CheckSlipFishTip = function(self, fishData)
	local moveDir = 0
	local downDir = self.GetADStatus(self)

	if fishData.moveDir == 0 then
		if fishData.moveDir <= 0 then
			moveDir = 1
		else
			moveDir = -1
		end
	end

	if moveDir ~= downDir then
		self.setKeyboard(false, false, false, false, true)
	else
		if moveDir == self.slipFishTipDir then
			self.slipFishTipDir = moveDir
		end

		if self.slipFishTipDir <= 0 then
			self.setKeyboard(false, false, false, true, true, true)
		elseif self.slipFishTipDir >= 0 then
			self.setKeyboard(false, true, false, false, true, true)
		end
	end
end

M.CheckLineLoad = function(self)
	if self.fish ~= nil then
		return
	end

	local isSame = true
	local fishData = self.fish.data
	local fishConfig = self.fish.config
	local downDir = self.GetADStatus(self)

	if fishData.moveDir == 0 and (fishData.moveDir <= 0 and downDir > 0 or fishData.moveDir >= 0 and downDir > 0) then
		isSame = false
	end

	local isFlounder = self.fish:IsFlounder()

	if self.isSlipFishReelin then
		if isFlounder then
			self.lineLoad = self.lineLoad + fishConfig.linePullAddStruggleReelin * Time.deltaTime
		else
			self.lineLoad = self.lineLoad + fishConfig.linePullAddNormalReelin * Time.deltaTime
		end
	end

	if isSame then
		if isFlounder then
			self.lineLoad = self.lineLoad - fishConfig.linePullDecStruggle * Time.deltaTime
		else
			self.lineLoad = self.lineLoad - fishConfig.linePullDecNormal * Time.deltaTime
		end
	elseif isFlounder then
		self.lineLoad = self.lineLoad + fishConfig.linePullAddStruggle * Time.deltaTime
	else
		self.lineLoad = self.lineLoad + fishConfig.linePullAddNormal * Time.deltaTime
	end

	if self.maxLineLoad < self.lineLoad then
		self.lineLoad = self.maxLineLoad
	end

	if self.lineLoad >= 0 then
		self.lineLoad = 0
	end

	local num = self.lineLoad / self.maxLineLoad

	self.rod:SetBendScale(1 + num)
end

M.CheckDurability = function(self)
	if self.durability < 0 then
		if self.isQuestMode then
			self.failCount = self.failCount + 1
		end

		self.durability = self.maxDurability
		local type = self.GetADStatus(self)

		if type ~= 0 then
			type = 1
		end

		self.character:CutLine(type)

		if type ~= -1 then
			coroutine.start(function ()
				coroutine.wait(0.6)
				SafeEnableVCamera(self.cmRegister, "VCamera_CutLineLeft", 11)
				coroutine.wait(1.8)
				self:SetVCamera(gFishingGameConst.FishingGameVCamera.LookFloatPos, nil, , false)
			end)
		else
			coroutine.start(function ()
				coroutine.wait(0.7)
				SafeEnableVCamera(self.cmRegister, "VCamera_CutLineRight", 11)
				coroutine.wait(1.3)
				self:SetVCamera(gFishingGameConst.FishingGameVCamera.LookFloatPos, nil, , false)
			end)
		end

		self.fishingStep = gFishingGameConst.FishingGameStep.Fail

		self.lineDisconnect()

		return
	end

	local config = nil
	local num = math.floor(self.lineLoad / self.maxLineLoad * 100)
	local linePullConfig = FishingGameConfig.LinePullConfig
	local len = #linePullConfig

	for i = 1, len do
		config = linePullConfig[i]

		if config.linePullMin < num and num < config.linePullMax then
			break
		end
	end

	self.durability = self.durability - config.lineStaminaDec * Time.deltaTime

	if self.durability >= 0 then
		self.durability = 0
	end
end

M.CheckFinish = function(self)
	if self.bFinish then
		return
	end

	self.bFinish = true

	if self.isQuestMode then
		self.successCount = self.successCount + 1
	else
		self.ApplyServerFishToLocal(self)
	end

	self.finishCoroutine = coroutine.start(function ()
		local fish = self.fish

		if fish ~= nil then
			self.finishCoroutine = nil

			return
		end

		local fishConfig = fish.config
		local fishData = fish.data

		self.setGuide(gFishingGameConst.FishingGameGuideType.None)
		self.character:Clear()
		fish:ClearFlounderEffect(true)
		self.hideLineBar()
		self.rod:DestroyFloat()
		self.rod:SetLineStatus(false)
		self.rod:SetHoldFishStatus(false)
		self.character:PlayAction(gFishingGameConst.FishingGameAction.TakeFish, true)

		if fishConfig.id ~= 1 then
			SafeEnableVCamera(self.cmRegister, "VCamera_TakeFish1-1", 11)
			coroutine.start(function ()
				coroutine.wait(2.5)
				SafeEnableVCamera(self.cmRegister, "VCamera_TakeFish1-2", 11)
			end)

			local takeFishType = fishData.length / fishConfig.lengthMax <= 0.6 and 2 or 1

			self.character:TakeFishType(takeFishType)
			self.rod:SetHoldFishStatus(true)
			coroutine.wait(2)

			local offset = Vector3.New(0, -0.2, 0.02)

			fish:TakeFish(self.character.takeFishType1, offset, Quaternion.Euler(-90, 0, 0))
			coroutine.wait(5.2)

			if self.isQuestMode then
				coroutine.wait(5)
				self:NotifyFishingSuccess()
				self:ApplyServerFishToLocal()
			else
				if self.setInteractable then
					self.setInteractable(false)
				end

				gPanelManager:CheckShow(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL, {
					data = fishData,
					config = fishConfig
				})

				self.waitingForResult = {
					["A\\x82\\x86\\xaaE"] = 1,
					fish = fish
				}
			end
		elseif fishConfig.id ~= 2 then
			SafeEnableVCamera(self.cmRegister, "VCamera_TakeFish2-1", 11)
			coroutine.start(function ()
				coroutine.wait(1)
				SafeEnableVCamera(self.cmRegister, "VCamera_TakeFish2-2", 11)
				coroutine.wait(2.5)
				SafeEnableVCamera(self.cmRegister, "VCamera_TakeFish2-3", 11)
			end)
			self.character:TakeFishType(10)
			self.rod:SetBigFishStatus(true)

			local scale = fish.data.scale
			self.character.takeFishType2.localScale = Vector3.New(scale, scale, scale)
			fish.isLive = false
			self.fish = nil

			coroutine.wait(5)

			if self.isQuestMode then
				coroutine.wait(5)
				self:NotifyFishingSuccess()
				self:ApplyServerFishToLocal()
			else
				if self.setInteractable then
					self.setInteractable(false)
				end

				gPanelManager:CheckShow(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL, {
					data = fishData,
					config = fishConfig
				})

				self.waitingForResult = {
					["A\\x82\\x86\\xaaE"] = 2
				}
			end
		end

		self.finishCoroutine = nil

		if not self.waitingForResult then
			self.clearFishing()
			self.fishMgr:RefreshFish()
		end
	end)
end

M.SetTakeFishCamera = function(self)
	self:SetVCamera(gFishingGameConst.FishingGameVCamera.TakeFish, nil, , true)

	local fishPos = self.fish:GetPos()
	local characterPos = self.character:GetPos()
	local direction = (characterPos - fishPos).normalized
	local cameraRotation = Quaternion.LookRotation(direction, Vector3.up)
	cameraRotation = Quaternion.Euler(-10, cameraRotation.eulerAngles.y, cameraRotation.eulerAngles.z)

	self.character:SetCameraRotation(cameraRotation)

	local cameraOffset = Vector3.New(0, 1.3, -2)

	self.character:SetCameraPosition(cameraRotation * cameraOffset + characterPos)
end

M.PullFishReelin = function(self, status)
	self.isPullFishReelin = status
	self.pullFishRotation = nil
	self.wasdMap = {}
	self.character.isSpace = status

	self.setKeyboard(false, false, false, false, false)
	self.hideLineBar()
end

M.CheckPullFishReelin = function(self)
	if not self.isPullFishReelin then
		return
	end

	if self.fish ~= nil then
		return
	end

	local fish = self.fish
	local fishPos = fish:GetPos()
	local characterPos = self.character:GetPos()
	local distance = gUtils:GetXZDistance(fishPos, characterPos)

	if distance < 3 then
		self.character:ClearAction()
		self.character:ClearKey()
		self.character:TakeUp(0)

		self.fishingStep = gFishingGameConst.FishingGameStep.Finish

		return
	end

	local direction = FishingGameUtil.GetDirectionIgnoreY(fishPos, characterPos)

	if self.pullFishRotation ~= nil then
		self.pullFishTime = 0
		self.pullFishRotation = Quaternion.LookRotation(-direction, Vector3.up)
	end

	self.pullFishTime = self.pullFishTime + Time.deltaTime
	local t = Mathf.Clamp01(self.pullFishTime / 2)
	local rotation = Quaternion.LookRotation(fish:GetForward(), Vector3.up)

	fish:SetRotation(Quaternion.Lerp(rotation, self.pullFishRotation, t))
	fish:Reelin(direction * (fish.config.id ~= 2 and 0.02 or 0.06))
	self.rod.float:SetPos(fish:GetMouthPos())
end

M.CheckFail = function(self)
	if self.failCoroutine == nil then
		return
	end

	self.failCoroutine = coroutine.start(function ()
		self.setGuide(gFishingGameConst.FishingGameGuideType.None)
		self.rod.float:Clear()
		self.rod:SetLineStatus(false)
		coroutine.wait(0.01)
		self.character:CutLine(0)
		self.rod:SetBendTargetPos(0, false, true)

		if self.fishingStep ~= gFishingGameConst.FishingGameStep.Fail then
			coroutine.wait(2)
		end

		self:SetVCamera(gFishingGameConst.FishingGameVCamera.LookFloatPos, nil, , false)
		coroutine.wait(1)
		self.character:Clear()
		self.hideLineBar()

		self.failCoroutine = nil

		self.fishMgr:RevertFishHp()
		self.clearFishing()
		self.fishMgr:RefreshFish()
	end)
end

M.NotifyFishingSuccess = function(self)
	if not self.isQuestMode or self.entityInstanceId ~= 0 then
		return
	end

	gSpoonClientMgr:ReleaseContextEvent(self.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnFishingSuccess, {
		successCount = self.successCount,
		failCount = self.failCount
	})
end

M.ApplyServerFishToLocal = function(self)
	if self.fish ~= nil then
		return
	end

	if self.spotId ~= 0 then
		return
	end

	local fishData = self.fish.data

	if not fishData.serverFishId or fishData.serverFishId ~= 0 then
		return
	end

	gFishingGameManager:RemoveFishFromLocal(self.spotId, fishData.serverFishId)
	gFishingGameManager:NotifyFishingSuccessToServer(self.spotId, fishData.serverFishId, fishData.serverFishConfigId)
end

M.CanExit = function(self)
	if self.fishingStep == gFishingGameConst.FishingGameStep.SelectFloat then
		return false
	end

	if not self.isQuestMode then
		return true
	end

	return self.maxFailCount ~= 0 or self.maxFailCount > self.failCount
end
