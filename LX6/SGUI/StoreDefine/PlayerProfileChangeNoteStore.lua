-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileChangeNoteStore.lua
-- Decompiled from: 00806_PlayerProfileChangeNoteStore.lua_d7f2051cca32.luajit

C_PlayerProfileChangeNoteStore = DefClass("C_PlayerProfileChangeNoteStore", C_PlayerProfileChangeNoteStore, C_StoreGroup)
GroupName2Class.PlayerProfileChangeNoteStore = C_PlayerProfileChangeNoteStore
local M = C_PlayerProfileChangeNoteStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.oldInput = nil
	self.textWasReplacedByFilter = false
end

M.OnAwake = function(self)
	self.bindData.btnSave.luaClick = self.CreateAction(self, self.OnClickSave)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnClickExit)
	self.bindData.btnExit2.luaClick = self.CreateAction(self, self.OnClickExit)
	self.bindData.input.luaValueChanged = self.CreateAction(self, self.OnValueChanged)
end

M.OnEnable = function(self)
	local msgEvents = {
		[gEventConstants.INPUT_TEXT_BLOCK_PEPLACE] = self.CreateAction(self, "OnInputTextReplacedByFilter")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.InitMessageEvents = function(self)
end

M.OnDestroy = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.pid then
		return
	end

	self.pid = data.pid
	self.note = data.note or ""
	self.bindData.input.text = self.note
	self.oldInput = self.note

	self:CloseOther()
end

M.CloseOther = function(self)
	local toClose = {
		gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_BIRTHDAY_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_POPUP_BACKGROUND_PANEL
	}

	for _, v in ipairs(toClose) do
		if gPanelManager:IsPanelShowing(v) then
			gPanelManager:Close(v)
		end
	end
end

M.OnClickSave = function(self)
	if self.textWasReplacedByFilter then
		return
	end

	local note = self.bindData.input.text

	gClientUtils.EnvSdkReviewWords(note, function ()
		if string.is_null_or_empty(note) then
			slot0 = gDisplayMessageMgr

			slot0:ShowMessage(LTConfig.MessageConfig.ClearSignature, function ()
				self:DoSaveNote()
			end, function ()
			end)
		else
			self:DoSaveNote()
		end
	end, function ()
	end, "ProfilePlayerNote")
end

M.DoSaveNote = function(self)
	self.note = self.bindData.input.text
	slot1 = gClientToGameDelegate

	slot1:AskUpdatePersonalZoneDescription(self.pid, self.note).Callback = function (err, list)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			gMessageManager:SendMessage(gEventConstants.PLAYER_PROFILE_INFO_CHANGED)
			self:OnClickExit()
		end
	end
end

M.OnInputTextReplacedByFilter = function(self)
	self.textWasReplacedByFilter = true
end

M.OnValueChanged = function(self)
	self.textWasReplacedByFilter = false
	local text = self.bindData.input.text
	local visualLength = LX6.Utils.TextUtils.GetVisualLength(text)
	local tooLong = LTConfig.ImageConfig.MaxSignLength <= visualLength

	if tooLong then
		self.bindData.input.text = self.oldInput

		if self.bindData.showWarningCtrl == BOOL2CTL[true] then
			self.bindData.showWarningCtrl = BOOL2CTL[true]

			Timer.New(function ()
				self.bindData.showWarningCtrl = BOOL2CTL[false]
			end, 3):Start()
		end
	else
		self.oldInput = text
	end
end

M.OnClickExit = function(self)
	gPanelManager:Close(gPanelId.PLAYER_PROFILE_CHANGE_NOTE_PANEL)
end

M.OnActiveDeviceChange = function(self, device)
end
