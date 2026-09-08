-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\HudMgr.lua
-- Decompiled from: 02283_HudMgr.lua_ff0a80177118.luajit

local HUDManager = LX6.GUI.HUDNew.HUDManager
local HudPool = {}
local HudTagCache = {}
local CreateParamsStack = {}

local PushDataToStack = function(data)
	table.insert(CreateParamsStack, data)
end

local PopDataFromStack = function()
	return table.remove(CreateParamsStack)
end

local GetTagString = function(tag)
	return ulong.check(tag) and ulong.tostring(tag) or tostring(tag)
end

local M = {
	needUpdateCount = 0,
	OnInit = function (self)
		self.ctrlDic = {}
		self.npcHuds = {}
		self.updateQueue = {}
		self.cacheClearInterval = 0
		self.globalHeadInfoDisallowReasons = {}
		slot1 = gMessageManager

		slot1:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, function (eventId, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			self:OnBeforeSwitchScene(switchType)
		end)
	end
}

M.GetCtrlFromPool = function(self, hudTargetType)
	if next(HudPool) and HudPool[hudTargetType] and next(HudPool[hudTargetType]) then
		return table.remove(HudPool[hudTargetType])
	else
		if not HudPool[hudTargetType] then
			HudPool[hudTargetType] = {}
		end

		return M.HUDTargetType2Ctrl[hudTargetType].New()
	end
end

M.RegisterHudCtrl = function(self, uniIdentifier, hudTargetType, param, hudUIRoot)
	local ctrl = self.GetCtrlFromPool(self, hudTargetType)
	local pid, unit = nil

	if not param then
		print_error("未传入引用！", uniIdentifier)

		return
	end

	if ulong.check(param) then
		pid = param
		unit = gCS.SceneDataMgr.GetUnit(pid)
	elseif param ~= 0 then
		pid = 0
	else
		unit = param
		pid = unit.Pid
	end

	if self.ctrlDic[uniIdentifier] then
		print_error("multiple registration! uniIdentifier: ", uniIdentifier)

		return
	end

	self.ctrlDic[uniIdentifier] = ctrl
	local data = nil

	if #CreateParamsStack <= 0 then
		data = PopDataFromStack()
	end

	ctrl.Init(ctrl, uniIdentifier, hudUIRoot, unit, data)

	ctrl.__isActiveSelf__ = true

	if ctrl.Update and type(ctrl.Update) ~= "function" then
		if ctrl.IsNpcHud(ctrl) then
			ctrl.npcPid = pid

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				ctrl.Update(ctrl)

				self.npcHuds[pid] = ctrl
			end
		else
			table.insert(self.updateQueue, ctrl)

			ctrl.updateIndex = table.count(self.updateQueue)
			M.needUpdateCount = M.needUpdateCount + 1
		end
	end
end

M.AddHudTemplate = function(self, uniIdentifier, InstanceId, templateType, templateTag)
	if not self.ctrlDic[uniIdentifier] then
		print_error("no exist HudUIRoot:", uniIdentifier, templateType)

		return
	end

	self.ctrlDic[uniIdentifier]:AddHudTemplate(InstanceId, templateType, templateTag)
end

M.GetHudCtrl = function(self, unit)
	local pid = ulong.tostring(unit.Pid)

	if not self.ctrlDic[pid] then
		return
	end

	return self.ctrlDic[pid]
end

M.GetHudCtrlByPid = function(self, Pid)
	local pid = ulong.tostring(Pid)

	if not self.ctrlDic[pid] then
		return
	end

	return self.ctrlDic[pid]
end

M.GetHudCtrlNoUnit = function(self, rootType, tag)
	local tTag = self.GenNoUnitRootTag(self, rootType, tag)

	if not self.ctrlDic[tTag] then
		return
	end

	return self.ctrlDic[tTag]
end

