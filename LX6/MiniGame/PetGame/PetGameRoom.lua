-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameRoom.lua
-- Decompiled from: 02141_PetGameRoom.lua_3feee412e675.luajit

local roomConf = require("LX6/MiniGame/PetGame/data/tbroom")
local furnitureConf = require("LX6/MiniGame/PetGame/data/tbfurniture")
local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local FurnitureType = PetGameEnum.FurnitureType
local petBehaviorState = PetGameConst.Behavior
C_PetGameRoom = DefClass("C_PetGameRoom", C_PetGameRoom)
local PetGameRoom = C_PetGameRoom

PetGameRoom.ctor = function(self, args)
	self.roomObj = args.roomObj
	self.roomId = args.roomId
	self.roomConf = roomConf[self.roomId]
	self.furnitures = args.furnitures or {}
	self.furnituresGoDic = {}
	local roomParentNode = self.roomObj.transform

	self:InitBirthPoint(roomParentNode)
	self:InitFurniturePoints(roomParentNode)
	self:InitMoveArea(roomParentNode)
	self:InitPooTrans(roomParentNode)
	self:InitPetTrans(roomParentNode)
	self:InitItemTrans(roomParentNode)
	self:InitPetShadowTrans(roomParentNode)
end

PetGameRoom.Show = function(self)
	self.active = true

	if self.roomObj then
		self.roomObj:SetActive(true)
	end

	self.SetFurnitureVisible(self, true)
end

PetGameRoom.Hide = function(self)
	self.active = false

	if self.roomObj then
		self.roomObj:SetActive(false)
	end

	self.SetFurnitureVisible(self, false)
end

PetGameRoom.SetFurnitureVisible = function(self, visible)
	for i, v in pairs(self.furnituresGoDic) do
		if v then
			v.SetVisible(v, visible, self.active)
		end
	end
end

PetGameRoom.SetDayNightState = function(self, isDay)
	self.isDay = isDay ~= true

	for _, furniture in pairs(self.furnituresGoDic) do
		if furniture and furniture.SetDayNightState then
			furniture.SetDayNightState(furniture, self.isDay)
		end
	end
end

PetGameRoom.GetDayNightState = function(self)
	return self.isDay
end

PetGameRoom.SetRainingState = function(self, isRaining)
	self.isRaining = isRaining ~= true

	for _, furniture in pairs(self.furnituresGoDic) do
		if furniture and furniture.SetRainingState then
			furniture.SetRainingState(furniture, self.isRaining)
		end
	end
end

PetGameRoom.GetRainingState = function(self)
	return self.isRaining
end

PetGameRoom.SetStageMode = function(self, stageMode, keepFurnitureVisible)
	self.StageMode = stageMode

	if stageMode and keepFurnitureVisible then
		return
	end

	for i, v in pairs(self.furnituresGoDic) do
		if v then
			v.SetStageMode(v, stageMode)
		end
	end
end

PetGameRoom.CreateFurniture = function(self, slotId, conf, pointParent, position)
	local furnitureClass = C_PetGameFurniture

	if conf.type ~= FurnitureType.Bed or conf.type ~= FurnitureType.Lamp then
		furnitureClass = C_PetGameBedRoomFurniture
	end

	local furniture = furnitureClass.new({
		slotId = slotId,
		conf = conf,
		parent = pointParent,
		position = position,
		ownerRoom = self
	})

	if self.isDay == nil and furniture.SetDayNightState then
		furniture.SetDayNightState(furniture, self.isDay)
	end

	if self.isRaining == nil and furniture.SetRainingState then
		furniture.SetRainingState(furniture, self.isRaining)
	end

	return furniture
end

PetGameRoom.InitFurniturePoints = function(self, roomParentNode)
	self.frontFurnitureTrans = roomParentNode.Find(roomParentNode, "frontFurniture")
	self.furniturePointsParent = roomParentNode.Find(roomParentNode, "furniturePoints")

	if self.furniturePointsParent then
		self.furniturePoints = {}

		for i = 1, self.furniturePointsParent.childCount do
			local pointNode = self.furniturePointsParent:GetChild(i - 1)

			table.insert(self.furniturePoints, pointNode)
		end
	else
		print_error("Cannot find furniture points node in room:", self.roomId)
	end
end

PetGameRoom.ApplyFurnitureData = function(self)
	local defultFurniture = self.roomConf.defualtFur or {}
	local furnitureData = table.combine(defultFurniture, self.furnitures)

	for k, v in pairs(furnitureData) do
		local conf = furnitureConf[v]

		if conf then
			if self.furnituresGoDic[k] then
				self.furnituresGoDic[k]:Clear()

				self.furnituresGoDic[k] = nil
			end

			self.furnitures[k] = v
			local pointParent = conf.coverPet and self.frontFurnitureTrans or self.furniturePointsParent

			if self.furniturePoints[k] then
				local position = self.furniturePoints[k].position
				local furniture = self.CreateFurniture(self, k, conf, pointParent, position)
				self.furnituresGoDic[k] = furniture
			else
				print_error(string.format("Furniture slot %d does not exist in room %d", k, self.roomId))
			end
		end
	end
