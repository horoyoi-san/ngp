-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UniqueSkillDiLaStore.lua
-- Decompiled from: 01178_UniqueSkillDiLaStore.lua_12546170f7f8.luajit

local GameConfig = LTConfig.GameConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local HudDescConfig = LTConfig.HudDescConfig
C_UniqueSkillDiLaStore = DefClass("C_UniqueSkillDiLaStore", C_UniqueSkillDiLaStore, C_StoreGroup)
GroupName2Class.UniqueSkillDiLaStore = C_UniqueSkillDiLaStore
local M = C_UniqueSkillDiLaStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.dragButtons = {
		"iz\\xa3vX\\x96\\xfdPdXjB",
		"UV\\xc1\\xbc\\x90=\\xa8&\\xdd\\xe6",
		"iz\\xa3vX\\x9e\\xf3InXjB"
	}
	self.floatFlightBtnNames = {
		"iz\\xa3vX\\x96\\xfdPdXjB",
		"UV\\xc1\\xbc\\x90=\\xa8&\\xdd\\xe6",
		"iz\\xa3vX\\x9e\\xf3InXjB"
	}
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
	self:InitData()
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.FloatFlight, true)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnGroupDisable = function(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self, panelId, data)
	gCoreHudTipManager:UpdateBtnTextSpecial(gCoreHudTipManager.btnInfoEnum.JumpJump, gCoreHudTipManager.conditionType.Special, 608)
end

M.OnClose = function(self)
	gCoreHudTipManager:UpdateBtnTextSpecial(gCoreHudTipManager.btnInfoEnum.JumpJump, gCoreHudTipManager.conditionType.Special, -1)
end

M.InitData = function(self)
	self.BindBtnEvent(self)
	self.RegisterBtnAction(self)
	self.InitBtnStore(self)
end

M.InitBtnStore = function(self)
	self.floatDownBtn = self.GetStoreByWidget(self, self.bindData.floatDownBtn)
	self.floatDownBtn.btnId = HudDescConfig.DOWN_BTN
	self.floatUpBtn = self.GetStoreByWidget(self, self.bindData.floatUpBtn)
	self.floatUpBtn.btnId = HudDescConfig.UP_BTN
	self.floatLandBtn = self.GetStoreByWidget(self, self.bindData.floatLandBtn)
	self.floatLandBtn.btnId = HudDescConfig.LAND_BTN
end

M.BindBtnEvent = function(self)
	self.bindData.floatDownBtn.luaBeginLongPress = self:CreateAction("OnDownBtnBeginLongPress")
	self.bindData.floatDownBtn.luaLongPress = self:CreateAction("OnDownBtnLongPress")
	self.bindData.floatDownBtn.luaEndLongPress = self:CreateAction("OnDownBtnEndLongPress")
	self.bindData.floatUpBtn.luaBeginLongPress = self:CreateAction("OnUpBtnBeginLongPress")
	self.bindData.floatUpBtn.luaLongPress = self:CreateAction("OnUpBtnLongPress")
	self.bindData.floatUpBtn.luaEndLongPress = self:CreateAction("OnUpBtnEndLongPress")
	self.bindData.floatLandBtn.luaBeginLongPress = self:CreateAction("OnLandBtnBeginLongPress")
	self.bindData.floatLandBtn.luaEndLongPress = self:CreateAction("OnLandBtnEndLongPress")

	gCoreHudUIManager:SetupDragButtons(self.bindData, self.dragButtons)
end

M.RegisterBtnAction = function(self)
end

M.OnDownBtnBeginLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatDownBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FallPress)

		return true
	end
end

M.OnDownBtnLongPress = function(self)
end

M.OnDownBtnEndLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatDownBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FallRelease)

		return true
	end
end

M.OnUpBtnBeginLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatUpBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.RisePress)

		return true
	end
end

M.OnUpBtnLongPress = function(self)
end

M.OnUpBtnEndLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatUpBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.RiseRelease)

		return true
	end
end

M.OnLandBtnBeginLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatLandBtn)
	gCS.MindPowerMgr:TryThrowEarPhone()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.Land)
end

M.OnLandBtnEndLongPress = function(self)
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatLandBtn)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.dataSetEvents = {
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.FloatFlight,
			self.CreateAction(self, "OnRefreshFloatFlightBtn")
		}
	}
end

M.RegisterWidget = function(self)
end

M.OnRefreshFloatFlightBtn = function(self, data)
	if not data then
		return
	end

	local skillType = data.key
	local state = data.value

	if skillType ~= gCoreHudUIManager.skillType.FloatFlight then
		for i = 1, #self.floatFlightBtnNames do
			local curBtnName = self.floatFlightBtnNames[i]

			if self[curBtnName] and self.bindData[curBtnName] then
				self:SetBtnControl(self[curBtnName], state[1], state[2])
				self.bindData[curBtnName]:SetActive(state[2])
			end
		end
	end

	if state[2] then
		gMessageManager:SendMessage(gEventConstants.ON_HIGH_OBSTACLE, false)
	end
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end
