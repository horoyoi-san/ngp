local ReportManager = gReportManager or {}

function ReportManager:ShowReportDialog(data)
	if not ulong.check(data.pid) or ulong.equals(data.pid, 0) then
		print_error("[ReportManager] 没传 pid 或者 pid 不是 ulong!")

		return
	end

	gPanelManager:CheckShow(gPanelId.REPORT_PANEL, data)
end

function ReportManager:ShowDefaultReportDialog(pid)
	self:ShowReportDialogByMatterList(pid, LTConfig.InformConfig.DefaultMatter)
end

function ReportManager:ShowReportDialogByMatterList(pid, matterList)
	if table.isNilOrEmpty(matterList) then
		print_error("[ReportManager] 传的 matterList 为空!")
	else
		for _, v in ipairs(matterList) do
			if LTConfig.InformMatterConfig.GetConfig(v) == nil then
				print_error("[ReportManager] 传的 matterList 找不到配置!", v)
			end
		end
	end

	self:ShowReportDialog({
		pid = pid,
		matterList = matterList
	})
end

function ReportManager:ShowReportDialogByUseSystemId(pid, useSystemId)
	if LTConfig.InformUseSystemConfig.GetConfig(useSystemId) == nil then
		print_error("[ReportManager] 传的 useSystemId 找不到配置!", useSystemId)
	end

	self:ShowReportDialog({
		pid = pid,
		useSystemId = useSystemId
	})
end

function ReportManager:ShowReportDialogBySystemId(pid, systemId)
	if self:FindInformUseSystemConfigId(systemId) == nil then
		print_error("[ReportManager] 传的 systemId 找不到配置!", systemId)
	end

	self:ShowReportDialog({
		pid = pid,
		systemId = systemId
	})
end

function ReportManager:FindInformUseSystemConfigId(systemId)
	for i = 0, LTConfig.InformUseSystemConfig.count - 1 do
		local cfg = LTConfig.InformUseSystemConfig.LoadAt(i)

		if cfg.SystemId == systemId then
			return cfg.Id
		end
	end

	return nil
end

gReportManager = ReportManager
