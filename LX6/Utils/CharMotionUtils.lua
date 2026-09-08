-- Original chunk: @Lua\LuaFiles\LX6\Utils\CharMotionUtils.lua
-- Decompiled from: 00142_CharMotionUtils.lua_598e9d9baed8.luajit

local M = {
	OnStateTreeEnter = function ()
		gMessageManager:SendMessage(gEventConstants.ON_ENTER_CHAR_MOTION_ANIMATION)
	end,
	OnStateTreeExit = function ()
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION)
	end,
	MotionActionBreak = function (_)
		gMessageManager:SendMessage(gEventConstants.ON_EXIT_CHAR_MOTION_ANIMATION)
	end,
	OnClickPlayerInteract = function (self, npcUnit)
		gMainPhoneFunctionAction.OpenCharMotionPanel({
			["ZIⴊ\\x95\\xcd\\xed"] = true,
			showType = LTConfig.ActionItemTabConfig.ShowTypeType.Interaction,
			npcId = npcUnit.NpcId,
			npcUnit = npcUnit,
			npcPid = npcUnit.Pid
		})
	end
}

M.InvitePlayerInteractionAction = function(pid, actionId)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(actionId)
	local multiInteractType = actionItemCfg.MultiInteractType
	local ok, unitPid = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)
	local npcUnit = ok and gCS.SceneDataMgr.GetUnit(unitPid)

	if npcUnit and gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		local canPlayMultiInteract = L18.Gameplay.MotionActionManager.Instance:CanInvitedPlayerMultiInteract(multiInteractType, gCS.MyPlayerManager.PlayerUnit, npcUnit)

		if not canPlayMultiInteract then
			local replyState = UX.Game.InteractionActionInviteReplyState.InInteractionReject
			slot9 = gClientToGameDelegate

			slot9:AskReplyInvitePlayerInteractionAction(replyState).Callback = function (errorId)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)
				end
			end

			return
		end

		M.invitePid = pid
		M.actionId = actionId

		gPanelManager:CheckShow(gPanelId.MOTION_INVITE_MSG_PANEL, {
			pid = pid,
			actionId = actionId
		})
	else
		local replyState = UX.Game.InteractionActionInviteReplyState.InInteractionReject
		slot8 = gClientToGameDelegate

		slot8:AskReplyInvitePlayerInteractionAction(replyState).Callback = function ()
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end
	end
end

M.SyncInviteeStartPlayAction = function()
	gPanelManager:CheckShow(gPanelId.CHAR_MOTION_STOP_BUTTON_PANEL, {
		invitePid = M.invitePid,
		actionId = M.actionId
	})
end

M.GetPlayerInteractionActionInfo = function()
	return gPlayerManager.infoMinor.bindData.playerInteractionActionInfo
end

M.IsActionMatchCurSpirit = function(actionItemId)
	local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(actionItemId)

	if not actionItemCfg then
		return false
	end

	local curSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	return #actionItemCfg.SpiritId ~= 0 or table.contains(actionItemCfg.SpiritId, curSpiritId)
end

M.CheckInviteNotDisturb = function()
	local playerInteractionActionInfo = M.GetPlayerInteractionActionInfo()

	return playerInteractionActionInfo and playerInteractionActionInfo.InvitedNotDisturb or false
end

M.SetInviteNotDisturb = function(callback)
	local isEnableNotDisturb = M.CheckInviteNotDisturb()
	slot2 = gClientToGameDelegate

	slot2:AskEnableInvitedNotDisturb(not isEnableNotDisturb).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback()
			end

			return
		end

		local playerInteractionActionInfo = M.GetPlayerInteractionActionInfo()

		if playerInteractionActionInfo then
			playerInteractionActionInfo.InvitedNotDisturb = not isEnableNotDisturb
		end

		if callback then
			callback()
		end
	end
end

M.TryMultiInteract = function(id, playerUnit, npcUnit)
	local result, multiInteractId = nil

	if gCS.LuaUtils.IsBaseUnitValid(playerUnit) and gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
		local multiInteractType = actionItemCfg.MultiInteractType
		result, multiInteractId = L18.Gameplay.MotionActionManager.Instance:TryMultiInteract(multiInteractType, playerUnit, npcUnit, 0)

		if result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.Success then
			return true, multiInteractId
		end
	end

	gCharMotionUtils.ShowMultiActionFailTips(id, result)

	return false
end

M.TryGetMultiInteractPosAndDir = function(id, playerUnit, npcUnit)
	local result = nil

	if gCS.LuaUtils.IsBaseUnitValid(playerUnit) and gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		local actionItemCfg = LTConfig.ActionItemConfig.GetConfig(id)
		local multiInteractType = actionItemCfg.MultiInteractType
		result = L18.Gameplay.MotionActionManager.Instance:TryGetMultiInteractPosAndDir(multiInteractType, playerUnit, npcUnit)

		if result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.Success then
			return true
		end
	end

	gCharMotionUtils.ShowMultiActionFailTips(id, result)
end

M.ShowMultiActionFailTips = function(id, result)
	if result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfSpace then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.NoEnoughSpaceMessage)
		print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，没有足够空间"):format(id, result))
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ActionItemConfig.CanNotDoubleInteract)

		if result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfUnit then
			print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，缺少主角或NPC"):format(id, result))
		elseif result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.LackOfConfig then
			print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，找不到配置表项，可能是角色体型不匹配"):format(id, result))
		elseif result ~= AetherAI.Systems.InteractionSystem.MultiInteractCheckResult.UnReachable then
			print_debug(("交互动作:ActionId:%d_交互返回失败result：%d，不可到达"):format(id, result))
		elseif result then
			print_debug(("交互动作:ActionId:%d_交互返回失败result：%s"):format(id, result))
		else
			print_debug(("交互动作:ActionId:%d_交互返回失"):format(id))
		end
	end
end

M.OpenCharMotionPanel = function(self, npcId, agentId)
	local npcUnit = gCS.SceneDataMgr.GetUnit(agentId)

	gMainPhoneFunctionAction.OpenCharMotionPanel({
		showType = LTConfig.ActionItemTabConfig.ShowTypeType.Interaction,
		npcId = npcUnit.NpcId,
		npcUnit = npcUnit,
		npcPid = agentId
	})
end

gCharMotionUtils = M
