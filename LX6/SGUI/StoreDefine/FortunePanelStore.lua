-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FortunePanelStore.lua
-- Decompiled from: 01866_FortunePanelStore.lua_68e11d29a55b.luajit

C_FortunePanelStore = DefClass("C_FortunePanelStore", C_FortunePanelStore, C_StoreGroup)
GroupName2Class.FortunePanelStore = C_FortunePanelStore
local M = C_FortunePanelStore
local GENDER = {
	[":M\\x9c\\x8f\\x8fD"] = 1,
	["W#q^"] = 0,
	["b\\xba\\xaa\\xaa\\xa4"] = 2
}
local TIME_TYPE = {
	["\\xaai"] = 2,
	["R-hI"] = 3,
	["`\\xa1\\xac\\xbb\\xbe"] = 1,
	["C'|I"] = 0
}
local WISH = {
	["V-k^"] = 2,
	["?I\\x83\\x8b\\x86S"] = 3,
	["+M\\x90\\x82\\x97I"] = 1,
	["\\xfe\\xde%\\xfd"] = 0
}
local WISH_TO_SERVER = {
	[WISH.General] = 3,
	[WISH.Wealth] = 0,
	[WISH.Love] = 1,
	[WISH.Career] = 2
}
local INPUT_MODE = {
	["1I\\x9f\\x9b\\x82M"] = 0,
	["\\xfd\\xde\t*\\xe8"] = 1
}
local RESULT_TYPE = {
	["]-r_"] = 0,
	["\\xacib"] = 1
}
local FORTUNE_REQ_TYPE = {
	["~\\xba\\xa3\\xbd\\xa2"] = 1,
	["qBJf\\\n="] = 2
}
local START_YEAR = 1900
local DEFAULT_YEAR = 2000
local DEFAULT_MONTH = 1
local DEFAULT_DAY = 1
local TIAN_GAN = {
	"\t\\x9c\\xb4",
	"\n\\xb1\\x9f",
	"\n\\xb0\\x9f",
	"\n\\xb0\\x87",
	"\\x80\\x8c",
	"\\xbf\\xb7",
	"\\xb2\\x9c",
	"\\xb6\\x9d",
	"\\xab\\xaa",
	"\t\\x91\\xbe"
}
local DI_ZHI = {
	"\\xa5\\x96",
	"\n\\xb0\\x97",
	"\\xa7\\x83",
	"\\x85\\xa9",
	"\\xb6\\xb6",
	"\\xbf\\xb5",
	"\\x85\\x8e",
	"\\x94\\xac",
	"\t\\x9c\\xb5",
	"\\x8d\\x8f",
	"\\x80\\x8a",
	"\n\\xb2\\xa3"
}
local MONTH_GAN_START = {
	[0] = 2,
	4,
	6,
	8,
	0
}
local HOUR_GAN_START = {
	[0] = 0,
	2,
	4,
	6,
	8
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.gadgetId = nil
	self.playerName = ""
	self.gender = nil
	self.inputMode = INPUT_MODE.Manual
	self.birthdayItems = nil
	self.wishType = WISH.General
	self.confirmedWish = nil
	self.result = nil
	self.requestingFortune = false
	self.fortuneRequestType = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.gadgetId = data and data.gadgetId or nil

	self:ApplyPivot(data and data.pivot)
	self:ResetData()
	self:InitPage1()
	self:GotoPage1()
end

M.ApplyPivot = function(self, pivot)
	if not pivot or not self.rootGo then
		return
	end

	local tf = self.rootGo.transform

	if pivot.position then
		tf.position = pivot.position
	end

	if pivot.eulerAngles then
		tf.eulerAngles = pivot.eulerAngles
	end

	if pivot.localScale then
		tf.localScale = pivot.localScale
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.ResetData = function(self)
	self.playerName = ""
	self.gender = nil
	self.inputMode = INPUT_MODE.Manual
	self.wishType = WISH.General
	self.confirmedWish = nil
	self.result = nil

	self.BuildBirthdayItems(self)
end

M.GetCurrentYear = function(self)
	return tonumber(os.date("%Y", gCS.TimeManager.ServerUnixTime))
end

M.GetDaysInMonth = function(self, year, month)
	local days = {
		31,
		28,
		31,
		30,
		31,
		30,
		31,
		31,
		30,
		31,
		30,
		31
	}

	if month ~= 2 then
		local isLeap = year % 4 ~= 0 and year % 100 == 0 or year % 400 ~= 0

		return isLeap and 29 or 28
	end

	return days[month] or 31
end

M.BuildBirthdayItems = function(self)
	self.birthdayItems = {
		{
			timeType = TIME_TYPE.Year,
			selectedIndex = self.GetCurrentYear(self) - DEFAULT_YEAR
		},
		{
			timeType = TIME_TYPE.Month,
			selectedIndex = DEFAULT_MONTH - 1
		},
		{
			timeType = TIME_TYPE.Day,
			selectedIndex = DEFAULT_DAY - 1
		},
		{
			timeType = TIME_TYPE.Hour
		}
	}

	self.RefreshBirthdayOptions(self)
end

M.RefreshBirthdayOptions = function(self)
	local curYear = self.GetCurrentYear(self)

	for _, item in ipairs(self.birthdayItems) do
		local options = {}

		if item.timeType ~= TIME_TYPE.Year then
			for y = curYear, START_YEAR, -1 do
				table.insert(options, tostring(y))
			end
		elseif item.timeType ~= TIME_TYPE.Month then
			for mo = 1, 12 do
				table.insert(options, tostring(mo))
			end
		elseif item.timeType ~= TIME_TYPE.Day then
			local dayCount = self.GetDaysInMonth(self, self.GetSelectedYear(self), self.GetSelectedMonth(self))

			for d = 1, dayCount do
				table.insert(options, tostring(d))
			end
		elseif item.timeType ~= TIME_TYPE.Hour then
			for h = 0, 23 do
				table.insert(options, tostring(h))
			end
		end

		item.options = options

		if item.selectedIndex == nil and item.selectedIndex <= #options - 1 then
			item.selectedIndex = 0
		end
	end
end

M.GetBirthdayItemByType = function(self, timeType)
	for _, item in ipairs(self.birthdayItems) do
		if item.timeType ~= timeType then
			return item
		end
	end

	return nil
end

M.GetSelectedYear = function(self)
	local item = self.GetBirthdayItemByType(self, TIME_TYPE.Year)

	if not item or item.selectedIndex ~= nil then
		return DEFAULT_YEAR
	end

	return self.GetCurrentYear(self) - item.selectedIndex
end

M.GetSelectedMonth = function(self)
	local item = self.GetBirthdayItemByType(self, TIME_TYPE.Month)

	if not item or item.selectedIndex ~= nil then
		return DEFAULT_MONTH
	end

	return item.selectedIndex + 1
end

M.GetSelectedDay = function(self)
	local item = self.GetBirthdayItemByType(self, TIME_TYPE.Day)

	if not item or item.selectedIndex ~= nil then
		return DEFAULT_DAY
	end

	return item.selectedIndex + 1
end

M.GetSelectedHour = function(self)
	local item = self.GetBirthdayItemByType(self, TIME_TYPE.Hour)

	if not item or item.selectedIndex ~= nil then
		return nil
	end

	return item.selectedIndex
end

M.GetDaysFrom1970 = function(self, y, m, d)
	if m < 2 then
		y = y - 1
	end

	local era = math.floor((y > 0 and y or y - 399) / 400)
	local yoe = y - era * 400
	local doy = math.floor((153 * (m <= 2 and m - 3 or m + 9) + 2) / 5) + d - 1
	local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy

	return era * 146097 + doe - 719468
end

M.GetYearGanZhi = function(self, year)
	local gan = TIAN_GAN[(year - 4) % 10 + 1]
	local zhi = DI_ZHI[(year - 4) % 12 + 1]

	return gan .. zhi
end

M.GetMonthGanZhi = function(self, year, month)
	local yearGanIndex = (year - 4) % 10
	local startGan = MONTH_GAN_START[yearGanIndex % 5]
	local ganIndex = (startGan + month - 1) % 10
	local zhiIndex = (month + 1) % 12

	return TIAN_GAN[ganIndex + 1] .. DI_ZHI[zhiIndex + 1]
end

M.GetDayPosition = function(self, year, month, day)
	return (self.GetDaysFrom1970(self, year, month, day) + 37) % 60
end

M.GetDayGanZhi = function(self, year, month, day)
	local pos = self.GetDayPosition(self, year, month, day)

	return TIAN_GAN[pos % 10 + 1] .. DI_ZHI[pos % 12 + 1]
end

M.GetHourGanZhi = function(self, year, month, day, hour)
	local dayGanIndex = self.GetDayPosition(self, year, month, day) % 10
	local startGan = HOUR_GAN_START[dayGanIndex % 5]
	local zhiIndex = math.floor((hour + 1) / 2) % 12
	local ganIndex = (startGan + zhiIndex) % 10

	return TIAN_GAN[ganIndex + 1] .. DI_ZHI[zhiIndex + 1]
end

M.GetPillarGanZhi = function(self, timeType)
	local year = self.GetSelectedYear(self)
	local month = self.GetSelectedMonth(self)
	local day = self.GetSelectedDay(self)

	if timeType ~= TIME_TYPE.Year then
		return self.GetYearGanZhi(self, year)
	elseif timeType ~= TIME_TYPE.Month then
		return self.GetMonthGanZhi(self, year, month)
	elseif timeType ~= TIME_TYPE.Day then
		return self.GetDayGanZhi(self, year, month, day)
	elseif timeType ~= TIME_TYPE.Hour then
		local hour = self.GetSelectedHour(self)

		if hour ~= nil then
			return ""
		end

		return self.GetHourGanZhi(self, year, month, day, hour)
	end

	return ""
end

M.IsBaziComplete = function(self)
	for _, item in ipairs(self.birthdayItems) do
		if item.selectedIndex ~= nil then
			return false
		end
	end

	return true
end

M.GotoPage1 = function(self)
	self.bindData.pageCtrl = self.pageCtrlEnum.default0
end

M.GotoPage2 = function(self)
	self.bindData.pageCtrl = self.pageCtrlEnum.default1

	self.InitPage2(self)
end

M.GotoPage3 = function(self)
	self.confirmedWish = nil
	self.bindData.pageCtrl = self.pageCtrlEnum.default2

	self.InitPage3(self)
end

M.InitPage1 = function(self)
	self.bindData.inputNameP1.text = self.playerName

	self.bindData.genderListP1:SetSimpleList(3)
	self.bindData.birthdayListP1:SetSimpleList(#self.birthdayItems)
	self:RefreshManualConfirmBtn()
end

M.IsManualInfoReady = function(self)
	return self.playerName == nil and self.playerName == "" and self.gender == nil and self:IsBaziComplete()
end

M.RefreshManualConfirmBtn = function(self)
	self.bindData.manualConfirmBtnP1.interactable = self.IsManualInfoReady(self)
end

M.InitPage2 = function(self)
	self.bindData.confirmBtnP2.interactable = true
	self.bindData.backBtnP2.interactable = true

	self.bindData.choseBoxListP2:SetSimpleList(4)
end

M.ConvertStrArray = function(self, arr)
	local list = {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0
	}

	if not arr then
		return list
	end

	local n = arr.Length or 0

	for i = 1, n do
		list[i] = arr[i]
	end

	list.Count = n

	return list
end

M.ApplyFakeFortuneConfig = function(self)
	local result = self.result

	if not result then
		return
	end

	local fakeId = result.FakeFortuneId or 0

	if fakeId ~= 0 then
		return
	end

	local cfg = LTConfig.TempleInteractionFortuneMachineConfig.GetConfig(fakeId)

	if not cfg then
		return
	end

	result.Poem = {
		cfg.SignText or "",
		["n\\xa1\\xb7\\xa1\\xa2"] = 1
	}
	result.Interpretation = cfg.Interpretation or ""
	result.TodayGood = self:ConvertStrArray(cfg.Suitable)
	result.TodayBad = self:ConvertStrArray(cfg.Taboo)
end

M.InitPage3 = function(self)
	local result = self.result

	if not result then
		return
	end

	self:ApplyFakeFortuneConfig()

	self.bindData.fortuneLevelTextP3 = result.FortuneLevel or ""
	self.bindData.poemTextP3 = self:JoinStringList(result.Poem, " ")
	self.bindData.interpretationTextP3 = result.Interpretation or ""
	local goodCount = result.TodayGood and result.TodayGood.Count or 0
	local badCount = result.TodayBad and result.TodayBad.Count or 0

	self.bindData.todayGoodListP3:SetSimpleList(goodCount)
	self.bindData.todayBadListP3:SetSimpleList(badCount)
end

M.JoinStringList = function(self, list, sep)
	if not list or list.Count ~= 0 then
		return ""
	end

	local strs = {}

	for i = 1, list.Count do
		table.insert(strs, list[i])
	end

	return table.concat(strs, sep)
end

M.BuildStartParams = function(self)
	return {
		PlayerName = self.playerName or "",
		Gender = self.gender or 2,
		Year = self:GetSelectedYear(),
		Month = self:GetSelectedMonth(),
		Day = self:GetSelectedDay(),
		Hour = self:GetSelectedHour(),
		WishType = WISH_TO_SERVER[self.wishType] or 3,
		InputMode = self.inputMode,
		Language = self:GetCurLanguageAbbreviation() or ""
	}
end

M.GetCurLanguageAbbreviation = function(self)
	local langIdx = LX6.Engine.ProfileManager.languageProfile.textLanguage
	local langCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(langIdx)

	return langCfg and langCfg.Abbreviation
end

M.RequestStartFortune = function(self)
	if not self.gadgetId then
		return
	end

	if self.requestingFortune then
		return
	end

	self.requestingFortune = true
	self.fortuneRequestType = FORTUNE_REQ_TYPE.Start
	self.bindData.confirmBtnP2.interactable = false
	self.bindData.backBtnP2.interactable = false
	slot1 = gClientToGameDelegate

	slot1:AskStartFortune(self.gadgetId, self:BuildStartParams()).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self.requestingFortune = false
			self.fortuneRequestType = nil
			self.bindData.confirmBtnP2.interactable = true
			self.bindData.backBtnP2.interactable = true

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.RequestReFortune = function(self)
	if not self.gadgetId then
		return
	end

	if self.requestingFortune then
		return
	end

	self.requestingFortune = true
	self.fortuneRequestType = FORTUNE_REQ_TYPE.ReFortune
	self.bindData.againBtnP3.interactable = false
	self.bindData.backBtnP3.interactable = false
	slot1 = gClientToGameDelegate

	slot1:AskReFortune(self.gadgetId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self.requestingFortune = false
			self.fortuneRequestType = nil
			self.bindData.againBtnP3.interactable = true
			self.bindData.backBtnP3.interactable = true

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.OnSyncFortuneResult = function(self, gadgetId, result)
	if not self.gadgetId or tostring(gadgetId) == tostring(self.gadgetId) then
		return
	end

	self.result = result
	self.requestingFortune = false

	if self.fortuneRequestType ~= FORTUNE_REQ_TYPE.ReFortune then
		self.bindData.againBtnP3.interactable = true
		self.bindData.backBtnP3.interactable = true

		self.InitPage3(self)
	else
		self.GotoPage3(self)

		self.bindData.againBtnP3.interactable = true
		self.bindData.backBtnP3.interactable = true
	end

	self.fortuneRequestType = nil
end

M.RegisterWidget = function(self)
	self.bindData.manualConfirmBtnP1.luaClick = self.CreateAction(self, self.OnClickManualConfirmBtnP1)
	self.bindData.destinyConfirmBtnP1.luaClick = self.CreateAction(self, self.OnClickDestinyConfirmBtnP1)
	self.bindData.backBtnP2.luaClick = self.CreateAction(self, self.OnClickBackBtnP2)
	self.bindData.confirmBtnP2.luaClick = self.CreateAction(self, self.OnClickConfirmBtnP2)
	self.bindData.backBtnP3.luaClick = self.CreateAction(self, self.OnClickBackBtnP3)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.againBtnP3.luaClick = self.CreateAction(self, self.OnClickAgainBtnP3)
	self.bindData.genderListP1.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGenderListP1Item)
	self.bindData.birthdayListP1.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBirthdayListP1Item)
	self.bindData.choseBoxListP2.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderChoseBoxListP2Item)
	self.bindData.todayGoodListP3.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTodayGoodListP3Item)
	self.bindData.todayBadListP3.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTodayBadListP3Item)
	self.bindData.inputNameP1.luaValueChanged = self.CreateAction(self, self.OnInputNameP1InputValueChanged)
