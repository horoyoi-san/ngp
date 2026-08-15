C_UrbanAbilityLUExpTipsStore = DefClass("C_UrbanAbilityLUExpTipsStore", C_UrbanAbilityLUExpTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityLUExpTipsStore = C_UrbanAbilityLUExpTipsStore
local M = C_UrbanAbilityLUExpTipsStore

function M:ctor()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.spiritId = args.spiritId
	self.info = args.info
	self.lastInfo = args.lastInfo

	self:InitView()
	self:SetData()
end

function M:InitView()
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end

	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(3)
		gPanelManager:Close(self.panelId)
	end)
end

function M:SetData()
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(self.info.TemplateId)

	if not aCfg then
		return
	end

	self.bindData.title = aCfg.Name
	self.bindData.abilityIcon = aCfg.Icon
	self.bindData.rise = " + " .. self.info.Exp - self.lastInfo.Exp
	local maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(self.info.TemplateId)
	self.bindData.progressText = self.info.Exp .. "/" .. maxExp
end

function M:OnClose()
	return
end
