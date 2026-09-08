-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideNewcomerModelStore.lua
-- Decompiled from: 01745_GuideNewcomerModelStore.lua_6b8f09a8d581.luajit

C_GuideNewcomerModelStore = DefClass("C_GuideNewcomerModelStore", C_GuideNewcomerModelStore, C_StoreGroup)
GroupName2Class.GuideNewcomerModelStore = C_GuideNewcomerModelStore
local M = C_GuideNewcomerModelStore

M.ctor = function(self)
	self.callback = nil
	self.isPrev = false
	self.currentConfigId = 0
	self.newbieData = nil
	self.optionListData = nil
	self.ShowType = {
		["\\xed\\xde\t6\\xf4"] = 1,
		["{\\xa7\\xa6\\xaa\\xb9"] = 2
	}
end

M.DefineAllVariables = function(self)
	self.callback = nil
	self.isPrev = false
	self.currentConfigId = 0
	self.newbieData = nil
	self.optionListData = {}
	self.currentIndex = 1
end

M.DefineAllEnumsAutoGen = function(self)
	self.showBackBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showBackBtnCtrlEnum = nil
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
	self.callback = data and data.callback or nil
	self.isPrev = false
	self.currentConfigId = data and data.id or 0
	self.newbieData = gGuideNewcomerMgr:BuildGuideNewbieData(self.currentConfigId)

	if not self.newbieData then
		print_error("GuideNewcomerModelStore OnShow newbieData is nil, configId=", self.currentConfigId)
		gPanelManager:Close(gPanelId.GUIDE_NEWCOMER_MODEL)

		return
	end

	if gGuideNewcomerMgr.currentIndex and gGuideNewcomerMgr.currentIndex ~= 1 then
		self.bindData.showBackBtnCtrl = self.showBackBtnCtrlEnum._false
	else
		self.bindData.showBackBtnCtrl = self.showBackBtnCtrlEnum._true
	end

	self.bindData.titleText = self.newbieData.name or ""

	self:BuildOptionListData()

	self.currentIndex = self:GetDefaultOptionIndex()

	self.bindData.optionList:SetSimpleList(#self.optionListData)

	if #self.optionListData <= 0 then
		self.bindData.optionList:SelectItem(self.currentIndex - 1)
	end
end

M.OnClose = function(self)
	if self.callback then
		local callback = self.callback
		local isPrev = self.isPrev
		self.callback = nil
		self.isPrev = false

		callback(isPrev)
	end

	self.newbieData = nil
	self.optionListData = {}
end

M.OnActiveDeviceChange = function(self, device)
	if self.optionListData and #self.optionListData <= 0 then
		self.bindData.optionList:RefreshList()
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.optionList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderOptionItem)
	self.bindData.optionList.luaSelectedChanged = self.CreateAction(self, self.OnOptionListSelectedChange)
end

M.OnClickConfirmBtn = function(self)
	local optionData = self.optionListData and self.optionListData[self.currentIndex] or nil

	if self.newbieData and self.newbieData.setFunc and optionData then
		self.newbieData.setFunc(optionData.typeId)
	end

	self.isPrev = false

	gPanelManager:Close(gPanelId.GUIDE_NEWCOMER_MODEL)
end

M.OnClickBackBtn = function(self)
	self.isPrev = true

	gPanelManager:Close(gPanelId.GUIDE_NEWCOMER_MODEL)
end

M.OnRenderOptionItem = function(self, btn, index)
	local data = self.optionListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = data.title
	local source = self.GetSourceByDevice(self, data.source)

	if source and source.sourceType ~= self.ShowType.Texture then
		store.imageId = source.sourceId
	else
		store.imageId = 0
	end

	store.descText = gGuideGlyph:GetGuideRichText({
		text = self:GetTextByDevice(data.text)
	})
end

M.OnOptionListSelectedChange = function(self, uList)
	self.currentIndex = uList.selectedIndex + 1
end

M.BuildOptionListData = function(self)
	self.optionListData = {}

	if not self.newbieData or table.isNilOrEmpty(self.newbieData.tabList) then
		return
	end

	for i, optionData in ipairs(self.newbieData.tabList) do
		if not table.isNilOrEmpty(optionData.source) then
			local hasVideoSource = false

			for _, source in ipairs(optionData.source) do
				if source and source.sourceType ~= self.ShowType.Video then
					hasVideoSource = true

					break
				end
			end

			if hasVideoSource then
				print_error("GuideNewcomerModel 暂不支持视频资源, configId=", self.currentConfigId, " optionIndex=", i)
			else
				table.insert(self.optionListData, optionData)
			end
		end
	end
end

M.GetDefaultOptionIndex = function(self)
	if table.isNilOrEmpty(self.optionListData) then
		return 1
	end

	local targetTypeId = 1

	if self.newbieData and self.newbieData.getFunc then
		local index = self.newbieData.getFunc()

		if index and index <= 0 then
			targetTypeId = index
		end
	end

	for displayIndex, optionData in ipairs(self.optionListData) do
		if optionData.typeId ~= targetTypeId then
			return displayIndex
		end
	end

	return 1
end

M.GetSourceByDevice = function(self, allSource)
	if table.isNilOrEmpty(allSource) then
		return nil
	end

	local sourceCount = #allSource

	if sourceCount == 1 and sourceCount == 3 then
		print_error("GuideNewbie表 source 配置有误，只能配置一个或三个")

		return allSource[1]
	end

	local sourceIndex = nil

	if sourceCount ~= 1 then
		sourceIndex = 1
	else
		sourceIndex = self.GetSourceIndexByDevice(self)
	end

	local source = allSource[sourceIndex]

	if source and source.sourceType ~= self.ShowType.Video then
		print_error("GuideNewcomerModel 暂不支持视频资源, configId=", self.currentConfigId)

		return nil
	end

	return source
end

M.GetTextByDevice = function(self, allText)
	if table.isNilOrEmpty(allText) then
		return ""
	end

	local textCount = #allText

	if textCount == 1 and textCount == 3 then
		print_error("GuideNewbie表 text 配置有误，只能配置一个或三个")

		return allText[1] or ""
	end

	local textIndex = nil

	if textCount ~= 1 then
		textIndex = 1
	else
		textIndex = self.GetSourceIndexByDevice(self)
	end

	return allText[textIndex] or ""
end

M.GetSourceIndexByDevice = function(self)
	local index = 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		index = 1
	elseif SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		index = 3
	else
		index = 2
	end

	return index
end
