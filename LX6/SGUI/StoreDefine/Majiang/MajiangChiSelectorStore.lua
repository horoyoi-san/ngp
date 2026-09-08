-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangChiSelectorStore.lua
-- Decompiled from: 01207_MajiangChiSelectorStore.lua_2b920c235589.luajit

local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
C_MajiangChiSelectorStore = DefClass("C_MajiangChiSelectorStore", C_MajiangChiSelectorStore, C_StoreGroup)
GroupName2Class.MajiangChiSelectorStore = C_MajiangChiSelectorStore
local M = C_MajiangChiSelectorStore

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnStart = function(self)
	local chiData = self.reachChiData
	self.reachChiData = nil

	self.ApplyChiData(self, chiData)
end

M.OnDestroy = function(self)
	self.chiData = nil
	self.selectedIndex = nil
end

M.SetData = function(self, chiData)
	if not self.STATE_EnableOnce then
		self.reachChiData = chiData

		return
	end

	self.ApplyChiData(self, chiData)
end

M.ApplyChiData = function(self, chiData)
	self.chiData = chiData or {}
	self.selectedIndex = #self.chiData <= 0 and 1 or nil

	self.bindData.list:SetSimpleList(#self.chiData)
end

M.OnClickCloseBtn = function(self)
	gMaJiangUtils:GetPanelStore():ShowReachChiSelector(false)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.chiData[index + 1]

	if data ~= nil then
		return
	end

	local store = self:GetStoreByWidget(btn)
	local card1Store = gStoreManager:GetStoreGroup("MaJiangHandCardTemplate"):GetStoreByWidget(store.card1)
	local card2Store = gStoreManager:GetStoreGroup("MaJiangHandCardTemplate"):GetStoreByWidget(store.card2)
	local openMeld = data.operation and data.operation.Meld
	local meldTiles = openMeld and openMeld.Meld and openMeld.Meld.Tiles
	local discardTile = data.operation and data.operation.Tile
	local ownTiles = {}

	if meldTiles and discardTile then
		for i = 1, #meldTiles do
			if meldTiles[i].InstanceId == discardTile.InstanceId then
				ownTiles[#ownTiles + 1] = meldTiles[i]
			end
		end
	end

	card1Store.iconId = ReachTile.GetIconId(ownTiles[1])
	card2Store.iconId = ReachTile.GetIconId(ownTiles[2])

	btn:SetSelected(index + 1 ~= self.selectedIndex)
end

M.OnSimpleClickList = function(self, btn, index)
	local data = self.chiData[index + 1]

	if data ~= nil then
		return
	end

	gMaJiangUtils:GetPanelStore():OnReachChiSelected(data.opIndex)
end

M.MoveSelection = function(self, step)
	if not self.STATE_EnableOnce then
		return
	end

	local count = #self.chiData

	if count < 0 then
		return
	end

	self.selectedIndex = self.selectedIndex or 1
	self.selectedIndex = self.selectedIndex + step

	if self.selectedIndex >= 1 then
		self.selectedIndex = count
	elseif count >= self.selectedIndex then
		self.selectedIndex = 1
	end

	self.bindData.list:RefreshList()
end

M.ConfirmSelection = function(self)
	if not self.STATE_EnableOnce or self.selectedIndex ~= nil then
		return
	end

	local data = self.chiData[self.selectedIndex]

	if data then
		gMaJiangUtils:GetPanelStore():OnReachChiSelected(data.opIndex)
	end
end
