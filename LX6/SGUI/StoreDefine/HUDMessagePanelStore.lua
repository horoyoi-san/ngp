-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HUDMessagePanelStore.lua
-- Decompiled from: 01811_HUDMessagePanelStore.lua_3fd55d17443f.luajit

C_HUDMessagePanelStore = DefClass("C_HUDMessagePanelStore", C_HUDMessagePanelStore, C_StoreGroup)
GroupName2Class.HUDMessagePanelStore = C_HUDMessagePanelStore
local M = C_HUDMessagePanelStore

M.ctor = function(self)
	self.delayTime = 3
	self.callBacks = {}
	self.curType = -1
	self.curTypeStore = nil
	self.curShowData = nil
	self.areaIndex = nil
	self.allTime = 0
	self.TipType = nil
end

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = function ()
			self:CloseSelf()
		end,
		[gEventConstants.TIME_PAUSE_BY_FULL_PANEL] = function ()
			self:CloseSelf()
		end
	}
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	self.isClose = false
	self.allTime = 0
	self.curShowData = data or {}
	self.curShowData.CallBack = self.curShowData.CallBack or {}

	array.concat(self.callBacks, self.curShowData.CallBack)

	self.areaIndex = self.curShowData.areaIndex
	self.bindData.tabRect.selectedIndex = 0

	if not self.alwaysShow then
		if self.timer then
			self.timer:Stop()
		end

		self.timer = Timer.New(function ()
			if gPanelManager:IsPanelShowing(self.m_Id) then
				self:CloseSelf()
			end
		end, self.delayTime):Start()
	end
end

M.OnUpdate = function(self)
	if not self.alwaysShow then
		self.allTime = self.allTime + gLogicTime.deltaTime

		if self.allTime > 5 then
			self.CloseSelf(self)
		end
	end
end

M.OnClose = function(self)
	if not self.areaIndex then
		return
	end
end

M.OnDestroy = function(self)
	if self.timer then
		self.timer:Stop()
	end

	if not table.isNilOrEmpty(self.callBacks) then
		for i = 1, #self.callBacks do
			self.callBacks[i]()
		end
	end
end

M.CloseSelf = function(self)
	if self.isClose then
		return
	end

	self.isClose = true

	if self.closeAniName then
		slot1 = gUIUtils

		slot1:PlayAniCallback(self.closeAnimation, self.closeAniName, function ()
			gPanelManager:Close(self.m_Id)
		end)
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnRenderTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:Show(self.curShowData, widget)
	end
end
