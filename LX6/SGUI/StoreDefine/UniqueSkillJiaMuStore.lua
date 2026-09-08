-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillJiaMuStore.lua
-- Decompiled from: 01180_UniqueSkillJiaMuStore.lua_183387cbcfed.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
local HudDescConfig = LTConfig.HudDescConfig
local CoreHudButtonConfig = LTConfig.CoreHudButtonConfig
C_UniqueSkillJiaMuStore = DefClass("C_UniqueSkillJiaMuStore", C_UniqueSkillJiaMuStore, C_StoreGroup)
GroupName2Class.UniqueSkillJiaMuStore = C_UniqueSkillJiaMuStore
local M = C_UniqueSkillJiaMuStore

M.DefineAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.OnAwake = function(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)
end

M.OnEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnStart = function(self)
	self.summonWheelBtn = self:GetStoreByWidget(self.bindData.summonWheelBtn)
	self.summonWheelBtn.btnId = HudDescConfig.SUMMON_WHEEL_BTN

	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.JiaMuSummon, true)
end

M.OnShow = function(self, panelId, data)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
	self.dataSetEvents = {
		{
			gCoreHudUIManager.buttonStateMonitor,
			CoreHudButtonConfig.JiaMuSummon,
			self.CreateAction(self, "UpdateBtnState")
		}
	}
end

M.RegisterWidget = function(self)
	self.bindData.summonWheelBtn.luaPress = self.CreateAction(self, "OnPressSummonWheelBtn")
	self.bindData.summonWheelBtn.luaRelease = self.CreateAction(self, "OnReleaseSummonWheelBtn")
	local btnDrag = DragEventListener.Get(self.bindData.summonWheelBtn.gameObject)
	btnDrag.onBeginDrag = self.CreateAction(self, "OnBtnDragBegin")
	btnDrag.onDrag = self.CreateAction(self, "OnBtnDrag")
	btnDrag.onEndDrag = self.CreateAction(self, "OnBtnDragEnd")
end

M.OnPressSummonWheelBtn = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):OpenCircle(gCircleType.SUMMON)
end

M.OnReleaseSummonWheelBtn = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()
end

M.UpdateBtnState = function(self, data)
	local skillType = data.key
	local state = data.value
	local btnStore, btn = nil

	if skillType ~= CoreHudButtonConfig.JiaMuSummon then
		btnStore = self.summonWheelBtn
		btn = self.bindData.summonWheelBtn
	end

	if not btnStore or not btn then
		return
	end

	gStoreButtonMgr:SetButtonVisibleBase(btnStore, state[1])
	btn:SetActive(state[2])
	self:Log("visible", state[1], "interactable", state[2])
end

M.OnBtnDragBegin = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleJiaMuSummonStore"):OnDragMoveStart(eventPointer)
end

M.OnBtnDrag = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleJiaMuSummonStore"):OnDragMove(eventPointer)
end

M.OnBtnDragEnd = function(self, eventPointer)
	gStoreManager:GetStoreGroup("BackCircleJiaMuSummonStore"):OnDragMoveEnd(eventPointer)
end

M.Log = function(self, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[UniqueSkillJiaMuStore]", ...)
	end
end
