-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PopupType2BaikeStore.lua
-- Decompiled from: 00799_PopupType2BaikeStore.lua_964d7f627a0b.luajit

C_PopupType2BaikeStore = DefClass("C_PopupType2BaikeStore", C_PopupType2BaikeStore, C_StoreGroup)
GroupName2Class.PopupType2BaikeStore = C_PopupType2BaikeStore
local M = C_PopupType2BaikeStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId

	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.areaIndex = args.areaIndex
end

M.InitView = function(self, args)
	self.StartAutoClose(self)

	local id = args.id
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	self.bindData.name = cityPediaCfg.Name
end

M.StartAutoClose = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

M.OnDestroy = function(self)
end
