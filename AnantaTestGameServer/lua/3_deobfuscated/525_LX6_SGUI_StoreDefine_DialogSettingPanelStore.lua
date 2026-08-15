local DialogSettingNameConfig = LTConfig.DialogSettingNameConfig
C_DialogSettingPanelStore = DefClass("C_DialogSettingPanelStore", C_DialogSettingPanelStore, C_StoreGroup)
GroupName2Class.DialogSettingPanelStore = C_DialogSettingPanelStore
local M = C_DialogSettingPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	return
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
	data = data:ToTable()
	self.dialogId = data.dialogId
	self.playSpeedIndex = data.playSpeedIndex
	self.autoPlay = data.playSpeedIndex ~= 0
	self.savedAutoPlay = self.autoPlay
	self.autoBranch = data.autoBranch
	self.bindData.closeBtn = self:CreateAction("OnClosePanel")
	self.bindData.settingList.luaSimpleRenderItem = self:CreateAction("OnRenderSettingItem")
	self.bindData.settingList.onGetTIndex = self:CreateAction("OnGetTIndex")

	self:RefreshPanel()
	gMessageManager:SendMessage(gEventConstants.DIALOG_REVIEW_PANEL_STATE, 1)
end

function M:OnClose()
	gMessageManager:SendMessage(gEventConstants.DIALOG_REVIEW_PANEL_STATE, 2)

	if self.autoPlay ~= self.savedAutoPlay then
		gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
			type = 5,
			dialogId = self.dialogId
		})
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnClosePanel()
	gPanelManager:Close(gPanelId.S_DIALOG_SETTING)
end

function M:AddSetting(tIndex, text, callback, enable, order, showButton, interactable)
	local view = {
		tIndex = tIndex,
		text = text,
		onOffBtn = callback,
		onOff = enable,
		order = order,
		showButton = showButton,
		interactable = interactable
	}

	table.insert(self.settingViews, view)
end

function M:OnAutoClick()
	self.autoPlay = not self.autoPlay

	self:RefreshPanel()
end

function M:OnAutoBranchClick()
	self.autoBranch = not self.autoBranch

	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 7,
		dialogId = self.dialogId
	})
	self:RefreshPanel()
end

function M:CreateActionByKey(key)
	if key == "Auto" then
		return self:CreateAction("OnAutoClick")
	elseif key == "AutoBranch" then
		return self:CreateAction("OnAutoBranchClick")
	else
		print_error("尚未支持该表示符，需要添加请联系wulingyu01,Key=" .. key)
	end
end

function M:GetEnableByKey(key)
	if key == "Auto" then
		return self.autoPlay
	elseif key == "AutoBranch" then
		return self.autoBranch
	end
end

function M:CheckShowCondition(id, visit)
	if id == 0 then
		return true
	end

	if visit[id] then
		print_error("检查Dialog.SettingName表，关联节点存在循环")

		return false
	end

	visit[id] = true
	local cfg = DialogSettingNameConfig.GetConfig(id)

	if cfg == nil then
		print_error("检查Dialog.SettingName表，关联节点不存在，id=" .. id)

		return false
	end

	if cfg.ShowButton and not self:GetEnableByKey(cfg.Key) then
		return false
	end

	return self:CheckShowCondition(cfg.ShowCondition, visit)
end

function M:CheckEnableCondition(id)
	if id == 0 then
		return true
	end

	local cfg = DialogSettingNameConfig.GetConfig(id)

	if cfg == nil then
		print_error("检查Dialog.SettingName表，关联节点不存在，id=" .. id)

		return true
	end

	if cfg.ShowButton and not self:GetEnableByKey(cfg.Key) then
		return false
	end

	return true
end

function M:RefreshPanel()
	local count = DialogSettingNameConfig.count

	for i = 0, count - 1 do
		local cfg = DialogSettingNameConfig.GetConfigValueByIndex(i)

		if (cfg.ShowCondition == 0 or self:CheckShowCondition(cfg.ShowCondition, {})) and cfg.ShowButton then
			local enable = self:GetEnableByKey(cfg.Key)
			local interactable = self:CheckEnableCondition(cfg.EnableCondition)
			local clickAction = self:CreateActionByKey(cfg.Key)

			if enable and not interactable then
				clickAction()
			end
		end
	end

	self.settingViews = {}

	for i = 0, count - 1 do
		local cfg = DialogSettingNameConfig.GetConfigValueByIndex(i)

		if cfg.ShowCondition == 0 or self:CheckShowCondition(cfg.ShowCondition, {}) then
			if cfg.ShowButton then
				local enable = self:GetEnableByKey(cfg.Key)
				local interactable = self:CheckEnableCondition(cfg.EnableCondition)
				local clickAction = self:CreateActionByKey(cfg.Key)

				self:AddSetting(cfg.Style, cfg.Name, clickAction, enable, cfg.Order, true, interactable)
			else
				self:AddSetting(cfg.Style, cfg.Name, nil, nil, cfg.Order, false, false)
			end
		end
	end

	table.sort(self.settingViews, function (a, b)
		return a.order < b.order
	end)
	self.bindData.settingList:SetSimpleList(#self.settingViews)
end

function M:OnRenderSettingItem(setting, index)
	local store = gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(setting)

	if not store then
		return
	end

	local data = self.settingViews[index + 1]
	store.text = data.text
	store.btnHide = data.showButton and 0 or 1

	if data.showButton then
		store.onOffBtn.luaClick = data.onOffBtn
		store.onOffBtn.isSelected = data.onOff
		store.onOffBtn.interactable = data.interactable
	end
end

function M:OnGetTIndex(index)
	local luaIndex = index + 1

	if luaIndex < #self.settingViews then
		return self.settingViews[luaIndex].tIndex
	else
		return 1
	end
end
