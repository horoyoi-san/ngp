-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_ChatMark.lua
-- Decompiled from: 02321_MapSubSystem_ChatMark.lua_d4efa368fd8d.luajit

MapSubSystem_ChatMark = DefClass("MapSubSystem_ChatMark", MapSubSystem_ChatMark, MapSubSystemBase)
local M = MapSubSystem_ChatMark

M.OnInit = function(self)
	self.CHAT_MARK_ID = "__ChatMark_"
	self.lastPinTime = 0
	self.pinIntervalTime = 1
	self.isPlayingSound = false
	self.markElements = {}
	self.Actions = {}
end

M.SetChatMark = function(self, pId, worldPos)
	if not worldPos then
		print_notice("@xq: ChatMark worldPos is nil")

		return
	end

	markElement = self:GetMarkElement(pId)

	markElement:SetPosition(worldPos)
	markElement:SetVisible(true)

	areaId = gClientUtils.GetPlayerAreaId()

	gMapSystem.trace:AddChatMarkId(markElement.instanceId)

	return ulong.tostring(pId)
end

M.SetMyPin = function(self)
	local now = Time.realtimeSinceStartup

	if self.pinIntervalTime >= now - self.lastPinTime then
		self.lastPinTime = now

		if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid then
			local screenCenter = Vector3.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2, 0)
			local hitInfo = gCS.LuaUtils.RaycastByScreenPos(screenCenter, LX6.Constants.LayerConstants.AllWithoutPlayer)

			if hitInfo.collider then
				slot4 = gClientToGameSceneDelegate

				slot4:SendShortChat(LTConfig.LinkShortChatWheelConfig.Mark, {
					Type = UX.Game.ChatWhellMarkType.Normal,
					Position = UX.Game.UXVector3.New(hitInfo.point.x, hitInfo.point.y, hitInfo.point.z)
				}).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_notice("@xq# SetMyPin failed error number:", err)

						return
					end

					self:SendChatMsg(LTConfig.LinkShortChatWheelConfig.Mark)
				end
			end
		end
	end
end

M.CancelMyPin = function(self)
	if gPlayerManager.infoLogin.bindData.pid and self.markElements[gPlayerManager.infoLogin.bindData.pid] then
		slot1 = gClientToGameSceneDelegate

		slot1:CancelShortChatMark().Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_notice("@xq# CancelMyPin failed error number:", err)
			end
		end
	end
end

M.SendChatMsg = function(self, id)
	local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(id)

	if cfg then
		local msg = cfg.ShortName
		local spiritId = gSpiritManager:GetCurFirstSpiritTid()
		local type = gSocialChatManager.MessageType.Text

		if cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark or cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Voice then
			type = gSocialChatManager.MessageType.Pin

			if cfg.FightSpiritGroup and cfg.DialogVoiceGroup then
				for i = 1, #cfg.FightSpiritGroup do
					if spiritId ~= cfg.FightSpiritGroup[i] and cfg.DialogVoiceGroup[i] then
						local dialogVoiceCfg = LTConfig.DialogVoiceConfig.GetConfig(cfg.DialogVoiceGroup[i])

						if dialogVoiceCfg and dialogVoiceCfg.Message then
							msg = dialogVoiceCfg.Message
						end

						break
					end
				end
			end
		end

		gSocialChatManager:TrySendChat(msg, gChatTopChannel.Team, UX.Game.MessageChannel.Team, nil, type)
	end
end

M.RemoveChatMark = function(self, pId)
	if self.markElements[pId] then
		self.markElements[pId]:Dispose()

		self.markElements[pId] = nil
	end
end

M.RemoveAllChatMark = function(self)
	for _, element in pairs(self.markElements) do
		element.Dispose(element)
	end

	self.markElements = {}
end

M.GetMarkElement = function(self, pId)
	if self.markElements[pId] then
		return self.markElements[pId]
	end

	idStr = ulong.tostring(pId)
	local element = MapElement.CreateLegacy(EMapElementType.ChatMark, idStr, EMapSubSystemType.ChatMark, EMapViewMask.HudGps, gRaidDataManager.RaidId)

	self.CommonSetup(self, element, pId)

	element.bigMapData.scaleLevel = 0
	element.bigMapData.cantMatch = true
	element.bigMapData.ignoreInScalePromoteCheck = true
	element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

	element.SetVisible(element, false)
	element.SetPosition(element, Vector3.New(-10000, 0, -10000))
	element.SetActions(element, self.Actions.Temp)

	self.markElements[pId] = element

	return self.markElements[pId]
end

