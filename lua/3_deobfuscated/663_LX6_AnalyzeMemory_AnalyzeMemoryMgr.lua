local M = {}

function M:DumpMemorySnapshot(strSavePath, nMaxRescords)
	self.memory_cal = require("memory_cal")

	collectgarbage("collect")

	self.collectgarbageCount = collectgarbage("count")
	cRootObject = debug.getregistry()
	strRootObjectName = "registry"
	local cDumpInfoContainer = self:CreateObjectReferenceInfoContainer()
	local cStackInfo = debug.getinfo(2, "Sl")

	if cStackInfo then
		cDumpInfoContainer.m_strShortSrc = cStackInfo.short_src
		cDumpInfoContainer.m_nCurrentLine = cStackInfo.currentline
	end

	self:CollectObjectReferenceInMemory(strRootObjectName, cRootObject, cDumpInfoContainer)
	self:OutputMemorySnapshot(strSavePath, nil, nMaxRescords, strRootObjectName, cRootObject, nil, cDumpInfoContainer)

	cDumpInfoContainer = nil

	collectgarbage("collect")
end

function M:FormatDateTimeNow()
	local cDateTime = os.date("*t")
	local strDateTime = string.format("%04d%02d%02d-%02d%02d%02d", tostring(cDateTime.year), tostring(cDateTime.month), tostring(cDateTime.day), tostring(cDateTime.hour), tostring(cDateTime.min), tostring(cDateTime.sec))

	return strDateTime
end

function M:CreateObjectReferenceInfoContainer()
	local cContainer = {}
	local cObjectReferenceCount = {}

	setmetatable(cObjectReferenceCount, {
		__mode = "k"
	})

	local cObjectAddressToName = {}

	setmetatable(cObjectAddressToName, {
		__mode = "k"
	})

	cContainer.m_cObjectReferenceCount = cObjectReferenceCount
	cContainer.m_cObjectAddressToName = cObjectAddressToName
	cContainer.m_nStackLevel = -1
	cContainer.m_strShortSrc = "None"
	cContainer.m_nCurrentLine = -1
	cContainer.m_nTotalMemory = 0
	cContainer.m_cObjectMemorySize = {}

	setmetatable(cContainer.m_cObjectMemorySize, {
		__mode = "k"
	})

	return cContainer
end

