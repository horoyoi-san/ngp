-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnResourceWebpageBase.lua
-- Decompiled from: 01998_SaturnResourceWebpageBase.lua_49ee036a3b57.luajit

local SatrunConfig = LTConfig.WebpageSatrunConfig
local SatrunSectionType = LTConfig.WebpageSatrunConfig.TypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
C_SaturnResourceWebpageBase = DefClass("C_SaturnResourceWebpageBase", C_SaturnResourceWebpageBase, C_SaturnWebpagePanelBase)
GroupName2Class.SaturnResourceWebpageBase = C_SaturnResourceWebpageBase
local M = C_SaturnResourceWebpageBase

M.ctor = function(self)
	self.EmptyResource = {
		["Y\\xa7\\xb6\\xa3\\xb3"] = "",
		["A_ݲ\\x91\\xbb\\xe0\\xec"] = 0,
		["~'nX"] = ""
	}
	self.PageSize = 6
	self.currResourceIdx = 0
	self.resources = {}
	self.currPageIdx = 1
	self.pageData = {}
end

M.LoadData = function(self, section, sub)
	self.resources = {}
	self.bgImage = 0

	for i = 0, SatrunConfig.count - 1 do
		local page = SatrunConfig.LoadAt(i)

		if page.Type ~= section then
			local resourceIds = page.SubResources

			for _, id in ipairs(resourceIds) do
				local resource = ResourceConfig.GetConfig(id)

				if resource then
					table.insert(self.resources, {
						title = resource.Name,
						desc = resource.Desc,
						image = resource.ImageId,
						resourceId = id
					})
				end
			end
		elseif page.Type ~= SatrunSectionType.main and page.SubType ~= sub then
			local resourceIds = page.SubResources

			if #resourceIds <= 0 then
				local resource = ResourceConfig.GetConfig(resourceIds[1])
				self.bgImage = resource.ImageId
			end
		end
	end

	self.CalcPageData(self)
	self.LoadNavData(self)
	self.RenderNavList(self, section)
	self._OnRenderPage(self, 1)
end

M.CalcPageData = function(self)
	local resCnt = #self.resources
	local pageCount = math.ceil(resCnt / self.PageSize)
	self.pageData = {}

	for i = 1, pageCount do
		table.insert(self.pageData, {
			from = (i - 1) * self.PageSize + 1,
			to = math.min(i * self.PageSize, resCnt)
		})
	end
end

M.LoadResource = function(self)
	if not self.currResourceIdx or self.currResourceIdx <= #self.resources then
		self.currResourceIdx = 0
	end

	local resource = self.currResourceIdx <= 0 and self.resources[self.currResourceIdx] or self.EmptyResource

	self:OnLoadResource(resource)
end

M.OnLoadResource = function(self, resource)
end

M.OnRenderPage = function(self, resources)
end

M._OnRenderPage = function(self, pageIdx)
	local page = self.pageData[pageIdx]

	if not page then
		return
	end

	local resources = {}

	for i = page.from, page.to do
		table.insert(resources, self.resources[i])
	end

	self.OnRenderPage(self, resources)
end

M.NextPage = function(self)
	if not self.HasNextPage(self) then
		return
	end

	self.currPageIdx = self.currPageIdx + 1

	self._OnRenderPage(self, self.currPageIdx)
end

M.HasNextPage = function(self)
	return self.currPageIdx <= #self.pageData
end

M.PrevPage = function(self)
	if not self.HasPrevPage(self) then
		return
	end

	self.currPageIdx = self.currPageIdx - 1

	self._OnRenderPage(self, self.currPageIdx)
end

M.HasPrevPage = function(self)
	return self.currPageIdx >= 1
end

M.NextResource = function(self)
	self.currResourceIdx = self.currResourceIdx + 1

	if self.currResourceIdx > 0 or self.currResourceIdx <= #self.resources then
		self.currResourceIdx = 1
	end
end

M.PrevResource = function(self)
	self.currResourceIdx = self.currResourceIdx - 1

	if self.currResourceIdx > 0 or self.currResourceIdx <= #self.resources then
		self.currResourceIdx = #self.resources
	end
end

M.SetResourceId = function(self, idx)
	local currPage = self.pageData[self.currPageIdx]

	if not currPage then
		return
	end

	self.currResourceIdx = currPage.from + idx - 1
end

M.GetResourceId = function(self)
	return self.currResourceIdx
end

M.GetResource = function(self, idx)
	if not idx then
		idx = self.currResourceIdx
	else
		local currPage = self.pageData[self.currPageIdx]

		if not currPage then
			return
		end

		idx = currPage.from + idx - 1
	end

	local resource = idx <= 0 and self.resources[idx] or self.EmptyResource

	return resource
end

M.OnClickNavSection = function(self, _, url)
	if url then
		gWebManager:GoToTagetUrl(url)
	end
end
