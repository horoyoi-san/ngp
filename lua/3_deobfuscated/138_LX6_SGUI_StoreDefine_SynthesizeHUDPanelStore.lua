C_SynthesizeHUDPanelStore = DefClass("C_SynthesizeHUDPanelStore", C_SynthesizeHUDPanelStore, C_StoreGroup)
GroupName2Class.SynthesizeHUDPanelStore = C_SynthesizeHUDPanelStore
local M = C_SynthesizeHUDPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.exitCb = nil
	self.machine = nil
	self.isProduceEnable = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.exitCb = data.exitCb
	self.machine = data.machine
end

function M:OnEnable()
	self.bindData.btnExit:SetActive(true)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	if not self.isProduceEnable then
		return
	end

	self.machine:EnableTubeFocus(SGUI.GameDevice.KeyboardMouse < device)
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PRODUCE_INTERACTION_CHANGE] = function (_, enable)
			self.bindData.interactiveCtrl = enable and 1 or 0
			self.isProduceEnable = enable

			if enable then
				self:ResetLayout()
			end
		end
	}
end

function M:RegisterWidget()
	self.bindData.btn1.luaPress = self:CreateAction("OnPressBtn1")
	self.bindData.btn2.luaPress = self:CreateAction("OnPressBtn2")
	self.bindData.btn3.luaPress = self:CreateAction("OnPressBtn3")
	self.bindData.btn4.luaPress = self:CreateAction("OnPressBtn4")
	self.bindData.btn1.luaRelease = self:CreateAction("OnReleaseBtn1")
	self.bindData.btn2.luaRelease = self:CreateAction("OnReleaseBtn2")
	self.bindData.btn3.luaRelease = self:CreateAction("OnReleaseBtn3")
	self.bindData.btn4.luaRelease = self:CreateAction("OnReleaseBtn4")
	self.bindData.btnReset.luaClick = self:CreateAction("OnClickBtnReset")
	self.bindData.btnReselect.luaClick = self:CreateAction("OnClickBtnReselect")
	self.bindData.btnExecution.luaClick = self:CreateAction("OnClickBtnExecution")
	self.bindData.btnExit.luaClick = self:CreateAction("OnClickBtnExit")
	self.bindData.btnJoyStickExecution.luaBeginLongPress = self:CreateAction("OnPressBtnJoyStickExecution")
	self.bindData.btnJoyStickExecution.luaEndLongPress = self:CreateAction("OnReleaseBtnJoyStickExecution")
	self.bindData.btnJoySelectLeft.luaClick = self:CreateAction("OnClickBtnJoySelectLeft")
	self.bindData.btnJoySelectRight.luaClick = self:CreateAction("OnClickBtnJoySelectRight")
end

function M:OnPressBtn1()
	gProduceManager:ClickFirstButton()
end

function M:OnPressBtn2()
	gProduceManager:ClickSecButton()
end

function M:OnPressBtn3()
	gProduceManager:ClickTrdButton()
end

function M:OnPressBtn4()
	gProduceManager:ClickFourButton()
end

function M:OnReleaseBtn1()
	gProduceManager:ClickFirstButtonRelease()
end

function M:OnReleaseBtn2()
	gProduceManager:ClickSecButtonRelease()
end

function M:OnReleaseBtn3()
	gProduceManager:ClickTrdButtonRelease()
end

function M:OnReleaseBtn4()
	gProduceManager:ClickFourButtonRelease()
end

function M:OnPressBtnJoyStickExecution()
	if self.machine then
		self.machine:OnFocusButtonClickDown()
	end
end

function M:OnReleaseBtnJoyStickExecution()
	if self.machine then
		self.machine:OnFocusButtonClickRelease()
	end
end

function M:OnClickBtnReset()
	gProduceManager:OnMachineReset()
end

function M:OnClickBtnReselect()
	gProduceManager:ReSelectStart()
end

function M:OnClickBtnExecution()
	local time = self.machine:PlayStartTriggerAni()
	self.bindData.interactiveCtrl = 0

	self.bindData.btnExit:SetActive(false)
	gLuaTimeMgrUtils.Delay(function ()
		gProduceManager:OnMachineBeginMake()
	end, time)
end

function M:OnClickBtnExit()
	gProduceManager:ReSelectStart()
end

function M:OnClickBtnJoySelectLeft()
	if self.machine then
		self.machine:FocusNextTube(false)
	end
end

function M:OnClickBtnJoySelectRight()
	if self.machine then
		self.machine:FocusNextTube(true)
	end
end

local tmpVec = Vector2.zero

function M:GetUIPotion(trans)
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(trans.position, gCS.CameraDataMgr.ActiveCamera, 0, 0, 0)

	tmpVec:Set(x, y)

	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, tmpVec)

	return uiPos
end

function M:ResetLayout()
	self.bindData.btn1.localPosition = self:GetUIPotion(self.machine.buttonOne.transform)
	self.bindData.btn2.localPosition = self:GetUIPotion(self.machine.buttonTwo.transform)
	self.bindData.btn3.localPosition = self:GetUIPotion(self.machine.buttonThree.transform)
	self.bindData.btn4.localPosition = self:GetUIPotion(self.machine.buttonFour.transform)
	self.bindData.btnReselect.localPosition = self:GetUIPotion(self.machine.buttonReselect.transform)
	self.bindData.btnReset.localPosition = self:GetUIPotion(self.machine.buttonReset.transform)
	self.bindData.btnExecution.localPosition = self:GetUIPotion(self.machine.buttonExecution.transform)
end
