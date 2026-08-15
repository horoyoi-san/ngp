gBlockMgr = gBlockMgr or {}
local M = gBlockMgr

function M:Init()
	return
end

function M:OnLogin()
	return
end

function M:TryGetUnlockedBlocks(raidId)
	local unlockBlocks = {}

	for j = 0, LTConfig.CollectionBlockConfig.count - 1 do
		local blockCfg = LTConfig.CollectionBlockConfig.LoadAt(j)
		local countryCfg = LTConfig.CollectionCountryConfig.GetConfig(blockCfg.CountryId)

		if countryCfg then
			if countryCfg.RaidId == raidId then
				local block = {
					worldPos = Vector3.New(blockCfg.BlockLabelPos[1], 0, blockCfg.BlockLabelPos[2]),
					name = blockCfg.BlockName,
					raidId = raidId
				}

				table.insert(unlockBlocks, block)
			end
		end
	end

	return true, unlockBlocks
end

function M:NegativeSyncBlockInfo()
	return
end

function M:IsBlockUnlocked(blockId)
	return true
end
