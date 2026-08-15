local AnimationManager = LX6.Units.AnimationManager
local InstrumentConfig = LTConfig.InstrumentConfig
local M = gGamePlayPianoManager or {}
M.debugPiano = false

function M:InitParam()
	self.piano_curLeftHandPosType = 0
	self.piano_curRightHandPosType = 0
	self.piano_curLeftHandWeight = InstrumentConfig.PianoHandDefaultWeight
	self.piano_curRightHandWeight = InstrumentConfig.PianoHandDefaultWeight
	self.piano_lastLeftHandWeight = InstrumentConfig.PianoHandDefaultWeight
	self.piano_lastRightHandWeight = InstrumentConfig.PianoHandDefaultWeight
	self.piano_curMaskType = -1
	self.piano_curMaskHoldTime = 0
	self.piano_curCheckType = 0
	self.piano_lastNoteTime = 0
end

function M:DoActionAfter(unit, cfg, actionKey)
	if self.debugPiano then
		print_debug("DoPianoActionAfter", cfg.Id)
	end

	if self.piano_curCheckType == 0 then
		if self.debugPiano then
			print_debug("=====设置base层参数", self.piano_curLeftHandWeight, self.piano_curRightHandWeight)
		end

		gCS.BaseUnitModuleUtils.PianoSetLayerParamFade(unit, 0, self.piano_curLeftHandWeight, self.piano_curRightHandWeight)
	end

	local ok, piano_curMaskType, piano_curMaskHoldTime = gCS.GamePlayPianoMgr.DoActionAfter(cfg.Id, actionKey, self.piano_lastLeftHandWeight, self.piano_lastRightHandWeight, self.piano_curLeftHandWeight, self.piano_curRightHandWeight, 0, 0)

	if ok then
		self.piano_curMaskType = piano_curMaskType
		self.piano_curMaskHoldTime = piano_curMaskHoldTime
	end

	if self.piano_curCheckType == 0 then
		self.piano_curCheckType = 1

		gGamePlayTransitionMgr:CheckSwitchAction()

		self.piano_curCheckType = 0
	end
end

function M:RemovePianoModule()
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit then
		gCS.BaseUnitModuleUtils.RemovePianoModule(unit)
	end
end

function M:EnterGamePlay()
	self:InitParam()
end

function M:EndGamePlay()
	self:RemovePianoModule(false)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.AnimationManager.StopAllLayerAction(gCS.MyPlayerManager.PlayerUnit, -1)
	end

	table.clear(M.tempActionInfo)
end

M.tempActionInfo = {}

function M:GetActionLayer(actionType, actionGroup)
	local key = gUtils:GetActionKey(actionType, actionGroup)

	if not self.tempActionInfo[key] then
		self.tempActionInfo[key] = gCS.AnimationManager.CheckActionConfigLayer(gCS.MyPlayerManager.PlayerUnit, key)
	end

	return self.tempActionInfo[key]
end

function M:CheckConfigNoOk(unit, cfg)
	if cfg.CheckType ~= self.piano_curCheckType and cfg.CheckType ~= 2 then
		return true
	end

	if cfg.PianoCheckTimeInterval == 1 and unit.time - self.piano_lastNoteTime < InstrumentConfig.PianoCheckTimeInterval then
		return true
	end

	if cfg.PianoKeyType > 0 and cfg.PianoKeyType ~= self.piano_curLeftHandPosType and cfg.PianoKeyType ~= self.piano_curRightHandPosType then
		return true
	end

	local layerIndex = self:GetActionLayer(cfg.TargetAniType, cfg.TargetAniGroup)

	if layerIndex < 0 then
		return true
	end

	if cfg.ActionMaskHoldTime > 0 and layerIndex == self.piano_curMaskType and unit.time - self.piano_curMaskHoldTime <= cfg.ActionMaskHoldTime then
		return true
	end

	return false
end

function M:CheckExConfigs(unit, unityDeltaTime, unityTime)
	local flag, playtime, targetActionType, fadeInTime = nil

	if self.piano_curCheckType > 0 then
		local needCheckConfigs = gGamePlayTransitionMgr:GetCurGamePlayCheckConfigs()

		for _, v in pairs(needCheckConfigs) do
			for _, v2 in pairs(v) do
				local cfg = v2

				if cfg.StartAniLayer > 0 and cfg.CheckType == self.piano_curCheckType then
					local layerActionInfo = gCS.AnimationManager.GetCurrentLayerActionKey(unit, cfg.StartAniLayer)
					local configActionKey = gUtils:GetActionKey(cfg.StartAniType, cfg.StartAniGroup)
					local isOk = false

					if cfg.StartAniType == 0 then
						if layerActionInfo == 0 then
							isOk = true
						end
					elseif layerActionInfo == configActionKey then
						isOk = true
					end

					if isOk then
						local currentLayerActionTime = cfg.StartAniType == 0 and 1 or gCS.AnimationManager.GetCurrentActionTime(unit, cfg.StartAniLayer)
						local currentLayerActionAllTime = cfg.StartAniType == 0 and 0 or gCS.AnimationManager.AnimatorGetAnimationTime(unit, layerActionInfo)
						flag, playtime, targetActionType, fadeInTime = gGamePlayTransitionMgr:CheckTransitionAndPlay(unit, cfg, true, unityDeltaTime, unityTime, currentLayerActionTime, currentLayerActionAllTime)

						if flag then
							break
						end
					end
				end
			end
		end
	end

	return flag, playtime, targetActionType, fadeInTime
end

gGamePlayPianoManager = M
