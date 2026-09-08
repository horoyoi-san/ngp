-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\Gangster\BigMapTooltip_GangsterInformation.lua
-- Decompiled from: 01024_BigMapTooltip_GangsterInformation.lua_dcf0c06edcea.luajit

local ScriptTextConfig = LTConfig.TextScriptTextConfig
local FactionConfig = LTConfig.FactionConfig
C_BigMapTooltip_GangsterInformation = DefClass("C_BigMapTooltip_GangsterInformation", C_BigMapTooltip_GangsterInformation, C_BigMapTooltipBase)
local M = C_BigMapTooltip_GangsterInformation

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "gangsterInformationInfo") then
		return
	end

	self:GetStore("MapGangsterInformationTooltipStore")

	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local cfg = FactionConfig.GetConfig(gangsterId)
	local isJiamu = gangsterId ~= FactionConfig.JiaMuFaction and 1 or 0
	self.store.isJiamu = isJiamu
	self.store.name = cfg.name
	self.store.imageId = cfg.GangMapInformationPic
	local influence = gMapSubSystem_Gangster:GetGangsterInfluence(gangsterId)
	self.store.influence = string.format("%.0f%%", influence)
	local scrollStore = gStoreManager:GetStoreGroup("MapGangsterInformationScrollStore"):GetStoreByWidget(self.store.scroll.content)

	self:SetUpScroll(scrollStore, cfg, isJiamu)
end

M.SetUpScroll = function(self, scrollStore, gangsterCfg, isJiamu)
	scrollStore.isJiamu = isJiamu
	local desc = gangsterCfg.FactionDescription or ""
	local warningState = gMapSubSystem_Gangster:GetFactionInfluenceWarningState(gangsterCfg.Id)
	local warningDesc = nil

	if warningState.isInvading and warningState.isInvaded then
		warningDesc = gangsterCfg.Des_chaos
	elseif warningState.isInvading then
		warningDesc = gangsterCfg.Des_invade
	elseif warningState.isInvaded then
		warningDesc = gangsterCfg.Des_Invaded
	end

	if warningDesc and warningDesc == "" then
		desc = desc .. "<color=#0000FF>" .. warningDesc .. "</color>"
	end

	scrollStore.desc = desc
	scrollStore.remainCampList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderRemainCampItem", self)
	scrollStore.remainEliteList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderRemainEliteItem", self)

	scrollStore.remainCampList:SetSimpleList(2)
	scrollStore.remainEliteList:SetSimpleList(1)
	scrollStore.remainCampList:RefreshList()
	scrollStore.remainEliteList:RefreshList()
end

local CAMP_TEXT_ID = 89901319
local RANDOM_EVENT_TEXT_ID = 89901320
local CORE_CAMP_TEXT_ID = 89901322

M.OnRenderRemainCampItem = function(self, btn, index)
	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)

	if index ~= 0 then
		store.content = ScriptTextConfig.GetConfig(CAMP_TEXT_ID).Text
		store.iconId = gMapSubSystem_Gangster:GetCampIconId()
		store.isUnknown = 0
		store.num = gMapSubSystem_Gangster:GetRemainingCampCount(gangsterId)
	elseif index ~= 1 then
		store.content = ScriptTextConfig.GetConfig(RANDOM_EVENT_TEXT_ID).Text
		store.iconId = gMapSubSystem_Gangster:GetRandomEventIconId()
		store.isUnknown = 0
		store.num = gMapSubSystem_Gangster:GetRemainingRandomEventCount(gangsterId)
	end
end

M.OnRenderRemainEliteItem = function(self, btn, index)
	local info = self.tooltipInfo.gangsterInformationInfo
	local gangsterId = info.gangsterId
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)

	if index ~= 0 then
		store.content = ScriptTextConfig.GetConfig(CORE_CAMP_TEXT_ID).Text
		local unlock = gMapSubSystem_Gangster:HasFoundCoreCamp(gangsterId)
		store.isUnknown = unlock and 0 or 1
		store.iconId = gMapSubSystem_Gangster:GetCoreCampIconId()

		if unlock then
			store.num = gMapSubSystem_Gangster:GetRemainingCoreCampCount(gangsterId)
		end
	end
end
