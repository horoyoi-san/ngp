local PopupConfig = LTConfig.PopupConfig
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local StaticProps = {}
C_FactionManager = DefClass("C_FactionManager", C_FactionManager, nil, StaticProps)
local M = C_FactionManager

function M:ctor()
	function self.panelCloseHandler(eventId, panelId)
		self:OnCloseFactionMap(eventId, panelId)
	end
end

function M:ChangeShowPopup(isShow)
	self.isShowPopup = isShow
end

function M:OnFactionChange(factionId, info, oldInfo, dropTextId)
	gPlayerManager.infoAchievement.bindData.FactionInfoDic[factionId] = info

	self:OnDispostionChange(factionId, info, oldInfo, dropTextId)
	self:OnInfulunceChange(factionId, info, oldInfo)
end

function M:OnFactionsChange(changeInfos, dropTextId)
	local dispostionAddition = 0
	local levelChanged = false
	local factionIds = {}

	for i = 1, #changeInfos do
		local factionId = changeInfos[i].FactionId
		local info = changeInfos[i].NewInfo
		local oldInfo = changeInfos[i].OldInfo
		gPlayerManager.infoAchievement.bindData.FactionInfoDic[factionId] = info
		local currentLevelChange = oldInfo.DispositionLevel ~= info.DispositionLevel

		if not currentLevelChange then
			dispostionAddition = dispostionAddition + info.Disposition - oldInfo.Disposition
		else
			local popupParam = {
				FactionId = factionId,
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

	if dispostionAddition ~= 0 then
		gNewPopupManager:PushPopup(PopupConfig.FactionChange, popupParam)
	end
end

function M:OnDispostionChange(factionId, info, oldInfo, dropTextId)
	local dispostionAddition = info.Disposition - oldInfo.Disposition

	if dispostionAddition ~= 0 then
		local levelChanged = oldInfo.DispositionLevel ~= info.DispositionLevel
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

function M:OnInfulunceChange(factionId, info, oldInfo)
	return
end

function M:ShowCampFinishPopup()
	gNewPopupManager:PushPopup(PopupConfig.S_HUDTipsPanel, {
		Param = {
			TipType = TaskTipsType.CampFinish
		}
	})
end

function M:OpenFactionMap()
	if self.showMap then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = true

	gMapUtils:CheckRaidCanOpenMap({
		factionMode = true
	})
end

function M:OpenFactionMapWithSelection(factionId)
	if self.showMap then
		return
	end

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = true

	gMapUtils:CheckRaidCanOpenMap({
		factionMode = true,
		autoSelectFactionId = factionId
	})
end

function M:OnCloseFactionMap(eventId, panelId)
	if panelId ~= gPanelId.S_NEW_MAP_PANEL then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseHandler)

	self.showMap = false
end

function M:TestInfluenceChange()
	local popupParam = {
		nInfluence = 100,
		cInfluence = 10,
		FactionId = 18000111
	}

	gNewPopupManager:PushPopup(PopupConfig.FactionInfluenceChange, popupParam)
end

function M:TestFaction(isLevelChange)
	local popupParam = {
		clv = 1,
		Disposition = 10,
		FactionId = {
			18000111
		},
		nlv = isLevelChange and 2 or 1
	}

	if isLevelChange then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_PowerMapHUD, popupParam)
	else
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.FactionChange, popupParam)
	end
end

gFactionManager = gFactionManager or C_FactionManager.new()
