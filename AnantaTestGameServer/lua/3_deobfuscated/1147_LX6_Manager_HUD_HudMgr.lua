local HUDManager = LX6.GUI.HUDNew.HUDManager
local DestructibleManager = LX6.Item.DestructibleMgr
local HudPool = {}
local HudTagCache = {}
local CreateParamsStack = {}

local function PushDataToStack(data)
	table.insert(CreateParamsStack, data)
end

local function PopDataFromStack()
	return table.remove(CreateParamsStack)
end

local function GetTagString(tag)
	return ulong.check(tag) and ulong.tostring(tag) or tostring(tag)
end

local M = {
	needUpdateCount = 0,
	OnInit = function (self)
		self.ctrlDic = {}
		self.npcHuds = {}
		self.updateQueue = {}
		self.cacheClearInterval = 0

		gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, function (eventId, switchType)
			self:OnBeforeSwitchScene(switchType)
		end)
	end
}

function M:GetCtrlFromPool(hudTargetType)
	if next(HudPool) and HudPool[hudTargetType] and next(HudPool[hudTargetType]) then
		return table.remove(HudPool[hudTargetType])
	else
		if not HudPool[hudTargetType] then
			HudPool[hudTargetType] = {}
		end

		return M.HUDTargetType2Ctrl[hudTargetType].New()
	end
end

function M:RegisterHudCtrl(uniIdentifier, hudTargetType, param, hudUIRoot)
	local ctrl = self:GetCtrlFromPool(hudTargetType)
	local pid, unit = nil

	if not param then
		print_error("未传入引用！", uniIdentifier)

		return
	end

	if ulong.check(param) then
		pid = param
		unit = gCS.SceneDataMgr.GetUnit(pid)
	elseif param == 0 then
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

	if #CreateParamsStack > 0 then
		data = PopDataFromStack()
	end

	ctrl:Init(uniIdentifier, hudUIRoot, unit, data)

	ctrl.__isActiveSelf__ = true

	if ctrl.Update and type(ctrl.Update) == "function" then
		if ctrl:IsNpcHud() then
			ctrl.npcPid = pid

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				ctrl:Update()

				self.npcHuds[pid] = ctrl
			end
		else
			table.insert(self.updateQueue, ctrl)

			ctrl.updateIndex = table.count(self.updateQueue)
			M.needUpdateCount = M.needUpdateCount + 1
		end
	end
end

function M:AddHudTemplate(uniIdentifier, InstanceId, templateType, templateTag)
	if not self.ctrlDic[uniIdentifier] then
		print_error("no exist HudUIRoot:", uniIdentifier, templateType)

		return
	end

	self.ctrlDic[uniIdentifier]:AddHudTemplate(InstanceId, templateType, templateTag)
end

function M:GetHudCtrl(unit)
	local pid = ulong.tostring(unit.Pid)

	if not self.ctrlDic[pid] then
		return
	end

	return self.ctrlDic[pid]
end

function M:GetHudCtrlByPid(Pid)
	local pid = ulong.tostring(Pid)

	if not self.ctrlDic[pid] then
		return
	end

	return self.ctrlDic[pid]
end

function M:GetHudCtrlNoUnit(rootType, tag)
	local tTag = self:GenNoUnitRootTag(rootType, tag)

	if not self.ctrlDic[tTag] then
		return
	end

	return self.ctrlDic[tTag]
end

function M:DestroyHudCtrl(uniIdentifier)
	if not self.ctrlDic[uniIdentifier] then
		return
	end

	local hudTargetType = self.ctrlDic[uniIdentifier]:GetHudTargetType()

	if HudTagCache[uniIdentifier] then
		HudTagCache[hudTargetType][HudTagCache[uniIdentifier]] = nil
		HudTagCache[uniIdentifier] = nil
	end

	local ctrl = self.ctrlDic[uniIdentifier]

	if ctrl.Update and type(ctrl.Update) == "function" then
		if ctrl:IsNpcHud() then
			if ctrl.npcPid then
				self.npcHuds[ctrl.npcPid] = nil
			end
		else
			if ctrl.updateIndex == nil then
				print_error("看到这个报错说明被前面的报错阻塞了，请把紧跟在前的报错发给@wuzhijing01")
			end

			table.remove(self.updateQueue, ctrl.updateIndex)

			for i = ctrl.updateIndex, #self.updateQueue do
				if self.updateQueue[i] == nil then
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

function M:CreateMySpiritHUD()
	HUDManager.GenMyHUDUIRoot()
end

function M:CreateDestruct(destructId)
	local destructibleTarget = DestructibleManager.Instance:GetDestructibleHUDTarget(destructId)

	if destructibleTarget then
		HUDManager.GenHUDUIRootNoUnit(M.HUDTargetType.Destruct, destructibleTarget, GetTagString(destructId))
	end
end

function M:CreateSlotEntity(entityId, data)
	local tran = data.go.transform
	local tag = GetTagString(entityId)

	if tran then
		PushDataToStack(data)
		HUDManager.GenHUDUIRootNoUnit(M.HUDTargetType.SlotEntity, tran, tag)

		gGadgetManager.headTitleList[entityId] = entityId
	end
