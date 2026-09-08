-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCDialogFirstStore.lua
-- Decompiled from: 00940_OCDialogFirstStore.lua_473991ceb220.luajit

local consts = gClientConst
C_OCDialogFirstStore = DefClass("C_OCDialogFirstStore", C_OCDialogFirstStore, C_StoreGroup)
GroupName2Class.OCDialogFirstStore = C_OCDialogFirstStore
local M = C_OCDialogFirstStore

M.ctor = function(self)
	self.parentStore = nil
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showConfirmEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showConfirmEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	slot3 = gStoreManager
	local baseGroup = slot3:GetStoreGroup(self.bindData.relationCom.Store)
	self.relationStore = baseGroup:GetStoreByWidget(self.bindData.relationCom)
	slot4 = self.mgr

	slot4:RenderInputBox(self.bindData.relationCom, self.bindData.curNavigationArea, function (text)
		self.mgr:OnChangeRelation(text)
		self:RefreshState()
	end, "relationShip")

	self.callStore = baseGroup:GetStoreByWidget(self.bindData.callCom)
	slot4 = self.mgr

	slot4:RenderInputBox(self.bindData.callCom, self.bindData.curNavigationArea, function (text)
		self.mgr:OnChangeCallName(text)
		self:RefreshState()
	end, "callName")

	if self.mgr.isMeikaGrandpa then
		self.ApplyGrandpaDefaults(self)
	end
end

M.ApplyGrandpaDefaults = function(self)
	local defaultCallName = LTConfig.MeccaGrandpaRobotConfig.GrandpaDefaultCallName

	if self.callStore and self.callStore.input then
		self.callStore.input.text = defaultCallName

		self.mgr:OnChangeCallName(defaultCallName)
	end

	local presetRelation = LTConfig.MeccaGrandpaRobotConfig.GrandpaPresetRelation

	if self.relationStore and self.relationStore.input then
		self.relationStore.input.text = presetRelation

		self.mgr:OnChangeRelation(presetRelation)

		self.relationStore.input.interactable = false
	end

	local grandpaWhoIam = (LTConfig.MeccaGrandpaRobotConfig or {}).WhoIam or ""
	self.mgr.chatSettings.whoIam = grandpaWhoIam

	self.mgr.api.RegisterPlayerInfoIdentity(grandpaWhoIam)
	self:RefreshState()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnConfirm)
end

M.RefreshState = function(self)
	self.bindData.showConfirm = consts.BOOL2CTL[self.mgr:CheckHasRelANdName()]
end

M.OnConfirm = function(self)
	self.bindData.confirmBtn.interactable = false
	slot1 = self.mgr

	slot1:PrepareVoiceForChat(function (success)
		self.mgr:Log("[OCDialogFirstStore] PrepareVoiceForChat 回调", "success=", success, "state=", self.STATE_EnableOnce)

		self.bindData.confirmBtn.interactable = true

		if success and self.parentStore then
			self.mgr:Log("[OCDialogFirstStore] 音色准备成功，进入聊天")
			self.parentStore:OnChat()
		elseif not success then
			self.mgr:Log("[OCDialogFirstStore] 音色准备失败")
		end
	end)
end
