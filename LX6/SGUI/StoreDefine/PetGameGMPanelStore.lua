-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameGMPanelStore.lua
-- Decompiled from: 00854_PetGameGMPanelStore.lua_a41f4fa42513.luajit

C_PetGameGMPanelStore = DefClass("C_PetGameGMPanelStore", C_PetGameGMPanelStore, C_StoreGroup)
GroupName2Class.PetGameGMPanelStore = C_PetGameGMPanelStore
local M = C_PetGameGMPanelStore
local UXTime = LTUtils.UXTime
local DateTime = System.DateTime
local petGameConstData = require("LX6/MiniGame/PetGame/data/tbconstants")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local StageShowType = PetGameConst.StageShowType

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.timeInputText = nil
	self.timeScaleInputText = nil
	self.panelId = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	self.ShowDefaultInputTime(self)
	self.ShowCurrentTimeScaleInfo(self)
	self.RefreshPanelInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.deathBtn.luaClick = self.CreateAction(self, self.OnClickDeathBtn)
	self.bindData.goToBedBtn.luaClick = self.CreateAction(self, self.OnClickGoToBedBtn)
	self.bindData.wakeUpBtn.luaClick = self.CreateAction(self, self.OnClickWakeUpBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.setTimeBtn.luaClick = self.CreateAction(self, self.OnClickSetTimeBtn)
	self.bindData.resetTimeBtn.luaClick = self.CreateAction(self, self.OnClickResetTimeBtn)
	self.bindData.enterNightTimeBtn.luaClick = self.CreateAction(self, self.OnClickEnterNightTimeBtn)
	self.bindData.enterMorningTimeBtn.luaClick = self.CreateAction(self, self.OnClickEnterMorningTimeBtn)
	self.bindData.timeScaleBtn.luaClick = self.CreateAction(self, self.OnClickTimeScaleBtn)
	self.bindData.passStoolBtn.luaClick = self.CreateAction(self, self.OnClickPassStoolBtn)
	self.bindData.cleanUpPoopBtn.luaClick = self.CreateAction(self, self.OnClickCleanUpPoopBtn)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, self.OnClickRefreshBtn)
	self.bindData.takeBatheBtn.luaClick = self.CreateAction(self, self.OnClickTakeBatheBtn)
	self.bindData.treatBtn.luaClick = self.CreateAction(self, self.OnClickTreatBtn)
	self.bindData.lvupBtn.luaClick = self.CreateAction(self, self.OnClickLvupBtn)
	self.bindData.interactiveWithFurBtn.luaClick = self.CreateAction(self, self.OnClickInteractiveWithFurBtn)
	self.bindData.timeInputField.luaValueChanged = self.CreateAction(self, self.OnTimeInputFieldInputValueChanged)
	self.bindData.timeScaleInput.luaValueChanged = self.CreateAction(self, self.OnTimeScaleInputInputValueChanged)
end

M.OnClickDeathBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.OnPetDie(pet)
	self.OnClickCloseBtn(self)
end

M.OnClickGoToBedBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.AheadOfGo2Sleep(pet)
	self.RefreshPanelInfo(self)
end

M.OnClickWakeUpBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.AheadOfWakeUp(pet)
	self.RefreshPanelInfo(self)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.panelId or self.m_Id or gPanelId.MINI_GAMES_PET_GAME_GM)
end

M.OnClickSetTimeBtn = function(self)
	local timeText = self.timeInputText or self.bindData.timeInputField.text

	if not timeText or timeText ~= "" then
		print_error("拓麻歌子 GM 设置时间失败：请输入时间")

		return
	end

	local parseSuccess, dateTime = pcall(function ()
		return DateTime.Parse(timeText)
	end)

	if not parseSuccess then
		print_error("拓麻歌子 GM 设置时间失败：时间格式不正确")

		return
	end

	gPetGameTime:SetTime(UXTime.DateTimeToUnixTime(dateTime))

	local pet = self:GetPet(false)

	if pet then
		pet.ResetPetTime(pet)
	end

	self.ShowDefaultInputTime(self)
	self.RefreshPanelInfo(self)
end

M.OnClickResetTimeBtn = function(self)
	gPetGameTime:ResetTime()

	local pet = self:GetPet(false)

	if pet then
		pet.ResetPetTime(pet)
	end

	self.ShowDefaultInputTime(self)
	self.RefreshPanelInfo(self)
end

M.OnClickEnterNightTimeBtn = function(self)
	self.EnterConfiguredTime(self, petGameConstData.data.RemindSleepTime)
end

M.OnClickEnterMorningTimeBtn = function(self)
	self.EnterConfiguredTime(self, petGameConstData.data.RemindWakeUpTime)
end

M.OnClickTimeScaleBtn = function(self)
	local timeScale = tonumber(self.timeScaleInputText or self.bindData.timeScaleInput.text)

	if not timeScale or timeScale >= 0 then
		print_error("拓麻歌子 GM 设置时间倍率失败：请输入大于等于 0 的数字")

		return
	end

	gPetGameTime:SetTimeScale(timeScale)
	self:ShowCurrentTimeScaleInfo()