end

function M:CreateVehicle(vehicle_uid)
	local vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(vehicle_uid)
	local tag = GetTagString(vehicle_uid)

	if vehicle then
		HUDManager.GenHUDUIRootNoUnit(M.HUDTargetType.Vehicle, vehicle.gameObject.transform, tag)
	end
end

function M:DestroyDestructTarget(destructId)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl:GetUIRoot())
end

function M:DestroySlotEntityTarget(entityId)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.SlotEntity, entityId)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl:GetUIRoot())

	gGadgetManager.headTitleList[entityId] = nil
end

function M:DestroyVehicleTarget(vehicle_uid)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if not hudCtrl then
		return
	end

	HUDManager.DestroyHUDUIRoot(hudCtrl:GetUIRoot())
end

function M:HpChanged(pid)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "HpChanged")
end

function M:RefreshHpVisible(pid)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "RefreshHpVisible")
end

function M:VehicleAddHp(vehicle_uid)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		local tTag = self:GenNoUnitRootTag(M.HUDTargetType.Vehicle, vehicle_uid)

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyHpBar, tTag)
	end
end

function M:VehicleHpChanged(vehicle_uid, hp)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self:TryDoHudAction(hudCtrl, "HpChanged", hp)
	end
end

function M:VehicleDead(vehicle_uid)
	if vehicle_uid == nil then
		print_error("vehicle_uid 为 nil")

		return
	end

	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self:TryDoHudAction(hudCtrl, "Dead")
	end
end

function M:ShowHpBar(pid, show)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	if not unit.IsDead then
		local hudCtrl = self:GetHudCtrl(unit)

		self:TryDoHudAction(hudCtrl, "ShowHpBar", show)
	end
end

function M:DisarmChanged(pid)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "DisarmChanged")
end

function M:ShowPartShieldBar(pid, index, show)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "ShowPartShieldBar", index, show)
end

function M:PartShieldChanged(pid, index)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsDead then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)
	local shieldConfigId = gCS.ShieldManager:GetShieldConfigId(unit.ClientData.SubType, index)
	local shieldConfig = LTConfig.ShieldConfig.GetConfig(shieldConfigId)

	if shieldConfig.Kind == 4 then
		self:TryDoHudAction(hudCtrl, "FrequencyShieldChanged", index)

		return
	end

	if shieldConfig.Kind == 1 or shieldConfig.Kind == 3 then
		self:TryDoHudAction(hudCtrl, "WholeBodyShieldChanged")

		return
	end

	self:TryDoHudAction(hudCtrl, "PartShieldChanged", index)
end

function M:RefreshMissileAttackMarker(pid, uuid, show)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "RefreshMissileAttackMarker", uuid, show)
end

function M:PlayLockStateAni(pid, uuid, show, time)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	if not hudCtrl then
		return
	end

	time = time or 9999

	self:TryDoHudAction(hudCtrl, "PlayLockStateAni", uuid, show, time)
end

function M:PlayAttackStateAni(pid, uuid, show, time)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	if not hudCtrl then
		return
	end

	time = time or 9999

	self:TryDoHudAction(hudCtrl, "PlayAttackStateAni", uuid, show, time)
end

function M:AddBuffHeadIcon(pid, buffId)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "AddBuffHeadIcon", buffId)
end

function M:RemoveBuffHeadIcon(pid, buffId)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "RemoveBuffHeadIcon", buffId)
end

function M:EnableAIChatHud(pid, enable)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "EnableAIChatHud", enable)
end

function M:SetHeadInfoVisibility(pid, show)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "SetHeadInfoVisibility", show)
end

function M:SetDestructibleHpProgress(destructId, hpProgress)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self:CreateDestruct(destructId)

		hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)
	end

	self:TryDoHudAction(hudCtrl, "HpProgressChange", hpProgress)
end

function M:SetDestructibleDebugInfo(destructId, hp, maxHp, damageText)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self:CreateDestruct(destructId)

		hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)
	end

	self:TryDoHudAction(hudCtrl, "HpProgressChangeDebug", hp, maxHp, damageText)
end

function M:SetDestructibleCommonDebugInfo(destructId, info)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self:CreateDestruct(destructId)

		hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)
	end

	self:TryDoHudAction(hudCtrl, "OnShowDestructCommonDebug", info)
end

function M:SetDestructibleCommonDebugInfoVisible(destructId, visible)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self:CreateDestruct(destructId)

		hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)
	end

	self:TryDoHudAction(hudCtrl, "SetDestructibleCommonDebugVisible", visible)
end

function M:SetDestructibleDebugVisible(destructId, visible)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)

	if not hudCtrl then
		self:CreateDestruct(destructId)

		hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Destruct, destructId)
	end

	self:TryDoHudAction(hudCtrl, "SetDestructibleDebugVisible", visible)
end

function M:DestroyHpBar(pid)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "DestroyHpBar")
end

function M:CreateHpBar(pid)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "CreateHpBar")
end

function M:SetNpcNameAllow(pid, allow)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetNpcNameAllow", allow)
end

function M:SetNpcTitleAllow(pid, allow)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetNpcTitleAllow", allow)
end

