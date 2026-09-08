-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueCostumeControlsStore.lua
-- Decompiled from: 01176_UniqueCostumeControlsStore.lua_d27283834a20.luajit

local FashionInteractModule = LX6.Units.Module.FashionInteractModule
C_UniqueCostumeControlsStore = DefClass("C_UniqueCostumeControlsStore", C_UniqueCostumeControlsStore, C_StoreGroup)
GroupName2Class.UniqueCostumeControlsStore = C_UniqueCostumeControlsStore
local M = C_UniqueCostumeControlsStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.interactId = 0
	self.isWingSuitDressed = false
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
	FashionInteractModule.GetInteractState(gCS.MyPlayerManager.PlayerUnit)
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

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_WING_SUIT_DRESSED] = self.CreateAction(self, "SetWingSuitDressed"),
		[gEventConstants.FASHION_INTERACT_CHANGE] = self.CreateAction(self, "OnFashionInteractChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.costumeTabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnTabRectRender = function(self, index, widget)
	self.curCostumeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curCostumeStore then
		self.curCostumeStore:OnShow(self.interactId, self.interactState)
	end
end

M.SetWingSuitDressed = function(self, eventId, isDressed)
	self.isWingSuitDressed = isDressed

	self.RefreshDressTab(self)
end

M.OnFashionInteractChange = function(self, eventId, interactId, interactState)
	self.interactId = interactId
	self.interactState = interactState

	self.RefreshDressTab(self)
end

M.RefreshDressTab = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	if self.curCostumeStore then
		self.curCostumeStore:OnClose()

		self.curCostumeStore = nil
	end

	if self.interactId == 0 then
		self.bindData.costumeTabRect.selectedIndex = 1
	elseif self.isWingSuitDressed then
		self.bindData.costumeTabRect.selectedIndex = 0
	else
		self.bindData.costumeTabRect.selectedIndex = -1
	end
end