M.DestroyHudCtrl = function(self, uniIdentifier)
	if not self.ctrlDic[uniIdentifier] then
		return
	end

	local hudTargetType = self.ctrlDic[uniIdentifier]:GetHudTargetType()

	if HudTagCache[uniIdentifier] then
		HudTagCache[hudTargetType][HudTagCache[uniIdentifier]] = nil
		HudTagCache[uniIdentifier] = nil
	end

	local ctrl = self.ctrlDic[uniIdentifier]

	if ctrl.Update and type(ctrl.Update) ~= "function" then
		if ctrl.IsNpcHud(ctrl) then
			if ctrl.npcPid then
				self.npcHuds[ctrl.npcPid] = nil
			end
		else
			if ctrl.updateIndex ~= nil then
				print_error("看到这个报错说明被前面的报错阻塞了，请把紧跟在前的报错发给@wuzhijing01")
			end

			table.remove(self.updateQueue, ctrl.updateIndex)

			for i = ctrl.updateIndex, #self.updateQueue do
				if self.updateQueue[i] ~= nil then
					print_error("看到这个报错说明被前面的报错阻塞了，请把紧跟在前的报错发给@wuzhijing01")
				end

				self.updateQueue[i].updateIndex = self.updateQueue[i].updateIndex - 1
			end

			ctrl.updateIndex = nil
			M.needUpdateCount = M.needUpdateCount - 1
		end
	end

	ctrl.__isActiveSelf__ = false

	self.ctrlDic[uniIdentifier]:Clear()

	if not HudPool[hudTargetType] then
		self.ctrlDic[uniIdentifier] = nil

		return
	end

	table.insert(HudPool[hudTargetType], self.ctrlDic[uniIdentifier])

	self.ctrlDic[uniIdentifier] = nil
end

M.CreateMySpiritHUD = function(self)
	HUDManager.GenMyHUDUIRoot()
end

M.CreateDestruct = function(self, destructId)
end

M.CreateSlotEntity = function(self, entityId, data)
	local tran = data.go.transform
	local tag = GetTagString(entityId)

	if tran then
		PushDataToStack(data)
		HUDManager.GenHUDUIRootNoUnit(M.HUDTargetType.SlotEntity, tran, tag)

		gGadgetManager.headTitleList[entityId] = entityId
	end
end

M.CreateVehicle = function(self, vehicle_uid)
	local vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(vehicle_uid)
	local tag = GetTagString(vehicle_uid)

	if vehicle and vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) and vehicle.gameObject.transform then
		HUDManager.GenHUDUIRootNoUnit(M.HUDTargetType.Vehicle, vehicle.gameObject.transform, tag)
	end
end

M.DestroyDestructTarget = function(self, destructId)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl.GetUIRoot(hudCtrl))
end

M.DestroySlotEntityTarget = function(self, entityId)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.SlotEntity, entityId)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl.GetUIRoot(hudCtrl))

	gGadgetManager.headTitleList[entityId] = nil
end

M.DestroyVehicleTarget = function(self, vehicle_uid)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl.GetUIRoot(hudCtrl))
end

M.HpChanged = function(self, pid)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "HpChanged")
end

M.RefreshHpVisible = function(self, pid)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "RefreshHpVisible")
end

M.VehicleAddHp = function(self, vehicle_uid)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		local tTag = self.GenNoUnitRootTag(self, M.HUDTargetType.Vehicle, vehicle_uid)

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.VehicleHpBar, tTag)
	end
end

M.VehicleHpChanged = function(self, vehicle_uid, hp)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self.TryDoHudAction(self, hudCtrl, "HpChanged", hp)
	end
end

M.VehicleDead = function(self, vehicle_uid)
	if vehicle_uid ~= nil then
		print_error("vehicle_uid 为 nil")

		return
	end

	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self.TryDoHudAction(self, hudCtrl, "Dead")
	end
end

M.ShowHpBar = function(self, pid, show)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	if not unit.IsDead then
		local hudCtrl = self.GetHudCtrl(self, unit)

		self.TryDoHudAction(self, hudCtrl, "ShowHpBar", show)
	end
end

M.DisarmChanged = function(self, pid)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "DisarmChanged")
	self.TryDoHudAction(self, hudCtrl, "OnRefreshPoiseNum")
end

M.ShowPartShieldBar = function(self, pid, index, show)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "ShowPartShieldBar", index, show)
end

M.PartShieldChanged = function(self, pid, index)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)
	local shieldConfigId = gCS.ShieldManager:GetShieldConfigId(unit.ClientData.SubType, index)
	local shieldConfig = LTConfig.ShieldConfig.GetConfig(shieldConfigId)

	if shieldConfig.Kind ~= 4 then
		self.TryDoHudAction(self, hudCtrl, "FrequencyShieldChanged", index)

		return
	end

	if shieldConfig.Kind ~= 1 or shieldConfig.Kind ~= 3 then
		self.TryDoHudAction(self, hudCtrl, "WholeBodyShieldChanged")

		return
	end

	self.TryDoHudAction(self, hudCtrl, "PartShieldChanged", index)
