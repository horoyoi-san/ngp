-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ShuttlecockGame\ShuttlecockGameManager.lua
-- Decompiled from: 00610_ShuttlecockGameManager.lua_2512610e5193.luajit

C_ShuttlecockGameManager = DefClass("C_ShuttlecockGameManager", C_ShuttlecockGameManager, gBaseMiniGameManager)
local ShuttlecockGameManager = C_ShuttlecockGameManager
local CHALLENGE_TAG_TO_WIN_TYPE = {
	[503.0] = 3,
	[501.0] = 1,
	[502.0] = 2
}

ShuttlecockGameManager.CreateGame = function(self, args)
	self.currentGame = gShuttlecockGame.new(args)
end

ShuttlecockGameManager.CreateGameCs = function(self, taskId, npcId, position, eulerRotation, isCuJuVariant, entityId)
	local cfg = ShuttlecockConfig.LevelGroupConfig[1]
	local wayPointPosition, wayPointRotation = nil
	local hasPosition = position and (position.x == 0 or position.y == 0 or position.z == 0)

	if hasPosition then
		wayPointPosition = {
			position.x,
			position.y,
			position.z
		}
	else
		wayPointPosition = cfg.LevelPos
	end

	if eulerRotation then
		wayPointRotation = {
			eulerRotation.x,
			eulerRotation.y,
			eulerRotation.z
		}
	else
		wayPointRotation = cfg.LevelRotation
	end

	self.entityId = entityId
	self.taskId = taskId
	local challengeList = LTConfig.PoiGameConfig.Shuttlecock_ChallengeList
	local baseScore = LTConfig.PoiGameConfig.Shuttlecock_DrawScore

	gClientToGameDelegate:AskNewChallengeRecordList(challengeList).Callback = function (err, records)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		local challengeId = self:PickNextChallenge(challengeList, records)

		gClientToGameDelegate:StartNewChallenge(challengeId).Callback = function (err2)
			if err2 == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:ShowServerMessage(err2)

				return
			end

			local challengeCfg = LTConfig.ChallengeConfig.GetConfig(challengeId)

			self:CreateGame({
				["\\xca\\xcf\n\r\\xf5"] = 1,
				taskId = taskId,
				npcId = npcId,
				wayPointPosition = wayPointPosition,
				wayPointRotation = wayPointRotation,
				isCuJuVariant = isCuJuVariant or false,
				challengeId = challengeId,
				challengeCfg = challengeCfg,
				challengeList = challengeList,
				baseScore = baseScore
			})
		end
	end
end

ShuttlecockGameManager.PickNextChallenge = function(self, challengeList, records)
	local recordMap = {}

	if records then
		for i = 1, #records do
			local r = records[i]

			if r and r.ChallengeId then
				recordMap[r.ChallengeId] = r
			end
		end
	end

	for i = 1, #challengeList do
		local id = challengeList[i]
		local r = recordMap[id]

		if not r or r.HighestLevel >= 2 then
			return id
		end
	end

	local n = #challengeList
	local last3 = {
		challengeList[n - 2],
		challengeList[n - 1],
		challengeList[n]
	}

	return last3[math.random(1, 3)]
end

ShuttlecockGameManager.ExitGameCs = function(self)
	if self.currentGame then
		self.currentGame:ForceExit()

		self.currentGame = nil

		gSpoonClientMgr:TryCallInnerSignal(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "ShuttlecockGameExit")
	end
end

gShuttlecockGameManager = gShuttlecockGameManager or C_ShuttlecockGameManager.new()
