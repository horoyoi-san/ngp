-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerTetrisMainPanelStore.lua
-- Decompiled from: 01727_HackerTetrisMainPanelStore.lua_e7e087371b7e.luajit

local MessageConfig = LTConfig.MessageConfig
C_HackerTetrisMainPanelStore = DefClass("C_HackerTetrisMainPanelStore", C_HackerTetrisMainPanelStore, C_StoreGroup)
GroupName2Class.HackerTetrisMainPanelStore = C_HackerTetrisMainPanelStore
local M = C_HackerTetrisMainPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.gridWidth = 10
	self.gridHeight = 20
	self.gridTotal = self.gridWidth * self.gridHeight
	self.board = {}

	for i = 1, self.gridTotal do
		self.board[i] = 0
	end

	self.currentPiece = nil
	self.currentPieceX = 0
	self.currentPieceY = 0
	self.currentPieceRotation = 0
	self.nextPiece = nil
	self.isGameRunning = false
	self.hasGameStarted = false
	self.currentStatus = nil
	self.startAnimationVersion = 0
	self.fallTime = 0
	self.fallInterval = 1
	self.defaultGravity = LTConfig.HackerConfig.HackerTetris_DefaultGravity or 1
	self.gravityCoefficient = LTConfig.HackerConfig.HackerTetris_GravityCoefficient or 0.1
	self.endUnixTime = nil
	self.score = 0
	self.totalLinesCleared = 0
	self.popupScoreDuration = 1
	self.popupScoreCo = nil
	self.pieceColor = Color.New(0.03, 0.94, 0.44, 1)
	self.pieceTypes = {
		{
			{
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					3,
					1
				}
			},
			{
				{
					2,
					0
				},
				{
					2,
					1
				},
				{
					2,
					2
				},
				{
					2,
					3
				}
			},
			{
				{
					0,
					2
				},
				{
					1,
					2
				},
				{
					2,
					2
				},
				{
					3,
					2
				}
			},
			{
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					1,
					2
				},
				{
					1,
					3
				}
			}
		},
		{
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				}
			},
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				}
			},
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				}
			},
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				}
			}
		},
		{
			{
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				}
			},
			{
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					1,
					2
				}
			},
			{
				{
					1,
					2
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				}
			},
			{
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					1,
					2
				}
			}
		},
		{
			{
				{
					1,
					0
				},
				{
					2,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				}
			},
			{
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					2,
					2
				}
			},
			{
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					0,
					2
				},
				{
					1,
					2
				}
			},
			{
				{
					0,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					1,
					2
				}
			}
		},
		{
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					2,
					1
				}
			},
			{
				{
					2,
					0
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					1,
					2
				}
			},
			{
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					1,
					2
				},
				{
					2,
					2
				}
			},
			{
				{
					1,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					0,
					2
				}
			}
		},
		{
			{
				{
					0,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				}
			},
			{
				{
					1,
					0
				},
				{
					2,
					0
				},
				{
					1,
					1
				},
				{
					1,
					2
				}
			},
			{
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					2,
					2
				}
			},
			{
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					0,
					2
				},
				{
					1,
					2
				}
			}
		},
		{
			{
				{
					2,
					0
				},
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				}
			},
			{
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					1,
					2
				},
				{
					2,
					2
				}
			},
			{
				{
					0,
					1
				},
				{
					1,
					1
				},
				{
					2,
					1
				},
				{
					0,
					2
				}
			},
			{
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					1,
					2
				}
			}
		}
	}
	self.srsOffsetsJLSTZ = {
		[0] = {
			{
				{
					0,
					0
				},
				{
					-1,
					0
				},
				{
					-1,
					1
				},
				{
					0,
					-2
				},
				{
					-1,
					-2
				}
			}
		},
		{
			[2] = {
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					1,
					-1
				},
				{
					0,
					2
				},
				{
					1,
					2
				}
			}
		},
		{
			[3] = {
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					1,
					1
				},
				{
					0,
					-2
				},
				{
					1,
					-2
				}
			}
		},
		{
			[0] = {
				{
					0,
					0
				},
				{
					-1,
					0
				},
				{
					-1,
					-1
				},
				{
					0,
					2
				},
				{
					-1,
					2
				}
			}
		}
	}
	self.srsOffsetsI = {
		[0] = {
			{
				{
					0,
					0
				},
				{
					-2,
					0
				},
				{
					1,
					0
				},
				{
					-2,
					-1
				},
				{
					1,
					2
				}
			}
		},
		{
			[2] = {
				{
					0,
					0
				},
				{
					-1,
					0
				},
				{
					2,
					0
				},
				{
					-1,
					2
				},
				{
					2,
					-1
				}
			}
		},
		{
			[3] = {
				{
					0,
					0
				},
				{
					2,
					0
				},
				{
					-1,
					0
				},
				{
					2,
					1
				},
				{
					-1,
					-2
				}
			}
		},
		{
			[0] = {
				{
					0,
					0
				},
				{
					1,
					0
				},
				{
					-2,
					0
				},
				{
					1,
					-2
				},
				{
					-2,
					1
				}
			}
		}
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.nextBlockTypeCtrlEnum = {
		["\\xfe"] = 4,
		["\\xe1"] = 2,
		["\\xf7"] = 5,
		["\\xf9"] = 6,
		["\\xdd\\xd2(\\xf4"] = 7,
		["\\xe7"] = 1,
		["\\xe2"] = 3,
		["\\xe4"] = 0
	}
	self.nextBlockAngleCtrlEnum = {
		["^-jU"] = 2,
		["5"] = 0,
		["\\xa7\\xa5\\xa7\\xa2"] = 1,
		["V'{O"] = 3
	}
	self.scoresPopUpCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.statusCtrlEnum = {
		["^\\xba\\xa3\\xbd\\xa2"] = 3,
		["I\\x98\\x82\\x86E"] = 4,
		["]\\xaf\\xb7\\xbc\\xb3"] = 1,
		["A\\x9f\\x87\\x90I"] = 2,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.nextBlockTypeCtrlEnum = nil
	self.nextBlockAngleCtrlEnum = nil
	self.scoresPopUpCtrlEnum = nil
	self.statusCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.currentStatus = nil
	self.popupScoreCo = coroutine.stop(self.popupScoreCo)
end

M.OnUpdate = function(self)
	if self.isGameRunning then
		self.fallTime = self.fallTime + Time.deltaTime

		if self.fallInterval < self.fallTime then
			self.fallTime = 0

			self.FallPiece(self)
		end
	end

	local timeUp = nil

	if self.endUnixTime then
		local now = gCS.TimeManager.ServerUnixTime or os.time()
		timeUp = self.endUnixTime > now
	end

	if timeUp then
		self.OnGameTimeUp(self)
	elseif self.isGameRunning then
		self.UpdateCamera(self)
	end
end

M.UpdateCamera = function(self)
	local lookAtPos = self.lookAtPivot and self.lookAtPivot.position or Vector3.New(2001.479, 70, 2287.694)
	local playerPosition = gClientUtils.GetPlayerPosition()
	playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
	local dir = lookAtPos - playerPosition

	gCS.LuaUtils.SetFreeLookCameraDirection(dir, 0, 999)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.currentStatus = nil
	self.bindData.startAnim.animCallBack = nil

	self.ClearMessageEvents(self)
	self.StopGame(self)
end

M.OnShow = function(self, _, args)
	if type(args) ~= "userdata" then
		args = args.ToTable(args)
		self.closeCallback = args[1]
		self.lookAtPivot = args[2]
		self.endUnixTime = args[3]
	end

	self.InitView(self, args)
end

M.InitView = function(self, args)
	self.bindData.score = 0
	self.bindData.line = 0
	self.bindData.popupScore = ""
	self.hasGameStarted = false

	self.StopGame(self)
	self.PlayStartAnimation(self)
end

M.OnClose = function(self)
	self.currentStatus = nil
	self.bindData.startAnim.animCallBack = nil

	if self.closeCallback then
		self.closeCallback:DynamicInvoke()
	end

	self.StopGame(self)
	self.SwitchToNormalFreeLook(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.HACKER_TETRIS_ROTATE] = self.CreateAction(self, "OnTetrisRotate"),
		[gEventConstants.HACKER_TETRIS_HARD_DROP] = self.CreateAction(self, "OnTetrisHardDrop"),
		[gEventConstants.HACKER_TETRIS_MOVE_LEFT] = self.CreateAction(self, "OnTetrisMoveLeft"),
		[gEventConstants.HACKER_TETRIS_MOVE_RIGHT] = self.CreateAction(self, "OnTetrisMoveRight"),
		[gEventConstants.HACKER_TETRIS_MOVE_DOWN] = self.CreateAction(self, "OnTetrisMoveDown"),
		[gEventConstants.HACKER_TETRIS_PAUSE] = self.CreateAction(self, "OnTetrisPause"),
		[gEventConstants.HACKER_TETRIS_RESUME] = self.CreateAction(self, "OnTetrisResume")
	}
end

M.RegisterWidget = function(self)
	self.bindData.gridList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGridListItem")
	self.bindData.gridList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickGridList")
end

M.OnSimpleRenderGridListItem = function(self, btn, index)
	local row = math.floor(index / self.gridWidth)
	local col = index % self.gridWidth
	local displayRow = self.gridHeight - 1 - row
	local cellValue = self.GetCellValue(self, col, displayRow)
	local color = Color.New(0.2, 0.2, 0.2, 1)
	local isCurrentPieceCell = false

	if self.currentPiece then
		local pieceCells = self.pieceTypes[self.currentPiece][self.currentPieceRotation + 1]

		for _, cell in ipairs(pieceCells) do
			local px = self.currentPieceX + cell[1]
			local py = self.currentPieceY - cell[2]

			if px ~= col and py ~= displayRow then
				isCurrentPieceCell = true

				break
			end
		end
	end

	if isCurrentPieceCell or cellValue and cellValue <= 0 then
		color = self.pieceColor
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.color = color
	end
end

M.OnSimpleClickGridList = function(self, btn, index)
end

M.AddScore = function(self, addScore, linesCount, totalLinesCleared)
	self.score = self.score + addScore

	if totalLinesCleared then
		self.totalLinesCleared = totalLinesCleared
	end

	self.bindData.score = tostring(self.score)
	self.bindData.line = tostring(self.totalLinesCleared)

	if addScore and addScore <= 0 then
		self.bindData.popupScore = string.format("+%d", addScore)
		self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.active
		self.popupScoreCo = coroutine.stop(self.popupScoreCo)
		self.popupScoreCo = coroutine.start(function ()
			coroutine.wait(self.popupScoreDuration)

			self.bindData.scoresPopUpCtrl = self.scoresPopUpCtrlEnum.normal
			self.bindData.popupScore = ""
		end)
	end
end

M.SetNextBlock = function(self, pieceType, rotation)
	local typeEnum = self.nextBlockTypeCtrlEnum.disable

	if pieceType ~= 1 then
		typeEnum = self.nextBlockTypeCtrlEnum.I
	elseif pieceType ~= 2 then
		typeEnum = self.nextBlockTypeCtrlEnum.O
	elseif pieceType ~= 3 then
		typeEnum = self.nextBlockTypeCtrlEnum.T
	elseif pieceType ~= 4 then
		typeEnum = self.nextBlockTypeCtrlEnum.S
	elseif pieceType ~= 5 then
		typeEnum = self.nextBlockTypeCtrlEnum.Z
	elseif pieceType ~= 6 then
		typeEnum = self.nextBlockTypeCtrlEnum.J
	elseif pieceType ~= 7 then
		typeEnum = self.nextBlockTypeCtrlEnum.L
	end

	self.bindData.nextBlockTypeCtrl = typeEnum
	local angleEnum = self.nextBlockAngleCtrlEnum.Up

	if rotation ~= 1 then
		angleEnum = self.nextBlockAngleCtrlEnum.Right
	elseif rotation ~= 2 then
		angleEnum = self.nextBlockAngleCtrlEnum.Down
	elseif rotation ~= 3 then
		angleEnum = self.nextBlockAngleCtrlEnum.Left
	end

	self.bindData.nextBlockAngleCtrl = angleEnum
end

M.SetStatus = function(self, status, force)
	self.currentStatus = status

	if force then
		self.bindData:Commit("statusCtrl", status, COMMIT_FORCE)
	else
		self.bindData.statusCtrl = status
	end
end

M.PlayStartAnimation = function(self)
	self.startAnimationVersion = self.startAnimationVersion + 1
	self.bindData.startAnim.animCallBack = self.CreateActionWithArgs(self, "OnStartAnimationEnd", self.startAnimationVersion)

	self.SetStatus(self, self.statusCtrlEnum.start, true)
end

M.OnStartAnimationEnd = function(self, version)
	if version == self.startAnimationVersion or self.currentStatus == self.statusCtrlEnum.start then
		return
	end

	local now = gCS.TimeManager.ServerUnixTime or os.time()

	if self.endUnixTime and self.endUnixTime < now then
		self.OnGameTimeUp(self)

		return
	end

	self.SetStatus(self, self.statusCtrlEnum.normal)
	self.StartGame(self)
end

M.StartGame = function(self)
	if self.isGameRunning then
		return
	end

	self.hasGameStarted = true
	self.isGameRunning = true
	self.fallTime = 0

	for i = 1, self.gridTotal do
		self.board[i] = 0
	end

	self.currentPiece = nil
	self.currentPieceX = 0
	self.currentPieceY = 0
	self.currentPieceRotation = 0
	self.nextPiece = nil
	self.score = 0
	self.totalLinesCleared = 0

	self:AddScore(0, 0, 0)

	self.bindData.gridList.rowCount = self.gridHeight
	self.bindData.gridList.colCount = self.gridWidth

	self.bindData.gridList:SetSimpleList(self.gridTotal)
	self:SpawnNewPiece()

	local countSeconds = nil

	if self.endUnixTime then
		local now = gCS.TimeManager.ServerUnixTime or os.time()
		countSeconds = math.max(0, self.endUnixTime - now)
	end

	if countSeconds and countSeconds <= 0 then
		self.bindData.countDown.enabledMilli = true
		self.bindData.countDown.formatText = "{2:D2}:{3:D2}.{4:D3}"

		self.bindData.countDown:Play(countSeconds)
	end

	self.UpdateFallInterval(self)
	self.EnterTetrisGameCamera(self)
end

M.StopGame = function(self)
	self.isGameRunning = false
	self.fallTime = 0
end

M.SendHackerTetrisSignal = function(self, signalKey)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey
	})
