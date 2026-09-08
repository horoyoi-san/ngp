-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillHackStore.lua
-- Decompiled from: 01179_UniqueSkillHackStore.lua_69b1456fe3e5.luajit

C_UniqueSkillHackStore = DefClass("C_UniqueSkillHackStore", C_UniqueSkillHackStore, C_StoreGroup)
GroupName2Class.UniqueSkillHackStore = C_UniqueSkillHackStore
local M = C_UniqueSkillHackStore
local DragEventListener = SGUI.EventSystems.DragEventListener

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.SetShowBtn(self)
	self.RefreshBtnHide(self)
end

M.OnStart = function(self)
	self:RefreshBtnHide()

	self.RingShowMsg = function(eventId, show)
		self:SetRingShow(show)
	end

	gMessageManager:AddMessageListener(gEventConstants.HACK_RING_SHOW, self.RingShowMsg)

	self.BtnShowMsg = function(eventId)
		self:SetShowBtn()
	end

	self.ParkourStateMsg = function(eventId)
		if gCoreHudUIManager.hudDecisionMode ~= 2 then
			return
		end

		local hackBtnType = gCoreHudUIManager.skillType.Hack

		if hackBtnType then
			gCoreHudUIManager:AddDirtySkillType(hackBtnType)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.HACK_BTN_REFRESH, self.BtnShowMsg)
	gMessageManager:AddMessageListener(gEventConstants.PAOKU_STATE_CHANGE, self.ParkourStateMsg)

	self.isPressBtn = false
	local dragBtn = DragEventListener.Get(self.bindData.skillBtn.gameObject)
	dragBtn.onDrag = self:CreateAction("OnDrag")
	dragBtn.onBeginDrag = self:CreateAction("OnBeginDrag")
	dragBtn.onEndDrag = self:CreateAction("OnEndDrag")
	self.bindData.skillBtn.luaBeginLongPress = self:CreateAction("OnPress")
	self.bindData.skillBtn.luaEndLongPress = self:CreateAction("OnRelease")

	self:SetSelect(1)
end

M.RefreshBtnGray = function(self)
	if not self.bindData.skillBtn then
		return
	end

	self.RefreshBtnHide(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.RingShowMsg then
		gMessageManager:RemoveMessageListener(gEventConstants.HACK_RING_SHOW, self.RingShowMsg)
	end

	if self.BtnShowMsg then
		gMessageManager:RemoveMessageListener(gEventConstants.HACK_BTN_REFRESH, self.BtnShowMsg)
	end

	if self.ParkourStateMsg then
		gMessageManager:RemoveMessageListener(gEventConstants.PAOKU_STATE_CHANGE, self.ParkourStateMsg)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnGroupDisable = function(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.dataSetEvents = {
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hack,
			self.CreateAction(self, "OnHackBtnStateChange")
		}
	}
end

M.OnHackBtnStateChange = function(self, data)
	self.RefreshBtnHide(self)
end

M.RegisterWidget = function(self)
end

M.OnDrag = function(self, eventData)
	if not gGadgetManager.HackInteractTarget or not self.isPressBtn then
		return
	end

	self.curPos = eventData.position

	self.RefreshSelect(self)
end

M.OnPress = function(self)
	gMessageManager:SendMessage(gEventConstants.HACK_BTN_PRESS)

	if not gGadgetManager.HackInteractTarget then
		return
	end

	if gCS.BattleManager.CheckCanBreakCounterSkill() then
		gCS.BattleManager.ClearSkill(gCS.MyPlayerManager.PlayerUnit)
	else
		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8506)
	gInteractionManager.hintInfosHudStore:OnPressHackInteract()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.isPressBtn = true

	if not gGadgetManager.HackInteractTarget.hackerId then
		if gGadgetManager.HackInteractTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
			self.textIds = L50.L50App.Scene.HackManager:GetVehicleHackBtns(gGadgetManager.HackInteractTarget.vehicle):ToTable()
		elseif gGadgetManager.HackInteractTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
			self.textIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(gGadgetManager.HackInteractTarget.unit):ToTable()
		end

		self.bindData.num = math.min(#self.textIds, 3)

		for i = 1, self.bindData.num do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.textIds[i])
			self.bindData["text" .. i] = textCfg.Text
		end
	else
		self.clickAbleBtns = {}

		for i = 1, #gGadgetManager.HackInteractTarget.usefulBtns do
			local btn = gGadgetManager.HackInteractTarget.usefulBtns[i]

			if btn.state ~= 0 then
				table.insert(self.clickAbleBtns, btn)
			end
		end

		self.bindData.num = math.min(#self.clickAbleBtns, 3)

		for i = 1, self.bindData.num do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.clickAbleBtns[i].id)
			self.bindData["text" .. i] = textCfg.Text
		end
	end

	self.SetSelect(self, 1)
