local GameConfig = LTConfig.GameConfig
local AetherNpcConfig = LTConfig.AetherNpcConfig
C_PlayerRarrestedPanelStore = DefClass("C_PlayerRarrestedPanelStore", C_PlayerRarrestedPanelStore, C_StoreGroup)
GroupName2Class.PlayerRarrestedPanelStore = C_PlayerRarrestedPanelStore
local M = C_PlayerRarrestedPanelStore

function M:ctor()
	return
end

function M:OnShow(panelId, data)
	self.rootGo:SetActive(false)
	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.UnderArrest)
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

			gPanelManager:Close(self.m_Id)
			gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.UnderArrest)

			local targetPosition = Vector3.New(AetherNpcConfig.PlayerArrestedPosition[1], AetherNpcConfig.PlayerArrestedPosition[2], AetherNpcConfig.PlayerArrestedPosition[3])

			gClientToGameDelegate:AskGetArrestTimes().Callback = function (err, arrestTimes)
				if err ~= LTConfig.MessageConfig.Ok then
					return
				end

				local part2 = "play_police_arrested_indoor"

				if GameConfig.PoliceArrestRecordThresholdTimes <= arrestTimes and not string.contains(gCS.MyPlayerManager.PlayerUnit.ModelCfg.config.Model, "A104003") then
					part2 = "play_police_arrested01_indoor"
				end

				gLoadingManager:Quick_ArrestTeleport(Vector3.zero, 0, targetPosition, AetherNpcConfig.PlayerArrestedPosition[4], "", part2, "loading_general_end", function ()
					gClientToGameSceneDelegate:AskTeleportToPoliceStation().Callback = function (errId)
						if errId ~= 0 then
							print_error("AskTeleportToPoliceStation Failed Error = ", gCS.Error.GetNameById(errId))
						end
					end
				end, 0, 0)
			end
		end, GameConfig.ArrestedUITime)
	end, GameConfig.ArrestedUIDelayTime)
end

function M:OnClose()
	return
end
