-- Original chunk: @Lua\LuaFiles\LX6\GUI\SocialNetWork\ListPageEntity.lua
-- Decompiled from: 00578_ListPageEntity.lua_0f57fa0566a2.luajit

gListPageEntity = DefClass("ListPageEntity", gListPageEntity)
local ListPageEntity = gListPageEntity

ListPageEntity.ctor = function(self, pageSize)
	self.pageSize = pageSize or 10
	self.totalCount = 0
	self.dataMap = {}
	self.viewDataList = {}
	self.viewIdToIndexMap = {}
end

ListPageEntity.UpdateDataList = function(self, info)
	if not info then
		return
	end

	self.totalCount = info.total

	if info.list and next(info.list) then
		for _, data in ipairs(info.list) do
			self.dataMap[data.id] = data
			local viewIndex = self.GetViewIndexById(self, data.id)

			if viewIndex then
				self.viewDataList[viewIndex] = {
					listPageDataKeyValuePair = data
				}
			else
				viewIndex = #self.viewDataList + 1
				self.viewDataList[viewIndex] = {
					listPageDataKeyValuePair = data
				}
				self.viewIdToIndexMap[data.id] = viewIndex
			end
		end
	end
end

ListPageEntity.GetViewDataList = function(self)
	return self.viewDataList
end

ListPageEntity.GetDataMap = function(self)
	return self.dataMap
end

ListPageEntity.GetDataByIndex = function(self, index)
	local viewData = self.viewDataList[index]
	local listPageDataKeyValuePair = viewData and viewData.listPageDataKeyValuePair
	local id = listPageDataKeyValuePair and listPageDataKeyValuePair.id

	return self.dataMap[id]
end

ListPageEntity.GetViewIndexById = function(self, id)
	return self.viewIdToIndexMap[id]
end

ListPageEntity.GetViewDataCount = function(self)
	return #self.viewDataList
end

ListPageEntity.GetDataById = function(self, id)
	return self.dataMap[id]
end

ListPageEntity.UpdateData = function(self, args)
	local id = args.id

	if self.dataMap[id] then
		local data = self.dataMap[id]

		for k, v in pairs(args) do
			data[k] = v
		end

		local viewIndex = self.GetViewIndexById(self, id)
		self.viewDataList[viewIndex] = {
			listPageDataKeyValuePair = data
		}
	end
end

ListPageEntity.AddData = function(self, data, pos)
	local id = data.id
	self.dataMap[id] = data
	local viewIndex = pos or self:GetViewDataCount() + 1

	table.insert(self.viewDataList, viewIndex, {
		listPageDataKeyValuePair = data
	})

	self.viewIdToIndexMap = {}

	for index, viewData in ipairs(self.viewDataList) do
		local viewDataId = viewData.listPageDataKeyValuePair.id
		self.viewIdToIndexMap[viewDataId] = index
	end
end

ListPageEntity.CheckLoadMore = function(self)
	local viewDataCount = self:GetViewDataCount()

	return viewDataCount <= self.totalCount
end

ListPageEntity.GetCurrentPageIndex = function(self)
	local viewCount = self.GetViewDataCount(self)

	return math.ceil(viewCount / self.pageSize)
end

ListPageEntity.ClearData = function(self)
	self.dataMap = nil
	self.viewDataList = nil
	self.viewIdToIndexMap = nil
end

ListPageEntity.Reset = function(self)
	self.totalCount = 0
	self.dataMap = {}
	self.viewDataList = {}
	self.viewIdToIndexMap = {}
end
