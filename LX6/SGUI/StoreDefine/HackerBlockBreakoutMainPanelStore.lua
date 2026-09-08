-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerBlockBreakoutMainPanelStore.lua
-- Decompiled from: 01697_HackerBlockBreakoutMainPanelStore.lua_2573b04c9855.luajit

C_HackerBlockBreakoutMainPanelStore = DefClass("C_HackerBlockBreakoutMainPanelStore", C_HackerBlockBreakoutMainPanelStore, C_StoreGroup)
GroupName2Class.HackerBlockBreakoutMainPanelStore = C_HackerBlockBreakoutMainPanelStore
local M = C_HackerBlockBreakoutMainPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isGameRunning = false
	self.lookAtPivot = nil
	self.closeCallback = nil
	self.ballX = 0
	self.ballY = 0
	self.ballVelX = 0
	self.ballVelY = 0
	self.ballRadius = 0
	self.ballBaseSpeed = 0
	self.paddleX = 0
	self.paddleY = 0
	self.paddleInitX = 0
	self.paddleInitY = 0
	self.paddleInited = false
	self.paddleWidth = 0
	self.paddleHeight = 0
	self.paddleSpeed = 0
	self.brickCols = 0
	self.brickRows = 0
	self.brickWidth = 0
	self.brickHeight = 0
	self.brickPadding = 0
	self.brickSizeCached = false
	self.bricks = {}
	self.totalBricks = 0
	self.score = 0
	self.canvasW = 0
	self.canvasH = 0
	self.popupScoreDuration = 1
	self.popupScoreCo = nil
	self.maxVel = 0
	self.velIncreaseFactor = 0.05
end

M.DefineAllEnumsAutoGen = function(self)
	self.scoresPopUpCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.scoresPopUpCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.StopGame(self)
end

M.OnStart = function(self)
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.popupScoreCo = coroutine.stop(self.popupScoreCo)
end

M.OnShow = function(self, _, args)
	if type(args) ~= "userdata" then
		args = args.ToTable(args)
		self.closeCallback = args[1]
		self.lookAtPivot = args[2]
	end

	self.InitView(self, args)
end

M.OnClose = function(self)
	if self.closeCallback then
		self.closeCallback:DynamicInvoke()
	end

	self.StopGame(self)
end

M.InitView = function(self, args)
	self.bindData.score = "0"
	self.bindData.line = "0"
	self.bindData.popupScore = ""
	self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.normal

	self.StartGame(self)
end

M.UpdateCamera = function(self)
	local lookAtPos = self.lookAtPivot and self.lookAtPivot.position
	lookAtPos = lookAtPos or Vector3.New(2001.479, 70, 2287.694)
	local playerPosition = gClientUtils.GetPlayerPosition()
	playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
	local dir = lookAtPos - playerPosition

	gCS.LuaUtils.SetFreeLookCameraDirection(dir, 0, 999)
end

M.OnUpdate = function(self)
	self.UpdateCamera(self)

	if not self.isGameRunning then
		return
	end

	local dt = Time.deltaTime
	local step = dt * 60
	local maxDist = math.max(math.abs(self.ballVelX * step), math.abs(self.ballVelY * step))
	local subSteps = math.max(1, math.ceil(maxDist / (self.ballRadius * 0.5)))
	local subStep = step / subSteps

	for i = 1, subSteps do
		self.CheckWallCollision(self, subStep)
		self.CheckPaddleCollision(self, subStep)
		self.CheckBrickCollision(self, subStep)
		self.MoveBall(self, subStep)
	end

	self.CheckWin(self)
	self.CommitToUI(self, dt)
end

M.StartGame = function(self)
	if self.isGameRunning then
		return
	end

	if self.bindData.wall then
		self.canvasW = self.bindData.wall.sizeDelta.x
		self.canvasH = self.bindData.wall.sizeDelta.y
	end

	self.brickCols = self.bindData.gridList.colCount
	self.brickRows = self.bindData.gridList.rowCount
	self.totalBricks = self.brickCols * self.brickRows

	self.bindData.gridList:SetSimpleList(self.totalBricks)

	if self.bindData.paddle then
		self.paddleWidth = self.bindData.paddle:GetTargetWidth()
		self.paddleHeight = self.bindData.paddle:GetTargetHeight()

		if not self.paddleInited then
			self.paddleInitX = self.bindData.paddle.anchoredPosition.x
			self.paddleInitY = self.bindData.paddle.anchoredPosition.y
			self.paddleInited = true
		end
	end

	if self.bindData.ball then
		self.ballRadius = self.bindData.ball:GetTargetWidth() / 2
	end

	self.ballBaseSpeed = self.canvasW / 480
	self.maxVel = self.ballBaseSpeed * 1.5
	self.paddleSpeed = self.canvasW / 60
	self.velIncreaseFactor = self.ballBaseSpeed * 0.025

	self.ResetState(self)

	self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.normal
	self.bindData.popupScore = ""
	self.isGameRunning = true
