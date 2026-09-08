-- Original chunk: @Lua\LuaFiles\LX6\Manager\OC\OCMgr_Finish.lua
-- Decompiled from: 02262_OCMgr_Finish.lua_8bc3b5c589c9.luajit

local PhotoUtils = LX6.Utils.PhotoUtils
local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
local M = C_OCMgr

M.BeginShare = function(self, callback)
	self.waitPhoto = callback

	PhotoUtils.TakePhoto()
end

M.OnTakePhoto = function(self)
	if not self.waitPhoto then
		return
	end

	if self.waitPhoto then
		self.waitPhoto()
	end

	gPanelManager:CheckShow(gPanelId.OC_CREATE_FINISH_SHARE)
end

M.LoadEndTimeLine = function(self, playCb)
	local tlName = OriginalCharacterConfig.FinishTimeLine

	if string.is_null_or_empty(tlName) then
		if playCb then
			playCb()
		end

		return
	end

	local data = gTimelineManager:Timeline_CreateTimelineData()

	data.onPlayCallback = function(t)
		if playCb then
			playCb()
		end
	end

	local bindInfoList = {}
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.csUnit.Pid, "oc", nil)

	data.onFinishCallback = function(t)
		self:OnEnd()
	end

	table.insert(bindInfoList, c_bindInfo)

	data.bindUnitInfos = bindInfoList

	self:SetPersonalityAndBackGround(self.personalityAndStory.desc, self.personalityAndStory.labels, self.personalityAndStory.story)
	gTimelineManager:Timeline_LoadAndPlay(tlName, data)
	gPanelManager:Close(gPanelId.OC_CREATE_MAIN_PANEL)
end

M.CreateUnitInWorld = function(self)
	local position = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	position = Vector3.New(position.x + 10, position.y, position.z)
	slot2 = L50.L50App.Scene.OCManager

	slot2:CreateRealUnit(self.npcId, position, 0, function (unit)
		self.worldUnit = unit
	end)
end
