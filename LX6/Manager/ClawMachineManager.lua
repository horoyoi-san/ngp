-- Original chunk: @Lua\LuaFiles\LX6\Manager\ClawMachineManager.lua
-- Decompiled from: 00577_ClawMachineManager.lua_eae6676ea0b4.luajit

local ClawMachineConfig = LTConfig.ClawMachineConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local LayerConstants = LX6.Constants.LayerConstants
local StaticProps = {
	PLAY_MODE = {
		["^I~"] = 3,
		["8g\\xa4\\xac\\xafd"] = 2,
		["I\rQt"] = 1,
		["T\rS~"] = 0
	}
}
C_ClawMachineManager = DefClass("C_ClawMachineManager", C_ClawMachineManager, nil, StaticProps)
local M = C_ClawMachineManager

M.ctor = function(self)
	self.activeMachine = nil
	self.testOnlineMachine = nil
	self.playMode = M.PLAY_MODE.NONE
	self.hidePlayerTimer = nil
	self.npcInvited = false
	self.npcCultivationId = nil
	self.npcCfgId = nil
	self.npcWaypoint = nil
	self.npcLoadComplete = false
	self.npcRelatedMachineId = nil
	self.inviteMachineNpcId = nil
	self.dateTaskAccepted = false
	self.dateMachineNpcId = nil
	self.dateMaxFailTimes = nil
	self.dateFailTimes = nil
	self.dateToyId = nil
	self.blackRecover = false
	self.isCameraFocusNpc = false
	self.isCameraHidePlayer = false

	self.dialogBeforePlayEndCB = function(eventId)
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.dialogBeforePlayEndCB)
		self:CameraFocusNpc(false)
		self:StartPlayClawMachineById(self.npcRelatedMachineId, M.PLAY_MODE.DOUBLE)
	end

	self.dialogAfterGiveEndCB = function(eventId)
		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_END, self.dialogAfterGiveEndCB)
	end

	self.eventHandler = {
		[gEventConstants.CLAWMACHINE_INVITE_NPC] = function (eventId, npcCultivationId)
			self:InviteNpc(npcCultivationId)
		end
	}

	for event, func in pairs(self.eventHandler) do
		gMessageManager:AddMessageListener(event, func)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.Reconnect then
		return
	end

	self:EndPlayClawMachine()
	self:CameraHidePlayer(false)
	self:CameraFocusNpc(false)
	self:DestroyNpc(true)
end

M.GetMachineById = function(self, machineId)
	return gCS.ClawMachineMgr:GetClawMachineById(machineId)
end

M.StartPlayClawMachineById = function(self, machineId, playMode)
	if not machineId then
		return
	end

	self:StartPlayClawMachine(self:GetMachineById(machineId), playMode)
end

M.StartPlayClawMachine = function(self, machine, playMode)
	if not machine then
		return
	end

	self.playMode = playMode <= 0 and playMode or M.PLAY_MODE.SOLO

	if self.playMode <= 0 then
		gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ClawMachine)
	end

	self.activeMachine = machine
	self.testOnlineMachine = machine
	self.hidePlayerTimer = Timer.New(function ()
		self:CameraHidePlayer(true)

		self.hidePlayerTimer = nil
	end, ClawMachineConfig.InteractionWaitTime):Start()

	gPanelManager:CheckShow(gPanelId.S_ARCADE_CLAW_MAIN_PANEL)
end

M.EndPlayClawMachine = function(self, hidePlayer)
	if self.activeMachine then
		self.activeMachine:EnableClawMachine(false)

		self.activeMachine = nil

		if self.hidePlayerTimer then
			self.hidePlayerTimer:Stop()

			self.hidePlayerTimer = nil
		end

		if not hidePlayer then
			self:CameraHidePlayer(false)
		end

		gPanelManager:Close(gPanelId.S_ARCADE_CLAW_MAIN_PANEL)
		self:PlayExitClawMachineAnim()
	end

	self.playMode = M.PLAY_MODE.NONE

	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.ClawMachine)
end

M.GetNpcClawMachineCfg = function(self)
	if not self.npcCultivationId then
		return nil
	end

	for i = 0, ClawMachineConfig.count - 1 do
		local cfg = ClawMachineConfig.LoadAt(i)

		if cfg.Npcid ~= self.npcCultivationId then
			return cfg
		end
	end

	return nil
end

M.PlayExitClawMachineAnim = function(self)
	gInteractionManager:SetCommonInteractEnd(19)
end

M.GetPrizeSoloPlay = function(self, toyId, finishCB, panel)
	Timer.New(function ()
		gPanelManager:CheckShow(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)
		Timer.New(function ()
			gClientToGameDelegate:AskClawSettlement({
				["c\\xbe\\xa1\\x86\\xb2"] = 0,
				["^#i^"] = false,
				ClawToyId = toyId
			}).Callback = function (errId)
				if errId == 0 then
					print_error("AskClawSettlement failed, error = ", gCS.Error.GetNameById(errId))
				end

				gPanelManager:Close(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)

				if finishCB and panel then
					finishCB(panel)
				end
			end
		end, 1):Start()
	end, ClawMachineConfig.CongratulationsUIDelayTime):Start()
end

M.GetPrizeDoublePlay = function(self, toyId)
	Timer.New(function ()
		gPanelManager:CheckShow(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)
		Timer.New(function ()
			gClientToGameDelegate:AskClawSettlement({
				["^#i^"] = false,
				ClawToyId = toyId,
				NpcId = self.npcCultivationId
			}).Callback = function (errId)
				if errId ~= 0 then
					self.activeMachine:HideSeizedPrize()
					self:EndPlayClawMachine(true)
				else
					print_error("AskClawSettlement failed, error = ", gCS.Error.GetNameById(errId))
				end
			end

			gPanelManager:Close(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)
		end, 1):Start()
	end, ClawMachineConfig.CongratulationsUIDelayTime):Start()
