-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\FloatingGuideText.lua
-- Decompiled from: 00407_FloatingGuideText.lua_d6082aba98d0.luajit

C_GuideBT_FloatingGuideText = DefClass("C_GuideBT_FloatingGuideText", C_GuideBT_FloatingGuideText, C_GuideBT_ActionBase)
local M = C_GuideBT_FloatingGuideText

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.Run = function(self)
	if not self.guideTextData then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.ShowText(self)
	else
		self.ShowTopText(self)
	end
end

M.OnEnterRunning = function(self)
	if self.guideTextData ~= nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的FloatingGuideText没有设置guideText")

		return
	end
end

M.OnExitRunning = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.HideText(self)
	else
		self.HideTopText(self)
	end
end

M.ShowTopText = function(self)
	if not self.IsShow then
		gPanelManager:CheckShow(gPanelId.S_FLOATING_GUIDE_TEXT_TOP, {
			Param = {
				guideTextData = self.guideTextData:Eval()
			}
		})

		self.IsShow = true
	end
end

M.GetConflictPanelId = function(self)
	if self.isFrontLayer then
		return gPanelId.FLOATING_GUIDE_TEXT
	end

	return gPanelId.FLOATING_GUIDE_TEXT_FRONT
end

M.CloseConflictPanelIfNeeded = function(self)
	gPanelManager:Destroy(self:GetConflictPanelId())
end

M.ShowText = function(self)
	if not self.IsShow then
		self.CloseConflictPanelIfNeeded(self)

		if self.isFrontLayer then
			gPanelManager:CheckShow(gPanelId.FLOATING_GUIDE_TEXT_FRONT, {
				guideTextData = self.guideTextData:Eval()
			})
		else
			gPanelManager:CheckShow(gPanelId.FLOATING_GUIDE_TEXT, {
				guideTextData = self.guideTextData:Eval()
			})
		end

		self.IsShow = true
	end
end

M.HideTopText = function(self)
	if self.IsShow then
		gPanelManager:Close(gPanelId.S_FLOATING_GUIDE_TEXT_TOP)

		self.IsShow = nil
	end
end

M.HideText = function(self)
	if self.IsShow then
		if self.isFrontLayer then
			gPanelManager:Close(gPanelId.FLOATING_GUIDE_TEXT_FRONT)
		else
			gPanelManager:Close(gPanelId.FLOATING_GUIDE_TEXT)
		end

		self.IsShow = nil
	end
end

M.GetPreLoadPanelIds = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.isFrontLayer then
			return gPanelId.FLOATING_GUIDE_TEXT_FRONT
		end

		return gPanelId.FLOATING_GUIDE_TEXT
	end

	return gPanelId.S_FLOATING_GUIDE_TEXT_TOP
end