end

M.RefreshMissileAttackMarker = function(self, pid, uuid, show)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "RefreshMissileAttackMarker", uuid, show)
end

M.PlayLockStateAni = function(self, pid, uuid, show, time)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	if not hudCtrl then
		return
	end

	time = time or 9999

	self:TryDoHudAction(hudCtrl, "PlayLockStateAni", uuid, show, time)
end

M.PlayAttackStateAni = function(self, pid, uuid, show, time)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	if not hudCtrl then
		return
	end

	time = time or 9999

	self:TryDoHudAction(hudCtrl, "PlayAttackStateAni", uuid, show, time)
end

M.AddBuffHeadIcon = function(self, pid, buffId)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "AddBuffHeadIcon", buffId)
end

M.RemoveBuffHeadIcon = function(self, pid, buffId)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "RemoveBuffHeadIcon", buffId)
end

M.EnableAIChatHud = function(self, pid, enable)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "EnableAIChatHud", enable)
end

M.SetHeadInfoVisibility = function(self, pid, show)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "SetHeadInfoVisibility", show)
end

M.SetDestructibleHpProgress = function(self, destructId, hpProgress)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self.CreateDestruct(self, destructId)

		hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)
	end

	self.TryDoHudAction(self, hudCtrl, "HpProgressChange", hpProgress)
end

M.SetDestructibleDebugInfo = function(self, destructId, hp, maxHp, damageText)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self.CreateDestruct(self, destructId)

		hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)
	end

	self.TryDoHudAction(self, hudCtrl, "HpProgressChangeDebug", hp, maxHp, damageText)
end

M.SetDestructibleCommonDebugInfo = function(self, destructId, info)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self.CreateDestruct(self, destructId)

		hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)
	end

	self.TryDoHudAction(self, hudCtrl, "OnShowDestructCommonDebug", info)
end

M.SetDestructibleCommonDebugInfoVisible = function(self, destructId, visible)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self.CreateDestruct(self, destructId)

		hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)
	end

	self.TryDoHudAction(self, hudCtrl, "SetDestructibleCommonDebugVisible", visible)
end

M.SetDestructibleDebugVisible = function(self, destructId, visible)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self.CreateDestruct(self, destructId)

		hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)
	end

	self.TryDoHudAction(self, hudCtrl, "SetDestructibleDebugVisible", visible)
end

M.SetDestructTopText = function(self, destructId, text)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		return
	end

	self.TryDoHudAction(self, hudCtrl, "SetPaperPlaneText", text)
end

M.RemoveDestructTopText = function(self, destructId)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		return
	end

	self.TryDoHudAction(self, hudCtrl, "RemovePaperPlaneText")
end

M.DestroyHpBar = function(self, pid)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "DestroyHpBar")
end

M.SetNpcNameAllow = function(self, pid, allow)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetNpcNameAllow", allow)
end

M.SetNpcTitleAllow = function(self, pid, allow)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetNpcTitleAllow", allow)
end

M.SetNpcIconAllow = function(self, pid, allow, reason)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetNpcIconAllow", allow, reason)
end

M.DumpNpcIconAllowState = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		print(string.format("[HudMgr] DumpNpcIconAllowState: unit not found, pid=%s", tostring(pid)))

		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "DumpIconAllowState")
end

M.AddNpcIcon = function(self, pid, iconId, scale)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "AddNpcIcon", iconId, scale)
end

M.RemoveNpcIcon = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveNpcIcon")
end

M.PlayEnergyShortageAnim = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "PlayEnergyShortageAnim")
end

M.SetAIChatVisibility = function(self, pid, visible)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetAIChatVisibility", visible)
end

M.SetForceHideHp = function(self, pid, force)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetForceHideHp", force)
end

M.RemoveLevitationBar = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveLevitationBar")
end