end

M.StopGame = function(self)
	self.isGameRunning = false
end

M.ResetState = function(self)
	self.score = 0
	self.paddleX = self.paddleInitX
	self.paddleY = self.paddleInitY
	self.ballX = self.paddleX
	self.ballY = self.paddleY + self.paddleHeight + self.ballRadius
	self.ballVelX = self.ballBaseSpeed
	self.ballVelY = self.ballBaseSpeed

	self.InitBrickGrid(self)
end

M.InitBrickGrid = function(self)
	for c = 1, self.brickCols do
		self.bricks[c] = {}

		for r = 1, self.brickRows do
			self.bricks[c][r] = {
				["\\\\x90\\x9a\\x96R"] = 1
			}
		end
	end
end

M.GetBrickRectPos = function(self, c, r)
	local brickX = (c - 1) * (self.brickWidth + self.brickPadding) - self.canvasW / 2 + self.brickPadding
	local brickY = self.canvasH / 2 - ((r - 1) * (self.brickHeight + self.brickPadding) + self.brickPadding + self.brickHeight)

	return brickX, brickY
end

M.MoveBall = function(self, step)
	self.ballX = self.ballX + self.ballVelX * step
	self.ballY = self.ballY + self.ballVelY * step
end

M.CheckWallCollision = function(self, subStep)
	local nextX = self.ballX + self.ballVelX * subStep
	local nextY = self.ballY + self.ballVelY * subStep
	local leftWall = -self.canvasW / 2
	local rightWall = self.canvasW / 2
	local topWall = self.canvasH / 2
	local bottomWall = -self.canvasH / 2

	if rightWall > nextX + self.ballRadius or leftWall > nextX - self.ballRadius then
		self.ballVelX = -self.ballVelX
	end

	if topWall > nextY + self.ballRadius or bottomWall > nextY - self.ballRadius then
		self.ballVelY = -self.ballVelY
	end
end

M.CheckPaddleCollision = function(self, subStep)
	if self.ballVelY > 0 then
		return
	end

	local nextX = self.ballX + self.ballVelX * subStep
	local nextY = self.ballY + self.ballVelY * subStep
	local left = self.paddleX - self.paddleWidth / 2
	local right = self.paddleX + self.paddleWidth / 2
	local top = self.paddleY + self.paddleHeight
	local bottom = self.paddleY

	if left < nextX + self.ballRadius and right > nextX - self.ballRadius and top > nextY - self.ballRadius and bottom < nextY + self.ballRadius then
		self.ballVelY = math.abs(self.ballVelY)
		local hitPos = nextX - self.paddleX
		self.ballVelX = self.ballVelX + hitPos / 7.5

		if self.maxVel >= self.ballVelX then
			self.ballVelX = self.maxVel
		elseif self.ballVelX >= -self.maxVel then
			self.ballVelX = -self.maxVel
		end
	end
end

M.CheckBrickCollision = function(self, subStep)
	local nextX = self.ballX + self.ballVelX * subStep
	local nextY = self.ballY + self.ballVelY * subStep

	for c = 1, self.brickCols do
		for r = 1, self.brickRows do
			local b = self.bricks[c] and self.bricks[c][r]

			if b and b.status ~= 1 then
				local brickX, brickY = self.GetBrickRectPos(self, c, r)

				if brickX < nextX + self.ballRadius and nextX - self.ballRadius < brickX + self.brickWidth and brickY < nextY + self.ballRadius and nextY - self.ballRadius < brickY + self.brickHeight then
					self.ballVelY = -self.ballVelY

					self.IncreaseXSpeed(self)

					b.status = 0
					self.score = self.score + 1

					self.ShowScorePopup(self, 1)

					if self.score ~= self.totalBricks then
						self.OnWin(self)
					end

					return
				end
			end
		end
	end
