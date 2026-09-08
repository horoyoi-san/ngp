-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\FactionManager.lua
-- Decompiled from: 02220_FactionManager.lua_7eb0a9d907d0.luajit

local PopupConfig = LTConfig.PopupConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local StaticProps = {}
C_FactionManager = DefClass("C_FactionManager", C_FactionManager, nil, StaticProps)
local M = C_FactionManager

M.ctor = function(self)
	self.panelCloseHandler = function(eventId, panelId)
		self:OnCloseFactionMap(eventId, panelId)
	end
end

M.ChangeShowPopup = function(self, isShow)
	self.isShowPopup = isShow
end

M.OnFactionChange = function(self, factionId, info, oldInfo, dropTextId)
	gPlayerManager.infoAchievement.bindData.FactionInfoDic[factionId] = info

	self:OnDispostionChange(factionId, info, oldInfo, dropTextId)
	self:OnInfulunceChange(factionId, info, oldInfo)
end

M.OnFactionsChange = function(self, changeInfos, dropTextId)
	local dispostionAddition = 0
	local levelChanged = false
	local factionIds = {}

	for i = 1, #changeInfos do
		local factionId = changeInfos[i].FactionId
		local info = changeInfos[i].NewInfo
		local oldInfo = changeInfos[i].OldInfo
		gPlayerManager.infoAchievement.bindData.FactionInfoDic[factionId] = info
		local currentLevelChange = oldInfo.DispositionLevel == info.DispositionLevel

		if not currentLevelChange then
			dispostionAddition = dispostionAddition + info.Disposition - oldInfo.Disposition
		else
			local popupParam = {
				FactionId = {
					factionId
				},
				Disposition = dispostionAddition,
				clv = oldInfo.DispositionLevel,
				nlv = info.DispositionLevel,
				textId = dropTextId
			}

			gNewPopupManager:PushPopup(PopupConfig.S_PowerMapHUD, popupParam)
		end

		levelChanged = levelChanged or currentLevelChange

		if currentLevelChange then
			gMessageManager:SendMessage(gEventConstants.FACTION_LEVEL_CHANGE, factionId)
		end

		gMessageManager:SendMessage(gEventConstants.FACTION_INFO_CHANGE, factionId)

		factionIds[i] = factionId
	end

	local popupParam = {
		FactionId = factionIds,
		Disposition = dispostionAddition,
		textId = dropTextId
	}

	if dispostionAddition == 0 then
		gNewPopupManager:PushPopup(PopupConfig.FactionChange, popupParam)
	end
end

M.OnDispostionChange = function(self, factionId, info, oldInfo, dropTextId)
	local dispostionAddition = info.Disposition - oldInfo.Disposition

	if dispostionAddition == 0 then
		local levelChanged = oldInfo.DispositionLevel == info.DispositionLevel
		local popupParam = {
			FactionId = {
				factionId
			},
			Disposition = dispostionAddition,
			clv = oldInfo.DispositionLevel,
			nlv = info.DispositionLevel,
			textId = dropTextId
		}

		if levelChanged then
			gNewPopupManager:PushPopup(PopupConfig.S_PowerMapHUD, popupParam)
			gMessageManager:SendMessage(gEventConstants.FACTION_LEVEL_CHANGE, factionId)
		else
			gNewPopupManager:PushPopup(PopupConfig.FactionChange, popupParam)
		end

		gMessageManager:SendMessage(gEventConstants.FACTION_INFO_CHANGE, factionId)
	end
end

M.OnInfulunceChange = function(self, factionId, info, oldInfo)
end

M.OpenFactionMap = function(self)
	if self.showMap then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = true

	gMapUtils:CheckRaidCanOpenMap({
		["\\x995#+q\\x92O\\xf48\\xae\\xbc"] = true
	})
end

M.OpenFactionMapWithSelection = function(self, factionId)
	if self.showMap then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = true

	gMapUtils:CheckRaidCanOpenMap({
		["\\x995#+q\\x92O\\xf48\\xae\\xbc"] = true,
		autoSelectFactionId = factionId
	})
end

M.OnCloseFactionMap = function(self, eventId, panelId)
	if panelId == gPanelId.S_NEW_MAP_PANEL then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = false
end

gFactionManager = gFactionManager or C_FactionManager.new()
