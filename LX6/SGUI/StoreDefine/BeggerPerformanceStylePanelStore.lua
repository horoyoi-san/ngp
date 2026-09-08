-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggerPerformanceStylePanelStore.lua
-- Decompiled from: 02054_BeggerPerformanceStylePanelStore.lua_4bcfa547788b.luajit

C_BeggerPerformanceStylePanelStore = DefClass("C_BeggerPerformanceStylePanelStore", C_BeggerPerformanceStylePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BeggerPerformanceStylePanelStore = C_BeggerPerformanceStylePanelStore
local M = C_BeggerPerformanceStylePanelStore
local BeggarStyleConfig = LTConfig.BeggarStyleConfig

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.typeId = args.typeId
	self.check = false
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshPanelView(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BEGGAR_APP_CONTENT_CLOSE)
end

M.RegisterWidget = function(self)
	self.bindData.startBtn.luaClick = self.CreateAction(self, "OnClickStartBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.checkBox.luaClick = self.CreateAction(self, "OnClickCheckBox")
	self.bindData.typeList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTypeListItem")
	self.bindData.typeList.luaSelectedChanged = self.CreateAction(self, "OnTypeListSelectChanged")
end

M.OnClickStartBtn = function(self)
	local index = self.bindData.typeList.selectedIndex

	if index > 0 then
		local data = self.styleData[index + 1]

		if data then
			local valid = true

			if self.check then
				local curMoney = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)

				if curMoney >= LTConfig.BeggarConfig.PromotionCost then
					valid = false

					gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.BeggarMoneyNotEnough)
				end
			end

			if valid then
				gBeggarManager:OpenBeggarHudPanel(self.typeId, data, self.check)
				gMainPhoneUtils.CloseMainPhonePanel()
			end
		end
	end
end

M.OnTypeListSelectChanged = function(self, list)
	local index = list.selectedIndex
	self.bindData.startBtn.interactable = index < 0
end

M.OnClickCheckBox = function(self)
	self.check = not self.check
	self.bindData.selected = self.check and 1 or 0
end

M.OnSimpleRenderTypeListItem = function(self, btn, index)
	local data = self.styleData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = BeggarStyleConfig.GetConfig(data)

	if cfg then
		store.title = cfg.Name
	end
end

M.RefreshPanelView = function(self)
	self.styleData = gBeggarManager:GetBeggarStyleInfo(self.typeId)

	self.bindData.typeList:SetSimpleList(#self.styleData)

	self.bindData.selected = self.check and 1 or 0
	self.bindData.startBtn.interactable = false
end

M.ClearData = function(self)
end
