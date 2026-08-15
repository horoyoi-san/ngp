local MoneyType = UX.Game.MoneyType
local ClawMachineConfig = LTConfig.ClawMachineConfig
local DialogConfig = LTConfig.DialogConfig
local MessageConfig = LTConfig.MessageConfig
local InputDir = {
	down = 2,
	up = -2,
	right = 1,
	left = -1,
	None = 0
}
C_ArcadeClawMainPanelStore = DefClass("C_ArcadeClawMainPanelStore", C_ArcadeClawMainPanelStore, C_StoreGroup)
GroupName2Class.ArcadeClawMainPanelStore = C_ArcadeClawMainPanelStore
local M = C_ArcadeClawMainPanelStore

function M:ctor()
	self:GenMessageEvents()
end

function M:DefineAllVariables()
	self.inputDir = InputDir.None
	self.allowMove = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButton()
	self:RegisterJoystick()
	self:RegisterWASD()
end

function M:OnDestroy()
	gClawMachineManager:EndPlayClawMachine()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
	self:ClearDataSetEvents()
end

function M:OnShow(panelId, data)
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.bindData.moneyText = ClawMachineConfig.ClawMachineCost

	self:RefreshCoinBtn()
	gClawMachineManager.activeMachine:EnableClawMachine(true)

	self.bindData.gameStage = 1

	self:OnCoinBtnClick()
end

function M:OnClose()
	gClawMachineManager:EndPlayClawMachine()
end

function M:OnActiveDeviceChange(device)
	self.inputDir = InputDir.None
end

function M:OnUpdate()
	if not gClawMachineManager.activeMachine then
		return
	end

	if self.inputDir == InputDir.None then
		gClawMachineManager.activeMachine.isManualMove = false

		return
	end

	gClawMachineManager.activeMachine:DoMove(self.inputDir)

	gClawMachineManager.activeMachine.isManualMove = true
end

function M:RefreshCoinBtn()
	if gPlayerManager.infoItem.bindData.money < ClawMachineConfig.ClawMachineCost then
		self.bindData.coinBtn.interactable = false
		self.bindData.mCoinBtn.interactable = false
	else
		self.bindData.coinBtn.interactable = true
		self.bindData.mCoinBtn.interactable = true
	end
end

function M:RegisterButton()
	self.bindData.clawBtn.luaClick = self:CreateAction("OnClawBtnClick")
	self.bindData.switchAngleBtn.luaClick = self:CreateAction("OnSwitchAngleBtnClick")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.coinBtn.luaClick = self:CreateAction("OnCoinBtnClick")
	self.bindData.mCoinBtn.luaClick = self:CreateAction("OnCoinBtnClick")
	self.bindData.coinBtn.luaInvalidClick = self:CreateAction("OnCoinBtnInvalidClick")
	self.bindData.mCoinBtn.luaInvalidClick = self:CreateAction("OnCoinBtnInvalidClick")
end

function M:OnClawBtnClick()
	self.allowMove = false

	gClawMachineManager.activeMachine:DoConfirm()
end

function M:OnSwitchAngleBtnClick()
	gClawMachineManager.activeMachine:DoSwitch()
end

function M:OnExitBtnClick()
	gClawMachineManager:EndPlayClawMachine()
end

function M:OnCoinBtnClick()
	gClientToGameDelegate:AskClawBuyTicket().Callback = function (errID)
		if errID == 0 then
			gClawMachineManager.activeMachine:PayFinish()

			self.allowMove = true
		else
			print_error("AskClawBuyTicket failed, error = ", gCS.Error.GetNameById(errID))
		end
	end
end

function M:OnCoinBtnInvalidClick()
	gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)
end

function M:OnMoveBtnPress(dir)
	self.inputDir = dir
end

function M:OnMoveBtnRelease()
	self.inputDir = InputDir.None
end

