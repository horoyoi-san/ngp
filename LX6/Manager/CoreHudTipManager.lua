-- Original chunk: @Lua\LuaFiles\LX6\Manager\CoreHudTipManager.lua
-- Decompiled from: 02238_CoreHudTipManager.lua_470a44f421a6.luajit

local SceneitemConfig = LTConfig.SceneitemConfig
local SceneitemWeaponBtnConfig = LTConfig.SceneitemWeaponBtnConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local HudDescConfig = LTConfig.HudDescConfig
local CoreHudButtonTipMapConfig = LTConfig.CoreHudButtonTipMapConfig
local CoreHudButtonConfig = LTConfig.CoreHudButtonConfig
C_CoreHudTipManager = DefClass("C_CoreHudTipManager", C_CoreHudTipManager)
local M = C_CoreHudTipManager

M.ctor = function(self)
	self.isDebug = false
	self.isInitCache = false
	self.isEnable = true
	self.btnInfoEnum = {}

	for i = 0, CoreHudButtonConfig.count - 1 do
		local cfg = CoreHudButtonConfig.LoadAt(i)
		self.btnInfoEnum[cfg.Name] = cfg.Id
	end

	self.btnEnumToBtnRef = {
		[self.btnInfoEnum.NormalAttack] = "normalAttackBtn",
		[self.btnInfoEnum.HeavyAttack] = "heavyAttackBtn",
		[self.btnInfoEnum.Skill] = "basicSkillBtnGo",
		[self.btnInfoEnum.UltSkill] = "ultSkillBtnGo",
		[self.btnInfoEnum.Dodge] = "dodgeBtn",
		[self.btnInfoEnum.JumpJump] = "jumpSwingBtn",
		[self.btnInfoEnum.MindPower] = "mindPowerBtn",
		[self.btnInfoEnum.Grapple] = "grappleBtn",
		[self.btnInfoEnum.OffWall] = "dropBtn",
		[self.btnInfoEnum.Dive] = "ctrlButton",
		[self.btnInfoEnum.EBtnInfo] = "basicNormalBtnGo",
		[self.btnInfoEnum.RBtnInfo] = "ultNormalBtnGo",
		[self.btnInfoEnum.TaFeiMoto] = "motoBtn",
		[self.btnInfoEnum.MotoDash] = "motoSpeedUpBtn",
		[self.btnInfoEnum.MotoLight] = "motoLightBtn",
		[self.btnInfoEnum.Hold_Left] = "holdLeftBtn",
		[self.btnInfoEnum.Hold_Q] = "holdQBtn",
		[self.btnInfoEnum.Hold_R] = "holdRBtn",
		[self.btnInfoEnum.PhoneCall] = "carSummonBtn",
		[self.btnInfoEnum.MilkCar] = "milkVehicleBtn",
		[self.btnInfoEnum.MotionAction] = "motionActionBtn",
		[self.btnInfoEnum.DiveDash] = "diveSpeedUpBtn",
		[self.btnInfoEnum.WingSuitDash] = "wingRushBtn",
		[self.btnInfoEnum.ProfessionalSkill] = "professionSkillBtn",
		[self.btnInfoEnum.KickOff] = "kickOffBtn",
		[self.btnInfoEnum.Umbrella] = "umbrellaBtn",
		[self.btnInfoEnum.SkyDiving] = "skyDiveBtn",
		[self.btnInfoEnum.YingLongCharge] = "chargeBtn"
	}
	self.btnEnumToGamePadIndex = {
		[self.btnInfoEnum.NormalAttack] = 5,
		[self.btnInfoEnum.HeavyAttack] = 10,
		[self.btnInfoEnum.Skill] = 13,
		[self.btnInfoEnum.UltSkill] = 11,
		[self.btnInfoEnum.Dodge] = 2,
		[self.btnInfoEnum.JumpJump] = 1,
		[self.btnInfoEnum.MindPower] = -1,
		[self.btnInfoEnum.Grapple] = -1,
		[self.btnInfoEnum.OffWall] = -1,
		[self.btnInfoEnum.Dive] = -1,
		[self.btnInfoEnum.EBtnInfo] = 0,
		[self.btnInfoEnum.RBtnInfo] = -1,
		[self.btnInfoEnum.TaFeiMoto] = 2,
		[self.btnInfoEnum.MotoDash] = -1,
		[self.btnInfoEnum.MotoLight] = -1,
		[self.btnInfoEnum.Hold_Left] = 24,
		[self.btnInfoEnum.Hold_R] = -1,
		[self.btnInfoEnum.Hold_Q] = 30,
		[self.btnInfoEnum.GamepadWeaponE] = 26,
		[self.btnInfoEnum.GamepadWeaponR] = 27,
		[self.btnInfoEnum.GamepadWeaponShoot] = 8,
		[self.btnInfoEnum.GamepadWeaponAim] = 28,
		[self.btnInfoEnum.PhoneCall] = -1,
		[self.btnInfoEnum.MilkCar] = -1,
		[self.btnInfoEnum.MotionAction] = -1,
		[self.btnInfoEnum.DiveDash] = 32,
		[self.btnInfoEnum.WingSuitDash] = -1,
		[self.btnInfoEnum.ProfessionalSkill] = 17,
		[self.btnInfoEnum.KickOff] = 16,
		[self.btnInfoEnum.Umbrella] = -1,
		[self.btnInfoEnum.SkyDiving] = 31,
		[self.btnInfoEnum.YingLongCharge] = -1
	}
	self.weaponCfgToBtnEnum = {
		MouseLeft_Click = self.btnInfoEnum.NormalAttack,
		MouseLeft_Hold = self.btnInfoEnum.Hold_Left,
		MouseRight_Click = self.btnInfoEnum.HeavyAttack,
		ButtonCombatE_Click = self.btnInfoEnum.Skill,
		ButtonE_Click = self.btnInfoEnum.EBtnInfo,
		ButtonQ_Hold = self.btnInfoEnum.Hold_Q,
		ButtonCombatR_Click = self.btnInfoEnum.UltSkill,
		ButtonR_Click = self.btnInfoEnum.RBtnInfo
	}
	self.gamepadWeaponCfgToBtnEnum = {
		WestButton_Click = self.btnInfoEnum.GamepadWeaponE,
		WestButton_Hold = self.btnInfoEnum.Hold_Left,
		NorthButton_Click = self.btnInfoEnum.GamepadWeaponR,
		NorthButton_Hold = self.btnInfoEnum.Hold_Q,
		North_EastButton = self.btnInfoEnum.UltSkill,
		LeftTrigger_Click = self.btnInfoEnum.GamepadWeaponAim,
		RightTrigger_Click = self.btnInfoEnum.GamepadWeaponShoot
	}
	self.conditionType = {
		["+M\\x90\\x9e\\x8cO"] = 5,
		["\\xba:66j\\x92O\\xd42\\xa4\\xad"] = 3,
		["~O©\\x8d8\\xb0\\xda\\xed"] = 4,
		["\\xea\\xcb%\\xfd"] = 1,
		["\\xfd\\xde(\\xe5"] = 6,
		["\\xe9\\xda1\\xe3"] = 2
	}
	self.onlyTipButtonEnum = {
		self.btnInfoEnum.Hold_Left,
		self.btnInfoEnum.Hold_Q,
		self.btnInfoEnum.Hold_R
	}
	self.pcOnlyBtnEnums = {
		[self.btnInfoEnum.Hold_Q] = true,
		[self.btnInfoEnum.Hold_Left] = true,
		[self.btnInfoEnum.Hold_R] = true,
		[self.btnInfoEnum.PhoneCall] = true,
		[self.btnInfoEnum.MilkCar] = true
	}
	self.sortedConditions = {}

	for key in pairs(self.conditionType) do
		table.insert(self.sortedConditions, key)
	end

	table.sort(self.sortedConditions, function (a, b)
		return self.conditionType[b] <= self.conditionType[a]
	end)

	self.queryConfigs = {}
	self.queryIdToButtonEnum = {}
	self.buttonQueryList = {}
	self.buttonQueryStates = {}
	self.PCTipCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.PCTipCache[conditionType] = {}
	end

	self.gamePadTipCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.gamePadTipCache[conditionType] = {}
	end

	self.finalTipStates = {}
	self.finalGamepadTipState = {}
	self.finalMobileStates = {}
	self.finalMobileIcon = {}
	self.finalMobileText = {}
	self.mobileCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.mobileCache[conditionType] = {}
	end

	self.mobileIconCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.mobileIconCache[conditionType] = {}
	end

	self.mobileTextCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.mobileTextCache[conditionType] = {}
	end

	self.btnGoCache = {}
	self.groupCache = {}
	self._MsgEvents = {}
	self.msgEvents = {
		[gEventConstants.ON_GAMEPLAY_TAG_TIP_REFRESH] = self:CreateAction("OnGameplayTagTipRefresh"),
		[gEventConstants.MIND_POWER_INTELLIGENT_SEARCH_CHANGE] = self:CreateAction("OnIntelligentSearchChange"),
		[gEventConstants.LANGUAGE_CHANGE] = self:CreateAction("OnLanguageChange")
	}
