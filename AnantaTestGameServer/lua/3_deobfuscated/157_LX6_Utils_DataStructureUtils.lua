local M = {}

function M.GetQueue()
	return {
		firstIndex = -1,
		count = 0,
		lastIndex = -1,
		Push = function (queue, value)
			if not value then
				return
			end

			if queue.count == 0 then
				queue.firstIndex = 1
				queue.lastIndex = 1
			else
				queue.lastIndex = queue.lastIndex + 1
			end

			queue[queue.lastIndex] = value
			queue.count = queue.count + 1
		end,
		Pop = function (queue)
			if queue.count > 0 then
				local value = queue[queue.firstIndex]
				queue[queue.firstIndex] = nil
				queue.count = queue.count - 1

				if queue.count == 0 then
					queue.firstIndex = -1
					queue.lastIndex = -1
				else
					queue.firstIndex = queue.firstIndex + 1
				end

				return value
			else
				return nil
			end
		end,
		Peek = function (queue)
			if queue.count > 0 then
				return queue[queue.firstIndex]
			else
				return nil
			end
		end,
		Clear = function (queue)
			if queue.count > 0 then
				for i = queue.firstIndex, queue.lastIndex do
					queue[i] = nil
				end

				queue.firstIndex = -1
				queue.lastIndex = -1
				queue.count = 0
			end
		end
	}
end

function M.GetStack()
	return {
		topIndex = -1,
		count = 0,
		bottomIndex = -1,
		Push = function (stack, item)
			if stack.count < 0 then
				return
			end

			if stack.count == 0 then
				stack.topIndex = 1
				stack.bottomIndex = 1
				stack[stack.bottomIndex] = item
				stack.count = 1

				return
			else
				stack.topIndex = stack.topIndex + 1
				stack[stack.topIndex] = item
				stack.count = stack.count + 1

				return
			end
		end,
		Pop = function (stack)
			if stack.count > 0 then
				local item = stack[stack.topIndex]
				stack.topIndex = stack.topIndex - 1
				stack.count = stack.count - 1

				if stack.count == 0 then
					stack.bottomIndex = -1
					stack.topIndex = -1
				end

				return item
			else
				return nil
			end
		end,
		PopToIndex = function (stack, index)
			if stack.count > 0 then
				stack.topIndex = index
				stack.count = stack.topIndex - stack.bottomIndex + 1
			end
		end,
		Peek = function (stack)
			if stack.count > 0 then
				return stack[stack.topIndex]
			else
				return nil
			end
		end,
		PeekBottom = function (stack)
			if stack.count > 0 then
				return stack[stack.bottomIndex]
			else
				return nil
			end
		end,
		Clear = function (stack)
			if stack.count > 0 then
				for i = stack.bottomIndex, stack.topIndex do
					stack[i] = nil
				end

				stack.topIndex = -1
				stack.bottomIndex = -1
				stack.count = 0
			end
		end,
		Contains = function (stack, item)
			return stack:IndexOf(item) ~= nil
		end,
		IndexOf = function (stack, item)
			if stack.count > 0 then
				for i = stack.bottomIndex, stack.topIndex do
					if stack[i] == item then
						return i
					end
				end
			end
		end,
		Delete = function (stack, item)
			local index = stack:IndexOf(item)

			if index then
				for i = index + 1, stack.topIndex do
					stack[i - 1] = stack[i]
				end

				stack[stack.topIndex] = nil
				stack.count = stack.count - 1

				if stack.count == 0 then
					stack.topIndex = -1
					stack.bottomIndex = -1
				else
					stack.topIndex = stack.topIndex - 1
				end
			end
		end
	}
end

function M.GetLRU(capability)
	local function createNode(content, prev, next)
		return {
			content = content,
			prev = prev,
			next = next
		}
	end

	return {
		count = 0,
		capability = capability,
		map = {},
		Visit = function (this, content)
			if this.count > 0 then
				local node = this.map[content]

				if node == nil then
					node = createNode(content, nil, nil)
					this.map[content] = node
					node.next = nil
					node.prev = this.tail
					this.tail.next = node
					this.tail = node

					if this.count == this.capability then
						local oldHead = this.head
						this.head = this.head.next
						this.head.prev = nil
						this.map[oldHead.content] = nil

						return oldHead.content
					else
						this.count = this.count + 1
					end
				elseif node ~= this.tail then
					if node.prev then
						node.prev.next = node.next
					else
						this.head = node.next
					end

					node.next.prev = node.prev
					node.next = nil
					node.prev = this.tail
					this.tail.next = node
					this.tail = node
				end
			else
				this.count = 1
				local node = createNode(content, nil, nil)
				this.map[content] = node
				this.head = node
				this.tail = node
			end
		end,
		Pop = function (this)
			if this.count > 0 then
				local oldHead = this.head
				this.head = this.head.next
				this.head.prev = nil
				this.map[oldHead.content] = nil
				this.count = this.count - 1

				return oldHead.content
			end
		end,
		Peek = function (this)
			return this.head.content
		end
	}
end

gDataStructureUtils = M