function M:RegisterJoystick()
	self.bindData.joyStick.luaValueChanged = self:CreateAction("OnJoystickValueChange")
	self.bindData.moveRespondPS.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnJoystickValueChange(dx, dy, size)
	if math.abs(dy) < math.abs(dx) then
		if dx > 0 then
			self.inputDir = InputDir.right
		elseif dx == 0 then
			self.inputDir = InputDir.None
		else
			self.inputDir = InputDir.left
		end
	elseif dy > 0 then
		self.inputDir = InputDir.up
	elseif dy == 0 then
		self.inputDir = InputDir.None
	else
		self.inputDir = InputDir.down
	end
end

function M:OnRightStickControl(context)
	if not self.allowMove then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		if not self.shakeNid then
			self.shakeNid = gSoundMgr:PlaySoundByExternalSource("ExHandle_clawmachin_horizontal", LX6.Audio.ExternalSourceType.Motion_2D)
		end

		local dx = value.x
		local dy = value.y

		if math.abs(dy) < math.abs(dx) then
			if dx > 0 then
				self.inputDir = InputDir.right
			elseif dx == 0 then
				self.inputDir = InputDir.None
			else
				self.inputDir = InputDir.left
			end
		elseif dy > 0 then
			self.inputDir = InputDir.up
		elseif dy == 0 then
			self.inputDir = InputDir.None
		else
			self.inputDir = InputDir.down
		end
	end

	if context.canceled then
		if self.shakeNid then
			gSoundMgr:StopSoundByNid(self.shakeNid)

			self.shakeNid = nil
		end

		self.inputDir = InputDir.None
	end
end

function M:RegisterWASD()
	self.bindData.moveRespond.luaGamePadInputChanged = self:CreateAction("OnWASDChange")
end

function M:OnWASDChange(context)
	if context.performed then
		local name = context:ReadContextName()

		if name == "w" then
			self.inputDir = InputDir.up
		elseif name == "s" then
			self.inputDir = InputDir.down
		elseif name == "a" then
			self.inputDir = InputDir.left
		elseif name == "d" then
			self.inputDir = InputDir.right
		end
	elseif context.canceled then
		self.inputDir = InputDir.None
	end
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.CLAWMACHINE_CAPTURE_SUCCESS] = function (eventId, toyId)
			if gClawMachineManager.playMode == C_ClawMachineManager.PLAY_MODE.SOLO then
				gClawMachineManager:GetPrizeSoloPlay(toyId, self.ResetToCoinStage, self)
			elseif gClawMachineManager.playMode == C_ClawMachineManager.PLAY_MODE.DOUBLE then
				gClawMachineManager:GetPrizeDoublePlay(toyId)
			else
				gClawMachineManager:GetPrizeDatePlay(toyId)
			end
		end,
		[gEventConstants.CLAWMACHINE_CAPTURE_FAIL] = function (eventId)
			if gClawMachineManager.playMode == C_ClawMachineManager.PLAY_MODE.DATE then
				gClawMachineManager:CaptureDateToyFail()
			end

			if not gClawMachineManager.activeMachine then
				return
			end

			gClawMachineManager.activeMachine:TryAgain()
			self:ResetToCoinStage()
			self:OnCoinBtnClick()
		end,
		[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
			if data == gPanelId.COMMON_REWARD_WINDOW or data == gPanelId.S_COMMON_REWARD_WINDOW then
				if gClawMachineManager.activeMachine:CheckEmpty() then
					gClawMachineManager.activeMachine:ResetAllPrizePos()
					gDialogManager:ShowGeneralDialog(ClawMachineConfig.ArrangeDialog, gDialogSource.ClawMachine)

					local cfg = DialogConfig.GetConfig(ClawMachineConfig.ArrangeDialog)
					local time = cfg.DialogStayTime / 2

					Timer.New(function ()
						gClawMachineManager.activeMachine:TryAgain()
						self:OnCoinBtnClick()
					end, time):Start()
				else
					gClawMachineManager.activeMachine:TryAgain()
					self:OnCoinBtnClick()
				end
			end
		end
	}
	self.dataEvents = {
		{
			gPlayerManager.infoItem.bindData,
			"money",
			function ()
				self:RefreshCoinBtn()
			end
		}
	}
end

function M:ResetToCoinStage()
	if gClawMachineManager.activeMachine then
		gClawMachineManager.activeMachine:TryAgain()
	end

	self:OnCoinBtnClick()
end
