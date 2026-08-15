local RecordConfig = LTConfig.SyncValueConfig
local RecordParamConfig = LTConfig.SyncValueParameterConfig
C_GameplayRecordValueManager = DefClass("C_GameplayRecordValueManager", C_GameplayRecordValueManager)
local M = C_GameplayRecordValueManager

function M:ctor()
	self.passwords = {}
end

function M:OnChangeRaidGamePlayInfo(recordInfo)
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

function M:OnRemoveRecordValue(recordId, paramId)
	if self.passwords[recordId] then
		if paramId == 0 then
			self.passwords[recordId] = {}
		else
			self.passwords[recordId][paramId] = nil
		end
	end
end

function M:OnChangeRecordDoubleValue(recordId, paramId, value)
	if recordId == RecordConfig.YLHotel and paramId == RecordParamConfig.CurrencyNum then
		gMessageManager:SendMessage(gEventConstants.ROB_BANK_ADD_MONEY, value)
	end
end

function M:ChangeRecordDoubleValue(recordId, paramId, value, callBack)
	gClientToGameSceneDelegate:AskAddRaidGamePlayRecordDoubleValue(recordId, paramId, value).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		callBack()
	end
end

gGameplayRecordValueManager = gGameplayRecordValueManager or C_GameplayRecordValueManager.new()
