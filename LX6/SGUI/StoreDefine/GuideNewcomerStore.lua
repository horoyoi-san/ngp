-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideNewcomerStore.lua
-- Decompiled from: 01729_GuideNewcomerStore.lua_392c2cfd4895.luajit

C_GuideNewcomerStore = DefClass("C_GuideNewcomerStore", C_GuideNewcomerStore, C_StoreGroup)
GroupName2Class.GuideNewcomerStore = C_GuideNewcomerStore
local M = C_GuideNewcomerStore

M.ctor = function(self)
	self.callback = nil
	self.isPrev = false
	self.currentTabIndex = 1
	self.newbieData = nil
	self.displayTabList = nil
	self.currentSource = nil
	self.currentConfigId = 0
	self.ShowType = {
		["\\xed\\xde\t6\\xf4"] = 1,
		["{\\xa7\\xa6\\xaa\\xb9"] = 2
	}
end

M.DefineAllVariables = function(self)
	self.callback = nil
	self.isPrev = false
	self.currentTabIndex = 1
	self.newbieData = nil
	self.displayTabList = {}
	self.currentSource = nil
	self.currentConfigId = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
		print_error("GuideNewcomerStore OnShow newbieData is nil, configId=", self.currentConfigId)
		gPanelManager:Close(gPanelId.GUIDE_NEWCOMER)

		return
	end

	self:BuildDisplayTabList()

	self.currentTabIndex = self:GetDefaultTabIndex()

	self.SubGroup.CommonTabSingleStore:SetSimpleData(#self.displayTabList, nil, self.currentTabIndex - 1, nil, self:CreateAction(self.OnTabSelectedChange), self:CreateAction(self.OnRenderTabItem))

	if #self.displayTabList <= 0 then
		local tabData = self.displayTabList[self.currentTabIndex]
		self.bindData.titleText = tabData.title
		self.currentSource = tabData.source

		self.RenderSource(self)
	else
		self.currentSource = nil

		self.RenderSource(self)
	end
end

M.OnClose = function(self)
	self.bindData.videoPlayer:Stop()

	if self.callback then
		local callback = self.callback
		local isPrev = self.isPrev
		self.callback = nil
		self.isPrev = false

		callback(isPrev)
	end

	self.newbieData = nil
	self.displayTabList = {}
	self.currentSource = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.RenderSource(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.OnClickConfirmBtn = function(self)
	local tabData = self.displayTabList and self.displayTabList[self.currentTabIndex] or nil

	if self.newbieData and self.newbieData.setFunc and tabData then
		self.newbieData.setFunc(tabData.typeId)
	end

	self.isPrev = false

	gPanelManager:Close(gPanelId.GUIDE_NEWCOMER)
end

M.OnClickBackBtn = function(self)
	print_error("GuideNewcomer界面还未接入返回按钮限制，禁止返回")
end

M.OnTabSelectedChange = function(self, uList, isSub)
	if isSub then
		return
	end

	local tabIndex = uList.selectedIndex + 1

	if tabIndex < 0 then
		return
	end

	if table.isNilOrEmpty(self.displayTabList) then
		return
	end

	local tabData = self.displayTabList[tabIndex]

	if not tabData then
		return
	end

	self.currentTabIndex = tabIndex
	self.bindData.titleText = tabData.title
	self.currentSource = tabData.source

	self.RenderSource(self)
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub)
	if isSub or table.isNilOrEmpty(self.displayTabList) then
		return
	end

	local tabData = self.displayTabList[index + 1]

	if not tabData then
		return
	end

	store.title = tabData.title or ""

	if store.icon == nil then
		store.icon = tabData.iconId or 0
	end
end

M.RenderSource = function(self)
	local allSource = self.currentSource

	if table.isNilOrEmpty(allSource) then
		self.bindData.videoPlayer:Stop()
		self.bindData.videoPlayer.gameObject:SetActive(false)

		return
	end

	if #allSource == 1 and #allSource == 3 then
		print_error("GuideNewbie表 source 配置有误，只能配置一个或三个")

		return
	end

	local index = nil

	if #allSource ~= 1 then
		index = 1
	else
		index = self.GetSourceIndexByDevice(self)
	end

	local source = allSource[index]

	if not source then
		return
	end

	if source.sourceType ~= self.ShowType.Video then
		self.bindData.videoPlayer.gameObject:SetActive(true)
		self.bindData.videoPlayer:Init()
		self.bindData.videoPlayer:PlayVideo(source.sourceId, true, nil)
	else
		self.bindData.videoPlayer:Stop()
		self.bindData.videoPlayer.gameObject:SetActive(false)

		self.bindData.imageIconId = source.sourceId
	end
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

M.BuildDisplayTabList = function(self)
	self.displayTabList = {}

	if not self.newbieData or table.isNilOrEmpty(self.newbieData.tabList) then
		return
	end

	for _, tabData in ipairs(self.newbieData.tabList) do
		if not table.isNilOrEmpty(tabData.source) then
			table.insert(self.displayTabList, tabData)
		end
	end
end

M.GetDefaultTabIndex = function(self)
	if table.isNilOrEmpty(self.displayTabList) then
		return 1
	end

	local targetTypeId = 1

	if self.newbieData and self.newbieData.getFunc then
		local index = self.newbieData.getFunc()

		if index and index <= 0 then
			targetTypeId = index
		end
	end

	for displayIndex, tabData in ipairs(self.displayTabList) do
		if tabData.typeId ~= targetTypeId then
			return displayIndex
		end
	end

	return 1
end
