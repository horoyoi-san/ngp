C_TaskChangedFullScreenStore = DefClass("C_TaskChangedFullScreenStore", C_TaskChangedFullScreenStore, C_StoreGroup)
GroupName2Class.TaskChangedFullScreenStore = C_TaskChangedFullScreenStore
local M = C_TaskChangedFullScreenStore
local TaskConfig = LTConfig.TaskConfig

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:DelayClose()
	if self.m_TaskId then
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime

		L18.Spoon.Task.TaskManager.Instance:WaitTaskResourceDependedLoadComplete(self.m_TaskId, waitLoadMaxTime, function ()
			self:CloseByAnim()
		end)
	else
		self:CloseByAnim()
	end
end

function M:CloseByAnim()
	local closeAnim = "vx_S_TaskChangedFullscreenPanel_close"
	local animTime = 0

	if self.bindData and self.bindData.anim then
		animTime = gCS.LuaUtils.GetAnimationTime(self.bindData.anim, closeAnim)
	end

	if animTime <= 0 then
		gPanelManager:Close(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL)
	end

	if animTime > 5 then
		animTime = 5
	end

	self.bindData.anim:Play(closeAnim)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL)
	end, animTime, nil, nil, true)
end
