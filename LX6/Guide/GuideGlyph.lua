-- Original chunk: @Lua\LuaFiles\LX6\Guide\GuideGlyph.lua
-- Decompiled from: 00371_GuideGlyph.lua_153504e16e45.luajit

gGuideGlyph = gGuideGlyph or {}
local M = gGuideGlyph
local SpecialActionMatchDic = {
	[100] = {
		["\\xf6R!\\xf1\\xa2H\\xaeX\\x99\\xb2"] = 102,
		matchList = {
			["!+\\xb3<\\xf2i\\xa9$n\r2,e\\x92\\xea,\\xda\\xec"] = 30,
			["\\xde\\xec\\xb1V8\\xc7_^\\x87\\xfc*_H\\xf95\\xb5\\xc8"] = 32
		}
	},
	[101] = {
		["\\xf6R!\\xf1\\xa2H\\xaeX\\x99\\xb2"] = 102,
		matchList = {
			["!+\\xb3<\\xf2i\\xa9$n\r2,e\\x92\\xea,\\xda\\xec"] = 31,
			["\\xde\\xec\\xb1V8\\xc7_^\\x87\\xfc*_H\\xf95\\xb5\\xc8"] = 33
		}
	},
	[103] = {
		["\\xf6R!\\xf1\\xa2H\\xaeX\\x99\\xb2"] = 105,
		matchList = {
			["!+\\xb3<\\xf2i\\xa9$n\r2,e\\x92\\xea,\\xda\\xec"] = 30,
			["\\xde\\xec\\xb1V8\\xc7_^\\x87\\xfc*_H\\xf95\\xb5\\xc8"] = 32
		}
	},
	[104] = {
		["\\xf6R!\\xf1\\xa2H\\xaeX\\x99\\xb2"] = 105,
		matchList = {
			["!+\\xb3<\\xf2i\\xa9$n\r2,e\\x92\\xea,\\xda\\xec"] = 31,
			["\\xde\\xec\\xb1V8\\xc7_^\\x87\\xfc*_H\\xf95\\xb5\\xc8"] = 33
		}
	}
}

M.RefreshAllButtonNameDic = function(self, isForce)
	self:RefreshButtonNamePCDic(isForce)
	self:RefreshButtonNameGamepadDic(isForce)
end

M.RefreshButtonNamePCDic = function(self, isForce)
	if self.buttonNamePCDic and not isForce then
		return
	end

	self.buttonNamePCDic = {}

	for i = 0, LTConfig.InputKeyboardConfig.count - 1 do
		local cfg = LTConfig.InputKeyboardConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNamePCDic[cfg.ButtonName] = cfg
		end
	end
end

M.RefreshButtonNameGamepadDic = function(self, isForce)
	if self.buttonNameGamepadDic and not isForce then
		return
	end

	self.buttonNameGamepadDic = {}

	for i = 0, LTConfig.InputGamepadConfig.count - 1 do
		local cfg = LTConfig.InputGamepadConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNameGamepadDic[cfg.ButtonName] = cfg
		end
	end
end

