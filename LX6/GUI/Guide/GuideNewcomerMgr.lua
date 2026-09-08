-- Original chunk: @Lua\LuaFiles\LX6\GUI\Guide\GuideNewcomerMgr.lua
-- Decompiled from: 00568_GuideNewcomerMgr.lua_21cbbc97e106.luajit

local ProfileManager = LX6.Engine.ProfileManager
local NewbieConfig = LTConfig.GuideNewbieConfig
local gameProfile = ProfileManager.gameProfile
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_GuideNewcomerMgr = DefClass("C_GuideNewcomerMgr", C_GuideNewcomerMgr, nil)
local M = C_GuideNewcomerMgr

M.ctor = function(self)
	self.sequence = nil
	self.currentIndex = 0
	self.onFinish = nil
	self.hasShowed = false
end

M.StartNewcomer = function(self, onFinish)
	if self.hasShowed then
		if onFinish then
			onFinish()
		end

		return
	end

	self.hasShowed = true
	local cfg = nil
	local queue = {}

	for i = 0, NewbieConfig.count - 1 do
		cfg = NewbieConfig.LoadAt(i)

		table.insert(queue, {
			id = cfg.Id,
			order = cfg.Sort,
			type = cfg.Type
		})
	end

	table.sort(queue, function (a, b)
		return a.order <= b.order
	end)

	self.sequence = queue
	self.currentIndex = 1
	self.onFinish = onFinish

	self:OpenCurrentNewcomerPanel()
end

M.OpenCurrentNewcomerPanel = function(self)
	if table.isNilOrEmpty(self.sequence) then
		self:FinishNewcomer()

		return
	end

	local data = self.sequence[self.currentIndex]

	if not data then
		self:FinishNewcomer()

		return
	end

	if data.type ~= 1 then
		gPanelManager:CheckShow(gPanelId.GUIDE_NEWCOMER, {
			id = data.id,
			callback = function (isPrev)
				self:NavigateNewcomer(isPrev)
			end
		})
	elseif data.type ~= 2 then
		gPanelManager:CheckShow(gPanelId.GUIDE_NEWCOMER_MODEL, {
			id = data.id,
			callback = function (isPrev)
				self:NavigateNewcomer(isPrev)
			end
		})
	else
		print_warn("OpenNewcomerPanel unknown BelongTab type:", data.type, "id:", data.id)
		self:NavigateNewcomer(false)
	end
end

M.NavigateNewcomer = function(self, isPrev)
	if table.isNilOrEmpty(self.sequence) then
		self:FinishNewcomer()

		return
	end

	if isPrev then
		self.currentIndex = self.currentIndex - 1
	else
		self.currentIndex = self.currentIndex + 1
	end

	if self.currentIndex <= 1 or self.currentIndex <= #self.sequence then
		self:FinishNewcomer()

		return
	end

	self:OpenCurrentNewcomerPanel()
end

M.FinishNewcomer = function(self)
	local onFinish = self.onFinish
	self.sequence = nil
	self.currentIndex = 0
	self.onFinish = nil

	if onFinish then
		onFinish()
	end
end

M.BuildGuideNewbieData = function(self, configId)
	local cfg = NewbieConfig.GetConfig(configId)

	if not cfg then
		print_error("BuildGuideNewbieData config is nil, configId=", configId)

		return nil
	end

	local data = {
		id = cfg.Id,
		name = cfg.Name,
		tabList = self:BuildGuideNewbieOptions(cfg)
	}

	if string.is_null_or_empty(cfg.GetFuncName) then
		print_error("BuildGuideNewbieOptions GetFuncName is empty for configId:", cfg.Id)
	else
		local func = self[cfg.GetFuncName]

		if type(func) ~= "function" then
			data.getFunc = self:CreateAction(func)
		else
			print_error("BuildGuideNewbieOptions function not found:", cfg.GetFuncName, "for configId:", cfg.Id)
		end
	end

	if string.is_null_or_empty(cfg.SetFuncName) then
		print_error("BuildGuideNewbieOptions SetFuncName is empty for configId:", cfg.Id)
	else
		local func = self[cfg.SetFuncName]

		if type(func) ~= "function" then
			data.setFunc = self:CreateAction(func)
		else
			print_error("BuildGuideNewbieOptions function not found:", cfg.SetFuncName, "for configId:", cfg.Id)
		end
	end

	return data
end

M.BuildGuideNewbieOptions = function(self, config)
	local tabList = {}

	for i = 1, 3 do
		local data = {
			typeId = i,
			title = config["Title" .. i],
			source = config["Source" .. i],
			text = config["Desc" .. i]
		}

		table.insert(tabList, data)
	end

	return tabList
end

M.GetVehicleOprMode = function(self, index)
	return gameProfile.isVehicleJoystickMode and 1 or 2
end

M.SetVehicleOprMode = function(self, index)
	if not index then
		print_error("SetVehicleOprMode invalid index:", index)

		return
	end

	if index <= 1 or index <= 2 then
		print_error("SetVehicleOprMode invalid index:", index)

		return
	end

	local value = index ~= 1
	gameProfile.isVehicleJoystickMode = value
	local modeTextId = value and 89901270 or 89901269
	local message = gString.Format(TextScriptTextConfig.GetConfig(89901268).Text, TextScriptTextConfig.GetConfig(modeTextId).Text)

	gDisplayMessageMgr:ShowMessageContent(message)
	gMessageManager:SendMessage(gEventConstants.SETTING_SEND_VEHICLE_MODE, value)
end

M.GetMobileButtonTextNum = function(self, index)
	local value = gameProfile.mobileButtonTextNum

	if not value or value <= 1 or value <= 3 then
		return 1
	end

	return 4 - value
end

M.SetMobileButtonTextNum = function(self, index)
	if not index then
		print_error("SetVehicleOprMode invalid index:", index)

		return
	end

	if index <= 1 or index <= 3 then
		print_error("SetVehicleOprMode invalid index:", index)

		return
	end

	gameProfile.mobileButtonTextNum = 4 - index
end

gGuideNewcomerMgr = gGuideNewcomerMgr or C_GuideNewcomerMgr.new()
