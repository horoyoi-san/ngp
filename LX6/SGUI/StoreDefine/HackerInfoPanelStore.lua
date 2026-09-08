-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerInfoPanelStore.lua
-- Decompiled from: 01702_HackerInfoPanelStore.lua_714bf044288c.luajit

C_HackerInfoPanelStore = DefClass("C_HackerInfoPanelStore", C_HackerInfoPanelStore, C_StoreGroup)
GroupName2Class.HackerInfoPanelStore = C_HackerInfoPanelStore
local M = C_HackerInfoPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gHackManager.isShowHackInfoPanel = true
	self.isClickedBtn = false
	gInteractionManager.hackerInfoStore = self

	if not data then
		gPanelManager:Close(gPanelId.HACKER_INFO)

		return
	end

	gGadgetManager:OnHackItemView(true, data)

	self.bindData.batteryChangeAction = self:CreateAction("OnHackBatteryChange")

	gMessageManager:AddMessageListener(gEventConstants.HACK_BATTERY_CHANGE, self.bindData.batteryChangeAction)
	self:RefreshBattery(true)

	self.data = data

	if data.isPress then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8504)
	end

	local isAtmosphereNpc = data.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc
	local isAtmosphereVehicle = data.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle
	local isGadget = data.hackTargetType ~= gGadgetManager.HackTargetType.Gadget
	local isTaskNpc = data.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc
	local isNpc = isAtmosphereNpc or isTaskNpc
	self.bindData.type = isGadget and 0 or 1
	L50.L50App.Scene.HackManager.curHackUnit = data.unit
	L50.L50App.Scene.HackManager.curHackVehicle = data.vehicle

	if data.hackerId then
		self.bindData.HackInfo = 0
		local cfg = isTaskNpc and LTConfig.HackerHackNpcConfig.GetConfig(data.hackerId) or LTConfig.HackerHackJiguanConfig.GetConfig(data.hackerId)

		if not cfg then
			print_error("HackerInfoPanelStore:OnShow cfg is nil, hackerId = ", data.hackerId, data)

			return
		end

		self.bindData.title = cfg.Name
		self.clickAbleBtns = {}
		local isLock = 0

		for i = 1, #data.usefulBtns do
			local btn = data.usefulBtns[i]

			if btn.state ~= 0 then
				table.insert(self.clickAbleBtns, btn)
			end

			if btn.state ~= 1 then
				isLock = 1
			end
		end

		self.bindData.isLock = isLock
		self.bindData.btnNum = math.min(#self.clickAbleBtns, 3)

		for i = 1, self.bindData.btnNum do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.clickAbleBtns[i].id)

			if textCfg then
				self.bindData["text" .. i] = textCfg.Text
			else
				print_error("HackerInfoPanelStore:OnShow textCfg is nil, id = ", self.clickAbleBtns[i].id)
			end
		end

		self.bindData.desc = cfg.Introduction

		if isNpc then
			if not string.is_null_or_empty(cfg.Job) then
				self.bindData.showIP = 1
				self.bindData.ipText = cfg.Job
			else
				self.bindData.showIP = 0
			end
		else
			self.bindData.showIP = 1
			self.bindData.ipText = self.GetRandomIp(self)
		end

		self.bindData.icon = cfg.Icon
	elseif isAtmosphereNpc then
		if L50.L50App.Scene.GamePlayUtils:UnitIsNull(data.unit) then
			gGadgetManager:SetHackInfoPanel(false)

			return
		end

		local tempId = data.unit.NpcId
		local cfg = LTConfig.AgentConfig.GetConfig(tempId)

		if cfg then
			self.bindData.title = cfg.Name
			self.bindData.icon = cfg.HeadIcon
		else
			print_error("HackerInfoPanelStore:OnShow cfg is nil, tempId = ", tempId, data.go.name)
		end

		if not string.is_null_or_empty(cfg.JobFakeTag) then
			self.bindData.showIP = 1
			self.bindData.ipText = cfg.JobFakeTag
		else
			self.bindData.showIP = 0
		end

		self.bindData.desc = L50.L50App.Scene.GamePlayUtils:GetJobDescByUnit(data.unit)
		self.textIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(data.unit):ToTable()
		self.bindData.HackInfo = L50.L50App.Scene.HackManager.hackInfoType
		self.bindData.btnNum = math.min(#self.textIds, 3)

		for i = 1, self.bindData.btnNum do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.textIds[i])
			self.bindData["text" .. i] = textCfg.Text
		end
	elseif isAtmosphereVehicle then
		if gCS.LuaUtils.IsNull(data.go) then
			gGadgetManager:SetHackInfoPanel(false)

			return
		end

		local tempId = data.vehicle.cfgId
		local cfg = LTConfig.VehicleConfig.GetConfig(tempId)

		if cfg then
			self.bindData.title = cfg.VehicleName
			self.bindData.icon = cfg.SVehicleBrandSmallIcon
			self.bindData.desc = LTConfig.VehicleTypeConfig.GetConfig(cfg.VehicleType).DisplayName
		else
			print_error("HackerInfoPanelStore:OnShow cfg is nil, tempId = ", tempId, data.go)
		end

		self.bindData.showIP = 1
		self.bindData.ipText = self:GetRandomIp()
		self.textIds = L50.L50App.Scene.HackManager:GetVehicleHackBtns(data.vehicle):ToTable()
		self.bindData.HackInfo = 0
		self.bindData.btnNum = math.min(#self.textIds, 3)

		for i = 1, self.bindData.btnNum do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.textIds[i])
			self.bindData["text" .. i] = textCfg.Text
		end
	end

	self.bindData.btn1.luaClick = self.CreateAction(self, self.OnClick1)
	self.bindData.btn2.luaClick = self.CreateAction(self, self.OnClick2)
	self.bindData.btn3.luaClick = self.CreateAction(self, self.OnClick3)
