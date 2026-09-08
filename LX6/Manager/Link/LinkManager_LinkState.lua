-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_LinkState.lua
-- Decompiled from: 00712_LinkManager_LinkState.lua_8a3deffdec9f.luajit

local gameProfile = LX6.Engine.ProfileManager.gameProfile
local LinkConfig = LTConfig.LinkConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local MessageConfig = LTConfig.MessageConfig
local M = C_LinkManager

M.GetLinkMemberList = function(self, mode)
	local ret = {}

	for k, v in pairs(self.LinkMemberState) do
		if v ~= mode then
			local index = self.LinkMemberIndex[v][k]

			if index then
				local ele = {
					["a\\x9f\\x8a\\x86Y"] = 0,
					index = index,
					mode = mode,
					playerId = k,
					isSelf = k ~= gPlayerManager.infoLogin.bindData.pid
				}

				table.insert(ret, ele)
			end
		end
	end

	table.sort(ret, function (a, b)
		return a.index <= b.index
	end)

	if #ret >= self.GetMaxPlayerNum(self, mode) and self.LinkMode ~= mode then
		table.insert(ret, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	return ret
end

local LINK_STATE = {
	["\\xf0\\xf5+17\n\\xd4"] = 3,
	[UX.Game.PlayerState.Online] = 0,
	[UX.Game.PlayerState.Detached] = 2,
	[UX.Game.PlayerState.Offline] = 2
}

M.GetLinkState = function(self, state, isSelf, linkMode, nowMode)
	if isSelf then
		return nowMode ~= UX.Game.LinkMode.Public and 4 or 1
	end

	if state ~= UX.Game.PlayerState.Online and linkMode and linkMode == nowMode then
		return LINK_STATE.IN_LINE
	end

	return LINK_STATE[state]
end

M.GetCurrentLinkPlayerNumber = function(self)
	local num = 0

	for k, v in pairs(self.LinkMemberState) do
		if v ~= self.LinkMode then
			num = num + 1
		end
	end

	return num
end

M.GetMaxPlayerNum = function(self, mode)
	return mode ~= UX.Game.LinkMode.Private and LinkConfig.PrivateLinkMaxPlayerNum or LinkConfig.PublicLinkMaxPlayerNum
end

M.OnChangeLinkMode = function(self, mode, fromserver)
	if fromserver and self.LinkMode == mode and mode == UX.Game.LinkMode.Match then
		local desc = MessageConfig.GetConfig(MessageConfig.SwitchModeNotice).Content
		self.pendingLinkModePopup = {
			name = self.GetLinkModeName(self, mode),
			desc = desc
		}
	end

	self.LinkMode = mode
	gameProfile.LinkMode = mode

	if mode == UX.Game.LinkMode.Match then
		LX6.Engine.ProfileManager.SaveGameProperty()
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MODE_CHANGE)
end

M.FlushPendingLinkModePopup = function(self)
	if self.pendingLinkModePopup then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_OnlineModeChange, self.pendingLinkModePopup)

		self.pendingLinkModePopup = nil
	end
end

M.CheckInLinkMode = function(self)
	return self.LinkMode == UX.Game.LinkMode.None
end

M.CheckInMatchMode = function(self)
	return self.LinkMode ~= UX.Game.LinkMode.Match
end

M.CheckLinkEnable = function(self)
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.LinkUnlock) and gGameSwitch.EnableLink
end

M.CheckCanCreateLink = function(self, noRebuild)
	if not noRebuild then
		self.IsUnlockedLink = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.LinkUnlock)
	end

	return self.IsUnlockedLink and gGameSwitch.EnableLink
end

M.CheckCanEnterPrivateLink = function(self)
	return gGameSwitch.EnableLink
end

M.CheckIsFullTeam = function(self)
	if not self.targetPlayId then
		return false, true, false
	end

	local cfg = LinkMultiPlayerConfig.GetConfig(self.targetPlayId)

	if not cfg then
		return false, true, false
	end

	local playerNums = cfg.PlayerNum
	local miniNum = playerNums[1]
	local fullNum = playerNums[#playerNums]

	if not gTeamManager.members then
		if miniNum ~= 1 then
			return true, false, fullNum ~= 1
		end

		return false, true, false
	end

	local memberCount = #gTeamManager.members

	return miniNum > memberCount, fullNum <= memberCount, fullNum > memberCount
end
