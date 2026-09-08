-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerRarrestedPanelStore.lua
-- Decompiled from: 00778_PlayerRarrestedPanelStore.lua_ffd0a98a85ab.luajit

local GameConfig = LTConfig.GameConfig
local AetherNpcConfig = LTConfig.AetherNpcConfig
C_PlayerRarrestedPanelStore = DefClass("C_PlayerRarrestedPanelStore", C_PlayerRarrestedPanelStore, C_StoreGroup)
GroupName2Class.PlayerRarrestedPanelStore = C_PlayerRarrestedPanelStore
local M = C_PlayerRarrestedPanelStore

M.ctor = function(self)
end

M.OnShow = function(self, panelId, data)
	slot3 = self.rootGo

	slot3:SetActive(false)

	slot3 = gCS.CameraDataMgr.cinemachineManager

	slot3:EnterMovementState(LX6.Cinemachine.EMovementCamState.UnderArrest)
	gLuaTimeMgrUtils.Delay(function ()
		if not gPanelManager:IsPanelShowing(self.m_Id) then
			return
		end

		self.rootGo:SetActive(true)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.ani:Play("S_Vx_PlayerRarrestedPanel_PC_open")
		else
			self.bindData.ani:Play("S_Vx_PlayerRarrestedPanel_open")
		end

		gLuaTimeMgrUtils.Delay(function ()
			if not gPanelManager:IsPanelShowing(self.m_Id) then
				return
			end

			slot0 = gPanelManager

			slot0:Close(self.m_Id)

			slot0 = gCS.CameraDataMgr.cinemachineManager

			slot0:ExitMovementState(LX6.Cinemachine.EMovementCamState.UnderArrest)

			slot0 = gClientToGameDelegate

			slot0:AskGetArrestTimes().Callback = function (err, arrestTimes)
				if err == LTConfig.MessageConfig.Ok then
					return
				end

				local part2 = "play_police_arrested_indoor"

				if GameConfig.PoliceArrestRecordThresholdTimes < arrestTimes and not string.contains(gCS.MyPlayerManager.PlayerUnit.ModelCfg.config.Model, "A104003") then
					part2 = "play_police_arrested01_indoor"
				end

				local preTeleportOption = UX.Game.PreTeleportOption.New()
				local extParams = LX6.GUI.LoadingManager.AskTeleportExtParams.New()
				preTeleportOption.customAfterTrans = true
				preTeleportOption.afterPosition = UX.Game.UXVector3.New(AetherNpcConfig.PlayerArrestedPosition[1], AetherNpcConfig.PlayerArrestedPosition[2], AetherNpcConfig.PlayerArrestedPosition[3])
				preTeleportOption.afterRot = UX.Game.UXVector3.New(0, AetherNpcConfig.PlayerArrestedPosition[4], 0)
				preTeleportOption.afterResName = "loading_general_end"
				preTeleportOption.loadingResName = part2
				slot5 = gLoadingManager

				slot5:AskTeleport(LTConfig.LoadingConfig.PoliceArrest, preTeleportOption, extParams, function (loadingInfoIndex)
					slot1 = gClientToGameSceneDelegate

					slot1:AskTeleportToPoliceStation().Callback = function (errId)
						if errId == 0 then
							print_error("AskTeleportToPoliceStation Failed Error = ", gCS.Error.GetNameById(errId))
							gLoadingManager:StopLoading(loadingInfoIndex)
						end
					end
				end)
			end
		end, GameConfig.ArrestedUITime)
	end, GameConfig.ArrestedUIDelayTime)
end

M.OnClose = function(self)
end
