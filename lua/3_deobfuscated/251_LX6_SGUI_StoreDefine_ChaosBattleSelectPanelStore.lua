C_ChaosBattleSelectPanelStore = DefClass("C_ChaosBattleSelectPanelStore", C_ChaosBattleSelectPanelStore, C_StoreGroup)
GroupName2Class.ChaosBattleSelectPanelStore = C_ChaosBattleSelectPanelStore
local M = C_ChaosBattleSelectPanelStore
local ShowType = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	self.curChooseId = nil
	self.chaosUIlist = {}
	self.isStart = false
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.chaosUIlist[1] = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(self.bindData.chaos1)
	self.chaosUIlist[2] = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(self.bindData.chaos2)
	self.chaosUIlist[3] = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(self.bindData.chaos3)

	self:RefreshChaosList(true)

	self.isStart = true
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.curChooseId = 0

	if self.isStart then
		self:RefreshChaosList(true)
	end
end

function M:OnClose()
	return
end

function M:OnDestroy()
	self.isStart = false
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
	self.bindData.chaos1.luaClick = self:CreateActionWithArgs("OnClickChaos", 1)
	self.bindData.chaos2.luaClick = self:CreateActionWithArgs("OnClickChaos", 2)
	self.bindData.chaos3.luaClick = self:CreateActionWithArgs("OnClickChaos", 3)
end

function M:OnClickConfirmBtn(isEnd)
	if isEnd and not self.curChooseId then
		self.curChooseId = self.chaoslist[1].chaosData.Id
	end

	if not self.curChooseId then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ChaosMasterConfig.ChaosNotSelectMessage)

		return
	end
end

function M:OnGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId ~= 0 and data.iconId or nil
end

function M:OnClickChaos(data)
	local btn = self.bindData["chaos" .. data]
	local store = self.chaosUIlist[data]

	if store.deadCtrl == 0 then
		btn.isSelected = false

		return
	end

	self.curChooseId = store.chaosData.Id

	self:RefreshChaosList()
end

function M:OnUpdate()
	return
end

function M:RefreshChaosList(isFirst)
	if not gBattlePetsMgr.myChaosList or #gBattlePetsMgr.myChaosList == 0 then
		return
	end

	local chaosList = gBattlePetsMgr.myChaosList
	self.chaoslist = {}

	for i = 1, 3 do
		self.bindData["showChaos" .. i] = chaosList[i] ~= nil

		if chaosList[i] ~= nil then
			local item = self.chaosUIlist[i]
			local chaos = gBattlePetsMgr:GetPetDataById(chaosList[i].PokemonId)

			if chaos then
				local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(chaos.LimboChaId)
				local remainLife = chaosList[i].RemainDurability

				if isFirst and remainLife > 0 then
					self.curChooseId = chaos.Id
					isFirst = false
				end

				item.isEmptyCtrl = 0
				item.lihuiId = cfg.CardIcon
				item.name = cfg.Name
				item.cost = gBattlePetsMgr:GetChaosCost(chaos)
				item.deadCtrl = remainLife == 0 and 0 or 1
				item.cfg = cfg
				item.chaosData = chaos

				item.button:SetSelected(self.curChooseId == chaos.Id)

				item.button.interactable = remainLife > 0
				item.genreList.luaRenderItem = self:CreateAction("OnGenreRender")
				local list = {}

				for i = 1, #cfg.ChaosTag do
					table.insert(list, cfg.ChaosTag[i])
				end

				gBattlePetsMgr:RefreshGenreList(item.genreList, list)
			end
		end
	end
end
