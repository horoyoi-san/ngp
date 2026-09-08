-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineCustomPrepareRoomStore_Stage.lua
-- Decompiled from: 01105_OnlineCustomPrepareRoomStore_Stage.lua_b8435df1646b.luajit

local M = C_OnlineCustomPrepareRoomStore

M.SetConfirm = function(self, isConfirm)
	self.bindData.readyBtn.interactable = false
	slot2 = self.mgr

	slot2:AskStageConfirm(self.linkGame.uxData.StageId, isConfirm, function (isSuccess)
		if not self.STATE_OnShowOnce or not isSuccess then
			return
		end

		self.bindData.readyBtn.interactable = true
	end)
end

M.AddReadyChangeInfo = function(self, patch)
	self.pendingPatch = self.pendingPatch or {}

	for k, v in pairs(patch) do
		self.pendingPatch[k] = v
	end
end
