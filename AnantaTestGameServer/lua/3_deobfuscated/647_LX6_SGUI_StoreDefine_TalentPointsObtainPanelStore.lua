C_TalentPointsObtainPanelStore = DefClass("C_TalentPointsObtainPanelStore", C_TalentPointsObtainPanelStore, C_StoreGroup)
GroupName2Class.TalentPointsObtainPanelStore = C_TalentPointsObtainPanelStore
local M = C_TalentPointsObtainPanelStore

function M:ctor()
	self.areaIndex = 0
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	self.areaIndex = data.areaIndex
	self.bindData.countLabel = "+" .. data.addition
	self.bindData.headIcon = data.headId

	Timer.New(function ()
		if self.areaIndex then
			gPanelManager:Close(gPanelId.S_TALENT_POINTS_OBTAIN_PANEL)
		else
			gPanelManager:Close(gPanelId.S_TALENT_POINTS_OBTAIN_FRONT_PANEL)
		end
	end, 3):Start()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
