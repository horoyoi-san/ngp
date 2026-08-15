local ButtonInfoEnum = LX6.Units.Module.ButtonInfoEnum
local WeaponConfig = LTConfig.WeaponConfig
local WeaponGamepadBtnConfig = LTConfig.WeaponWeaponGamepadBtnConfig
local WeaponPCBtnConfig = LTConfig.WeaponWeaponPCBtnConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
C_CoreHudTipManager = DefClass("C_CoreHudTipManager", C_CoreHudTipManager)
local M = C_CoreHudTipManager

function M:ctor()
	self.isDebug = false
	self.isInitCache = false
	self.isEnable = true
	self.btnInfoEnum = LX6.Units.Module.ButtonInfoEnum
	self.btnInfoEnum.GamepadWeaponE = 100
	self.btnInfoEnum.GamepadWeaponR = 101
	self.btnInfoEnum.GamepadWeaponShoot = 102
	self.btnInfoEnum.GamepadWeaponAim = 103
	self.MotoSpeedUpGamepadIndex = 26
	self.btnEnumToBtnRef = {
		[ButtonInfoEnum.NormalAttack] = "normalAttackBtn",
		[ButtonInfoEnum.HeavyAttack] = "heavyAttackBtn",
		[ButtonInfoEnum.Skill] = "basicSkillBtnGo",
		[ButtonInfoEnum.UltSkill] = "ultSkillBtnGo",
		[ButtonInfoEnum.Dodge] = "dodgeBtn",
		[ButtonInfoEnum.JumpJump] = "jumpSwingBtn",
		[ButtonInfoEnum.MindPower] = "mindPowerBtn",
		[ButtonInfoEnum.Grapple] = "grappleBtn",
		[ButtonInfoEnum.OffWall] = "dropBtn",
		[ButtonInfoEnum.Magnet] = "magnetBtn",
		[ButtonInfoEnum.MagnetPutDown] = "putDownBtn",
		[ButtonInfoEnum.HandBagPutDown] = "handBagPutDownBtn",
		[ButtonInfoEnum.DiveBtnInfo] = "ctrlButton",
		[ButtonInfoEnum.EBtnInfo] = "basicNormalBtnGo",
		[ButtonInfoEnum.RBtnInfo] = "ultNormalBtnGo",
		[ButtonInfoEnum.TaFeiMoto] = "motoBtn",
		[ButtonInfoEnum.Hold_Left] = "holdLeftBtn",
		[ButtonInfoEnum.Hold_E] = "holdEBtn",
		[ButtonInfoEnum.Hold_R] = "holdRBtn"
	}
	self.btnEnumToGamePadIndex = {
		[ButtonInfoEnum.NormalAttack] = 5,
		[ButtonInfoEnum.HeavyAttack] = 10,
		[ButtonInfoEnum.Skill] = 13,
		[ButtonInfoEnum.UltSkill] = 11,
		[ButtonInfoEnum.Dodge] = 2,
		[ButtonInfoEnum.JumpJump] = 1,
		[ButtonInfoEnum.MindPower] = -1,
		[ButtonInfoEnum.Grapple] = -1,
		[ButtonInfoEnum.OffWall] = -1,
		[ButtonInfoEnum.Magnet] = 4,
		[ButtonInfoEnum.MagnetPutDown] = 3,
		[ButtonInfoEnum.HandBagPutDown] = -1,
		[ButtonInfoEnum.DiveBtnInfo] = -1,
		[ButtonInfoEnum.EBtnInfo] = 32,
		[ButtonInfoEnum.RBtnInfo] = -1,
		[ButtonInfoEnum.TaFeiMoto] = 1,
		[ButtonInfoEnum.Hold_Left] = 25,
		[ButtonInfoEnum.Hold_R] = -1,
		[ButtonInfoEnum.Hold_E] = 31,
		[self.btnInfoEnum.GamepadWeaponE] = 27,
		[self.btnInfoEnum.GamepadWeaponR] = 28,
		[self.btnInfoEnum.GamepadWeaponShoot] = 8,
		[self.btnInfoEnum.GamepadWeaponAim] = 29
	}
	self.weaponCfgToBtnEnum = {
		MouseLeft_Click = ButtonInfoEnum.NormalAttack,
		MouseLeft_Hold = ButtonInfoEnum.Hold_Left,
		MouseRight_Click = ButtonInfoEnum.HeavyAttack,
		ButtonCombatE_Click = ButtonInfoEnum.Skill,
		ButtonE_Click = ButtonInfoEnum.EBtnInfo,
		ButtonE_Hold = ButtonInfoEnum.Hold_E,
		ButtonCombatR_Click = ButtonInfoEnum.UltSkill,
		ButtonR_Click = ButtonInfoEnum.RBtnInfo
	}
	self.gamepadWeaponCfgToBtnEnum = {
		WestButton_Click = self.btnInfoEnum.GamepadWeaponE,
		WestButton_Hold = ButtonInfoEnum.Hold_Left,
		NorthButton_Click = self.btnInfoEnum.GamepadWeaponR,
		NorthButton_Hold = ButtonInfoEnum.Hold_E,
		North_EastButton = ButtonInfoEnum.UltSkill,
		LeftTrigger_Click = self.btnInfoEnum.GamepadWeaponAim,
		RightTrigger_Click = self.btnInfoEnum.GamepadWeaponShoot
	}
	self.conditionType = {
		Weapon = 4,
		Environment = 2,
		MultiPhase = 3,
		Default = 5,
		Parkour = 1
	}
	self.onlyTipButtonEnum = {
		ButtonInfoEnum.Hold_Left,
		ButtonInfoEnum.Hold_E,
		ButtonInfoEnum.Hold_R
	}
	self.sortedConditions = {}

	for key in pairs(self.conditionType) do
		table.insert(self.sortedConditions, key)
	end

	table.sort(self.sortedConditions, function (a, b)
		return self.conditionType[b] < self.conditionType[a]
	end)

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
	self.mobileCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.mobileCache[conditionType] = {}
	end

	self.mobileIconCache = {}

	for _, conditionType in pairs(self.conditionType) do
		self.mobileIconCache[conditionType] = {}
	end

	self.btnGoCache = {}