end

PetGameRoom.StopPetFurnitureInteraction = function(self)
	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local petEntity = currentGame and currentGame:GetPetEnity()

	if petEntity and petEntity.GetFurnitureInteractionData(petEntity) then
		petEntity.ChangeState(petEntity, petBehaviorState.idle)
	end
end

PetGameRoom.ChangeFurniture = function(self, slot, newFurnitureId)
	local conf = furnitureConf[newFurnitureId]

	if conf then
		self.StopPetFurnitureInteraction(self)

		self.furnitures[slot] = newFurnitureId

		if self.furnituresGoDic[slot] then
			self.furnituresGoDic[slot]:Clear()

			self.furnituresGoDic[slot] = nil
		end

		local pointParent = conf.coverPet and self.frontFurnitureTrans or self.furniturePointsParent
		local position = self.furniturePoints[slot].position
		local furniture = self:CreateFurniture(slot, conf, pointParent, position)
		self.furnituresGoDic[slot] = furniture
	else
		print_error("Invalid furniture id:", newFurnitureId)
	end
end

PetGameRoom.GetRoomId = function(self)
	return self.roomId
end

PetGameRoom.GetFurnitureData = function(self)
	return self.furnitures
end

PetGameRoom.Reset = function(self)
end

PetGameRoom.Clear = function(self)
	for k, v in pairs(self.furnituresGoDic) do
		if v then
			v.Clear(v)

			self.furnituresGoDic[k] = nil
		end
	end

	self.furnituresGoDic = {}
	self.furnitures = {}
end

PetGameRoom.InitBirthPoint = function(self, roomParentNode)
	local leftNode = roomParentNode.Find(roomParentNode, "birthPoint/left")
	local rightNode = roomParentNode.Find(roomParentNode, "birthPoint/right")

	if leftNode then
		self.leftBirthPoint = leftNode.transform.position
	else
		print_error("Cannot find birth point: left")
	end

	if rightNode then
		self.rightBirthPoint = rightNode.transform.position
	else
		print_error("Cannot find birth point: right")
	end

	self.petFollow = roomParentNode.Find(roomParentNode, "petFollow")
end

PetGameRoom.GetBirthPoint = function(self, isLeft)
	if isLeft then
		return self.leftBirthPoint
	elseif not isLeft then
		return self.rightBirthPoint
	end
end

PetGameRoom.GetPetFollow = function(self)
	return self.petFollow
end

PetGameRoom.InitMoveArea = function(self, roomParentNode)
	local moveAreaNode = roomParentNode.Find(roomParentNode, "moveArea")

	if moveAreaNode then
		local collider = moveAreaNode.GetComponent(moveAreaNode, typeof(UnityEngine.Collider2D))

		if collider then
			self.moveAreaCollider = collider
		else
			print_error("Cannot find move area collider in room:", self.roomId)
		end
	else
		print_error("Cannot find move area node in room:", self.roomId)
	end
end

PetGameRoom.GetMovePointInMoveArea = function(self)
	if not self.moveAreaCollider then
		self.InitMoveArea(self, self.roomObj.transform)
	end

	if not self.moveAreaCollider then
		print_error("PetGameRoom:GetMovePointInMoveArea failed, moveAreaCollider is nil", self.roomId)

		return nil
	end

	local bounds = self.moveAreaCollider.bounds

	if not bounds then
		print_error("PetGameRoom:GetMovePointInMoveArea failed, moveAreaCollider.bounds is nil", self.roomId)

		return nil
	end

	local min = bounds.min
	local max = bounds.max
	local bestPoint = bounds.center

	local isValidPoint = function(point)
		if self.moveAreaCollider.OverlapPoint then
			return self.moveAreaCollider:OverlapPoint(point)
		end

		return bounds:Contains(point)
	end

	for i = 1, 20 do
		local x = min.x + math.random() * (max.x - min.x)
		local y = min.y + math.random() * (max.y - min.y)
		local point = Vector3(x, y, bounds.center.z)

		if isValidPoint(point) then
			return point
		end
	end

	if isValidPoint(bestPoint) then
		return bestPoint
	end

	return bestPoint
end

PetGameRoom.GetRoomNodeObj = function(self)
	return self.roomObj
end

PetGameRoom.GetFurnitureBySlot = function(self, slotIndex)
	return self.furnituresGoDic[slotIndex]
end

PetGameRoom.GetFurnitureGoByType = function(self, furnitureType)
	local furnitureInfo = self:GetFurnitureByType(furnitureType)

	return furnitureInfo and furnitureInfo.furnitureGo or nil
end

PetGameRoom.GetFurnitureByType = function(self, furnitureType)
	for _, furnitureInfo in pairs(self.furnituresGoDic) do
		if furnitureInfo.conf.type ~= furnitureType then
			return furnitureInfo
		end
	end

	return nil
end

PetGameRoom.GetAllFurnitures = function(self)
	return self.furnituresGoDic
end