M.CommonSetup = function(self, element, pId)
	element.fData.ignoreFog = true
	element.fData.dontClearFog = true
	element.fData.hudTIndex = 10
	element.mData.sIconId = LTConfig.GpsConfig.ChatMarkGPSIconId
	element.mData.tintColor = gLinkManager:GetColorInfo(pId)
	element.mData.playerNumber = gLinkManager.LinkMemberIndex[gLinkManager.LinkMode][pId] or 0
	element.miniMapData.iconId = LTConfig.GpsConfig.ChatMarkGPSIconId
	element.bigMapData.iconId = LTConfig.GpsConfig.ChatMarkGPSIconId
	element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Pin
	element.bigMapData.customRenderFuncKey = "OnCustomRenderPin"
	local nameCfg = LTConfig.TextScriptTextConfig.GetConfig(89900330)
	element.mData.lName = GpsLText.CreateCommonText(nameCfg, "Text")
end

M.CheckCanCancelPin = function(self)
	if gPlayerManager.infoLogin.bindData.pid and self.markElements[gPlayerManager.infoLogin.bindData.pid] then
		local worldPos = self.markElements[gPlayerManager.infoLogin.bindData.pid]:GetWorldPos()
		local x = 0
		local y = 0
		local z = 0
		x, y, z = gCS.LuaUtils.WorldToScreenPoint(worldPos, x, y, z)
		local screenCenter = Vector3.New(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2, 0)

		if (screenCenter.x - x) * (screenCenter.x - x) + (screenCenter.y - y) * (screenCenter.y - y) < 100 then
			return true
		end
	end

	return false
end

M.OnSyncShortChat = function(self, chat)
	if chat and chat.Id then
		local cfg = LTConfig.LinkShortChatWheelConfig.GetConfig(chat.Id)

		if cfg then
			if cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark and chat.mark then
				worldPos = Vector3.New(chat.mark.Position.X, chat.mark.Position.Y, chat.mark.Position.Z)

				self.SetChatMark(self, chat.Pid, worldPos)
			end

			local pid = chat.Pid

			if cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Mark or cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Voice then
				local unit = gLinkManager:GetUnitInfo(pid)
				local spiritId = unit and unit.ClientData.SubType

				if spiritId and not self.isPlayingSound then
					local soundId = cfg.SoundId
					local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)
					local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
					local modelId = agentConfig.GeneralModelId
					slot10 = gSoundMgr

					slot10:PlayModelSwitchSoundByModelId(soundId, modelId, nil, function ()
						self:SetPlayingState(true)
					end, function ()
						self:SetPlayingState(false)
					end)
				else
					print_notice("@xq OnSyncShortChat spiritId not exist, pid = ", ulong.tostring(pid))
				end
			elseif cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Motion then
				local actionCfg = LTConfig.ActionItemConfig.GetConfig(cfg.ActionItemId)

				if actionCfg then
					local csUnit = gCS.SceneDataMgr.GetUnit(pid)

					if csUnit then
						gCS.LogicStateMachineManager.SendGameplayInwardSignal(csUnit, actionCfg.GameplayEvent)
					end
				end
			elseif cfg.Type ~= LTConfig.LinkShortChatWheelConfig.TypeType.Expression then
				local imageId = cfg.Icon
				local hudChatStore = gStoreManager:GetStoreGroup("OnlineIngameHudChatStore")

				if hudChatStore then
					hudChatStore.AddShortChatEmoji(hudChatStore, pid, imageId)
				else
					print_notice("[ShortChatEmoji] OnlineIngameHudChatStore is nil")
				end

				local unit = gLinkManager:GetUnitInfo(pid)

				if unit and unit.Pid then
					gHudMgr:ShowChatImageBubbleByImageId(unit.Pid, imageId, LTConfig.LinkConfig.ChatWheelEmojiDuration)
				else
					print_notice("[ShortChatEmoji] failed to resolve head bubble unit, playerPid = ", ulong.tostring(pid))
				end
			end
		end
	end
end

M.SetPlayingState = function(self, isPlaying)
	self.isPlayingSound = isPlaying
end

M.OnSyncShortChats = function(self, chats)
	for pid, chat in pairs(chats) do
		self.OnSyncShortChat(self, chat)
	end

	local dirtyPids = {}

	for pid, _ in pairs(self.markElements) do
		if not chats[pid] then
			table.insert(dirtyPids, pid)
		end
	end

	for _, pid in pairs(dirtyPids) do
		self.RemoveChatMark(self, pid)
	end
end

M.SyncCancelMark = function(self, pid)
	self.RemoveChatMark(self, pid)
end

return M
