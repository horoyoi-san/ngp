-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystemBase.lua
-- Decompiled from: 00187_MapSubSystemBase.lua_30a4a305c7b0.luajit

EGpsDelayCallType = {
	["|\\xbb\\xa7\\xba\\xb3"] = 1,
	["\\xeb\\xde'\\xf4"] = 2
}
MapSubSystemBase = DefClass("MapSubSystemBase", MapSubSystemBase)
local M = MapSubSystemBase

M.ctor = function(self)
	self._flushReasons = {}
	self.__tickTimer = 0
	self.actions = {}
	self.NormalTraceableActions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.Trace
		},
		[gMapSystem_Element_State.Tracing] = {
			gMapSystemElementAction.Untrace
		}
	}
end

M.Init = function(self)
	self._sceneTaskQueue = {}

	self.OnInit(self)
end

M.OnInit = function(self)
end

M.LoadData = function(self)
	self.OnLoadData(self)
end

M.OnLoadData = function(self)
end

M.DoSceneInit = function(self)
	self.OnSceneInit(self)

	self.inScene = true

	for _, task in ipairs(self._sceneTaskQueue) do
		task.func(task.target, unpack(task.args))
	end
end

M.OnSceneInit = function(self)
end

M.DoSceneDestroy = function(self)
	self.inScene = false

	table.clear(self._sceneTaskQueue)
	self.OnSceneDestroy(self)
end

M.OnSceneDestroy = function(self)
end

M.OnLogin = function(self)
end

M.OnLogout = function(self)
end

M.GetActionInfo = function(self, element)
	return element.GetRawActions(element), nil
end

M.OnBeforeSwitchScene = function(self, switchType)
end

M.OnBigMapOpen = function(self)
end

M.OnClearTrace = function(self, element)
end

M.FlushData = function(self, reason)
	self._needFlushData = true
	reason = reason or "Unknown"
	self._flushReasons[#self._flushReasons + 1] = reason
end

M.OnFlushData = function(self)
end

M.ExecuteAction = function(self, element, action, ctx)
end

M.SGetTooltipInfo = function(self, id, element)
	return nil
end