end

function M:OnInit()
	return
end

function M:RegisterDataSetEvents(eventHandlers)
	if #eventHandlers == 0 then
		return
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

function M:ClearDataSetEvents()
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

function M:RegisterSingleEvent(enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function M:RegisterMessageEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

function M:ClearMessageEvents()
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

function M:CreateAction(action, target)
	return function (...)
		target = target or self

		if type(action) == "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

function M:CreateActionWithArgs(action, args, target)
	return function (...)
		target = target or self

		if type(action) == "string" then
			if target[action] then
				return target[action](target, args, ...)
			end
		else
			return action(target, args, ...)
		end
	end
end

function M:InitTipDefaultCache()
	table.clear(self.btnGoCache)

	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")
	local coreHud = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	local tafei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")

	for _, btnTypeNum in pairs(self.btnInfoEnum) do
		if btnTypeNum ~= self.btnInfoEnum.Count then
			local btnRefName = self.btnEnumToBtnRef[btnTypeNum]
			local gamePadIndex = self.btnEnumToGamePadIndex[btnTypeNum]

			if not btnRefName then
				self.PCTipCache[self.conditionType.Default][btnTypeNum] = {
					showTip = false,
					tipNameId = -1
				}
			else
				local btn = store.characterControlData[btnRefName] or store[btnRefName] or tafei.bindData[btnRefName]

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
						showTip = false,
						tipNameId = -1
					}
				end
			end

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self.finalTipStates[btnTypeNum] = {
					showTip = self.PCTipCache[self.conditionType.Default][btnTypeNum].showTip,
					tipNameId = self.PCTipCache[self.conditionType.Default][btnTypeNum].tipNameId
				}
				local showTip = false
				local tipNameId = -1

				if gamePadIndex ~= -1 then
					showTip = coreHud.bindData.gamePadArea:GetButtonInfoTipShowTip(gamePadIndex)
					tipNameId = coreHud.bindData.gamePadArea:GetButtonInfoTipNameId(gamePadIndex)
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
	end

	self.isInitCache = true
end

function M:InitButtonInfoForTabRect(btn, btnTypeNum)
	if not btn or not btnTypeNum then
		return
	end

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
end

