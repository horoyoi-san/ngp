local ScriptTextConfig = LTConfig.TextScriptTextConfig
C_BigMapTooltip_GangsterInformation = DefClass("C_BigMapTooltip_GangsterInformation", C_BigMapTooltip_GangsterInformation, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterInformation

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("gangsterInformationInfo") then
		return
	end

	self:GetStore("MapGangsterInformationTooltipStore")

	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local cfg = LTConfig.FactionConfig.GetConfig(gangsterId)
	self.store.name = cfg.name
	self.store.imageId = cfg.GangMapInformationPic
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterInformationScrollStore"):GetStoreByWidget(self.store.scroll.content)

	self:SetUpScroll(scrollStore, cfg)
end

function M:SetUpScroll(scrollStore, gangsterCfg)
	scrollStore.desc = gangsterCfg.FactionDescription or ""
	local influence = gMapSubSystem_Gangster:GetGangsterInfluence(gangsterCfg.Id)
	scrollStore.influence = string.format("%.0f%%", influence)
	scrollStore.remainCampList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderRemainCampItem", self)
	scrollStore.remainEliteList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderRemainEliteItem", self)

	scrollStore.remainCampList:SetSimpleList(2)
	scrollStore.remainEliteList:SetSimpleList(1)
end

local CAMP_TEXT_ID = 89901319
local RANDOM_EVENT_TEXT_ID = 89901320
local ELITE_TEXT_ID = 89901321
local CORE_CAMP_TEXT_ID = 89901322

function M:OnRenderRemainCampItem(btn, index)
	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)

	if index == 0 then
		store.content = ScriptTextConfig.GetConfig(CAMP_TEXT_ID).Text
		store.iconId = gMapSubSystem_Gangster:GetCampIconId()
		store.isUnknown = 0
		store.num = gMapSubSystem_Gangster:GetRemainingCampCount(gangsterId)
	elseif index == 1 then
		store.content = ScriptTextConfig.GetConfig(RANDOM_EVENT_TEXT_ID).Text
		store.iconId = gMapSubSystem_Gangster:GetRandomEventIconId()
		store.isUnknown = 0
		store.num = gMapSubSystem_Gangster:GetRemainingRandomEventCount(gangsterId)
	end
end

function M:OnRenderRemainEliteItem(btn, index)
	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)

	if index == 0 then
		store.content = ScriptTextConfig.GetConfig(CORE_CAMP_TEXT_ID).Text
		local unlock = gMapSubSystem_Gangster:HasFoundCoreCamp(gangsterId)
		store.isUnknown = unlock and 0 or 1
		store.iconId = gMapSubSystem_Gangster:GetCoreCampIconId()

		if unlock then
			store.num = gMapSubSystem_Gangster:GetRemainingCoreCampCount(gangsterId)
		end
	end
end
