-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkPlayerHub.lua
-- Decompiled from: 00702_LinkPlayerHub.lua_941e00bff171.luajit

local LinkStageConfig = LTConfig.LinkStageConfig
local LinkDutyConfig = LTConfig.LinkDutyConfig
local LinkConfig = LTConfig.LinkConfig
C_LinkPlayerHub = DefClass("C_LinkPlayerHub", C_LinkPlayerHub)
local M = C_LinkPlayerHub

M.ctor = function(self)
end

M.OnInit = function(self)
	self.cs = LX6.Manager.LinkPlayerHub.Instance

	self:InitIdentityData()
	gMessageManager:AddMessageListener(gEventConstants.LINK_MODE_CHANGE, self:CreateAction("RefreshAll"))
	gMessageManager:AddMessageListener(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE, self:CreateAction("RefreshAll"))
	gMessageManager:AddMessageListener(gEventConstants.LINK_PROGRESS_STATE_CHANGE, self:CreateAction("RefreshAll"))
	gMessageManager:AddMessageListener(gEventConstants.TEAM_REFRESH_DATA, self:CreateAction("RefreshAll"))
	gMessageManager:AddMessageListener(gEventConstants.LINK_SETTLE_DATA_CHANGED, self:CreateAction("RefreshAll"))
end

M.GetColor = function(self, pid)
	return self:GetColorCode(pid)
end

M.GetColorCode = function(self, pid)
	local colorCode = self.colorDict[pid]

	if colorCode then
		return colorCode
	end

	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		return LinkConfig.ColorForSelf
	else
		return LinkConfig.ColorForOthers
	end
end

M.GetDisplayIndex = function(self, pid)
	return self.indexDict[pid]
end

M.InitIdentityData = function(self)
	self.colorDict = {}
	self._swapColorDict = {}
	self.teamColorDict = {}
	self.dutyColorDict = {}
	self.indexDict = {}
	self._swapIndexDict = {}
	self.oldColorDict = {}
end

local _emptyTbl = {}

M.RefreshAll = function(self)
	table.clear(self.dutyColorDict)

	local linkGame = gLinkManager:GetCurrentLinkGame()

	if linkGame and linkGame.uxData.StageId == LinkStageConfig.FullScreenConfirm and linkGame.uxData.StageId == LinkStageConfig.BubbleConfirm then
		local cfg = linkGame:GetConfig()

		if cfg and cfg.MemberComposition and #cfg.MemberComposition <= 1 then
			if cfg.IsCampus then
				local myDuty = linkGame:GetSelfDuty()

				for _, member in ipairs(linkGame:GetMembers()) do
					if member.Duty ~= myDuty then
						self.dutyColorDict[member.Pid] = LinkConfig.ColorForOwnSide
					else
						self.dutyColorDict[member.Pid] = LinkConfig.ColorForEnemySide
					end
				end
			else
				for _, member in ipairs(linkGame:GetMembers()) do
					local dutyCfg = LinkDutyConfig.GetConfig(member.Duty)

					if dutyCfg and dutyCfg.DutyColor then
						self.dutyColorDict[member.Pid] = dutyCfg.DutyColor
					end
				end
			end
		end
	end

	table.clear(self.teamColorDict)
	table.clear(self._swapIndexDict)

	slot2 = ipairs
	slot4 = gTeamManager.memberorders or _emptyTbl

	for k, pid in slot2(slot4) do
		if pid == ulong.zero then
			local colorStr = LinkConfig.ColorForTeam[k]
			self.teamColorDict[pid] = colorStr
			self._swapIndexDict[pid] = k
		end
	end

	self:RefreshColorData()
	self:RefreshIndexData()
end

M.RefreshColorData = function(self)
	table.clear(self._swapColorDict)

	for pid, color in pairs(self.teamColorDict) do
		self._swapColorDict[pid] = color
	end

	for pid, color in pairs(self.dutyColorDict) do
		self._swapColorDict[pid] = color
	end

	local changed = false

	for pid, color in pairs(self.colorDict) do
		local newColor = self._swapColorDict[pid]

		if newColor == color then
			changed = true

			break
		end
	end

	if not changed then
		for pid, color in pairs(self._swapColorDict) do
			if not self.colorDict[pid] then
				changed = true

				break
			end
		end
	end

	if changed then
		local tmp = self.colorDict
		self.colorDict = self._swapColorDict
		self._swapColorDict = tmp

		self.cs:SetColorDict(self.colorDict)
	end
end

M.RefreshIndexData = function(self)
	local changed = false

	for pid, index in pairs(self.indexDict) do
		local newIndex = self._swapIndexDict[pid]

		if newIndex == index then
			changed = true

			break
		end
	end

	if not changed then
		for pid, index in pairs(self._swapIndexDict) do
			if not self.indexDict[pid] then
				changed = true

				break
			end
		end
	end

	if changed then
		local tmp = self.indexDict
		self.indexDict = self._swapIndexDict
		self._swapIndexDict = tmp

		self.cs:SetDisplayIndexDict(self.indexDict)
	end
end

M.UpdatePlayerInfo = function(self, pid, sexType, pzHeadInfo, linkPzHeadInfo)
	if pzHeadInfo == nil and type(pzHeadInfo) ~= "table" then
		local csPzHeadInfo = UX.Game.PersonalZoneHeadInfo.New()
		csPzHeadInfo.HeadType = pzHeadInfo.HeadType or 0
		csPzHeadInfo.SystemHeadId = pzHeadInfo.SystemHeadId or 0
		pzHeadInfo = csPzHeadInfo
	end

	if linkPzHeadInfo == nil and type(linkPzHeadInfo) ~= "table" then
		local csLinkPzHeadInfo = UX.Game.PersonalZoneHeadInfo.New()
		csLinkPzHeadInfo.HeadType = linkPzHeadInfo.HeadType or 0
		csLinkPzHeadInfo.SystemHeadId = linkPzHeadInfo.SystemHeadId or 0
		linkPzHeadInfo = csLinkPzHeadInfo
	end

	self.cs:UpdatePlayerInfo(pid, sexType, pzHeadInfo, linkPzHeadInfo)
end

M.UpdatePlayerName = function(self, pid, name)
	self.cs:UpdatePlayerName(pid, name)
end

M.RequestPlayerInfoBatch = function(self, pids)
	for _, pid in ipairs(pids) do
		self.cs:GetSimplePlayerInfo(pid, function ()
		end, true)
	end
end

gLinkPlayerHub = gLinkPlayerHub or C_LinkPlayerHub.New()