end

M.OnGameTimeUp = function(self)
	self.endUnixTime = nil

	self:StopGame()
	self:SetStatus(self.statusCtrlEnum.failed)
	self:SwitchToNormalFreeLook()

	slot1 = gPanelManager

	slot1:Close(gPanelId.HACKER_TETRIS_HUD_PANEL)
	self:SendHackerTetrisSignal("HackerTimesUp")

	slot1 = gClientToGameDelegate

	slot1:AskFinishHackerTetris().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnGameFail = function(self)
	self.endUnixTime = nil

	self:StopGame()
	self:SetStatus(self.statusCtrlEnum.failed)
	self:SwitchToNormalFreeLook()
	gPanelManager:Close(gPanelId.HACKER_TETRIS_HUD_PANEL)
	self:SendHackerTetrisSignal("HackerTetrisFail")
end

M.OnTetrisRotate = function(self)
	if self.isGameRunning then
		self.RotatePiece(self)
	end
end

M.OnTetrisHardDrop = function(self)
	if not self.isGameRunning then
		return
	end

	while self.MovePiece(self, 0, -1) do
	end

	self.LockPiece(self)
	self.ClearFullLines(self)
	self.SpawnNewPiece(self)
end

M.OnTetrisMoveLeft = function(self)
	if self.isGameRunning then
		self.MovePiece(self, -1, 0)
	end
