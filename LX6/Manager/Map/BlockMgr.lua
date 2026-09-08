-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\BlockMgr.lua
-- Decompiled from: 00198_BlockMgr.lua_83c587bde1e8.luajit

gBlockMgr = gBlockMgr or {}
local M = gBlockMgr

M.Init = function(self)
end

M.OnLogin = function(self)
end

M.TryGetUnlockedBlocks = function(self, raidId)
	local unlockBlocks = {}

	for j = 0, LTConfig.CollectionBlockConfig.count - 1 do
		local blockCfg = LTConfig.CollectionBlockConfig.LoadAt(j)

		if blockCfg.RaidId ~= raidId then
			local block = {
				worldPos = Vector3.New(blockCfg.BlockLabelPos[1], 0, blockCfg.BlockLabelPos[2]),
				name = blockCfg.BlockName,
				raidId = raidId
			}

			table.insert(unlockBlocks, block)
		end
	end

	return true, unlockBlocks
end

M.NegativeSyncBlockInfo = function(self)
end

M.IsBlockUnlocked = function(self, blockId)
	return true
end
