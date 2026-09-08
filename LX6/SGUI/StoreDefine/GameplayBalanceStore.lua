-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayBalanceStore.lua
-- Decompiled from: 01736_GameplayBalanceStore.lua_6f4fc66fd543.luajit

C_GameplayBalanceStore = DefClass("C_GameplayBalanceStore", C_GameplayBalanceStore, C_StoreGroup)
GroupName2Class.GameplayBalanceStore = C_GameplayBalanceStore
local M = C_GameplayBalanceStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.m_SafeStart = 0
	self.m_SafeEnd = 0
	self.m_Current = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self._ReadPositionsFromTrans(self)

	if data then
		if data.safeStart and data.safeEnd then
			if data.isNormalized then
				self.SetSafeIntervalNormalized(self, data.safeStart, data.safeEnd - data.safeStart)
			else
				self.SetSafeInterval(self, data.safeStart, data.safeEnd - data.safeStart)
			end
		end

		if data.current then
			self.SetCurrent(self, data.current)
		end
	end

	self._RefreshUI(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GAMEPLAY_BALANCE_SET_SAFE_INTERVAL] = self.CreateAction(self, "OnMsgSetSafeInterval"),
		[gEventConstants.GAMEPLAY_BALANCE_SET] = self.CreateAction(self, "OnMsgSetBalancePosition")
	}
end

M.RegisterWidget = function(self)
end

M.OnMsgSetSafeInterval = function(self, eventId, data)
	if not data then
		return
	end

	if data.isNormalized then
		self:SetSafeIntervalNormalized(data.start or 0, data.length or 0.1)
	else
		self:SetSafeInterval(data.start or 0, data.length or 0)
	end
end

M.OnMsgSetBalancePosition = function(self, eventId, data)
	if not data then
		return
	end

	if data.position == nil then
		self.SetCurrentNormalized(self, data.position)
	end
end

M.GetBackgroundWidth = function(self)
	if self.bindData.backgroundTrans then
		return self.bindData.backgroundTrans.rect.width
	end

	return 0
end

M.GetCurrentWidth = function(self)
	if self.bindData.currentTrans then
		return self.bindData.currentTrans.sizeDelta.x
	end

	return 0
end

M.SetSafeInterval = function(self, start, length)
	local halfBg = self.GetBackgroundWidth(self) / 2
	length = math.max(0, length)
	self.m_SafeStart = Mathf.Clamp(start, -halfBg, halfBg)
	self.m_SafeEnd = Mathf.Clamp(self.m_SafeStart + length, self.m_SafeStart, halfBg)

	self.SetCurrent(self, self.m_Current)
	self._RefreshUI(self)
end

M.SetSafeIntervalNormalized = function(self, nStart, nLength)
	local bgWidth = self.GetBackgroundWidth(self)

	self.SetSafeInterval(self, (nStart - 0.5) * bgWidth, nLength * bgWidth)
end

M.SetCurrent = function(self, value)
	local halfBg = self.GetBackgroundWidth(self) / 2
	local halfCurrent = self.GetCurrentWidth(self) / 2
	local limit = halfBg - halfCurrent
	self.m_Current = Mathf.Clamp(value, -limit, limit)

	self._RefreshUI(self)
end

M.SetCurrentNormalized = function(self, nValue)
	local bgWidth = self.GetBackgroundWidth(self)
	local validRange = bgWidth - self.GetCurrentWidth(self)

	self.SetCurrent(self, (nValue - 0.5) * validRange)
end

M.GetSafeLength = function(self)
	return self.m_SafeEnd - self.m_SafeStart
end

M._ReadPositionsFromTrans = function(self)
	local halfBg = self.GetBackgroundWidth(self) / 2

	if self.bindData.safeIntervalTrans then
		local center = self.bindData.safeIntervalTrans.anchoredPosition.x
		local halfW = self.bindData.safeIntervalTrans.sizeDelta.x / 2
		self.m_SafeStart = Mathf.Clamp(center - halfW, -halfBg, halfBg)
		self.m_SafeEnd = Mathf.Clamp(center + halfW, self.m_SafeStart, halfBg)
	end

	if self.bindData.currentTrans then
		self.m_Current = self.bindData.currentTrans.anchoredPosition.x
		local halfCurrent = self.GetCurrentWidth(self) / 2
		local limit = halfBg - halfCurrent
		self.m_Current = Mathf.Clamp(self.m_Current, -limit, limit)
	end
end

M._RefreshUI = function(self)
	local bgWidth = self.GetBackgroundWidth(self)

	if bgWidth < 0 then
		return
	end

	if self.bindData.safeIntervalTrans then
		self.bindData.safeIntervalTrans.anchoredPosition = Vector2.New((self.m_SafeStart + self.m_SafeEnd) * 0.5, self.bindData.safeIntervalTrans.anchoredPosition.y)
		self.bindData.safeIntervalTrans.sizeDelta = Vector2.New(self.m_SafeEnd - self.m_SafeStart, self.bindData.safeIntervalTrans.sizeDelta.y)
	end

	if self.bindData.currentTrans then
		self.bindData.currentTrans.anchoredPosition = Vector2.New(self.m_Current, self.bindData.currentTrans.anchoredPosition.y)
	end
end
