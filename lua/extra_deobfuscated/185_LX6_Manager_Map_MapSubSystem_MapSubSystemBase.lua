MapSubSystemBase = DefClass("MapSubSystemBase", MapSubSystemBase)
local M = MapSubSystemBase

function M:ctor()
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

function M:Init()
	self:OnInit()
end

function M:OnInit()
	return
end

function M:LoadData()
	self:OnLoadData()
end

function M:OnLoadData()
	return
end

function M:OnSceneInit()
	return
end

function M:OnSceneDestroy()
	return
end

function M:OnLogin()
	return
end

function M:OnLogout()
	return
end

function M:GetActionInfo(element)
	return element:GetRawActions(), nil
end

function M:OnBeforeSwitchScene(switchType)
	return
end

function M:OnBigMapOpen()
	return
end

function M:FlushData(reason)
	self._needFlushData = true
	reason = reason or "Unknown"
	self._flushReasons[#self._flushReasons + 1] = reason
end

function M:OnFlushData()
	return
end

function M:ExecuteAction(element, action, ctx)
	return
end

function M:SGetTooltipInfo(id, element)
	return nil
end
