-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopModelViewerStore.lua
-- Decompiled from: 01322_ShopModelViewerStore.lua_f3d3d61c8ded.luajit

C_ShopModelViewerStore = DefClass("C_ShopModelViewerStore", C_ShopModelViewerStore, C_StoreGroup)
GroupName2Class.ShopModelViewerStore = C_ShopModelViewerStore
local M = C_ShopModelViewerStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	if self.bindData then
		if self.bindData.camera then
			self.bindData.camera.gameObject:SetActive(false)
		end

		if self.bindData.rawImage then
			self.bindData.rawImage.gameObject:SetActive(false)
		end
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.bindData and self.bindData.modelTrans then
		GameObject.Destroy(self.bindData.modelTrans.gameObject)
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnClose = function(self)
end
