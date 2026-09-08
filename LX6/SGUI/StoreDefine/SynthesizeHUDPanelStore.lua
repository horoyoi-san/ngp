-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SynthesizeHUDPanelStore.lua
-- Decompiled from: 01347_SynthesizeHUDPanelStore.lua_14ebe47a3b1f.luajit

C_SynthesizeHUDPanelStore = DefClass("C_SynthesizeHUDPanelStore", C_SynthesizeHUDPanelStore, C_StoreGroup)
GroupName2Class.SynthesizeHUDPanelStore = C_SynthesizeHUDPanelStore
local M = C_SynthesizeHUDPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.exitCb = nil
	self.machine = nil
	self.isProduceEnable = false
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.exitCb = data.exitCb
	self.machine = data.machine
end

M.OnEnable = function(self)
	self.bindData.btnExit:SetActive(true)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	if not self.isProduceEnable then
		return
	end

	self.machine:EnableTubeFocus(SGUI.GameDevice.KeyboardMouse <= device)
	self.machine:StopShake()
end

M.GenMessageEvents = function(self)
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

M.RegisterWidget = function(self)
	self.bindData.btn1.luaPress = self.CreateAction(self, "OnPressBtn1")
	self.bindData.btn2.luaPress = self.CreateAction(self, "OnPressBtn2")
	self.bindData.btn3.luaPress = self.CreateAction(self, "OnPressBtn3")
	self.bindData.btn4.luaPress = self.CreateAction(self, "OnPressBtn4")
	self.bindData.btn1.luaRelease = self.CreateAction(self, "OnReleaseBtn1")
	self.bindData.btn2.luaRelease = self.CreateAction(self, "OnReleaseBtn2")
	self.bindData.btn3.luaRelease = self.CreateAction(self, "OnReleaseBtn3")
	self.bindData.btn4.luaRelease = self.CreateAction(self, "OnReleaseBtn4")
	self.bindData.btnReset.luaClick = self.CreateAction(self, "OnClickBtnReset")
	self.bindData.btnReselect.luaClick = self.CreateAction(self, "OnClickBtnReselect")
	self.bindData.btnExecution.luaClick = self.CreateAction(self, "OnClickBtnExecution")
	self.bindData.btnExit.luaClick = self.CreateAction(self, "OnClickBtnExit")
	self.bindData.btnJoyStickExecution.luaBeginLongPress = self.CreateAction(self, "OnPressBtnJoyStickExecution")
	self.bindData.btnJoyStickExecution.luaEndLongPress = self.CreateAction(self, "OnReleaseBtnJoyStickExecution")
	self.bindData.btnJoySelectLeft.luaClick = self.CreateAction(self, "OnClickBtnJoySelectLeft")
	self.bindData.btnJoySelectRight.luaClick = self.CreateAction(self, "OnClickBtnJoySelectRight")
	self.bindData.customRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftJoyStickMove")
end

M.OnPressBtn1 = function(self)
	gProduceManager:ClickFirstButton()
end

M.OnPressBtn2 = function(self)
	gProduceManager:ClickSecButton()
end

M.OnPressBtn3 = function(self)
	gProduceManager:ClickTrdButton()
end

M.OnPressBtn4 = function(self)
	gProduceManager:ClickFourButton()
end

M.OnReleaseBtn1 = function(self)
	gProduceManager:ClickFirstButtonRelease()
end

M.OnReleaseBtn2 = function(self)
	gProduceManager:ClickSecButtonRelease()
end

M.OnReleaseBtn3 = function(self)
	gProduceManager:ClickTrdButtonRelease()
end

M.OnReleaseBtn4 = function(self)
	gProduceManager:ClickFourButtonRelease()
end

M.OnPressBtnJoyStickExecution = function(self)
	if self.machine then
		self.machine:OnFocusButtonClickDown()
	end
end

M.OnReleaseBtnJoyStickExecution = function(self)
	if self.machine then
		self.machine:OnFocusButtonClickRelease()
	end
end

M.OnClickBtnReset = function(self)
	gProduceManager:OnMachineReset()
end

M.OnClickBtnReselect = function(self)
	gProduceManager:ReSelectStart()
end

M.OnClickBtnExecution = function(self)
	slot1 = self.machine
	local time = slot1:PlayStartTriggerAni()
	self.bindData.interactiveCtrl = 0
	slot2 = self.bindData.btnExit

	slot2:SetActive(false)
	gLuaTimeMgrUtils.Delay(function ()
		gProduceManager:OnMachineBeginMake()
	end, time)
end

M.OnClickBtnExit = function(self)
	gProduceManager:ReSelectStart()
end

M.OnClickBtnJoySelectLeft = function(self)
	if self.machine then
		self.machine:FocusNextTube(false)
	end
end

M.OnClickBtnJoySelectRight = function(self)
	if self.machine then
		self.machine:FocusNextTube(true)
	end
end

M.OnLeftJoyStickMove = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed and math.abs(value.x) <= 0.8 and not self.isDoneMove then
		self.isDoneMove = true

		if value.x <= 0 then
			self.OnClickBtnJoySelectRight(self)
		else
			self.OnClickBtnJoySelectLeft(self)
		end
	end

	if context.canceled then
		self.isDoneMove = false
	end
end

local tmpVec = Vector2.zero

M.GetUIPotion = function(self, trans)
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(trans.position, gCS.CameraDataMgr.ActiveCamera, 0, 0, 0)

	tmpVec:Set(x, y)

	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, tmpVec)

	return uiPos
end

M.ResetLayout = function(self)
	self.bindData.btn1.localPosition = self.GetUIPotion(self, self.machine.buttonOne.transform)
	self.bindData.btn2.localPosition = self.GetUIPotion(self, self.machine.buttonTwo.transform)
	self.bindData.btn3.localPosition = self.GetUIPotion(self, self.machine.buttonThree.transform)
	self.bindData.btn4.localPosition = self.GetUIPotion(self, self.machine.buttonFour.transform)
	self.bindData.btnReselect.localPosition = self.GetUIPotion(self, self.machine.buttonReselect.transform)
	self.bindData.btnReset.localPosition = self.GetUIPotion(self, self.machine.buttonReset.transform)
	self.bindData.btnExecution.localPosition = self.GetUIPotion(self, self.machine.buttonExecution.transform)
end
