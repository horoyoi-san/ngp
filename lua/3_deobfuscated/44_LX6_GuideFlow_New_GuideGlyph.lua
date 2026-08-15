gGuideGlyph = gGuideGlyph or {}
local M = gGuideGlyph
local SpecialActionMatchDic = {
	[100] = {
		dummyActionId = 102,
		matchList = {
			["<Gamepad>/leftStick"] = "<Gamepad>/leftStickX",
			["<Gamepad>/rightStick"] = "<Gamepad>/rightStickY"
		}
	},
	[101] = {
		dummyActionId = 102,
		matchList = {
			["<Gamepad>/leftStick"] = "<Gamepad>/leftStickY",
			["<Gamepad>/leftStick/left"] = "<Gamepad>/leftStickX"
		}
	},
	[103] = {
		dummyActionId = 105,
		matchList = {
			["<Gamepad>/rightStick"] = "<Gamepad>/rightStickX",
			["<Gamepad>/rightStick/left"] = "<Gamepad>/rightStickY"
		}
	},
	[104] = {
		dummyActionId = 105,
		matchList = {
			["<Gamepad>/rightStick"] = "<Gamepad>/rightStickY",
			["<Gamepad>/rightStick/up"] = "<Gamepad>/rightStickX"
		}
	}
}

function M:RefreshAllButtonNameDic(isForce)
	self:RefreshButtonNamePCDic(isForce)
	self:RefreshButtonNameGamepadDic(isForce)
end

function M:RefreshButtonNamePCDic(isForce)
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

function M:RefreshButtonNameGamepadDic(isForce)
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

function M:RenderGuideText(guideTextBase, textData)
	local store = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(guideTextBase)

	self:RenderGuideGlyphList(store.glyphList, textData)
end

