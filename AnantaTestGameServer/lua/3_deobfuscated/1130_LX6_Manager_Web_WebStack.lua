local BrowserStack = {
	__index = BrowserStack,
	MAX_SIZE = 30,
	new = function (self)
		local instance = {
			currentIndex = 0,
			history = {}
		}

		setmetatable(instance, self)

		return instance
	end
}

function BrowserStack:push(url)
	if self.currentIndex < #self.history then
		for i = #self.history, self.currentIndex + 1, -1 do
			table.remove(self.history, i)
		end
	end

	table.insert(self.history, url)

	self.currentIndex = self.currentIndex + 1

	if self.MAX_SIZE < #self.history then
		table.remove(self.history, 1)

		self.currentIndex = self.currentIndex - 1
	end
end

function BrowserStack:back()
	if self.currentIndex > 1 then
		self.currentIndex = self.currentIndex - 1

		return self.history[self.currentIndex]
	end

	return nil
end

function BrowserStack:forward()
	if self.currentIndex < #self.history then
		self.currentIndex = self.currentIndex + 1

		return self.history[self.currentIndex]
	end

	return nil
end

function BrowserStack:current()
	if self.currentIndex > 0 then
		return self.history[self.currentIndex]
	end

	return nil
end

function BrowserStack:canGoBack()
	return self.currentIndex > 1
end

function BrowserStack:canGoForward()
	return self.currentIndex < #self.history
end

return BrowserStack
