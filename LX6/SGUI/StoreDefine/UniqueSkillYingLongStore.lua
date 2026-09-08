-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillYingLongStore.lua
-- Decompiled from: 01183_UniqueSkillYingLongStore.lua_827f624af72b.luajit

local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
C_UniqueSkillYingLongStore = DefClass("C_UniqueSkillYingLongStore", C_UniqueSkillYingLongStore, C_StoreGroup)
GroupName2Class.UniqueSkillYingLongStore = C_UniqueSkillYingLongStore
local M = C_UniqueSkillYingLongStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.started = false
	self.isDebug = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnStart = function(self)
	gBattleMgr.uniqueSkillYingLongPanel = self
	self.started = true

	self.InitData(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	gBattleMgr.uniqueSkillYingLongPanel = nil
	self.started = nil

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.InitData = function(self)
	self.GetBtnBindData(self)
	self.BindBtnEvent(self)
	self.RegisterBtnAction(self)
end

M.GetBtnBindData = function(self)
	self.chargeBtn = self.GetStoreByWidget(self, self.bindData.chargeBtn)
end

M.BindBtnEvent = function(self)
	self.bindData.chargeBtn.luaPress = self:CreateAction("OnChargeBtnBeginLongPress")
	self.bindData.chargeBtn.luaRelease = self:CreateAction("OnChargeBtnEndLongPress")

	gCoreHudUIManager:SetupDragButtons(self.bindData, {
		"@Om{I36"
	})
end

M.RegisterBtnAction = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "OnSpiritChange")
	}

	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	self.dataSetEvents = {
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.YingLongCharge,
			self.CreateAction(self, "UpdateBtnState")
		}
	}

	self.ClearDataSetEvents(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnChargeBtnBeginLongPress = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.YinglongPress)
end

M.OnChargeBtnEndLongPress = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.YinglongRelease)
end

M.OnSpiritChange = function(self)
	gCoreHudUIManager:AddDirtySkillType(gCoreHudUIManager.skillType.YingLongCharge)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.UpdateBtnState = function(self, data)
	local skillType = data.key
	local state = data.value
	local btnStore, btn = nil

	if skillType ~= gCoreHudUIManager.skillType.YingLongCharge then
		btnStore = self.chargeBtn
		btn = self.bindData.chargeBtn
	end

	if not btnStore or not btn then
		return
	end

	self.SetBtnVisible(self, btnStore, state[1])
	btn.SetActive(btn, state[2])
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.Log = function(self, ...)
	if self.isDebug then
		print_debug("[UniqueSkillYingLongStore]", ...)
	end
end
