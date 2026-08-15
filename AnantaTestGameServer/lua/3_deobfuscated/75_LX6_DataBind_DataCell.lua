local DataCell = DefClass("DataCell")

function DataCell:ctor(dataSet, bindFunc, eventName)
	self._func = bindFunc
	self.dataSet = dataSet
	self.key = eventName
	self.tracePath = dataSet.tracePath
	self.value = self.dataSet[eventName]
end

function DataCell:Destroy()
	if self.onDestroy then
		self:onDestroy()

		self.onDestroy = nil
	end

	self._func = nil
	self.param = nil

	if self.dataSet and self.dataSetIndex then
		self.dataSet:UnBindCell(self)
	end
end

function DataCell:Call(value)
	if value ~= nil then
		self.value = value
	end

	local status, err = xpcall(self._func, tolua.traceback, self)

	if not status then
		if self.gameObject then
			print_error("DataCell:Call Failed, Key:", self.key, value, "filePath[" .. (self.tracePath or "nil") .. "]", " GameObject:", SGUITools.GetHierarchy(self.gameObject), "\n", err)
		else
			print_error("DataCell:Call Failed, Key:", self.key, value, "filePath[" .. (self.tracePath or "nil") .. "]", "\n", err)
		end
	end
end

return DataCell
