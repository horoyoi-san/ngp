-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShootBubbleMsgPanelStore.lua
-- Decompiled from: 01133_ShootBubbleMsgPanelStore.lua_69718777d4e9.luajit

C_ShootBubbleMsgPanelStore = DefClass("C_ShootBubbleMsgPanelStore", C_ShootBubbleMsgPanelStore, C_StoreGroup)
GroupName2Class.ShootBubbleMsgPanelStore = C_ShootBubbleMsgPanelStore
local M = C_ShootBubbleMsgPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.BUBBLE_SCORE_MESSAGE] = self.CreateAction(self, self.ShowBubbleScoreMessage)
	}
end

M.RegisterWidget = function(self)
end

M.ShowBubbleScoreMessage = function(self, _, data)
	if data and data.score and data.position then
		self.bindData.shootingBubbleMgr:Show(data.position, "+" .. data.score)
	end
end

M.OnCameraUpdate = function(self)
	self.bindData.shootingBubbleMgr:UpdatePanel()
end