end

M.OnClick1 = function(self)
	self.OnClick(self, 1)
end

M.OnClick2 = function(self)
	self.OnClick(self, 2)
end

M.OnClick3 = function(self)
	self.OnClick(self, 3)
end

M.OnClick = function(self, index)
	if not gGadgetManager.HackInteractTarget then
		return false
	end

	if not self.data.hackerId then
		local textId = self.textIds[index] or 0
		local target = self.data

		gGadgetManager:AskHack(nil, function (success, batteryEnough)
			if not batteryEnough then
				self:PlayBatteryClickLowAnim()
			end

			if success then
				self.isClickedBtn = true
			else
				return
			end

			gGadgetManager:DoHackPressClickAction()

			if target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
				local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(target.unit, textId)

				gInteractionManager.hintInfosHudStore:AddHackSkillIcon(target.unit, skillType)
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				L50.L50App.Scene.HackManager:OnClickHackVehicle(target.vehicle, textId)
			end

			gGadgetManager:SetHackInfoPanel(false)
		end)

		return true
	end

	if #self.clickAbleBtns ~= 0 then
		return false
	end

	local data = self.clickAbleBtns[index]

	if data.state == 0 then
		return false
	end

	local realIndex = data.index - 1
	local target = gGadgetManager.HackInteractTarget
	local needClosePanel = gHackManager:IsShowHackInfoPanel() and gGadgetManager.HackInteractTarget.interactType == 2

	gGadgetManager:AskHack(data.index, function (success, batteryEnough)
		if not batteryEnough then
			self:PlayBatteryClickLowAnim()
		end

		if success then
			self.isClickedBtn = true
		else
			return
		end

		gGadgetManager:DoHackPressClickAction()

		if target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
			gSpoonClientMgr:ReleaseContextEvent(target.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.HackInteractTrigger, {
				index = realIndex
			})
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc then
			gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskHackingNpc, target.entityId, realIndex, function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)
					print_error("AskHackingNpc err = ", err, realIndex, target)
				end
			end)
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle then
			L50.L50App.Scene.HackManager:AskHackTaskVehicle(target.entityId, realIndex)
		end

		if needClosePanel and batteryEnough then
			gGadgetManager:SetHackInfoPanel(false)
		end
	end)

	return true