M.AddCommonHeadIcon = function(self, pid, iconId)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false, "unit_not_found"
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	if not hudCtrl then
		HUDManager.GenHUDUIRoot(self.HUDTargetType.Npc, pid)

		hudCtrl = self.GetHudCtrl(self, unit)

		if not hudCtrl then
			return false, "hud_root_requested"
		end
	end

	return self.TryDoHudAction(self, hudCtrl, "AddCommonHeadIcon", iconId)
end

M.RemoveCommonHeadIcon = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveCommonHeadIcon")
end

M.AddTopAnimHeadIcon = function(self, pid, iconType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false, "unit_not_found"
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	if not hudCtrl then
		HUDManager.GenHUDUIRoot(self.HUDTargetType.Npc, pid)

		hudCtrl = self.GetHudCtrl(self, unit)

		if not hudCtrl then
			return false, "hud_root_requested"
		end
	end

	return self.TryDoHudAction(self, hudCtrl, "AddTopAnimHeadIcon", iconType)
end

M.RemoveTopAnimHeadIcon = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveTopAnimHeadIcon")
end

M.RemoveTopAnimHeadIconByType = function(self, pid, iconType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveTopAnimHeadIconByType", iconType)
end

M.SetPlayerHeadInfoVisible = function(self, pid, visible)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetPlayerHeadInfoVisible", visible)
end

M.SetPlayerHeadInfoAllow = function(self, pid, allow, reason)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetPlayerHeadInfoAllow", allow, reason)
end

M.SetPlayersHeadInfoAllow = function(self, allow, reason)
	reason = reason or "default"

	if allow then
		self.globalHeadInfoDisallowReasons[reason] = nil
	else
		self.globalHeadInfoDisallowReasons[reason] = true
	end

	self.TryDoHudActionWithType(self, gHudMgr.HUDTargetType.Player, "SetPlayerHeadInfoAllow", allow, reason)
end

M.SetTopText = function(self, pid, text)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetTopIconText", text)
end

M.RemoveTopText = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemoveTopText")
end

M.SetHpHideByBarrier = function(self, pid, enable)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetHpHideByBarrier", enable)
end

M.ShowChatBubble = function(self, pid, isVoice, text)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "ShowChatBubble", isVoice, text)
end

M.ShowChatImageBubble = function(self, pid, tex)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "ShowChatImageBubble", tex)
end

M.ShowChatImageBubbleByImageId = function(self, pid, imageId, duration)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		print_notice("[ShortChatEmoji] head bubble unit is nil, pid = ", ulong.tostring(pid))

		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	if not hudCtrl then
		print_notice("[ShortChatEmoji] head bubble hudCtrl is nil, pid = ", ulong.tostring(pid))

		return
	end

	self.TryDoHudAction(self, hudCtrl, "ShowChatImageBubbleByImageId", imageId, duration)
end

M.RemovePlayerSurvivalStatus = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RemovePlayerSurvivalStatus")
end

M.RefreshPlayerSurvivalStatus = function(self, pid, isRescue, value)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "RefreshPlayerSurvivalStatus", isRescue, value)
end

