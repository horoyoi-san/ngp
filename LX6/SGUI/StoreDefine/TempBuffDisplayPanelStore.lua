-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TempBuffDisplayPanelStore.lua
-- Decompiled from: 01381_TempBuffDisplayPanelStore.lua_2021c197625c.luajit

local RestaurantFoodConfig = LTConfig.RestaurantFoodConfig
local BuffConfig = LTConfig.BuffConfig
C_TempBuffDisplayPanelStore = DefClass("C_TempBuffDisplayPanelStore", C_TempBuffDisplayPanelStore, C_StoreGroup)
GroupName2Class.TempBuffDisplayPanelStore = C_TempBuffDisplayPanelStore
local M = C_TempBuffDisplayPanelStore

M.ctor = function(self)
	self.tempBuffDisplayDelay = nil
	self.areaIndex = nil
end

M.OnAwake = function(self)
	self.bindData.buffList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBuffItem")
end

M.OnShow = function(self, panelId, data)
	local foodList = data.foodList
	self.buffViewList = {}
	self.areaIndex = data.areaIndex

	if self.tempBuffDisplayDelay then
		self.tempBuffDisplayDelay:Stop()

		self.tempBuffDisplayDelay = nil
	end

	for _, foodId in ipairs(foodList) do
		local foodCfg = RestaurantFoodConfig.GetConfig(foodId)

		if foodCfg then
			local buffCfg = BuffConfig.GetConfig(foodCfg.FoodBuff)

			if buffCfg then
				local view = {
					["a\\x9f\\x8a\\x86Y"] = 0,
					buffIcon = buffCfg.IconIdSGUI,
					buffValue = buffCfg.EatingBuffValue
				}

				table.insert(self.buffViewList, view)
			else
				print_error("餐饮店食物没有找到对应buff，foodId = ", foodId, ",buffId = ", foodCfg.FoodBuff)
			end
		end
	end

	self.bindData.buffList:SetSimpleList(#self.buffViewList)

	self.tempBuffDisplayDelay = Timer.New(function ()
		gPanelManager:Close(gPanelId.S_TEMP_BUFF_DISPLAY)
	end, 2.5, false):Start()
end

M.OnClose = function(self)
	self.buffViewList = nil
end

M.OnRenderBuffItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.buffViewList and self.buffViewList[index + 1]

	if store and data then
		store.buffIcon = data.buffIcon
		store.buffValue = data.buffValue
	end
end
