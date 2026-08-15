local MessageConfig = LTConfig.MessageConfig
local LayerConstants = LX6.Constants.LayerConstants
local MiniGameSheet1Config = LTConfig.MiniGameSheet1Config
local MiniGameConfig = LTConfig.MiniGameConfig
C_CoinIndiePagePanelStore = DefClass("C_CoinIndiePagePanelStore", C_CoinIndiePagePanelStore, C_StoreGroup)
GroupName2Class.CoinIndiePagePanelStore = C_CoinIndiePagePanelStore
local M = C_CoinIndiePagePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.btnBack.luaClick = self:CreateAction("OnBtnBack")
	self.bindData.btnConfirmMobile.luaClick = self:CreateAction("OnBtnConfirm")
	self.bindData.btnConfirmPC.luaClick = self:CreateAction("OnBtnConfirm")
	self.dataSetEvents = {
		{
			gPlayerManager.infoItem.bindData,
			"money",
			self:CreateAction("RefreshBtnStyle")
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:OnDestroy()
	self:ClearDataSetEvents()
end

function M:OnShow(panelId, data)
	if not data then
		print_error("CoinIndiePagePanelStore 缺少data")
		gPanelManager:Close(gPanelId.S_COIN_INDIE_PAGE_PANEL)

		return
	end

	self.miniGameType = data.miniGameType or tonumber(data[1])
	self.exitInteractionType = data[2] and tonumber(data[2]) or 17

	if data and data.exitInteractionType then
		self.exitInteractionType = data.exitInteractionType
	end

	self.LuaSlotEntity = data[3]

	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)

	local cfg = MiniGameSheet1Config.GetConfig(self.miniGameType)
	self.onceCost = cfg.GameCost
	self.bindData.cost = self.onceCost

	self:SetCamera()
end

function M:OnClose()
	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_COIN_INDIE_PAGE_PANEL)

	if gSceneGameRuleManager.exitInteractionType < 0 and self.exitInteractionType > 0 then
		gInteractionManager:SetCommonInteractEnd(self.exitInteractionType)
	end
end

function M:SetCamera()
	if not gCS.LuaUtils.IsNull(self.LuaSlotEntity.gameObject) then
		self.bindData.vcam.gameObject:SetActive(true)

		local upbodyslot = self.LuaSlotEntity.gameObject:FindChild(MiniGameConfig.CameraLookAtPath).transform
		local camParam = MiniGameConfig.CameraParam

		gCS.CameraDataMgr.cinemachineManager.SetVcamFacingTargetPos(self.bindData.vcam.gameObject, upbodyslot, camParam[1], camParam[3], camParam[4], camParam[2])
	end

	gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.S_COIN_INDIE_PAGE_PANEL, LayerConstants.AllWithoutPlayer)
end

function M:RefreshBtnStyle()
	return
end

function M:StartMiniGame()
	if not self.miniGameType then
		return
	end

	gSceneGameRuleManager:CreateProcedureGameRule(self.miniGameType, self.exitInteractionType)
	gPanelManager:Close(gPanelId.S_COIN_INDIE_PAGE_PANEL)
end

function M:OnBtnBack()
	gPanelManager:Close(gPanelId.S_COIN_INDIE_PAGE_PANEL)
end

function M:OnBtnConfirm()
	if gPlayerManager.infoItem.bindData.money < self.onceCost then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)
	else
		gClientToGameDelegate:AskBuyMiniGameTicket(self.miniGameType).Callback = function (errId)
			if errId == 0 then
				self:StartMiniGame()
			else
				print_error("AskBuyMiniGameTicket failed, error = ", gCS.Error.GetNameById(errId))
			end
		end
	end
end