function M:CollectObjectReferenceInMemory(strName, cObject, cDumpInfoContainer)
	if not cObject then
		return
	end

	strName = strName or ""
	cDumpInfoContainer = cDumpInfoContainer or self:CreateObjectReferenceInfoContainer()

	if cDumpInfoContainer.m_nStackLevel > 0 then
		local cStackInfo = debug.getinfo(cDumpInfoContainer.m_nStackLevel, "Sl")

		if cStackInfo then
			cDumpInfoContainer.m_strShortSrc = cStackInfo.short_src
			cDumpInfoContainer.m_nCurrentLine = cStackInfo.currentline
		end

		cDumpInfoContainer.m_nStackLevel = -1
	end

	local cRefInfoContainer = cDumpInfoContainer.m_cObjectReferenceCount
	local cNameInfoContainer = cDumpInfoContainer.m_cObjectAddressToName
	local strType = type(cObject)

	if strType == "table" then
		if rawget(cObject, "__cname") then
			if type(cObject.__cname) == "string" then
				strName = strName .. "[class:" .. cObject.__cname .. "]"
			end
		elseif rawget(cObject, "class") then
			if type(cObject.class) == "string" then
				strName = strName .. "[class:" .. cObject.class .. "]"
			end
		elseif rawget(cObject, "_className") and type(cObject._className) == "string" then
			strName = strName .. "[class:" .. cObject._className .. "]"
		end

		if cObject == _G then
			strName = strName .. "[_G]"
		end

		local bWeakK = false
		local bWeakV = false
		local cMt = getmetatable(cObject)

		if cMt then
			local strMode = rawget(cMt, "__mode")

			if strMode then
				if string.find(strMode, "k") then
					bWeakK = true
				end

				if string.find(strMode, "v") then
					bWeakV = true
				end
			end
		end

		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName

		for k, v in pairs(cObject) do
			local strKeyType = type(k)

			if strKeyType == "table" then
				if not bWeakK then
					self:CollectObjectReferenceInMemory(strName .. ".[table:key.table]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self:CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "function" then
				if not bWeakK then
					self:CollectObjectReferenceInMemory(strName .. ".[table:key.function]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self:CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "thread" then
				if not bWeakK then
					self:CollectObjectReferenceInMemory(strName .. ".[table:key.thread]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self:CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "userdata" then
				if not bWeakK then
					self:CollectObjectReferenceInMemory(strName .. ".[table:key.userdata]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self:CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			else
				self:CollectObjectReferenceInMemory(strName .. "." .. tostring(k), v, cDumpInfoContainer)
			end
		end

		if cMt then
			self:CollectObjectReferenceInMemory(strName .. ".[metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "function" then
		local cDInfo = debug.getinfo(cObject, "Su")
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName .. "[line:" .. tostring(cDInfo.linedefined) .. "@file:" .. cDInfo.short_src .. "]"
		local nUpsNum = cDInfo.nups

		for i = 1, nUpsNum do
			local strUpName, cUpValue = debug.getupvalue(cObject, i)
			local strUpValueType = type(cUpValue)

			if strUpValueType == "table" then
				self:CollectObjectReferenceInMemory(strName .. ".[ups:table:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "function" then
				self:CollectObjectReferenceInMemory(strName .. ".[ups:function:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "thread" then
				self:CollectObjectReferenceInMemory(strName .. ".[ups:thread:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "userdata" then
				self:CollectObjectReferenceInMemory(strName .. ".[ups:userdata:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			end
		end

		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self:CollectObjectReferenceInMemory(strName .. ".[function:environment]", cEnv, cDumpInfoContainer)
			end
		end
	elseif strType == "thread" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName
		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self:CollectObjectReferenceInMemory(strName .. ".[thread:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			self:CollectObjectReferenceInMemory(strName .. ".[thread:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "userdata" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName
		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self:CollectObjectReferenceInMemory(strName .. ".[userdata:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			self:CollectObjectReferenceInMemory(strName .. ".[userdata:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "string" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName .. "[" .. strType .. "]"
	end

	local nMemSize = self:GetObjectMemorySize(cObject)
	cDumpInfoContainer.m_cObjectMemorySize[cObject] = nMemSize
	cDumpInfoContainer.m_nTotalMemory = cDumpInfoContainer.m_nTotalMemory + nMemSize
end

function M:GetObjectMemorySize(obj)
	return self.memory_cal(obj)
end

function M:OutputMemorySnapshot(strSavePath, strExtraFileName, nMaxRescords, strRootObjectName, cRootObject, cDumpInfoResultsBase, cDumpInfoResults)
	if not cDumpInfoResults then
		return
	end

	local strDateTime = self:FormatDateTimeNow()
	local cRefInfoBase = cDumpInfoResultsBase and cDumpInfoResultsBase.m_cObjectReferenceCount or nil
	local cRefInfo = cDumpInfoResults.m_cObjectReferenceCount
	local cNameInfo = cDumpInfoResults.m_cObjectAddressToName
	local memoryInfo = cDumpInfoResults.m_cObjectMemorySize
	local cRes = {}
	local nIdx = 0

	for k in pairs(memoryInfo) do
		nIdx = nIdx + 1
		cRes[nIdx] = k
	end

	table.sort(cRes, function (l, r)
		return memoryInfo[r] < memoryInfo[l]
	end)

	local bOutputFile = strSavePath and string.len(strSavePath) > 0
	local cOutputHandle = nil
	local cOutputEntry = print

	if bOutputFile then
		local strAffix = string.sub(strSavePath, -1)

		if strAffix ~= "/" and strAffix ~= "\\" then
			strSavePath = strSavePath .. "/"
		end

		local strFileName = strSavePath .. "LuaMemRefInfo-All" .. "-[" .. strDateTime .. "].txt"
		local cFile = assert(io.open(strFileName, "w"))
		cOutputHandle = cFile
		cOutputEntry = cFile.write
	end

	local function cOutputer(strContent)
		if cOutputHandle then
			cOutputEntry(cOutputHandle, strContent)
		else
			cOutputEntry(strContent)
		end
	end

	if strRootObjectName and cRootObject then
		if type(cRootObject) == "string" then
			cOutputer("-- From Root Object: \"" .. tostring(cRootObject) .. "\" (" .. strRootObjectName .. ")\n")
		else
			cOutputer("-- From Root Object: " .. self:GetOriginalToStringResult(cRootObject) .. " (" .. strRootObjectName .. ")\n")
		end
	end

	cOutputer("--------------------------------------------------------\n")
	cOutputer(string.format("-- Total Memory Usage: %.2f KB\n", cDumpInfoResults.m_nTotalMemory / 1024))
	cOutputer(string.format("-- collectgarbage(count): %.2f KB\n", self.collectgarbageCount))
	cOutputer("--------------------------------------------------------\n")
	cOutputer("-- [Table/Function/String Address/Name]\t[Reference Path]\t[Reference Count]\t[memory size KB]\n")
	cOutputer("--------------------------------------------------------\n")

	for i, v in ipairs(cRes) do
		if not cDumpInfoResultsBase or not cRefInfoBase[v] then
			local nMemSize = cDumpInfoResults.m_cObjectMemorySize[v] or 0

			if cNameInfo[v] and cRefInfo[v] then
				cOutputer(string.format("%s\t%s\t%d\t%.2f\tkb\n", self:GetOriginalToStringResult(v), cNameInfo[v], cRefInfo[v], nMemSize / 1024))
			end
		end
	end

	if bOutputFile then
		io.close(cOutputHandle)

		cOutputHandle = nil
	end

	cDumpInfoResults.m_cObjectMemorySize = nil
	cDumpInfoResults.m_cObjectReferenceCount = nil
	cDumpInfoResults.m_cObjectAddressToName = nil

	collectgarbage()
end

function M:GetOriginalToStringResult(cObject)
	if not cObject then
		return ""
	end

	local cMt = getmetatable(cObject)

	if not cMt then
		return tostring(cObject)
	end

	local strName = ""
	local cToString = rawget(cMt, "__tostring")

	if cToString then
		rawset(cMt, "__tostring", nil)

		strName = tostring(cObject)

		rawset(cMt, "__tostring", cToString)
	else
		strName = tostring(cObject)
	end

	return strName
end

function M:testSizeCal()
	self.memory_cal = require("memory_cal")
	local mem_table_before = collectgarbage("count")
	local tabletest = {
		c = true,
		a = 1,
		b = "test"
	}
	local mem_table_after = collectgarbage("count")
	local luacalvalue = (mem_table_after - mem_table_before) * 1024
	local self_calsize = self.memory_cal(tabletest)

	print("Table 内存占用 ---》: " .. self_calsize .. " B,   collectgarbage('count') 计算 : " .. luacalvalue .. " B")

	local mem_function_before = collectgarbage("count")

	local function functiontest()
		return "hello"
	end

	local mem_function_after = collectgarbage("count")
	local luacalvalue = (mem_function_after - mem_function_before) * 1024
	local self_calsize = self.memory_cal(functiontest)

	print("Function 内存占用 ---》: " .. self_calsize .. " B,   collectgarbage('count') 计算 : " .. luacalvalue .. " B")

	local mem_thread_before = collectgarbage("count")
	local threadtest = coroutine.create(function ()
		return "hello"
	end)
	local mem_thread_after = collectgarbage("count")
	local luacalvalue = (mem_thread_after - mem_thread_before) * 1024
	local self_calsize = self.memory_cal(threadtest)
	self_calsize = self_calsize + self.memory_cal(function ()
		return "hello"
	end)

	print("Thread 内存占用 ---》: " .. self_calsize .. " B,   collectgarbage('count') 计算 : " .. luacalvalue .. " B")
end

function M:Snapshot(savePath)
	local strDateTime = self:FormatDateTimeNow()

	snapshot(savePath .. "/LuaMemInfo-All" .. "-[" .. strDateTime .. "].txt")
end

gAnalyzeMemoryMgr = M
