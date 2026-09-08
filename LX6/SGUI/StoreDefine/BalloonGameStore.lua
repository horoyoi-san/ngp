-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BalloonGameStore.lua
-- Decompiled from: 01578_BalloonGameStore.lua_58413b657871.luajit

local SceneitemConfig = LTConfig.SceneitemConfig
local DurabilityUIModeType = LTConfig.SceneitemConfig.DurabilityUIModeType
C_BalloonGameStore = DefClass("C_BalloonGameStore", C_BalloonGameStore, C_StoreGroup)
GroupName2Class.BalloonGameStore = C_BalloonGameStore
local M = C_BalloonGameStore
local WeaponNumType = {
	["\\xa9}h"] = 0,
	["\\xc1\\x88\\xe98\\xf4\\xe8\\x81\\xe1\\x8b41"] = 2,
	["\\xe9\\xde*\\xe5"] = 1,
	["\n$&\\xed}\\x91\\xe31\\x98*\\xf4\\xf1\\xe3z\\xef"] = 4,
	["Fx\\xaa~B\\xbb\\xe6BKwsC"] = 3,
	["zN˰\\xaa\\xb5\\xcc\\xfa"] = 5
}

M.ctor = function(self)
	self.totalScore = 0
	self.timer = nil
	self.startTime = 0
	self.isStart = false
	self.buttonBanId = nil
	self.targetModelId = 0
	self.targetSceneItemId = 0
	self.ammunitionRoot = nil
	self.CfgDurabilityMode2Index = {
		[DurabilityUIModeType.Gun] = WeaponNumType.Gun,
		[DurabilityUIModeType.Percent] = WeaponNumType.Percent,
		[DurabilityUIModeType.Free] = WeaponNumType.FreeDurability,
		[DurabilityUIModeType.InfiniteAmmo] = WeaponNumType.InfiniteAmmo,
		[DurabilityUIModeType.InfinitePercent] = WeaponNumType.InfinitePercent
	}
	self.weaponStateEnum = {
		["\\+qW"] = 0,
		[">Z\\x9e\\x85\\x86O"] = 1,
		["T-s^"] = 2
	}
	self.endType = 0
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.bubbleActiveEnum = {
		["F\\x90\\x8c\\x8fD"] = 1,
		["\\xdd\\xd2(\\xf4"] = 0
	}
	self.scoreEnum = {
		["\\x98"] = 2,
		["\\x9c"] = 0,
		["\\x9e"] = 1,
		QY = 3
	}
	self.resultActiveCtrlEnum = {
		["\\xdd\\xd2(\\xf4"] = 1,
		["F\\x90\\x8c\\x8fD"] = 0
	}
	self.rankCtrlEnum = {
		["\\x9e"] = 2,
		["\\x9c"] = 0,
		["\\x9f"] = 1
	}
	self.exchangeBulletCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showSeedBulletCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.weaponTypeEnum = {
		["\\xfd\\xde(\\xe5"] = 2,
		["\\xa9}h"] = 0,
		["\n$&\\xed}\\x91\\xe31\\x98*\\xf4\\xf1\\xe3z\\xef"] = 4,
		["3\\\\x99\\x8b\\x91R"] = 1,
		["Fx\\xaa~B\\xbb\\xe6BKwsC"] = 3,
		["zN˰\\xaa\\xb5\\xcc\\xfa"] = 5
	}
	self.brokCtrlEnum = {
		[">Z\\x9e\\x85\\x86O"] = 2,
		["As\\xade@\\xab\\xd0Ueq{B"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.bubbleActiveEnum = nil
	self.scoreEnum = nil
	self.resultActiveCtrlEnum = nil
	self.rankCtrlEnum = nil
	self.exchangeBulletCtrlEnum = nil
	self.showSeedBulletCtrlEnum = nil
	self.weaponTypeEnum = nil
	self.brokCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	local animation1Name = "S_Vx_BalloonGamePanel_Bubble_point01"
	local animation3Name = "S_Vx_BalloonGamePanel_Bubble_point03"
	local animation5Name = "S_Vx_BalloonGamePanel_Bubble_point02"
	local animation10Name = "S_Vx_BalloonGamePanel_Bubble_point10"

	if self.bindData.bubble1Anim then
		self.bubble1AnimTime = gClientUtils.GetAnimationClipLength(self.bindData.bubble1Anim, animation1Name) or 1
	end

	if self.bindData.bubble3Anim then
		self.bubble3AnimTime = gClientUtils.GetAnimationClipLength(self.bindData.bubble3Anim, animation3Name) or 1
	end

	if self.bindData.bubble5Anim then
		self.bubble5AnimTime = gClientUtils.GetAnimationClipLength(self.bindData.bubble5Anim, animation5Name) or 1
	end

	if self.bindData.bubble10Anim then
		self.bubble10AnimTime = gClientUtils.GetAnimationClipLength(self.bindData.bubble10Anim, animation10Name) or 1
	end

	self.isStart = true
	local ammoWidget = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		ammoWidget = self.bindData.ammunitionRoot_PC
	else
		ammoWidget = self.bindData.ammunitionRoot
	end

	if ammoWidget then
		self.ammunitionRoot = self.GetStoreByWidget(self, ammoWidget)
		self.ammunitionRoot.exchangeBulletCtrl = 0
		self.ammunitionRoot.showSeedBulletCtrl = 1
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.SetBanButton(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.SetBanButton = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.Balloon
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.OnGroupDisable = function(self)
	self.ClearBanButton(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.totalScore = 0
	self.startTime = gCS.TimeManager.ServerUnixTime
	self.bindData.totalScore = self.totalScore
	self.timer = nil
	self.isStart = true
	self.targetModelId = data.targetId
	self.targetSceneItemId = data.targetSceneItemId
	self.bindData.resultActiveCtrl = self.resultActiveCtrlEnum.disable

	self:RefreshRank()
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 10)
	gTaskUtils:SetTaskGuidePanelActive(false)
	self:RefreshBalloonWeaponAmmo()

	self.endType = 0
end

M.OnClose = function(self)
	self.isStart = false

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	gTaskUtils:SetTaskGuidePanelActive(true)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)
end

M.OnGameEnd = function(self)
	self.bindData.resultActiveCtrl = self.resultActiveCtrlEnum.enable

	if LTConfig.PoiGameConfig.Balloon_GoodEndCredit < self.totalScore then
		self.endType = 2
	elseif LTConfig.PoiGameConfig.Balloon_NormalEndCredit < self.totalScore then
		self.endType = 1
	else
		self.endType = 0
	end

	Timer.New(function ()
		gPanelManager:Close(gPanelId.BALLOON_PANEL)
	end, 1.5, nil):Start()
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnBalloonEnd, {
		endType = self.endType
	})
end

M.OnUpdate = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SYNC_BALLOON_GAME_SCORE] = self.CreateAction(self, "SyncBalloonGameScore"),
		[gEventConstants.WEAPON_DURABILITY_CHANGE] = self.CreateAction(self, "OnBalloonWeaponDurabilityChange")
	}
