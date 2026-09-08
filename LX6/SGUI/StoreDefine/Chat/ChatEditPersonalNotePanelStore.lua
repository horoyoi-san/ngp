-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatEditPersonalNotePanelStore.lua
-- Decompiled from: 01940_ChatEditPersonalNotePanelStore.lua_f0c83f82e7ef.luajit

C_ChatEditPersonalNotePanelStore = DefClass("C_ChatEditPersonalNotePanelStore", C_ChatEditPersonalNotePanelStore, C_AppFragmentStore)
GroupName2Class.ChatEditPersonalNotePanelStore = C_ChatEditPersonalNotePanelStore
local M = C_ChatEditPersonalNotePanelStore

M.OnAwake = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnCancelBtnClick)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnConfirmBtnClick)
end

M.OnShow = function(self, _, data)
	self.bindData.inputField.text = gChatUtils.GetMySignature()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false
end

M.OnDisable = function(self)
	gLuaDataManager.guiMgr.sguiJoystick.Visible = true
end

M.OnCancelBtnClick = function(self)
	self.Close(self)
end

M.OnConfirmBtnClick = function(self)
	slot1 = self.bindData.inputField.text
	local sign = slot1:gsub("\\n", "\\\\n")
	slot2 = gHunLunManager

	slot2:ChangeSign(sign, function ()
		gMessageManager:SendMessage(gEventConstants.PLAYER_SIGN_CHANGED, sign)
		self:Close()
	end)
end

M.Close = function(self)
	self.activity:CloseCurrentFragment()
end
