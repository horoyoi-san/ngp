-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayAlienStore.lua
-- Decompiled from: 01735_GameplayAlienStore.lua_2f51bc0563a2.luajit

C_GameplayAlienStore = DefClass("C_GameplayAlienStore", C_GameplayAlienStore, C_StoreGroup)
GroupName2Class.GameplayAlienStore = C_GameplayAlienStore
local M = C_GameplayAlienStore
local STAGE_NAME = "stage"
local STAGE_MODE = {
	["/\\\\x90\\x89\\x86"] = 0,
	["/\\\\x90\\x89\\x86"] = 1,
	["/\\\\x90\\x89\\x86"] = 2
}
local CURSOR_NAME = "cursor"
local CURSOR_MODE = {
	["\\xfa\\xce6\\xa0"] = 0,
	["\\xfa\\xce6\\xa3"] = 1
}
local CURSOR_PROGRESS_NAME = "progress"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
end

M.OnStart = function(self)
	self.utralSkillProgress = 0
	self.tickUltraSkillProgress = false
	self.hasSendUtralSkill = false
end

M.OnUpdate = function(self)
	if self.hasSendUtralSkill then
		return
	end

	if self.tickUltraSkillProgress then
		self.utralSkillProgress = Mathf.Clamp(self.utralSkillProgress + Time.deltaTime, 0, 3)
	else
		self.utralSkillProgress = Mathf.Clamp(self.utralSkillProgress - Time.deltaTime, 0, 3)
	end

	local dot = Mathf.Ceil(self.utralSkillProgress * 2)

	self.bindData.ProgressCursor:TryChangePage(CURSOR_PROGRESS_NAME, dot)

	if dot > 6 and not self.hasSendUtralSkill then
		self.hasSendUtralSkill = true
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SWITCH_ALIEN_WAR_STAGE] = self.CreateAction(self, self.SwitchStage)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.hasFinishedHeavyAttackPreClick = false
	self.currentStage = 0

	self.SwitchStage(self, 0, 1)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.Btn1.luaPress = self.CreateActionWithArgs(self, "OnLeftStickAttackDown", 1)
	self.bindData.Btn1.luaRelease = self.CreateActionWithArgs(self, "OnLeftStickAttackUp", 1)
	self.bindData.Btn1.luaBeginLongPress = self.CreateActionWithArgs(self, "OnLeftStickAttackLongPressBegin", 1)
	self.bindData.Btn1.luaLongPress = self.CreateActionWithArgs(self, "OnLeftStickAttackLongPress", 1)
	self.bindData.Btn1.luaEndLongPress = self.CreateActionWithArgs(self, "OnLeftStickAttackLongPressEnd", 1)
	self.bindData.Btn2.luaPress = self.CreateActionWithArgs(self, "OnRightStickAttackDown", 1)
	self.bindData.Btn2.luaRelease = self.CreateActionWithArgs(self, "OnRightStickAttackUp", 1)
	self.bindData.Btn3.luaBeginLongPress = self.CreateActionWithArgs(self, "OnSpaceAttackLongPressBegin", 1)
	self.bindData.Btn3.luaLongPress = self.CreateActionWithArgs(self, "OnSpaceAttackLongPress", 1)
	self.bindData.Btn3.luaEndLongPress = self.CreateActionWithArgs(self, "OnSpaceAttackLongPressEnd", 1)
end

M.SwitchStage = function(self, eventId, stage)
	if self.currentStage ~= stage then
		return
	end

	if stage ~= 1 then
		self.bindData.StoreRoot:TryChangePage(CURSOR_NAME, CURSOR_MODE.Cursor1)
		self.bindData.StoreRoot:TryChangePage(STAGE_NAME, STAGE_MODE.Stage2)
	elseif stage ~= 2 then
		self.bindData.StoreRoot:TryChangePage(CURSOR_NAME, CURSOR_MODE.Cursor2)
		self.bindData.StoreRoot:TryChangePage(STAGE_NAME, STAGE_MODE.Stage3)
	end

	self.currentStage = stage
end

M.OnLeftStickAttackDown = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

M.OnLeftStickAttackUp = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

M.OnLeftStickAttackLongPressBegin = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

M.OnLeftStickAttackLongPress = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Normal)
end

M.OnLeftStickAttackLongPressEnd = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

M.OnRightStickAttackDown = function(self)
	self.hasFinishedHeavyAttackPreClick = true

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)
end

M.OnRightStickAttackUp = function(self)
	if not self.hasFinishedHeavyAttackPreClick then
		return
	end

	self.hasFinishedHeavyAttackPreClick = false

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)
end

M.OnSpaceAttackLongPressBegin = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Basic)

	self.tickUltraSkillProgress = true
	self.hasSendUtralSkill = false
end

M.OnSpaceAttackLongPress = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Basic)
end

M.OnSpaceAttackLongPressEnd = function(self)
	if self.hasSendUtralSkill then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Basic)
	end

	self.utralSkillProgress = 0
	self.tickUltraSkillProgress = false
	self.hasSendUtralSkill = false
end
