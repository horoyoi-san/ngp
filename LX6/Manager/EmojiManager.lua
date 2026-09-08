-- Original chunk: @Lua\LuaFiles\LX6\Manager\EmojiManager.lua
-- Decompiled from: 00521_EmojiManager.lua_c64eab94dbd6.luajit

local M = {
	LockEmotes = {},
	NewEmotes = {},
	LOCAL_CONFIG = "EmojiConfig"
}
local mEmojiActions = {}

M.OnInit = function(self)
	self.LockEmotes = {}

	for i = 0, LTConfig.EmoteChatConfig.count - 1 do
		local config = LTConfig.EmoteChatConfig.LoadAt(i)

		for j = 1, #config.AnimSequence do
			mEmojiActions[config.AnimSequence[j]] = true
		end
	end
end

M.ReInit = function(self)
	self.LockEmotes = gUIUtils:LoadJsonToLuaTableWithPid(self.LOCAL_CONFIG)

	if self.LockEmotes ~= nil then
		self.LockEmotes = {}

		for i = 0, LTConfig.EmoteChatConfig.count - 1 do
			local config = LTConfig.EmoteChatConfig.LoadAt(i)

			for j = 1, #config.AnimSequence do
				self.LockEmotes[config.Id] = not config.IsUnlock
			end
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self.LockEmotes = {}
	self.NewEmotes = {}
end

M.StopEmojiAction = function(self)
	gCS.AnimControllerManager.StopBaseActionQueue(gCS.MyPlayerManager.PlayerUnit)
end

gEmojiManager = M
