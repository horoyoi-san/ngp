-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_Capacity.lua
-- Decompiled from: 01718_HomeBuildPanelStore_Capacity.lua_d143d9627131.luajit

local M = C_HomeBuildPanelStore
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseBuildConfig = LTConfig.HouseBuildConfig
local HouseConfig = LTConfig.HouseConfig

M.GetHouseMaxCapacity = function(self)
	local buildId = self.editingBuildId

	if not buildId or buildId < 0 then
		return 0
	end

	local buildCfg = HouseBuildConfig.GetConfig(buildId)

	return buildCfg and buildCfg.HouseCapacity or 0
end

M.CalcPlacedCapacity = function(self)
	local total = 0
	local editingHouseId = gHouseManager:GetEditingHouseId()

	for uid, go in gFurnitureUIDManager:GetFurnitureGosByHouseId(editingHouseId) do
		if go and not gCS.LuaUtils.IsNull(go) then
			local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(go, uid)

			if furnitureId then
				local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

				if cfg then
					total = total + (cfg.OccupyCapacity or 0)
				end
			end
		end
	end

	return total
end

M.CanPlaceByCapacity = function(self, furnitureId)
	local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not cfg then
		return true
	end

	local addCost = cfg.OccupyCapacity or 0

	if addCost < 0 then
		return true
	end

	local maxCap = self.GetHouseMaxCapacity(self)

	if maxCap < 0 then
		return true
	end

	local curCap = self:CalcPlacedCapacity()

	return maxCap < curCap + addCost
end

M.RefreshLoadCtrl = function(self)
	local maxCap = self.GetHouseMaxCapacity(self)

	if maxCap < 0 then
		self.bindData.loadCtrl = 0

		return
	end

	local curCap = self:CalcPlacedCapacity()
	local ratio = curCap / maxCap
	local yellowThreshold = HouseConfig.CapacityYellow or 0.55
	local redThreshold = HouseConfig.CapacityRed or 0.8

	if ratio > redThreshold then
		self.bindData.loadCtrl = 2
	elseif yellowThreshold < ratio then
		self.bindData.loadCtrl = 1
	else
		self.bindData.loadCtrl = 0
	end
end

M.OnRenderLoadTooltip = function(self, btn, popup, index)
	local popStore = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)

	if not popStore then
		return
	end

	local curCap = self.CalcPlacedCapacity(self)
	local maxCap = self.GetHouseMaxCapacity(self)
	popStore.score = string.format("%d/%d", curCap, maxCap)
end
