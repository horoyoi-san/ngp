-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnWebpagePanelBase.lua
-- Decompiled from: 00867_SaturnWebpagePanelBase.lua_6e25d2c3ccc2.luajit

local SatrunConfig = LTConfig.WebpageSatrunConfig
local SatrunSectionType = LTConfig.WebpageSatrunConfig.TypeType
local SatrunSubPageType = LTConfig.WebpageSatrunConfig.SubTypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
local WebpageConfig = LTConfig.WebpageConfig
local AnimMgr = SGUI.AnimMgr
C_SaturnWebpagePanelBase = DefClass("C_SaturnWebpagePanelBase", C_SaturnWebpagePanelBase, C_StoreGroup)
GroupName2Class.SaturnWebpagePanelBase = C_SaturnWebpagePanelBase
local M = C_SaturnWebpagePanelBase

M.ctor = function(self)
	self.TAB_ANI_NAME = "SATURN_WEBPAGE_NAVBAR"
	self.TOTAL_ANI_TIME = 0.5
	self.navList = nil
	self.navBarRect = nil

	self.ResetNavData(self)
end

M.InitNavBindData = function(self, nav, navBarRect)
	nav.luaSimpleRenderItem = self.CreateAction(self, self._OnRenderNavListItem)
	nav.luaSimpleClick = self.CreateAction(self, self._OnSimpleClickNavListItem)
	nav.luaLayoutSet = self.CreateAction(self, self._OnLayoutSetNavList)
	self.navList = nav
	self.navBarRect = navBarRect
end

M.ResetNavData = function(self)
	self.navTags = {}
	self.navTypeToIdx = {}
	self.navPagePositions = {}
	self.navRenderingTypeList = {}

	self.ResetNavCache(self)
end

M.ResetNavCache = function(self)
	self.navCache = {
		["\\xf6M>\\xde\\x82@\\xa6\\xb4\\xae"] = 0,
		rendering = {
			btnWidgetList = {}
		}
	}
end

M.LoadNavData = function(self)
	self.ResetNavData(self)

	for i = 0, SatrunConfig.count - 1 do
		local page = SatrunConfig.LoadAt(i)

		if page.Type ~= SatrunSectionType.main then
			local resourceIds = page.SubResources

			for _, id in ipairs(resourceIds) do
				local resource = ResourceConfig.GetConfig(id)

				if resource then
					local url = nil

					if resource.Url and resource.Url == 0 then
						local webpage = WebpageConfig.GetConfig(resource.Url)

						if webpage then
							url = webpage.Url
						end
					end

					local tagData = {
						["}s\\xa2sI\\xa0\\xfbImSzT"] = 0,
						name = resource.Name,
						type = page.SubType,
						url = url,
						visible = page.NavVisible
					}
					self.navTypeToIdx[page.SubType] = #self.navTags + 1

					if page.NavVisible then
						table.insert(self.navRenderingTypeList, page.SubType)

						tagData.renderingIdx = #self.navRenderingTypeList
					end

					table.insert(self.navTags, tagData)
				end
			end
		end
	end
end

M.RenderNavList = function(self, initType)
	self:ResetNavCache()

	self.navCache.initType = initType

	self.navList:SetSimpleList(#self.navRenderingTypeList)
end

M.SetNavPagePositions = function(self, positions)
	self.navPagePositions = positions
end

M._OnRenderNavListItem = function(self, widget, index)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	local type = self.navRenderingTypeList[index + 1]
	local idx = self.navTypeToIdx[type]
	local tag = self.navTags[idx]
	store.title.text = tag.name
	self.navCache.rendering.btnWidgetList[index + 1] = widget
end

M._OnLayoutSetNavList = function(self)
	if not self.navCache.initType then
		return
	end

	local idx = self.navTypeToIdx[self.navCache.initType]
	local tag = self.navTags[idx]
	local renderingIdx = tag.renderingIdx
	local nav = self.navList

	nav.SelectItem(nav, renderingIdx - 1, false)
end

M._OnSimpleClickNavListItem = function(self, _, index)
	local type = self.navRenderingTypeList[index + 1]
	local tagIdx = self.navTypeToIdx[type]
	local tag = self.navTags[tagIdx]

	self.OnSetNavBarVisable(self, true)
	self.OnClickNavSection(self, tagIdx, tag.url)
end

M.GoToHomePage = function(self)
	local idx = self.navTypeToIdx[SatrunSubPageType.Top]

	if idx then
		local tag = self.navTags[idx]

		if tag and tag.url then
			gWebManager:GoToTagetUrl(tag.url)
		end
	end
end

M.ScrollToPosition = function(self, pos_y)
	local idx = self._GetNavTagIdxByPagePos(self, pos_y)
	local tag = self.navTags[idx]

	if tag then
		if self.navCache.currentTagIdx ~= idx then
			return
		end

		self.navCache.currentTagIdx = idx

		if tag.visible then
			self.OnSetNavBarVisable(self, true)
			self.OnScrollNavSection(self, idx, tag.url)
		else
			self.OnSetNavBarVisable(self, false)
		end
	end
end

M.SetCurrNavBarIdxWithAnim = function(self, idx)
	if idx and idx <= 0 then
		local targetBtnRenderingIdx = self.navTags[idx].renderingIdx

		if targetBtnRenderingIdx <= 0 then
			self.OnSetNavBarVisable(self, true)

			local targetBtn = self.navCache.rendering.btnWidgetList[targetBtnRenderingIdx]

			AnimMgr.Kill(self.navBarRect, self.TAB_ANI_NAME)
			AnimMgr.Move(self.navBarRect, self.TAB_ANI_NAME, self._GetTargetPosition(self, targetBtn), self.TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic, nil)
		end
	end
end

M._GetNavTagIdxByPagePos = function(self, pos)
	for i, v in ipairs(self.navPagePositions) do
		local endPos = self.navPagePositions[i + 1]

		if not endPos then
			return i
		end

		if v < pos and pos >= endPos then
			return i
		end
	end
end

M._GetTargetPosition = function(self, targetBtn)
	local targetPos = self.navList.rectTransform:InverseTransformPoint(targetBtn.position)
	local barPos = self.navBarRect.localPosition
	barPos.x = targetPos.x

	return barPos
end

M.OnClickNavSection = function(self, idx, url)
end

M.OnScrollNavSection = function(self, idx, url)
end

M.OnSetNavBarVisable = function(self, visable)
end
