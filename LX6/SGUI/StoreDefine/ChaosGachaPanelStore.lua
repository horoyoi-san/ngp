-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosGachaPanelStore.lua
-- Decompiled from: 01465_ChaosGachaPanelStore.lua_b9dc8a0835ec.luajit

C_ChaosGachaPanelStore = DefClass("C_ChaosGachaPanelStore", C_ChaosGachaPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaPanelStore = C_ChaosGachaPanelStore
local M = C_ChaosGachaPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
	gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
		["\\xe9\\xc91%\\xf5"] = true,
		["\\xcf\\xd2\r\\xf5"] = 24100203
	})

	self.panelId = panelId
	local poolId = 1

	if data and data.poolId then
		poolId = data.poolId
	end

	self.poolId = poolId
	local poolConfig = LTConfig.ChaosMastergachaConfig.GetConfig(poolId)

	if poolConfig.IconId then
		self.bindData.bannerIconId = poolConfig.IconId
	end

	self.bindData.onePrice = poolConfig.Cost
	self.bindData.tenPrice = poolConfig.Cost * 10

	if poolConfig.MoneyIcon then
		self.bindData.moneyIcon = poolConfig.MoneyIcon
	end

	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.gachaTenBtn.luaClick = self.CreateAction(self, "OnClickGachaTenBtn")
	self.bindData.gachaBtn.luaClick = self.CreateAction(self, "OnClickGachaBtn")
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.panelId)
end

M.OnClickGachaTenBtn = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskChaosMasterGacha(self.poolId, 10).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
				["*'-\\xe1w\\x91\\xf6 \\xad\n\\xfe\\xfb\\xf2W\\xf9"] = true,
				["\\xcf\\xd2\r\\xf5"] = 24100203,
				["[\\xbd\\x81\\x8cQ"] = false,
				exitCb = function ()
					gPanelManager:CheckShow(gPanelId.CHAOS_GACHA_RESULT_TEN_PANEL, data)
					FrameTimer.New(function ()
						if not self.STATE_EnableOnce then
							return
						end

						gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
							["\\xe9\\xc91%\\xf5"] = true,
							["\\xcf\\xd2\r\\xf5"] = 24100203
						})
					end, 1):Start()
				end
			})
		else
			gDisplayMessageMgr:ShowMessageContent(gCS.Error.GetNameById(err))
		end
	end
end

M.OnClickGachaBtn = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskChaosMasterGacha(self.poolId, 1).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
				["*'-\\xe1w\\x91\\xf6 \\xad\n\\xfe\\xfb\\xf2W\\xf9"] = true,
				["\\xcf\\xd2\r\\xf5"] = 24100203,
				["[\\xbd\\x81\\x8cQ"] = false,
				exitCb = function ()
					gPanelManager:CheckShow(gPanelId.CHAOS_GACHA_RESULT_ONE_PANEL, data)
					FrameTimer.New(function ()
						if not self.STATE_EnableOnce then
							return
						end

						gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
							["\\xe9\\xc91%\\xf5"] = true,
							["\\xcf\\xd2\r\\xf5"] = 24100203
						})
					end, 1):Start()
				end
			})
		else
			gDisplayMessageMgr:ShowMessageContent(gCS.Error.GetNameById(err))
		end
	end
end
