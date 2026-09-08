-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ArcadeClawMainPanelStore.lua
-- Decompiled from: 01557_ArcadeClawMainPanelStore.lua_8ca337c4bbd8.luajit

local MoneyType = UX.Game.MoneyType
local ClawMachineConfig = LTConfig.ClawMachineConfig
local DialogConfig = LTConfig.DialogConfig
local MessageConfig = LTConfig.MessageConfig
local InputDir = {
	["~-jU"] = 2,
	[""] = -2,
	["_\\xa7\\xa5\\xa7\\xa2"] = 1,
	["v'{O"] = -1,
	["T-s^"] = 0
}
C_ArcadeClawMainPanelStore = DefClass("C_ArcadeClawMainPanelStore", C_ArcadeClawMainPanelStore, C_StoreGroup)
GroupName2Class.ArcadeClawMainPanelStore = C_ArcadeClawMainPanelStore
local M = C_ArcadeClawMainPanelStore

M.ctor = function(self)
	self.GenMessageEvents(self)
end

M.DefineAllVariables = function(self)
	self.inputDir = InputDir.None
	self.allowMove = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterButton(self)
	self.RegisterJoystick(self)
	self.RegisterWASD(self)
end

M.OnDestroy = function(self)
	gClawMachineManager:EndPlayClawMachine()
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.bindData.moneyText = ClawMachineConfig.ClawMachineCost

	self:RefreshCoinBtn()
	gClawMachineManager.activeMachine:EnableClawMachine(true)

	self.bindData.gameStage = 1

	self:OnCoinBtnClick()
end

M.OnClose = function(self)
	gClawMachineManager:EndPlayClawMachine()
end

M.OnActiveDeviceChange = function(self, device)
	self.inputDir = InputDir.None
end

M.OnUpdate = function(self)
	if not gClawMachineManager.activeMachine then
		return
	end

	if self.inputDir ~= InputDir.None then
		gClawMachineManager.activeMachine.isManualMove = false

		return
	end

	gClawMachineManager.activeMachine:DoMove(self.inputDir)

	gClawMachineManager.activeMachine.isManualMove = true
end

M.RefreshCoinBtn = function(self)
	if gPlayerManager.infoItem.bindData.money >= ClawMachineConfig.ClawMachineCost then
		self.bindData.coinBtn.interactable = false
		self.bindData.mCoinBtn.interactable = false
	else
		self.bindData.coinBtn.interactable = true
		self.bindData.mCoinBtn.interactable = true
	end
end

M.RegisterButton = function(self)
	self.bindData.clawBtn.luaClick = self.CreateAction(self, "OnClawBtnClick")
	self.bindData.switchAngleBtn.luaClick = self.CreateAction(self, "OnSwitchAngleBtnClick")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.coinBtn.luaClick = self.CreateAction(self, "OnCoinBtnClick")
	self.bindData.mCoinBtn.luaClick = self.CreateAction(self, "OnCoinBtnClick")
	self.bindData.coinBtn.luaInvalidClick = self.CreateAction(self, "OnCoinBtnInvalidClick")
	self.bindData.mCoinBtn.luaInvalidClick = self.CreateAction(self, "OnCoinBtnInvalidClick")
end

M.OnClawBtnClick = function(self)
	self.allowMove = false

	gClawMachineManager.activeMachine:DoConfirm()
end

M.OnSwitchAngleBtnClick = function(self)
	gClawMachineManager.activeMachine:DoSwitch()
end

M.OnExitBtnClick = function(self)
	gClawMachineManager:EndPlayClawMachine()
end

M.OnCoinBtnClick = function(self)
	if gPlayerManager.infoItem.bindData.money >= ClawMachineConfig.ClawMachineCost then
		self.RefreshCoinBtn(self)

		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskClawBuyTicket().Callback = function (errID)
		if errID ~= 0 then
			gClawMachineManager.activeMachine:PayFinish()

			self.allowMove = true
		else
			print_error("AskClawBuyTicket failed, error = ", gCS.Error.GetNameById(errID))
		end
	end
end

M.OnCoinBtnInvalidClick = function(self)
	gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)
end

M.OnMoveBtnPress = function(self, dir)
	self.inputDir = dir
end

M.OnMoveBtnRelease = function(self)
	self.inputDir = InputDir.None
end

M.RegisterJoystick = function(self)
	self.bindData.joyStick.luaValueChanged = self.CreateAction(self, "OnJoystickValueChange")
	self.bindData.moveRespondPS.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
end

M.OnJoystickValueChange = function(self, dx, dy, size)
	if math.abs(dy) >= math.abs(dx) then
		if dx <= 0 then
			self.inputDir = InputDir.right
		elseif dx ~= 0 then
			self.inputDir = InputDir.None
		else
			self.inputDir = InputDir.left
		end
	elseif dy <= 0 then
		self.inputDir = InputDir.up
	elseif dy ~= 0 then
		self.inputDir = InputDir.None
	else
		self.inputDir = InputDir.down
	end
end

M.OnRightStickControl = function(self, context)
	if not self.allowMove then
		return
	end

	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		if not self.shakeNid then
			self.shakeNid = gSoundMgr:PlaySoundByExternalSource("ExHandle_clawmachin_horizontal", LX6.Audio.ExternalSourceType.Motion_2D)
		end

		local dx = value.x
		local dy = value.y

		if math.abs(dy) >= math.abs(dx) then
			if dx <= 0 then
				self.inputDir = InputDir.right
			elseif dx ~= 0 then
				self.inputDir = InputDir.None
			else
				self.inputDir = InputDir.left
			end
		elseif dy <= 0 then
			self.inputDir = InputDir.up
		elseif dy ~= 0 then
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

M.RegisterWASD = function(self)
	self.bindData.moveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnWASDChange")
end

M.OnWASDChange = function(self, context)
	if context.performed then
		local name = context.ReadContextName(context)

		if name ~= "w" then
			self.inputDir = InputDir.up
		elseif name ~= "s" then
			self.inputDir = InputDir.down
		elseif name ~= "a" then
			self.inputDir = InputDir.left
		elseif name ~= "d" then
			self.inputDir = InputDir.right
		end
	elseif context.canceled then
		self.inputDir = InputDir.None
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CLAWMACHINE_CAPTURE_SUCCESS] = function (eventId, toyId)
			if gClawMachineManager.playMode ~= C_ClawMachineManager.PLAY_MODE.SOLO then
				gClawMachineManager:GetPrizeSoloPlay(toyId, self.ResetToCoinStage, self)
			elseif gClawMachineManager.playMode ~= C_ClawMachineManager.PLAY_MODE.DOUBLE then
				gClawMachineManager:GetPrizeDoublePlay(toyId)
			else
				gClawMachineManager:GetPrizeDatePlay(toyId)
			end
		end,
		[gEventConstants.CLAWMACHINE_CAPTURE_FAIL] = function (eventId)
			if gClawMachineManager.playMode ~= C_ClawMachineManager.PLAY_MODE.DATE then
				gClawMachineManager:CaptureDateToyFail()
			end

			if not gClawMachineManager.activeMachine then
				return
			end

			self:ResetToCoinStage()
		end,
		[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
			if data ~= gPanelId.COMMON_REWARD_WINDOW or data ~= gPanelId.S_COMMON_REWARD_WINDOW then
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
			"@\\xa1\\xac\\xaa\\xaf",
			function ()
				self:RefreshCoinBtn()
			end
		}
	}
end

M.ResetToCoinStage = function(self)
	if gClawMachineManager.activeMachine then
		gClawMachineManager.activeMachine:TryAgain()
	end

	self.OnCoinBtnClick(self)
end