end

M.RefreshRank = function(self)
	local score = self.totalScore or 0

	if LTConfig.PoiGameConfig.Balloon_GoodEndCredit < score then
		self.bindData.rankCtrl = 2
	elseif LTConfig.PoiGameConfig.Balloon_NormalEndCredit < score then
		self.bindData.rankCtrl = 1
	else
		self.bindData.rankCtrl = 0
	end
end

M.SyncBalloonGameScore = function(self, eventId, data)
	local singleScore = data - self.totalScore
	self.totalScore = data
	self.bindData.totalScore = self.totalScore

	self.RefreshRank(self)

	if singleScore <= 0 then
		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		if self.bindData.bubble1Anim then
			gClientUtils.ResetAnimation(self.bindData.bubble1Anim, "S_Vx_BalloonGamePanel_Bubble_point01")
		end

		if self.bindData.bubble3Anim then
			gClientUtils.ResetAnimation(self.bindData.bubble3Anim, "S_Vx_BalloonGamePanel_Bubble_point03")
		end

		if self.bindData.bubble10Anim then
			gClientUtils.ResetAnimation(self.bindData.bubble10Anim, "S_Vx_BalloonGamePanel_Bubble_point10")
		end

		if self.bindData.bubble5Anim then
			gClientUtils.ResetAnimation(self.bindData.bubble5Anim, "S_Vx_BalloonGamePanel_Bubble_point02")
		end

		self.bindData.bubbleActive = self.bubbleActiveEnum.enable
		local animTime = 0

		if singleScore ~= 1 then
			self.bindData.bubble1Anim:Play("S_Vx_BalloonGamePanel_Bubble_point01")

			animTime = self.bubble1AnimTime
		elseif singleScore ~= 5 then
			self.bindData.bubble5Anim:Play("S_Vx_BalloonGamePanel_Bubble_point02")

			animTime = self.bubble5AnimTime
		elseif singleScore ~= 3 then
			self.bindData.bubble3Anim:Play("S_Vx_BalloonGamePanel_Bubble_point03")

			animTime = self.bubble3AnimTime
		elseif singleScore ~= 10 then
			self.bindData.bubble10Anim:Play("S_Vx_BalloonGamePanel_Bubble_point10")

			animTime = self.bubble10AnimTime
		end

		local scoreStyle = self.scoreEnum[tostring(singleScore)]

		if scoreStyle == nil then
			self.bindData.score = scoreStyle
		end

		self.timer = Timer.New(function ()
			self.bindData.bubbleActive = self.bubbleActiveEnum.disable
		end, animTime):Start()
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
end

