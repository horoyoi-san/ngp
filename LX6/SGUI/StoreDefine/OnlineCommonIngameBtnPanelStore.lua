-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineCommonIngameBtnPanelStore.lua
-- Decompiled from: 01100_OnlineCommonIngameBtnPanelStore.lua_9dc47441008b.luajit

C_OnlineCommonIngameBtnPanelStore = DefClass("C_OnlineCommonIngameBtnPanelStore", C_OnlineCommonIngameBtnPanelStore, C_StoreGroup)
GroupName2Class.OnlineCommonIngameBtnPanelStore = C_OnlineCommonIngameBtnPanelStore
local M = C_OnlineCommonIngameBtnPanelStore
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local LinkMultiTypeConfig = LTConfig.LinkMultiTypeConfig
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.btnTypeCtrlEnum = {
		["pR~{K*"] = 1,
		["_:tO"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnTypeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RefreshBtnType(self)
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
	print_notice("[OnlineCommonIngameBtnPanel] OnGroupEnable, RefreshBtnType")
	self.RefreshBtnType(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.surrenderBtn.luaClick = self.CreateAction(self, self.OnClickSurrenderBtn)
end

M.OnClickExitBtn = function(self)
	print_notice("[HideSeek] OnClickExitBtn, multiType=", gLinkManager:GetCurMultiType())

	if not self:ShouldShowQuitGameArea() then
		print_notice("[HideSeek] OnClickExitBtn -> ShouldShowQuitGameArea=false")

		return
	end

	local multiType = gLinkManager:GetCurMultiType()
	local cfg = gLinkManager.currentGameCfg
	local isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()

	if multiType ~= LinkMultiPlayerConfig.MultiTypeType.Raid then
		local isPlanningBoard = cfg and (cfg.Tags ~= LinkMultiPlayerConfig.TagsType.PlanningBoardReady or cfg.Tags ~= LinkMultiPlayerConfig.TagsType.PlanningBoardDividends)

		if isPlanningBoard then
			if isNonMobile then
				gLinkManager:AskLeaveGame()
			else
				slot5 = gDisplayMessageMgr

				slot5:ShowMessage(MessageConfig.OnlineRoomExitNormalTip, function ()
					gLinkManager:AskLeaveGame()
				end)
			end

			return
		end

		gUIUtils:ShowExitRaidWindow()

		return
	end

	if multiType ~= LinkMultiPlayerConfig.MultiTypeType.Race or multiType ~= LinkMultiPlayerConfig.MultiTypeType.HideAndSeek or multiType ~= LinkMultiPlayerConfig.MultiTypeType.ExtractionShooter then
		print_notice("[HideSeek] OnClickExitBtn -> Race/HideSeek/ExtractionShooter branch, calling TryExit")
		gLinkManager:TryExit()

		return
	end

	if isNonMobile then
		gLinkManager:AskLeaveGame()
	else
		slot4 = gDisplayMessageMgr

		slot4:ShowMessage(MessageConfig.OnlineRoomExitNormalTip, function ()
			gLinkManager:AskLeaveGame()
		end)
	end
end

M.OnClickSurrenderBtn = function(self)
	if not self.ShouldShowQuitGameArea(self) then
		return
	end

	if gLinkManager:CheckCanSurrender() then
		gLinkManager:CreateVote(UX.Game.VoteType.Surrender)
	end
end

M.ShouldShowQuitGameArea = function(self)
	return gLinkManager.LinkMode ~= UX.Game.LinkMode.Match and gLinkManager:GetCurMultiType() == 0
end

M.RefreshBtnType = function(self)
	if not self.ShouldShowQuitGameArea(self) then
		self.bindData.btnTypeCtrl = self.btnTypeCtrlEnum.Exit

		print_notice("[OnlineCommonIngameBtnPanel] RefreshBtnType -> Exit (shouldNotShow)")

		return
	end

	local multiType = gLinkManager:GetCurMultiType()
	local cfg = gLinkManager.currentGameCfg

	if multiType ~= LinkMultiPlayerConfig.MultiTypeType.Raid then
		local isPlanningBoard = cfg and (cfg.Tags ~= LinkMultiPlayerConfig.TagsType.PlanningBoardReady or cfg.Tags ~= LinkMultiPlayerConfig.TagsType.PlanningBoardDividends)

		if isPlanningBoard and gPlanningBoardManager.GetTeamMemberCount() <= 1 then
			self.bindData.btnTypeCtrl = self.btnTypeCtrlEnum.Surrender

			print_notice("[OnlineCommonIngameBtnPanel] RefreshBtnType -> Surrender (PlanningBoard multi)")

			return
		end
	end

	local multiTypeCfg = LinkMultiTypeConfig.GetConfig(multiType)

	if multiTypeCfg and multiTypeCfg.QuitType ~= LinkMultiTypeConfig.QuitTypeType.SurrenderVote then
		self.bindData.btnTypeCtrl = self.btnTypeCtrlEnum.Surrender

		print_notice("[OnlineCommonIngameBtnPanel] RefreshBtnType -> Surrender (SurrenderVote config)")

		return
	end

	self.bindData.btnTypeCtrl = self.btnTypeCtrlEnum.Exit

	print_notice("[OnlineCommonIngameBtnPanel] RefreshBtnType -> Exit (default), multiType=", multiType)
end

M.OnLinkModeChange = function(self)
	print_notice("[OnlineCommonIngameBtnPanel] OnLinkModeChange, ShouldShow=", self.ShouldShowQuitGameArea(self))

	if not self.ShouldShowQuitGameArea(self) then
		gPanelManager:Close(gPanelId.ONLINE_COMMON_INGAMEBTN_PANEL)

		return
	end

	self.RefreshBtnType(self)
end