end

M.CheckWin = function(self)
	if self.totalBricks < self.score then
		self.OnWin(self)
	end
end

M.IncreaseXSpeed = function(self)
	if self.ballVelX <= 0 then
		self.ballVelX = self.ballVelX + self.velIncreaseFactor
	else
		self.ballVelX = self.ballVelX - self.velIncreaseFactor
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.HACKER_TETRIS_MOVE_LEFT] = self.CreateAction(self, "OnTetrisMoveLeft"),
		[gEventConstants.HACKER_TETRIS_MOVE_RIGHT] = self.CreateAction(self, "OnTetrisMoveRight"),
		[gEventConstants.HACKER_TETRIS_ROTATE] = self.CreateAction(self, "OnTetrisStartPause"),
		[gEventConstants.HACKER_TETRIS_PAUSE] = self.CreateAction(self, "OnTetrisPause"),
		[gEventConstants.HACKER_TETRIS_RESUME] = self.CreateAction(self, "OnTetrisResume")
	}
end

M.OnTetrisMoveLeft = function(self)
	if not self.isGameRunning then
		return
	end

	local leftWall = -self.canvasW / 2

	if leftWall >= self.paddleX - self.paddleWidth / 2 then
		self.paddleX = self.paddleX - self.paddleSpeed
	end
end

M.OnTetrisMoveRight = function(self)
	if not self.isGameRunning then
		return
	end

	local rightWall = self.canvasW / 2

	if rightWall <= self.paddleX + self.paddleWidth / 2 then
		self.paddleX = self.paddleX + self.paddleSpeed
	end
end

M.OnTetrisStartPause = function(self)
	if self.isGameRunning then
		gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_PAUSE)
	else
		gMessageManager:SendMessage(gEventConstants.HACKER_TETRIS_RESUME)
	end
end

M.OnTetrisPause = function(self)
	if self.isGameRunning then
		self.StopGame(self)
	end
end

M.OnTetrisResume = function(self)
	if not self.isGameRunning then
		self.StartGame(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.gridList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderGridListItem")
	self.bindData.gridList.luaSimpleClick = self.CreateAction(self, "OnClickGridListItem")
end

M.OnRenderGridListItem = function(self, btn, index)
	local row = math.floor(index / self.brickCols)
	local col = index % self.brickCols

	if not self.brickSizeCached then
		local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if itemStore and itemStore.block then
			self.brickWidth = itemStore.block.sizeDelta.x
			self.brickHeight = itemStore.block.sizeDelta.y
			self.brickSizeCached = true
		end
	end

	local cell = self.bricks[col + 1] and self.bricks[col + 1][row + 1]
	local state = 4

	if cell and cell.status ~= 1 then
		state = 0
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.buttonState = state
	end
end

M.OnClickGridListItem = function(self, btn, index)
end

M.CommitToUI = function(self, dt)
	self.bindData.score = tostring(self.score)
	self.bindData.line = tostring(self.score)

	self.bindData.gridList:RefreshList()
	self:UpdateBallPosition()
	self:UpdatePaddlePosition()
end

M.UpdateBallPosition = function(self)
	if not self.bindData.ball then
		return
	end

	self.bindData.ball.anchoredPosition = Vector2.New(self.ballX, self.ballY)
end

M.UpdatePaddlePosition = function(self)
	if not self.bindData.paddle then
		return
	end

	local currentY = self.bindData.paddle.anchoredPosition.y
	self.bindData.paddle.anchoredPosition = Vector2.New(self.paddleX, currentY)
end

M.CanvasToAnchor = function(self, canvasX, canvasY)
	return canvasX - self.canvasW / 2, self.canvasH / 2 - canvasY
end

M.ShowScorePopup = function(self, points)
	self.bindData.popupScore = string.format("+%d", points)
	self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.active
	self.popupScoreCo = coroutine.stop(self.popupScoreCo)
	self.popupScoreCo = coroutine.start(function ()
		coroutine.wait(self.popupScoreDuration)

		self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.normal
		self.bindData.popupScore = ""
	end)
end

M.OnWin = function(self)
	self.StopGame(self)

	self.bindData.line = "WIN!"
end