M.OnClickBackBtn = function(self)
	if gMiniGameDataManager.curBalloonGadgetId == 0 then
		slot1 = gClientToGameSceneDelegate

		slot1:LeaveBalloon(gMiniGameDataManager.curBalloonGadgetId).Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				return
			end

			L50.L50App.Scene.ZoneGamePlayManager:EndContext()
		end
	end
end

M.RefreshBalloonWeaponAmmo = function(self)
	if not self.ammunitionRoot then
		return
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon
	local cfg = SceneitemConfig.GetConfig(weapon.TemplateId)

	if not cfg then
		return
	end

	local weaponType = self:GetBalloonWeaponDurabilityType(cfg)
	self.ammunitionRoot.weaponType = weaponType
	local cur = weapon.MagazineAmmo or 0
	local single = cfg.BulletNum or 0
	local total = weapon.Durability or 0
	local configTotal = cfg.Durability or 0
	local bulletId = weapon.BulletDatas and weapon.BulletDatas.BulletId or 0

	self:UpdateBalloonAmmunition(cur, single, total, configTotal, bulletId)
	self:SetBalloonAmmunitionBrokenState(weapon)
end

M.GetBalloonWeaponDurabilityType = function(self, cfg)
	if cfg then
		local cfgIndex = self.CfgDurabilityMode2Index[cfg.DurabilityUIMode]

		if cfgIndex then
			return cfgIndex
		end

		local totalDurability = cfg.Durability

		if cfg.ShootId <= 0 then
			local bulletNum = cfg.BulletNum

			if bulletNum and bulletNum ~= totalDurability then
				return WeaponNumType.Percent
			end

			if totalDurability >= 0 then
				if bulletNum and bulletNum <= 0 then
					return WeaponNumType.InfiniteAmmo
				end

				return WeaponNumType.FreeDurability
			end

			return WeaponNumType.Gun
		end

		if totalDurability >= 0 then
			return WeaponNumType.FreeDurability
		end

		if cfg.WeaponStackMaxCount == 0 then
			return WeaponNumType.ItemNumber
		end
	end

	return WeaponNumType.Percent
end

M.UpdateBalloonAmmunition = function(self, cur, single, total, configTotal, bulletId)
	if not self.ammunitionRoot then
		return
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon
	local templateId = weapon and weapon.TemplateId or 0
	local useBullet = templateId <= 0 and gWeaponManager:IsWeaponUseBulletById(templateId)

	if useBullet then
		if bulletId <= 0 then
			self.ammunitionRoot.curAmmunition = cur
			self.ammunitionRoot.remainAmmunition = math.max(gCommonItemManager:GetPackItemNum(bulletId), 0)

			if single <= 0 then
				self.ammunitionRoot.durabilityPercent = math.floor(cur / single * 100)
			end
		else
			self.ammunitionRoot.curAmmunition = 0
			self.ammunitionRoot.remainAmmunition = 0
		end
	else
		self.ammunitionRoot.curAmmunition = cur
		self.ammunitionRoot.infiniteCurNum = cur

		if total <= 0 then
			self.ammunitionRoot.remainAmmunition = math.max(total - cur, 0)
		elseif total >= 0 then
			self.ammunitionRoot.remainAmmunition = "-"
		else
			self.ammunitionRoot.remainAmmunition = 0
		end

		if configTotal <= 0 then
			self.ammunitionRoot.durabilityPercent = math.floor(total / configTotal * 100)
		end
	end
end

M.SetBalloonAmmunitionBrokenState = function(self, weapon)
	if not self.ammunitionRoot or not weapon or not weapon.TemplateId then
		return
	end

	local cfg = SceneitemConfig.GetConfig(weapon.TemplateId)

	if not cfg then
		return
	end

	local allDurability = cfg.Durability

	if allDurability ~= -1 or not weapon.Durability or gWeaponManager:IsWeaponPileUp(weapon.TemplateId) or gWeaponManager:IsWeaponUseBulletById(weapon.TemplateId) then
		self.ammunitionRoot.brokCtrl = self.weaponStateEnum.Fill

		return
	end

	local lowLimit = SceneitemConfig.WeaponDurabilityLow * allDurability

	if weapon.Durability ~= 0 then
		self.ammunitionRoot.brokCtrl = self.weaponStateEnum.None
	elseif weapon.Durability < lowLimit then
		self.ammunitionRoot.brokCtrl = self.weaponStateEnum.Broken
	else
		self.ammunitionRoot.brokCtrl = self.weaponStateEnum.Fill
	end
end

M.OnBalloonWeaponDurabilityChange = function(self, eventId, data)
	if not data then
		return
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if not weapon or weapon.InstanceId == data.weaponId then
		return
	end

	self.RefreshBalloonWeaponAmmo(self)
end
