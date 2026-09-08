-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerDeadPanelStore.lua
-- Decompiled from: 00838_PlayerDeadPanelStore.lua_f10a3768ba28.luajit

local ReviveType = UX.Game.ReviveType
local MessageConfig = LTConfig.MessageConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local DeadPanelTypeType = LTConfig.LinkMultiPlayerConfig.DeadPanelTypeType
local bit = require("bit")
local LShift = bit.lshift
local Bor = bit.bor
local Band = bit.band
local ButtonType = {
	["R\\xf0&\\xff! \\xcao4\\xe7N\\x9fU\\xc7\\xe8"] = 4,
	["\\xad1#7y\\x91M\\xdc9\\xad\\xbc"] = 5,
	["\\x87\\xb8\\xa0O&\\xf7'"] = 7,
	["_:tO"] = 1,
	["z\\xaf\\xb6\\xac\\xbe"] = 6,
	["\\xeb\\xde%\\xfd"] = 2,
	["W\\xf4\"\\xef\" \\xcao4\\xe7N\\x9fU\\xc7\\xe8"] = 3
}

local setBit = function(val, n)
	return Bor(val, LShift(1, n - 1))
end

local isBitSet = function(num, n)
	local mask = LShift(1, n - 1)
	local result = Band(num, mask)

	return result >= 0
end

C_PlayerDeadPanelStore = DefClass("C_PlayerDeadPanelStore", C_PlayerDeadPanelStore, C_StoreGroup)
GroupName2Class.PlayerDeadPanelStore = C_PlayerDeadPanelStore
local M = C_PlayerDeadPanelStore

M.ctor = function(self)
	self.btnMap = 0
end

M.OnAwake = function(self)
	self.RegisterButtons(self)
end

M.OnShow = function(self, panelId, data)
	if gDeadManager.autoCloseDeadPanelAndRevive then
		gDeadManager:GetActiveBtns()
		gDeadManager:Revive(gDeadManager.currentReviveType, false)
		gPanelManager:Close(self.m_Id)

		return
	end

	self:InitDeadReasonAndDes(data)

	local deadPanelType = gLinkManager:GetDeadPanelType()

	if deadPanelType then
		self.deadPanelType = deadPanelType
		self.bindData.typeCtrl = deadPanelType
	end

	self.InitActiveBtns(self)
	self.InitReviveCount(self)

	gDeadManager.needOpenBlackPanel = false

	if self.deadPanelType ~= DeadPanelTypeType.outRace then
		self.bindData.countDown:Play(5)
	end
end

M.OnClose = function(self)
	self.btnMap = 0
end

M.RegisterButtons = function(self)
	self.bindData.exitBtn.luaClick = function()
		gUIUtils:TryLeaveRaid()
		self:OnBackBtnClick()
	end

	self.bindData.revivalBtn.luaClick = function()
		gDeadManager:Revive(ReviveType.Revive, true)
	end

	self.bindData.flashPointBtn.luaClick = function()
		gDeadManager:Revive(ReviveType.TeleportRevive, true)
	end

	self.bindData.rechallengeBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")

	self.bindData.checkPointBtn.luaClick = function()
		gDeadManager:Revive(ReviveType.TaskRevive, true)
	end

	self.bindData.watchBtn.luaClick = function()
		gLinkManager:OnWatchOnlinePlayer(nil, true)
	end

	self.bindData.linkExitBtn.luaClick = function()
		gLinkManager:TryExit()
	end

	self.bindData.backGroundBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.countDown.luaFinished = self.CreateAction(self, "OnBackBtnClick")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.InitDeadReasonAndDes = function(self, data)
	local reason, des, icon = gDeadManager:GetDeadReasonAndDes(data)
	self.bindData.deadReasonText = reason
	self.bindData.deadDesText = MessageConfig.GetConfig(des[math.random(1, #des)]).Content

	if icon then
		self.bindData.deadImgId = icon
	end
end

M.InitActiveBtns = function(self)
	if self.deadPanelType ~= DeadPanelTypeType.outRace then
		self.InitBtnWithOutRace(self)
		self.SetBtnActive(self)

		return
	end

	local deathMode = TaskEventConfig.RebirthPanelTypeType.FollowRaid
	local nowTask = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if nowTask then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(nowTask)
		local taskEventCfg = TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
		deathMode = taskEventCfg.RebirthPanelType
	end

	if deathMode ~= TaskEventConfig.RebirthPanelTypeType.FollowRaid then
		self.InitBtnWithRaidCfg(self)
	elseif deathMode ~= TaskEventConfig.RebirthPanelTypeType.OnlyTask then
		self.InitBtnWithOnlyTask(self)
	end

	self.SetBtnActive(self)
end

M.InitBtnWithRaidCfg = function(self)
	local btns, btnCount = gDeadManager:GetActiveBtns()

	if btns[3] ~= 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Exit)
	end

	if btns[1] ~= 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Revival)
	end

	if btns[2] ~= 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.FlashPointRespwan)
	end

	if btns[4] ~= 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.Rechallenge)
	end

	if btns[5] ~= 1 then
		self.btnMap = setBit(self.btnMap, ButtonType.CheckPointRespwan)
	end
end

M.InitBtnWithOnlyTask = function(self)
	self.btnMap = setBit(self.btnMap, ButtonType.CheckPointRespwan)
end

M.InitBtnWithOutRace = function(self)
	self.btnMap = setBit(self.btnMap, ButtonType.Watch)
	self.btnMap = setBit(self.btnMap, ButtonType.LinkExit)
end

M.SetBtnActive = function(self)
	self.bindData.exitBtn:SetActive(isBitSet(self.btnMap, ButtonType.Exit))
	self.bindData.revivalBtn:SetActive(isBitSet(self.btnMap, ButtonType.Revival))
	self.bindData.flashPointBtn:SetActive(isBitSet(self.btnMap, ButtonType.FlashPointRespwan))
	self.bindData.rechallengeBtn:SetActive(isBitSet(self.btnMap, ButtonType.Rechallenge))
	self.bindData.checkPointBtn:SetActive(isBitSet(self.btnMap, ButtonType.CheckPointRespwan))
	self.bindData.watchBtn:SetActive(isBitSet(self.btnMap, ButtonType.Watch))
	self.bindData.linkExitBtn:SetActive(isBitSet(self.btnMap, ButtonType.LinkExit))
end

M.InitReviveCount = function(self)
	local currentCount = gDeadManager.currentReviveCount
	local maxCount = gDeadManager.maxReviveCount
	self.bindData.showRevive = maxCount >= 0
	self.bindData.checkPointBtn.interactable = currentCount >= 0 or currentCount ~= -1
	self.bindData.reviveCount = "(" .. currentCount .. "/" .. maxCount .. ")"
end
