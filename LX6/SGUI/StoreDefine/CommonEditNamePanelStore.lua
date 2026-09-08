-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonEditNamePanelStore.lua
-- Decompiled from: 01523_CommonEditNamePanelStore.lua_fd09bb04d7a4.luajit

C_CommonEditNamePanelStore = DefClass("C_CommonEditNamePanelStore", C_CommonEditNamePanelStore, C_StoreGroup)
GroupName2Class.CommonEditNamePanelStore = C_CommonEditNamePanelStore
local M = C_CommonEditNamePanelStore

M.OnAwake = function(self)
	self.bindData.cancelButton.luaClick = self.CreateAction(self, self.OnCancelClick)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnConfirmClick)
	self.bindData.inputField.luaExceedLength = self.CreateAction(self, self.OnInputExceedLength)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.onCancelCallback = args and args.onCancelCallback
	self.onConfirmCallback = args and args.onConfirmCallback
	self.maxLength = args and args.maxLength or LTConfig.GameConfig.PlayerNameMaxLength
	self.pixelLimit = args and args.pixelLimit
	self.hintText = args and args.hintText
	self.Show_Tips_Control = {
		["9P\\x92\\x8b\\x86E"] = 1,
		["pBbzG\n="] = 2,
		["Ay\\xa2TC\\xbf\\xe2Kc{pX"] = 3,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.InitView = function(self)
	self.bindData.showTipsControl = self.Show_Tips_Control.Normal
	self.bindData.inputField.maxLength = self.maxLength or self.bindData.inputField.maxLength
	self.bindData.inputField.pixelLimit = self.pixelLimit or self.bindData.inputField.pixelLimit
	self.bindData.inputField.placeHolder.text = self.hintText or self.bindData.inputField.placeHolder.text
end

M.OnCancelClick = function(self)
	if self.onCancelCallback then
		self.onCancelCallback()
	end

	gPanelManager:Close(self.m_Id)
end

M.OnConfirmClick = function(self)
	local name = self.bindData.inputField.text

	gClientUtils.EnvSdkReviewWords(name, function ()
		local maxLength = self.bindData.inputField.maxLength

		if UX.Utils.NameValidityChecker.CheckName(name, maxLength, 1) == 0 then
			self:ShowTips(self.Show_Tips_Control.NonCompliant)

			return
		end

		if self.onConfirmCallback then
			self.onConfirmCallback(self.bindData.inputField.text)
		end

		gPanelManager:Close(self.m_Id)
	end, function ()
		self:ShowTips(self.Show_Tips_Control.Sensitive)
	end, "CommonEditNamePanel")
end

M.ShowTips = function(self, controlValue)
	self.showTipsCo = coroutine.stop(self.showTipsCo)
	self.bindData.showTipsControl = controlValue
	self.showTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.showTipsControl = self.Show_Tips_Control.Normal
	end)
end

M.OnInputExceedLength = function(self)
	self.ShowTips(self, self.Show_Tips_Control.Exceed)
end

M.OnDestroy = function(self)
	self.showTipsCo = coroutine.stop(self.showTipsCo)
end

M.OnActiveDeviceChange = function(self, device)
end
