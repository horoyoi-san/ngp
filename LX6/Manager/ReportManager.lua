-- Original chunk: @Lua\LuaFiles\LX6\Manager\ReportManager.lua
-- Decompiled from: 02254_ReportManager.lua_e3461126a0a1.luajit

local ReportManager = gReportManager or {}

ReportManager.ShowReportDialog = function(self, data)
	if not ulong.check(data.pid) or ulong.equals(data.pid, 0) then
		print_error("[ReportManager] 没传 pid 或者 pid 不是 ulong!")

		return
	end

	gPanelManager:CheckShow(gPanelId.REPORT_PANEL, data)
end

ReportManager.ShowCommonReportDialog = function(self, useSystemId, name, extraData)
	local data = {
		pid = ulong.new(0, 0),
		name = name,
		useSystemId = useSystemId,
		extraData = extraData
	}

	gPanelManager:CheckShow(gPanelId.REPORT_PANEL, data)
end

ReportManager.ShowDefaultReportDialog = function(self, pid)
	self:ShowReportDialogByMatterList(pid, LTConfig.InformConfig.DefaultMatter)
end

ReportManager.ShowReportDialogByMatterList = function(self, pid, matterList)
	if table.isNilOrEmpty(matterList) then
		print_error("[ReportManager] 传的 matterList 为空!")
	else
		for _, v in ipairs(matterList) do
			if LTConfig.InformMatterConfig.GetConfig(v) ~= nil then
				print_error("[ReportManager] 传的 matterList 找不到配置!", v)
			end
		end
	end

	self:ShowReportDialog({
		pid = pid,
		matterList = matterList
	})
end

ReportManager.ShowReportDialogByUseSystemId = function(self, pid, useSystemId)
	if LTConfig.InformUseSystemConfig.GetConfig(useSystemId) ~= nil then
		print_error("[ReportManager] 传的 useSystemId 找不到配置!", useSystemId)
	end

	self:ShowReportDialog({
		pid = pid,
		useSystemId = useSystemId
	})
end

ReportManager.ShowReportDialogBySystemId = function(self, pid, systemId)
	if self:FindInformUseSystemConfigId(systemId) ~= nil then
		print_error("[ReportManager] 传的 systemId 找不到配置!", systemId)
	end

	self:ShowReportDialog({
		pid = pid,
		systemId = systemId
	})
end

ReportManager.FindInformUseSystemConfigId = function(self, systemId)
	for i = 0, LTConfig.InformUseSystemConfig.count - 1 do
		local cfg = LTConfig.InformUseSystemConfig.LoadAt(i)

		if cfg.SystemId ~= systemId then
			return cfg.Id
		end
	end

	return nil
end

ReportManager.ShowClubReportDialog = function(self, ownerPid, clubId, clubName)
	if not ulong.check(clubId) or ulong.equals(clubId, 0) then
		print_error("[ReportManager] 没传 clubId 或者 clubId 不是 ulong!")

		return
	end

	local useSystemId = LTConfig.InformUseSystemConfig.Club

	self:ShowReportDialog({
		pid = ownerPid,
		name = clubName,
		useSystemId = useSystemId,
		extraData = {
			clubId = ulong.tostring(clubId)
		}
	})
end

ReportManager.ShowRacingGameReportDialog = function(self, name, gameId)
	local useSystemId = LTConfig.InformUseSystemConfig.Race
	local extraData = {
		gameId = gameId
	}

	self:ShowCommonReportDialog(useSystemId, name, extraData)
end

gReportManager = ReportManager