function M:UpdateBtnTipState(btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData then
		return
	end

	if not self.PCTipCache[conditionType] then
		self:Log("UpdateBtnTipParkourState:Invalid ConditionType:", conditionType)

		return
	end

	local _showTip = stateData.useTipMode == 1

	if not self.PCTipCache[conditionType][btnEnum] then
		self.PCTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = stateData.tipId
		}

		self:RecalculateAndApplyPCTip(btnEnum)
	elseif self.PCTipCache[conditionType][btnEnum].showTip ~= _showTip or self.PCTipCache[conditionType][btnEnum].tipNameId ~= stateData.tipId then
		self.PCTipCache[conditionType][btnEnum].showTip = _showTip
		self.PCTipCache[conditionType][btnEnum].tipNameId = stateData.tipId

		self:RecalculateAndApplyPCTip(btnEnum)
	end
end

function M:UpdateBtnTipSpecial(btnEnum, conditionType, _showTip, _tipNameId)
	if not self.isInitCache or _showTip == nil or _tipNameId == nil then
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
	elseif self.PCTipCache[conditionType][btnEnum].showTip ~= _showTip or self.PCTipCache[conditionType][btnEnum].tipNameId ~= _tipNameId then
		self.PCTipCache[conditionType][btnEnum].showTip = _showTip
		self.PCTipCache[conditionType][btnEnum].tipNameId = _tipNameId

		self:RecalculateAndApplyPCTip(btnEnum)
	end
end

function M:RecalculateAndApplyPCTip(btnEnum)
	local finalShowTip, finalTipId = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.PCTipCache[condition][btnEnum]

		if cacheState and (condition == self.conditionType.Default or cacheState.tipNameId ~= -1) then
			finalShowTip = cacheState.showTip
			finalTipId = cacheState.tipNameId

			break
		end
	end

	if finalShowTip == nil or finalTipId == nil then
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
	elseif finalTipId ~= previousState.tipNameId or finalShowTip ~= previousState.showTip then
		self.finalTipStates[btnEnum].showTip = finalShowTip
		self.finalTipStates[btnEnum].tipNameId = finalTipId

		self:ApplyTipRefreshForPC(btnEnum, finalShowTip, finalTipId)
	end
end

function M:ApplyTipRefreshForPC(btnEnum, finalShowTip, finalTipId)
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

function M:GetBtnGoForPC(btnEnum)
	if self.btnGoCache[btnEnum] then
		return self.btnGoCache[btnEnum]
	end

	local store = gBattleMgr.characterControlPanel
	local taFei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")
	local btnRefName = self.btnEnumToBtnRef[btnEnum]
	local btn = store and (store.characterControlData[btnRefName] or store[btnRefName] or taFei.bindData[btnRefName]) or nil

	return btn
end

function M:UpdateBtnTipAllWeaponState()
	if not self.isInitCache then
		return
	end

	local weaponId = gCS.WeaponMgr:GetCurrentWeaponTid()

	if not WeaponConfig.GetConfig(weaponId) then
		self:Log("UpdateBtnTipAllWeaponState:No Config For WeaponId:", weaponId)

		return
	end

	local weaponTipType = WeaponConfig.GetConfig(weaponId).UiTipsType

	if not weaponTipType then
		self:Log("UpdateBtnTipAllWeaponState:Weapon No weaponTipType:", weaponId)

		return
	end

	local weaponTipInfo = WeaponPCBtnConfig.GetConfig(weaponTipType)

	for configName, btnEnum in pairs(self.weaponCfgToBtnEnum) do
		local stateData = weaponTipInfo[configName]

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self:UpdateBtnTipState(btnEnum, self.conditionType.Weapon, stateData)
		else
			if stateData.mobileSkillIcon then
				self:UpdateBtnIconState(btnEnum, self.conditionType.Weapon, stateData.mobileSkillIcon)
			end

			if stateData.width and stateData.height and stateData.posX and stateData.posY then
				self:UpdateBtnPosition(btnEnum, self.conditionType.Weapon, stateData)
			end
		end
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		weaponTipInfo = WeaponGamepadBtnConfig.GetConfig(weaponTipType)

		for configName, btnEnum in pairs(self.gamepadWeaponCfgToBtnEnum) do
			local gamepadStateData = weaponTipInfo[configName]

			if configName == "WestButton_Click" then
				self:UpdateGamepadBtnTipState(ButtonInfoEnum.NormalAttack, self.conditionType.Weapon, gamepadStateData)
			end

			self:UpdateGamepadBtnTipState(btnEnum, self.conditionType.Weapon, gamepadStateData)
		end
	end
end