end

M.OnClickPassStoolBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.PassStool(pet)
	self.RefreshPanelInfo(self)
end

M.OnClickCleanUpPoopBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	local args = {
		type = StageShowType.clearUpPoop
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_STAGE_SHOW_BEGIN, args)
end

M.OnClickRefreshBtn = function(self)
	self.RefreshPanelInfo(self)
end

M.OnClickTakeBatheBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.TakeBathe(pet)
	self.RefreshPanelInfo(self)
end

M.OnClickTreatBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	pet.Treat(pet)
	self.RefreshPanelInfo(self)
end

M.OnClickLvupBtn = function(self)
	local pet = self.GetPet(self)

	if not pet then
		return
	end

	local petInfo = pet.GetPetInfo(pet)

	if not petInfo or not petInfo.lifespan then
		print_error("拓麻歌子 GM 升级失败：找不到当前宠物配置")

		return
	end

	pet.attributes.age = petInfo.lifespan

	self.RefreshPanelInfo(self)
end

M.OnClickInteractiveWithFurBtn = function(self)
	if self.bindData.content then
		self.bindData.content.text = "当前单机宠物尚未迁移家具互动状态，暂时无法使用该功能。"
	end

	print_error("拓麻歌子 GM 家具互动失败：单机宠物尚未接入家具互动状态")
end

M.OnTimeInputFieldInputValueChanged = function(self, text)
	self.timeInputText = text
end

M.OnTimeScaleInputInputValueChanged = function(self, text)
	self.timeScaleInputText = text
end

M.GetPet = function(self, showError)
	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local pet = currentGame and currentGame.pet

	if not pet and showError == false then
		print_error("拓麻歌子 GM 操作失败：当前没有运行中的宠物存档")
	end

	return pet
end

M.UpdateTimeText = function(self)
	local now = UXTime.UnixTimeToDateTime(gPetGameTime:Now())
	self.bindData.curTimeText.text = string.format("当前游戏时间：%s", tostring(now))
end

M.ShowDefaultInputTime = function(self)
	local now = UXTime.UnixTimeToDateTime(gPetGameTime:Now())
	local timeText = tostring(now)
	self.timeInputText = timeText
	self.bindData.timeInputField.text = timeText

	self:UpdateTimeText()
end

M.ShowCurrentTimeScaleInfo = function(self)
	local timeScaleText = tostring(gPetGameTime:GetTimeScale())
	self.timeScaleInputText = timeScaleText
	self.bindData.timeScaleInput.text = timeScaleText
end

M.EnterConfiguredTime = function(self, timeConfig)
	if not timeConfig or not timeConfig.startTime then
		print_error("拓麻歌子 GM 跳转时间失败：缺少时间配置")

		return
	end

	local nowDateTime = UXTime.UnixTimeToDateTime(gPetGameTime:Now())

	if timeConfig.startTime < nowDateTime.Hour and nowDateTime.Hour >= timeConfig.endTime then
		return
	end

	local targetTime = DateTime.New(nowDateTime.Year, nowDateTime.Month, nowDateTime.Day, timeConfig.startTime, 0, 0)

	if timeConfig.startTime < nowDateTime.Hour then
		targetTime = targetTime.AddDays(targetTime, 1)
	end

	gPetGameTime:SetTime(UXTime.DateTimeToUnixTime(targetTime))
	self:ShowDefaultInputTime()
	self:RefreshPanelInfo()
end

M.RefreshPanelInfo = function(self)
	self.UpdateTimeText(self)

	local pet = self.GetPet(self, false)

	if not pet then
		self.bindData.content.text = "当前没有运行中的拓麻歌子存档。"

		return
	end

	local petInfo = pet:GetPetInfo()
	local lines = {
		string.format("宠物 ID：%s", tostring(pet:GetPetId())),
		string.format("等级：%s", tostring(petInfo and petInfo.level or 0)),
		string.format("地区：%s", tostring(pet:GetRegion())),
		string.format("年龄（秒）：%s", tostring(pet:GetAttribute("age"))),
		string.format("存活：%s", tostring(pet:IsAlive())),
		string.format("睡眠：%s", tostring(pet:IsSleeping())),
		string.format("生病：%s", tostring(pet:GetAttribute("isSicked"))),
		string.format("饱食：%s", tostring(pet:GetAttribute("hungerValue"))),
		string.format("心情：%s", tostring(pet:GetAttribute("moodValue"))),
		string.format("清洁：%s", tostring(pet:GetAttribute("cleanlinessValue"))),
		string.format("健康：%s", tostring(pet:GetAttribute("healthValue"))),
		string.format("幸福：%s", tostring(pet:GetAttribute("happinessValue"))),
		string.format("便便数量：%s", tostring(pet:GetAttribute("poopNum")))
	}
	self.bindData.content.text = table.concat(lines, "\n")
end