end

M.OnTetrisMoveRight = function(self)
	if self.isGameRunning then
		self.MovePiece(self, 1, 0)
	end
end

M.OnTetrisMoveDown = function(self)
	if self.isGameRunning then
		self.MovePiece(self, 0, -1)
	end
end

M.OnTetrisPause = function(self)
	if self.currentStatus == self.statusCtrlEnum.normal and self.currentStatus == self.statusCtrlEnum.start then
		return
	end

	self.StopGame(self)
	self.SetStatus(self, self.statusCtrlEnum.pause)
	self.SwitchToNormalFreeLook(self)
	self.SendHackerTetrisSignal(self, "HackerTetrisExit")
end

M.OnTetrisResume = function(self)
	if self.currentStatus == self.statusCtrlEnum.pause then
		return
	end

	local now = gCS.TimeManager.ServerUnixTime or os.time()
	local countSeconds = math.max(0, (self.endUnixTime or 0) - now)

	if countSeconds <= 0 then
		if not self.hasGameStarted then
			self.PlayStartAnimation(self)

			return
		end

		self.isGameRunning = true
		self.fallTime = 0

		self:SetStatus(self.statusCtrlEnum.normal)
		self:EnterTetrisGameCamera()
		self.bindData.countDown:Play(countSeconds)
	else
		self.OnGameTimeUp(self)
	end
