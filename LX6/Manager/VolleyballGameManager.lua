-- Original chunk: @Lua\LuaFiles\LX6\Manager\VolleyballGameManager.lua
-- Decompiled from: 00628_VolleyballGameManager.lua_9ddf563157eb.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local StaticProps = {}
C_VolleyballGameManager = DefClass("C_VolleyballGameManager", C_VolleyballGameManager, nil, StaticProps)
local M = C_VolleyballGameManager

M.ctor = function(self)
	self.curGame = nil
	self.curLuaGame = nil
	self.hasDestroy = true
	self.rootNodePath = "Res/MiniGame/Prefab/VolleyballGame/VolleyballGameRootNode.prefab"
	self.rootNodeCopyPath = "Res/MiniGame/Prefab/VolleyballGame/VolleyballGameRootNodeCopy.prefab"
	self.CharacterState = {
		["\\x98\\xbc\\xb8b\\xca"] = 2,
		["`\\xaf\\xb6\\xac\\xbe"] = 5,
		["oFygM &"] = 4,
		["\\0x^"] = 3,
		["sUiEO0"] = 1,
		["T-s^"] = 0
	}
	self.Team = {
		["/"] = 2,
		["-"] = 1
	}
	self.MoveReason = {
		["\\x80\\xb8\\xa0H?\\xfd8"] = 5,
		["J#nH"] = 4,
		["`\\xaf\\xb6\\xac\\xbe"] = 6,
		["eFee}0"] = 1,
		["\\xea\\xeb'7\\xf9"] = 3,
		["~\\xa3\\xa3\\xbc\\xbe"] = 2,
		["T-s^"] = 0
	}
	self.QTELevel = {
		["h\\xaf\\xb0\\xa3\\xaf"] = 1,
		["V#i^"] = 4,
		["\\xe9\\xde'\\xe5"] = 3,
		["\\#v^"] = 5,
		["2G\\x83\\x83\\x82M"] = 2
	}
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		-- Nothing
	end
end

M.CreateGame = function(self, args)
	self.taskId = args.taskId

	if self.curGame == nil or self.hasDestroy ~= false then
		self:DestroyGame()
		Timer.New(function ()
			self:LoadGame(args)
		end, 1):Start()
	else
		self:LoadGame(args)
	end
end

M.CreateLuaGame = function(self, args)
	self.taskId = args.taskId

	if self.curLuaGame == nil or self.hasDestroy ~= false then
		self:DestroyLuaGame()
		Timer.New(function ()
			self:LoadLuaGame(args)
		end, 1):Start()
	else
		self:LoadLuaGame(args)
	end
end

M.CreateLuaGameCs = function(self, taskId, position, rotation)
	self:CreateLuaGame({
		taskId = taskId,
		rootPosition = position,
		rootRotation = rotation
	})
end

M.LoadGame = function(self, args)
	LX6.Game.MyPlayerManager.SwitchCameraBlock(false)

	self.hasDestroy = false
	self.rootNodeLoadOp = gResourceManager:LoadAssetWithCallBack(self.rootNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if not self.hasDestroy then
			local rootNodeGo = GameObject.Instantiate(loadOp.asset)
			self.curGame = rootNodeGo:GetComponent(typeof(L18.VolleyballGame.VolleyballGame))

			if args then
				rootNodeGo.transform.position = Vector3.New(unpack(args.rootPosition))
				rootNodeGo.transform.rotation = Quaternion.New(unpack(args.rootRotation))
			end

			if self.curGame then
				gPanelManager:CheckShow(gPanelId.S_VOLLEYBALL_TOP_PANEL, {
					myName = gPlayerManager.infoLogin.bindData.name,
					opName = TextScriptTextConfig.GetConfig(89900892).Text,
					curGame = self.curGame
				})
				self.curGame:Init(function ()
					self.curGame.MgrTable = self

					gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(false)
					gPanelManager:SetVisibleMode(LX6.Manager.VisibleControlType.Gameplay, LX6.Manager.VisibleMode.Front)
					gPanelManager:CheckShow(gPanelId.S_VOLLEYBALL_PANEL, {
						playerController = self.curGame.PlayerController,
						finishCb = function ()
							self.curGame:ResetGame()
						end
					})
				end)
			end
		end
	end)
end

