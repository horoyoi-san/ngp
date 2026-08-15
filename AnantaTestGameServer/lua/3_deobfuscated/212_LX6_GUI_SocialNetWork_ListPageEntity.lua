gListPageEntity = DefClass("ListPageEntity", gListPageEntity)
local ListPageEntity = gListPageEntity

function ListPageEntity:ctor(pageSize)
	self.pageSize = pageSize or 10
	self.totalCount = 0
	self.dataMap = {}
	self.viewDataList = {}
	self.viewIdToIndexMap = {}
end

function ListPageEntity:UpdateDataList(info)
	if not info then
		return
	end

	self.totalCount = info.total

	if info.list and next(info.list) then
		for _, data in ipairs(info.list) do
			self.dataMap[data.id] = data
			local viewIndex = self:GetViewIndexById(data.id)

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

function ListPageEntity:GetViewDataList()
	return self.viewDataList
end

function ListPageEntity:GetDataMap()
	return self.dataMap
end

function ListPageEntity:GetDataByIndex(index)
	local viewData = self.viewDataList[index]
	local listPageDataKeyValuePair = viewData and viewData.listPageDataKeyValuePair
	local id = listPageDataKeyValuePair and listPageDataKeyValuePair.id

	return self.dataMap[id]
end

function ListPageEntity:GetViewIndexById(id)
	return self.viewIdToIndexMap[id]
end

function ListPageEntity:GetViewDataCount()
	return #self.viewDataList
end

function ListPageEntity:GetDataById(id)
	return self.dataMap[id]
end

function ListPageEntity:UpdateData(args)
	local id = args.id

	if self.dataMap[id] then
		local data = self.dataMap[id]

		for k, v in pairs(args) do
			data[k] = v
		end

		local viewIndex = self:GetViewIndexById(id)
		self.viewDataList[viewIndex] = {
			listPageDataKeyValuePair = data
		}
	end
end

function ListPageEntity:AddData(data, pos)
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

function ListPageEntity:CheckLoadMore()
	local viewDataCount = self:GetViewDataCount()

	return viewDataCount < self.totalCount
end

function ListPageEntity:GetCurrentPageIndex()
	local viewCount = self:GetViewDataCount()

	return math.ceil(viewCount / self.pageSize)
end

function ListPageEntity:ClearData()
	self.dataMap = nil
	self.viewDataList = nil
	self.viewIdToIndexMap = nil
end

function ListPageEntity:Reset()
	self.totalCount = 0
	self.dataMap = {}
	self.viewDataList = {}
	self.viewIdToIndexMap = {}
end
