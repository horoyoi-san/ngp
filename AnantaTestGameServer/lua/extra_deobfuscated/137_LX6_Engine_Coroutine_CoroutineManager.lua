local Coroutine = require("LX6/Engine/Coroutine/Coroutine")
local create = coroutine.create
local resume = coroutine.resume
local M = {
	Init = function (self)
		self.coroutineList = {}
	end
}
local backQueue = {}

function M:OnUpdate()
	if #self.coroutineList == 0 then
		return
	end

	local list = self.coroutineList
	self.coroutineList = backQueue

	for i = 1, #list do
		local coInternal = list[i]

		if coInternal ~= nil and not coInternal.isCanceled then
			while true do
				local moveStatus = coInternal:TryMoveNext()

				if moveStatus == 3 then
					break
				end

				if moveStatus == 1 then
					backQueue[#backQueue + 1] = coInternal

					break
				end

				if coInternal.wait == nil then
					backQueue[#backQueue + 1] = coInternal

					break
				end
			end
		end

		list[i] = nil
	end

	backQueue = list
end

function M:StartCoroutine(coFunc, ...)
	local co = create(coFunc)
	local status, wait = resume(co, ...)
	local coInternal = Coroutine:New(co, wait, nil, nil)

	if not status then
		local msg = debug.traceback(co, wait)

		print_error(msg)
		coInternal:Finish()

		return nil
	elseif not coInternal:HasNext() then
		coInternal:Finish()

		return nil
	end

	while true do
		if coInternal.wait == nil then
			table.insert(self.coroutineList, coInternal)

			return coInternal
		end

		local moveStatus = coInternal:TryMoveNext()

		if moveStatus == 3 then
			return nil
		end

		if moveStatus == 1 then
			table.insert(self.coroutineList, coInternal)

			return coInternal
		end
	end
end

function M:StartCoroutineWithCallback(coFunc, ...)
	local arg = {
		...
	}
	local length = #arg

	if length < 2 then
		print_error("Length of arguments should not be less than 3. Failed to call StartCoroutineWithCallback")

		return nil
	end

	local coFuncParams = {}

	for i = 1, length - 2 do
		table.insert(coFuncParams, arg[i])
	end

	local co = create(coFunc)
	local status, wait = resume(co, unpack(coFuncParams))
	local coInternal = Coroutine:New(co, wait, arg[length - 1], arg[length])

	if not status then
		local msg = debug.traceback(co, wait)

		print_error(msg)
		coInternal:Finish()

		return nil
	elseif not coInternal:HasNext() then
		coInternal:Finish()

		return nil
	end

	while true do
		if coInternal.wait == nil then
			table.insert(self.coroutineList, coInternal)

			return coInternal
		end

		local moveStatus = coInternal:TryMoveNext()

		if moveStatus == 3 then
			return nil
		end

		if moveStatus == 1 then
			table.insert(self.coroutineList, coInternal)

			return coInternal
		end
	end
end

function M:CancelCoroutine(coInternal)
	coInternal.isCanceled = true
end

function M:OnDestroy()
	self.coroutineList = nil
	self.instance = nil
end

M:Init()

gCoroutineManager = M
