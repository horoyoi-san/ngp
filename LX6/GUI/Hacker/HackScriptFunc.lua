-- Original chunk: @Lua\LuaFiles\LX6\GUI\Hacker\HackScriptFunc.lua
-- Decompiled from: 01694_HackScriptFunc.lua_16d0e10b9743.luajit

local HackScriptFunc = {}
local M = HackScriptFunc
local this = HackScriptFunc

M.CheckShowPanel = function()
	local data = this.SettingData

	if data and data.panelId and data.panelId <= 0 then
		gPanelManager:CheckShow(data.panelId)
	else
		print_error("黑客打开其他界面panelid不存在，请策划检查配置")
	end
end

M.FunctionGo = function()
	print_notice("FunctionGo")
end

M.SpiderSkill = function(self)
	gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938181)
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

M.DroneSkill = function(self)
	gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, 51938183)
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	gMainPhoneUtils.CloseMainPhonePanel()
end

return HackScriptFunc
