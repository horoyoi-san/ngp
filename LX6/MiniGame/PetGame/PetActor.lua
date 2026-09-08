-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetActor.lua
-- Decompiled from: 02149_PetActor.lua_50d9f50f752c.luajit

local GameObject = UnityEngine.GameObject
local petConfigs = require("LX6/MiniGame/PetGame/data/tbpet")
local accessoryDatas = require("LX6/MiniGame/PetGame/data/tbaccessories")
local petAccessoriesAni = require("LX6/MiniGame/PetGame/data/tbpetaccessoryani")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local AccessoryPoint = PetGameEnum.AccessoryPoint
local AccessoryType = PetGameEnum.AccessoryType
local PetAniEnum = PetGameEnum.PetAniEnum
local PetAnimation = PetGameEnum.PetAnimation
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
local static_props = {}
C_PetActor = DefClass("C_PetActor", C_PetActor, nil, static_props)
local PetActor = C_PetActor

PetActor.ctor = function(self, args)
	args = args or {}
	self.petId = args.petId
	self.hatId = args.hatId or 0
	self.faceAccId = args.faceAccId or 0
	self.backAccId = args.backAccId or 0
	local previewAni = args.previewAni

	if not PetAnimation[previewAni] then
		previewAni = PetAniEnum.idle
	end

	self.previewAni = previewAni
	self.petRequestVersion = 0
	self.accessoryRequestVersion = {}
	self.isDestroyed = false
end

static_props.CloneFromPetEntity = function(petEntity, previewAni)
	if not petEntity or type(petEntity.GetPetDataCopy) == "function" then
		print_error("PetActor CloneFromPetEntity failed: invalid petEntity")

		return nil
	end

	local petSnapshot = petEntity.GetPetDataCopy(petEntity)

	if type(petSnapshot) == "table" or not petConfigs[petSnapshot.id] then
		print_error("PetActor CloneFromPetEntity failed: invalid pet data")

		return nil
	end

	return PetActor.new({
		petId = petSnapshot.id,
		hatId = petSnapshot.hatId or 0,
		faceAccId = petSnapshot.faceAccId or 0,
		backAccId = petSnapshot.backAccId or 0,
		previewAni = previewAni
	})
end

PetActor.GetHatAcc = function(self)
	return self.hatId
end

PetActor.GetFaceAcc = function(self)
	return self.faceAccId
end

PetActor.GetBackAcc = function(self)
	return self.backAccId
end

PetActor.GetAccByType = function(self, accType)
	if accType ~= AccessoryType.hat then
		return self.hatId
	elseif accType ~= AccessoryType.face then
		return self.faceAccId
	elseif accType ~= AccessoryType.back then
		return self.backAccId
	end
end

PetActor.GetAllAccessories = function(self)
	local accessories = {
		[AccessoryType.hat] = self.hatId,
		[AccessoryType.face] = self.faceAccId,
		[AccessoryType.back] = self.backAccId
	}

	return accessories
end

PetActor._NextPetRequestVersion = function(self)
	self.petRequestVersion = self.petRequestVersion + 1

	return self.petRequestVersion
end

PetActor._IsPetRequestCurrent = function(self, requestVersion)
	return not self.isDestroyed and self.petRequestVersion ~= requestVersion
end

PetActor.LoadPetGameObject = function(self, parent)
	if self.isDestroyed then
		print_error("PetActor LoadPetGameObject failed: actor is destroyed")

		return false
	end

	if not parent then
		print_error("PetActor LoadPetGameObject failed: parent is nil")

		return false
	end

	local petInfo = petConfigs[self.petId]

	if not petInfo or not petInfo.prefab then
		print_error("PetActor LoadPetGameObject failed: invalid pet id", self.petId)

		return false
	end

	self:ClearPetGo()

	self.petGoParentTrans = parent
	local requestVersion = self.petRequestVersion
	local prefabPath = petInfo.prefab
	slot5 = gResourceManager

	slot5:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		if not self:_IsPetRequestCurrent(requestVersion) then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			error("Failed to load pet prefab: " .. prefabPath)

			return
		end

		local petGameObject = GameObject.Instantiate(loadOp.asset, parent)

		if not petGameObject then
			error("Failed to instantiate pet prefab: " .. prefabPath)

			return
		end

		petGameObject.transform.localPosition = Vector3.zero
		self.petGo = petGameObject
		self.animator = petGameObject.transform:GetComponent("Animation")

		self:PlayAni()
		self:LoadAccessories()
	end)

	return true
end

PetActor.GetAnimator = function(self)
	if self.animator then
		return self.animator
	end

	if self.petGo and self.petGo.transform then
		self.animator = self.petGo.transform:GetComponent("Animation")
	end

	return self.animator
end

PetActor.PlayAni = function(self)
	local animator = self.GetAnimator(self)

	if not animator then
		print_error("PetActor PlayAni failed: animator is nil")

		return false
	end

	local baseAni = PetAnimation[self.previewAni]

	if not baseAni or not animator.GetClip(animator, baseAni) then
		print_error("PetActor animation clip not found:", self.previewAni)

		return false
	end

	self.curPlayingAni = self.previewAni

	animator.Stop(animator)
	animator.Play(animator, baseAni, 4)

	if not self.acessoryAniDict then
		return true
	end

	for _, accessoryType in ipairs(accessoryTypes) do
		local accessoryAnis = self.acessoryAniDict[accessoryType]
		local accessoryAni = accessoryAnis and accessoryAnis[self.previewAni]

		if accessoryAni then
			animator.Blend(animator, accessoryAni.name)
		end
	end

	return true
