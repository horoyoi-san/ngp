-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShoulderPolePanelStore.lua
-- Decompiled from: 01326_ShoulderPolePanelStore.lua_f611f8c5481f.luajit

C_ShoulderPolePanelStore = DefClass("C_ShoulderPolePanelStore", C_ShoulderPolePanelStore, C_StoreGroup)
GroupName2Class.ShoulderPolePanelStore = C_ShoulderPolePanelStore
local M = C_ShoulderPolePanelStore
local ShoulderPoleManager = L50.Gameplay.ShoulderPole.ShoulderPoleManager
local LogUtils = LX6.Utils.LogUtilsLua

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curHintDir = 0
	self.isPCPlatform = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.bigMoveEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.smallMoveEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.maintainCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showhintCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.bigMoveEnum = nil
	self.smallMoveEnum = nil
	self.maintainCtrlEnum = nil
	self.showhintCtrlEnum = nil
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
	self.bindData.bigMove = self.bigMoveEnum.show
	self.bindData.smallMove = self.smallMoveEnum.show
	self.bindData.maintainCtrl = self.maintainCtrlEnum._true
	self.curHintDir = 0

	self.SetHintVisible(self, false)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.qBtn.luaClick = self.CreateAction(self, "OnClickqBtn")
	self.bindData.eBtn.luaClick = self.CreateAction(self, "OnClickeBtn")
	self.bindData.lmBtn.luaClick = self.CreateAction(self, "OnClicklmBtn")
	self.bindData.rmBtn.luaClick = self.CreateAction(self, "OnClickrmBtn")
	self.bindData.fbBalanceBtn.luaClick = self.CreateAction(self, "OnClickfbBalanceBtn")
end

M.OnClickqBtn = function(self)
	LogUtils.Debug("[ShoulderPolePanel] OnClickSpaceBtn")
	ShoulderPoleManager.AdjustPoleLeft()
end

M.OnClickeBtn = function(self)
	LogUtils.Debug("[ShoulderPolePanel] OnClickeBtn")
	ShoulderPoleManager.AdjustPoleRight()
end

M.OnClicklmBtn = function(self)
	LogUtils.Debug("[ShoulderPolePanel] OnClicklmBtn")
	ShoulderPoleManager.ManualAdjustLeft()
end

M.OnClickrmBtn = function(self)
	LogUtils.Debug("[ShoulderPolePanel] OnClickrmBtn")
	ShoulderPoleManager.ManualAdjustRight()
end

M.OnClickfbBalanceBtn = function(self)
	LogUtils.Debug("[ShoulderPolePanel] OnClickfbBalanceBtn")
	ShoulderPoleManager.ManualAdjustFB()
end

M.OnClickquitBtn = function(self)
	ShoulderPoleManager.PutDownPole()
end

M.OnUpdate = function(self)
	local dir = ShoulderPoleManager.GetUnbalanceHintDir()

	if dir == self.curHintDir then
		self.curHintDir = dir

		self:SetHintVisible(dir == 0)
		self:UpdateClickTip(dir)
	end

	if dir == 0 then
		self.UpdateHintPos(self, dir)
	end
end

M.SetHintVisible = function(self, visible)
	self.bindData.showhintCtrl = visible and self.showhintCtrlEnum._true or self.showhintCtrlEnum._false
end

M.UpdateClickTip = function(self, dir)
	if self.isPCPlatform ~= nil then
		self.isPCPlatform = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
	end

	if not self.isPCPlatform then
		return
	end

	self.bindData.leftClickTip:SetActive(dir ~= 2)
	self.bindData.rightClickTip:SetActive(dir ~= 1)
end

M.UpdateHintPos = function(self, dir)
	local worldPos = ShoulderPoleManager.GetUnbalanceHintWorldPos(dir)
	local hintRoot = self.bindData.hintRoot
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(worldPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local uiPos = gCS.LuaUtils.TransformScreenPointToUI(hintRoot.rectTransform.parent, Vector3.New(x, y, 0))
	hintRoot.rectTransform.anchoredPosition = Vector2.New(uiPos.x, uiPos.y)
end
