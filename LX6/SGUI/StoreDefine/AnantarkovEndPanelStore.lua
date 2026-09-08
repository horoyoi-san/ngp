-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovEndPanelStore.lua
-- Decompiled from: 01612_AnantarkovEndPanelStore.lua_c187f56a6164.luajit

C_AnantarkovEndPanelStore = DefClass("C_AnantarkovEndPanelStore", C_AnantarkovEndPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovEndPanelStore = C_AnantarkovEndPanelStore
local M = C_AnantarkovEndPanelStore
local ExtractionShooterConfig = LTConfig.ExtractionShooterConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.finishStatusCtrlEnum = {
		[":I\\x98\\x82\\x86E"] = 1,
		["\\xea\\xce7\\xe2"] = 0
	}
	self.pageCtrlEnum = {
		["}\\xaf\\xa5\\xaa\\xe4"] = 1,
		["}\\xaf\\xa5\\xaa\\xe7"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.finishStatusCtrlEnum = nil
	self.pageCtrlEnum = nil
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
	self.nextPageCountdownCo = coroutine.stop(self.nextPageCountdownCo)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.data = data
	local selfOnlineChallengeData = gLinkManager.selfOnlineChallengeData

	if selfOnlineChallengeData then
		self.extractionSettleData = selfOnlineChallengeData.extractionSettleData
	end

	if data.isSuccess then
		self.RefreshSuccessPage1(self)

		self.bindData.finishStatusCtrl = self.finishStatusCtrlEnum.Success
	else
		self.RefreshFailPage1(self)

		self.bindData.finishStatusCtrl = self.finishStatusCtrlEnum.Failed
	end

	self.bindData.durationPage1 = self.GetDurationText(self)

	self.StartCountdown(self)
end

M.GetDurationText = function(self)
	local totalDuration = gLinkManager.selfOnlineChallengeData.time or 0

	return gClientUtils.FormatTimeToMMSS(totalDuration)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RefreshSuccessPage1 = function(self)
	local extractionPointName = self.GetExtractionPointName(self)
	self.bindData.evacuatePointPage1 = extractionPointName
end

M.RefreshFailPage1 = function(self)
	local reasonText = self.GetFailReason(self)
	self.bindData.failReasonPage1 = reasonText
end

M.GetExtractionPointName = function(self)
	if not self.extractionSettleData then
		return
	end

	local extractionPointId = self.extractionSettleData.ExtractionPointId
	local evacuationPlaces = gMapSubSystem_EvacuationPlace.items

	if not evacuationPlaces then
		return
	end

	local extractionPointName = evacuationPlaces[extractionPointId] and evacuationPlaces[extractionPointId].mData.lName.cfg.Name or ""

	return extractionPointName
end

M.GetFailReason = function(self)
	if not self.extractionSettleData then
		return
	end

	local reason = self.extractionSettleData.Reason

	if reason ~= 1 then
		return ExtractionShooterConfig.ExtractFailForDeath
	elseif reason ~= 2 then
		return ExtractionShooterConfig.ExtractFailForTimeOut
	elseif reason ~= 3 then
		return ExtractionShooterConfig.ExtractFailForForceQuit
	end
end

M.GetIncome = function(self)
	if not self.extractionSettleData then
		return 0
	end

	local income = self.extractionSettleData.BringOutItemTotalPrice

	return income
end

M.StartCountdown = function(self)
	self.nextPageCountdownCo = coroutine.stop(self.nextPageCountdownCo)
	local leftTime = ExtractionShooterConfig.ToNextSettleHubTime
	self.nextPageCountdownCo = coroutine.start(function ()
		while leftTime <= 0 do
			self.bindData.leftTime = ExtractionShooterConfig.ToNextSettleHubText:format(leftTime)

			coroutine.wait(1)

			leftTime = leftTime - 1
		end

		self:ShowNextPage()
	end)
end

M.ShowNextPage = function(self)
	self.bindData.pageCtrl = self.pageCtrlEnum.Page2
	self.bindData.durationPage2 = self.GetDurationText(self)
	self.bindData.income = self.GetIncome(self)

	if self.data.isSuccess then
		self.RefreshSuccessPage2(self)
	else
		self.RefreshFailPage2(self)
	end
end

M.RefreshSuccessPage2 = function(self)
	local extractionPointName = self.GetExtractionPointName(self)
	self.bindData.evacuatePointPage2 = extractionPointName
end

M.RefreshFailPage2 = function(self)
	local reasonText = self.GetFailReason(self)
	self.bindData.failReasonPage2 = reasonText
end

M.RegisterWidget = function(self)
	self.bindData.continueButtonPage1.luaClick = self.CreateAction(self, self.OnClickContinueButtonPage1)
	self.bindData.continueButtonPage2.luaClick = self.CreateAction(self, self.OnClickContinueButtonPage2)
end

M.OnClickContinueButtonPage1 = function(self)
	self.ShowNextPage(self)
end

M.OnClickContinueButtonPage2 = function(self)
	gExtractionShooterManager:OnEndPanelContinue(self.data.isSuccess)
end
