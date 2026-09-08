-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_WatchGame.lua
-- Decompiled from: 00714_LinkManager_WatchGame.lua_7942bdc7be0f.luajit

local MessageConfig = LTConfig.MessageConfig
local M = C_LinkManager

M.AskWatchOnlinePlayer = function(self, pid, callback)
	if pid ~= self.currentWatchPid then
		if callback then
			callback()
		end

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskLinkWatchOther(pid).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.OnSyncWatchState = function(self, state, watchPid)
	local diff = self.watchState ~= state
	self.watchState = state
	self.currentWatchPid = watchPid
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if self.watchState and watchPid == ulong.zero then
		if gameplayControlStore.curType == gHUDGameplayType.InGameWatching then
			gPanelManager:Close(gPanelId.COMMON_LINK_SYMMETRY_END_PANEL)
			gPanelManager:Close(gPanelId.COMMON_TEAM_RANK)
			gameplayControlStore:StartGameplayByType(gHUDGameplayType.InGameWatching, {
				["`x\\xa0n\\xba\\xfdPD{sI"] = true,
				watchPlayer = watchPid
			})
		end

		gMessageManager:SendMessage(gEventConstants.ONLINE_INGAME_WATCH_PLAYER_CHANGE, watchPid)
		gCS.BaseUnitUtils.FocusOnTarget(watchPid)
	end

	if watchPid ~= ulong.zero and gameplayControlStore.curType ~= gHUDGameplayType.InGameWatching then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.InGameWatching)
		self.ExitIngameWatching(self)
		gCS.BaseUnitUtils.FocusOnTarget(ulong.zero)
	end

	if not diff then
		gMessageManager:SendMessage(gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE)
	end
end

M.OnWatchOnlinePlayer = function(self, pid, fromChallenge)
	pid = pid or 0

	self:AskWatchOnlinePlayer(pid)
end

M.ExitIngameWatching = function(self)
	if self.matchState then
		self.OpenFinalRankPanel(self, true)
	end
end
