local UNavigationMgr = SGUI.UNavigationMgr
C_CommonBombStore = DefClass("C_CommonBombStore", C_CommonBombStore, C_StoreGroup)
GroupName2Class.CommonBombStore = C_CommonBombStore
local M = C_CommonBombStore

function M:ctor()
	self.COMMON_BOMB_TYPE = {
		ONLYTIPS = 2,
		REWARD_PREVIEW = 3,
		INPUT = 0,
		TIPS = 1
	}
	self.BUTTON_TYPE = {
		TRIPLE = 2,
		SINGLE = 0,
		DOUBLE = 1
	}
	self.WARNING = {
		WARNING = 0,
		NON = 1
	}
end

function M:OnAwake()
	self.bindData.longBtn.luaClick = self:CreateAction("OnLongBtnClick")
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.centerBtn.luaClick = self:CreateAction("OnCenterBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.vConfirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.vCancelBtn.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.input.luaValueChanged = self:CreateAction("OnInputFieldChange")
	self.bindData.input.luaExceedLength = self:CreateAction("OnExceedLength")
	self.bindData.input.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.input.onDeActivateAction = self:CreateAction("OnInputFieldDeactivate")
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction("OnRewardListRenderItem")
end

function M:OnShow(panelId, data)
	self.params = data

	self:SetDefaultData()
	self:SetData()
	self:OnInputFieldChange("", true)
end

function M:OnExceedLength()
	if self.params.exceedLengthMsg then
		self.bindData:Commit("warning", self.WARNING.WARNING, COMMIT_FORCE)

		self.bindData.warningText.text = self.params.exceedLengthMsg
	end
end

function M:OnInputFieldChange(txt, isBegin)
	if self.params.inputCheck then
		local flag, str = self.params.inputCheck(txt)

		if not flag and not isBegin then
			if self.params.inputErrorTips then
				self.bindData.warningText.text = self.params.inputErrorTips

				self.bindData:Commit("warning", self.WARNING.WARNING, COMMIT_FORCE)
			elseif not string.is_null_or_empty(str) then
				self.bindData.warningText.text = str

				self.bindData:Commit("warning", self.WARNING.WARNING, COMMIT_FORCE)
			end
		else
			self.bindData.warningText.text = ""

			self.bindData:Commit("warning", self.WARNING.NON, COMMIT_FORCE)
		end

		self.bindData.confirmBtn.interactable = flag
	end
end

function M:OnCloseBtnClick()
	if self:CheckIsDoubleBtn() then
		self:OnCancelBtnClick()
	else
		gDisplayMessageMgr:CloseBomb()
	end
end

function M:OnLongBtnClick()
	self:OnConfirmBtnClick()
end

function M:OnConfirmBtnClick()
	local params = {}

	if self.params.mid then
		params.mid = self.params.mid
	end

	if self.params.isInput then
		params = self.bindData.input.text
	end

	local isClose = true

	if self.params.btnConfirmCallback then
		if type(self.params.btnConfirmCallback) == "userdata" then
			isClose = self.params.btnConfirmCallback:DynamicInvoke()
		elseif type(self.params.btnConfirmCallback) == "function" then
			isClose = self.params.btnConfirmCallback(params)
		end
	end

	if isClose == false then
		return
	end

	gDisplayMessageMgr:CloseBomb()
end

function M:OnCancelBtnClick()
	gDisplayMessageMgr:CloseBomb()

	if self.params.btnCancelCallback then
		if type(self.params.btnCancelCallback) == "userdata" then
			self.params.btnCancelCallback:DynamicInvoke()
		elseif type(self.params.btnCancelCallback) == "function" then
			self.params.btnCancelCallback()
		end
	end
end

function M:OnCenterBtnClick()
	gDisplayMessageMgr:CloseBomb()

	if self.params.btnCenterCallback then
		if type(self.params.btnCenterCallback) == "userdata" then
			self.params.btnCenterCallback:DynamicInvoke()
		elseif type(self.params.btnCenterCallback) == "function" then
			self.params.btnCenterCallback()
		end
	end
end

function M:SetData()
	local params = self.params

	if not params then
		return
	end

	if params.tips1Text and params.tips2Text then
		self.bindData.tips1Text.text = params.tips1Text
		self.bindData.tips2Text.text = params.tips2Text
		self.bindData.commonBombType = self.COMMON_BOMB_TYPE.TIPS
	elseif params.isInput then
		self.bindData.commonBombType = self.COMMON_BOMB_TYPE.INPUT

		self.bindData:Commit("warning", self.WARNING.NON, COMMIT_FORCE)
		self:ActivateInputField()
	else
		self.bindData.commonBombType = self.COMMON_BOMB_TYPE.ONLYTIPS
	end

	if self:CheckIsTripleBtn() then
		self.bindData.buttonType = self.BUTTON_TYPE.TRIPLE
	elseif self:CheckIsDoubleBtn() then
		self.bindData.buttonType = self.BUTTON_TYPE.DOUBLE
	else
		self.bindData.buttonType = self.BUTTON_TYPE.SINGLE
	end

	if params.confirmBtnText then
		self.bindData.longBtnText.text = params.confirmBtnText
		self.bindData.longBtnText2.text = params.confirmBtnText
		self.bindData.confirmBtnText.text = params.confirmBtnText
		self.bindData.confirmBtnText2.text = params.confirmBtnText
	end

	if params.cancelBtnText then
		self.bindData.cancelBtnText.text = params.cancelBtnText
		self.bindData.cancelBtnText2.text = params.cancelBtnText
	end

	if params.centerBtnText then
		self.bindData.centerBtnText.text = params.centerBtnText
		self.bindData.centerBtnText2.text = params.centerBtnText
	end

	if params.tips1Text then
		self.bindData.onlyTipsText.text = params.tips1Text
	end

	if params.titleText then
		self.bindData.titleLabel = params.titleText
	end

	self.bindData.input.maxLength = params.exceedLength and params.exceedLength or 0
	local isShowCloseBtn = self:CheckIsShowCloseBtn()

	self.bindData.closeBtn:SetActive(isShowCloseBtn)
	self.bindData.backTips:SetActive(isShowCloseBtn)

	if params.rewardRenderDataList then
		self.bindData.rewardList:SetSimpleList(#params.rewardRenderDataList)

		self.bindData.commonBombType = self.COMMON_BOMB_TYPE.REWARD_PREVIEW
	end
end

function M:SetDefaultData()
	self.bindData.confirmBtn.interactable = true
	self.bindData.commonBombType = self.COMMON_BOMB_TYPE.TIPS
	self.bindData.buttonType = self.BUTTON_TYPE.SINGLE
	self.bindData.warning = self.WARNING.NON
	self.bindData.input.text = ""
	self.bindData.tips1Text.text = ""
	self.bindData.tips2Text.text = ""
	self.bindData.onlyTipsText.text = ""
	self.bindData.warningText.text = ""
	local confirmText = LTConfig.TextScriptTextConfig.GetConfig(89900149).Text
	self.bindData.longBtnText.text = confirmText
	self.bindData.confirmBtnText.text = confirmText
	self.bindData.cancelBtnText.text = LTConfig.TextScriptTextConfig.GetConfig(89900120).Text
	self.bindData.titleLabel = LTConfig.TextScriptTextConfig.GetConfig(89901121).Text

	self.bindData.rewardList:SetSimpleList(0)
end

function M:CheckIsDoubleBtn()
	if self.params.msgType == gDisplayMessageId.SELECT then
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

function M:CheckIsTripleBtn()
	if self.params.msgType == gDisplayMessageId.TRIPLE_SELECT then
		return true
	end

	return false
end

function M:CheckIsShowCloseBtn()
	if self.params.isShowCloseBtn then
		return true
	end

	if self.params.msgType == gDisplayMessageId.SELECT_WITH_CLOSE then
		return true
	end

	return false
end

function M:OnDestroy()
	if self.delay then
		self.delay:Stop()
	end

	self:ClearMessageEvents()
end

function M:OnActiveDeviceChange(device)
	self:ActivateInputField()
end

function M:ActivateInputField()
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		if self.delay then
			self.delay:Stop()
		end

		self.delay = Timer.New(function ()
			self.bindData.input:ActivateInputField()
		end, 0.5):Start()
	end
end

function M:OnInputFieldActivate()
	if self.bindData.inputNavigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.inputNavigationArea
	end
end

function M:OnInputFieldDeactivate()
	if self.bindData.baseNavigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
	end
end

function M:OnRewardListRenderItem(btn, csIndex)
	local index = csIndex + 1
	local data = self.params.rewardRenderDataList[index]

	gCommonItemManager:OnCommonItemRender(btn, csIndex, data)
end
