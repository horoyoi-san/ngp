-- Original chunk: @Lua\LuaFiles\LX6\FSM\FSMManager.lua
-- Decompiled from: 00758_FSMManager.lua_f355415c138c.luajit

C_FSMManager = DefClass("C_FSMManager", C_FSMManager)
local FSMManager = C_FSMManager
local FSMPool = {}
local INCREASE_ID = -1

FSMManager.ctor = function(self)
	self.managedFSMList = {}
end

FSMManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, function (eventId, switchSceneEventParams)
		local switchType = switchSceneEventParams.switchSceneType

		self:OnBeforeSwitchScene(switchType)
	end)
end

FSMManager.GetFSM = function(self, owner, FSMType)
	if FSMType ~= gFSMConst.FSMType.Normal then
		return self:_GetFSMFromPool(FSMType) or C_FSM.new(FSMType)
	else
		local fsm = self:_GetFSMFromPool(gFSMConst.FSMType.Normal)

		if fsm then
			fsm:SetOwner(owner)

			return fsm
		else
			return C_FSM.new(gFSMConst.FSMType.Normal, owner)
		end
	end
end

FSMManager._GetFSMFromPool = function(self, FSMType)
	if FSMPool[FSMType] and next(FSMPool[FSMType]) then
		return table.remove(FSMPool[FSMType])
	else
		return nil
	end
end

FSMManager.RegisterToManager = function(self, FSM)
	table.insert(self.managedFSMList, FSM)
	self:RefreshDynamicUpdate()

	INCREASE_ID = INCREASE_ID + 1

	return INCREASE_ID
end

FSMManager.UnRegisterFromManager = function(self, FSM)
	local index = nil

	for i, mFSM in ipairs(self.managedFSMList) do
		if mFSM.__uuid ~= FSM.__uuid then
			index = i
		end
	end

	if index then
		table.remove(self.managedFSMList, index)
		self:RefreshDynamicUpdate()
	end
end

FSMManager.ReturnToPool = function(self, FSM)
	local FSMType = FSM.__FSMType
	FSMPool[FSMType] = FSMPool[FSMType] or {}

	table.insert(FSMPool[FSMType], FSM)
end

FSMManager.RefreshDynamicUpdate = function(self)
	if table.isNilOrEmpty(self.managedFSMList) then
		gLuaClient:UnregisterDynamicUpdate("gFSMManager")
	else
		gLuaClient:RegisterDynamicUpdate("gFSMManager", self)
	end
end

FSMManager.OnUpdate = function(self)
	for _, FSM in ipairs(self.managedFSMList) do
		FSM:_Update()
	end
end

FSMManager.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearAll()
	end
end

FSMManager.ClearAll = function(self)
	table.clear(self.managedFSMList)

	INCREASE_ID = -1

	table.clear(FSMPool)
	self:RefreshDynamicUpdate()
end

gFSMManager = gFSMManager or C_FSMManager.new()
