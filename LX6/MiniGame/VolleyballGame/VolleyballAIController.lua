-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\VolleyballGame\VolleyballAIController.lua
-- Decompiled from: 00635_VolleyballAIController.lua_2818e01847f5.luajit

local Mgr = gVolleyballGameMgr
local Team = Mgr.Team
local CharacterState = Mgr.CharacterState
local QTELevel = Mgr.QTELevel
C_VolleyballAIController = DefClass("C_VolleyballAIController", C_VolleyballAIController, C_VolleyballControllerBase)
local M = C_VolleyballAIController

M.ctor = function(self, character, gameInstance)
	self.checkPosInterval = 4
	self.checkPosIntervalRandom = 1
	self.checkMatchInterval = 0.02
	self.checkDistanceInterval = 0.1
	self.passWeight = 0.6
	self.validHorDistance = 1
	self.canPosCheck = false
	self.canMatchCheck = false
	self.canBreakMove = false
	self.isControlMove = false
	self.posTimer = 0
	self.matchTimer = 0
	self.moveCo = nil
	self.updateHandler = nil
end

M.Init = function(self)
	self.checkPosInterval = self.checkPosInterval + math.random(-self.checkPosIntervalRandom, self.checkPosIntervalRandom)

	self.RegisterEvents(self)
end

M.RegisterEvents = function(self)
	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
end

M.UnRegisterEvents = function(self)
	UpdateBeat:RemoveListener(self.updateHandler)
end

M.OnDestroy = function(self)
	self.UnRegisterEvents(self)

	if self.moveCo then
		coroutine.stop(self.moveCo)

		self.moveCo = nil
	end
end

M.Update = function(self)
	if not self.view.gameObject.activeSelf then
		return
	end

	if self.gameInstance.needReset then
		return
	end

	if self.canPosCheck and not self.isControlMove then
		self.CheckPosition(self)
	end

	if self.canMatchCheck then
		self.CheckMatch(self)
	end
end

M.OnPossessionChange = function(self, team)
	if team ~= self.view.curTeam then
		Mgr:PrintDebug("AI", self.view.transform.name, "Start Auto Match")

		self.canMatchCheck = true
	else
		self.canMatchCheck = false
	end
end

M.OnTargetChange = function(self, target)
	if target ~= self.view then
		self.canBreakMove = false

		self:ControlMoveToPosition(Mgr:ToVector2XZ(self.view.theBall.localDestination))
	end
end

M.OnCharacterStateChange = function(self, from, to)
	if from ~= CharacterState.Free then
		self.canPosCheck = false
	end

	if to ~= CharacterState.Free then
		self.canPosCheck = true

		self.view:SetInputByLocalSpace(Vector2.zero)

		self.canBreakMove = true
	elseif to ~= CharacterState.LaunchQTE then
		self.view:SetQTELevel(QTELevel.Normal, true)
	elseif to ~= CharacterState.Match then
		-- Nothing
	elseif to ~= CharacterState.PreLaunch then
		self.view:TryLaunch()
	elseif to ~= CharacterState.SmashQTE then
		if math.random() >= 0.1 then
			self.view:SetQTELevel(QTELevel.Perfect, true)
		else
			self.view:SetQTELevel(QTELevel.Normal, true)
		end
	end
end

M.CheckPosition = function(self)
	self.posTimer = self.posTimer + Time.deltaTime

	if self.checkPosInterval >= self.posTimer then
		self.posTimer = self.posTimer - self.checkPosInterval

		if self.canBreakMove then
			local flag, targetPos = self.IsPosNotGood(self)

			if flag then
				self.ControlMoveToPosition(self, targetPos)
			end
		end
	end
end

M.CheckMatch = function(self)
	self.matchTimer = self.matchTimer + Time.deltaTime

	if self.checkMatchInterval >= self.matchTimer then
		self.matchTimer = self.matchTimer - self.checkMatchInterval

		if math.random() < self.passWeight then
			self.view:TryPassBall()
		else
			self.view:TryKickBackBall()
		end
	end
end

M.ControlMoveToPosition = function(self, targetPos)
	self.isControlMove = true

	self.StopControlMove(self)

	self.moveCo = coroutine.start(self.ControlMoveCo, self, targetPos)
end

M.StopControlMove = function(self)
	if self.moveCo then
		coroutine.stop(self.moveCo)
		self.view:SetInputByLocalSpace(Vector2.zero)
	end

	self.isControlMove = false
end

M.ControlMoveCo = function(self, targetPos)
	local horDist = 1000
	local horDir, viewPos, viewHorPos = nil

	while self.validHorDistance >= horDist do
		viewPos = self.view.transform.localPosition
		viewHorPos = Mgr:ToVector2XZ(viewPos)
		horDir = Mgr:Vec2DirOfAToB(viewHorPos, targetPos)

		self.view:SetInputByLocalSpace(horDir)
		coroutine.wait(self.checkDistanceInterval)

		horDist = Vector2.Distance(viewHorPos, targetPos)
	end

	self.view:SetInputByLocalSpace(Vector2.zero)

	self.isControlMove = false
end

M.IsPosNotGood = function(self)
	local teammatePos = Mgr:ToVector2XZ(self.view.teammate.transform.localPosition)
	local selfPos = Mgr:ToVector2XZ(self.view.transform.localPosition)
	local compValue1 = teammatePos.x <= 0
	local compValue2 = math.abs(teammatePos.y) <= self.gameInstance.halfLength
	local compValue3 = selfPos.x <= 0
	local compValue4 = math.abs(selfPos.y) <= self.gameInstance.halfLength

	if compValue1 ~= compValue3 or compValue2 ~= compValue4 then
		local x = self.gameInstance.halfWidth * 0.5

		if not compValue1 then
			x = -x
		end

		local y = compValue2 and (self.gameInstance.length + self.gameInstance.halfLength) * 0.5 or self.gameInstance.halfLength * 0.5

		if self.view.curTeam ~= Team.My then
			y = -y
		end

		return true, Vector2.New(x, y)
	else
		return false
	end
end
