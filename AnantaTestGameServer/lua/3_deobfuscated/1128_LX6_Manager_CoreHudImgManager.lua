C_CoreHudImgManager = DefClass("C_CoreHudImgManager", C_CoreHudImgManager)
local M = C_CoreHudImgManager

function M:ctor()
	self.btnDownFanseAni = "s_vx_HudSkillbtn_fanse"
	self.btnUpFanseAni = "s_vx_HudSkillbtn_fanse_up"
	self.imgUpDiveId = 28000922
	self.imgRunOnGroundId = 28001218
	self.imgDashInAirId = 28001000
	self.imgSwingInAirId = 28001001
	self.imgJumpOnGroundId = 28001002
	self.imgMagnetLiftId = 28001003
	self.imgPutDownId = 28001004
	self.imgThrowId = 28001005
	self.imgAssIconId = 28001006
	self.imgMindPowerId = 28001008
	self.imgDodgeOnGroundId = 28001009
	self.imgFeiSuoAttackId = 28004199
	self.imgBaoShuaiId = 28001774
	self.imgWingSuitRushId = 28022152
	self.imgTafeiRushId = 28001770
	self.imgOnTafeiMoto = 28001771
	self.imgOffTafeiMoto = 28001768
	self.imgShootBlockId = 28000923
	self.btnFanseAniList = {}
end

function M:CheckNeedPlayFanseAni(btn)
	if not btn.btnInCDCtrl or btn.btnInCDCtrl == 0 then
		return true
	end

	return false
end

function M:PlaySkillBtnDownFanseAni(btn)
	if not self:CheckNeedPlayFanseAni(btn) then
		return
	end

	table.insert(self.btnFanseAniList, btn)
	gBattleMgr:CommonPlayAniTool(btn.btnFanseAni, self.btnDownFanseAni, 0, 1)
end

function M:PlaySkillBtnUpFanseAni(btn, index, notPlayAni)
	if notPlayAni then
		return
	end

	index = index or 0

	if table.contains(self.btnFanseAniList, btn) then
		gBattleMgr:CommonPlayAniTool(btn.btnFanseAni, self.btnUpFanseAni, 0, 1)
	end

	table.removeEx(self.btnFanseAniList, btn)
end

function M:ClearBtnFanseAni(btn, index)
	if not table.contains(self.btnFanseAniList, btn) then
		return
	end

	table.removeEx(self.btnFanseAniList, btn)
	gBattleMgr:CommonStopAniTool(btn.btnFanseAni, self.btnUpFanseAni)
end

function M:ClearAllBtnFanseAni()
	for i = #self.btnFanseAniList, 1, -1 do
		self:ClearBtnFanseAni(self.btnFanseAniList[i], 0)
	end
end

gCoreHudImgManager = gCoreHudImgManager or C_CoreHudImgManager.new()
