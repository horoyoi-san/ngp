C_ChaosGachaOneResultPanelStore = DefClass("C_ChaosGachaOneResultPanelStore", C_ChaosGachaOneResultPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaOneResultPanelStore = C_ChaosGachaOneResultPanelStore
local M = C_ChaosGachaOneResultPanelStore

function M:ctor()
	return
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
	return
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
	self.panelId = panelId
	local gachaTemplate = gStoreManager:GetStoreGroup("ChaosGachaTemplate"):GetStoreByWidget(self.bindData.gachaTemplate)
	local gachaItemId = data[1]
	local gachaItemCfg = LTConfig.ChaosMastergachalistConfig.GetConfig(gachaItemId)
	local limboChaId = gachaItemCfg.LimboChaId
	local limboChaCfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(limboChaId)
	gachaTemplate.iconId = limboChaCfg.Icon
	gachaTemplate.qualityCtrl = gachaItemCfg.Quality - 1
	local imageScaleOffset = limboChaCfg.ImageScaleOffset or {
		1,
		0,
		0
	}
	local scale = imageScaleOffset[1] or 1
	local offsetX = imageScaleOffset[2] or 0
	local offsetY = imageScaleOffset[3] or 0
	gachaTemplate.imageRect.localPosition = Vector3.New(offsetX, offsetY, 0)
	gachaTemplate.imageRect.localScale = Vector3.New(scale, scale, 1)
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

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.gachaTemplate.luaClick = self:CreateAction("OnClickGachaTemplate")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.panelId)
end

function M:OnClickGachaTemplate()
	return
end