M.LoadLuaGame = function(self, args)
	LX6.Game.MyPlayerManager.SwitchCameraBlock(false)

	self.hasDestroy = false
	self.rootNodeCopyLoadOp = gResourceManager:LoadAssetWithCallBack(self.rootNodeCopyPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)
		else
			local rootNodeGo = GameObject.Instantiate(loadOp.asset)

			if args then
				rootNodeGo.transform.position = Vector3.New(unpack(args.rootPosition))
				rootNodeGo.transform.rotation = Quaternion.New(unpack(args.rootRotation))
			end

			self.curLuaGame = C_VolleyballGame.new(rootNodeGo)

			self.curLuaGame:Init(function ()
				gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(false)
				self.curLuaGame:ResetGame()
			end)
		end
	end)
end

M.OnGameEnd = function(self, isWin)
	self:finishChallenge(0, isWin and 1 or 0)
	self:DestroyGame()
	self:DestroyLuaGame()
end

M.finishChallenge = function(self, score, result)
	gReliableRpcManager:RegisterRPC(gClientToGameDelegate.SetChallengeResult, self.taskId, score, result, function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end)
end

M.DestroyGame = function(self)
	self.rootNodeLoadOp = gResourceManager:UnloadAssetLoadOp(self.rootNodeLoadOp)
	self.rootNodeCopyLoadOp = gResourceManager:UnloadAssetLoadOp(self.rootNodeCopyLoadOp)
	self.hasDestroy = true

	if self.curGame == nil then
		self.curGame:DestroyGame()

		self.curGame = nil
		self.taskId = nil
	end

	LX6.Game.MyPlayerManager.SwitchCameraBlock(true)
	gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(true)
	gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.Gameplay)
	gPanelManager:Close(gPanelId.S_VOLLEYBALL_PANEL)
	gPanelManager:Close(gPanelId.S_VOLLEYBALL_TOP_PANEL)
end

M.DestroyLuaGame = function(self)
	self.hasDestroy = true

	if self.curLuaGame == nil then
		self.curLuaGame:DestroyGame()

		self.curLuaGame = nil
		self.taskId = nil
	end

	LX6.Game.MyPlayerManager.SwitchCameraBlock(true)
	gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject:SetActive(true)
	gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.Gameplay)
	gPanelManager:Close(gPanelId.S_VOLLEYBALL_PANEL)
	gPanelManager:Close(gPanelId.S_VOLLEYBALL_TOP_PANEL)
end

M.TimerCo = function(self, time, action)
	coroutine.wait(time)

	if action then
		action()
	end
end

M.GetHorDist = function(self, a, b)
	return Vector2.Magnitude(self:ToVector2XZ(a - b))
end

M.Vec3DirOfAToB = function(self, a, b)
	return Vector3.Normalize(b - a)
end

M.Vec3HorDirOfAToB = function(self, a, b)
	return Vector3.Normalize(Vector3.New(b.x - a.x, 0, b.z - a.z))
end

M.NewVec3SetY = function(self, v, y)
	return Vector3.New(v.x, y, v.z)
end

M.Vec2DirOfAToB = function(self, a, b)
	return Vector2.Normalize(b - a)
end

M.ToVector2XZ = function(self, v)
	return Vector2.New(v.x, v.z)
end

M.ToVector3 = function(self, v)
	return Vector3.New(v.x, 0, v.y)
end

M.GetRandomPosNearPos = function(self, pos, randomRadius)
	local randomValue = math.random(0, randomRadius)
	local randomAngle = math.random(0, 6.28)
	local offset = Vector3.New(Mathf.Cos(randomAngle) * randomValue, 0, Mathf.Sin(randomAngle) * randomValue)
	local targetPos = pos + offset

	return targetPos
end

M.ClampXZByRect = function(self, pos, rect)
	pos.x = Mathf.Clamp(pos.x, rect.xMin, rect.xMax)
	pos.z = Mathf.Clamp(pos.z, rect.yMin, rect.yMax)

	return pos
end

M.PrintDebug = function(self, ...)
	print_debug("[VolleyballGame]", ...)
end

M.PrintError = function(self, ...)
	print_error("[VolleyballGame]", ...)
end

gVolleyballGameMgr = gVolleyballGameMgr or C_VolleyballGameManager.new()