end

M.OnInit = function(self)
	self:RegisterMessageEvents(self.msgEvents)
end

M.RegisterDataSetEvents = function(self, eventHandlers)
	if #eventHandlers ~= 0 then
		return
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

M.ClearDataSetEvents = function(self)
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

M.RegisterSingleEvent = function(self, enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

M.RegisterMessageEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

M.ClearMessageEvents = function(self)
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

M.CreateAction = function(self, action, target)
	return function (...)
		target = target or self

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

M.CreateActionWithArgs = function(self, action, args, target)
	return function (...)
		target = target or self

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, args, ...)
			end
		else
			return action(target, args, ...)
		end
	end
end

M.InitTipDefaultCache = function(self)
	table.clear(self.btnGoCache)
	table.clear(self.groupCache)

	self.isNonMobile = gCS.LuaUtils.IsNonMobileAdaptive()
	local store = self:GetCachedGroup("CoreHudCharacterControlStore")
	local tafei = self:GetCachedGroup("UniqueSkillTaFeiStore")
	local systemControl = self:GetCachedGroup("CoreHudSystemControlStore")
	local wingSuit = self:GetCachedGroup("CostumWingSuitStore")

	for _, btnTypeNum in pairs(self.btnInfoEnum) do
		local btnRefName = self.btnEnumToBtnRef[btnTypeNum]
		local gamePadIndex = self.btnEnumToGamePadIndex[btnTypeNum]

		if not btnRefName then
			self.PCTipCache[self.conditionType.Default][btnTypeNum] = {
				["\\xca\\xd3\n*-\\xe1"] = false,
				["WN|GO;<"] = -1
			}
		else
			local btn = store.characterControlData[btnRefName] or store[btnRefName] or tafei.bindData[btnRefName] or systemControl and systemControl.bindData[btnRefName] or wingSuit and wingSuit.bindData[btnRefName]

			if btn then
				self.mobileCache[self.conditionType.Default][btnTypeNum] = {
					pos = btn.anchoredPosition,
					size = btn.sizeDelta
				}

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					self.PCTipCache[self.conditionType.Default][btnTypeNum] = {
						showTip = btn:GetPCKeyTipShowTip(),
						tipNameId = btn:GetPCKeyInfoTipNameId()
					}
				end
			elseif gCS.LuaUtils.IsNonMobileAdaptive() then
				self.PCTipCache[self.conditionType.Default][btnTypeNum] = {
					["\\xca\\xd3\n*-\\xe1"] = false,
					["WN|GO;<"] = -1
				}
			end
		end

		if self.isNonMobile then
			self.finalTipStates[btnTypeNum] = {
				showTip = self.PCTipCache[self.conditionType.Default][btnTypeNum].showTip,
				tipNameId = self.PCTipCache[self.conditionType.Default][btnTypeNum].tipNameId
			}
			local showTip = false
			local tipNameId = -1

			if gamePadIndex and gamePadIndex == -1 then
				local gpStore = self:GetStoreForGamepad(btnTypeNum)
				local gamePadArea = gpStore and gpStore.bindData and gpStore.bindData.gamePadArea

				if gamePadArea then
					showTip = gamePadArea:GetButtonInfoTipShowTip(gamePadIndex)
					tipNameId = gamePadArea:GetButtonInfoTipNameId(gamePadIndex)
				end
			end

			self.gamePadTipCache[self.conditionType.Default][btnTypeNum] = {
				showTip = showTip,
				tipNameId = tipNameId
			}
			self.finalGamepadTipState[btnTypeNum] = {
				showTip = showTip,
				tipNameId = tipNameId
			}
		end
	end

	if not self.isNonMobile then
		self:InitMobileTextCache()
	end

	self:InitGameplayTagTipConfigs()

	self.isInitCache = true