M.SetDisarmDebuff = function(self, pid, debuffType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetDisarmDebuff", debuffType)
end

M.SetHpDebuff = function(self, pid, debuffType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	self.TryDoHudAction(self, hudCtrl, "SetHpDebuff", debuffType)
end

M.IsTopAnimIconShow = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self.GetHudCtrl(self, unit)

	if not hudCtrl then
		return false
	end

	local exist = hudCtrl.GetIsTemplateExist(hudCtrl, gHudMgr.HUDTemplateType.TopAnimIcon)

	if exist then
		return self.TryDoHudActionWithReturn(self, hudCtrl, "IsTopAnimIconShow")
	end

	return false
end

M.OnShowId = function(self, pid, visible, value)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnShowId", visible, value)
end

M.OnShowIdVehicle = function(self, vehicle_uid, visible, value)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self.TryDoHudAction(self, hudCtrl, "OnShowId", visible, value)
	end
end

M.OnRemoveIdVehicle = function(self, vehicle_uid)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self.TryDoHudAction(self, hudCtrl, "OnRemoveId")
	end
end

M.OnShowHpNum = function(self, pid, visible)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnShowHpNum", visible)
end

M.OnShowDamAndDefNum = function(self, pid, visible)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnShowDamAndDefNum", visible)
end

M.OnShowLevelNum = function(self, pid, visible)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnShowLevelNum", visible)
end

M.OnShowMonsterAIActionDebug = function(self, pid, msg, fadeOutTime)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	if fadeOutTime > 1 then
		self.TryDoHudAction(self, hudCtrl, "OnShowAIAction", msg, fadeOutTime)
	else
		self.TryDoHudAction(self, hudCtrl, "OnRemoveAIAction")
	end
end

M.OnShowVehicleDebugInfo = function(self, vehicle_uid, msg, show)
	local hudCtrl = self.GetHudCtrlNoUnit(self, M.HUDTargetType.Vehicle, vehicle_uid)

	if show then
		self.TryDoHudAction(self, hudCtrl, "OnShowVehicleInfo", msg)
	else
		self.TryDoHudAction(self, hudCtrl, "OnRemoveVehicleInfo")
	end
end

M.OnShowBasketballInfo = function(self, pid, visible, msg)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnShowBasketball", visible, msg)
end

M.OnRemoveBasketballInfo = function(self, pid)
	local hudCtrl = self.GetHudCtrlByPid(self, pid)

	self.TryDoHudAction(self, hudCtrl, "OnRemoveBasketBall")
end

M.TryDoHudAction = function(self, ctrl, actionName, ...)
	if not ctrl then
		return false, "ctrl_missing"
	end

	if not ctrl[actionName] or type(ctrl[actionName]) == "function" then
		return false, "action_missing"
	end

	local result, reason = ctrl[actionName](ctrl, ...)

	if result ~= false then
		return false, reason
	end

	return true, reason
end

M.TryDoHudActionWithReturn = function(self, ctrl, actionName, ...)
	if not ctrl then
		print_error(string.format("%s执行失败，ctrl为空", actionName))

		return
	end

	if not ctrl[actionName] or type(ctrl[actionName]) == "function" then
		print_error(string.format("%s 执行失败，方法不存在", actionName))

		return
	end

	return ctrl[actionName](ctrl, ...)
end

M.ClearAllCtrl = function(self)
	for _, ctrl in pairs(self.ctrlDic) do
		if ctrl then
			local hudTargetType = ctrl.GetHudTargetType(ctrl)

			ctrl.Clear(ctrl)
			table.insert(HudPool[hudTargetType], ctrl)
		end
	end

	table.clear(self.ctrlDic)
	table.clear(self.updateQueue)
	table.clear(HudTagCache)

	M.needUpdateCount = 0
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.ClearAllCtrl(self)
	end
end

M.GenNoUnitRootTag = function(self, rootType, tag)
	if not HudTagCache[rootType] then
		HudTagCache[rootType] = {}
	end

	if not HudTagCache[rootType][tag] then
		HudTagCache[rootType][tag] = string.format("%d_%s", rootType, GetTagString(tag))
		HudTagCache[HudTagCache[rootType][tag]] = tag
	end

	return HudTagCache[rootType][tag]
end

M.OnNpcInteractBtnChanged = function(self, pid, interactBtnShow)
	if self.npcHuds[pid] then
		self.npcHuds[pid]:SetHudShow(interactBtnShow)
	end
end

M.TryDoHudActionWithType = function(self, hudType, actionName, ...)
	for _, ctrl in pairs(self.ctrlDic) do
		if ctrl.GetHudTargetType(ctrl) ~= hudType then
			if not ctrl[actionName] or type(ctrl[actionName]) == "function" then
				print_error(string.format("%s %s 执行失败，uniId = %s", hudType, actionName, ctrl.GetUniId(ctrl)))

				return false
			end

			ctrl[actionName](ctrl, ...)
		end
	end

	return true
end

M.Update = function(self)
	self.cacheClearInterval = self.cacheClearInterval + Time.deltaTime

	if self.cacheClearInterval <= 300 then
		self.cacheClearInterval = 0

		table.clear(HudTagCache)
	end

	for _, ctrl in ipairs(self.updateQueue) do
		if ctrl and ctrl.__isActiveSelf__ then
			ctrl.Update(ctrl)
		end
	end
end

M.ReleasePool = function(self)
	HudPool = {}
end

M.DebugShowAllHud = function(self)
	for _, ctrl in pairs(self.ctrlDic) do
		if ctrl and ctrl.__isActiveSelf__ then
			ctrl.DebugShowAllHud(ctrl)
		end
	end
end

gHudMgr = M
