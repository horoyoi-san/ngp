-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovInfoPanelStore.lua
-- Decompiled from: 01586_AnantarkovInfoPanelStore.lua_cfd87bdbec25.luajit

C_AnantarkovInfoPanelStore = DefClass("C_AnantarkovInfoPanelStore", C_AnantarkovInfoPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovInfoPanelStore = C_AnantarkovInfoPanelStore
local M = C_AnantarkovInfoPanelStore
local shooterItemConfig = LTConfig.ExtractionShooterItemConfig

M.ctor = function(self)
	self.isVisible = false
	self.maxSize = 5
	self.maxCapacity = self.maxSize * self.maxSize
	self.row = 0
	self.column = 0
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPanel(self, true)
end

M.SetPanelVisible = function(self, visible, force)
	if self.isVisible == visible or force then
		self.bindData.panel:SetWidgetFaraway(not visible)

		self.bindData.tipsNum = visible and 1 or 0
		self.isVisible = visible
	end
end

M.RefreshPanel = function(self, force)
	local isShow, panelPos, id, stackCount, keyCardCtrl, keyRoomLeftTime = L50.Spoon.ExtractionShooterSceneItemModule.Instance:GetPanelDataInfo(self.bindData.rootTransform, Vector2.zero, 0, 0, 0, 0)

	if not isShow then
		self.SetPanelVisible(self, false, force)
	else
		self.SetPanelVisible(self, true, force)

		self.bindData.panelTransform.anchoredPosition = panelPos

		self.SetPanelData(self, id, stackCount, keyCardCtrl, keyRoomLeftTime)
	end
end

M.SetPanelData = function(self, id, stackCount, keyCardCtrl, keyRoomLeftTime)
	local config = shooterItemConfig.GetConfig(id)
	local typeId = config.Type
	local typeConfig = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(typeId)

	if typeConfig.ReadInfoType ~= LTConfig.ExtractionShooterItemTypeConfig.ReadInfoTypeType.SceneItem then
		local sceneItemConfig = LTConfig.SceneitemConfig.GetConfig(config.RealSceneItemModelId)

		if sceneItemConfig then
			self.bindData.sceneItemName = sceneItemConfig.Name
			self.bindData.imageUrl = gUIUtils:GetSguiImagePath(sceneItemConfig.WeaponConsumableIcon)
			self.bindData.qualityCtrl = sceneItemConfig.Quality
		end
	elseif typeConfig.ReadInfoType ~= LTConfig.ExtractionShooterItemTypeConfig.ReadInfoTypeType.Consumable then
		local consumableId = config.ConsumableId
		local consumableConfig = LTConfig.ConsumableConfig.GetConfig(consumableId)
		self.bindData.imageUrl = gUIUtils:GetSguiImagePath(consumableConfig.SItemIconId)
		self.bindData.sceneItemName = config.Name
		self.bindData.qualityCtrl = consumableConfig.Quality
	end

	self.bindData.isShowCount = stackCount <= 1 and 1 or 0
	self.bindData.numberText = tostring(stackCount)
	self.bindData.keyCardCtrl = keyCardCtrl
	self.bindData.keyCardTimeText = keyCardCtrl ~= 1 and keyRoomLeftTime <= 0 and gClientUtils.FormatTimeToMMSS(keyRoomLeftTime) or ""

	if self.row == config.Volume.x or self.column == config.Volume.y then
		self.column = config.Volume.y
		self.row = config.Volume.x

		self.SetListData(self, self.maxCapacity)
	end
end

M.OnCameraUpdate = function(self)
	self.RefreshPanel(self)
end

M.OnClose = function(self)
	self.isVisible = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.SetListData = function(self, count)
	self.bindData.list:SetSimpleList(count)

	for index = 0, count - 1 do
		local col = index / self.maxSize
		local row = index % self.maxSize

		if row >= self.row and col >= self.column then
			self.bindData.list:SetItemSelected(index, true)
		else
			self.bindData.list:SetItemSelected(index, false)
		end
	end
end
