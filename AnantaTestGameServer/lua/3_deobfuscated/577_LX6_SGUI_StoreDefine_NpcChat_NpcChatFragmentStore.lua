C_NpcChatFragmentStore = DefClass("C_NpcChatFragmentStore", C_NpcChatFragmentStore, C_StoreGroup)
local M = C_NpcChatFragmentStore

function M:OnShow(tabIndex, args)
	return
end

function M:OnPause()
	return
end

function M:OnResume()
	return
end

function M:OnClose()
	return
end

function M:HandleExit()
	return false
end

function M:_ShowFragment(args, tabIndex, activity)
	self.activity = activity

	self:OnShow(tabIndex, args)
end
