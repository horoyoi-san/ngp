-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosGachaOneResultPanelStore.lua
-- Decompiled from: 01464_ChaosGachaOneResultPanelStore.lua_40fbf9485bbd.luajit

C_ChaosGachaOneResultPanelStore = DefClass("C_ChaosGachaOneResultPanelStore", C_ChaosGachaOneResultPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaOneResultPanelStore = C_ChaosGachaOneResultPanelStore
local M = C_ChaosGachaOneResultPanelStore

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
	local gachaTemplate = gStoreManager:GetStoreGroup("ChaosGachaTemplate"):GetStoreByWidget(self.bindData.gachaTemplate)
	local gachaItemId = data[1]
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

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.gachaTemplate.luaClick = self.CreateAction(self, "OnClickGachaTemplate")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickGachaTemplate = function(self)
end
