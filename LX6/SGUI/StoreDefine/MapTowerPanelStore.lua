-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MapTowerPanelStore.lua
-- Decompiled from: 00967_MapTowerPanelStore.lua_49cf3414aaf4.luajit

C_MapTowerPanelStore = DefClass("C_MapTowerPanelStore", C_MapTowerPanelStore, C_StoreGroup)
GroupName2Class.MapTowerPanelStore = C_MapTowerPanelStore
local M = C_MapTowerPanelStore

M.ctor = function(self)
	self.delayTime = 0
	self.callBacks = {}
	self.allTime = 0
	self.curShowData = {}
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

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnUpdate = function(self)
	if not self.alwaysShow then
		self.allTime = self.allTime + gLogicTime.deltaTime

		if self.allTime > 5 then
			self.CloseSelf(self)
		end
	end
end

M.OnShow = function(self, panelId, data)
	self.delayTime = gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_vx_MapTipPanel_Open")
	self.isClose = false
	self.allTime = 0
	self.curShowData = data or {}
	self.curShowData.CallBack = self.curShowData.CallBack or {}

	if type(self.curShowData.CallBack) ~= "table" then
		array.concat(self.callBacks, self.curShowData.CallBack)
	elseif type(self.curShowData.CallBack) ~= "function" then
		table.insert(self.callBacks, self.curShowData.CallBack)
	end

	local data = self.curShowData.Param

	if data then
		if data.alwaysShow then
			self.alwaysShow = data.alwaysShow
		end

		self.bindData.typeCtrl = 0
		self.bindData.mapName = data.name
		self.bindData.unlockCount = data.des
	end

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

M.OnClose = function(self)
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

	self.ClearMessageEvents(self)
end

M.CloseSelf = function(self)
	if self.isClose then
		return
	end

	self.isClose = true

	gPanelManager:Close(self.m_Id)
end
