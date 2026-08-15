local M = {
	LockEmotes = {},
	NewEmotes = {},
	LOCAL_CONFIG = "EmojiConfig"
}
local mEmojiActions = {}
local eventHandler = {}

function M:OnInit()
	self.LockEmotes = {}

	for i = 0, LTConfig.EmoteChatConfig.count - 1 do
		local config = LTConfig.EmoteChatConfig.LoadAt(i)

		for j = 1, #config.AnimSequence do
			mEmojiActions[config.AnimSequence[j]] = true
		end
	end
end

function M:ReInit()
	self.LockEmotes = gUIUtils:LoadJsonToLuaTableWithPid(self.LOCAL_CONFIG)

	if self.LockEmotes == nil then
		self.LockEmotes = {}

		for i = 0, LTConfig.EmoteChatConfig.count - 1 do
			local config = LTConfig.EmoteChatConfig.LoadAt(i)

			for j = 1, #config.AnimSequence do
				self.LockEmotes[config.Id] = not config.IsUnlock
			end
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self.LockEmotes = {}
	self.NewEmotes = {}
end

function M:StopEmojiAction()
	gCS.AnimControllerManager.StopBaseActionQueue(gCS.MyPlayerManager.PlayerUnit)
end

gEmojiManager = M
