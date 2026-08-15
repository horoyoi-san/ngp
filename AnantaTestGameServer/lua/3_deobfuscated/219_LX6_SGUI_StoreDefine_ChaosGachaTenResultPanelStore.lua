C_ChaosGachaTenResultPanelStore = DefClass("C_ChaosGachaTenResultPanelStore", C_ChaosGachaTenResultPanelStore, C_StoreGroup)
GroupName2Class.ChaosGachaTenResultPanelStore = C_ChaosGachaTenResultPanelStore
local M = C_ChaosGachaTenResultPanelStore

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

	for i = 1, 10 do
		local gachaTemplate = gStoreManager:GetStoreGroup("ChaosGachaTemplate"):GetStoreByWidget(self.bindData["gachaTemplate" .. i])

		if gachaTemplate then
			local gachaItemId = data[i]
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
	end
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
	self.bindData.gachaTemplate1.luaClick = self:CreateAction("OnClickGachaTemplate1")
	self.bindData.gachaTemplate2.luaClick = self:CreateAction("OnClickGachaTemplate2")
	self.bindData.gachaTemplate3.luaClick = self:CreateAction("OnClickGachaTemplate3")
	self.bindData.gachaTemplate4.luaClick = self:CreateAction("OnClickGachaTemplate4")
	self.bindData.gachaTemplate5.luaClick = self:CreateAction("OnClickGachaTemplate5")
	self.bindData.gachaTemplate6.luaClick = self:CreateAction("OnClickGachaTemplate6")
	self.bindData.gachaTemplate7.luaClick = self:CreateAction("OnClickGachaTemplate7")
	self.bindData.gachaTemplate8.luaClick = self:CreateAction("OnClickGachaTemplate8")
	self.bindData.gachaTemplate9.luaClick = self:CreateAction("OnClickGachaTemplate9")
	self.bindData.gachaTemplate10.luaClick = self:CreateAction("OnClickGachaTemplate10")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.panelId)
end

function M:OnClickGachaTemplate1()
	return
end

function M:OnClickGachaTemplate2()
	return
end

function M:OnClickGachaTemplate3()
	return
end

function M:OnClickGachaTemplate4()
	return
end

function M:OnClickGachaTemplate5()
	return
end

function M:OnClickGachaTemplate6()
	return
end

function M:OnClickGachaTemplate7()
	return
end

function M:OnClickGachaTemplate8()
	return
end

function M:OnClickGachaTemplate9()
	return
end

function M:OnClickGachaTemplate10()
	return
end