function M:SetNpcIconAllow(pid, allow)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetNpcIconAllow", allow)
end

function M:AddNpcIcon(pid, iconId)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "AddNpcIcon", iconId)
end

function M:RemoveNpcIcon(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveNpcIcon")
end

function M:PlayEnergyShortageAnim(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "PlayEnergyShortageAnim")
end

function M:SetAIChatVisibility(pid, visible)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetAIChatVisibility", visible)
end

function M:SetForceHideHp(pid, force)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetForceHideHp", force)
end

function M:RemoveLevitationBar(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveLevitationBar")
end

function M:AddCommonHeadIcon(pid, iconId)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "AddCommonHeadIcon", iconId)
end

function M:RemoveCommonHeadIcon(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveCommonHeadIcon")
end

function M:AddTopAnimHeadIcon(pid, iconType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "AddTopAnimHeadIcon", iconType)
end

function M:RemoveTopAnimHeadIcon(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveTopAnimHeadIcon")
end

function M:SetPlayerHeadInfoVisible(pid, visible)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetPlayerHeadInfoVisible", visible)
end

function M:SetTopText(pid, text)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetTopIconText", text)
end

function M:RemoveTopText(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveTopText")
end

function M:SetHpHideByBarrier(pid, enable)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "SetHpHideByBarrier", enable)
end

function M:RemoveDangerIcon(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	local hudCtrl = self:GetHudCtrl(unit)

	self:TryDoHudAction(hudCtrl, "RemoveDangerIcon")
end

function M:OnShowId(pid, visible, value)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "OnShowId", visible, value)
end

function M:OnShowIdVehicle(vehicle_uid, visible, value)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self:TryDoHudAction(hudCtrl, "OnShowId", visible, value)
	end
end

function M:OnRemoveIdVehicle(vehicle_uid)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if hudCtrl then
		self:TryDoHudAction(hudCtrl, "OnRemoveId")
	end
end

function M:OnShowHpNum(pid, visible)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "OnShowHpNum", visible)
end

function M:OnShowDamAndDefNum(pid, visible)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "OnShowDamAndDefNum", visible)
end

function M:OnShowLevelNum(pid, visible)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	self:TryDoHudAction(hudCtrl, "OnShowLevelNum", visible)
end

function M:OnShowMonsterAIActionDebug(pid, msg, fadeOutTime)
	local hudCtrl = self:GetHudCtrlByPid(pid)

	if fadeOutTime >= 1 then
		self:TryDoHudAction(hudCtrl, "OnShowAIAction", msg, fadeOutTime)
	else
		self:TryDoHudAction(hudCtrl, "OnRemoveAIAction")
	end
end

function M:OnShowVehicleDebugInfo(vehicle_uid, msg, show)
	local hudCtrl = self:GetHudCtrlNoUnit(M.HUDTargetType.Vehicle, vehicle_uid)

	if show then
		self:TryDoHudAction(hudCtrl, "OnShowVehicleInfo", msg)
	else
		self:TryDoHudAction(hudCtrl, "OnRemoveVehicleInfo")
	end
end

function M:TryDoHudAction(ctrl, actionName, ...)
	if not ctrl then
		return
	end

	if not ctrl[actionName] or type(ctrl[actionName]) ~= "function" then
		return
	end

	ctrl[actionName](ctrl, ...)
end

function M:ClearAllCtrl()
	for _, ctrl in pairs(self.ctrlDic) do
		if ctrl then
			local hudTargetType = ctrl:GetHudTargetType()

			ctrl:Clear()
			table.insert(HudPool[hudTargetType], ctrl)
		end
	end

	table.clear(self.ctrlDic)
	table.clear(self.updateQueue)
	table.clear(HudTagCache)

	M.needUpdateCount = 0
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:ClearAllCtrl()
	end
end

function M:GenNoUnitRootTag(rootType, tag)
	if not HudTagCache[rootType] then
		HudTagCache[rootType] = {}
	end

	if not HudTagCache[rootType][tag] then
		HudTagCache[rootType][tag] = string.format("%d_%s", rootType, GetTagString(tag))
		HudTagCache[HudTagCache[rootType][tag]] = tag
	end

	return HudTagCache[rootType][tag]
end

function M:OnNpcInteractBtnChanged(pid, interactBtnShow)
	if self.npcHuds[pid] then
		self.npcHuds[pid]:SetHudShow(interactBtnShow)
	end
end

function M:Update()
	self.cacheClearInterval = self.cacheClearInterval + Time.deltaTime

	if self.cacheClearInterval > 300 then
		self.cacheClearInterval = 0

		table.clear(HudTagCache)
	end

	for _, ctrl in ipairs(self.updateQueue) do
		if ctrl and ctrl.__isActiveSelf__ then
			ctrl:Update()
		end
	end
end

function M:ReleasePool()
	HudPool = {}
end

function M:DebugShowAllHud()
	for _, ctrl in pairs(self.ctrlDic) do
		if ctrl and ctrl.__isActiveSelf__ then
			ctrl:DebugShowAllHud()
		end
	end
end

gHudMgr = M
