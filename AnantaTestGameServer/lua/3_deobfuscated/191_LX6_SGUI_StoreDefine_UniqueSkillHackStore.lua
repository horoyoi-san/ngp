C_UniqueSkillHackStore = DefClass("C_UniqueSkillHackStore", C_UniqueSkillHackStore, C_StoreGroup)
GroupName2Class.UniqueSkillHackStore = C_UniqueSkillHackStore
local M = C_UniqueSkillHackStore
local DragEventListener = SGUI.EventSystems.DragEventListener

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	self:SetShowBtn(gGadgetManager.hackBtnShow)
	self:RefreshBtnHide()
end

function M:OnStart()
	self:RefreshBtnHide()

	function self.RingShowMsg(eventId, show)
		self:SetRingShow(show)
	end

	gMessageManager:AddMessageListener(gEventConstants.HACK_RING_SHOW, self.RingShowMsg)

	function self.BtnShowMsg(eventId, show)
		self:SetShowBtn(show)
	end

	function self.ParkourStateMsg(eventId)
		self:RefreshBtnHide()
	end

	gMessageManager:AddMessageListener(gEventConstants.HACK_BTN_SHOW, self.BtnShowMsg)
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

M.setBtnGray = false

function M:SetBtnGray(gray)
	if not self.bindData.skillBtn then
		return
	end

	self.setBtnGray = gray

	self:RefreshBtnHide()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gMessageManager:RemoveMessageListener(gEventConstants.HACK_RING_SHOW, self.RingShowMsg)
	gMessageManager:RemoveMessageListener(gEventConstants.HACK_BTN_SHOW, self.BtnShowMsg)
	gMessageManager:RemoveMessageListener(gEventConstants.PAOKU_STATE_CHANGE, self.ParkourStateMsg)
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end

function M:OnDrag(eventData)
	if not gGadgetManager.HackInteractTarget or not self.isPressBtn then
		return
	end

	self.curPos = eventData.position

	self:RefreshSelect()
end

function M:OnPress()
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
		self.npcTextIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(gGadgetManager.HackInteractTarget.unit):ToTable()
		self.bindData.num = math.min(#self.npcTextIds, 3)

		for i = 1, self.bindData.num do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.npcTextIds[i])
			self.bindData["text" .. i] = textCfg.Text
		end
	else
		self.clickAbleBtns = {}

		for i = 1, #gGadgetManager.HackInteractTarget.usefulBtns do
			local btn = gGadgetManager.HackInteractTarget.usefulBtns[i]

			if btn.state == 0 then
				table.insert(self.clickAbleBtns, btn)
			end
		end

		self.bindData.num = math.min(#self.clickAbleBtns, 3)

		for i = 1, self.bindData.num do
			local textCfg = LTConfig.TextCommonTextConfig.GetConfig(self.clickAbleBtns[i].id)
			self.bindData["text" .. i] = textCfg.Text
		end
	end

	self:SetSelect(1)
end

function M:OnRelease()
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

function M:OnBeginDrag(eventData)
	if not gGadgetManager.HackInteractTarget then
		return
	end

	self.isPressBtn = true
	self.startPos = eventData.position
	self.bindData.showRing = 1
end

function M:OnEndDrag(eventData)
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

function M:RefreshSelect()
	local delta = self.curPos - self.startPos
	local angle = math.atan2(delta.y, delta.x) * 180 / math.pi - 98

	if angle <= -180 then
		angle = angle + 360
	end

	local index = self:GetIndexByAngle(angle)

	self:SetSelect(index)
end

function M:SetSelect(index)
	self.curSelect = index
	self.bindData.button1 = index == 1 and 2 or 0
	self.bindData.button2 = index == 2 and 2 or 0
	self.bindData.button3 = index == 3 and 2 or 0
end

local angleUnit = 46

function M:GetIndexByAngle(angle)
	if self.bindData.num == 1 and angle >= 0 and angle <= angleUnit * 2 then
		return 1
	end

	if self.bindData.num == 2 or self.bindData.num == 3 then
		if angle >= 0 and angle <= angleUnit then
			return 1
		end

		if angleUnit < angle and angle <= angleUnit * 2 then
			return 2
		end
	end

	if self.bindData.num == 3 and angle >= -angleUnit and angle < 0 then
		return 3
	end

	return 0
end

function M:SetShowBtn(show)
	self:SetBtnGray(not show)

	self.isPressBtn = false
	self.bindData.num = 0
	self.bindData.showRing = 0
end

function M:OnClickSelect()
	if self.curSelect == 0 then
		return
	end

	gGadgetManager:OnClickHackBtn(self.curSelect)
end

function M:SetRingShow(show)
	return
end

function M:RefreshBtnHide()
	local isSummoned = L50.L50App.Scene.GamePlayUtils:IsNotPeople(gCS.MyPlayerManager.PlayerUnit)
	local isSaiMo = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId == 15021023
	local showState = isSaiMo or isSummoned
	local visible = showState
	local interactable = true
	local platform = gMainMenuMgr:GetParkourStatePlatform()

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local skill1Config = gMainMenuMgr.clientStateConfig[state].Hack

		if gCoreHudUIManager:IsParkourStateValid(skill1Config, platform) then
			visible = visible and skill1Config[platform].visible
			interactable = interactable and skill1Config[platform].interactable
		end
	end

	self.bindData.btnHide = visible and 0 or 1
	self.bindData.skillBtn.interactable = not self.setBtnGray and interactable
end
