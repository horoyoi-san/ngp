C_BaikeCategoryBigTemplateStore = DefClass("C_BaikeCategoryBigTemplateStore", C_BaikeCategoryBigTemplateStore, C_StoreGroup)
GroupName2Class.BaikeCategoryBigTemplateStore = C_BaikeCategoryBigTemplateStore
local M = C_BaikeCategoryBigTemplateStore
M.baikeType = {
	Text = 2,
	Vehicle = 4,
	Item = 0,
	Pets = 1,
	Fashion = 3
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.button.luaClick = self:CreateAction("OnClick")
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction

	self:InitMessages()
end

function M:InitMessages()
	local messageEvents = {
		[gEventConstants.ON_CLOSE_BAIKE_MAIN_POP_UP] = self:CreateAction("OnClosePopUp")
	}

	self:RegisterMessageEvents(messageEvents)
end

function M:OnClick()
	self.bindData.button:CloseTooltip(true)

	if self.onClickCallback then
		self.onClickCallback()
	end
end

function M:OnShow(_, _)
	if self.onShowCallback then
		self.onShowCallback()
	end
end

function M:RefreshView(cityPediaFirstClassId, parentButton, ignoreOpenAnimation, currentPoint, totalPoint, currentCount, totalCount)
	self.cityPediaFirstClassId = cityPediaFirstClassId
	local cityPediaFirstClassCfg = LTConfig.CityPediaFirstClassConfig.GetConfig(cityPediaFirstClassId)
	self.bindData.iconId = cityPediaFirstClassCfg.Image
	self.bindData.name = cityPediaFirstClassCfg.Name

	if currentCount and totalCount then
		self.bindData.current = currentCount
		self.bindData.total = totalCount
	else
		local current, total = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(cityPediaFirstClassId)
		self.bindData.current = current
		self.bindData.total = total
	end

	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaFirstClassHasRedDot(cityPediaFirstClassId)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaFirstClassRedDotKey(cityPediaFirstClassId)
	self.bindData.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	self.redDotKey = redDotKey

	self.bindData.button.transform:SetParent(parentButton.transform)

	local localPosition = self.bindData.button.transform.localPosition
	self.bindData.button.transform.localPosition = Vector3.Fetch(localPosition.x, localPosition.y, 0)
	self.bindData.button.transform.localScale = Vector3.one
	self.bindData.button.transform.anchoredPosition = Vector2.Fetch(self.bindData.button.transform.anchoredPosition.x, 0)

	self.bindData.pointTemplate.gameObject:SetActive(cityPediaFirstClassCfg.Type == self.baikeType.Fashion or cityPediaFirstClassCfg.Type == self.baikeType.Vehicle)

	self.bindData.pointText = currentPoint or gBaiKeArchiveManager.GetCityPediaCreditPoint(cityPediaFirstClassCfg.Type)
end

function M:OnClosePopUp()
	SGUI.UButton.CloseTooltip(self.rootGo:GetInstanceID(), false)
end

function M:OnRenderRedDot(redKey, templateKey, widget)
	if redKey == self.redDotKey then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetCityPediaFisrtClassRedDotCount(self.cityPediaFirstClassId)
		end
	end
end

function M:OnDestroy()
	if self.closeCallback then
		self.closeCallback()
	end

	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction

	self:ClearMessageEvents()

	self.callback = nil
	self.redDotKey = nil
	self.onShowCallback = nil
	self.onClickCallback = nil
end
