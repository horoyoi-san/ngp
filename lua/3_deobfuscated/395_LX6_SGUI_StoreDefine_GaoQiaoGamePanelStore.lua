C_GaoQiaoGamePanelStore = DefClass("C_GaoQiaoGamePanelStore", C_GaoQiaoGamePanelStore, C_StoreGroup)
GroupName2Class.GaoQiaoGamePanelStore = C_GaoQiaoGamePanelStore
local M = C_GaoQiaoGamePanelStore
local Side = {
	Left = 1,
	Right = 2
}
local MyPlayerManager = gCS.MyPlayerManager

function M:ctor()
	self.GAO_QIAO_VM_TYPE = {
		LEFT_QTE_END = 2,
		LEFT_QTE_START = 1,
		RIGHT_QTE_END = 4,
		RIGHT_QTE_START = 3,
		RIGHT_QTE_START_NO_END = 6,
		LEFT_QTE_START_NO_END = 5,
		NONE = 0
	}
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	self.bindData.btnL:SetActive(false)
	self.bindData.btnR:SetActive(false)

	self.qteBtn = {
		[Side.Left] = self.bindData.btnL,
		[Side.Right] = self.bindData.btnR
	}
	self.curSide = nil
	self.successSignalTable = {
		[Side.Left] = data.leftSuccessSignal,
		[Side.Right] = data.rightSuccessSignal
	}
	self.missSignal = {
		[Side.Left] = data.leftMissSignal,
		[Side.Right] = data.rightMissSignal
	}
	self.endSignal = data.endSignal
	self.waitEndSignal = false
	gGaoQiaoManager.gaoqiaoPanel = self
	self.isShow = true
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(false)
	end

	if gGaoQiaoManager.cachedGaoQiaoVmEvent and gGaoQiaoManager.cachedGaoQiaoVmEvent > 0 then
		self:OnVmSignal(gGaoQiaoManager.cachedGaoQiaoVmEvent)
	end
end

function M:OnClose()
	self.qteBtn = nil
	gGaoQiaoManager.gaoqiaoPanel = nil
	self.isShow = false
	local store = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	if store and store.bindData.btnExit then
		store.bindData.btnExit:SetActive(true)
	end

	if self.endSignal and self.endSignal > 0 then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.endSignal)
	end
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
	self.bindData.btnL.luaClick = self:CreateAction("OnClickBtnL")
	self.bindData.btnR.luaClick = self:CreateAction("OnClickBtnR")
end

function M:OnClickBtnL()
	self:ConfirmQTEClick(Side.Left)
end

function M:OnClickBtnR()
	self:ConfirmQTEClick(Side.Right)
end

function M:OnVmSignal(signalType)
	if signalType == self.GAO_QIAO_VM_TYPE.LEFT_QTE_START then
		self:HideQTEContent(Side.Right)
		self:ShowQTEContent(Side.Left)

		self.waitEndSignal = true
	elseif signalType == self.GAO_QIAO_VM_TYPE.LEFT_QTE_END then
		local failed = self.curSide ~= nil

		self:HideQTEContent(Side.Left)

		if failed then
			self:PlayMissEffect(Side.Left)
		elseif self.successSignal and self.successSignal > 0 then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.successSignal)
		end
	elseif signalType == self.GAO_QIAO_VM_TYPE.RIGHT_QTE_START then
		self:HideQTEContent(Side.Left)
		self:ShowQTEContent(Side.Right)

		self.waitEndSignal = true
	elseif signalType == self.GAO_QIAO_VM_TYPE.RIGHT_QTE_END then
		local failed = self.curSide ~= nil

		self:HideQTEContent(Side.Right)

		if failed then
			self:PlayMissEffect(Side.Right)
		elseif self.successSignal and self.successSignal > 0 then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.successSignal)
		end
	elseif signalType == self.GAO_QIAO_VM_TYPE.LEFT_QTE_START_NO_END then
		self:HideQTEContent(Side.Right)
		self:ShowQTEContent(Side.Left)

		self.waitEndSignal = false
	elseif signalType == self.GAO_QIAO_VM_TYPE.RIGHT_QTE_START_NO_END then
		self:HideQTEContent(Side.Left)
		self:ShowQTEContent(Side.Right)

		self.waitEndSignal = false
	end

	self.successSignal = nil
end

function M:ShowQTEContent(side)
	self.curSide = side
	local btn = self.qteBtn[side]

	btn:SetActive(true)

	self.bindData.qteClick.renderOpacity = 0
	self.bindData.qteMiss.renderOpacity = 0
end

function M:HideQTEContent(side)
	self.curSide = nil
	local btn = self.qteBtn[side]

	btn:SetActive(false)
end

function M:ConfirmQTEClick(side)
	if self.curSide == side then
		self:HideQTEContent(side)
		self:PlaySuccessEffect(side)
	end
end

function M:PlaySuccessEffect(side)
	self.bindData.qteClick.renderOpacity = 1
	self.successSignal = self.successSignalTable[side]

	self.bindData.QTERoot:InvokeCallback(SGUI.EInvokeTime.User1)
	self:ResetEffectPos(side)

	if not self.waitEndSignal and self.successSignal and self.successSignal > 0 then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, self.successSignal)

		self.successSignal = nil
	end
end

function M:PlayMissEffect(side)
	self.bindData.qteMiss.renderOpacity = 1
	local missSignal = self.missSignal[side]

	if missSignal and missSignal > 0 then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(MyPlayerManager.PlayerUnit, missSignal)
	end

	self.bindData.QTERoot:InvokeCallback(SGUI.EInvokeTime.User2)
	self:ResetEffectPos(side)
end

function M:ResetEffectPos(side)
	local qteBtn = self.qteBtn[side]
	local pos = qteBtn.localPosition

	self.bindData.QTERoot.transform:SetLocalPosition(pos.x, pos.y, pos.z)
end
