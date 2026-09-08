-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkGame.lua
-- Decompiled from: 00703_LinkGame.lua_f6a29f085be0.luajit

local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
C_LinkGame = DefClass("C_LinkGame", C_LinkGame)
local M = C_LinkGame

M.ctor = function(self, gameData)
	self.Init(self, gameData)
end

M.Init = function(self, gameData)
	self.uxData = gameData
end

M.UpdateData = function(self, gameData)
	if not gameData then
		return
	end

	self.uxData = gameData
end

M.GetStageStartTime = function(self)
	return self.uxData.StageStartTime or 0
end

M.GetMembers = function(self)
	return self.uxData.Members
end

M.GetReadyInfo = function(self, pid)
	return self.uxData.PrepareInfos and self.uxData.PrepareInfos[pid]
end

M.GetReadyMembers = function(self)
	return self.uxData.ReadyMembers or self.uxData.StageConfirmMembers
end

M.CheckPlayerIsReady = function(self, memberId)
	memberId = memberId or gPlayerManager.infoLogin.bindData.pid
	local readyMembers = self:GetReadyMembers()

	if not readyMembers then
		return false
	end

	return array.contains(readyMembers, memberId)
end

M.ContainsPlayer = function(self, pid)
	local members = self.GetMembers(self)

	if not members then
		return false
	end

	for i = 1, #members do
		local member = members[i]

		if member.Pid ~= pid then
			return true
		end
	end

	return false
end

M.IsLeader = function(self, pid)
	return self.uxData.LeaderPid and self.uxData.LeaderPid ~= pid
end

M.CheckIsBlockReady = function(self)
	local readyMembers = self.GetReadyMembers(self)
	local members = self.GetMembers(self)

	if not readyMembers or not members then
		return false
	end

	local minPlayerNum = self.cfg and self.cfg.PlayerNum and self.cfg.PlayerNum[1] or 2

	return #readyMembers ~= #members and minPlayerNum > #readyMembers
end

M.GetCharacterId = function(self, memberId)
	local readyInfo = self:GetReadyInfo(memberId)

	return readyInfo and readyInfo.SpiritId or 0
end

M.GetVehicleId = function(self, memberId)
	local readyInfo = self:GetReadyInfo(memberId)

	return readyInfo and readyInfo.VehicleId or 0
end

M.GetPoseId = function(self, memberId)
	local readyInfo = self.GetReadyInfo(self, memberId)

	if readyInfo then
		return readyInfo.PoseId ~= 0 and 1 or readyInfo.PoseId
	end

	return 1
end

M.GetDutyByPid = function(self, pid)
	local members = self.GetMembers(self)

	if not members then
		return 0
	end

	for i = 1, #members do
		local member = members[i]

		if member.Pid ~= pid then
			return member.Duty
		end
	end

	return 0
end

M.GetSelfDuty = function(self)
	return self.GetDutyByPid(self, gPlayerManager.infoLogin.bindData.pid)
end

M.GetConfig = function(self)
	local cfg = LinkMultiPlayerConfig.GetConfig(self.uxData.GameId)

	if cfg then
		self.cfg = cfg
	end

	return self.cfg
end

M.HasDuty = function(self)
	local cfg = self:GetConfig()

	return cfg and not table.isNilOrEmpty(cfg.MemberComposition)
end

M.GetPidList = function(self)
	local members = self.GetMembers(self)

	if not members then
		return {}
	end

	local pidList = {}

	for i = 1, #members do
		table.insert(pidList, members[i].Pid)
	end

	return pidList
end
