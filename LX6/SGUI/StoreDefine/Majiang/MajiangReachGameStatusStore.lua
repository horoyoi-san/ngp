-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangReachGameStatusStore.lua
-- Decompiled from: 01219_MajiangReachGameStatusStore.lua_4f75d3a6b79b.luajit

local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
C_MajiangReachGameStatusStore = DefClass("C_MajiangReachGameStatusStore", C_MajiangReachGameStatusStore, C_StoreGroup)
GroupName2Class.MajiangReachGameStatusStore = C_MajiangReachGameStatusStore
local M = C_MajiangReachGameStatusStore

M.OnAwake = function(self)
	self.bindData.doraList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDoraListItem)
	self.bindData.richiBou.text = "x0"
	self.bindData.honba.text = "x0"
end

M.OnStart = function(self)
	if self.cachedReachGameStatusData then
		local data = self.cachedReachGameStatusData
		self.cachedReachGameStatusData = nil

		self.ApplyReachGameStatusData(self, data.doraIndicators, data.richiSticks, data.extra, data.oyaPlayerIndex)
	end
end

M.OnDestroy = function(self)
	self.doraIndicators = nil
end

M.SetReachGameStatusData = function(self, doraIndicators, richiSticks, extra, oyaPlayerIndex)
	if not self.STATE_EnableOnce then
		self.cachedReachGameStatusData = {
			doraIndicators = doraIndicators,
			richiSticks = richiSticks,
			extra = extra,
			oyaPlayerIndex = oyaPlayerIndex
		}

		return
	end

	self.ApplyReachGameStatusData(self, doraIndicators, richiSticks, extra, oyaPlayerIndex)
end

M.ApplyReachGameStatusData = function(self, doraIndicators, richiSticks, extra, oyaPlayerIndex)
	self.doraIndicators = doraIndicators or {}
	self.bindData.richiBou.text = "x" .. tostring(richiSticks or 0)
	self.bindData.honba.text = "x" .. tostring(extra or 0)

	self.bindData.doraList:SetSimpleList(gReachMahjongConst.ReachConstants.MaxKongs + 1)

	self.bindData.title = LTConfig.MahjongConfig.ReachRoundName and LTConfig.MahjongConfig.ReachRoundName[(oyaPlayerIndex or 0) + 1]
end

M.OnSimpleRenderDoraListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local tile = self.doraIndicators and self.doraIndicators[index + 1]

	if tile then
		store.iconId = ReachTile.GetIconId(tile)
		store.isBack = 0
	else
		store.isBack = 1
	end

	store.isMask = 1
end