end

M.OnClickManualConfirmBtnP1 = function(self)
	self.inputMode = INPUT_MODE.Manual

	self.GotoPage2(self)
end

M.OnClickDestinyConfirmBtnP1 = function(self)
	self.inputMode = INPUT_MODE.Destiny

	self.GotoPage2(self)
end

M.OnClickBackBtnP2 = function(self)
	self.GotoPage1(self)
end

M.OnClickConfirmBtnP2 = function(self)
	self.confirmedWish = self.wishType

	self.bindData.choseBoxListP2:RefreshList()
	self:RequestStartFortune()
end

M.OnClickBackBtnP3 = function(self)
	self.GotoPage1(self)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickAgainBtnP3 = function(self)
	self.RequestReFortune(self)
end

M.OnSimpleRenderGenderListP1Item = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local gender = index
	store.genderCtrl = gender

	store.selfBtn:SetSelected(self.gender ~= gender)

	store.selfBtn.luaClick = self:CreateActionWithArgs(self.OnClickGenderSelf, gender)
end

M.OnClickGenderSelf = function(self, gender)
	self.gender = gender

	self.bindData.genderListP1:RefreshList()
	self:RefreshManualConfirmBtn()
end

M.OnSimpleRenderBirthdayListP1Item = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local item = self.birthdayItems[index + 1]

	if not item then
		return
	end

	store.timeCtrl = item.timeType
	store.stateCtrl = item.timeType
	local selector = store.ageSelector
	selector.luaSelectedChanged = nil
	selector.options = nil

	for i = 1, #item.options do
		selector:AddSimpleOptionLabel(0, item.options[i], i - 1 ~= item.selectedIndex)
	end

	selector:SelectOption(item.selectedIndex == nil and item.selectedIndex or -1, false)

	selector.luaSelectedChanged = self:CreateActionWithArgs(self.OnBirthdaySelectorChanged, item.timeType)

	if item.selectedIndex == nil then
		store.isSelectedCtrl = 1
		store.ageSelectTitle = self.GetPillarGanZhi(self, item.timeType)
	else
		store.isSelectedCtrl = 0
		store.ageSelectTitle = ""
	end