PetGameRoom.GetInteractiveFurnitureList = function(self)
	local furnitureList = {}
	local totalWeight = 0

	if self.StageMode then
		return furnitureList, totalWeight
	end

	for slot, furnitureInfo in pairs(self.furnituresGoDic) do
		if furnitureInfo and furnitureInfo.IsInteractive(furnitureInfo) then
			totalWeight = totalWeight + furnitureInfo.weight

			table.insert(furnitureList, furnitureInfo)
		end
	end

	table.sort(furnitureList, function (a, b)
		return (a.slotId or 0) <= (b.slotId or 0)
	end)

	return furnitureList, totalWeight
end

PetGameRoom.ChooseFurnitureInteraction = function(self)
	local furnitureList, totalWeight = self.GetInteractiveFurnitureList(self)

	if totalWeight < 0 then
		return nil
	end

	local randomWeight = math.random() * totalWeight
	local cumulativeWeight = 0

	for _, furnitureInfo in ipairs(furnitureList) do
		cumulativeWeight = cumulativeWeight + furnitureInfo.weight

		if randomWeight < cumulativeWeight then
			return furnitureInfo
		end
	end

	return furnitureList[#furnitureList]
end

PetGameRoom.InitPooTrans = function(self, roomParentNode)
	local pooTransNode = roomParentNode.Find(roomParentNode, "pooTrans")
	local lenth = pooTransNode.childCount
	self.pooTransList = {}
	self.pooGoList = {}
	self.pooNum = 0

	for i = 1, lenth do
		local pooTrans = pooTransNode.GetChild(pooTransNode, i - 1)

		table.insert(self.pooTransList, pooTrans)
	end
end

PetGameRoom.AddPoo = function(self)
	local maxNum = #self.pooTransList
	local currentNum = #self.pooGoList

	if maxNum < currentNum then
		print_error("Cannot add more poo, already at max:", maxNum)

		return
	end

	local pooIndex = currentNum + 1
	local pooTrans = self.pooTransList[pooIndex]

	self.LoadPoo(self, pooTrans, self.pooGoList)

	self.pooNum = self.pooNum + 1
end

PetGameRoom.ShowPooByNum = function(self, number)
	for i = 1, number do
		self.AddPoo(self)
	end
end

PetGameRoom.PlayClearAni = function(self)
	local delay = 0

	for i, v in pairs(self.pooGoList) do
		if v then
			local animation = v.GetComponent(v, typeof(UnityEngine.Animation))

			if animation then
				delay = delay + 0.1

				Timer.New(function ()
					if animation then
						animation:Play("clean")
					end
				end, delay, 1):Start()
			end
		end
	end

	delay = 1 + delay

	self.ClearAllPoo(self, delay)
end

PetGameRoom.ClearAllPoo = function(self, delayTime)
	self.pooNum = 0

	for i, go in pairs(self.pooGoList) do
		if go then
			UnityEngine.GameObject.Destroy(go, delayTime or 0)

			self.pooGoList[i] = nil
		end
	end
end

PetGameRoom.HideAllPoo = function(self)
	for i, go in pairs(self.pooGoList) do
		if go then
			go.SetActive(go, false)
		end
	end
end

PetGameRoom.ShowAllPoo = function(self)
	for i, go in pairs(self.pooGoList) do
		if go then
			go.SetActive(go, true)
		end
	end
end

PetGameRoom.GetPooNum = function(self)
	return self.pooNum
end

PetGameRoom.LoadPoo = function(self, parent, pooGoList)
	local prefabPath = "Assets/Res/SGUI/Panel/PetGame/GameContent/pet/effects_clean.prefab"
	slot4 = gCoroutineManager

	slot4:StartCoroutine(function ()
		local loadOp = gResourceManager:LoadAssetAsync(prefabPath, typeof(UnityEngine.GameObject))

		coroutine.yield(loadOp)

		if loadOp.asset then
			local pooGo = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not pooGo then
				error("Failed to instantiate poo prefab: " .. prefabPath)

				return
			end

			pooGo.transform.localPosition = Vector3.zero
			pooGo.transform.localRotation = Quaternion.identity

			table.insert(pooGoList, pooGo)
		else
			error("Failed to load Poo prefab: " .. prefabPath)
		end
	end)
end

PetGameRoom.InitPetShadowTrans = function(self, roomParentNode)
	local pooTransNode = roomParentNode.Find(roomParentNode, "shadow")
	self.petShadowTrans = pooTransNode
end

PetGameRoom.GetPetShadowTrans = function(self)
	return self.petShadowTrans
end

PetGameRoom.InitPetTrans = function(self, roomTrans)
	local petTrans = roomTrans.Find(roomTrans, "pet")
	self.petTrans = petTrans
end

PetGameRoom.GetPetTrans = function(self)
	return self.petTrans
end

PetGameRoom.InitItemTrans = function(self, roomTrans)
	local itemTrans = roomTrans.Find(roomTrans, "stageItemTrans")
	self.ItemTrans = itemTrans
end

PetGameRoom.GetItemTrans = function(self)
	return self.ItemTrans
end

PetGameRoom.GetRoomName = function(self)
	return gPetGameMultilingual:GetText(self.roomConf.name)
end
