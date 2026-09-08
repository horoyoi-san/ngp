-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQAIController.lua
-- Decompiled from: 00672_BBQAIController.lua_02658e74d6b1.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
local AIConfig = BBQConfig.AI
gBBQAIController = DefClass("BBQAIController", gBBQAIController)
local BBQAIController = gBBQAIController

BBQAIController.ctor = function(self)
	self.playerId = -1
	self.game = nil
	self.isPerformingAction = false
	self.thinkCoroutine = nil
	self.actionCoroutines = {}
	self.flippedMeatCoolDown = {}
	self.flipCoolDownTime = BBQConstants.FlipCoolDownTime
	self.currentMousePos = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
end

BBQAIController.Initialize = function(self, game, playerId)
	self.playerId = playerId
	self.game = game
	self.isPerformingAction = false
	self.flippedMeatCoolDown = {}
	self.currentMousePos = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.actionCoroutines = {}

	self.StartThinkLoop(self)
end

BBQAIController.StartThinkLoop = function(self)
	self.CancelAllCoroutines(self)

	self.thinkCoroutine = coroutine.start(function ()
		while self.game.gamePhase == BBQConstants.GamePhase.Playing do
			coroutine.wait(0.1)

			if self.game.hasDestroy then
				return
			end
		end

		while not self.game.hasDestroy and self.game.gamePhase ~= BBQConstants.GamePhase.Playing and not gClientUtils.IsNil(self.game.sceneNodeGo) do
			local waitTime = math.random() * (AIConfig.ThinkIntervalMax - AIConfig.ThinkIntervalMin) + AIConfig.ThinkIntervalMin

			coroutine.wait(waitTime)

			if self.game.hasDestroy then
				return
			end

			if gClientUtils.IsNil(self.game.sceneNodeGo) then
				return
			end

			if not self.isPerformingAction then
				self:ExecuteAIDecision()
			end
		end
	end)
end

BBQAIController.ExecuteAIDecision = function(self)
	if self.TryHandleBurntMeat(self) then
		return
	end

	if self.TryTakeCookedMeat(self) then
		return
	end

	if self.TryFlipMeat(self) then
		return
	end

	self.TryTakeMeatFromPlate(self)
end

