-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeCategoryBigTemplateStore.lua
-- Decompiled from: 01563_BaikeCategoryBigTemplateStore.lua_92438658583d.luajit

C_BaikeCategoryBigTemplateStore = DefClass("C_BaikeCategoryBigTemplateStore", C_BaikeCategoryBigTemplateStore, C_StoreGroup)
GroupName2Class.BaikeCategoryBigTemplateStore = C_BaikeCategoryBigTemplateStore
local M = C_BaikeCategoryBigTemplateStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.button.luaClick = self:CreateAction("OnClick")
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction

	self:InitMessages()
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.ON_CLOSE_BAIKE_MAIN_POP_UP] = self.CreateAction(self, "OnClosePopUp")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnClick = function(self)
	self.bindData.button:CloseTooltip(true)

	if self.onClickCallback then
		self.onClickCallback()
	end
end

M.OnShow = function(self, _, _)
	if self.onShowCallback then
		self.onShowCallback()
	end
end

M.RefreshView = function(self, cityPediaFirstClassId, parentButton, ignoreOpenAnimation, currentPoint, totalPoint, currentCount, totalCount)
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

	self.bindData.pointTemplate.gameObject:SetActive(false)
end

M.OnClosePopUp = function(self)
	SGUI.UButton.CloseTooltip(self.rootGo:GetInstanceID(), false)
end

M.OnRenderRedDot = function(self, redKey, templateKey, widget)
	if redKey ~= self.redDotKey then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

		if store then
			store.num = gBaiKeArchiveManager.GetCityPediaFisrtClassRedDotCount(self.cityPediaFirstClassId)
		end
	end
end

M.OnDestroy = function(self)
	if self.closeCallback then
		self.closeCallback()
	end

	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction

	self.ClearMessageEvents(self)

	self.callback = nil
	self.redDotKey = nil
	self.onShowCallback = nil
	self.onClickCallback = nil
end
