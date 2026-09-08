-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PoliceJob\PoliceChaseManager.lua
-- Decompiled from: 00553_PoliceChaseManager.lua_e111a387388b.luajit

local UXVector3 = UX.Game.UXVector3
gPoliceChaseManager = gPoliceChaseManager or {}
local M = {
	["^\\xbe\\xa7\\xaa\\xb2"] = 0,
	["\\xa6\\xb0\\x87k'\\xfb!"] = 0,
	["\\xedK)\\xf3\\xa4b\\xa9W\\xa3\\xb3"] = false,
	["\\xbb\\xa3\n\\xacx;\\xed "] = 0,
	SyncPoliceChargingSkillProgress = function (self, progress, maxLayer, speed)
		self.maxLayer = maxLayer
		self.progress = progress
		self.speed = speed or 0
		local data = {
			progress = progress,
			maxLayer = maxLayer,
			speed = speed or 0
		}

		gMessageManager:SendMessage(gEventConstants.CAR_CHASE_PROGRESS_CHANGE, data)
	end,
	AddPoliceChargingProgress = function (self, chargingeventid)
		gClientToGameDelegate:AddPoliceChargingProgress(chargingeventid).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end,
	UsePoliceChargingProgress = function (self, ChargingSkillId, askPosAndFacing)
		local position, facing = nil

		if askPosAndFacing then
			local isSuccess = nil
			isSuccess, position, facing = LX6.Drive.AI.VehicleMissionManager.Instance:GetTaskVehicleNextTargetInfo(self.chaseVehicleUId, position, facing)

			if not isSuccess then
				if gPoliceJobManager.isDebug then
					print_notice("PoliceChaseManager:UsePoliceChargingProgress failed")
				end

				return
			end
		else
			position = gCS.MyPlayerManager.PlayerUnit.PlayerObj.position
			facing = 0
		end

		local PoliceChargingSkillInfo = {
			ChargingSkillId = ChargingSkillId,
			Position = UXVector3.New(position.x, position.y, position.z),
			Facing = facing
		}

		gClientToGameDelegate:UsePoliceChargingProgress(PoliceChargingSkillInfo).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end,
	SyncPlayerPoliceChasedVehicles = function (self, vehicleUId)
		self.enterCarChase = true
		self.chaseVehicleUId = vehicleUId
		self.needAddHudVehicleId = vehicleUId

		gDriveVehiclesManager:TryGetBaseVehicleWithCallback(vehicleUId, function ()
			if gPoliceChaseManager.needAddHudVehicleId and gPoliceChaseManager.needAddHudVehicleId ~= gPoliceChaseManager.chaseVehicleUId then
				gPoliceChaseManager.needAddHudVehicleId = nil

				gHudMgr:CreateVehicle(gPoliceChaseManager.chaseVehicleUId)
				gHudMgr:VehicleAddHp(gPoliceChaseManager.chaseVehicleUId)
				gMessageManager:SendMessage(gEventConstants.CAR_STATE_CHANGE, true)
			end
		end)
	end,
	SyncPlayerPoliceChaseFinish = function (self)
		gHudMgr:VehicleDead(self.chaseVehicleUId)

		self.chaseVehicleUId = nil
		self.needAddHudVehicleId = nil
		self.maxLayer = 0
		self.enterCarChase = false

		gMessageManager:SendMessage(gEventConstants.CAR_CHASE_PROGRESS_CHANGE)
		gMessageManager:SendMessage(gEventConstants.CAR_STATE_CHANGE, false)
	end
}
gPoliceChaseManager = M
