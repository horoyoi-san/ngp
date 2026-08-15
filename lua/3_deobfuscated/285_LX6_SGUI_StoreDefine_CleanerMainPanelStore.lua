C_CleanerMainPanelStore = DefClass("C_CleanerMainPanelStore", C_CleanerMainPanelStore, C_StoreGroup)
GroupName2Class.CleanerMainPanelStore = C_CleanerMainPanelStore
local M = C_CleanerMainPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	local rate = math.floor(data.CleaningProcess * 1000) * 0.1

	if rate > 100 then
		rate = 100
	end

	self.bindData.rate = rate .. "%"
	local dropId = data.DropId
	local time = data.TotalSecond
	local second = time % 60
	local minute = math.floor(time / 60)
	local hour = math.floor(minute / 60)
	local cfg = LTConfig.DropConfig.GetConfig(dropId)
	minute = minute % 60

	if hour == 0 then
		self.bindData.time = string.format("%02d:%02d", minute, second)
	else
		self.bindData.time = string.format("%02d:%02d:%02d", hour, minute, second)
	end

	self.bindData.count = cfg.Money
	local itemCfg = LTConfig.ConsumableConfig.GetConfig(LTConfig.ConsumableConfig.RewardMoney)
	self.bindData.icon = itemCfg.SItemIconId

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_CLEAR_MAIN)
	end, LTConfig.WasherConfig.RewardPanelDuration, nil, nil, true)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
