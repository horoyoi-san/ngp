-- Original chunk: @Lua\LuaFiles\LX6\Utils\AsyncActionList.lua
-- Decompiled from: 00150_AsyncActionList.lua_0c8c384a067a.luajit

gAsyncActionList = DefClass("AsyncActionList", gAsyncActionList)
local AsyncActionList = gAsyncActionList

AsyncActionList.ctor = function(self)
	self.actions = {}
end

AsyncActionList.AddRange = function(self, args, action)
	for _, arg in ipairs(args) do
		self.Add(self, function (onFinish)
			action(arg, onFinish)
		end)
	end
end

AsyncActionList.Add = function(self, action)
	if self.inProcess then
		print_error("已经在处理了")

		return
	end

	table.insert(self.actions, action)
end

AsyncActionList.Stop = function(self)
	self.stopped = true
end

AsyncActionList.Start = function(self, onComplete)
	if self.inProcess then
		print_error("已经在处理了")

		return
	end

	if onComplete then
		if not self.onComplete then
			self.onComplete = onComplete
		else
			print_error("多次设置 onComplete")

			self.onComplete = onComplete
		end
	end

	self.index = 1
	self.inProcess = true

	self._Process(self, true)
end

AsyncActionList._Process = function(self, isInit, skipped)
	if self.stopped then
		self.inProcess = false

		return
	end

	local index = self.index
	index = isInit and index or index + 1
	self.index = index

	if index >= #self.actions or skipped then
		self.inProcess = false

		if self.onComplete then
			self.onComplete(skipped)
		end

		self.onComplete = nil

		return
	end

	local action = self.actions[index]

	action(function (_skipped)
		self:_Process(nil, _skipped)
	end)
end
