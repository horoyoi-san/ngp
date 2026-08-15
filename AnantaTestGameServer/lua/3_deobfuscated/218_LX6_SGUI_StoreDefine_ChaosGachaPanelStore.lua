C_ChaosGachaPanelStore = DefClass("C_ChaosGachaPanelStore", C_ChaosGachaPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaPanelStore = C_ChaosGachaPanelStore
local M = C_ChaosGachaPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
		PreLoad = true,
		videoId = 24100203
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

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.gachaTenBtn.luaClick = self:CreateAction("OnClickGachaTenBtn")
	self.bindData.gachaBtn.luaClick = self:CreateAction("OnClickGachaBtn")
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.panelId)
end

function M:OnClickGachaTenBtn()
	gClientToGameDelegate:AskChaosMasterGacha(self.poolId, 10).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
				immediateExitCb = true,
				videoId = 24100203,
				isLoop = false,
				exitCb = function ()
					gPanelManager:CheckShow(gPanelId.CHAOS_GACHA_RESULT_TEN_PANEL, data)
					FrameTimer.New(function ()
						if not self.STATE_EnableOnce then
							return
						end

						gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
							PreLoad = true,
							videoId = 24100203
						})
					end, 1):Start()
				end
			})
		else
			gDisplayMessageMgr:ShowMessageContent(gCS.Error.GetNameById(err))
		end
	end
end

function M:OnClickGachaBtn()
	gClientToGameDelegate:AskChaosMasterGacha(self.poolId, 1).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
				immediateExitCb = true,
				videoId = 24100203,
				isLoop = false,
				exitCb = function ()
					gPanelManager:CheckShow(gPanelId.CHAOS_GACHA_RESULT_ONE_PANEL, data)
					FrameTimer.New(function ()
						if not self.STATE_EnableOnce then
							return
						end

						gPanelManager:CheckShow(gPanelId.S_VIDEO_PLAYER_PANEL, {
							PreLoad = true,
							videoId = 24100203
						})
					end, 1):Start()
				end
			})
		else
			gDisplayMessageMgr:ShowMessageContent(gCS.Error.GetNameById(err))
		end
	end
end
