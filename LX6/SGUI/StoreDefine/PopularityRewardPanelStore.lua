-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PopularityRewardPanelStore.lua
-- Decompiled from: 00795_PopularityRewardPanelStore.lua_5dbfdad77c06.luajit

C_PopularityRewardPanelStore = DefClass("C_PopularityRewardPanelStore", C_PopularityRewardPanelStore, C_StoreGroup)
GroupName2Class.PopularityRewardPanelStore = C_PopularityRewardPanelStore
local M = C_PopularityRewardPanelStore

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.areaIndex = args and args.areaIndex
	self.dropId = args and args.DropId or 0
end

M.InitView = function(self, args)
	self:StartAutoClose()

	local popularityAdd = args and args.Popularity or 0
	self.bindData.popularityValue = string.format("%+d", popularityAdd)
	self.bindData.popularityControl = self:GetPopularityControlValue(popularityAdd)
end

M.StartAutoClose = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5.5)
		gPanelManager:Close(self.m_Id)
	end)
end

M.GetPopularityControlValue = function(self, popularityAdd)
	local rangePointList = LTConfig.TuiteConfig.PopularityRangePoint

	for i = 1, #rangePointList - 1 do
		if rangePointList[i] < popularityAdd and popularityAdd >= rangePointList[i + 1] then
			return i - 1
		end
	end

	return 3
end

M.OnDestroy = function(self)
end
