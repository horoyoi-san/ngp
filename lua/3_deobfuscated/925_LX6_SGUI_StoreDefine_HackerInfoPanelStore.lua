C_HackerInfoPanelStore = DefClass("C_HackerInfoPanelStore", C_HackerInfoPanelStore, C_StoreGroup)
GroupName2Class.HackerInfoPanelStore = C_HackerInfoPanelStore
local M = C_HackerInfoPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if not gInteractionManager.hackInfoShow then
		gPanelManager:Close(gPanelId.HACKER_INFO)

		return
	end

	self.isClickedBtn = false
	gInteractionManager.hackerInfoStore = self

	if self.data or not data then
		self:OnClose()
	end

	gMessageManager:AddMessageListener(gEventConstants.HACK_BATTERY_CHANGE, self:CreateAction(self.OnHackBatteryChange))
	self:RefreshBattery(true)

	self.data = data

	if data.isPress then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8504)
	end

	gHackManager.isShowHackInfoPanel = true
	local isNpcPanel = not data.isItem or data.useNpcCfg
	self.bindData.type = isNpcPanel and 1 or 0
	L50.L50App.Scene.HackManager.curHackUnit = data.unit

	if data.hackerId then
		self.bindData.HackInfo = 0
		local cfg = isNpcPanel and LTConfig.HackerHackNpcConfig.GetConfig(data.hackerId) or LTConfig.HackerHackJiguanConfig.GetConfig(data.hackerId)

		if not cfg then
			print_error("HackerInfoPanelStore:OnShow cfg is nil, hackerId = ", data.hackerId, data)

			return
		end

		self.bindData.title = cfg.Name
		self.clickAbleBtns = {}

		for i = 1, #data.usefulBtns do
			local btn = data.usefulBtns[i]

			if btn.state == 0 then
				table.insert(self.clickAbleBtns, btn)
			end

			if btn.state == 1 then
				self.bindData.isLock = 1
			end
		end

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

		if isNpcPanel then
			self.bindData.job = cfg.Job
		end

		self.bindData.icon = cfg.Icon
	else
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

		self.bindData.job = cfg.JobFakeTag
		self.bindData.desc = L50.L50App.Scene.GamePlayUtils:GetJobDescByUnit(data.unit)
		self.npcTextIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(data.unit):ToTable()
		self.bindData.HackInfo = L50.L50App.Scene.HackManager.hackInfoType
		self.bindData.btnNum = math.min(#self.npcTextIds, 3)

		for i = 1, self.bindData.btnNum do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.npcTextIds[i])
			self.bindData["text" .. i] = textCfg.Text
		end
	end

	self.bindData.btn1.luaClick = self:CreateAction(self.OnClick1)
	self.bindData.btn2.luaClick = self:CreateAction(self.OnClick2)
	self.bindData.btn3.luaClick = self:CreateAction(self.OnClick3)

	self.bindData.anim:Play("S_Vx_HackerAudioInfoPanel_open")
end

function M:OnClick1()
	self:OnClick(1)
end

function M:OnClick2()
	self:OnClick(2)
end

function M:OnClick3()
	self:OnClick(3)
end

function M:OnClick(index)
	if not gGadgetManager.HackInteractTarget then
		return false
	end

	if not self.data.hackerId then
		local textId = self.npcTextIds[index]
		local unit = self.data.unit
		local batteryEnough = gGadgetManager:AskHack(nil, function (success)
			if not success then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)

				return
			end

			gGadgetManager:DoHackPressClickAction()

			local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(unit, textId)

			gInteractionManager.hintInfosHudStore:AddHackSkillIcon(unit, skillType)
			gGadgetManager:SetHackInfoPanel(false)
		end)

		if not batteryEnough then
			self:PlayBatteryClickLowAnim()
		end

		self.isClickedBtn = true

		return true
	end

	if #self.clickAbleBtns == 0 then
		return false
	end

	local data = self.clickAbleBtns[index]

	if data.state ~= 0 then
		return false
	end

	local realIndex = data.index - 1
	local target = gGadgetManager.HackInteractTarget
	local batteryEnough = gGadgetManager:AskHack(data.index, function (success)
		if not success then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)

			return
		end

		gGadgetManager:DoHackPressClickAction()

		if target.isItem then
			gSpoonClientMgr:ReleaseContextEvent(target.entityId, gSpoonEventType.HackInteractTrigger, {
				index = realIndex
			})
		else
			gClientToGameSceneDelegate:AskHackingNpc(target.entityId, realIndex).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)
					print_error("AskHackingNpc err = ", err, realIndex, target)
				end
			end
		end
	end)

	if not batteryEnough then
		self:PlayBatteryClickLowAnim()
	end

	self.isClickedBtn = true

	if gHackManager.isShowHackInfoPanel and gGadgetManager.HackInteractTarget.interactType ~= 2 and batteryEnough then
		gGadgetManager:SetHackInfoPanel(false)
	end

	return true
end

function M:PlayBatteryClickLowAnim()
	self.bindData.batteryAnim:Play("S_Vx_HackerPeopleInfoPanel_less_click")

	local time = self.bindData.batteryAnim:GetClip("S_Vx_HackerPeopleInfoPanel_less_click").length

	gLuaTimeMgrUtils.Delay(function ()
		self:RefreshBattery(false, true)
	end, time, nil, nil, true)
end

function M:OnClose()
	gInteractionManager.hackInfoShow = false

	gMessageManager:RemoveMessageListener(gEventConstants.HACK_BATTERY_CHANGE, self:CreateAction(self.OnHackBatteryChange))

	if self.data.isPress and not self.isClickedBtn then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)
	end

	gGadgetManager:OnHackItemView(false, self.data)

	gHackManager.isShowHackInfoPanel = false
	gGadgetManager.hackInfoTargetId = nil
	self.data = nil
	L50.L50App.Scene.HackManager.curHackUnit = nil
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

M.lastUpdateTime = 0

function M:OnUpdate()
	if Time.time - self.lastUpdateTime < 1 then
		return
	end

	local myPlayerExists = gCS.MyPlayerManager.PlayerUnitExists

	if not myPlayerExists or gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or not gLuaDataManager.isNetworkAvailable then
		return
	end

	self.lastUpdateTime = Time.time
end

function M:RefreshFill(info, isInit, forcePlay)
	if not self.bindData.batteryAnim then
		return
	end

	self.bindData.maxMemory = Mathf.Floor(info.BatteryTotalCount)
	self.bindData.curMemory = Mathf.Floor(info.BatteryCurrentCount)
	self.bindData.maxMemoryText = "/" .. self.bindData.maxMemory
	local rate = self.bindData.curMemory / self.bindData.maxMemory
	local isBatteryEmpty = rate == 0
	local isBatteryFull = rate == 1

	if forcePlay or isBatteryEmpty ~= self.isBatteryEmpty then
		self.isBatteryEmpty = isBatteryEmpty

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
		local time = self.bindData.batteryAnim:GetClip("S_Vx_HackerPeopleInfoPanel_open").length

		gLuaTimeMgrUtils.Delay(function ()
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
		end, time, nil, nil, true)
	end
end

function M:RefreshBattery(isInit, forcePlay)
	if gInteractionManager.hackInfo then
		self:RefreshFill(gInteractionManager.hackInfo, isInit, forcePlay)
	end
end

function M:OnHackBatteryChange()
	self:RefreshBattery()
end
