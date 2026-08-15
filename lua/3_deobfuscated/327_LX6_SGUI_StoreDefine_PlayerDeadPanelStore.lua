local ReviveType = UX.Game.ReviveType
local MessageConfig = LTConfig.MessageConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local bit = require("bit")
local LShift = bit.lshift
local Bor = bit.bor
local Band = bit.band
local ButtonType = {
	FlashPointRespwan = 4,
	Rechallenge = 5,
	Exit = 1,
	Revival = 2,
	CheckPointRespwan = 3
}

local function setBit(val, n)
	return Bor(val, LShift(1, n - 1))
end

local function isBitSet(num, n)
	local mask = LShift(1, n - 1)
	local result = Band(num, mask)

	return result > 0
end

C_PlayerDeadPanelStore = DefClass("C_PlayerDeadPanelStore", C_PlayerDeadPanelStore, C_StoreGroup)
GroupName2Class.PlayerDeadPanelStore = C_PlayerDeadPanelStore
local M = C_PlayerDeadPanelStore

function M:ctor()
	self.btnMap = 0
end

function M:OnAwake()
	self:RegisterButtons()
end

function M:OnShow(panelId, data)
	if gDeadManager.autoCloseDeadPanelAndRevive then
		gDeadManager:GetActiveBtns()
		gDeadManager:Revive(gDeadManager.currentReviveType, false)
		gPanelManager:Close(self.m_Id)

		return
	end

	self:InitDeadReasonAndDes(data)
	self:InitActiveBtns()
	self:InitReviveCount()

	gDeadManager.needOpenBlackPanel = false
end

function M:OnClose()
	self.btnMap = 0
end

function M:RegisterButtons()
	function self.bindData.exitBtn.luaClick()
		gUIUtils:TryLeaveRaid()
		gPanelManager:Close(self.m_Id)
	end

	function self.bindData.revivalBtn.luaClick()
		gDeadManager:Revive(ReviveType.Revive, true)
	end

	function self.bindData.flashPointBtn.luaClick()
		gDeadManager:Revive(ReviveType.TeleportRevive, true)
	end

	function self.bindData.rechallengeBtn.luaClick()
		gPanelManager:Close(self.m_Id)
	end

	function self.bindData.checkPointBtn.luaClick()
		gDeadManager:Revive(ReviveType.TaskRevive, true)
	end
end

function M:InitDeadReasonAndDes(data)
	local reason, des, icon = gDeadManager:GetDeadReasonAndDes(data)
	self.bindData.deadReasonText = reason
	self.bindData.deadDesText = MessageConfig.GetConfig(des[math.random(1, #des)]).Content

	if icon then
		self.bindData.deadImgId = icon
	end
end

function M:InitActiveBtns()
	local deathMode = TaskEventConfig.RebirthPanelTypeType.FollowRaid
	local nowTask = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if nowTask then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(nowTask)
		local taskEventCfg = TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
		deathMode = taskEventCfg.RebirthPanelType
	end

	if deathMode == TaskEventConfig.RebirthPanelTypeType.FollowRaid then
		self:InitBtnWithRaidCfg()
	elseif deathMode == TaskEventConfig.RebirthPanelTypeType.OnlyTask then
		self:InitBtnWithOnlyTask()
	end

	self:SetBtnActive()
end

function M:InitBtnWithRaidCfg()
	local btns, btnCount = gDeadManager:GetActiveBtns()

	if btns[3] == 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Exit)
	end

	if btns[1] == 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Revival)
	end

	if btns[2] == 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.FlashPointRespwan)
	end

	if btns[4] == 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Rechallenge)
	end

	if btns[5] == 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.CheckPointRespwan)
	end
end

function M:InitBtnWithOnlyTask()
	self.btnMap = setBit(self.btnMap, ButtonType.CheckPointRespwan)
end

function M:SetBtnActive()
	self.bindData.exitBtn:SetActive(isBitSet(self.btnMap, ButtonType.Exit))
	self.bindData.revivalBtn:SetActive(isBitSet(self.btnMap, ButtonType.Revival))
	self.bindData.flashPointBtn:SetActive(isBitSet(self.btnMap, ButtonType.FlashPointRespwan))
	self.bindData.rechallengeBtn:SetActive(isBitSet(self.btnMap, ButtonType.Rechallenge))
	self.bindData.checkPointBtn:SetActive(isBitSet(self.btnMap, ButtonType.CheckPointRespwan))
end

function M:InitReviveCount()
	local currentCount = gDeadManager.currentReviveCount
	local maxCount = gDeadManager.maxReviveCount
	self.bindData.showRevive = maxCount > 0
	self.bindData.checkPointBtn.interactable = currentCount > 0 or currentCount == -1
	self.bindData.reviveCount = "(" .. currentCount .. "/" .. maxCount .. ")"
end