end

M.EnterTetrisGameCamera = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(LTConfig.HackerConfig.HackerTetris_ActionStatus, 0, nil)
end

M.SwitchToNormalFreeLook = function(self)
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0, nil)
end

M.SpawnNewPiece = function(self)
	local pieceType = self.nextPiece or math.random(1, 7)
	self.currentPiece = pieceType
	self.currentPieceX = math.floor(self.gridWidth / 2) - 1
	self.currentPieceY = self.gridHeight - 1
	self.currentPieceRotation = self.nextPieceRotation or math.random(0, 3)

	if not self:IsValidPosition(self.currentPieceX, self.currentPieceY, self.currentPieceRotation) then
		self.OnGameFail(self)

		return
	end

	self.nextPiece = math.random(1, 7)
	self.nextPieceRotation = math.random(0, 3)

	self.SetNextBlock(self, self.nextPiece, self.nextPieceRotation)
	self.RefreshGrid(self)
end

M.GetCellValue = function(self, x, y)
	if x <= 0 or self.gridWidth > x or y <= 0 or self.gridHeight < y then
		return -1
	end

	local index = y * self.gridWidth + x + 1

	if index <= 1 or self.gridTotal >= index then
		return 0
	end

	return self.board[index] or 0
end

M.SetCellValue = function(self, x, y, value)
	if x <= 0 or self.gridWidth > x or y <= 0 or self.gridHeight < y then
		return
	end

	local index = y * self.gridWidth + x + 1
	self.board[index] = value
