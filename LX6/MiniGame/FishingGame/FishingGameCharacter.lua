-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameCharacter.lua
-- Decompiled from: 00597_FishingGameCharacter.lua_a6ae80b57912.luajit

C_FishingGameCharacter = DefClass("C_FishingGameCharacter", C_FishingGameCharacter)
local M = C_FishingGameCharacter
local FISHING_CONTROLLER_PATH = "Res/MiniGame/Other/FishingGame/Animation/FishingCtrl.controller"

M.ctor = function(self)
	self.addAngleSpeed = 200
	self.attractAngle = 45
	self.currentAngle = 0
	self.downDir = 0
	self.isSpace = false
	self.baseUnit = nil
end

M.Init = function(self)
	self.gameObject = UnityEngine.GameObject.Find("Fishing/Character")
	self.transform = self.gameObject.transform
	self.animator = self.transform:GetComponent("Animator")
	self.takeFishType1 = self.transform:Find("Reference02/MotionRoot2/prop_Clip_03")
	self.takeFishType2 = self.transform:Find("Reference03/MotionRoot03/Root")
	self.initCharPos = self.transform.localPosition
	self.initCharRot = self.transform.localRotation
end

M.LoadModel = function(self, onComplete)
	local oldCharGO = self.gameObject
	local oldCharTF = self.transform
	local charParent = oldCharTF.parent
	slot5 = gResourceManager

	slot5:LoadAssetWithCallBack(FISHING_CONTROLLER_PATH, typeof(UnityEngine.RuntimeAnimatorController), function (controllerLoadOp)
		local fishingController = controllerLoadOp.asset
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		local fightSpiritId = gCS.MyPlayerManager.PlayerUnit.NpcId
		local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(fightSpiritId)
		local agentId = fightSpiritCfg and fightSpiritCfg.AgentId or 0

		gCS.UnitsManager:GetDialogModelByAgentId(function (baseUnit, _)
			self.baseUnit = baseUnit
			local modelSlotTF = baseUnit.ModelSlot.transform

			modelSlotTF:SetParent(charParent)

			modelSlotTF.localPosition = self.initCharPos
			modelSlotTF.localRotation = self.initCharRot
			modelSlotTF.localScale = Vector3.New(1, 1, 1)
			local playerTF = modelSlotTF:Find("player")

			if not playerTF then
				print("FishingGameCharacter: 'player' node not found in new model")

				return
			end

			local bodyNode = playerTF:Find("body")

			if bodyNode then
				bodyNode.name = "body1"
			end

			for i = oldCharTF.childCount - 1, 0, -1 do
				local child = oldCharTF:GetChild(i)

				if child.gameObject.activeSelf then
					local existing = playerTF:Find(child.name)

					if not existing then
						child:SetParent(playerTF)
					else
						for j = child.childCount - 1, 0, -1 do
							local subChild = child:GetChild(j)
							local existingSub = existing:Find(subChild.name)

							if not existingSub then
								subChild:SetParent(existing)
							end
						end
					end
				end
			end

			local animancer = playerTF:GetComponentInChildren(typeof(Animancer.AnimancerComponent))

			if animancer then
				animancer.enabled = false
			end

			local animator = playerTF.gameObject:GetOrAddComponent(typeof(UnityEngine.Animator))
			animator.runtimeAnimatorController = fishingController

			oldCharGO:SetActive(false)

			self.gameObject = playerTF.gameObject
			self.transform = playerTF
			self.animator = animator
			self.takeFishType1 = playerTF:Find("Reference02/MotionRoot2/prop_Clip_03")
			self.takeFishType2 = playerTF:Find("Reference03/MotionRoot03/Root")
			self.initCharPos = playerTF.localPosition
			self.initCharRot = playerTF.localRotation

			if onComplete then
				onComplete()
			end
		end, sexType, agentId, false, true, true, fightSpiritId)
	end)
end

M.SetData = function(self, system, vcIndex, vcam, follow, lookAt, isRotation)
	self.system = system
	self.vcIndex = vcIndex
	self.isRotation = isRotation
	self.cvCamera = vcam
	self.lookCamera = vcam.transform
	local initData = system.vcamInitData and system.vcamInitData[vcam.name]

	if initData then
		self.lookCameraPos = initData.position - self.GetPos(self)
		self.initRotation = initData.localRotation
		self.lookCamera.localRotation = initData.localRotation
	else
		self.lookCameraPos = self.lookCamera.position - self.GetPos(self)
		self.initRotation = self.lookCamera.localRotation
	end

	if follow == nil then
		self.cvCamera.Follow = follow
	end

	if lookAt == nil then
		self.cvCamera.LookAt = lookAt
	end
end

M.SetCameraPosition = function(self, pos)
	self.lookCamera.position = pos
end

M.SetCameraRotation = function(self, rotation)
	self.lookCamera.localRotation = rotation
end

M.PlayAction = function(self, action, status)
	self.animator:SetBool(action, status)
end

M.TakeUp = function(self, value)
	self.animator:SetInteger(gFishingGameConst.FishingGameAction.TakeUp, value)
end

M.TakeFishType = function(self, type)
	self.animator:SetInteger(gFishingGameConst.FishingGameAction.TakeFishType, type)
end

M.CutLine = function(self, type)
	self.animator:SetInteger(gFishingGameConst.FishingGameAction.CutLine, type)