end

M.GetRandomIp = function(self)
	local parts = {}

	for i = 1, 8 do
		parts[i] = string.format("%x", math.random(0, 65535))
	end

	return "@ " .. table.concat(parts, ":")
end

M.PlayBatteryClickLowAnim = function(self)
	slot1 = self.bindData.batteryAnim

	slot1:Play("S_Vx_HackerPeopleInfoPanel_less_click")

	slot1 = self.bindData.batteryAnim
	local time = slot1:GetClip("S_Vx_HackerPeopleInfoPanel_less_click").length

	gLuaTimeMgrUtils.Delay(function ()
		self:RefreshBattery(false, true)
	end, time, nil, , true)
end

M.OnClose = function(self)
	gMessageManager:RemoveMessageListener(gEventConstants.HACK_BATTERY_CHANGE, self.bindData.batteryChangeAction)

	if self.data.isPress and not self.isClickedBtn then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)
	end

	gGadgetManager:OnHackItemView(false, self.data)

	gHackManager.isShowHackInfoPanel = false

	gGadgetManager:SetHackTarget(nil)

	gGadgetManager.hackInfoTargetId = nil
	self.data = nil
	L50.L50App.Scene.HackManager.curHackUnit = nil
	L50.L50App.Scene.HackManager.curHackVehicle = nil

	gMessageManager:SendMessage(gEventConstants.HACK_BTN_REFRESH)
end

M.OnActiveDeviceChange = function(self, device)
end

M.lastUpdateTime = 0

M.OnUpdate = function(self)
	if Time.time - self.lastUpdateTime >= 0.5 then
		return
	end

	self.lastUpdateTime = Time.time
	local myPlayerExists = gCS.MyPlayerManager.PlayerUnitExists

	if not myPlayerExists or gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not gLuaDataManager.isNetworkAvailable then
		return
	end

	if not self.PanelShowAble(self) then
		gGadgetManager:SetHackInfoPanel(false)

		return
	end
end

M.PanelShowAble = function(self)
	if not gGadgetManager.HackInteractTarget then
		return false
	end

	return true
end

M.RefreshFill = function(self, info, isInit, forcePlay)
	if not self.bindData.batteryAnim then
		return
	end

	self.bindData.maxMemory = Mathf.Floor(info.BatteryTotalCount)
	self.bindData.curMemory = Mathf.Floor(info.BatteryCurrentCount)
	self.bindData.maxMemoryText = "/" .. self.bindData.maxMemory
	local rate = self.bindData.curMemory / self.bindData.maxMemory
	local isBatteryEmpty = rate ~= 0
	local isBatteryFull = rate ~= 1

	if forcePlay or isBatteryEmpty == self.isBatteryEmpty or isBatteryFull == self.isBatteryFull then
		self.isBatteryEmpty = isBatteryEmpty
		self.isBatteryFull = isBatteryFull

		if not isInit then
			if isBatteryFull then
				self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_Full")
			elseif isBatteryEmpty then
				self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_empty")
			else
				self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_Charging")
			end
		end
	end

	if isInit then
		if not self.bindData.batteryAnim then
			return
		end

		if isBatteryFull then
			self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_Full")
		elseif isBatteryEmpty then
			self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_empty")
		else
			self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_Charging")
		end
	end
end

M.RefreshBattery = function(self, isInit, forcePlay)
	if gInteractionManager.hackInfo then
		self.RefreshFill(self, gInteractionManager.hackInfo, isInit, forcePlay)
	end
end

M.OnHackBatteryChange = function(self)
	self.RefreshBattery(self)
end