end

M.IsValidPosition = function(self, x, y, rotation)
	local pieceCells = self.pieceTypes[self.currentPiece][rotation + 1]

	for _, cell in ipairs(pieceCells) do
		local px = x + cell[1]
		local py = y - cell[2]

		if px <= 0 or self.gridWidth > px or py >= 0 then
			return false
		end

		if py >= self.gridHeight then
			local cellValue = self.GetCellValue(self, px, py)

			if cellValue <= 0 then
				return false
			end
		end
	end

	return true
end

M.MovePiece = function(self, dx, dy)
	local newX = self.currentPieceX + dx
	local newY = self.currentPieceY + dy

	if self.IsValidPosition(self, newX, newY, self.currentPieceRotation) then
		self.currentPieceX = newX
		self.currentPieceY = newY

		self.RefreshGrid(self)

		return true
	end

	return false
end

M.RotatePiece = function(self)
	local currentRotation = self.currentPieceRotation
	local newRotation = (currentRotation + 1) % 4

	if self.currentPiece ~= 2 then
		if self.IsValidPosition(self, self.currentPieceX, self.currentPieceY, newRotation) then
			self.currentPieceRotation = newRotation

			self.RefreshGrid(self)

			return true
		end

		return false
	end

	local offsets = nil

	if self.currentPiece ~= 1 then
		if self.srsOffsetsI[currentRotation] then
			offsets = self.srsOffsetsI[currentRotation][newRotation]
		end
	elseif self.srsOffsetsJLSTZ[currentRotation] then
		offsets = self.srsOffsetsJLSTZ[currentRotation][newRotation]
	end

	if not offsets then
		if self.IsValidPosition(self, self.currentPieceX, self.currentPieceY, newRotation) then
			self.currentPieceRotation = newRotation

			self.RefreshGrid(self)

			return true
		end

		return false
	end

	for i = 1, #offsets do
		local offset = offsets[i]
		local testX = self.currentPieceX + offset[1]
		local testY = self.currentPieceY - offset[2]

		if self.IsValidPosition(self, testX, testY, newRotation) then
			self.currentPieceX = testX
			self.currentPieceY = testY
			self.currentPieceRotation = newRotation

			self.RefreshGrid(self)

			return true
		end
	end

	return false