function M:SetBtnHideByBtnType(btnType, showTip)
	if btnType == ButtonInfoEnum.Skill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "isHideByTipRefresh", showTip)
	elseif btnType == ButtonInfoEnum.UltSkill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isHideByTipRefresh", showTip or self.finalGamepadTipState[self.btnInfoEnum.GamepadWeaponR].showTip)
	elseif btnType == ButtonInfoEnum.MindPower then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isHideByTipRefresh", not showTip)
	elseif btnType == self.btnInfoEnum.GamepadWeaponR then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isHideByTipRefresh", showTip)
	end
end

function M:UpdateGamepadBtnTipState(btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData then
		return
	end

	if not self.gamePadTipCache[conditionType] then
		self:Log("UpdateGamepadBtnTipState:Invalid ConditionType:", conditionType)

		return
	end

	local _showTip = stateData.useTipMode == 1

	if not self.gamePadTipCache[conditionType][btnEnum] then
		self.gamePadTipCache[conditionType][btnEnum] = {
			showTip = _showTip,
			tipNameId = stateData.tipId
		}

		self:RecalculateAndApplyGamepadTip(btnEnum)
	elseif self.gamePadTipCache[conditionType][btnEnum].showTip ~= _showTip or self.gamePadTipCache[conditionType][btnEnum].tipNameId ~= stateData.tipId then
		self.gamePadTipCache[conditionType][btnEnum].showTip = _showTip
		self.gamePadTipCache[conditionType][btnEnum].tipNameId = stateData.tipId

		self:RecalculateAndApplyGamepadTip(btnEnum)
	end
end

function M:UpdateGamepadBtnTipSpecial(btnEnum, conditionType, _showTip, _tipNameId)
	if not self.isInitCache or _showTip == nil or _tipNameId == nil then
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
	elseif self.gamePadTipCache[conditionType][btnEnum].showTip ~= _showTip or self.gamePadTipCache[conditionType][btnEnum].tipNameId ~= _tipNameId then
		self.gamePadTipCache[conditionType][btnEnum].showTip = _showTip
		self.gamePadTipCache[conditionType][btnEnum].tipNameId = _tipNameId

		self:RecalculateAndApplyGamepadTip(btnEnum)
	end
end

function M:RecalculateAndApplyGamepadTip(btnEnum)
	local finalShowTip, finalTipId = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.gamePadTipCache[condition][btnEnum]

		if cacheState and (condition == self.conditionType.Default or cacheState.tipNameId ~= -1) then
			finalShowTip = cacheState.showTip
			finalTipId = cacheState.tipNameId

			break
		end
	end

	if finalShowTip == nil or finalTipId == nil then
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
	elseif finalTipId ~= previousState.tipNameId or finalShowTip ~= previousState.showTip then
		self.finalGamepadTipState[btnEnum].showTip = finalShowTip
		self.finalGamepadTipState[btnEnum].tipNameId = finalTipId

		self:ApplyTipRefreshForGamepad(btnEnum, finalShowTip, finalTipId)
	end
end

function M:ApplyTipRefreshForGamepad(btnEnum, finalShowTip, finalTipId)
	local store = self:GetStoreForGamepad(btnEnum)
	local buttonInfoIndex = self:ExchangeBtnForSpecial(store, btnEnum, self.btnEnumToGamePadIndex[btnEnum])

	if not store or not store.bindData.gamePadArea or buttonInfoIndex == -1 then
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

function M:ExchangeBtnForSpecial(hud, btnEnum, curBtnIndex)
	if btnEnum == ButtonInfoEnum.Dodge then
		if self.hasBtnExchange then
			hud.bindData.gamePadArea:SetButtonInfoTipShowTip(false, self.MotoSpeedUpGamepadIndex)

			self.hasBtnExchange = nil
		elseif gBattleMgr:CheckIsInMotorState() then
			hud.bindData.gamePadArea:SetButtonInfoTipShowTip(false, curBtnIndex)

			self.hasBtnExchange = true

			return self.MotoSpeedUpGamepadIndex
		end
	end

	return self.btnEnumToGamePadIndex[btnEnum]
end

function M:GetStoreForGamepad(btnEnum)
	local coreHud = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	local taFei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")
	local control = btnEnum == ButtonInfoEnum.TaFeiMoto and taFei or coreHud

	return control
end

function M:UpdateBtnPosition(btnEnum, conditionType, stateData)
	if not self.isInitCache or not stateData then
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
	elseif self.mobileCache[conditionType][btnEnum].pos.x ~= newPos.x or self.mobileCache[conditionType][btnEnum].pos.y ~= newPos.y or self.mobileCache[conditionType][btnEnum].size.x ~= newSize.x or self.mobileCache[conditionType][btnEnum].size.y ~= newSize.y then
		self.mobileCache[conditionType][btnEnum].pos = newPos
		self.mobileCache[conditionType][btnEnum].size = newSize

		self:RecalculateAndApplyMobile(btnEnum)
	end
end

function M:RecalculateAndApplyMobile(btnEnum)
	local finalPos, finalSize = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.mobileCache[condition][btnEnum]

		if cacheState and (condition == self.conditionType.Default or cacheState.pos.x ~= -1 or cacheState.pos.y ~= -1) then
			finalPos = cacheState.pos

			break
		end
	end

	for condition = 1, table.count(self.conditionType) do
		local cacheStateSize = self.mobileCache[condition][btnEnum]

		if cacheStateSize and (condition == self.conditionType.Default or cacheStateSize.size.x ~= -1 or cacheStateSize.size.y ~= -1) then
			finalSize = cacheStateSize.size

			break
		end
	end

	if finalPos == nil or finalSize == nil then
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
	elseif finalPos ~= previousState.showTip or finalSize ~= previousState.tipNameId then
		self.finalMobileStates[btnEnum].pos = finalPos
		self.finalMobileStates[btnEnum].size = finalSize

		self:ApplyPositionRefreshForMobile(btnEnum, finalPos, finalSize)
	end
end

function M:ApplyPositionRefreshForMobile(btnEnum, finalPos, finalSize)
	local btnGo = self:GetBtnGoForPC(btnEnum)

	if not btnGo then
		self:Log("[ApplyPositionRefreshForMobile]Can not Get btnGo, btnType", self.btnEnumToBtnRef[btnEnum])

		return
	end

	btnGo.anchoredPosition = finalPos
	btnGo.sizeDelta = finalSize

	self:Log("[ApplyPositionRefreshForMobile] finish", btnEnum, finalPos, finalSize)
end

function M:UpdateBtnIconState(btnEnum, conditionType, iconId)
	if not self.isInitCache or not iconId then
		return
	end

	if not self.mobileIconCache[conditionType] then
		self:Log("UpdateBtnIconState:Invalid ConditionType:", conditionType)

		return
	end

	if not self.mobileIconCache[conditionType][btnEnum] or self.mobileIconCache[conditionType][btnEnum] ~= iconId then
		self.mobileIconCache[conditionType][btnEnum] = iconId

		self:RecalculateAndApplyIcon(btnEnum)
	end
end

function M:RecalculateAndApplyIcon(btnEnum)
	local finalIcon = nil

	for condition = 1, table.count(self.conditionType) do
		local cacheState = self.mobileIconCache[condition][btnEnum]

		if cacheState and (condition == self.conditionType.Default or cacheState ~= 0) then
			finalIcon = cacheState

			break
		end
	end

	if finalIcon == nil then
		self:Log("[RecalculateAndApplyIcon]No state found for btnEnum, not even Default:", self.btnEnumToBtnRef[btnEnum])

		return
	end

	local previousIcon = self.finalMobileIcon[btnEnum]

	if not previousIcon or finalIcon ~= previousIcon then
		self.finalMobileIcon[btnEnum] = finalIcon
		local btnGo = self:GetBtnGoForPC(btnEnum)

		if not btnGo then
			self:Log("[ApplyPositionRefreshForMobile]Can not Get btnGo, btnType", self.btnEnumToBtnRef[btnEnum])

			return
		end

		local btnStore = gStoreManager:GetStoreGroup(btnGo.Store):GetStoreByWidget(btnGo)
		btnStore.btnIcon = finalIcon
		btnStore.xuliIcon = finalIcon
		btnStore.btnIconvx = finalIcon
		btnStore.iconUlt = finalIcon

		self:Log("[RecalculateAndApplyIcon] finish", btnEnum, finalIcon)
	end
end

function M:Log(...)
	if self.isDebug then
		print_warn("[CoreHudTipManager]", ...)
	end
end

function M:SetNewTipMode(isEnable)
	self.isEnable = isEnable
end

gCoreHudTipManager = gCoreHudTipManager or C_CoreHudTipManager.new()
