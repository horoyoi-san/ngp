-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\GameplayRecordValueManager.lua
-- Decompiled from: 00695_GameplayRecordValueManager.lua_2aa47324fc0b.luajit

C_GameplayRecordValueManager = DefClass("C_GameplayRecordValueManager", C_GameplayRecordValueManager)
local M = C_GameplayRecordValueManager

M.ctor = function(self)
	self.passwords = {}
end

M.OnChangeRaidGamePlayInfo = function(self, recordInfo)
	if table.isNilOrEmpty(recordInfo) then
		return
	end

	for i, info in pairs(recordInfo) do
		self.passwords[i] = {}

		for k, v in pairs(info) do
			self.passwords[i][k] = v
		end
	end
end

M.OnRemoveRecordValue = function(self, recordId, paramId)
	if self.passwords[recordId] then
		if paramId ~= 0 then
			self.passwords[recordId] = {}
		else
			self.passwords[recordId][paramId] = nil
		end
	end
end

M.OnChangeRecordDoubleValue = function(self, recordId, paramId, value, recordValue)
	gMessageManager:SendMessage(gEventConstants.ROB_BANK_ADD_MONEY, {
		value = value,
		recordId = recordId,
		paramId = paramId,
		recordValue = recordValue
	})
end

M.ChangeRecordDoubleValue = function(self, recordId, paramId, value, callBack)
	gClientToGameSceneDelegate:AskAddRaidGamePlayRecordDoubleValue(recordId, paramId, value).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		callBack()
	end
end

gGameplayRecordValueManager = gGameplayRecordValueManager or C_GameplayRecordValueManager.new()