end

M.InitButtonInfoForTabRect = function(self, btn, btnTypeNum)
	if not btn or not btnTypeNum then
		return
	end

	self.mobileCache[self.conditionType.Default][btnTypeNum] = {
		pos = btn.anchoredPosition,
		size = btn.sizeDelta
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local pcShowTip = btn:GetPCKeyTipShowTip()
		local pcTipNameId = btn:GetPCKeyInfoTipNameId()
		self.PCTipCache[self.conditionType.Default][btnTypeNum] = {
			showTip = pcShowTip,
			tipNameId = pcTipNameId
		}
		self.finalTipStates[btnTypeNum] = {
			showTip = pcShowTip,
			tipNameId = pcTipNameId
		}
		local gamePadIndex = self.btnEnumToGamePadIndex[btnTypeNum]

		if gamePadIndex and gamePadIndex == -1 then
			local gpStore = self:GetStoreForGamepad(btnTypeNum)
			local gamePadArea = gpStore and gpStore.bindData and gpStore.bindData.gamePadArea

			if gamePadArea then
				local padShowTip = gamePadArea:GetButtonInfoTipShowTip(gamePadIndex)
				local padTipNameId = gamePadArea:GetButtonInfoTipNameId(gamePadIndex)
				self.gamePadTipCache[self.conditionType.Default][btnTypeNum] = {
					showTip = padShowTip,
					tipNameId = padTipNameId
				}
				self.finalGamepadTipState[btnTypeNum] = {
					showTip = padShowTip,
					tipNameId = padTipNameId
				}
			end
		end
	else
		local finalText = self.finalMobileText[btnTypeNum]

		if finalText == nil then
			self:ApplyBtnText(btn, finalText)
		end
	end
end

M.InitMobileTextCache = function(self)
	gStoreButtonMgr:InitBtnTextVisible()

	for _, btnTypeNum in pairs(self.btnInfoEnum) do
		if btnTypeNum == self.btnInfoEnum.Count then
			self.mobileTextCache[self.conditionType.Default][btnTypeNum] = 0
			self.finalMobileText[btnTypeNum] = self.mobileTextCache[self.conditionType.Default][btnTypeNum]
		end
	end

	self.mobileTextImportance = {}

	for i = 0, HudDescConfig.count - 1 do
		local config = HudDescConfig.LoadAt(i)

		if config.TextId == 0 and config.ButtonInfoEnum == 0 then
			self.mobileTextCache[self.conditionType.Default][config.ButtonInfoEnum] = config.TextId

			self:RecalculateAndApplyText(config.ButtonInfoEnum)
		end
	end
end

M.GetCachedGroup = function(self, groupName)
	if self.groupCache[groupName] then
		return self.groupCache[groupName]
	end

	local groupObj = gStoreManager:GetStoreGroup(groupName)

	if groupObj then
		self.groupCache[groupName] = groupObj
	else
		print_error("[CoreHudTipManager][GetCachedGroup]找不到 Group -> " .. groupName)
	end

	return groupObj
end

M.InitDefaultBtnIcon = function(self)
	for i = 0, CoreHudButtonConfig.count - 1 do
		local cfg = CoreHudButtonConfig.LoadAt(i)

		if cfg and cfg.DefaultIconId and cfg.DefaultIconId == 0 then
			self.mobileIconCache[self.conditionType.Default][cfg.Id] = cfg.DefaultIconId
		end
	end
end

M.InitGameplayTagTipConfigs = function(self)
	self.queryConfigs = {}
	self.queryIdToButtonEnum = {}
	self.buttonQueryList = {}
	self.buttonQueryStates = {}

	for i = 0, CoreHudButtonTipMapConfig.count - 1 do
		local cfg = CoreHudButtonTipMapConfig.LoadAt(i)
		local queryId = cfg and cfg.QueryId
		local btn = cfg and cfg.ButtonEnum

		if queryId and btn then
			self.queryConfigs[queryId] = cfg

			if not self.queryIdToButtonEnum[queryId] then
				self.queryIdToButtonEnum[queryId] = {}
			end

			local alreadyExists = false

			for _, existBtn in ipairs(self.queryIdToButtonEnum[queryId]) do
				if existBtn ~= btn then
					alreadyExists = true

					break
				end
			end

			if not alreadyExists then
				table.insert(self.queryIdToButtonEnum[queryId], btn)
			end

			self.buttonQueryList[btn] = self.buttonQueryList[btn] or {}

			table.insert(self.buttonQueryList[btn], cfg)

			self.buttonQueryStates[btn] = self.buttonQueryStates[btn] or {}
			self.buttonQueryStates[btn][queryId] = false
		end
	end

	for btn, list in pairs(self.buttonQueryList) do
		table.sort(list, function (a, b)
			local pa = a and a.Priority or 0
			local pb = b and b.Priority or 0

			if pa == pb then
				return pb <= pa
			end

			local qa = a and a.QueryId or 0
			local qb = b and b.QueryId or 0

			return qa <= qb
		end)
	end

	for btn, list in pairs(self.buttonQueryList) do
		table.sort(list, function (a, b)
			local pa = a.Priority or 0
			local pb = b.Priority or 0

			if pa ~= pb then
				return (a.Id or 0) <= (b.Id or 0)
			end

			return pb <= pa
		end)
	end

	self:InitDefaultBtnIcon()
end

M.UpdateBtnTipState = function(self, btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData then
		return
	end

	if not self.PCTipCache[conditionType] then
		self:Log("UpdateBtnTipParkourState:Invalid ConditionType:", conditionType)

		return
	end

	local _showTip = stateData.useTipMode ~= 1

	if not self.PCTipCache[conditionType][btnEnum] then
		self.PCTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = stateData.tipId
		}

		self:RecalculateAndApplyPCTip(btnEnum)
	elseif self.PCTipCache[conditionType][btnEnum].showTip == _showTip or self.PCTipCache[conditionType][btnEnum].tipNameId == stateData.tipId then
		self.PCTipCache[conditionType][btnEnum].showTip = _showTip
		self.PCTipCache[conditionType][btnEnum].tipNameId = stateData.tipId

		self:RecalculateAndApplyPCTip(btnEnum)
	end
end

M.UpdateBtnTipSpecial = function(self, btnEnum, conditionType, _showTip, _tipNameId)
	if not self.isInitCache or _showTip ~= nil or _tipNameId ~= nil then
		return
	end

	if not self.PCTipCache[conditionType] then
		self:Log("UpdateBtnTipSpecial:Invalid ConditionType:", conditionType)

		return
	end

	if not self.PCTipCache[conditionType][btnEnum] then
		self.PCTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = _tipNameId
		}

		self:RecalculateAndApplyPCTip(btnEnum)
	elseif self.PCTipCache[conditionType][btnEnum].showTip == _showTip or self.PCTipCache[conditionType][btnEnum].tipNameId == _tipNameId then
		self.PCTipCache[conditionType][btnEnum].showTip = _showTip
		self.PCTipCache[conditionType][btnEnum].tipNameId = _tipNameId

		self:RecalculateAndApplyPCTip(btnEnum)
	end
