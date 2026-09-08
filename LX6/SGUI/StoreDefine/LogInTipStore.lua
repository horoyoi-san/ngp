-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LogInTipStore.lua
-- Decompiled from: 01790_LogInTipStore.lua_9c5334b2d8ed.luajit

local MultiverseJumpEventConfig = LTConfig.MultiverseJumpEventConfig
C_LogInTipStore = DefClass("C_LogInTipStore", C_LogInTipStore, C_StoreGroup)
GroupName2Class.LogInTipStore = C_LogInTipStore
local M = C_LogInTipStore

M.ctor = function(self)
	self.mgr = gLoginManager
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.pid = data
	self.eventList = {}

	for i = 0, MultiverseJumpEventConfig.count - 1 do
		local cfg = MultiverseJumpEventConfig.LoadAt(i)
		local ele = {
			id = cfg.Id,
			label = cfg.Name
		}
		self.eventList[i + 1] = ele
	end

	self.bindData.selector:SetSimpleOptions(#self.eventList)

	for i = 1, #self.eventList do
		self.bindData.selector:SetItemLabel(i - 1, self.eventList[i].label)
	end

	self.bindData.selector:SelectOption(0, false)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.selector.luaSelectedChanged = self.CreateAction(self, self.OnSelectedEvent)
end

M.OnClickConfirmBtn = function(self)
	local event = self.eventList[self.bindData.selector.selectedIndex + 1]

	self.mgr:SetJumpEvent(event.id, self.pid, true)

	if event.id ~= 1 then
		LX6.TimelineScript.CutsceneManager.CreateChar_PlayTimeline()
	else
		gPanelManager:CheckShow(gPanelId.S_CREATE_CHARACTER_PANEL)
	end

	gPanelManager:Close(self.m_Id)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSelectedEvent = function(self)
	self.bindData.selector:ClosePopUp()
end
