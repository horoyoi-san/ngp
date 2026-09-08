-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\VolleyballGame\VolleyballCameraController.lua
-- Decompiled from: 00631_VolleyballCameraController.lua_cfc973e8a866.luajit

C_VolleyballCameraController = DefClass("C_VolleyballCameraController", C_VolleyballCameraController)
local M = C_VolleyballCameraController
local Team = gVolleyballGameMgr.Team

M.ctor = function(self, cameraSet)
	self.cameraSet = cameraSet
	self.closeUpCam = nil
	self.battleCam = {
		[Team.My] = nil,
		[Team.Op] = nil
	}
	self.curCam = nil
	self.closeUpDistance = 2.5
	self.closeUpOffset = Vector3.New(0, 0.8, 0)
end

M.Init = function(self)
	self.closeUpCam = self.cameraSet:Find("CloseUpCam")
	self.battleCam[Team.My] = self.cameraSet:Find("C1")
	self.battleCam[Team.Op] = self.cameraSet:Find("C2")
end

M.SwitchCameraByTeam = function(self, team)
	if self.curCam == self.battleCam[team] then
		self.curCam = self.battleCam[team]

		for _, cam in pairs(self.battleCam) do
			cam.gameObject:SetActive(cam ~= self.curCam)
		end
	end
end

M.StartCloseUp = function(self, targetTrans)
	gCS.CameraDataMgr.cinemachineManager.SetVcamFacingTargetPos(self.closeUpCam.gameObject, targetTrans, self.closeUpDistance, 0.5, 0.5, 60)

	self.closeUpCam.position = self.closeUpCam.position + self.closeUpOffset

	self.closeUpCam.gameObject:SetActive(true)
end

M.EndCloseUp = function(self)
	self.closeUpCam.gameObject:SetActive(false)
end
