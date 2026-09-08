-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\CoreHudUIManager_Tag.lua
-- Decompiled from: 02233_CoreHudUIManager_Tag.lua_3ebd0f3c6951.luajit

local CoreHudButtonTagMapConfig = LTConfig.CoreHudButtonTagMapConfig
local M = C_CoreHudUIManager
local TAG_PROPERTIES = {
	"\\xef\\xd2(\\xf4",
	"Fx\\xb8r^\\xb3\\xf1SkxrI",
	"\\xea\\xd3\n*-\\xe1"
}

M.OnInitGameplayTagData = function(self)
	local pcMap = {}
	local mobileMap = {}
	local mobileOverrideKeys = {}

	for i = 0, CoreHudButtonTagMapConfig.count - 1 do
		local cfg = CoreHudButtonTagMapConfig.LoadAt(i)

		if cfg.Platform ~= 1 then
			for _, prop in ipairs(TAG_PROPERTIES) do
				if cfg[prop] ~= 1 then
					local key = string.format("%d_%s", cfg.ButtonEnum, prop)
					mobileOverrideKeys[key] = true
				end
			end
		end
	end

	for i = 0, CoreHudButtonTagMapConfig.count - 1 do
		local cfg = CoreHudButtonTagMapConfig.LoadAt(i)

		if cfg.Platform ~= 1 then
			mobileMap[cfg.QueryId] = mobileMap[cfg.QueryId] or {}

			table.insert(mobileMap[cfg.QueryId], {
				cfg = cfg
			})
		elseif cfg.Platform ~= 0 then
			pcMap[cfg.QueryId] = pcMap[cfg.QueryId] or {}

			table.insert(pcMap[cfg.QueryId], {
				cfg = cfg
			})

			local activeMobileProps = {}

			for _, prop in ipairs(TAG_PROPERTIES) do
				if cfg[prop] ~= 1 then
					local key = string.format("%d_%s", cfg.ButtonEnum, prop)

					if not mobileOverrideKeys[key] then
						activeMobileProps[prop] = true
					end
				end
			end

			if next(activeMobileProps) then
				mobileMap[cfg.QueryId] = mobileMap[cfg.QueryId] or {}

				table.insert(mobileMap[cfg.QueryId], {
					cfg = cfg,
					props = activeMobileProps
				})
			end
		end
	end

	self._queryIdMapByPlatform = {
		pc = pcMap,
		mobile = mobileMap
	}

	self.ApplyGameplayTagPlatform(self)
end

M.ApplyGameplayTagPlatform = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.queryIdToButtonInfo = isMobile and self._queryIdMapByPlatform.mobile or self._queryIdMapByPlatform.pc
end

M.DebugPrintButtonTagInfo = function(self, targetButtonEnum)
	if table.isNilOrEmpty(self.queryIdToButtonInfo) then
		print("[TagDebug] queryIdToButtonInfo 尚未初始化")

		return
	end

	print(string.format("[TagDebug] ButtonEnum=%s 当前生效的 GameplayTag Query:", tostring(targetButtonEnum)))

	local found = false

	for queryId, entryList in pairs(self.queryIdToButtonInfo) do
		for _, entry in ipairs(entryList) do
			local cfg = entry.cfg

			if cfg.ButtonEnum ~= targetButtonEnum then
				found = true
				local activeProps = {}
				local props = entry.props

				for _, prop in ipairs(TAG_PROPERTIES) do
					if cfg[prop] ~= 1 and (props ~= nil or props[prop]) then
						activeProps[#activeProps + 1] = prop
					end
				end

				print(string.format("  QueryId=%-6s 影响属性: [%s]", tostring(queryId), table.concat(activeProps, ", ")))
			end
		end
	end

	if not found then
		print("  (无匹配记录)")
	end
end
