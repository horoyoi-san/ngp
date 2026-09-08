-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaskChangedFullScreenStore.lua
-- Decompiled from: 01411_TaskChangedFullScreenStore.lua_5c590f4f805a.luajit

C_TaskChangedFullScreenStore = DefClass("C_TaskChangedFullScreenStore", C_TaskChangedFullScreenStore, C_StoreGroup)
GroupName2Class.TaskChangedFullScreenStore = C_TaskChangedFullScreenStore
local M = C_TaskChangedFullScreenStore
local TaskConfig = LTConfig.TaskConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.DelayClose = function(self)
	if self.m_TaskId then
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime
		slot2 = L18.Spoon.Task.TaskManager.Instance

		slot2:WaitTaskResourceDependedLoadComplete(self.m_TaskId, waitLoadMaxTime, function ()
			self:CloseByAnim()
		end)
	else
		self.CloseByAnim(self)
	end
end

M.CloseByAnim = function(self)
	if self.bindData and self.bindData.anim then
		local closeAnim = "vx_S_TaskChangedFullscreenPanel_close"
		local animTime = 0
		animTime = gCS.LuaUtils.GetAnimationTime(self.bindData.anim, closeAnim)

		if animTime < 0 then
			gPanelManager:Close(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL)

			return
		end

		if animTime <= 5 then
			animTime = 5
		end

		slot3 = self.bindData.anim

		slot3:Play(closeAnim)
		gLuaTimeMgrUtils.Delay(function ()
			gPanelManager:Close(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL)
		end, animTime, nil, , true)

		return
	end

	gPanelManager:Close(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL)
end
