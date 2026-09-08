-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SkyCountDownStore.lua
-- Decompiled from: 01334_SkyCountDownStore.lua_13b074df57e0.luajit

C_SkyCountDownStore = DefClass("C_SkyCountDownStore", C_SkyCountDownStore, C_StoreGroup)
GroupName2Class.SkyCountDownStore = C_SkyCountDownStore
local M = C_SkyCountDownStore
local AtmosphereManager = LX6.Manager.AtmosphereManager

M.ctor = function(self)
	self.endTime = nil
	self.timeValues = {}
	self.timeType = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.timeTypeCtrlEnum = {
		["\\xaai"] = 0,
		["c\\xa7\\xa5\\xa7\\xa2"] = 1
	}
	self.numCtrlEnum = {
		["\\x9d"] = 0,
		["\\x97"] = 10,
		["\\x9f"] = 2,
		["\\x9a"] = 7,
		["\\x9e"] = 3,
		["\\x9b"] = 6,
		["\\x94"] = 9,
		["\\x98"] = 5,
		["\\x9c"] = 1,
		["\\x95"] = 8,
		["\\x99"] = 4
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.timeTypeCtrlEnum = nil
	self.numCtrlEnum = nil
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
	local endTime = gSkyCountManager:GetUnixEndTime()

	if not endTime then
		return
	end

	local duration = endTime - gLuaDataManager.serverUnixTime

	if duration < 0 then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.endTime = endTime
end

M.OnUpdate = function(self)
	if not self.endTime then
		return
	end

	local remainSeconds = self.endTime - gLuaDataManager.serverUnixTime

	if remainSeconds < 0 then
		self.endTime = nil

		gPanelManager:Close(self.m_Id)

		return
	end

	local day = math.floor(remainSeconds / 86400)
	local hour = math.floor(remainSeconds % 86400 / 3600)
	local minute = math.floor(remainSeconds % 3600 / 60)
	local second = math.floor(remainSeconds % 60)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local gameHour = math.floor(gameTime / 3600) % 24
	local timeType = gameHour > 6 and gameHour >= 20 and self.timeTypeCtrlEnum.Day or self.timeTypeCtrlEnum.Night
	local timeValues = {}

	if day ~= 0 then
		table.insert(timeValues, 0)
	else
		local dayDigits = {}
		local n = day

		while n <= 0 do
			table.insert(dayDigits, n % 10)

			n = math.floor(n / 10)
		end

		for i = #dayDigits, 1, -1 do
			table.insert(timeValues, dayDigits[i])
		end
	end

	table.insert(timeValues, 10)
	table.insert(timeValues, math.floor(hour / 10))
	table.insert(timeValues, hour % 10)
	table.insert(timeValues, 10)
	table.insert(timeValues, math.floor(minute / 10))
	table.insert(timeValues, minute % 10)
	table.insert(timeValues, 10)
	table.insert(timeValues, math.floor(second / 10))
	table.insert(timeValues, second % 10)

	local changed = #self.timeValues == #timeValues or self.timeType == timeType

	if not changed then
		for i = 1, #timeValues do
			if self.timeValues[i] == timeValues[i] then
				changed = true

				break
			end
		end
	end

	if changed then
		self.timeValues = timeValues
		self.timeType = timeType

		self.bindData.numList:SetSimpleList(#self.timeValues)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.numList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderNumList")
end

M.OnRenderNumList = function(self, btn, index)
	local value = self.timeValues[index + 1]

	if value ~= nil then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.numCtrl = value
	store.timeTypeCtrl = self.timeType
end