end

M.FallPiece = function(self)
	if not self.MovePiece(self, 0, -1) then
		self.LockPiece(self)
		self.ClearFullLines(self)
		self.SpawnNewPiece(self)
	end
end

M.LockPiece = function(self)
	local pieceCells = self.pieceTypes[self.currentPiece][self.currentPieceRotation + 1]

	for _, cell in ipairs(pieceCells) do
		local px = self.currentPieceX + cell[1]
		local py = self.currentPieceY - cell[2]

		if px > 0 and px >= self.gridWidth and py > 0 and py >= self.gridHeight then
			self.SetCellValue(self, px, py, self.currentPiece)
		end
	end

	self.currentPiece = nil
end

M.ClearFullLines = function(self)
	local linesToClear = {}

	for y = 0, self.gridHeight - 1 do
		local isFull = true

		for x = 0, self.gridWidth - 1 do
			if self.GetCellValue(self, x, y) ~= 0 then
				isFull = false

				break
			end
		end

		if isFull then
			table.insert(linesToClear, y)
		end
	end

	local linesCount = #linesToClear

	if linesCount <= 0 then
		local baseScore = 0

		if linesCount ~= 1 then
			baseScore = LTConfig.HackerConfig.HackerTetris_ClearPoints1
		elseif linesCount ~= 2 then
			baseScore = LTConfig.HackerConfig.HackerTetris_ClearPoints2
		elseif linesCount ~= 3 then
			baseScore = LTConfig.HackerConfig.HackerTetris_ClearPoints3
		elseif linesCount ~= 4 then
			baseScore = LTConfig.HackerConfig.HackerTetris_ClearPoints4
		end

		self.AddScore(self, baseScore, linesCount, self.totalLinesCleared + linesCount)
	end

	for i = #linesToClear, 1, -1 do
		local y = linesToClear[i]

		for x = 0, self.gridWidth - 1 do
			self.SetCellValue(self, x, y, 0)
		end

		for yy = y + 1, self.gridHeight - 1 do
			for x = 0, self.gridWidth - 1 do
				local value = self.GetCellValue(self, x, yy)

				self.SetCellValue(self, x, yy - 1, value)
			end
		end

		for x = 0, self.gridWidth - 1 do
			self.SetCellValue(self, x, self.gridHeight - 1, 0)
		end
	end

	if #linesToClear <= 0 then
		self.RefreshGrid(self)
		self.UpdateFallInterval(self)
	end
end

M.RefreshGrid = function(self)
	self.bindData.gridList:RefreshList()
end

M.UpdateFallInterval = function(self)
	local speed = self.defaultGravity + self.gravityCoefficient * self.totalLinesCleared
	self.fallInterval = 1 / speed
end
