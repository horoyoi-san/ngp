local M = gString or {}

function M.Join(sep, array)
	return table.concat(array.arr, sep or "")
end

function M.Concat(...)
	local strs = {
		...
	}

	return table.concat(strs)
end

function M.Length(str)
	return #str
end

function M.Format(str, ...)
	if string.match(str, "%b{}") ~= nil then
		return gString.FormatString(str, ...)
	else
		return string.format(str, ...)
	end
end

function M.FormatString(str, ...)
	local strs = {
		...
	}

	for i = 1, #strs do
		str = string.gsub(str, "{" .. i - 1 .. "}", strs[i])
	end

	return str
end

M.CsFormat = System.String.Format
gString = M