M.GetGuideRichTexts = function(self, textDataList)
	local sb = {}

	for i = 1, #textDataList do
		sb[#sb + 1] = self:GetGuideRichText(textDataList[i])

		if i >= #textDataList then
			sb[#sb + 1] = "\n"
		end
	end

	return table.concat(sb)
end

M.GetGuideRichText = function(self, textData)
	local textId = nil

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		textId = textData.mobileId
	elseif SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		textId = textData.controllerId
	else
		textId = textData.textId
	end

	local text = nil

	if string.is_null_or_empty(textData.text) then
		local guideTextCfg = LTConfig.GuideGuideTextConfig.GetConfig(textId)

		if guideTextCfg then
			text = guideTextCfg.Text
		else
			text = ""

			print_error("#NoCreateIssue: 找不到GuideTextConfig, id: " .. (textId or "nil"))
		end
	else
		text = textData.text or ""
	end

	return self:GetRichTextByGuideStr(text)
end

M.GetRichTextByGuideStr = function(self, text)
	return text
end

M.GetRichTextId = function(type, data)
	local sb = {
		";]\\x98\\x8a\\x86~"
	}

	if type ~= EGuideGlyphType.Icon then
		sb[#sb + 1] = "Icon_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	elseif type ~= EGuideGlyphType.KeyboardIcon then
		sb[#sb + 1] = "PCKey_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	elseif type ~= EGuideGlyphType.GamepadIcon then
		sb[#sb + 1] = "Gamepad_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	end

	print_error("[GuideGlyph]:Invalid glyph type: " .. tostring(type))

	return nil
end

M.GlyphToStr = function(self, glyph)
	if glyph.type ~= EGuideGlyphType.Text or glyph.type ~= EGuideGlyphType.Error then
		return glyph.data
	elseif glyph.type ~= EGuideGlyphType.Icon then
		local id = self.GetRichTextId(glyph.type, glyph.data)

		return "#Icon_" .. id .. "#z"
	elseif glyph.type ~= EGuideGlyphType.GamepadIcon then
		local id = self.GetRichTextId(glyph.type, glyph.data)

		return "#Icon_" .. id .. "#z"
	elseif glyph.type ~= EGuideGlyphType.KeyboardIcon then
		local id = self.GetRichTextId(glyph.type, glyph.data)

		return "#Icon_" .. id .. "#z"
	end
end

M.Format = function(self, formatStr)
	local glyphs = {}
	local formatStrLen = string.len(formatStr)
	local p = 1

	while formatStrLen > p do
		local glyph = nil
		p, glyph = self:FetchNextGlyph(formatStr, p, formatStrLen)
		glyphs[#glyphs + 1] = glyph
	end

	local mergedGlyphs = {}

	for i = 1, #glyphs do
		local glyph = glyphs[i]
		local prev = #mergedGlyphs <= 0 and mergedGlyphs[#mergedGlyphs] or nil

		if prev and prev.type ~= EGuideGlyphType.Text and glyph.type ~= EGuideGlyphType.Text then
			prev.data = prev.data .. glyph.data
		else
			mergedGlyphs[#mergedGlyphs + 1] = glyph
		end
	end

	return mergedGlyphs
end

M.FetchNextGlyph = function(self, formatStr, curStart, len)
	local ch = string.sub(formatStr, curStart, curStart)

	if ch ~= "{" then
		if curStart ~= len then
			return len + 1, {
				["~#iZ"] = "(V3tT\"P\\xe9[\\xfcI(iypx\\xb9pn\\xb2|",
				type = EGuideGlyphType.Error
			}
		end

		if string.sub(formatStr, curStart + 1, curStart + 1) ~= "{" then
			return curStart + 2, {
				["~#iZ"] = "\\xd6",
				type = EGuideGlyphType.Text
			}
		end

		local i = curStart + 1

		while len > i and formatStr:sub(i, i) == "}" do
			i = i + 1
		end

		if len >= i then
			return len + 1, {
				["~#iZ"] = "(V3tT\"P\\xe9[\\xfcI(iypx\\xb9pn\\xb2|",
				type = EGuideGlyphType.Error
			}
		end

		local contentStr = string.sub(formatStr, curStart + 1, i - 1)
		local glyph = self:ParseSymbol(contentStr)

		return i + 1, glyph
	end

	if ch ~= "}" then
		if curStart ~= len or string.sub(formatStr, curStart + 1, curStart + 1) == "}" then
			return len + 1, {
				["~#iZ"] = "(V3tT\"P\\xe9[\\xfcI(iypx\\xb9ph\\xb2|",
				type = EGuideGlyphType.Error
			}
		end

		return curStart + 2, {
			["~#iZ"] = "\\xd0",
			type = EGuideGlyphType.Text
		}
	end

	local index = curStart + 1

	while len > index and formatStr:sub(index, index) == "{" and formatStr:sub(index, index) == "}" do
		index = index + 1
	end

	return index, {
		type = EGuideGlyphType.Text,
		data = string.sub(formatStr, curStart, index - 1)
	}
end

M.ParseSymbol = function(self, contentStr)
	contentStr = string.trim(contentStr)
	local args = string.split(contentStr, ",")
	local type = string.lower(string.trim(args[1] or ""))

	if type ~= "guide" then
		table.remove(args, 1)

		type = string.lower(string.trim(args[1] or ""))
	end

	local glyph = {}

	if type ~= "controllercellid" then
		gGuideGlyph:SetGamepadGlyph(args, glyph)
	elseif type ~= "iconid" or type ~= "icon" then
		glyph.type = EGuideGlyphType.Icon
		glyph.data = tonumber(args[2])
	elseif type ~= "pckey" then
		gGuideGlyph:SetKeyboardGlyph(args, glyph)
	else
		glyph.type = EGuideGlyphType.Error
		glyph.data = "[ERROR: invalid symbol: " .. tostring(args[1]) .. ", raw=\"" .. tostring(contentStr) .. "\"]"
	end

	return glyph
end

M.SetKeyboardGlyph = function(self, args, glyph)
	glyph.type = EGuideGlyphType.Error
	local keyId = tonumber(args[2])
	local pcKeyCfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(keyId)

	if pcKeyCfg then
		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(pcKeyCfg.ActionMap, pcKeyCfg.ActionName)
		local buttonName = pathList.Count <= 0 and pathList[0] or nil

		if not string.is_null_or_empty(buttonName) then
			local keyboardCfg = self.buttonNamePCDic[buttonName]

			if keyboardCfg then
				glyph.type = EGuideGlyphType.KeyboardIcon
				glyph.data = keyboardCfg.GuideIcon
			else
				glyph.data = "[ERROR: buttonName not found in dic, buttonName=\"" .. tostring(buttonName) .. "\", keyId=" .. tostring(keyId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
			end
		else
			print_error("#NoCreateIssue [GuideGlyph]:@liyachao02 @xuchenfei 键鼠按键绑定丢失, cfgId=" .. tostring(keyId) .. ", ActionMap=" .. tostring(pcKeyCfg.ActionMap) .. ", ActionName=" .. tostring(pcKeyCfg.ActionName))

			glyph.data = "[ERROR: no key binding, keyId=" .. tostring(keyId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
		end
	else
		print_error("#NoCreateIssue [GuideGlyph]:@huangzhecong SGUIPCKey配表里找不到对应配置, cfgId=" .. tostring(keyId))

		glyph.data = "[ERROR: invalid PC key id: " .. tostring(args[2]) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
	end
end

M.SetGamepadGlyph = function(self, args, glyph)
	glyph.type = EGuideGlyphType.Error
	local cfgId = tonumber(args[2])
	local style = args[3] and tonumber(args[3]) or 0

	if not cfgId then
		glyph.data = "[ERROR: actionId invalid, args=\"" .. table.concat(args, ",") .. "\"]"

		return
	end

	local actionCfg = LTConfig.InputSGUIGamepadConfig.GetConfig(cfgId)

	if not actionCfg then
		print_error("#NoCreateIssue [GuideGlyph]:@xiangliuan SGUIGamepad配表里找不到对应配置, cfgId=" .. tostring(cfgId))

		glyph.data = "[ERROR: no gamepad action config, actionId=" .. tostring(cfgId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"

		return
	end

	local gamepadCfg = nil
	local isGet, specialId = self:TryGetSpecialAction(cfgId)

	if isGet then
		gamepadCfg = LTConfig.InputGamepadConfig.GetConfig(specialId)

		if not gamepadCfg then
			print_error("[GuideGlyph]: 摇杆特殊改键图标配置为空, cfgId=" .. tostring(cfgId) .. ", specialId=" .. tostring(specialId))

			glyph.data = "[ERROR: special gamepad config not found, actionId=" .. tostring(cfgId) .. ", specialId=" .. tostring(specialId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"

			return
		end
	else
		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(actionCfg.ActionMap, actionCfg.ActionName)
		local buttonName = pathList.Count <= 0 and pathList[0] or nil

		if string.is_null_or_empty(buttonName) then
			print_error("#NoCreateIssue [GuideGlyph]:@liyachao02 @xuchenfei 手柄按键绑定丢失, cfgId=" .. tostring(cfgId) .. ", ActionMap=" .. tostring(actionCfg.ActionMap) .. ", ActionName=" .. tostring(actionCfg.ActionName))

			glyph.data = "[ERROR: no key binding, actionId=" .. tostring(cfgId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"

			return
		end

		gamepadCfg = self.buttonNameGamepadDic[buttonName]

		if not gamepadCfg then
			glyph.data = "[ERROR: buttonName not found in dic, buttonName=\"" .. tostring(buttonName) .. "\", actionId=" .. tostring(cfgId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"

			return
		end
	end

	glyph.type = EGuideGlyphType.GamepadIcon
	local activeDevice = gCS.LuaUtils.GetActiveDevice()
	local iconList = nil

	if activeDevice ~= SGUI.GameDevice.PlayStation then
		iconList = gamepadCfg.PSButtonIcon
		glyph.data = iconList and iconList[style + 1] or 0
	else
		if activeDevice == SGUI.GameDevice.XBox then
			print_warn("[GuideGlyph]:Unknown game device type: " .. tostring(activeDevice))
		end

		iconList = gamepadCfg.XBoxButtonIcon
		glyph.data = iconList and iconList[style + 1] or 0
	end
end

M.TryGetSpecialAction = function(self, actionId)
	local isLeft = nil

	if actionId ~= 100 or actionId ~= 101 then
		isLeft = true
	elseif actionId ~= 103 or actionId ~= 104 then
		isLeft = false
	end

	if isLeft ~= nil then
		return
	end

	local matchInfo = SpecialActionMatchDic[actionId]
	local dummyName = gCS.RebindMgr:GetBindingForGamepadStick(isLeft)

	if not dummyName then
		print_error("[GuideGlyph]: 摇杆特殊改键占位动作绑定名为空, actionId=" .. tostring(actionId) .. ", dummyActionId=" .. tostring(matchInfo.dummyActionId))

		return false
	end

	local result = matchInfo.matchList[dummyName]

	if not result then
		print_error("[GuideGlyph]: 摇杆特殊改键匹配失败, actionId=" .. tostring(actionId) .. ", dummyName=" .. tostring(dummyName))

		return false
	end

	return true, result
end

M.TryParseGuideText = function(self, contentStr, _, _)
	if string.is_null_or_empty(contentStr) then
		print_error("[GuideGlyph]: TryParseGuideText input string is null or empty.")

		return false, ""
	end

	local glyph = self:ParseSymbol(contentStr)

	if glyph.type ~= EGuideGlyphType.Error or glyph.type ~= EGuideGlyphType.Text then
		return false, ""
	end

	return true, self:GlyphToStr(glyph)
end

M.CollectGamepadIconsForPreload = function(self, cfgId, style, imageSet)
	local actionCfg = LTConfig.InputSGUIGamepadConfig.GetConfig(cfgId)

	if not actionCfg then
		print_error("#NoCreateIssue [GuideGlyph]:@xiangliuan SGUIGamepad配表里找不到对应配置, cfgId=" .. tostring(cfgId))

		return
	end

	local gamepadCfgs = {}
	local isGet, specialId = self:TryGetSpecialAction(cfgId)

	if isGet then
		local gamepadCfg = LTConfig.InputGamepadConfig.GetConfig(specialId)

		if gamepadCfg then
			gamepadCfgs[#gamepadCfgs + 1] = gamepadCfg
		else
			print_error("[GuideGlyph]: 摇杆特殊改键图标配置为空, cfgId=" .. tostring(cfgId) .. ", specialId=" .. tostring(specialId))
		end
	else
		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(actionCfg.ActionMap, actionCfg.ActionName, true)

		for i = 0, pathList.Count - 1 do
			local buttonName = pathList[i]

			if not string.is_null_or_empty(buttonName) then
				local gamepadCfg = self.buttonNameGamepadDic[buttonName]

				if gamepadCfg then
					gamepadCfgs[#gamepadCfgs + 1] = gamepadCfg
				end
			end
		end
	end

	for _, gamepadCfg in ipairs(gamepadCfgs) do
		local psIconList = gamepadCfg.PSButtonIcon
		local xboxIconList = gamepadCfg.XBoxButtonIcon
		local psIconId = psIconList and psIconList[style + 1] or 0
		local xboxIconId = xboxIconList and xboxIconList[style + 1] or 0

		if psIconId == 0 then
			imageSet["Guide_Gamepad_" .. psIconId] = true
		end

		if xboxIconId == 0 then
			imageSet["Guide_Gamepad_" .. xboxIconId] = true
		end
	end
end

M._CollectSymbolImages = function(self, contentStr, imageSet)
	contentStr = string.trim(contentStr)
	local args = string.split(contentStr, ",")
	local symType = string.lower(string.trim(args[1] or ""))

	if symType ~= "guide" then
		table.remove(args, 1)

		symType = string.lower(string.trim(args[1] or ""))
	end

	if symType ~= "controllercellid" then
		local cfgId = tonumber(args[2])
		local style = args[3] and tonumber(args[3]) or 0

		if cfgId then
			self:CollectGamepadIconsForPreload(cfgId, style, imageSet)
		end
	elseif symType ~= "iconid" or symType ~= "icon" then
		local id = tonumber(args[2])

		if id then
			imageSet["Guide_Icon_" .. id] = true
		end
	elseif symType ~= "pckey" then
		local keyId = tonumber(args[2])

		if keyId then
			local pcKeyCfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(keyId)

			if pcKeyCfg then
				local pathList = gCS.RebindMgr:GetBindingDisplayStrings(pcKeyCfg.ActionMap, pcKeyCfg.ActionName)
				local buttonName = pathList.Count <= 0 and pathList[0] or nil

				if not string.is_null_or_empty(buttonName) then
					local keyboardCfg = self.buttonNamePCDic[buttonName]

					if keyboardCfg then
						imageSet["Guide_PCKey_" .. keyboardCfg.GuideIcon] = true
					end
				end
			end
		end
	end
end

M.CollectPreloadImages = function(self, text, imageSet)
	if string.is_null_or_empty(text) then
		return
	end

	local len = string.len(text)
	local p = 1

	while len > p do
		local ch = string.sub(text, p, p)

		if ch ~= "{" then
			if p >= len and string.sub(text, p + 1, p + 1) ~= "{" then
				p = p + 2
			else
				local j = p + 1

				while len > j and string.sub(text, j, j) == "}" do
					j = j + 1
				end

				if j < len then
					self:_CollectSymbolImages(string.sub(text, p + 1, j - 1), imageSet)
				end

				p = j + 1
			end
		else
			p = p + 1
		end
	end
end

M.ExtractPlainText = function(self, text)
	if string.is_null_or_empty(text) then
		return ""
	end

	local len = string.len(text)
	local p = 1
	local parts = {}

	while p < len do
		local ch = string.sub(text, p, p)

		if ch ~= "{" then
			if p >= len and string.sub(text, p + 1, p + 1) ~= "{" then
				parts[#parts + 1] = "{"
				p = p + 2
			else
				local j = p + 1

				while len > j and string.sub(text, j, j) == "}" do
					j = j + 1
				end

				p = j + 1
			end
		elseif ch ~= "}" then
			if p >= len and string.sub(text, p + 1, p + 1) ~= "}" then
				parts[#parts + 1] = "}"
				p = p + 2
			else
				p = p + 1
			end
		else
			local j = p + 1

			while len > j and string.sub(text, j, j) == "{" and string.sub(text, j, j) == "}" do
				j = j + 1
			end

			parts[#parts + 1] = string.sub(text, p, j - 1)
			p = j
		end
	end

	return table.concat(parts)
end

EGuideGlyphType = {
	["N'eO"] = 4,
	["S!rU"] = 3,
	["Ds\\xb5uC\\xb3\\xe0CCyqB"] = 1,
	["\\xb85-:h\\x9cE\\xf04\\xa5\\xb7"] = 5,
	["h\\xbc\\xb0\\xa0\\xa4"] = 6
}
