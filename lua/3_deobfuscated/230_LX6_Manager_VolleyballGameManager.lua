local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local StaticProps = {}
C_VolleyballGameManager = DefClass("C_VolleyballGameManager", C_VolleyballGameManager, nil, StaticProps)
local M = C_VolleyballGameManager

function M:ctor()
	self.curGame = nil
	self.curLuaGame = nil
	self.hasDestroy = true
	self.rootNodePath = "Res/MiniGame/Prefab/VolleyballGame/VolleyballGameRootNode.prefab"
	self.rootNodeCopyPath = "Res/MiniGame/Prefab/VolleyballGame/VolleyballGameRootNodeCopy.prefab"
	self.CharacterState = {
		SmashQTE = 2,
		Match = 5,
		LaunchQTE = 4,
		Free = 3,
		PreLaunch = 1,
		None = 0
	}
	self.Team = {
		Op = 2,
		My = 1
	}
	self.MoveReason = {
		KickBack = 5,
		Pass = 4,
		Match = 6,
		FailSmash = 1,
		SPSmash = 3,
		Smash = 2,
		None = 0
	}
	self.QTELevel = {
		Early = 1,
		Late = 4,
		Perfect = 3,
		Fake = 5,
		Normal = 2
	}
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		-- Nothing
	end
end

function M:CreateGame(args)
	self.taskId = args.taskId

	if self.curGame ~= nil or self.hasDestroy == false then
		self:DestroyGame()
		Timer.New(function ()
			self:LoadGame(args)
		end, 1):Start()
	else
		self:LoadGame(args)
	end
end

function M:CreateLuaGame(args)
	self.taskId = args.taskId

	if self.curLuaGame ~= nil or self.hasDestroy == false then
		self:DestroyLuaGame()
		Timer.New(function ()
			self:LoadLuaGame(args)
		end, 1):Start()
	else
		self:LoadLuaGame(args)
	end
end

function M:CreateLuaGameCs(taskId, position, rotation)
	self:CreateLuaGame({
		taskId = taskId,
		rootPosition = position,
		rootRotation = rotation
	})
end

function M:LoadGame(args)
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

function M:LoadLuaGame(args)
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

function M:OnGameEnd(isWin)
	self:finishChallenge(0, isWin and 1 or 0)
	self:DestroyGame()
	self:DestroyLuaGame()
end

function M:finishChallenge(score, result)
	gClientToGameDelegate:SetChallengeResult(self.taskId, score, result).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

function M:DestroyGame()
	self.rootNodeLoadOp = gResourceManager:UnloadAssetLoadOp(self.rootNodeLoadOp)
	self.rootNodeCopyLoadOp = gResourceManager:UnloadAssetLoadOp(self.rootNodeCopyLoadOp)
	self.hasDestroy = true

	if self.curGame ~= nil then
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

function M:DestroyLuaGame()
	self.hasDestroy = true

	if self.curLuaGame ~= nil then
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

function M:TimerCo(time, action)
	coroutine.wait(time)

	if action then
		action()
	end
end

function M:GetHorDist(a, b)
	return Vector2.Magnitude(self:ToVector2XZ(a - b))
end

function M:Vec3DirOfAToB(a, b)
	return Vector3.Normalize(b - a)
end

function M:Vec3HorDirOfAToB(a, b)
	return Vector3.Normalize(Vector3.New(b.x - a.x, 0, b.z - a.z))
end

function M:NewVec3SetY(v, y)
	return Vector3.New(v.x, y, v.z)
end

function M:Vec2DirOfAToB(a, b)
	return Vector2.Normalize(b - a)
end

function M:ToVector2XZ(v)
	return Vector2.New(v.x, v.z)
end

function M:ToVector3(v)
	return Vector3.New(v.x, 0, v.y)
end

function M:GetRandomPosNearPos(pos, randomRadius)
	local randomValue = math.random(0, randomRadius)
	local randomAngle = math.random(0, 6.28)
	local offset = Vector3.New(Mathf.Cos(randomAngle) * randomValue, 0, Mathf.Sin(randomAngle) * randomValue)
	local targetPos = pos + offset

	return targetPos
end

function M:ClampXZByRect(pos, rect)
	pos.x = Mathf.Clamp(pos.x, rect.xMin, rect.xMax)
	pos.z = Mathf.Clamp(pos.z, rect.yMin, rect.yMax)

	return pos
end

function M:PrintDebug(...)
	print_debug("[VolleyballGame]", ...)
end

function M:PrintError(...)
	print_error("[VolleyballGame]", ...)
end

gVolleyballGameMgr = gVolleyballGameMgr or C_VolleyballGameManager.new()
