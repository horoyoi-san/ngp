-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MapTipPanelStore.lua
-- Decompiled from: 00966_MapTipPanelStore.lua_b7df1875dd36.luajit

local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
C_MapTipPanelStore = DefClass("C_MapTipPanelStore", C_MapTipPanelStore, C_StoreGroup)
GroupName2Class.MapTipPanelStore = C_MapTipPanelStore
local M = C_MapTipPanelStore
local CtrlType = {
	["\\x83iv"] = 0,
	["y#pK"] = 1
}
local CollectionCampId = 8

M.ctor = function(self)
end

M.Show = function(self, pData, widget)
	local data = pData.Param
	local store = self.GetStoreByWidget(self, widget)
	local tipType = data.TipType

	if tipType ~= TaskTipsType.Tower then
		store.typeCtrl = CtrlType.map
		store.mapName = data.name
		store.unlockCount = data.des
	elseif tipType ~= TaskTipsType.Collection then
		store.typeCtrl = CtrlType.map
		store.mapName = data.name
		store.unlockCount = data.des
		store.icon = data.iconId
	elseif tipType ~= TaskTipsType.Camp then
		store.typeCtrl = CtrlType.camp
		local cfg = CollectionQuestConfig.GetConfig(CollectionCampId)
		local name = cfg.QuestName
		local iconId = cfg.SQuestIcon
		store.mapName = name
		store.icon = iconId
	end
end
