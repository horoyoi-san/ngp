gAsyncActionList = DefClass("AsyncActionList", gAsyncActionList)
local AsyncActionList = gAsyncActionList

function AsyncActionList:ctor()
	self.actions = {}
end

function AsyncActionList:AddRange(args, action)
	for _, arg in ipairs(args) do
		self:Add(function (onFinish)
			action(arg, onFinish)
		end)
	end
end

function AsyncActionList:Add(action)
	if self.inProcess then
		print_error("已经在处理了")

		return
	end

	table.insert(self.actions, action)
end

function AsyncActionList:Stop()
	self.stopped = true
end

function AsyncActionList:SetOnComplete(onComplete)
	self.onComplete = onComplete
end

function AsyncActionList:Start(onComplete)
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

	self:_Process(true)
end

function AsyncActionList:_Process(isInit, skipped)
	if self.stopped then
		self.inProcess = false

		return
	end

	local index = self.index
	index = isInit and index or index + 1
	self.index = index

	if index > #self.actions or skipped then
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