end

PetActor._MatchAccessoryCurAniOnLoad = function(self, aniName, realAniName)
	self.animator:Blend(realAniName)
end

PetActor._GetAccessoryRequestVersion = function(self, accessoryType)
	return self.accessoryRequestVersion[accessoryType] or 0
end

PetActor._NextAccessoryRequestVersion = function(self, accessoryType)
	local version = self._GetAccessoryRequestVersion(self, accessoryType) + 1
	self.accessoryRequestVersion[accessoryType] = version

	return version
end

PetActor._IsAccessoryRequestCurrent = function(self, accessoryType, requestVersion)
	return not self.isDestroyed and self:_GetAccessoryRequestVersion(accessoryType) ~= requestVersion
end

PetActor._InvalidateAllAccessoryRequests = function(self)
	for _, accessoryType in ipairs(accessoryTypes) do
		self._NextAccessoryRequestVersion(self, accessoryType)
	end
end

PetActor.GetAccessoryMountPoint = function(self, accessoryType)
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

	return nil
end

PetActor.LoadAccessories = function(self)
	if self.hatId <= 0 then
		self._loadAccessory(self, self.hatId)
	end

	if self.faceAccId <= 0 then
		self._loadAccessory(self, self.faceAccId)
	end

	if self.backAccId <= 0 then
		self._loadAccessory(self, self.backAccId)
	end
end

PetActor._ClearAccessory = function(self, accessoryType)
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

PetActor.TryOnAccessory = function(self, accessoryId)
	if self.isDestroyed then
		return false
	end

	local accessoryData = accessoryDatas[accessoryId]
	local accessoryType = accessoryData and accessoryData.type
	local attributeName = accessoryAttributeByType[accessoryType]

	if not accessoryData or not attributeName then
		print_error("PetActor TryOnAccessory failed:", accessoryId)

		return false
	end

	local requestVersion = self._NextAccessoryRequestVersion(self, accessoryType)

	self._ClearAccessory(self, accessoryType)

	self[attributeName] = accessoryId

	self._loadAccessory(self, accessoryId, requestVersion)

	return true
end

PetActor.RemoveAccessory = function(self, accessoryId)
	if self.isDestroyed then
		return false
	end

	local accessoryData = accessoryDatas[accessoryId]
	local accessoryType = accessoryData and accessoryData.type
	local attributeName = accessoryAttributeByType[accessoryType]

	if not accessoryData or not attributeName then
		print_error("PetActor RemoveAccessory failed:", accessoryId)

		return false
	end

	if self[attributeName] == accessoryId then
		return false
	end

	self._NextAccessoryRequestVersion(self, accessoryType)

	self[attributeName] = 0

	self._ClearAccessory(self, accessoryType)
	self.PlayAni(self)

	return true
end

PetActor._loadAccessory = function(self, accessoryId, requestVersion)
	local accessoryData = accessoryDatas[accessoryId]
	local accessoryType = accessoryData and accessoryData.type

	if not accessoryData or not accessoryAttributeByType[accessoryType] then
		print_error("PetActor LoadAccessory failed:", accessoryId)

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

PetActor._loadAccessoryGo = function(self, slotName, prefabPath, mountPoint, accessoryType, requestVersion)
	if not prefabPath or not mountPoint then
		print_error("PetActor LoadAccessoryGo failed:", slotName, prefabPath)

		return
	end

	slot6 = gResourceManager

	slot6:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		if not self:_IsAccessoryRequestCurrent(accessoryType, requestVersion) then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			error("Failed to load pet accessory prefab: " .. prefabPath)

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
	end)
end

PetActor._loadAccessoriesAni = function(self, accessoryId, accessoryType, requestVersion)
	local animationDataId = self.petId .. "_" .. accessoryId
	local petAccAniData = petAccessoriesAni[animationDataId]

	if not petAccAniData then
		animationDataId = "common_" .. accessoryId
		petAccAniData = petAccessoriesAni[animationDataId]
	end

	if not petAccAniData then
		print_error("PetActor accessory animation data not found:", animationDataId)

		return
	end

	local animationPath = petAccAniData[self.previewAni]

	if not animationPath then
		print_error("PetActor accessory animation not found:", animationDataId, self.previewAni)

		return
	end

	local animation = self.GetAnimator(self)

	if not animation then
		print_error("PetActor animator not found")

		return
	end

	self._loadAccessoryAni(self, accessoryType, self.previewAni, animationPath, animation, requestVersion)
end

PetActor._loadAccessoryAni = function(self, accessoryType, aniName, aniPath, animation, requestVersion)
	local path = "Assets/Res/SGUI/Panel/PetGame/GameContent/AccessoryAni/" .. aniPath .. ".anim"
	slot7 = gResourceManager

	slot7:LoadAssetWithCallBack(path, typeof(UnityEngine.AnimationClip), function (loadOp)
		if not self:_IsAccessoryRequestCurrent(accessoryType, requestVersion) then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp.asset then
			error("Failed to load pet accessory animation: " .. path)

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
		self:PlayAni()
	end)
end

PetActor.ClearPetGo = function(self)
	self._NextPetRequestVersion(self)
	self._InvalidateAllAccessoryRequests(self)

	if self.petGo then
		GameObject.Destroy(self.petGo)

		self.petGo = nil
	end

	self.animator = nil
	self.acessoryGoDict = nil
	self.acessoryAniDict = nil
	self.curPlayingAni = nil
end

PetActor.Destroy = function(self)
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true

	self.ClearPetGo(self)

	self.petGoParentTrans = nil
end