end

M.OnBirthdaySelectorChanged = function(self, timeType, selector)
	local item = self.GetBirthdayItemByType(self, timeType)

	if not item then
		return
	end

	item.selectedIndex = selector.selectedIndex

	if timeType ~= TIME_TYPE.Year or timeType ~= TIME_TYPE.Month then
		self.RefreshBirthdayOptions(self)
	end

	self.bindData.birthdayListP1:RefreshList()
	self:RefreshManualConfirmBtn()
end

M.OnSimpleRenderChoseBoxListP2Item = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local wish = index
	store.selectCtrl = wish
	store.noselectCtrl = wish
	store.typeCtrl = self.wishType ~= wish and 1 or 0
	store.showResultCtrl = self.confirmedWish ~= wish and 1 or 0
	store.selfBtn.luaClick = self:CreateActionWithArgs(self.OnClickBoxSelf, wish)
end

M.OnClickBoxSelf = function(self, wish)
	if self.requestingFortune then
		return
	end

	self.wishType = wish

	self.bindData.choseBoxListP2:RefreshList()
end

M.OnSimpleRenderTodayGoodListP3Item = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local list = self.result and self.result.TodayGood

	if not list then
		return
	end

	store.typeCtrl = RESULT_TYPE.Good
	store.resultText = list[index]
end

M.OnSimpleRenderTodayBadListP3Item = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local list = self.result and self.result.TodayBad

	if not list then
		return
	end

	store.typeCtrl = RESULT_TYPE.Bad
	store.resultText = list[index]
end

M.OnInputNameP1InputValueChanged = function(self, text)
	self.playerName = text or ""

	self:RefreshManualConfirmBtn()
end
