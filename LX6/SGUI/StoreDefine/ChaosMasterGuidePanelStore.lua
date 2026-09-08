-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosMasterGuidePanelStore.lua
-- Decompiled from: 01470_ChaosMasterGuidePanelStore.lua_155d18ee6e45.luajit

C_ChaosMasterGuidePanelStore = DefClass("C_ChaosMasterGuidePanelStore", C_ChaosMasterGuidePanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterGuidePanelStore = C_ChaosMasterGuidePanelStore
local M = C_ChaosMasterGuidePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	self.InitGuideData(self)
	self.RefreshGuideData(self, self.curIndex)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftArrow.luaClick = self.CreateAction(self, "OnClickLeftArrow")
	self.bindData.rightArrow.luaClick = self.CreateAction(self, "OnClickRightArrow")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExitBtn")
end

M.OnClickLeftArrow = function(self)
	self.RefreshGuideData(self, self.curIndex - 1)
end

M.OnClickRightArrow = function(self)
	self.RefreshGuideData(self, self.curIndex + 1)
end

M.OnClickExitBtn = function(self)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_GUIDE_PANEL)
end

M.InitGuideData = function(self)
	self.imageList = LTConfig.ChaosMasterConfig.GuideImg
	self.textList = LTConfig.ChaosMasterConfig.GuideText
	self.curIndex = 1
end

M.RefreshGuideData = function(self, newIndex)
	self.curIndex = newIndex
	self.bindData.leftArrow.interactable = true
	self.bindData.rightArrow.interactable = true

	if newIndex ~= 1 then
		self.bindData.leftArrow.interactable = false
	elseif newIndex ~= #self.imageList then
		self.bindData.rightArrow.interactable = false
	end

	self.bindData.image = self.imageList[newIndex]
	self.bindData.text = self.textList[newIndex]
end