end

M.ClearAction = function(self)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.Idle, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.CastFloat, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.PullLeft, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.PullRight, false)
	self.animator:SetBool(gFishingGameConst.FishingGameAction.TakeFish, false)
end

M.Update = function(self)
	self.CheckCamera(self)
	self.CheckPullAction(self)
	self.CheckTakeUp(self)
end

M.Clear = function(self)
	self.dynamicFloatOffset = nil
	self.transform.localPosition = self.initCharPos
	self.transform.localRotation = self.initCharRot
	self.vcIndex = 0
	self.downDir = 0

	self.ClearKey(self)
	self.ClearAction(self)
	self.TakeFishType(self, 0)
	self.CutLine(self, 0)
	self.PlayAction(self, gFishingGameConst.FishingGameAction.Idle, true)
end

M.Destroy = function(self)
	self.Clear(self)

	if self.baseUnit then
		if gCS.LuaUtils.IsBaseUnitValid(self.baseUnit) then
			self.baseUnit:DestroyUnit(true)
		end

		self.baseUnit = nil
	end

	self.system = nil
	self.lookCamera = nil
	self.cvCamera = nil
end

M.GetPos = function(self)
	return self.transform.position
end

M.GetRight = function(self)
	return self.transform.right
end

M.GetForward = function(self)
	return self.transform.forward
end

M.SetAttractAngle = function(self, attractAngle)
	self.attractAngle = attractAngle
end

M.CheckCamera = function(self)
	if self.vcIndex ~= gFishingGameConst.FishingGameVCamera.LookFloatPos then
		self.LookFloatPos(self)
	elseif self.vcIndex ~= gFishingGameConst.FishingGameVCamera.FollowFloat then
		self.FollowFloat(self)
	elseif self.vcIndex ~= gFishingGameConst.FishingGameVCamera.LookFish then
		self.LookFish(self)
	end
end

M.LookFish = function(self)
	local fish = self.system.fish

	if fish ~= nil then
		return
	end

	local characterPos = self.GetPos(self)
	local fishPos = fish.GetPos(fish)
	local direction = (fishPos - characterPos).normalized
	direction.y = 0
	local rotation = Quaternion.LookRotation(direction, Vector3.up)
	local eulerAngles = rotation.eulerAngles
	rotation = Quaternion.Euler(0, eulerAngles.y, eulerAngles.z)

	if self.isRotation then
		self.transform.localRotation = rotation
	end

	eulerAngles = self.transform.localRotation.eulerAngles
	rotation = Quaternion.Euler(self.initRotation.eulerAngles.x, eulerAngles.y, eulerAngles.z)
	self.lookCamera.localRotation = rotation
end

M.LookFloatPos = function(self)
	local characterPos = self.GetPos(self)
	local floatPos = self.system.floatPosTF.position
	local direction = (floatPos - characterPos).normalized
	direction.y = 0
	local rotation = Quaternion.LookRotation(direction, Vector3.up)
	local eulerAngles = rotation.eulerAngles
	rotation = Quaternion.Euler(0, eulerAngles.y, eulerAngles.z)

	if self.isRotation then
		self.transform.localRotation = rotation
	end

	eulerAngles = rotation.eulerAngles
	rotation = Quaternion.Euler(self.initRotation.eulerAngles.x, eulerAngles.y, eulerAngles.z)
	self.lookCamera.localRotation = rotation
	self.lookCamera.position = rotation * self.lookCameraPos + self.GetPos(self)
end

M.FollowFloat = function(self)
	local characterPos = self:GetPos()
	local floatPos = self.system.rod.float:GetPos()
	local direction = (floatPos - characterPos).normalized
	direction.y = 0
	local rotation = Quaternion.LookRotation(direction, Vector3.up)

	if self.isRotation then
		self.transform.localRotation = rotation
	end

	local eulerAngles = rotation.eulerAngles
	rotation = Quaternion.Euler(self.initRotation.eulerAngles.x, eulerAngles.y, eulerAngles.z)
	self.lookCamera.localRotation = rotation
	local initData = self.system.vcamInitData and self.system.vcamInitData[self.lookCamera.name]
	local floatOffset = initData and initData.localPosition or Vector3.New(0, 0.1, -3.43)

	if floatOffset.x ~= 0 and floatOffset.y ~= 0 and floatOffset.z ~= 0 then
		floatOffset = Vector3.New(0, 0.1, -3.43)
	end

	self.lookCamera.position = rotation * floatOffset + floatPos
end

M.CheckTakeUp = function(self)
	if not self.isSpace then
		self.TakeUp(self, 0)

		return
	end

	if self.downDir ~= 1 then
		self.TakeUp(self, 1)
	elseif self.downDir ~= -1 then
		self.TakeUp(self, -1)
	else
		self.TakeUp(self, 2)
	end
end

M.CheckPullAction = function(self)
	if self.system.fishingStep == gFishingGameConst.FishingGameStep.SlipFish then
		return
	end

	self.downDir = self.system:GetADStatus()

	self:PlayAction(gFishingGameConst.FishingGameAction.PullLeft, self.downDir ~= -1)
	self:PlayAction(gFishingGameConst.FishingGameAction.PullRight, self.downDir ~= 1)
end

M.ClearKey = function(self)
	self.isSpace = false
	self.downDir = 0
end
