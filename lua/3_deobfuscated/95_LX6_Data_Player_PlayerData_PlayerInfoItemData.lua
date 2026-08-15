local DataSet = require("LX6/DataBind/DataSet")
local ConsumableConfig = LTConfig.ConsumableConfig
C_PlayerInfoItemData = DefClass("C_PlayerInfoItemData", C_PlayerInfoItemData, C_PlayerDataBase)
local M = C_PlayerInfoItemData

function M:DefineData()
	self.DataSet_Template = {}
	self.bindData = DataSet.New()
	self.pack = DataSet.New({
		destructibleShortcut = 0,
		itemUseTimes = {},
		itemShortcutDic = {},
		lingPeiYangPacks = {},
		lingScrollPacks = {},
		otherItems = {}
	})
end

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.money = info.InfoItem.Money
	t.lastMoney = info.InfoItem.Money
	t.gold = info.InfoItem.Gold + info.InfoItem.FreeGold
	t.bindGold = info.InfoItem.BindingGold
	t.todayGachaCount = info.InfoItem.TodayGachaCount
	t.gachaPoolCount = info.InfoItem.GachaPoolCount
	t.itemCountLimitInfoList = info.InfoItem.ItemCountLimitInfoList
	t.todayGachaCountUpdateTime = gLuaDataManager.serverTime
	t.portalPosition = info.InfoItem.PortalPosition
	t.portalRaidId = info.InfoItem.PortalRaidId
	self.pack.itemShortcutDic = info.InfoItem.ItemShortcutDic
	self.pack.destructibleShortcut = info.InfoItem.DestructibleShortcut
	self.pack.itemUseTimes = {}

	for i = 1, info.InfoItem.ItemDayCounts.Count do
		local playerItemDayCount = info.InfoItem.ItemDayCounts[i]
		self.pack.itemUseTimes[playerItemDayCount.TemplateId] = playerItemDayCount.Count
	end

	self.pack.packTabListCapacity = array.concat({
		0,
		0,
		0
	}, ConsumableConfig.TabCapacity)

	gCommonItemManager:OnSyncQuantumWalletInfo(info.InfoItem.QuantumWalletStartTime)
	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