end

M.RecalculateAndApplyPCTip = function(self, btnEnum)
	local finalShowTip, finalTipId = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.PCTipCache[condition][btnEnum]

		if cacheState and (condition ~= self.conditionType.Default or cacheState.tipNameId == -1) then
			finalShowTip = cacheState.showTip
			finalTipId = cacheState.tipNameId

			break
		end
	end

	if finalShowTip ~= nil or finalTipId ~= nil then
		self:Log("No state found for btnEnum, not even Default:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousState = self.finalTipStates[btnEnum]

	if not previousState then
		self.finalTipStates[btnEnum] = {
			showTip = finalShowTip,
			tipNameId = finalTipId
		}

		self:ApplyTipRefreshForPC(btnEnum, finalShowTip, finalTipId)
	elseif finalTipId == previousState.tipNameId or finalShowTip == previousState.showTip then
		self.finalTipStates[btnEnum].showTip = finalShowTip
		self.finalTipStates[btnEnum].tipNameId = finalTipId

		self:ApplyTipRefreshForPC(btnEnum, finalShowTip, finalTipId)
	end
end

M.ApplyTipRefreshForPC = function(self, btnEnum, finalShowTip, finalTipId)
	local btnGo = self:GetBtnGoForPC(btnEnum)

	if not btnGo then
		self:Log("Can not Get btnGo, btnType", self.btnEnumToBtnRef[btnEnum])

		return
	end

	self:Log("ApplyTipRefreshForPC", btnEnum, finalShowTip, finalTipId)
	btnGo:SetPCKeyTipShowTip(finalShowTip)
	self:SetBtnHideByBtnType(btnEnum, finalShowTip)
	btnGo:SetPCKeyInfoTipNameId(finalTipId)
end

M.GetBtnGoForPC = function(self, btnEnum)
	if self.btnGoCache[btnEnum] then
		return self.btnGoCache[btnEnum]
	end

	local store = self:GetCachedGroup("CoreHudCharacterControlStore")
	local taFei = self:GetCachedGroup("UniqueSkillTaFeiStore")
	local systemControl = self:GetCachedGroup("CoreHudSystemControlStore")
	local wingSuit = self:GetCachedGroup("CostumWingSuitStore")
	local btnRefName = self.btnEnumToBtnRef[btnEnum]

	if not btnRefName then
		return nil
	end

	local btn = store and (store.characterControlData[btnRefName] or store[btnRefName] or taFei.bindData[btnRefName]) or systemControl and systemControl.bindData[btnRefName] or wingSuit and wingSuit.bindData[btnRefName] or nil
	self.btnGoCache[btnEnum] = btn

	return btn
end

M.UpdateBtnTipAllWeaponState = function(self)
	if not self.isInitCache then
		return
	end

	local weaponId = gCS.WeaponMgr.GetCurrentWeaponTid()
	local weaponCfg = SceneitemConfig.GetConfig(weaponId)

	if not weaponCfg then
		self:Log("UpdateBtnTipAllWeaponState:No Config For WeaponId:", weaponId)

		return
	end

	local weaponTipType = weaponCfg.UiTipsType

	if not weaponTipType then
		self:Log("UpdateBtnTipAllWeaponState:Weapon No weaponTipType:", weaponId)

		return
	end

	local weaponTipInfo = SceneitemWeaponBtnConfig.GetConfig(weaponTipType)

	if not weaponTipInfo then
		self:FatalLog("策划修改武器UI配置 UpdateBtnTipAllWeaponState:No weaponTipInfo For WeaponId:", weaponId)

		return
	end

	for configName, btnEnum in pairs(self.weaponCfgToBtnEnum) do
		local stateData = weaponTipInfo[configName]

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self:UpdateBtnTipState(btnEnum, self.conditionType.Weapon, stateData)
		elseif not self.pcOnlyBtnEnums[btnEnum] then
			if stateData.mobileSkillIcon then
				self:UpdateBtnIconState(btnEnum, self.conditionType.Weapon, stateData.mobileSkillIcon)
			end

			if stateData.width and stateData.height and stateData.posX and stateData.posY then
				self:UpdateBtnPosition(btnEnum, self.conditionType.Weapon, stateData)
			end

			if stateData.tipId then
				self:UpdateBtnTextState(btnEnum, self.conditionType.Weapon, stateData)
			end
		end
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		weaponTipInfo = SceneitemWeaponBtnConfig.GetConfig(weaponTipType)

		for configName, btnEnum in pairs(self.gamepadWeaponCfgToBtnEnum) do
			local gamepadStateData = weaponTipInfo[configName]

			if configName ~= "WestButton_Click" then
				self:UpdateGamepadBtnTipState(self.btnInfoEnum.NormalAttack, self.conditionType.Weapon, gamepadStateData)
			end

			self:UpdateGamepadBtnTipState(btnEnum, self.conditionType.Weapon, gamepadStateData)
		end
	end
end

M.SetBtnHideByBtnType = function(self, btnType, showTip)
	if btnType ~= self.btnInfoEnum.Skill then
		gCoreHudUIManager:OnSetSkillBtnState(self.btnInfoEnum.Skill, "isHideByTipRefresh", showTip)
	elseif btnType ~= self.btnInfoEnum.UltSkill then
		gCoreHudUIManager:OnSetSkillBtnState(self.btnInfoEnum.UltSkill, "isHideByTipRefresh", showTip or self.finalGamepadTipState[self.btnInfoEnum.GamepadWeaponR].showTip)
	elseif btnType ~= self.btnInfoEnum.GamepadWeaponR then
		gCoreHudUIManager:OnSetSkillBtnState(self.btnInfoEnum.UltSkill, "isHideByTipRefresh", showTip)
	end
end

M.UpdateGamepadBtnTipState = function(self, btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData then
		return
	end

	if not self.gamePadTipCache[conditionType] then
		self:Log("UpdateGamepadBtnTipState:Invalid ConditionType:", conditionType)

		return
	end

	local _showTip = stateData.useTipMode ~= 1

	if not self.gamePadTipCache[conditionType][btnEnum] then
		self.gamePadTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = stateData.tipId
		}

		self:RecalculateAndApplyGamepadTip(btnEnum)
	elseif self.gamePadTipCache[conditionType][btnEnum].showTip == _showTip or self.gamePadTipCache[conditionType][btnEnum].tipNameId == stateData.tipId then
		self.gamePadTipCache[conditionType][btnEnum].showTip = _showTip
		self.gamePadTipCache[conditionType][btnEnum].tipNameId = stateData.tipId

		self:RecalculateAndApplyGamepadTip(btnEnum)
	end
end

M.UpdateGamepadBtnTipSpecial = function(self, btnEnum, conditionType, _showTip, _tipNameId)
	if not self.isInitCache or _showTip ~= nil or _tipNameId ~= nil then
		return
	end

	if not self.gamePadTipCache[conditionType] then
		self:Log("UpdateGamepadBtnTipSpecial:Invalid ConditionType:", conditionType)

		return
	end

	if not self.gamePadTipCache[conditionType][btnEnum] then
		self.gamePadTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = _tipNameId
		}

		self:RecalculateAndApplyGamepadTip(btnEnum)
	elseif self.gamePadTipCache[conditionType][btnEnum].showTip == _showTip or self.gamePadTipCache[conditionType][btnEnum].tipNameId == _tipNameId then
		self.gamePadTipCache[conditionType][btnEnum].showTip = _showTip
		self.gamePadTipCache[conditionType][btnEnum].tipNameId = _tipNameId

		self:RecalculateAndApplyGamepadTip(btnEnum)
	end