end

M.OnRelease = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() and L50.L50App.Scene.HackManager.curSelectHackData and not gGadgetManager.HackInteractTarget then
		if L50.L50App.Scene.HackManager.curSelectHackData.locked then
			return
		end

		gGadgetManager:OnLongPressHackTrigger()

		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gInteractionManager.hintInfosHudStore:OnReleaseHackInteract()

		return
	end

	if not self.isPressBtn then
		return
	end

	if not gGadgetManager.HackInteractTarget then
		return
	end

	self:OnClickSelect()
	gInteractionManager.hintInfosHudStore:OnReleaseHackInteract(true)

	self.isPressBtn = false
	self.bindData.num = 0
	self.bindData.showRing = 0
end

M.OnBeginDrag = function(self, eventData)
	if not gGadgetManager.HackInteractTarget then
		return
	end

	self.isPressBtn = true
	self.startPos = eventData.position
	self.bindData.showRing = 1
end

M.OnEndDrag = function(self, eventData)
	if not self.isPressBtn then
		return
	end

	self.isPressBtn = false
	self.bindData.num = 0
	self.bindData.showRing = 0

	if not gGadgetManager.HackInteractTarget then
		return
	end
end

M.RefreshSelect = function(self)
	local delta = self.curPos - self.startPos
	local angle = math.atan2(delta.y, delta.x) * 180 / math.pi - 98

	if angle < -180 then
		angle = angle + 360
	end

	local index = self.GetIndexByAngle(self, angle)

	self.SetSelect(self, index)
end

M.SetSelect = function(self, index)
	self.curSelect = index
	self.bindData.button1 = index ~= 1 and 2 or 0
	self.bindData.button2 = index ~= 2 and 2 or 0
	self.bindData.button3 = index ~= 3 and 2 or 0
end

local angleUnit = 46

M.GetIndexByAngle = function(self, angle)
	if self.bindData.num ~= 1 and angle > 0 and angle < angleUnit * 2 then
		return 1
	end

	if self.bindData.num ~= 2 or self.bindData.num ~= 3 then
		if angle > 0 and angle < angleUnit then
			return 1
		end

		if angleUnit >= angle and angle < angleUnit * 2 then
			return 2
		end
	end

	if self.bindData.num ~= 3 and angle > -angleUnit and angle >= 0 then
		return 3
	end

	return 0
end

M.SetShowBtn = function(self)
	self.RefreshBtnGray(self)

	self.isPressBtn = false
	self.bindData.num = 0
	self.bindData.showRing = 0
end

M.OnClickSelect = function(self)
	if self.curSelect ~= 0 then
		return
	end

	gGadgetManager:OnClickHackBtn(self.curSelect)
end

M.SetRingShow = function(self, show)
end

M.RefreshBtnHide = function(self)
	if not self.bindData.skillBtn then
		return
	end

	local hackBtnType = gCoreHudUIManager.skillType.Hack
	local btnState = hackBtnType and gCoreHudUIManager.buttonStateMonitor and gCoreHudUIManager.buttonStateMonitor[hackBtnType]
	local coreVisible = true
	local coreInteractable = true

	if btnState then
		coreVisible = btnState[1]
		coreInteractable = btnState[2]
	end

	local visible = gGadgetManager:HasGlobalHackAble() and coreVisible
	local interactable = coreInteractable
	self.bindData.btnHide = visible and 0 or 1
	self.bindData.skillBtn.interactable = gGadgetManager.HackInteractTarget and interactable

	if not gCS.LuaUtils.IsNonMobileAdaptive() and L50.L50App.Scene.HackManager.curSelectHackData and not gGadgetManager.HackInteractTarget then
		self.bindData.skillBtn.interactable = not L50.L50App.Scene.HackManager.curSelectHackData.locked

		return
	end
end
