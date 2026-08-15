local GuideTextConfig = LTConfig.GuideGuideTextConfig
local glyphDef = require("LX6.GuideFlow.GFGlyphDef")
C_GFFormatUtil = DefClass("C_GFFormatUtil", C_GFFormatUtil)
local M = C_GFFormatUtil

local function FetchNextGlyph(formatStr, curStart, len)
	local ch = string.sub(formatStr, curStart, curStart)

	if ch == "{" then
		if curStart == len then
			return len + 1, glyphDef.GenTextGlyph("[ERROR: unmatched '{']")
		end

		if string.sub(formatStr, curStart + 1, curStart + 1) == "{" then
			return curStart + 2, glyphDef.GenTextGlyph("{")
		end

		local i = curStart + 1

		while len >= i and formatStr:sub(i, i) ~= "}" do
			i = i + 1
		end

		if len < i then
			return len + 1, glyphDef.GenTextGlyph("[ERROR: unmatched '{']")
		end

		local contentStr = string.sub(formatStr, curStart + 1, i - 1)
		contentStr = string.trim(contentStr)
		local sep = nil

		if contentStr:find(",") then
			sep = ","
		elseif contentStr:find("|") then
			sep = "|"
		end

		if not sep then
			return i + 1, glyphDef.GenTextGlyph("[ERROR: invalid placeholder]")
		end

		local args = string.split(contentStr, sep)
		local type = string.lower(string.trim(args[1]))
		local glyph = glyphDef.GenGlyph(type, args)

		return i + 1, glyph
	end

	if ch == "}" then
		if curStart == len or string.sub(formatStr, curStart + 1, curStart + 1) ~= "}" then
			return len + 1, glyphDef.GenTextGlyph("[ERROR: unmatched '}']")
		end

		return curStart + 2, glyphDef.GenTextGlyph("}")
	end

	local index = curStart + 1

	while len >= index and formatStr:sub(index, index) ~= "{" and formatStr:sub(index, index) ~= "}" do
		index = index + 1
	end

	return index, glyphDef.GenTextGlyph(string.sub(formatStr, curStart, index - 1))
end

function M:Format(formatStr)
	local glyphs = {}
	local formatStrLen = string.len(formatStr)
	local p = 1

	while formatStrLen >= p do
		local glyph = nil
		p, glyph = FetchNextGlyph(formatStr, p, formatStrLen)
		glyphs[#glyphs + 1] = glyph
	end

	local mergedGlyphs = {}

	for i = 1, #glyphs do
		local glyph = glyphs[i]
		local prev = #mergedGlyphs > 0 and mergedGlyphs[#mergedGlyphs] or nil

		if prev and prev.type == glyph.type and glyph.type == gGFConstant.GuideGlyphType.Text then
			prev.text = prev.text .. glyph.text
		else
			mergedGlyphs[#mergedGlyphs + 1] = glyph
		end
	end

	return mergedGlyphs
end

function M:GetControllerButtonCodeByCellId(cellId)
	if cellId == nil then
		return 0, 0
	end

	return 0, 0
end

function M:GetGuideText(guideText)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local textId = nil

		if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
			if guideText.textIdConsole > 0 then
				textId = guideText.textIdConsole
			else
				return guideText.textConsole
			end
		elseif guideText.textIdPc > 0 then
			textId = guideText.textIdPc
		else
			return guideText.textPc
		end

		local cfg = GuideTextConfig.GetConfig(textId)

		if not cfg then
			print_warn("GF Debug => GetGuideText的cfg为空，Id=", textId, Time.time, Time.frameCount)

			return ""
		end

		return cfg.Text or ""
	elseif guideText.textIdMobile > 0 then
		local cfg = GuideTextConfig.GetConfig(guideText.textIdMobile)

		if not cfg then
			print_warn("GF Debug => GetGuideText的cfg为空，textId=", guideText.textIdMobile, Time.time, Time.frameCount)

			return ""
		end

		return cfg.Text or ""
	else
		return guideText.textMobile
	end
end

gGFFormatUtil = gGFFormatUtil or C_GFFormatUtil.new()