end

M.GetPrizeDatePlay = function(self, toyId, finishCB, panel)
	Timer.New(function ()
		gPanelManager:CheckShow(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)
		Timer.New(function ()
			gClientToGameDelegate:AskClawSettlement({
				["c\\xbe\\xa1\\x86\\xb2"] = 0,
				["^#i^"] = true,
				ClawToyId = toyId
			}).Callback = function (errId)
				if errId ~= 0 then
					self.activeMachine:HideSeizedPrize()

					if toyId == self.dateToyId then
						self:CaptureDateToyFail(finishCB, panel)
					else
						self:EndPlayClawMachine()
						self:DateTaskEnd()
					end
				else
					print_error("AskClawSettlement failed, error = ", gCS.Error.GetNameById(errId))
				end

				gPanelManager:Close(gPanelId.S_ARCADE_CLAW_GOTCHA_PANEL)
			end
		end, 1):Start()
	end, ClawMachineConfig.CongratulationsUIDelayTime):Start()
end

M.InviteNpc = function(self, npcCultivationId)
	self.npcCultivationId = npcCultivationId
	local cultivationCfg = NpcCultivationConfig.GetConfig(self.npcCultivationId)
	self.npcCfgId = cultivationCfg.ClawMachineNpcid
	self.npcWaypoint = gSpoonMgr:GetWayPointByNameOrId(ClawMachineConfig.NpcWayPointName .. self.npcRelatedMachineId)
	self.npcLoadComplete = false
	self.blackRecover = false

	local stayBlackHandler = function()
		self:DestroyNpc(true)
		self:CreateNpc(function ()
			self.npcLoadComplete = true

			self:CameraHidePlayer(true)
			self:CameraFocusNpc(true)

			if self.blackRecover then
				self:ShowDialogBeforeGamePlay()
			end
		end)
	end

	local recoverBlackHandler = function()
		self.blackRecover = true

		if self.npcLoadComplete then
			self:ShowDialogBeforeGamePlay()
		end
	end

	local blackText = gString.Format(ClawMachineConfig.Dialog_AfterInvite, cultivationCfg.Name)

	gBlackScreenManager:AutoTransition(gBlackScreenId.CLAW_MACHINE_MANAGER, blackText, false, false, 0.4, 1, 0.4, stayBlackHandler, recoverBlackHandler, nil)

	self.npcInvited = true
end

M.ShowDialogBeforeGamePlay = function(self)
	gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.dialogBeforePlayEndCB)
end

M.CreateNpc = function(self, loadCompleteHandler)
	if self.npcWaypoint then
		local trans = self.npcWaypoint.transform
		local pos = trans.position
		local angle = trans.eulerAngles
		self.npc = gCS.LuaUtils.CreateLocalUnit(self.npcCfgId, pos, angle, loadCompleteHandler)
		self.npcInvited = true
	end
end

M.DestroyNpc = function(self, deep)
	if self.npcInvited then
		if deep and self.npc then
			gCS.BaseUnitUtils.DestroyAgentUnit(self.npc, true, true, false)
		end

		self.npc = nil
		self.npcInvited = false
	end
end

M.CameraHidePlayer = function(self, enable)
	if self.isCameraHidePlayer ~= enable then
		return
	end

	if enable then
		gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.S_ARCADE_CLAW_MAIN_PANEL, LayerConstants.AllWithoutPlayer)
	else
		gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_ARCADE_CLAW_MAIN_PANEL)
	end

	self.isCameraHidePlayer = enable
end

M.CameraFocusNpc = function(self, enable)
	if self.isCameraFocusNpc ~= enable then
		return
	end

	if enable then
		gCS.CameraDataMgr.cinemachineManager:EnableFocusNpcCameraAtUnit(self.npc, 3, 0, 0.5, 0.5)
	else
		gCS.CameraDataMgr.cinemachineManager:DisableFocusNpcCamera()
	end

	self.isCameraFocusNpc = enable
end

M.DateTaskBegin = function(self, data)
	self:DestroyNpc(true)

	self.dateTaskAccepted = true
	self.dateMachineNpcId = data.HideNpcId
	self.dateToyId = data.FavorToyId
	self.dateMaxFailTimes = data.FailTimes
	self.npcCultivationId = data.DateNpcId
end

M.StartPlayDateMachine = function(self, machineId)
	self.FailTimes = 0

	self:StartPlayClawMachineById(machineId, M.PLAY_MODE.DATE)
end

M.DateTaskEnd = function(self)
	self.dateTaskAccepted = false
	self.dateMachineNpcId = nil
	self.dateToyId = nil
	self.dateMaxFailTimes = nil
	self.npcCultivationId = nil
end

M.CaptureDateToyFail = function(self, finishCB, panel)
	self.FailTimes = self.FailTimes + 1

	if self.playMode ~= M.PLAY_MODE.DATE then
		gClientToGameDelegate:AskClawDateFail().Callback = function (err)
			if err == 0 then
				print_error("AskClawDateFail failed, error = ", gCS.Error.GetNameById(err))
			end
		end
	end

	if finishCB and panel then
		finishCB(panel)
	end
end

gClawMachineManager = gClawMachineManager or C_ClawMachineManager.new()