function M:RenderGuideGlyphList(glyphListView, textData)
	function glyphListView.luaRenderItem(widget, index, data)
		self:RenderItems(widget, index, data)
	end

	local rDatas = {}
	local textId = nil

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		textId = textData.mobileId
	elseif SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
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

	local glyphs = self:Format(text)

	for i = 1, #glyphs do
		local glyph = glyphs[i]
		local rData = {}

		if glyph.type == EGuideGlyphType.Text then
			rData.tIndex = 2
			rData.text = glyph.data
		elseif glyph.type == EGuideGlyphType.Icon then
			rData.tIndex = 0
			rData.iconId = glyph.data
		elseif glyph.type == EGuideGlyphType.ControllerActionId then
			rData.tIndex = 3
			rData.actionId = glyph.data.actionId
			rData.style = glyph.data.style
		else
			rData.tIndex = 2
			rData.text = "<Error>"
		end

		rDatas[#rDatas + 1] = rData
	end

	glyphListView:SetList(rDatas)
end

function M:GetGuideRichTexts(textDataList)
	local sb = {}

	for i = 1, #textDataList do
		sb[#sb + 1] = self:GetGuideRichText(textDataList[i])

		if i < #textDataList then
			sb[#sb + 1] = "\n"
		end
	end

	return table.concat(sb)
end

function M:GetGuideRichText(textData)
	local textId = nil

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		textId = textData.mobileId
	elseif SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
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

function M:GetRichTextByGuideStr(text)
	local glyphs = self:Format(text)
	local sb = {}

	for i = 1, #glyphs do
		local glyph = glyphs[i]

		if glyph.type == EGuideGlyphType.Text then
			sb[#sb + 1] = glyph.data
		elseif glyph.type == EGuideGlyphType.Icon then
			sb[#sb + 1] = "#Icon_" .. self.GetRichTextId(glyph.type, glyph.data) .. "#z"
		elseif glyph.type == EGuideGlyphType.KeyboardIcon then
			sb[#sb + 1] = "#Icon_" .. self.GetRichTextId(glyph.type, glyph.data) .. "#z"
		elseif glyph.type == EGuideGlyphType.GamepadIcon then
			sb[#sb + 1] = "#Icon_" .. self.GetRichTextId(glyph.type, glyph.data) .. "#z"
		end
	end

	return table.concat(sb)
end

function M:GetRichTextByGuideStrV1(text, imageSet)
	imageSet = imageSet or {}
	local glyphs = self:Format(text)
	local sb = {}

	for i = 1, #glyphs do
		local glyph = glyphs[i]

		if glyph.type == EGuideGlyphType.Text then
			sb[#sb + 1] = glyph.data
		elseif glyph.type == EGuideGlyphType.Icon then
			local id = self.GetRichTextId(glyph.type, glyph.data)
			sb[#sb + 1] = "#Icon_" .. id .. "#z"
			imageSet[id] = true
		elseif glyph.type == EGuideGlyphType.GamepadIcon then
			local id = self.GetRichTextId(glyph.type, glyph.data)
			sb[#sb + 1] = "#Icon_" .. id .. "#z"
			imageSet[id] = true
		elseif glyph.type == EGuideGlyphType.KeyboardIcon then
			local id = self.GetRichTextId(glyph.type, glyph.data)
			sb[#sb + 1] = "#Icon_" .. id .. "#z"
			imageSet[id] = true
		end
	end

	return table.concat(sb)
end

function M.GetRichTextId(type, data)
	local sb = {
		"Guide_"
	}

	if type == EGuideGlyphType.ControllerActionId then
		local activeDevice = gCS.LuaUtils.GetActiveDevice()

		if activeDevice == SGUI.GameDevice.PlayStation then
			sb[#sb + 1] = "PS_"
		elseif activeDevice == SGUI.GameDevice.Xbox then
			sb[#sb + 1] = "XBOX_"
		else
			print_warn("[GuideGlyph]:Unknown game device type: " .. tostring(activeDevice))

			sb[#sb + 1] = "XBOX_"
		end

		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	elseif type == EGuideGlyphType.Icon then
		sb[#sb + 1] = "Icon_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	elseif type == EGuideGlyphType.KeyboardIcon then
		sb[#sb + 1] = "PCKey_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	elseif type == EGuideGlyphType.GamepadIcon then
		sb[#sb + 1] = "Gamepad_"
		sb[#sb + 1] = tostring(data)

		return table.concat(sb)
	end

	print_error("[GuideGlyph]:Invalid glyph type: " .. tostring(type))

	return nil
end

function M:RenderItems(btn, index, data)
	local store = gStoreManager:GetStoreGroup("GuideAnonymousStore"):GetStoreByWidget(btn)

	if data.tIndex == 0 then
		store.iconId = data.iconId
		local icon = store.icon

		icon:SetNativeSize()
	elseif data.tIndex == 2 then
		store.text = data.text
	elseif data.tIndex == 3 then
		local actionId = data.actionId
		local style = data.style or 0
		local singleIcon = store.singleIcon

		singleIcon:ChangeDeviceGamePadAction("GamePad", actionId, style, nil)
	end
end

function M:Format(formatStr)
	self:RefreshAllButtonNameDic(false)

	local glyphs = {}
	local formatStrLen = string.len(formatStr)
	local p = 1

	while formatStrLen >= p do
		local glyph = nil
		p, glyph = self.FetchNextGlyph(formatStr, p, formatStrLen)
		glyphs[#glyphs + 1] = glyph
	end

	local mergedGlyphs = {}

	for i = 1, #glyphs do
		local glyph = glyphs[i]
		local prev = #mergedGlyphs > 0 and mergedGlyphs[#mergedGlyphs] or nil

		if prev and prev.type == EGuideGlyphType.Text and glyph.type == EGuideGlyphType.Text then
			prev.data = prev.data .. glyph.data
		else
			mergedGlyphs[#mergedGlyphs + 1] = glyph
		end
	end

	return mergedGlyphs
end

function M.FetchNextGlyph(formatStr, curStart, len)
	local ch = string.sub(formatStr, curStart, curStart)

	if ch == "{" then
		if curStart == len then
			return len + 1, {
				data = "[ERROR: unmatched '{']",
				type = EGuideGlyphType.Text
			}
		end

		if string.sub(formatStr, curStart + 1, curStart + 1) == "{" then
			return curStart + 2, {
				data = "{",
				type = EGuideGlyphType.Text
			}
		end

		local i = curStart + 1

		while len >= i and formatStr:sub(i, i) ~= "}" do
			i = i + 1
		end

		if len < i then
			return len + 1, {
				data = "[ERROR: unmatched '{']",
				type = EGuideGlyphType.Text
			}
		end

		local contentStr = string.sub(formatStr, curStart + 1, i - 1)
		local glyph = M.ParseSymbol(contentStr)

		return i + 1, glyph
	end

	if ch == "}" then
		if curStart == len or string.sub(formatStr, curStart + 1, curStart + 1) ~= "}" then
			return len + 1, {
				data = "[ERROR: unmatched '}']",
				type = EGuideGlyphType.Text
			}
		end

		return curStart + 2, {
			data = "}",
			type = EGuideGlyphType.Text
		}
	end

	local index = curStart + 1

	while len >= index and formatStr:sub(index, index) ~= "{" and formatStr:sub(index, index) ~= "}" do
		index = index + 1
	end

	return index, {
		type = EGuideGlyphType.Text,
		data = string.sub(formatStr, curStart, index - 1)
	}
end

function M.ParseSymbol(contentStr)
	contentStr = string.trim(contentStr)
	local sep = nil

	if string.find(contentStr, "|") then
		sep = "|"
	elseif string.find(contentStr, ",") then
		sep = ","
	end

	if not sep then
		return {
			type = EGuideGlyphType.Text,
			data = "[ERROR: invalid placeholder, content=\"" .. tostring(contentStr) .. "\"]"
		}
	end

	local args = string.split(contentStr, sep)
	local type = string.lower(string.trim(args[1] or ""))
	local glyph = {}

	if type == "controllercellid" then
		gGuideGlyph:SetGamepadGlyph(args, glyph)
	elseif type == "iconid" or type == "icon" then
		glyph.type = EGuideGlyphType.Icon
		glyph.data = tonumber(args[2])
	elseif type == "pckey" then
		gGuideGlyph:SetKeyboardGlyph(args, glyph)
	else
		glyph.type = EGuideGlyphType.Text
		glyph.data = "[ERROR: invalid symbol: " .. tostring(args[1]) .. ", raw=\"" .. tostring(contentStr) .. "\"]"
	end

	return glyph
end

function M:SetKeyboardGlyph(args, glyph)
	glyph.type = EGuideGlyphType.Text
	local keyId = tonumber(args[2])
	local pcKeyCfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(keyId)

	if pcKeyCfg then
		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(pcKeyCfg.ActionMap, pcKeyCfg.ActionName)
		local buttonName = pathList.Count > 0 and pathList[0] or nil

		if not string.is_null_or_empty(buttonName) then
			local keyboardCfg = self.buttonNamePCDic[buttonName]

			if keyboardCfg then
				glyph.type = EGuideGlyphType.KeyboardIcon
				glyph.data = keyboardCfg.GuideIcon
			else
				glyph.data = "[ERROR: buttonName not found in dic, buttonName=\"" .. tostring(buttonName) .. "\", keyId=" .. tostring(keyId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
			end
		else
			glyph.data = "[ERROR: no key binding, keyId=" .. tostring(keyId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
		end
	else
		glyph.data = "[ERROR: invalid PC key id: " .. tostring(args[2]) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
	end
end

function M:SetGamepadGlyph(args, glyph)
	glyph.type = EGuideGlyphType.Text
	local actionId = tonumber(args[2])
	local style = args[3] and tonumber(args[3]) or 0

	if not actionId then
		glyph.data = "[ERROR: Format error, actionId invalid, args=\"" .. table.concat(args, ",") .. "\"]"

		return
	end

	local actionCfg = LTConfig.InputSGUIGamepadConfig.GetConfig(actionId)

	if actionCfg then
		local buttonName = nil
		local isGet, specialButtonName = self:TryGetSpecialActionButtonName(actionId)

		if isGet then
			buttonName = specialButtonName
		else
			local pathList = gCS.RebindMgr:GetBindingDisplayStrings(actionCfg.ActionMap, actionCfg.ActionName)
			buttonName = pathList.Count > 0 and pathList[0] or nil
		end

		if not string.is_null_or_empty(buttonName) then
			local gamepadCfg = self.buttonNameGamepadDic[buttonName]

			if gamepadCfg then
				glyph.type = EGuideGlyphType.GamepadIcon
				local activeDevice = gCS.LuaUtils.GetActiveDevice()
				local iconList, iconId = nil

				if activeDevice == SGUI.GameDevice.PlayStation then
					iconList = gamepadCfg.PSButtonIcon
					iconId = iconList and iconList[style + 1] or 0
					glyph.data = iconId
				else
					if activeDevice ~= SGUI.GameDevice.XBox then
						print_warn("[GuideGlyph]:Unknown game device type: " .. tostring(activeDevice))
					end

					iconList = gamepadCfg.XBoxButtonIcon
					iconId = iconList and iconList[style + 1] or 0
					glyph.data = iconId
				end
			else
				glyph.data = "[ERROR: buttonName not found in dic, buttonName=\"" .. tostring(buttonName) .. "\", actionId=" .. tostring(actionId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
			end
		else
			glyph.data = "[ERROR: no key binding, actionId=" .. tostring(actionId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
		end
	else
		glyph.data = "[ERROR: no gamepad action config, actionId=" .. tostring(actionId) .. ", args=\"" .. table.concat(args, ",") .. "\"]"
	end
end

function M:SetControllerGlyph(args, glyph)
	print_warn("[GuideGlyph]:SetControllerGlyph is deprecated, please use SetGamepadGlyph instead.")

	glyph.type = EGuideGlyphType.ControllerActionId
	local actionId = tonumber(args and args[2])
	local style = args and (args[3] and tonumber(args[3]) or 0) or 0

	if not actionId then
		glyph.type = EGuideGlyphType.Text
		glyph.data = "[ERROR: Format error, actionId invalid, args=\"" .. tostring(args and table.concat(args, ",") or "nil") .. "\"]"

		return
	end

	glyph.data = {
		actionId = actionId,
		style = style
	}
end

function M:TryGetSpecialActionButtonName(actionId)
	local matchInfo = SpecialActionMatchDic[actionId]

	if not matchInfo then
		return false
	end

	local dummyCfg = LTConfig.InputSGUIGamepadConfig.GetConfig(matchInfo.dummyActionId)

	if not dummyCfg then
		print_error("[GuideGlyph]: TryGetSpecialActionButtonName dummyCfg nil, actionId=" .. tostring(actionId))

		return false
	end

	local buttonNames = gCS.RebindMgr:GetBindingDisplayStrings(dummyCfg.ActionMap, dummyCfg.ActionName)
	local dummyName = buttonNames.Count > 0 and buttonNames[0] or nil

	if not dummyName then
		print_error("[GuideGlyph]: TryGetSpecialActionButtonName dummyName nil, actionId=" .. tostring(actionId))

		return false
	end

	local result = matchInfo.matchList[dummyName]

	if not result then
		print_error("[GuideGlyph]: TryGetSpecialActionButtonName result nil, actionId=" .. tostring(actionId) .. ", dummyName=" .. tostring(dummyName))

		return false
	end

	return true, result
end

EGuideGlyphType = {
	Text = 4,
	ControllerActionId = 2,
	KeyboardIcon = 1,
	GamepadIcon = 5,
	Icon = 3
}
