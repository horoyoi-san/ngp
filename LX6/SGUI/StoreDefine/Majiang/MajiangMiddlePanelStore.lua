-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangMiddlePanelStore.lua
-- Decompiled from: 01209_MajiangMiddlePanelStore.lua_524bc3c91d48.luajit

C_MajiangMiddlePanelStore = DefClass("C_MajiangMiddlePanelStore", C_MajiangMiddlePanelStore, C_StoreGroup)
GroupName2Class.MajiangMiddlePanelStore = C_MajiangMiddlePanelStore
local M = C_MajiangMiddlePanelStore

M.ctor = function(self)
	self.instances = {}
end

M.OnEnable = function(self, widget)
	local instanceId = widget.GetInstanceID(widget)
	local store = self.GetStoreByWidget(self, widget)

	if table.isNilOrEmpty(self.instances) then
		self.InitData(self)
	end

	gMaJiangManager:RegisterMiddleStore(self)

	local instanceData = {
		seatStore = {},
		store = store
	}
	self.instances[instanceId] = instanceData

	for i = 1, 4 do
		local seatWidget = store["seat" .. tostring(i)]
		instanceData.seatStore[i] = seatWidget and self:GetStoreByWidget(seatWidget) or {}
		local richiWidget = store["richi" .. tostring(i)]
		instanceData.richiWidget = instanceData.richiWidget or {}
		instanceData.richiWidget[i] = richiWidget

		if richiWidget then
			richiWidget.SetActive(richiWidget, false)
		end
	end
end

M.InitData = function(self)
	local digitStart = LTConfig.MahjongConfig.DigitIconIdStart
	self.iconIdMap = {
		["\\x8d"] = 0,
		["0"] = digitStart,
		["1"] = digitStart + 1,
		["2"] = digitStart + 2,
		["3"] = digitStart + 3,
		["4"] = digitStart + 4,
		["5"] = digitStart + 5,
		["6"] = digitStart + 6,
		["7"] = digitStart + 7,
		["8"] = digitStart + 8,
		["9"] = digitStart + 9,
		["-"] = digitStart + 10,
		["+"] = digitStart + 11
	}
end

M.ClearData = function(self)
	self.iconIdMap = nil
end

M.OnDisable = function(self, widget)
	local instanceId = widget.GetInstanceID(widget)

	if self.instances[instanceId] then
		self.instances[instanceId] = nil
	end

	if table.isNilOrEmpty(self.instances) then
		gMaJiangManager:UnRegisterMiddleStore()
		self:ClearData()
	end
end

M.RefreshSeat = function(self, nowSeatId)
	for _, instance in pairs(self.instances) do
		instance.store.nowSeatId = nowSeatId
	end
end

M.RefreshSeatFieldCtrl = function(self, seatFieldCtrls)
	for _, instance in pairs(self.instances) do
		for i = 1, 4 do
			instance.seatStore[i].fieldCtrl = seatFieldCtrls[i] or 0
		end
	end
end

M.RefreshSeatScore = function(self, scores)
	for _, instance in pairs(self.instances) do
		for i = 1, 4 do
			local score = scores[i] or 0
			instance.seatStore[i].score = score

			self:SetDigits(instance.seatStore[i], score, false)
		end
	end
end

M.RefreshRichiMark = function(self, seatID, isRichi)
	for _, instance in pairs(self.instances) do
		local richiWidget = instance.richiWidget and instance.richiWidget[seatID + 1]

		if richiWidget then
			richiWidget:SetActive(isRichi ~= true)
		end
	end
end

M.SetSeatScoreChange = function(self, seatIndex, score, change)
	for _, instance in pairs(self.instances) do
		if instance.seatStore[seatIndex] ~= nil then
			return
		end

		self.SetDigits(self, instance.seatStore[seatIndex], change, true)

		if score <= 0 then
			instance.seatStore[seatIndex].scoreCtrl = self.scoreCtrlEnum.add
		else
			instance.seatStore[seatIndex].scoreCtrl = self.scoreCtrlEnum.minus
		end

		Timer.New(function ()
			if instance.seatStore[seatIndex] ~= nil then
				return
			end

			self:SetDigits(instance.seatStore[seatIndex], score, false)

			instance.seatStore[seatIndex].scoreCtrl = self.scoreCtrlEnum.none
		end, 1):Start()
	end
end

M.SetDigits = function(self, seatStore, score, showChangeSign)
	if seatStore ~= nil then
		return
	end

	if score ~= 0 then
		for d = 1, 6 do
			seatStore["digit" .. tostring(d)] = 0
		end

		seatStore.digit7 = self.iconIdMap["0"]

		return
	end

	local scoreStr = tostring(math.abs(math.floor(score)))

	if showChangeSign then
		if score <= 0 then
			scoreStr = "+" .. scoreStr
		elseif score >= 0 then
			scoreStr = "-" .. scoreStr
			score = -score
		end
	elseif score >= 0 then
		scoreStr = "-" .. scoreStr
		score = -score
	end

	if #scoreStr <= 7 then
		print_error("score too long ", scoreStr)

		scoreStr = string.sub(scoreStr, -7)
	end

	scoreStr = string.rep(" ", 7 - #scoreStr) .. scoreStr

	for i = 1, 7 do
		local digit = string.sub(scoreStr, i, i)
		seatStore["digit" .. tostring(i)] = self.iconIdMap[digit]
	end
end

M.RefreshSeatName = function(self, seatNames)
	for _, instance in pairs(self.instances) do
		local store = instance.store
		store.seatName1 = seatNames[1]
		store.seatName2 = seatNames[2]
		store.seatName3 = seatNames[3]
		store.seatName4 = seatNames[4]
	end
end

M.RefreshCountDown = function(self, countDown)
	for _, instance in pairs(self.instances) do
		instance.store.countDown = countDown
	end
end

M.RefreshIsShow = function(self, isShow)
	for _, instance in pairs(self.instances) do
		instance.store.isShow = isShow
	end
end

M.DefineAllEnumsAutoGen = function(self)
	self.nowSeatIdEnum = {
		["~\\xab\\xa3\\xbb\\xe7"] = 0,
		["~\\xab\\xa3\\xbb\\xe2"] = 3,
		["~\\xab\\xa3\\xbb\\xe4"] = 1,
		["~\\xab\\xa3\\xbb\\xe5"] = 2
	}
	self.isShowEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.fieldCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.scoreCtrlEnum = {
		["@\\xa7\\xac\\xba\\xa5"] = 2,
		["\\x8flb"] = 1,
		["t-s^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.nowSeatIdEnum = nil
	self.isShowEnum = nil
	self.fieldCtrlEnum = nil
	self.scoreCtrlEnum = nil
end
