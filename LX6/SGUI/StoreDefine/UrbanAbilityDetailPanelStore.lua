-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityDetailPanelStore.lua
-- Decompiled from: 01192_UrbanAbilityDetailPanelStore.lua_d0c28f122716.luajit

C_UrbanAbilityDetailPanelStore = DefClass("C_UrbanAbilityDetailPanelStore", C_UrbanAbilityDetailPanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityDetailPanelStore = C_UrbanAbilityDetailPanelStore
local M = C_UrbanAbilityDetailPanelStore
local DIMENSION_ICON_SPACING = 34

M.ctor = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.SetDetailData(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearAllDimensionIconClones(self)
	self.ClearMessageEvents(self)
end

M.ShowPanel = function(self)
	self.SetDetailData(self)
end

M.DefineAllVariables = function(self)
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityV2PanelStore")
	self.tabList = {}
	self.dimensionIconClones = {}

	self:BuildTypeToAttrsMap()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.BuildTypeToAttrsMap = function(self)
	self.typeToAttrs = {}

	for i = 0, LTConfig.AttributeNameConfig.count - 1 do
		local cfg = LTConfig.AttributeNameConfig.LoadAt(i)

		if cfg and cfg.Type and cfg.Type <= 0 then
			if not self.typeToAttrs[cfg.Type] then
				self.typeToAttrs[cfg.Type] = {}
			end

			table.insert(self.typeToAttrs[cfg.Type], {
				attrId = cfg.Id,
				name = cfg.AttributeName,
				showType = cfg.ShowType,
				description = cfg.Description,
				dimensionInfos = self.BuildDimensionInfos(self, cfg.AffectedUrbanAttributeId)
			})
		end
	end
end

M.BuildDimensionInfos = function(self, affectedUrbanAttributeIds)
	local dimensionInfos = {}

	if not affectedUrbanAttributeIds then
		return dimensionInfos
	end

	if type(affectedUrbanAttributeIds) ~= "number" then
		affectedUrbanAttributeIds = {
			affectedUrbanAttributeIds
		}
	end

	for _, urbanAttributeId in ipairs(affectedUrbanAttributeIds) do
		local urbanAttrCfg = LTConfig.UrbanAttributeConfig.GetConfig(urbanAttributeId)

		if urbanAttrCfg then
			table.insert(dimensionInfos, {
				iconId = urbanAttrCfg.SIcon,
				urbanAttrName = urbanAttrCfg.Name,
				urbanAttrEffect = urbanAttrCfg.Effect
			})
		end
	end

	return dimensionInfos
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.tab.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabItem")
	self.bindData.tab.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTab")
end

M.OnClickCloseBtn = function(self)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_UrbanAbilityBasicFeaturePanel_close")
	Timer.New(function ()
		self.urbanAbilityStore:CloseCurrentTab()
	end, 0.2):Start()
end

M.OnSimpleRenderTabItem = function(self, btn, index)
	local data = self.tabList[index + 1]

	if not data then
		return
	end

	self.RenderTitleItem(self, btn, data)
end

M.OnSimpleClickTab = function(self, btn, index)
	local data = self.tabList[index + 1]

	if not data then
		return
	end

	local list = data.list
	self._listData = list

	self.bindData.list:SetSimpleList(#list)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self._listData[index + 1]

	if not data then
		return
	end

	self.RenderDetailListItem(self, btn, data)
end

M.OnSimpleClickList = function(self, btn, index)
end

M.SetDetailData = function(self)
	self.tabList = {}
	local spiritId = self.urbanAbilityStore:GetCurSpiritTid()
	self.spiritPanelData = gUrbanAbilityManager:GetUrbanPanelData(spiritId)

	for tabIdx = 0, LTConfig.AttributeNameAttributeTabConfig.count - 1 do
		local tabCfg = LTConfig.AttributeNameAttributeTabConfig.LoadAt(tabIdx)

		if tabCfg then
			local tab = {
				title = tabCfg.Name,
				iconId = tabCfg.Icon
			}

			table.insert(self.tabList, tab)

			if tabCfg.TypeList then
				tab.list = {}

				for _, typeId in ipairs(tabCfg.TypeList) do
					local typeCfg = LTConfig.AttributeNameAttributeTypeConfig.GetConfig(typeId)
					local attrs = self.typeToAttrs[typeId]

					if typeCfg and attrs and #attrs <= 0 then
						table.insert(tab.list, {
							title = typeCfg.Name,
							items = attrs
						})
					end
				end
			end
		end
	end

	self.bindData.isEmpty = #self.tabList <= 0 and self.isEmptyEnum._false or self.isEmptyEnum._true

	self.bindData.tab:SetSimpleList(#self.tabList)
	self.bindData.tab:SelectItem(0, true)
	self:OnSimpleClickTab(nil, 0)
end

local trimNumberTail = function(value)
	return value:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
end

M.FormatAttributeValue = function(self, value, showType)
	if showType ~= nil or showType ~= "" then
		return value
	end

	local typeName, precision = string.match(showType, "^([fp])(%d+)$")

	if not typeName then
		return tostring(value)
	end

	precision = tonumber(precision)
	local scale = 10^precision
	local displayValue = typeName ~= "p" and value * 100 or value
	displayValue = math.floor(displayValue * scale + 1e-08) / scale
	local result = trimNumberTail(string.format("%." .. precision .. "f", displayValue))

	if typeName ~= "p" then
		return result .. "%"
	end

	return result
end

M.RenderTitleItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityDetailTitleTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title or ""

	store:Commit("iconId", data.iconId, COMMIT_FORCE)
end

M.RenderDetailListItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityDetailListTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title or ""

	store.foldBtn.luaClick = function()
		data.isFold = not data.isFold

		self.bindData.list:ForceRebuildDynamicVirtual()
	end

	if data.items then
		store.list.luaSimpleRenderItem = self.CreateActionWithArgs(self, "OnRenderInnerDetailItem", data.items)
		store.list.luaSimpleClick = self.CreateActionWithArgs(self, "OnClickInnerDetailItem", data.items)

		if data.isFold then
			store.list:SetSimpleList(0)
		else
			store.list:SetSimpleList(#data.items)
		end
	end

	store.isFold = data.isFold and 1 or 0
end

M.OnRenderInnerDetailItem = function(self, items, btn, index)
	local itemData = items[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup("UrbanAbilityDetailTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = itemData.name or ""
	local value = self.spiritPanelData and self.spiritPanelData.Attrs and self.spiritPanelData.Attrs[itemData.attrId]
	store.value = value and self:FormatAttributeValue(value, itemData.showType) or ""

	self:RenderDimensionIcons(store, itemData.dimensionInfos)
end

M.SetDimensionTooltip = function(self, btn, dimensionInfo)
	btn.forceOneTooltip = true

	btn.luaRenderTooltip = function(_, popIns)
		local tipsStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

		if not tipsStore then
			return
		end

		tipsStore.title = dimensionInfo.urbanAttrName or ""
		tipsStore.context = dimensionInfo.urbanAttrEffect or ""
	end

	btn.luaTooltipPopup = function(btn, popup)
		if popup then
			self.activeDimensionTooltipBtn = btn
		elseif self.activeDimensionTooltipBtn ~= btn then
			self.activeDimensionTooltipBtn = nil
			SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
		end
	end
end

M.BindDimensionIcon = function(self, btn, dimensionInfo)
	local image = btn.transform:Find("Image"):GetComponent(typeof(SGUI.UImage))

	gStoreBindMethod:BindIconIdToImage(image, dimensionInfo.iconId)
	self:SetDimensionTooltip(btn, dimensionInfo)
end

M.ClearDimensionIconClones = function(self, btn)
	local widgetId = btn.gameObject:GetInstanceID()
	local clones = self.dimensionIconClones[widgetId]

	if clones then
		for i = 1, #clones do
			UnityEngine.GameObject.Destroy(clones[i])
		end

		self.dimensionIconClones[widgetId] = nil
	end
end

M.ClearAllDimensionIconClones = function(self)
	for _, clones in pairs(self.dimensionIconClones) do
		for i = 1, #clones do
			UnityEngine.GameObject.Destroy(clones[i])
		end
	end

	self.dimensionIconClones = {}
end

M.RenderDimensionIcons = function(self, store, dimensionInfos)
	self:ClearDimensionIconClones(store.dimensionBtn)

	local dimensionCount = dimensionInfos and #dimensionInfos or 0
	store.hasDimensionIcon = dimensionCount <= 0 and 1 or 0

	if dimensionCount ~= 0 then
		return
	end

	self.BindDimensionIcon(self, store.dimensionBtn, dimensionInfos[1])

	if dimensionCount ~= 1 then
		return
	end

	local widgetId = store.dimensionBtn.gameObject:GetInstanceID()
	local clones = {}
	self.dimensionIconClones[widgetId] = clones
	local basePos = store.dimensionBtn.rectTransform.anchoredPosition

	for i = 2, dimensionCount do
		local cloneGo = UnityEngine.GameObject.Instantiate(store.dimensionBtn.gameObject, store.dimensionBtn.transform.parent)
		local cloneBtn = cloneGo.GetComponent(cloneGo, typeof(SGUI.UButton))

		cloneBtn.TryInit(cloneBtn)

		cloneBtn.rectTransform.anchoredPosition = Vector2.New(basePos.x - (i - 1) * DIMENSION_ICON_SPACING, basePos.y)

		self.BindDimensionIcon(self, cloneBtn, dimensionInfos[i])
		cloneGo.SetActive(cloneGo, true)
		table.insert(clones, cloneGo)
	end
end

M.OnClickInnerDetailItem = function(self, items, btn, index)
	local itemData = items[index + 1]

	if not itemData then
		return
	end
end
