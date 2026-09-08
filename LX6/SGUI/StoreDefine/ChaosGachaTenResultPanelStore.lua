-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosGachaTenResultPanelStore.lua
-- Decompiled from: 01466_ChaosGachaTenResultPanelStore.lua_4e0b79898a55.luajit

C_ChaosGachaTenResultPanelStore = DefClass("C_ChaosGachaTenResultPanelStore", C_ChaosGachaTenResultPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaTenResultPanelStore = C_ChaosGachaTenResultPanelStore
local M = C_ChaosGachaTenResultPanelStore

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
	self.panelId = panelId

	for i = 1, 10 do
		local gachaTemplate = gStoreManager:GetStoreGroup("ChaosGachaTemplate"):GetStoreByWidget(self.bindData["gachaTemplate" .. i])

		if gachaTemplate then
			local gachaItemId = data[i]
			local gachaItemCfg = LTConfig.ChaosMastergachalistConfig.GetConfig(gachaItemId)
			local limboChaId = gachaItemCfg.LimboChaId
			local limboChaCfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(limboChaId)
			gachaTemplate.iconId = limboChaCfg.Icon
			gachaTemplate.qualityCtrl = gachaItemCfg.Quality - 1
			local imageScaleOffset = limboChaCfg.ImageScaleOffset or {
				1,
				0,
				0
			}
			local scale = imageScaleOffset[1] or 1
			local offsetX = imageScaleOffset[2] or 0
			local offsetY = imageScaleOffset[3] or 0
			gachaTemplate.imageRect.localPosition = Vector3.New(offsetX, offsetY, 0)
			gachaTemplate.imageRect.localScale = Vector3.New(scale, scale, 1)
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.gachaTemplate1.luaClick = self.CreateAction(self, "OnClickGachaTemplate1")
	self.bindData.gachaTemplate2.luaClick = self.CreateAction(self, "OnClickGachaTemplate2")
	self.bindData.gachaTemplate3.luaClick = self.CreateAction(self, "OnClickGachaTemplate3")
	self.bindData.gachaTemplate4.luaClick = self.CreateAction(self, "OnClickGachaTemplate4")
	self.bindData.gachaTemplate5.luaClick = self.CreateAction(self, "OnClickGachaTemplate5")
	self.bindData.gachaTemplate6.luaClick = self.CreateAction(self, "OnClickGachaTemplate6")
	self.bindData.gachaTemplate7.luaClick = self.CreateAction(self, "OnClickGachaTemplate7")
	self.bindData.gachaTemplate8.luaClick = self.CreateAction(self, "OnClickGachaTemplate8")
	self.bindData.gachaTemplate9.luaClick = self.CreateAction(self, "OnClickGachaTemplate9")
	self.bindData.gachaTemplate10.luaClick = self.CreateAction(self, "OnClickGachaTemplate10")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickGachaTemplate1 = function(self)
end

M.OnClickGachaTemplate2 = function(self)
end

M.OnClickGachaTemplate3 = function(self)
end

M.OnClickGachaTemplate4 = function(self)
end

M.OnClickGachaTemplate5 = function(self)
end

M.OnClickGachaTemplate6 = function(self)
end

M.OnClickGachaTemplate7 = function(self)
end

M.OnClickGachaTemplate8 = function(self)
end

M.OnClickGachaTemplate9 = function(self)
end

M.OnClickGachaTemplate10 = function(self)
end
