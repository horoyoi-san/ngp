C_BartenderInfoPanelStore = DefClass("C_BartenderInfoPanelStore", C_BartenderInfoPanelStore, C_StoreGroup)
GroupName2Class.BartenderInfoPanelStore = C_BartenderInfoPanelStore
local M = C_BartenderInfoPanelStore

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.leftBtn.luaClick = self:CreateAction("OnLeftBtnClick")
	self.bindData.rightBtn.luaClick = self:CreateAction("OnRightBtnClick")
end

function M:OnEnable()
	self.curIndex = 1

	self:GetMenuList()
	self:SetMenu()
end

function M:GetMenuList()
	self.menulist = {}

	for i = 0, LTConfig.BartenderDrinkMenuConfig.count - 1 do
		local cfg = LTConfig.BartenderDrinkMenuConfig.LoadAt(i)

		table.insert(self.menulist, cfg)
	end
end

function M:SetMenu()
	self.menucfg = self.menulist[self.curIndex]
	self.bindData.icon = self.menucfg.MenuImage
	self.store = gStoreManager:GetStoreGroup("BartenderProcedureTemplateStore"):GetStoreByWidget(self.bindData.menu)
	self.store.title = self.menucfg.DrinkMenuName
	self.store.des = self.menucfg.DrinkMenuDescription
	self.store.list.luaSimpleRenderItem = self:CreateAction("OnRenderMenuItem")
	self.menuList = {}

	for i, v in pairs(self.menucfg.MenuStep) do
		local info = {
			id = v,
			selected = false
		}

		table.insert(self.menuList, info)
	end

	self.store.list:SetSimpleList(#self.menuList)
end

function M:OnRenderMenuItem(btn, index)
	local store = gStoreManager:GetStoreGroup("BartenderListTemplateStore"):GetStoreByWidget(btn)
	store.check = 2
	local cfg = LTConfig.BartenderMenuStepConfig.GetConfig(self.menuList[index + 1].id)
	store.des.text = cfg.StepDescription
	store.must = 1
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_BARTENDER_INFO_PANEL)
	gPanelManager:Close(gPanelId.S_BARTENDER_INFO_PANEL)
end

function M:OnLeftBtnClick()
	if self.curIndex <= 1 then
		return
	end

	self.curIndex = self.curIndex - 1

	self:SetMenu()
end

function M:OnRightBtnClick()
	if self.curIndex >= #self.menulist then
		return
	end

	self.curIndex = self.curIndex + 1

	self:SetMenu()
end
