-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewCommonWindowMiddleStore.lua
-- Decompiled from: 01043_NewCommonWindowMiddleStore.lua_7154437dd285.luajit

C_NewCommonWindowMiddleStore = DefClass("C_NewCommonWindowMiddleStore", C_NewCommonWindowMiddleStore, C_StoreGroup)
GroupName2Class.NewCommonWindowMiddleStore = C_NewCommonWindowMiddleStore
local M = C_NewCommonWindowMiddleStore

M.ctor = function(self)
	self.BUTTON_TYPE = {
		["8g\\xa4\\xac\\xafd"] = 1,
		["/a\\xbf\\xa9\\xafd"] = 0
	}
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.buttonTypeEnum = {
		["G\\x84\\x8c\\x8fD"] = 1,
		["A\\x9f\\x89\\x8fD"] = 0,
		["Z\\x98\\x9e\\x8fD"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.buttonTypeEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.params = data

	self.SetDefaultData(self)
	self.SetData(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnClickCancelBtn)
end

M.OnClickConfirmBtn = function(self)
	local isClose = true

	if self.params and self.params.btnConfirmCallback then
		if type(self.params.btnConfirmCallback) ~= "userdata" then
			isClose = self.params.btnConfirmCallback:DynamicInvoke()
		elseif type(self.params.btnConfirmCallback) ~= "function" then
			local callbackParams = {}

			if self.params.mid then
				callbackParams.mid = self.params.mid
			end

			isClose = self.params.btnConfirmCallback(callbackParams)
		end
	end

	if isClose ~= false then
		return
	end

	gDisplayMessageMgr:CloseMiddleWindow()
end

M.OnClickCancelBtn = function(self)
	gDisplayMessageMgr:CloseMiddleWindow()

	if self.params and self.params.btnCancelCallback then
		if type(self.params.btnCancelCallback) ~= "userdata" then
			self.params.btnCancelCallback:DynamicInvoke()
		elseif type(self.params.btnCancelCallback) ~= "function" then
			self.params.btnCancelCallback()
		end
	end
end

M.SetDefaultData = function(self)
	self.bindData.confirmBtn.interactable = true
	self.bindData.buttonType = self.BUTTON_TYPE.SINGLE
	local confirmText = LTConfig.TextScriptTextConfig.GetConfig(89900149).Text
	self.bindData.confirmLabel = confirmText
	self.bindData.cancelLabel = LTConfig.TextScriptTextConfig.GetConfig(89900120).Text
	self.bindData.titleLabel = LTConfig.TextScriptTextConfig.GetConfig(89901121).Text
	self.bindData.tips1Label = ""
end

M.SetData = function(self)
	local params = self.params

	if not params then
		return
	end

	if self.CheckIsDoubleBtn(self) then
		self.bindData.buttonType = self.BUTTON_TYPE.DOUBLE
	else
		self.bindData.buttonType = self.BUTTON_TYPE.SINGLE
	end

	if params.confirmBtnText then
		self.bindData.confirmLabel = params.confirmBtnText
	end

	if params.cancelBtnText then
		self.bindData.cancelLabel = params.cancelBtnText
	end

	if params.tips1Text then
		self.bindData.tips1Label = params.tips1Text
	end

	if params.titleText then
		self.bindData.titleLabel = params.titleText
	end
end

M.CheckIsDoubleBtn = function(self)
	if self.params.msgType ~= gDisplayMessageId.SELECT or self.params.msgType ~= gDisplayMessageId.SELECT_FORCE or self.params.msgType ~= gDisplayMessageId.SELECT_WITH_CLOSE then
		return true
	end

	if self.params.confirmBtnText and self.params.cancelBtnText then
		return true
	end

	if self.params.btnConfirmCallback and self.params.btnCancelCallback then
		return true
	end

	return false
end
