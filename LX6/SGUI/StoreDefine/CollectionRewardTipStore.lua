-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CollectionRewardTipStore.lua
-- Decompiled from: 01435_CollectionRewardTipStore.lua_ae12e3f53c31.luajit

C_CollectionRewardTipStore = DefClass("C_CollectionRewardTipStore", C_CollectionRewardTipStore, C_StoreGroup)
GroupName2Class.CollectionRewardTipStore = C_CollectionRewardTipStore
local M = C_CollectionRewardTipStore

M.OnShow = function(self, panelId, data)
	self.areaIndex = data.areaIndex
	local info = data.GalleryReward
	local showCount = true

	if showCount then
		self.bindData.showCountCtrl = 0
		local countNow = info.countNow
		local countAll = info.countAll
		self.bindData.count = "(" .. countNow .. "/" .. countAll .. ")"
	else
		self.bindData.showCountCtrl = 1
	end

	self.bindData.name = info.name
	self.bindData.typeName = info.typeName
	self.bindData.icon = info.sIcon
	local ani = self.bindData.openAni
	local duration = ani.clip.length

	Timer.New(function ()
		gPanelManager:Close(panelId)
	end, duration):Start()
end

M.OnClose = function(self)
end
