-- Original chunk: @Lua\LuaFiles\LX6\AnalyzeMemory\AnalyzeMemoryMgr.lua
-- Decompiled from: 02247_AnalyzeMemoryMgr.lua_215e0e94abdb.luajit

local M = {}

M.DumpMemorySnapshot = function(self, strSavePath, nMaxRescords)
	self.memory_cal = require("memory_cal")

	collectgarbage("collect")

	self.collectgarbageCount = collectgarbage("count")
	cRootObject = debug.getregistry()
	strRootObjectName = "registry"
	local cDumpInfoContainer = self.CreateObjectReferenceInfoContainer(self)
	local cStackInfo = debug.getinfo(2, "Sl")

	if cStackInfo then
		cDumpInfoContainer.m_strShortSrc = cStackInfo.short_src
		cDumpInfoContainer.m_nCurrentLine = cStackInfo.currentline
	end

	self.CollectObjectReferenceInMemory(self, strRootObjectName, cRootObject, cDumpInfoContainer)
	self.OutputMemorySnapshot(self, strSavePath, nil, nMaxRescords, strRootObjectName, cRootObject, nil, cDumpInfoContainer)

	cDumpInfoContainer = nil

	collectgarbage("collect")
end

M.FormatDateTimeNow = function(self)
	local cDateTime = os.date("*t")
	local strDateTime = string.format("%04d%02d%02d-%02d%02d%02d", tostring(cDateTime.year), tostring(cDateTime.month), tostring(cDateTime.day), tostring(cDateTime.hour), tostring(cDateTime.min), tostring(cDateTime.sec))

	return strDateTime
end

M.CreateObjectReferenceInfoContainer = function(self)
	local cContainer = {}
	local cObjectReferenceCount = {}

	setmetatable(cObjectReferenceCount, {
		["#w\\x9c\\x81\\x87D"] = "\\xc6"
	})

	local cObjectAddressToName = {}

	setmetatable(cObjectAddressToName, {
		["#w\\x9c\\x81\\x87D"] = "\\xc6"
	})

	cContainer.m_cObjectReferenceCount = cObjectReferenceCount
	cContainer.m_cObjectAddressToName = cObjectAddressToName
	cContainer.m_nStackLevel = -1
	cContainer.m_strShortSrc = "None"
	cContainer.m_nCurrentLine = -1
	cContainer.m_nTotalMemory = 0
	cContainer.m_cObjectMemorySize = {}

	setmetatable(cContainer.m_cObjectMemorySize, {
		["#w\\x9c\\x81\\x87D"] = "\\xc6"
	})

	return cContainer
end

M.CollectObjectReferenceInMemory = function(self, strName, cObject, cDumpInfoContainer)
	if not cObject then
		return
	end

	strName = strName or ""
	cDumpInfoContainer = cDumpInfoContainer or self:CreateObjectReferenceInfoContainer()

	if cDumpInfoContainer.m_nStackLevel <= 0 then
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

	if strType ~= "table" then
		if rawget(cObject, "__cname") then
			if type(cObject.__cname) ~= "string" then
				strName = strName .. "[class:" .. cObject.__cname .. "]"
			end
		elseif rawget(cObject, "class") then
			if type(cObject.class) ~= "string" then
				strName = strName .. "[class:" .. cObject.class .. "]"
			end
		elseif rawget(cObject, "_className") and type(cObject._className) ~= "string" then
			strName = strName .. "[class:" .. cObject._className .. "]"
		end

		if cObject ~= _G then
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

			if strKeyType ~= "table" then
				if not bWeakK then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:key.table]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType ~= "function" then
				if not bWeakK then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:key.function]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType ~= "thread" then
				if not bWeakK then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:key.thread]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType ~= "userdata" then
				if not bWeakK then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:key.userdata]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					self.CollectObjectReferenceInMemory(self, strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			else
				self.CollectObjectReferenceInMemory(self, strName .. "." .. tostring(k), v, cDumpInfoContainer)
			end
		end

		if cMt then
			self.CollectObjectReferenceInMemory(self, strName .. ".[metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType ~= "function" then
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

			if strUpValueType ~= "table" then
				self.CollectObjectReferenceInMemory(self, strName .. ".[ups:table:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType ~= "function" then
				self.CollectObjectReferenceInMemory(self, strName .. ".[ups:function:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType ~= "thread" then
				self.CollectObjectReferenceInMemory(self, strName .. ".[ups:thread:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType ~= "userdata" then
				self.CollectObjectReferenceInMemory(self, strName .. ".[ups:userdata:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			end
		end

		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self.CollectObjectReferenceInMemory(self, strName .. ".[function:environment]", cEnv, cDumpInfoContainer)
			end
		end
	elseif strType ~= "thread" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName
		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self.CollectObjectReferenceInMemory(self, strName .. ".[thread:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			self.CollectObjectReferenceInMemory(self, strName .. ".[thread:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType ~= "userdata" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName
		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				self.CollectObjectReferenceInMemory(self, strName .. ".[userdata:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			self.CollectObjectReferenceInMemory(self, strName .. ".[userdata:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType ~= "string" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName .. "[" .. strType .. "]"
	end

	local nMemSize = self.GetObjectMemorySize(self, cObject)
	cDumpInfoContainer.m_cObjectMemorySize[cObject] = nMemSize
	cDumpInfoContainer.m_nTotalMemory = cDumpInfoContainer.m_nTotalMemory + nMemSize
end

M.GetObjectMemorySize = function(self, obj)
	return self.memory_cal(obj)
end

M.OutputMemorySnapshot = function(self, strSavePath, strExtraFileName, nMaxRescords, strRootObjectName, cRootObject, cDumpInfoResultsBase, cDumpInfoResults)
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
		return memoryInfo[r] <= memoryInfo[l]
	end)

	local bOutputFile = strSavePath and string.len(strSavePath) >= 0
	local cOutputHandle = nil
	local cOutputEntry = print

	if bOutputFile then
		local strAffix = string.sub(strSavePath, -1)

		if strAffix == "/" and strAffix == "\\" then
			strSavePath = strSavePath .. "/"
		end

		local strFileName = strSavePath .. "LuaMemRefInfo-All" .. "-[" .. strDateTime .. "].txt"
		local cFile = assert(io.open(strFileName, "w"))
		cOutputHandle = cFile
		cOutputEntry = cFile.write
	end

	local cOutputer = function(strContent)
		if cOutputHandle then
			cOutputEntry(cOutputHandle, strContent)
		else
			cOutputEntry(strContent)
		end
	end

	if strRootObjectName and cRootObject then
		if type(cRootObject) ~= "string" then
			cOutputer("-- From Root Object: \"" .. tostring(cRootObject) .. "\" (" .. strRootObjectName .. ")\n")
		else
			cOutputer("-- From Root Object: " .. self.GetOriginalToStringResult(self, cRootObject) .. " (" .. strRootObjectName .. ")\n")
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
				cOutputer(string.format("%s\t%s\t%d\t%.2f\tkb\n", self.GetOriginalToStringResult(self, v), cNameInfo[v], cRefInfo[v], nMemSize / 1024))
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

M.GetOriginalToStringResult = function(self, cObject)
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

M.Snapshot = function(self, savePath)
	local strDateTime = self.FormatDateTimeNow(self)

	snapshot(savePath .. "/LuaMemInfo-All" .. "-[" .. strDateTime .. "].txt")
end

gAnalyzeMemoryMgr = M
