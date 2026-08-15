local HackScriptFunc = {}
local M = HackScriptFunc
local this = HackScriptFunc

function M.CheckShowPanel()
	local data = this.SettingData

	if data and data.panelId and data.panelId > 0 then
		gPanelManager:CheckShow(data.panelId)
	else
		print_error("黑客打开其他界面panelid不存在，请策划检查配置")
	end
end

function M.FunctionGo()
	print_notice("FunctionGo")
end

function M:SpiderSkill()
	gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938181)
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

function M:DroneSkill()
	gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938183)
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

return HackScriptFunc