BBQAIController.TryHandleBurntMeat = function(self)
	if self.isPerformingAction then
		return false
	end

	if AIConfig.BurntProb >= math.random() then
		return false
	end

	local player = self.game:GetPlayer(self.playerId)

	if not player or player.hasEnterDrag then
		return false
	end

	local burntMeats = self.game:GetBurntMeats()
	local otherBowls = self.game:GetOtherPlayerBowls(self.playerId)

	if #burntMeats ~= 0 or #otherBowls ~= 0 then
		return false
	end

	local targetMeat = burntMeats[math.random(1, #burntMeats)]
	local targetBowl = nil

	if math.random() < AIConfig.BurntMistakeProb then
		targetBowl = self.game:GetPlayerBowl(self.playerId)
	else
		targetBowl = otherBowls[math.random(1, #otherBowls)]
	end

	if not targetBowl then
		return false
	end

	self.StartActionCoroutine(self, "DragMeat", targetMeat.id, targetBowl)

	return true
end

BBQAIController.TryTakeCookedMeat = function(self)
	if self.isPerformingAction then
		return false
	end

	if AIConfig.PickProb >= math.random() then
		return false
	end

	local player = self.game:GetPlayer(self.playerId)

	if not player or player.hasEnterDrag then
		return false
	end

	local selfBowl = self.game:GetPlayerBowl(self.playerId)

	if not selfBowl then
		return false
	end

	local targetCookLevel = math.random(AIConfig.CookLevelThresholdMin, AIConfig.CookLevelThresholdMax)
	local availableMeats = self.game:GetAvailableGrillMeats()
	local eligibleMeatId = nil

	for _, meatId in ipairs(availableMeats) do
		local meat = self.game:GetMeat(meatId)

		if meat and not meat.meatData.isBurnt then
			local side0Level = meat.meatData.sides[0].cookedLevel
			local side1Level = meat.meatData.sides[1].cookedLevel

			if targetCookLevel > side0Level or targetCookLevel < side1Level then
				eligibleMeatId = meatId

				break
			end
		end
	end

	if not eligibleMeatId then
		return false
	end

	local targetBowl = selfBowl

	if math.random() < AIConfig.PickMistakeProb then
		local otherBowls = self.game:GetOtherPlayerBowls(self.playerId)

		if #otherBowls <= 0 then
			targetBowl = otherBowls[math.random(1, #otherBowls)]
		end
	end

	self.StartActionCoroutine(self, "DragMeat", eligibleMeatId, targetBowl)

	return true
end

BBQAIController.TryFlipMeat = function(self)
	if self.isPerformingAction then
		return false
	end

	if AIConfig.FlipProb >= math.random() then
		return false
	end

	local player = self.game:GetPlayer(self.playerId)

	if not player or player.hasEnterDrag then
		return false
	end

	local availableMeats = self.game:GetAvailableGrillMeats(true, self)

	if #availableMeats ~= 0 then
		return false
	end

	local targetMeatId = availableMeats[math.random(1, #availableMeats)]

	self.StartActionCoroutine(self, "FlipMeat", targetMeatId)

	return true
end

BBQAIController.TryTakeMeatFromPlate = function(self)
	if self.isPerformingAction then
		return false
	end

	local player = self.game:GetPlayer(self.playerId)

	if not player or player.hasEnterDrag then
		return false
	end

	local plates = self.game:GetPlates()

	if #plates ~= 0 then
		return false
	end

	local targetPlate = plates[math.random(1, #plates)]
	local plateId = targetPlate.id
	local randomGrillPos = self.game:GetDropPositionOnGrill()

	if not randomGrillPos then
		return false
	end

	self.StartActionCoroutine(self, "TakeMeatFromPlate", plateId, randomGrillPos)

	return true
end

BBQAIController.StartActionCoroutine = function(self, actionName, ...)
	local action = self[actionName]
	local co = coroutine.start(function (...)
		self.isPerformingAction = true
		local ok, err = pcall(action, self, ...)

		if not ok then
			print_warn("[BBQAI] Action", actionName, "error:", err)
		end

		self.isPerformingAction = false
	end, ...)

	table.insert(self.actionCoroutines, co)
end

BBQAIController.DragMeat = function(self, meatId, targetBowl)
	local meat = self.game:GetMeat(meatId)

	if not meat then
		return
	end

	local meatPos = meat.GetPosition(meat)

	if not meatPos then
		return
	end

	local moveSuccess = self.MoveMouseTo(self, meatPos)

	if not moveSuccess then
		return
	end

	meat = self.game:GetMeat(meatId)

	if not meat then
		return
	end

	self.game:OnAIBeginDrag(self.playerId, meatId)

	local targetPos = self.game:GetBowlWorldPosition(targetBowl)

	if not targetPos then
		self.game:OnAIEndDrag(self.playerId, meatId)

		return
	end

	self:MoveMouseTo(targetPos)
	self.game:OnAIEndDrag(self.playerId, meatId)
end

BBQAIController.FlipMeat = function(self, meatId)
	local meatPos = self.game:GetMeatWorldPosition(meatId)

	if not meatPos then
		return
	end

	local moveSuccess = self.MoveMouseTo(self, meatPos)

	if not moveSuccess then
		return
	end

	local meat = self.game:GetMeat(meatId)

	if not meat or meat.state == BBQConstants.MeatState.OnGrill then
		return
	end

	self.game:OnAIMeatClick(self.playerId, meatId)

	self.flippedMeatCoolDown[meatId] = Time.time
end

BBQAIController.TakeMeatFromPlate = function(self, plateId, targetPos)
	local platePos = self.game:GetPlateWorldPosition(plateId)

	if not platePos then
		return
	end

	local moveSuccess = self.MoveMouseTo(self, platePos)

	if not moveSuccess then
		return
	end

	local newMeatId = self.game:OnAIPlateBeginDrag(self.playerId, plateId)

	if not newMeatId then
		return
	end

	self:MoveMouseTo(targetPos)
	self.game:OnAIEndDrag(self.playerId, newMeatId)
end

BBQAIController.MoveMouseTo = function(self, worldPos)
	local targetScreenPos = gCS.CameraDataMgr.Instance.MainCamera:WorldToScreenPoint(UnityEngine.Vector3.New(worldPos.x, worldPos.y, worldPos.z))
	local moveSpeed = (AIConfig.MouseMoveSpeedMin + math.random() * (AIConfig.MouseMoveSpeedMax - AIConfig.MouseMoveSpeedMin)) * 100
	local player = self.game:GetPlayer(self.playerId)

	if not player then
		return false
	end

	local currentPos = self.currentMousePos
	local dist = Vector2.Distance(UnityEngine.Vector2.New(currentPos.x, currentPos.y), targetScreenPos)

	while dist <= 0.1 do
		if self.game.hasDestroy then
			return false
		end

		local moved = Vector2.MoveTowards(UnityEngine.Vector2.New(currentPos.x, currentPos.y), targetScreenPos, moveSpeed * UnityEngine.Time.deltaTime)
		currentPos.x = moved.x
		currentPos.y = moved.y
		player.inputPosition = {
			x = currentPos.x,
			y = currentPos.y
		}

		self.game:SetPlayerInputPosition(self.playerId, currentPos.x, currentPos.y)
		coroutine.wait(0)

		dist = Vector2.Distance(UnityEngine.Vector2.New(currentPos.x, currentPos.y), targetScreenPos)
	end

	currentPos.x = targetScreenPos.x
	currentPos.y = targetScreenPos.y
	player.inputPosition = {
		x = currentPos.x,
		y = currentPos.y
	}

	self.game:SetPlayerInputPosition(self.playerId, currentPos.x, currentPos.y)

	return true
end

BBQAIController.IsFlipCoolingDown = function(self, meatId)
	local lastTime = self.flippedMeatCoolDown[meatId]

	if not lastTime then
		return false
	end

	return Time.time - lastTime <= self.flipCoolDownTime
end

BBQAIController.CancelAllCoroutines = function(self)
	if self.thinkCoroutine then
		coroutine.stop(self.thinkCoroutine)

		self.thinkCoroutine = nil
	end

	for _, co in ipairs(self.actionCoroutines) do
		coroutine.stop(co)
	end

	self.actionCoroutines = {}
end

BBQAIController.OnExit = function(self)
	self.CancelAllCoroutines(self)

	self.isPerformingAction = false
end
