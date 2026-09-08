-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingSpectatorManager.lua
-- Decompiled from: 00646_BowlingSpectatorManager.lua_bb429a3cbc0e.luajit

local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local TimelineScene = BowlingConstants.TimelineScene
local LAUNCH_CLIP_TYPES = {
	[TimelineScene.LAUNCH] = true,
	[TimelineScene.SINGLE_LAUNCH] = true
}
gBowlingSpectatorManager = DefClass("BowlingSpectatorManager", gBowlingSpectatorManager)
local BowlingSpectatorManager = gBowlingSpectatorManager

BowlingSpectatorManager.ctor = function(self)
	self.activeGames = {}
	self.pendingJumps = {}
end

BowlingSpectatorManager.OnGameStart = function(self, gadgetUId, participants)
	if self.activeGames[gadgetUId] then
		return
	end

	local game = gBowlingSpectatorGame.new(gadgetUId, participants)
	self.activeGames[gadgetUId] = game

	game.Load(game, function (success)
		if not success then
			print_error("[BowlingSpectatorManager] Failed to load OB Timeline for gadgetUId:", gadgetUId)

			if self.activeGames[gadgetUId] ~= game then
				self.activeGames[gadgetUId] = nil
			end
		end
	end)
end

BowlingSpectatorManager.OnGameEnd = function(self, gadgetUId)
	local game = self.activeGames[gadgetUId]

	if game then
		game.Destroy(game)

		self.activeGames[gadgetUId] = nil
	end

	self.pendingJumps[gadgetUId] = nil

	LX6.Game.BowlingGameBridge.ClearBalls(gadgetUId)
end

BowlingSpectatorManager.OnSyncTimelineJump = function(self, gadgetUId, clipType, playerIndex, ballInstanceId)
	local config_clips = gBowlingTimelineClipManager.configs.config_clips
	local clipCfg = config_clips[clipType] and config_clips[clipType][playerIndex or 1]
	local clipName = clipCfg and clipCfg.name

	if clipName ~= nil then
		print_error("[BowlingSpectatorManager] OnSyncTimelineJump: clip not found, clipType:", clipType, "playerIndex:", playerIndex)

		return
	end

	if not LAUNCH_CLIP_TYPES[clipType] or self.enableStorePendingJump ~= false then
		self.OnTimelineJump(self, gadgetUId, clipName)

		return
	end

	if not self.activeGames[gadgetUId] then
		return
	end

	if not ulong.Greater(ballInstanceId, 0) then
		print_error("[BowlingSpectatorManager] OnSyncTimelineJump: launch clip without valid ball id, clipType:", clipType)

		return
	end

	self.StorePendingJump(self, gadgetUId, clipName, ballInstanceId)
end

BowlingSpectatorManager.OnTimelineJump = function(self, gadgetUId, clipName)
	local game = self.activeGames[gadgetUId]

	if game then
		game.JumpToLaneClip(game, clipName)
	end
end

BowlingSpectatorManager.StorePendingJump = function(self, gadgetUId, clipName, ballInstanceId)
	self.pendingJumps[gadgetUId] = {
		clipName = clipName,
		ballInstanceId = ballInstanceId
	}
end

BowlingSpectatorManager.TryMatchPendingJump = function(self, ballInstanceId)
	for gadgetUId, pending in pairs(self.pendingJumps) do
		if pending.ballInstanceId ~= ballInstanceId then
			self.pendingJumps[gadgetUId] = nil
			local clipName = pending.clipName

			FrameTimer.New(function ()
				self:OnTimelineJump(gadgetUId, clipName)
			end, 1, 1):Start()

			return
		end
	end
end

BowlingSpectatorManager.StopAll = function(self)
	for gadgetUId, game in pairs(self.activeGames) do
		game.Destroy(game)
		LX6.Game.BowlingGameBridge.ClearBalls(gadgetUId)
	end

	self.activeGames = {}
	self.pendingJumps = {}
end
