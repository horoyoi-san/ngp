local M = {
	files = {},
	listeners = {}
}

setmetatable(M.files, {
	__mode = "v"
})

function M.AddFile(path, t)
	if string.ends_with(path, ".lua") then
		path = string.left(path, string.len(path) - 4)
	end

	M.files[path] = t
	local listeners = M.listeners[path]

	if listeners then
		for _, pair in ipairs(listeners) do
			pair[1](t, false)
		end
	end
end

function M.AddListener(path, listener, tag)
	if M.listeners[path] then
		table.insert(M.listeners[path], {
			listener,
			tag
		})
	else
		M.listeners[path] = {
			{
				listener,
				tag
			}
		}
	end

	if M.files[path] then
		listener(M.files[path], true)
	end
end

function M.RemoveListener(path, listener)
	array.remove_if(M.listeners[path], function (pair)
		return pair[1] == listener
	end)
end

function M.GetCount()
	local count = 0

	for _, _ in pairs(M.files) do
		count = count + 1
	end

	return count
end

function M.Clear(path)
	M.listeners[path] = nil
end

gLuaLoadFiles = M
