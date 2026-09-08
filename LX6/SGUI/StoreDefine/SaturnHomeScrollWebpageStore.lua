-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnHomeScrollWebpageStore.lua
-- Decompiled from: 00866_SaturnHomeScrollWebpageStore.lua_cfdbdaf51fb9.luajit

local SatrunConfig = LTConfig.WebpageSatrunConfig
local SatrunSectionType = LTConfig.WebpageSatrunConfig.TypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
local WebpageConfig = LTConfig.WebpageConfig
C_SaturnHomeScrollWebpageStore = DefClass("C_SaturnHomeScrollWebpageStore", C_SaturnHomeScrollWebpageStore, C_StoreGroup)
GroupName2Class.SaturnHomeScrollWebpageStore = C_SaturnHomeScrollWebpageStore
local M = C_SaturnHomeScrollWebpageStore

M.ctor = function(self)
	self.mgr = gWebManager
	self.sections = {}
	self.postions = {}
end

M.OnAwake = function(self)
	self.bindings = {
		{
			[""] = "\\x8co7",
			obj = self.bindData.obj1,
			rect = self.bindData.rect1
		},
		{
			[""] = "\\x8co4",
			title = self.bindData.title2,
			desc = self.bindData.desc2,
			obj = self.bindData.obj2,
			rect = self.bindData.rect2
		},
		{
			[""] = "\\x8co5",
			title = self.bindData.title3,
			desc = self.bindData.desc3,
			obj = self.bindData.obj3,
			rect = self.bindData.rect3
		},
		{
			[""] = "\\x8co2",
			obj = self.bindData.obj4,
			rect = self.bindData.rect4
		}
	}
end

M.RefreshPage = function(self)
	self.LoadData(self)
	self.RenderPage(self)
end

M.LoadData = function(self)
	self.sections = {}

	for i = 0, SatrunConfig.count - 1 do
		local page = SatrunConfig.LoadAt(i)

		if page.Type ~= SatrunSectionType.main then
			local resourceIds = page.SubResources

			for _, id in ipairs(resourceIds) do
				local resource = ResourceConfig.GetConfig(id)
				local url = nil

				if resource.Url and resource.Url == 0 then
					local webpage = WebpageConfig.GetConfig(resource.Url)

					if webpage then
						url = webpage.Url
					end
				end

				if resource then
					table.insert(self.sections, {
						title = page.SubTitle,
						type = page.SubType,
						subtitle = page.SubTitle,
						desc = resource.Desc,
						image = resource.ImageId,
						resourceId = id,
						url = url
					})
				end
			end
		end
	end
end

M.RenderPage = function(self)
	self.postions = {}

	for i, data in ipairs(self.sections) do
		local binding = self.bindings[i]

		if binding then
			if binding.title then
				binding.title.text = data.title or ""
			end

			if binding.subtitle then
				binding.subtitle.text = data.subtitle or ""
			end

			if binding.desc then
				binding.desc.text = data.desc or ""
			end

			if binding.bg then
				self.bindData:Commit(binding.bg, data.image, COMMIT_FORCE)
			end

			if binding.obj and data.url then
				binding.obj.clickUrlOverride = data.url
			end

			if binding.rect then
				table.insert(self.postions, math.abs(binding.rect.transform.localPosition.y))
			end
		end
	end
end

M.GetPagePositions = function(self)
	return self.postions
end

M.GetPageSizeY = function(self)
	return self.bindData.rectself.rect.height
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end
