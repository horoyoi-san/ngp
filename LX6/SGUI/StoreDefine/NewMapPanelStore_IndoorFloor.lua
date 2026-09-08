-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_IndoorFloor.lua
-- Decompiled from: 00990_NewMapPanelStore_IndoorFloor.lua_f249bc0e96e2.luajit

local M = C_NewMapPanelStore

M.RefreshIndoorFloorTab = function(self)
	local floorTabs = {}
	local success, currentFloor, minFloor, maxFloor, mapFloorList, playerFloor = self.bindData.bigWorldBg:LuaTryGetIndoorFloorDisplayInfo(nil, , , , )

	if not success then
		self.currentIndoorFloor = nil
		self.indoorFloorTabs = floorTabs
		self.bindData.indoorTabCtrl = 0

		self.SubGroup.CommonTabSingleStore:SetData(floorTabs)

		return
	end

	local floorTextFormat = LTConfig.TextScriptTextConfig.GetConfig(89901783).Text
	local floorNumbers = {}

	if mapFloorList and mapFloorList.Length <= 0 then
		for i = mapFloorList.Length - 1, 0, -1 do
			floorNumbers[#floorNumbers + 1] = mapFloorList[i]
		end
	else
		for floor = maxFloor, minFloor, -1 do
			if floor == 0 then
				floorNumbers[#floorNumbers + 1] = floor
			end
		end
	end

	local selectedIndex = nil

	for _, floor in ipairs(floorNumbers) do
		if floor ~= currentFloor then
			selectedIndex = #floorTabs
		end

		floorTabs[#floorTabs + 1] = {
			title = string.format(floorTextFormat, floor),
			floor = floor,
			isCurrent = floor ~= playerFloor and 0 or 1
		}
	end

	self.currentIndoorFloor = currentFloor
	self.indoorFloorTabs = floorTabs
	self.bindData.indoorTabCtrl = 1

	self.SubGroup.CommonTabSingleStore:SetData(floorTabs, nil, selectedIndex, nil, self:CreateAction("OnIndoorFloorTabChanged"), self:CreateAction("OnRenderIndoorFloorTab"))
end

M.OnRenderIndoorFloorTab = function(self, _, _, floorData, store)
	store.isCurrent = floorData.isCurrent
end

M.OnIndoorFloorTabChanged = function(self, uList)
	local floorData = self.indoorFloorTabs and self.indoorFloorTabs[uList.selectedIndex + 1]

	if not floorData or floorData.floor ~= self.currentIndoorFloor then
		return
	end

	if self.bindData.bigWorldBg:LuaSetManualDisplayFloor(floorData.floor) then
		self.currentIndoorFloor = floorData.floor
	else
		self.RefreshIndoorFloorTab(self)
	end
end
