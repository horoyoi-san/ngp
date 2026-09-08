-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\CoreHudUIManager_Debug.lua
-- Decompiled from: 02237_CoreHudUIManager_Debug.lua_917cd8db0add.luajit

local M = C_CoreHudUIManager

M.GetRealtimeDecisionDetail = function(self, funcName, decType)
	if funcName ~= "DecideCharacterWheels_RaidCanChangeRole" then
		local ok, v = pcall(function ()
			local raidCfg = LTConfig.RaidConfig.GetConfig(gRaidDataManager.RaidId)
			local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

			return raidTypeCfg and raidTypeCfg.CanChangeRole
		end)

		return string.format("[RT:canChangeRole=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideCharacterWheels_TaskRoleTeam" then
		local ok1, isTeam = pcall(function ()
			return gTaskManager:GetNowTaskIsRoleTeamTask()
		end)
		local ok2, canSwitch = pcall(function ()
			return gSpiritManager:CheckCanTaskRoleSwitch()
		end)

		return string.format("[RT:isRoleTeamTask=%s,canTaskRoleSwitch=%s]", ok1 and tostring(isTeam) or "err", ok2 and tostring(canSwitch) or "err")
	elseif funcName ~= "DecideSkill_Trigger" then
		local ok, v = pcall(function ()
			return gPaokuLimitManager:CheckFightNeedLimit(decType)
		end)

		return string.format("[RT:CheckFightNeedLimit(%s)=%s]", tostring(decType), ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkill_SkillQTE" then
		local ok, v = pcall(function ()
			return gPlayerManager.main.bindData.isInSkillQTE
		end)

		return string.format("[RT:isInSkillQTE=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkill1_SkillQTE" then
		local ok1, v1 = pcall(function ()
			return gPlayerManager.main.bindData.isInSkillQTE
		end)
		local ok2, v2 = pcall(function ()
			return gPlayerManager.main.bindData.banShootBthInHoldState
		end)

		return string.format("[RT:isInSkillQTE=%s,banShootBth=%s]", ok1 and tostring(v1) or "err", ok2 and tostring(v2) or "err")
	elseif funcName ~= "DecideSkill4_CanUseMind" then
		local ok, v = pcall(function ()
			return gPlayerManager.main.bindData.canUseMindPower
		end)

		return string.format("[RT:canUseMindPower=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkill_PaokuLimit" then
		local ok, v = pcall(function ()
			return gPaokuLimitManager:CheckNeedLimit(decType)
		end)

		return string.format("[RT:CheckNeedLimit(%s)=%s]", tostring(decType), ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkill_BadgeUnlock" then
		local ok, v = pcall(function ()
			return gSpiritJobManager:CheckCurSpiritContainBadge(decType)
		end)

		return string.format("[RT:badge(%s)=%s]", tostring(decType), ok and tostring(v) or "err")
	elseif funcName ~= "DecideMoto_IsTaffi" then
		local ok, v = pcall(function ()
			local unit = gCS.MyPlayerManager.PlayerUnit

			return unit and tostring(unit.ClientData.cardId) or "nil"
		end)

		return string.format("[RT:cardId=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideMoto_HasMotorWeapon" then
		local ok, v = pcall(function ()
			local motoId = LTConfig.SceneitemConfig.TaffyMoto

			return motoId and gCS.WeaponMgr.HasWeapon(motoId) or false
		end)

		return string.format("[RT:hasMotorWeapon=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecidePhoneSummon_WatchOrConflict" then
		local ok1, watchState = pcall(function ()
			return gLinkManager.watchState
		end)
		local ok2, hasConflict = pcall(function ()
			return gCallPhoneUtils.CheckPhoneCallConflict()
		end)

		return string.format("[RT:watchState=%s,phoneConflict=%s]", ok1 and tostring(watchState) or "err", ok2 and tostring(hasConflict) or "err")
	elseif funcName ~= "DecidePhoneSummon_SpiritLimit" then
		local ok, v = pcall(function ()
			return gUIFunctionStateManager:CheckVehicleSpiritLimit()
		end)

		return string.format("[RT:vehicleSpiritLimit=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecidePhoneSummon_FormalShortCutKey" then
		local ok, v = pcall(function ()
			return gGmUtils:GetFormalShortCutKeyState()
		end)

		return string.format("[RT:formalShortCutKey=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecidePhoneSummon_Condition" then
		local ok, s = pcall(function ()
			local state = self.skillStateList[decType]
			local canCall = state and state.vehicleCondition
			local contactId = self:GetPhoneSummonContactId(decType)
			local canSummon = false

			if canCall and contactId then
				local spiritId = gSpiritManager:GetCurFirstSpiritTid()
				local cfg = LTConfig.PhoneContactConfig.GetConfig(contactId)
				local hasUnlock = gCallPhoneUtils.CheckConfigContactHasUnlock(spiritId, cfg.Id) ~= true
				local checkPass = true

				if not string.is_null_or_empty(cfg.Check) then
					local ok2, flag = gClientUtils.RunCode(cfg.Check, gDialogScriptFunc)

					if not ok2 or not flag then
						checkPass = false
					end
				end

				canSummon = hasUnlock and checkPass
			end

			return string.format("canCall=%s,canSummon=%s", tostring(canCall), tostring(canSummon))
		end)

		return string.format("[RT:%s]", ok and s or "err")
	elseif funcName ~= "DecideFeiSuo_TaskFeiSuo" then
		local ok1, hasTask = pcall(function ()
			return gTaskManager.taskFeiSuo.hasTaskFeiSuo
		end)
		local ok2, hasTgt = pcall(function ()
			return gGadgetManager.FeiSuoTarget == nil
		end)

		return string.format("[RT:hasTaskFeiSuo=%s,FeiSuoTarget=%s]", ok1 and tostring(hasTask) or "err", ok2 and tostring(hasTgt) or "err")
	elseif funcName ~= "DecideFeiSuo_ForbidNormal" then
		local ok, v = pcall(function ()
			return gFeisuoUIUpdateMgr.HideUI
		end)

		return string.format("[RT:HideUI=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideFeiSuo_FeiSuoPoint" then
		local ok, v = pcall(function ()
			return gFeisuoUIUpdateMgr.selectFeisuoInfo.select
		end)

		return string.format("[RT:select=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkillJump_InLiftHide" then
		local ok, v = pcall(function ()
			return gPlayerManager.main.bindData.isInLift
		end)

		return string.format("[RT:isInLift=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideSkillJump_InZipLineDisable" then
		local ok, v = pcall(function ()
			return gPlayerManager.main.bindData.isInZipLine
		end)

		return string.format("[RT:isInZipLine=%s]", ok and tostring(v) or "err")
	elseif funcName ~= "DecideDive_IsEnableDiving" then
		local ok, v = pcall(function ()
			return LX6.Units.Module.DiveManager.CheckIsEnableDiving()
		end)

		return string.format("[RT:CheckIsEnableDiving=%s]", ok and tostring(v) or "err")
	end

	return nil
end

M._EvalDecisions = function(self, btnId)
	if not self.customBtnList then
		return nil
	end

	local config = self.skillConfigs[btnId]

	if not config then
		return nil
	end

	if not config.decisions then
		return {}
	end

	local monitor = self.buttonStateMonitor and self.buttonStateMonitor[btnId]
	local curVis = monitor and tostring(monitor[1]) or "nil"
	local curInt = monitor and tostring(monitor[2]) or "nil"
	self.curEvalSkillType = btnId
	local results = {}
	local finalVis, finalInt = nil

	for i, dec in ipairs(config.decisions) do
		local funcName = dec.func
		local r = {
			["\\xcf\\xd2(\\xf4"] = "\\x80",
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = "\\x80",
			index = i,
			funcName = funcName or ""
		}

		if not funcName or funcName ~= "" then
			r.funcName = "(empty)"
			results[#results + 1] = r
		else
			local func = self[funcName]

			if not func then
				r.missing = true
				results[#results + 1] = r
			else
				local arg = funcName ~= "DecideFlag" and dec or dec.type
				local ok, res = pcall(func, self, arg)

				if not ok then
					r.visible = "?"
					r.interactable = "?"
					r.error = tostring(res)
					results[#results + 1] = r
				elseif type(res) ~= "table" then
					r.visible = res.visible ~= nil and "-" or tostring(res.visible)
					r.interactable = res.interactable ~= nil and "-" or tostring(res.interactable)
					r.isFinal = res.isFinal or false
					r.reason = res.reason

					if funcName ~= "DecideFlag" and not r.reason then
						local state = self.skillStateList[dec.type or self.curEvalSkillType]
						local flagValue = state and state[dec.flag]
						r.reason = dec.flag .. "=" .. tostring(flagValue) .. " [" .. self.DecisionFlagName[dec.polarity] .. "]"
					end

					if r.isFinal then
						finalVis = r.visible
						finalInt = r.interactable
					end

					results[#results + 1] = r
				else
					r.visible = tostring(res)
					r.interactable = tostring(res)
					results[#results + 1] = r
				end
			end
		end
	end

	return results, curVis, curInt, finalVis, finalInt
end

M._FillRTDetails = function(self, results, decConfigs)
	if not results then
		return
	end

	for _, r in ipairs(results) do
		if not r.missing and not r.error and r.funcName == "" and r.funcName == "(empty)" then
			local decType = decConfigs and decConfigs[r.index] and decConfigs[r.index].type
			r.rtDetail = self:GetRealtimeDecisionDetail(r.funcName, decType)
		end
	end
end

M.DumpButtonStatusOneLine = function(self, skillTypeName)
	local btnId = self.skillType[skillTypeName]

	if not btnId then
		print_debug(string.format("[DumpButtonStatusOneLine] SkillType '%s' not found.", tostring(skillTypeName)))

		return
	end

	local results, curVis, curInt = self._EvalDecisions(self, btnId)

	if not results then
		print_debug("[DumpButtonStatusOneLine] No buttons registered or no config.")

		return
	end

	local config = self.skillConfigs[btnId]

	self:_FillRTDetails(results, config and config.decisions)

	local parts = {
		string.format("[%s|ID:%s|Vis=%s,Int=%s]", skillTypeName, tostring(btnId), curVis, curInt)
	}

	for _, r in ipairs(results) do
		local info = nil

		if r.error then
			info = "ERR=" .. r.error
		elseif r.missing then
			info = "MISS"
		elseif r.funcName ~= "(empty)" then
			info = "empty"
		else
			local fin = r.isFinal and "F" or ""
			info = string.format("V%s/I%s%s", r.visible, r.interactable, fin)

			if r.rtDetail then
				info = info .. r.rtDetail
			end
		end

		parts[#parts + 1] = string.format("%d.%s(%s)", r.index, r.funcName, info)
	end

	print_debug(table.concat(parts, " | "))
end

M.NoticeButtonStatusOneLine = function(self, skillTypeName)
	local btnId = self.skillType[skillTypeName]

	if not btnId then
		print_notice(string.format("[CoreHud] SkillType '%s' not found. Available: %s", tostring(skillTypeName), table.concat(self.GetAllButtonNames(self), ", ")))

		return
	end

	local results, curVis, curInt, finalVis, finalInt = self._EvalDecisions(self, btnId)

	if not results then
		print_notice("[CoreHud] No buttons registered or no config.")

		return
	end

	local config = self.skillConfigs[btnId]

	self:_FillRTDetails(results, config and config.decisions)

	local parts = {
		string.format("[CoreHud][%s|ID:%s|Vis=%s,Int=%s]", skillTypeName, tostring(btnId), curVis, curInt)
	}

	for _, r in ipairs(results) do
		local info = nil

		if r.error then
			info = "ERR=" .. r.error
		elseif r.missing then
			info = "MISS"
		elseif r.funcName ~= "(empty)" then
			info = "empty"
		else
			local fin = r.isFinal and "F" or ""
			info = string.format("V%s/I%s%s", r.visible, r.interactable, fin)

			if r.reason and r.reason == "" then
				info = info .. "(" .. r.reason .. ")"
			end

			if r.rtDetail then
				info = info .. r.rtDetail
			end
		end

		parts[#parts + 1] = string.format("%d.%s:%s", r.index, r.funcName, info)
	end

	if finalVis or finalInt then
		parts[#parts + 1] = string.format("[Final:Vis=%s,Int=%s]", tostring(finalVis), tostring(finalInt))
	end

	local uiStatus = self.GetButtonUIStatus(self, skillTypeName)

	if uiStatus then
		parts[#parts + 1] = uiStatus
	end

	local storeStatus = self.GetButtonStoreStatus(self, btnId)

	if storeStatus then
		parts[#parts + 1] = storeStatus
	end

	print_notice(table.concat(parts, " | "))
end

M.GetButtonRealtimeDetails = function(self, skillTypeName)
	local btnId = self.skillType[skillTypeName]

	if not btnId then
		return {}
	end

	local config = self.skillConfigs[btnId]

	if not config or not config.decisions then
		return {}
	end

	self.curEvalSkillType = btnId
	local details = {}

	for i, dec in ipairs(config.decisions) do
		if dec.func and dec.func == "" then
			local rt = self.GetRealtimeDecisionDetail(self, dec.func, dec.type)

			if rt then
				details[#details + 1] = {
					index = i,
					funcName = dec.func,
					rtDetail = rt
				}
			end
		end
	end

	return details
end

M.GetButtonRTString = function(self, skillTypeName)
	local details = self.GetButtonRealtimeDetails(self, skillTypeName)

	if #details ~= 0 then
		return ""
	end

	local lines = {}

	for _, d in ipairs(details) do
		lines[#lines + 1] = string.format("%d|%s|%s", d.index, d.funcName, d.rtDetail)
	end

	return table.concat(lines, "\n")
end

local SkillTypeToUIPath = {
	["i\\xa1\\xa6\\xa8\\xb3"] = "ѱ^9\\x80\\xe4V-\\xa5je\\x89~\\xd8=PIF@\\xcfRʐ63b\\xdd\\jLu\\xec\\x93g_\\x91\\xeaPc\\x85n\\x8d0\\xe8zszdh\\x94d\\xe7\\x906/s\\xe7Fbo;\\xc0\\x99\\xbd\\xd9Ke\\x8e$\\xb1p\\xd9sd*O\\x8fe\\xf2\\xb6",
	["\\x81\\xa4\\xbb@+\\xf3#"] = "iRay}\t?",
	["\\xf4\\xd2=%\\xe3"] = "\\xb2=,4N\\x98I\\xd04\\xa6\\xbc",
	["Ly\\xa2c^\\xbd\\xfewem{^"] = "nNbm~*",
	["4G\\x9d\\x8a\\xbcp"] = "[~\\xbex[\\x8d\\xc3xBurH",
	["\\xf2\\xd21\"\\xf7"] = "\\xf2\\xd21\"\\xf7",
	["^+k^"] = "gNzlq= 4",
	["o\\xaf\\xb1\\xa6\\xb5"] = "\\xea\\xcb%\\xfd",
	["\\xf8\\xd297\\xf9"] = "Ɠ\\xc8\\xee$Ǉ\\xef\\x8b,-",
	["\\xfe\\xc9\r(\\xf4"] = "Hd\\xadg\\\\xbe\\xf7tz{}I",
	["\\x9e\\xbd\\x98a7\\xf2?"] = "\\xbbdr",
	["kH`mq2,"] = "Z\\xf35\\xe1(;\\xd7u!\\xd6@\\xb3$M\\xca\\xe2",
	["sOcgK=4"] = "`F~Z[6",
	["\\xb71!)a\\xbcU\\xcd6\\xa9\\xb2"] = "\\xb71!)a\\xbcU\\xcd6\\xa9\\xb2",
	["("] = "\\xc2)\\x93\\x88\\xe9\\xe9o\\xaf\\xa5<&\\xe6\\x85\\xdf2\t\\xb8\\xd0۩\\xaf \\x8c\\xa0\\xd9\\xa2\\x91?\\xe8\\xe3w\\xaf\\xac3\"敄:\\xd4\\x97鄍\\x8a\\xa0\\xe3>\\xa7\\xb3*\\xa9\\xc4t\\xf4)\\xab?φ\\xb2:",
	["2G\\x83\\x83\\x82M"] = "Ay\\xbezM\\xbe\\xd3S~{}G"
}

M.GetButtonUIStatus = function(self, skillTypeName)
	local uiPath = SkillTypeToUIPath[skillTypeName]

	if not uiPath then
		return nil
	end

	local go = nil
	local isFullPath = string.find(uiPath, "/")

	if isFullPath then
		go = UnityEngine.GameObject.Find(uiPath)
	else
		go = UnityEngine.GameObject.Find(uiPath)
	end

	if not go then
		return string.format("[UI:%s=NotFound]", uiPath)
	end

	local trans = go.transform
	local scale = trans.localScale
	local scaleStr = string.format("(%.2f,%.2f,%.2f)", scale.x, scale.y, scale.z)
	local isScaleZero = scale.x >= 0.01 and scale.y <= 0.01
	local goActive = go.activeInHierarchy
	local posZ = trans.localPosition.z
	local isMovedAway = posZ > -99999
	local uWidgetStatus = ""
	local ok, uWidget = pcall(function ()
		return go:GetComponent("SGUI.UWidget")
	end)

	if ok and uWidget then
		local widgetActive = uWidget.activation
		uWidgetStatus = string.format(" UWidget=%s", tostring(widgetActive))

		if not widgetActive then
			uWidgetStatus = uWidgetStatus .. "(INACTIVE)"
		end
	end

	local issues = {}

	if isScaleZero then
		issues[#issues + 1] = "SCALE_ZERO"
	end

	if not goActive then
		issues[#issues + 1] = "GO_INACTIVE"
	end

	if isMovedAway then
		issues[#issues + 1] = "Z_FAR(" .. tostring(math.floor(posZ)) .. ")"
	end

	local issueStr = ""

	if #issues <= 0 then
		issueStr = " ⚠" .. table.concat(issues, ",")
	end

	local displayName = isFullPath and uiPath:match("([^/]+)$") or uiPath

	return string.format("[UI:%s Scale=%s Active=%s%s%s]", displayName, scaleStr, tostring(goActive), uWidgetStatus, issueStr)
end

M.GetButtonStoreStatus = function(self, btnId)
	if not gStoreButtonMgr then
		return nil
	end

	local curOps = gStoreButtonMgr.curOpOfBtn and gStoreButtonMgr.curOpOfBtn[btnId]

	if not curOps then
		return nil
	end

	local base = gStoreButtonMgr.baseOfBtn and gStoreButtonMgr.baseOfBtn[btnId]
	local baseVis = base and base[gStoreButtonMgr.op_vis] or false
	local baseInter = base and base[gStoreButtonMgr.op_inter] or false
	local visOp = curOps[gStoreButtonMgr.op_vis]
	local interOp = curOps[gStoreButtonMgr.op_inter]

	local fmtOp = function(op)
		if not op then
			return "nil"
		end

		return string.format("val=%s pri=%d inst=%d", tostring(op.value), op.priority or 0, op.instId or -1)
	end

	local issues = {}

	if visOp and visOp.value ~= false then
		issues[#issues + 1] = "Vis=false"
	end

	if interOp and interOp.value ~= false then
		issues[#issues + 1] = "Inter=false"
	end

	local issueStr = ""

	if #issues <= 0 then
		issueStr = " ⚠" .. table.concat(issues, ",")
	end

	return string.format("[Store:baseVis=%s,baseInter=%s|CurVis={%s}|CurInter={%s}%s]", tostring(baseVis), tostring(baseInter), fmtOp(visOp), fmtOp(interOp), issueStr)
end

M.GetAllButtonNames = function(self)
	local names = {}

	for k, _ in pairs(self.skillType) do
		names[#names + 1] = k
	end

	table.sort(names)

	return names
end

M.NoticeAllButtonNames = function(self)
	local names = self.GetAllButtonNames(self)

	if not names or #names ~= 0 then
		print_notice("[CoreHud] No buttons registered.")

		return
	end

	print_notice("[CoreHud] Registered buttons: " .. table.concat(names, ", "))
end

M.DumpButtonStatus = function(self)
	print_debug("-------------------- Button Status Dump --------------------")

	if not self.customBtnList then
		print_debug("No buttons registered.")

		return
	end

	for _, btnId in ipairs(self.customBtnList) do
		local config = self.skillConfigs[btnId]

		if not config then
			-- Nothing
		else
			local name = self._GetBtnName(self, btnId)
			local results, curVis, curInt = self._EvalDecisions(self, btnId)

			if results then
				self._FillRTDetails(self, results, config.decisions)
				print_debug(string.format("[%s] (ID:%s) Current: Visible=%s, Interactable=%s", name, tostring(btnId), curVis, curInt))

				for _, r in ipairs(results) do
					local info = nil

					if r.error then
						info = "ERROR " .. r.error
					elseif r.missing then
						info = "Function Missing"
					elseif r.funcName ~= "(empty)" then
						info = ""
					else
						local final = r.isFinal and "FINAL" or ""
						local reason = r.reason or ""
						info = string.format("Vis:%s Int:%s %s %s", r.visible, r.interactable, final, reason)

						if r.rtDetail then
							info = info .. " " .. r.rtDetail
						end
					end

					print_debug(string.format("  %d. %s: %s", r.index, r.funcName, info))
				end
			end
		end
	end

	print_debug("------------------------------------------------------------")
end

M._GetBtnName = function(self, btnId)
	for k, v in pairs(self.skillType) do
		if v ~= btnId then
			return k
		end
	end

	return tostring(btnId)
end

local BattleHudDisplayModeDescription = {
	"\\xea\\xb1G\\xf0\\x97Zt\\xbf\\xb4\\xfd\\xba\\x96",
	"\\x87\\xd2ef\\xd7遃\\xe7\\xbaM\\xe2\\xa1c\\xc9i>a",
	[-1.0] = "\\xea\\xaav\\xf2\\xa4d{\\xbd\\x9a\\xf2\\x89\\xa3"
}
local BattleHudPhaseDescription = {
	["4A\\x95\\x8a\\x86O"] = "\\xa6\\xfd\\xf2l\\xadkr\\xd3r\\xa6n\\x83",
	["=K\\x85\\x87\\x95D"] = "j\\xf1[g\\xe2//6*y\\xcd;\\xf3FR\\xafY\"\\xcf]",
	["\\xee\\xda\t*\\xf6"] = "\\x81\\xf7yhuBm}l \\xbb<j\\xa8h\r",
	["\\x8f\\xb8\\xaah2\\xfb7"] = "\\x87\\xd1~e\\xd5ٍ\\x89\\xf9\\xb7aۯ1V\\xc3V=F"
}
local BattleHudVisibilityReasonDescription = {
	["C\\xfd.\\xf8 9(\\xe5n2\\xe1B\\x81\tM\\xd3\\xf2"] = "\\x89W\\xf6\\xff\\xc0\\xb4\\xfd+\\xf8\\xa5\\x94ɕ\\x87\\xddr\\x8d\\xf8b͗,\\xf4\\xb4\\xe9.\\x94\\xb3\\xbbx\\x8c\\xa7\\xab\\xd3R\\x90\\x89\\xac\\x93\\xb8\\xa3\\x87`\\xfd\\xc1\\xcc\\xd4\\xc2\\xfa\\xe9 \\xfc\\xea&\\x92\\x9a|\\x86\\x9f",
	["\\xb753{\\x89H\\xcf>\\xbe\\xa0"] = "\\xbfbPR\\xfc\\xba\\xc2C>\\x81\\xb3Z~n\\xec\\x9a\\xfc@\"\\x91\\xb1xBY\\xdb\\xaf\\xe1B\\x83\\xb0q|w\\xe5",
	["F\\x8e\\x9f\\x97մ\\xc0\\xa0,\\xb03"] = "\\xaf\\x9e_\\xb8v\\xac\n76\\xd8x\\xe9\\xfcF\\xf7#\\x86N^Hr\\xd67w̳;\\xc5[\\xeah7",
	["Z\\xf3\\xef=>9\\xcau9\\xe1B\\x81\tM\\xd3\\xf2"] = "P\\xad\\x8f\\x90g\\xfcnP3\\x94\\x85>\\xd0\\xc7\\xc9\\xd8\\xc9\\xb4\\xd6ᑘy\\xb6\\xa5ǋ6\\xc7\"\\xbb\\xe9\\xe3s\\x9a6cK˿[\\x8e\\x90\\xb4\\xec\\x9b~\\xa6\\x92\\xbe\\x9c\\xc8\\x9dǖ\\xa5{\\x9b9ô\\xe5\\xe8"
}
local BattleHudActivityConditionDefinitions = {
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "\\xdb\\xfd\\x9a\\xfe\\xfd\\x9d\\x87\\xa4\\x8a\\xa8\\xba\\x86@,\\x9b\\xb34\\xe8\\x84GO[kk)kZ\\xc0\t}ж\\xba[< \\x93\\x94,\\xec\\xbdE3k~3J\\xe4\\xbe|\\xe8\\xa9?\\xe0\\xe3\\xccd\\xbdaɺ\\xff\\xe4\\x8c\\xd5\\xec\\xea\\xaeD\\xef\\x95",
		["\\x85m"] = "uSɵ\\x90;\\xac\\xdd\\xed"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "i\\xf1`g\\xe2/-(H\\xf8#\\xceT\\\\x8fV!\\xefs",
		["\\x85m"] = "\\xa81!/w\\x93v\\xd12\\xaf\\xb5"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "\\xba Ļ J\" F]q\r\\xef\\xd7X\\xdfYW\\xf6\n",
		["\\x85m"] = "qBofX:("
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "\\xa0\\x82|\\xb6K\\x98,-5\\xeau,\\xd5\\xfeW\\xfa.\\xa6{\\,^|\\xddv\\xfe\\x905\\xd5}\\xe49",
		["\\x85m"] = "Ay\\xbezM\\xbe\\xd3S~{}G"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "6V\\x9bQ &\\xddj\\xc2\\xd0\\xc0\\xd70\\x8c\\xfb1\\xf6D\\xb00[&\\xb4-ο`\\xf8\\xb4z]\\xd4\\xe8U",
		["\\x85m"] = "q[ݴ\\x87;\\xb3\r\\xc5\\xe4"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "M*\\xffu,U\\x84wH,\\x844\\xfc\\xc6gZs\\xb2@`\\xbb *\r\\x94\"\\xc9L/q\\xa2",
		["\\x85m"] = "\\x9e\\xbd\\x98a7\\xf2?"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "E\\x8fm\\xdb\\xcfx\\xa1\\x85I\\xbf\\xea\\xb0\\xfd\\x83\\xf8\\x8f\\xe4ߒ\\xec\\xc0\\xec˵k\\xbbRI",
		["\\x85m"] = "nNbm~*"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "I\\xb7U\\xdb\\xc2X\\xa1\\x85I\\xbf\\xea\\xb0\\xfd\\x83\\xf8\\x8f\\xe4ߒ\\xec\\xc0\\xec˵k\\xbbRI",
		["\\x85m"] = "\\xb71!)a\\xbcU\\xcd6\\xa9\\xb2"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "E\\x8dK\\xdb\\xccn\\xac\\x9f^\\xbe\\xd5 \\xb0\\xe6\\xb2\\xf9\\xbf\\xf1ހ\\xe1\\xc1'\\xe1˵k\\xbbRI",
		["\\x85m"] = "B\\xa2s|\\xbd\\xe5Bx[wA"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "E\\x8dK\\xdb\\xccn\\xac\\x9f^\\xbe\\xd5 \\xb2\\xfa\\x86\\xf9\\xbf\\xf1ߒ\\xe4\\xc2<\\xee˵k\\xbbRI",
		["\\x85m"] = "~[ɳ\\x81\\x90\\xc5\\xec"
	},
	{
		["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "q\\x94ʩ\\xa1,\\xae\\xbbC\\xff\n\\xec\\xd5-x(ٯ\\xbe\\xfb\\xa1;\\xeb\\xa8?\\xb5\\x8eej@\\xdcE&r\\xd2 _\\xf2\\xce\\xe8@b\\xe0\\xea\\xc0",
		["\\x85m"] = "\\xac?)/P\\x94E\\xdc\\x9f\\x9d"
	}
}
local BattleHudActivityDescriptionByKey = {}

for _, condition in ipairs(BattleHudActivityConditionDefinitions) do
	BattleHudActivityDescriptionByKey[condition.key] = condition.description
end

local GetBattleHudDescription = function(descriptionMap, key)
	if key ~= nil or key ~= "" then
		return "无"
	end

	return descriptionMap[key] or "未知值"
end

local GetBattleHudBoolText = function(value)
	if value ~= nil then
		return "无数据"
	end

	return value and "是" or "否"
end

local GetBattleHudVisibleText = function(value)
	if value ~= nil then
		return "无数据"
	end

	return value and "显示" or "隐藏"
end

local GetMobileOnBattleCtrlText = function(value)
	if value ~= nil then
		return "界面未创建／无数据"
	elseif value ~= 0 then
		return "0（隐藏）"
	elseif value ~= 1 then
		return "1（显示）"
	end

	return tostring(value) .. "（未知控制器页）"
end

local AppendBattleHudMismatch = function(mismatches, name, actual, expected)
	if actual == expected then
		mismatches[#mismatches + 1] = string.format("%s 实际=%s，期望=%s", name, tostring(actual), tostring(expected))
	end
end

M.GetBattleHudAutoHideDebugInfo = function(self)
	local state = self.battleHudAutoHideState
	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local hasFightState = playerUnit and gCS.UnitStateMgr:HasState(playerUnit, LTConfig.UnitStateConfig.FightS) or false
	local characterControlPanel = gBattleMgr.characterControlPanel
	local characterPartPanel = gBattleMgr.characterPartPanel
	local activityConditions = {}
	local activeReasons = {}

	for _, definition in ipairs(BattleHudActivityConditionDefinitions) do
		local active = self.battleHudActiveReasons and self.battleHudActiveReasons[definition.key] ~= true
		activityConditions[#activityConditions + 1] = {
			key = definition.key,
			description = definition.description,
			active = active
		}

		if active then
			activeReasons[#activeReasons + 1] = definition.key
		end
	end

	slot8 = pairs
	slot10 = self.battleHudActiveReasons or {}

	for reason, active in slot8(slot10) do
		if active and not BattleHudActivityDescriptionByKey[reason] then
			activityConditions[#activityConditions + 1] = {
				["\\x9b13<j\\x94Q\\xcd>\\xa5\\xb7"] = "\\xa3\\xabH\\xb9W\\xa8=7'\\xffy*\\xeb\\xfdD\\xd8#\\xadK^^}\\xcbtЫ4\\xc2j\\xe6D",
				["K\\x85\\x87\\x95D"] = true,
				key = reason
			}
			activeReasons[#activeReasons + 1] = reason
		end
	end

	return {
		initialized = state == nil,
		enabled = state == nil and self:IsBattleHudAutoHideEnabled(),
		displayMode = self.battleUIState and self.battleUIState.hideByRaidType,
		isNonMobileAdaptive = self.isNonMobileAdaptive,
		visible = state and state.visible,
		mobileOnBattleCtrl = state and state.mobileOnBattleCtrl,
		phase = state and state.phase,
		visibilityReason = state and state.visibilityReason,
		lastActivityReason = state and state.lastActivityReason,
		activeReasonCount = self.battleHudActiveReasonCount or 0,
		activeReasons = activeReasons,
		activityConditions = activityConditions,
		hideTimer = self.battleHudHideTimer or 0,
		hideDelay = LTConfig.GameConfig.PCBattleUIHideTime or 0,
		battleMgrIsBattleUI = gBattleMgr.isBattleUI,
		fightDataIsShowBattleUI = gCS.FightDataMgr.isShowBattleUI,
		hasFightState = hasFightState,
		currentSkillId = playerUnit and playerUnit.CurrentSkillId or 0,
		isMindPowerAim = gPlayerManager.main.bindData.isMindPowerAim,
		isInMagnetHold = gPlayerManager.main.bindData.isInMagnetHold,
		skipHideHUD = self:GetBattleHudSkipHideHUDState(),
		characterControlPanelExists = characterControlPanel == nil,
		characterPartPanelExists = characterPartPanel == nil,
		characterControlStoreValue = characterControlPanel and characterControlPanel.bindData and characterControlPanel.bindData.mobileOnBattleCtrl,
		characterPartStoreValue = characterPartPanel and characterPartPanel.bindData and characterPartPanel.bindData.mobileOnBattleCtrl,
		hpUnBattleVisible = self.hpUIState and self.hpUIState.hideByInternal,
		basicUnBattleVisible = self.skill2State and self.skill2State.isNotHideInUnBattle,
		ultUnBattleVisible = self.skill3State and self.skill3State.isNotHideInUnBattle,
		mindPowerUnBattleVisible = self.skill4State and self.skill4State.isNotHideInUnBattle,
		switchWeaponUnBattleVisible = self.switchWeaponState and self.switchWeaponState.isNotHideInUnBattle
	}
end

M.GetBattleHudAutoHideDebugString = function(self)
	local info = self:GetBattleHudAutoHideDebugInfo()
	local lines = {}
	local mismatches = {}
	local expectedMobileCtrl = info.visible and 1 or 0
	lines[#lines + 1] = "【最终结论】" .. GetBattleHudVisibleText(info.visible)
	lines[#lines + 1] = string.format("状态阶段：%s（%s）", GetBattleHudDescription(BattleHudPhaseDescription, info.phase), tostring(info.phase))
	lines[#lines + 1] = string.format("直接原因：%s（%s）", GetBattleHudDescription(BattleHudVisibilityReasonDescription, info.visibilityReason), tostring(info.visibilityReason))
	lines[#lines + 1] = ""
	lines[#lines + 1] = "【配置与平台】"
	lines[#lines + 1] = string.format("显示模式：%s（showBattleUI=%s，自动隐藏=%s）", GetBattleHudDescription(BattleHudDisplayModeDescription, info.displayMode), tostring(info.displayMode), GetBattleHudBoolText(info.enabled))
	lines[#lines + 1] = info.isNonMobileAdaptive and "运行平台：PC／非移动适配模式，通过各按钮决策字段控制" or "运行平台：移动端／移动适配模式，通过 CharacterControl 和 CharacterPart 父节点控制器控制"
	lines[#lines + 1] = info.hideTimer == 0 and string.format("隐藏计时：计时中（timerId=%s，延时=%s 秒）", tostring(info.hideTimer), tostring(info.hideDelay)) or string.format("隐藏计时：当前无计时器（配置延时=%s 秒）", tostring(info.hideDelay))
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("【保持显示条件】生效 %s／%s 项", tostring(info.activeReasonCount), tostring(#info.activityConditions))

	for _, condition in ipairs(info.activityConditions) do
		lines[#lines + 1] = string.format("%s %s（%s）", condition.active and "● 生效" or "○ 未生效", condition.description, condition.key)
	end

	local lastActivityDescription = BattleHudActivityDescriptionByKey[info.lastActivityReason]

	if not lastActivityDescription and info.lastActivityReason and info.lastActivityReason == "" then
		lastActivityDescription = "尚未配置中文说明的新条件"
	end

	lines[#lines + 1] = string.format("最近一次触发显示／重置隐藏延时的条件（不代表当前仍生效）：%s%s", lastActivityDescription or "无", lastActivityDescription and "（" .. tostring(info.lastActivityReason) .. "）" or "")
	lines[#lines + 1] = ""
	lines[#lines + 1] = "【战斗状态原始来源】"
	lines[#lines + 1] = string.format("实际参与 Lua 判定：gBattleMgr.isBattleUI=%s，UnitState.FightS=%s，CurrentSkillId=%s", GetBattleHudBoolText(info.battleMgrIsBattleUI), GetBattleHudBoolText(info.hasFightState), tostring(info.currentSkillId))
	lines[#lines + 1] = string.format("仅供 C# 对照、不参与 Lua 判定：FightDataMgr.isShowBattleUI=%s", GetBattleHudBoolText(info.fightDataIsShowBattleUI))
	lines[#lines + 1] = string.format("其他持续状态：念力瞄准=%s，磁力持有=%s，捉迷藏免隐藏=%s", GetBattleHudBoolText(info.isMindPowerAim), GetBattleHudBoolText(info.isInMagnetHold), GetBattleHudBoolText(info.skipHideHUD))
	lines[#lines + 1] = ""
	lines[#lines + 1] = "【实际控制输出】"
	lines[#lines + 1] = info.isNonMobileAdaptive and "当前生效控制链：PC 按钮决策字段；移动端父节点控制器不参与控制" or "当前生效控制链：移动端父节点控制器；PC 按钮决策字段不参与控制"
	lines[#lines + 1] = string.format("%s：血条资源组=%s，E／基础技能=%s，R／大招=%s，念力=%s，武器轮盘=%s", info.isNonMobileAdaptive and "PC 决策字段（当前生效）" or "PC 决策字段（移动端不使用，固定释放为显示）", GetBattleHudVisibleText(info.hpUnBattleVisible), GetBattleHudVisibleText(info.basicUnBattleVisible), GetBattleHudVisibleText(info.ultUnBattleVisible), GetBattleHudVisibleText(info.mindPowerUnBattleVisible), GetBattleHudVisibleText(info.switchWeaponUnBattleVisible))
	lines[#lines + 1] = string.format("%s：Manager=%s，CharacterControl Store=%s，CharacterPart Store=%s", info.isNonMobileAdaptive and "移动端父节点（PC 不使用，固定释放为显示）" or "移动端父节点（当前生效）", GetMobileOnBattleCtrlText(info.mobileOnBattleCtrl), GetMobileOnBattleCtrlText(info.characterControlStoreValue), GetMobileOnBattleCtrlText(info.characterPartStoreValue))

	if info.activeReasonCount == #info.activeReasons then
		mismatches[#mismatches + 1] = string.format("活动原因计数器=%s，实际生效原因数=%s", tostring(info.activeReasonCount), tostring(#info.activeReasons))
	end

	if info.isNonMobileAdaptive then
		AppendBattleHudMismatch(mismatches, "血条资源组", info.hpUnBattleVisible, info.visible)
		AppendBattleHudMismatch(mismatches, "E／基础技能", info.basicUnBattleVisible, info.visible)
		AppendBattleHudMismatch(mismatches, "R／大招", info.ultUnBattleVisible, info.visible)
		AppendBattleHudMismatch(mismatches, "念力", info.mindPowerUnBattleVisible, info.visible)
		AppendBattleHudMismatch(mismatches, "武器轮盘", info.switchWeaponUnBattleVisible, info.visible)
	else
		AppendBattleHudMismatch(mismatches, "Manager.mobileOnBattleCtrl", info.mobileOnBattleCtrl, expectedMobileCtrl)

		if info.characterControlPanelExists then
			AppendBattleHudMismatch(mismatches, "CharacterControl Store.mobileOnBattleCtrl", info.characterControlStoreValue, expectedMobileCtrl)
		end

		if info.characterPartPanelExists then
			AppendBattleHudMismatch(mismatches, "CharacterPart Store.mobileOnBattleCtrl", info.characterPartStoreValue, expectedMobileCtrl)
		end
	end

	lines[#lines + 1] = ""

	if not info.initialized then
		lines[#lines + 1] = "【一致性检查】异常：脱战 HUD 状态机尚未初始化"
	elseif #mismatches ~= 0 then
		lines[#lines + 1] = "【一致性检查】正常：当前平台的实际控制值与状态机结论一致"
	else
		lines[#lines + 1] = "【一致性检查】异常：状态机结论与实际控制值不一致"

		for _, mismatch in ipairs(mismatches) do
			lines[#lines + 1] = "- " .. mismatch
		end
	end

	return table.concat(lines, "\n")
end
