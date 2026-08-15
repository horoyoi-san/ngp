C_GuideBT_FloatingGuideTextTop = DefClass("C_GuideBT_FloatingGuideTextTop", C_GuideBT_FloatingGuideTextTop, C_GuideBT_ActionBase)
local M = C_GuideBT_FloatingGuideTextTop

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	if self.guideTextData == nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePic没有设置guideText")

		return
	end
end

function M:Run()
	if not self.IsShow then
		gPanelManager:CheckShow(gPanelId.S_FLOATING_GUIDE_TEXT_TOP, {
			Param = {
				guideTextData = self.guideTextData:Eval()
			}
		})

		self.IsShow = true
	end
end

function M:OnExitRunning()
	if self.IsShow then
		gPanelManager:Close(gPanelId.S_FLOATING_GUIDE_TEXT_TOP)

		self.IsShow = nil
	end
end
