local RestaurantFoodConfig = LTConfig.RestaurantFoodConfig
local BuffConfig = LTConfig.BuffConfig
C_TempBuffDisplayPanelStore = DefClass("C_TempBuffDisplayPanelStore", C_TempBuffDisplayPanelStore, C_StoreGroup)
GroupName2Class.TempBuffDisplayPanelStore = C_TempBuffDisplayPanelStore
local M = C_TempBuffDisplayPanelStore

function M:ctor()
	self.tempBuffDisplayDelay = nil
	self.areaIndex = nil
end

function M:OnAwake()
	self.bindData.buffList.luaRenderItem = self:CreateAction("OnRenderBuffItem")
end

function M:OnShow(panelId, data)
	local foodList = data.foodList
	local buffViewList = {}
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
					tIndex = 0,
					buffIcon = buffCfg.IconIdSGUI,
					buffValue = buffCfg.EatingBuffValue
				}

				table.insert(buffViewList, view)
			else
				print_error("餐饮店食物没有找到对应buff，foodId = ", foodId, ",buffId = ", foodCfg.FoodBuff)
			end
		end
	end

	self.bindData.buffList:SetList(buffViewList)

	self.tempBuffDisplayDelay = Timer.New(function ()
		gPanelManager:Close(gPanelId.S_TEMP_BUFF_DISPLAY)
	end, 2.5, false):Start()
end

function M:OnClose()
	return
end

function M:OnRenderBuffItem(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.buffIcon = data.buffIcon
		store.buffValue = data.buffValue
	end
end
