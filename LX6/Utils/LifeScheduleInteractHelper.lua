-- Original chunk: @Lua\LuaFiles\LX6\Utils\LifeScheduleInteractHelper.lua
-- Decompiled from: 00143_LifeScheduleInteractHelper.lua_b7bf6808e77f.luajit

LifeScheduleInteract = LifeScheduleInteract or {}
LifeScheduleInteract.Type = {
	["]+{O"] = 3,
	["}\\xa6\\xad\\xbb\\xb9"] = 4,
	["pRϯ\\xa9\\xac\r\\xc6\\xe6"] = 5,
	["Y*|O"] = 2,
	["}\\xaf\\xac\\xaa\\xba"] = 1,
	["zFbcG0("] = 6,
	["T-s^"] = 0
}
LifeScheduleInteract.Phase = {
	["~\\xba\\xa3\\xbd\\xa2"] = 0,
	["\\xabfb"] = 1
}
LifeScheduleInteract.Reason = {
	["|Oڒ\\x82:\\xb9\n\\xce\\xed"] = 2,
	["\\xed\\xd21\\xe5"] = 3,
	[":G\\x83\\x8d\\x86E"] = 4,
	["dUܱ\\x80-\\xae\\xc7\\xfc"] = 5,
	["2\\xe2Q)\\xe2\\xa6M\\xa0U\\xb5\\xb2"] = 6,
	["&!\\xfdv\\x8a\\xd45\\xa6,\\xe3\\xfe\\xeaq\\xff"] = 1,
	["\\xea\\xce7\\xe2"] = 0
}

local isZeroPid = function(pid)
	if not pid then
		return true
	end

	if ulong and ulong.check and ulong.check(pid) then
		return ulong.equals(pid, 0)
	end

	return pid ~= 0
end

local getPid = function(npcUnit, fallbackPid)
	if fallbackPid and not isZeroPid(fallbackPid) then
		return fallbackPid
	end

	if not npcUnit or not gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		return 0
	end

	return npcUnit.Pid or 0
end

local warnInvalid = function(method)
	print_warn("LifeScheduleInteract:" .. method .. " npcUnit invalid")
end

LifeScheduleInteract.FireStart = function(self, npcUnit, interactionType, fallbackPid)
	local pid = getPid(npcUnit, fallbackPid)

	if isZeroPid(pid) then
		warnInvalid("FireStart")

		return
	end

	gMessageManager:SendMessage(gEventConstants.FAVOR_NPC_INTERACT_LIFECYCLE, {
		pid = pid,
		type = interactionType,
		phase = self.Phase.Start,
		reason = self.Reason.Success
	})
end

LifeScheduleInteract.FireEnd = function(self, npcUnit, interactionType, reason, fallbackPid)
	local pid = getPid(npcUnit, fallbackPid)

	if isZeroPid(pid) then
		warnInvalid("FireEnd")

		return
	end

	gMessageManager:SendMessage(gEventConstants.FAVOR_NPC_INTERACT_LIFECYCLE, {
		pid = pid,
		type = interactionType,
		phase = self.Phase.End,
		reason = reason or self.Reason.Success
	})
end

LifeScheduleInteract.FirePanelStart = function(self, npcUnit, fallbackPid)
	self:FireStart(npcUnit, self.Type.Panel, fallbackPid)
end

LifeScheduleInteract.FirePanelEnd = function(self, npcUnit, reason, fallbackPid)
	self:FireEnd(npcUnit, self.Type.Panel, reason or self.Reason.PlayerCancelled, fallbackPid)
end

LifeScheduleInteract.FirePanelTransfer = function(self, npcUnit, fallbackPid)
	self:FirePanelEnd(npcUnit, self.Reason.PanelReplaced, fallbackPid)
end

return LifeScheduleInteract
