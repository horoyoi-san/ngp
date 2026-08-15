C_CommonEditNamePanelStore = DefClass("C_CommonEditNamePanelStore", C_CommonEditNamePanelStore, C_StoreGroup)
GroupName2Class.CommonEditNamePanelStore = C_CommonEditNamePanelStore
local M = C_CommonEditNamePanelStore

function M:OnAwake()
	self.bindData.cancelButton.luaClick = self:CreateAction(self.OnCancelClick)
	self.bindData.confirmButton.luaClick = self:CreateAction(self.OnConfirmClick)
	self.bindData.inputField.luaExceedLength = self:CreateAction(self.OnInputExceedLength)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.onCancelCallback = args and args.onCancelCallback
	self.onConfirmCallback = args and args.onConfirmCallback
	self.maxLength = args and args.maxLength or LTConfig.GameConfig.PlayerNameMaxLength
	self.pixelLimit = args and args.pixelLimit
	self.hintText = args and args.hintText
	self.Show_Tips_Control = {
		Exceed = 1,
		Sensitive = 2,
		NonCompliant = 3,
		Normal = 0
	}
end

function M:InitView()
	self.bindData.showTipsControl = self.Show_Tips_Control.Normal
	self.bindData.inputField.maxLength = self.maxLength or self.bindData.inputField.maxLength
	self.bindData.inputField.pixelLimit = self.pixelLimit or self.bindData.inputField.pixelLimit
	self.bindData.inputField.placeHolder.text = self.hintText or self.bindData.inputField.placeHolder.text
end

function M:OnCancelClick()
	if self.onCancelCallback then
		self.onCancelCallback()
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnConfirmClick()
	local name = self.bindData.inputField.text

	gClientUtils.EnvSdkReviewWords(name, function ()
		local maxLength = self.bindData.inputField.maxLength

		if UX.Utils.NameValidityChecker.CheckName(name, maxLength, 1) ~= 0 then
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

function M:ShowTips(controlValue)
	self.showTipsCo = coroutine.stop(self.showTipsCo)
	self.bindData.showTipsControl = controlValue
	self.showTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.showTipsControl = self.Show_Tips_Control.Normal
	end)
end

function M:OnInputExceedLength()
	self:ShowTips(self.Show_Tips_Control.Exceed)
end

function M:OnDestroy()
	self.showTipsCo = coroutine.stop(self.showTipsCo)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