end

M.RecalculateAndApplyGamepadTip = function(self, btnEnum)
	local finalShowTip, finalTipId = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.gamePadTipCache[condition][btnEnum]

		if cacheState and (condition ~= self.conditionType.Default or cacheState.tipNameId == -1) then
			finalShowTip = cacheState.showTip
			finalTipId = cacheState.tipNameId

			break
		end
	end

	if finalShowTip ~= nil or finalTipId ~= nil then
		self:Log("No state found for btnEnum, not even Default:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousState = self.finalGamepadTipState[btnEnum]

	if not previousState then
		self.finalGamepadTipState[btnEnum] = {
			showTip = finalShowTip,
			tipNameId = finalTipId
		}

		self:ApplyTipRefreshForGamepad(btnEnum, finalShowTip, finalTipId)
	elseif finalTipId == previousState.tipNameId or finalShowTip == previousState.showTip then
		self.finalGamepadTipState[btnEnum].showTip = finalShowTip
		self.finalGamepadTipState[btnEnum].tipNameId = finalTipId

		self:ApplyTipRefreshForGamepad(btnEnum, finalShowTip, finalTipId)
	end
end

M.ApplyTipRefreshForGamepad = function(self, btnEnum, finalShowTip, finalTipId)
	local store = self:GetStoreForGamepad(btnEnum)
	local buttonInfoIndex = self.btnEnumToGamePadIndex[btnEnum]

	if not store or not store.bindData.gamePadArea or buttonInfoIndex ~= -1 then
		self:Log("ApplyTipRefreshForGamepad Can not Get store, btnType:", btnEnum, buttonInfoIndex)

		return
	end

	if table.contains(self.onlyTipButtonEnum, btnEnum) then
		store.bindData.gamePadArea:SetButtonInfoTipOnlyShowTipAndShowTip(finalShowTip, finalShowTip, buttonInfoIndex)
	else
		store.bindData.gamePadArea:SetButtonInfoTipShowTip(finalShowTip, buttonInfoIndex)
	end

	self:SetBtnHideByBtnType(btnEnum, finalShowTip)
	store.bindData.gamePadArea:SetButtonInfoTipNameId(finalTipId, buttonInfoIndex)
end

M.GetStoreForGamepad = function(self, btnEnum)
	local characterControl = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")
	local taFei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")
	local wingSuit = gStoreManager:GetStoreGroup("CostumWingSuitStore")
	local isTaFeiBtn = btnEnum ~= self.btnInfoEnum.TaFeiMoto or btnEnum ~= self.btnInfoEnum.MotoDash or btnEnum ~= self.btnInfoEnum.MotoLight

	if isTaFeiBtn then
		return taFei
	end

	if btnEnum ~= self.btnInfoEnum.WingSuitDash then
		return wingSuit
	end

	return characterControl
end

M.UpdateBtnPosition = function(self, btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData or self.isNonMobile then
		return
	end

	if not self.mobileCache[conditionType] then
		self:Log("UpdateBtnPosition:Invalid ConditionType:", conditionType)

		return
	end

	local newPos = Vector2.New(stateData.posX, stateData.posY)
	local newSize = Vector2.New(stateData.width, stateData.height)

	if not self.mobileCache[conditionType][btnEnum] then
		self.mobileCache[conditionType][btnEnum] = {
			pos = newPos,
			size = newSize
		}

		self:RecalculateAndApplyMobile(btnEnum)
	elseif self.mobileCache[conditionType][btnEnum].pos.x == newPos.x or self.mobileCache[conditionType][btnEnum].pos.y == newPos.y or self.mobileCache[conditionType][btnEnum].size.x == newSize.x or self.mobileCache[conditionType][btnEnum].size.y == newSize.y then
		self.mobileCache[conditionType][btnEnum].pos = newPos
		self.mobileCache[conditionType][btnEnum].size = newSize

		self:RecalculateAndApplyMobile(btnEnum)
	end
end

M.RecalculateAndApplyMobile = function(self, btnEnum)
	local finalPos, finalSize = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.mobileCache[condition][btnEnum]

		if cacheState and (condition ~= self.conditionType.Default or cacheState.pos.x == -1 or cacheState.pos.y == -1) then
			finalPos = cacheState.pos

			break
		end
	end

	for condition = 1, table.count(self.conditionType) do
		local cacheStateSize = self.mobileCache[condition][btnEnum]

		if cacheStateSize and (condition ~= self.conditionType.Default or cacheStateSize.size.x == -1 or cacheStateSize.size.y == -1) then
			finalSize = cacheStateSize.size

			break
		end
	end

	if finalPos ~= nil or finalSize ~= nil then
		self:Log("[RecalculateAndApplyMobile]No state found for btnEnum, not even Default:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousState = self.finalMobileStates[btnEnum]

	if not previousState then
		self.finalMobileStates[btnEnum] = {
			pos = finalPos,
			size = finalSize
		}

		self:ApplyPositionRefreshForMobile(btnEnum, finalPos, finalSize)
	elseif finalPos == previousState.showTip or finalSize == previousState.tipNameId then
		self.finalMobileStates[btnEnum].pos = finalPos
		self.finalMobileStates[btnEnum].size = finalSize

		self:ApplyPositionRefreshForMobile(btnEnum, finalPos, finalSize)
	end
end

M.ApplyPositionRefreshForMobile = function(self, btnEnum, finalPos, finalSize)
	local btnGo = self:GetBtnGoForPC(btnEnum)

	if not btnGo then
		self:Log("[ApplyPositionRefreshForMobile]Can not Get btnGo, btnType", self.btnEnumToBtnRef[btnEnum])

		return
	end

	btnGo.anchoredPosition = finalPos
	btnGo.sizeDelta = finalSize

	self:Log("[ApplyPositionRefreshForMobile] finish", btnEnum, finalPos, finalSize)
end

M.UpdateBtnIconState = function(self, btnEnum, conditionType, iconId)
	if not self.isInitCache or not iconId or self.isNonMobile then
		return
	end

	if not self.mobileIconCache[conditionType] then
		self:Log("UpdateBtnIconState:Invalid ConditionType:", conditionType)

		return
	end

	if not self.mobileIconCache[conditionType][btnEnum] or self.mobileIconCache[conditionType][btnEnum] == iconId then
		self.mobileIconCache[conditionType][btnEnum] = iconId

		self:RecalculateAndApplyIcon(btnEnum)
	end
end

M.RecalculateAndApplyIcon = function(self, btnEnum)
	local finalIcon = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.mobileIconCache[condition][btnEnum]

		if cacheState and (condition ~= self.conditionType.Default or cacheState == 0) then
			finalIcon = cacheState

			break
		end
	end

	if finalIcon ~= nil then
		self:Log("[RecalculateAndApplyIcon]No state found for btnEnum, 没有配置默认按键图标:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousIcon = self.finalMobileIcon[btnEnum]

	if not previousIcon or finalIcon == previousIcon then
		self.finalMobileIcon[btnEnum] = finalIcon
		local btnGo = self:GetBtnGoForPC(btnEnum)

		if not btnGo or not btnGo.Store then
			self:Log("[ApplyPositionRefreshForMobile]Can not Get btnGo, btnType", self.btnEnumToBtnRef[btnEnum])

			return
		end

		local btnStore = gStoreManager:GetStoreGroup(btnGo.Store):GetStoreByWidget(btnGo)

		btnStore:Commit("btnIcon", finalIcon, COMMIT_IMMEDIATELY)
		btnStore:Commit("xuliIcon", finalIcon, COMMIT_IMMEDIATELY)
		btnStore:Commit("btnIconvx", finalIcon, COMMIT_IMMEDIATELY)
		self:Log("[RecalculateAndApplyIcon] finish", btnEnum, finalIcon)
	end
end

M.UpdateBtnTextState = function(self, btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData or self.isNonMobile then
		return
	end

	if not self.mobileTextCache[conditionType] then
		self:Log("UpdateBtnTextState:Invalid ConditionType:", conditionType)

		return
	end

	if not self.mobileTextCache[conditionType][btnEnum] or self.mobileTextCache[conditionType][btnEnum] == stateData.tipId then
		self.mobileTextCache[conditionType][btnEnum] = stateData.tipId

		self:RecalculateAndApplyText(btnEnum)
	end
end

M.UpdateBtnTextSpecial = function(self, btnEnum, conditionType, newTextId)
	if not self.isInitCache or not newTextId or self.isNonMobile then
		return
	end

	if not self.mobileTextCache[conditionType] then
		self:Log("UpdateBtnTextSpecial:Invalid ConditionType:", conditionType)

		return
	end

	if not self.mobileTextCache[conditionType][btnEnum] or self.mobileTextCache[conditionType][btnEnum] == newTextId then
		self.mobileTextCache[conditionType][btnEnum] = newTextId

		self:RecalculateAndApplyText(btnEnum)
	end
end

M.RecalculateAndApplyText = function(self, btnEnum)
	local finalText = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.mobileTextCache[condition][btnEnum]

		if cacheState and (condition ~= self.conditionType.Default or cacheState == -1) then
			finalText = cacheState

			break
		end
	end

	if finalText ~= nil then
		self:Log("[RecalculateAndApplyText]No state found for btnEnum, not even Default:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousText = self.finalMobileText[btnEnum]

	if not previousText or finalText == previousText then
		self.finalMobileText[btnEnum] = finalText
		local btnGo = self:GetBtnGoForPC(btnEnum)

		self:ApplyBtnText(btnGo, finalText)

		if btnEnum ~= self.btnInfoEnum.NormalAttack then
			local store = self:GetCachedGroup("CoreHudCharacterControlStore")
			local btn = store and store.characterControlData.leftShootBtn or nil

			self:ApplyBtnText(btn, finalText)
		end

		self:Log("[RecalculateAndApplyText] finish", btnEnum, finalText)
	end
end

M.ApplyBtnText = function(self, btnGo, finalText)
	if not btnGo or not btnGo.Store then
		self:Log("[ApplyBtnText]在设置按钮文本时找不到按钮对象")

		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btnGo.Store)

	if not storeGroup then
		self:FatalLog("[ApplyBtnText] GetStoreGroup返回nil, Store=", btnGo.Store, finalText)

		return
	end

	local btnStore = storeGroup:GetStoreByWidget(btnGo)

	if finalText and finalText == -1 and finalText == 0 then
		btnStore:Commit("notifyWord", InputButtonNameConfig.GetConfig(finalText).Name, COMMIT_IMMEDIATELY)
	else
		btnStore.notifyWord = ""
	end
end

M.OnGameplayTagTipRefresh = function(self, eventId, queryId, isActive)
	if gCoreHudUIManager and gCoreHudUIManager.hudDecisionMode ~= 1 then
		return
	end

	local btnList = self.queryIdToButtonEnum and self.queryIdToButtonEnum[queryId]

	self:Log("[OnGameplayTagTipRefresh]", queryId, isActive, btnList)

	if not btnList or #btnList ~= 0 then
		return
	end

	for _, btn in ipairs(btnList) do
		self.buttonQueryStates[btn] = self.buttonQueryStates[btn] or {}
		self.buttonQueryStates[btn][queryId] = isActive ~= true

		self:RefreshButtonTipForGameplayTag(btn)
	end
end

M.RefreshButtonTipForGameplayTag = function(self, buttonEnum)
	local parkour = self.conditionType.Parkour
	local gamepadBtnEnum = buttonEnum

	if buttonEnum ~= self.btnInfoEnum.HeavyAttack and gCoreHudUIManager.isHoldRangedWeapon then
		gamepadBtnEnum = self.btnInfoEnum.GamepadWeaponAim
	end

	local list = self.buttonQueryList and self.buttonQueryList[buttonEnum]

	if not list or #list ~= 0 then
		self:UpdateBtnTextSpecial(buttonEnum, parkour, -1)

		return
	end

	local states = self.buttonQueryStates and self.buttonQueryStates[buttonEnum] or {}
	local isPC = gCoreHudUIManager.isNonMobileAdaptive
	local picked = nil

	for i = 1, #list do
		local cfg = list[i]
		local qid = cfg and cfg.QueryId

		if qid and states[qid] ~= true then
			local platform = cfg.TipPlatform

			if not isPC or platform == 3 then
				if isPC or platform == 2 then
					picked = cfg

					break
				end
			end
		end
	end

	if picked then
		if isPC then
			local showTip = picked.TextId == nil and picked.TextId == -1 and picked.TextId == 0

			self:UpdateBtnTipSpecial(buttonEnum, parkour, showTip, picked.TextId or -1)
			self:UpdateGamepadBtnTipSpecial(gamepadBtnEnum, parkour, showTip, picked.TextId or -1)
		elseif not self.pcOnlyBtnEnums[buttonEnum] then
			self:UpdateBtnTextSpecial(buttonEnum, parkour, picked.TextId or -1)
			self:UpdateBtnIconState(buttonEnum, parkour, picked.ImageId or 0)
		end
	elseif isPC then
		self:UpdateBtnTipSpecial(buttonEnum, parkour, false, -1)
		self:UpdateGamepadBtnTipSpecial(gamepadBtnEnum, parkour, false, -1)
	elseif not self.pcOnlyBtnEnums[buttonEnum] then
		self:UpdateBtnTextSpecial(buttonEnum, parkour, -1)
		self:UpdateBtnIconState(buttonEnum, parkour, 0)
	end
end

M.OnIntelligentSearchChange = function(self, eventId, hasTarget)
	local newTextId = hasTarget and 465 or -1

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:UpdateBtnTipSpecial(self.btnInfoEnum.NormalAttack, self.conditionType.Special, hasTarget, newTextId)
		self:UpdateGamepadBtnTipSpecial(self.btnInfoEnum.NormalAttack, self.conditionType.Special, hasTarget, newTextId)
	else
		self:UpdateBtnTextSpecial(self.btnInfoEnum.NormalAttack, self.conditionType.Special, newTextId)
	end
end

M.Log = function(self, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[CoreHudTipManager]", ...)
	end
end

M.FatalLog = function(self, ...)
	print_error("[CoreHudTipManager] 存在配置错误 @xuchenfei @xiongzheng", ...)
end

M.OnLanguageChange = function(self, eventId, lang)
	if not self.isInitCache then
		return
	end

	if self.isNonMobile then
		for btnEnum, state in pairs(self.finalTipStates) do
			if state.tipNameId and state.tipNameId == -1 then
				local btnGo = self:GetBtnGoForPC(btnEnum)

				if btnGo then
					btnGo:SetPCKeyInfoTipNameId(state.tipNameId)
				end
			end
		end

		for btnEnum, state in pairs(self.finalGamepadTipState) do
			if state.tipNameId and state.tipNameId == -1 then
				local buttonInfoIndex = self.btnEnumToGamePadIndex[btnEnum]

				if buttonInfoIndex and buttonInfoIndex == -1 then
					local store = self:GetStoreForGamepad(btnEnum)

					if store and store.bindData.gamePadArea then
						store.bindData.gamePadArea:SetButtonInfoTipNameId(state.tipNameId, buttonInfoIndex)
					end
				end
			end
		end
	else
		for btnEnum, finalText in pairs(self.finalMobileText) do
			if finalText and finalText == -1 and finalText == 0 then
				local btnGo = self:GetBtnGoForPC(btnEnum)

				self:ApplyBtnText(btnGo, finalText)

				if btnEnum ~= self.btnInfoEnum.NormalAttack then
					local store = self:GetCachedGroup("CoreHudCharacterControlStore")
					local btn = store and store.characterControlData.leftShootBtn or nil

					self:ApplyBtnText(btn, finalText)
				end
			end
		end
	end
end

M.SetNewTipMode = function(self, isEnable)
	self.isEnable = isEnable
end

gCoreHudTipManager = gCoreHudTipManager or C_CoreHudTipManager.new()
