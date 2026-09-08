-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\FloatingGuideTextTop.lua
-- Decompiled from: 00409_FloatingGuideTextTop.lua_d2aa7b9b9fa1.luajit

C_GuideBT_FloatingGuideTextTop = DefClass("C_GuideBT_FloatingGuideTextTop", C_GuideBT_FloatingGuideTextTop, C_GuideBT_ActionBase)
local M = C_GuideBT_FloatingGuideTextTop

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	if self.guideTextData ~= nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePic没有设置guideText")

		return
	end
end

M.Run = function(self)
	if not self.IsShow then
		gPanelManager:CheckShow(gPanelId.S_FLOATING_GUIDE_TEXT_TOP, {
			Param = {
				guideTextData = self.guideTextData:Eval()
			}
		})

		self.IsShow = true
	end
end

M.OnExitRunning = function(self)
	if self.IsShow then
		gPanelManager:Close(gPanelId.S_FLOATING_GUIDE_TEXT_TOP)

		self.IsShow = nil
	end
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.S_FLOATING_GUIDE_TEXT_TOP
end
