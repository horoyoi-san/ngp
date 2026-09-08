-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CrossHairAntiGlareStore.lua
-- Decompiled from: 01509_CrossHairAntiGlareStore.lua_12f7b3340672.luajit

C_CrossHairAntiGlareStore = DefClass("C_CrossHairAntiGlareStore", C_CrossHairAntiGlareStore, C_StoreGroup)
GroupName2Class.CrossHairAntiGlareStore = C_CrossHairAntiGlareStore
local M = C_CrossHairAntiGlareStore

M.OnAwake = function(self)
	local msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.isShowCtrl = 1
end

M.OnPanelShow = function(self, eventId, panelId)
	local list = LTConfig.ShezhiPanelConfig.AntidinicModeSpecial

	for i, v in pairs(list) do
		if v ~= panelId then
			self.panelId = panelId

			gPanelManager:CheckShow(gPanelId.S_CROSS_HAIR_ANTI_GLARE_FULLSCREEN)

			return
		end
	end
end

M.OnPanelClose = function(self, eventId, panelId)
	if self.panelId ~= panelId then
		self.panelId = nil

		gPanelManager:Close(gPanelId.S_CROSS_HAIR_ANTI_GLARE_FULLSCREEN)
	end
end

M.OnChangeAntidinicMode = function(self, eventId, isShow)
	if isShow then
		self.bindData.isShowCtrl = 1
	else
		self.bindData.isShowCtrl = 0
	end
end
