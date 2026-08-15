local def = {}
def.metas = {
	controllerCellId = {
		keyName = {},
		genToken = function (args)
			local glyph = {
				type = gGFConstant.GuideGlyphType.ControllerCell
			}
			local id = tonumber(args[2])
			local controllerIconType = 0

			if #args > 2 then
				controllerIconType = tonumber(args[3])
			end

			local _, code2 = gGFFormatUtil:GetControllerButtonCodeByCellId(id)
			glyph.controller = {
				cellId = id,
				isCombo = code2 and code2 > 0,
				iconType = controllerIconType or 0
			}

			return glyph
		end
	},
	iconId = {
		genToken = function (args)
			local glyph = {
				type = gGFConstant.GuideGlyphType.Icon,
				iconId = tonumber(args[2])
			}

			return glyph
		end
	},
	keyboardId = {
		genToken = function (args)
			local glyph = {}
			local id = tonumber(args[2])
			local style = 0

			if #args > 2 then
				style = tonumber(args[3])
			end

			local keyNameText = ""

			if string.is_null_or_empty(keyNameText) then
				keyNameText = "[ERROR: invalid keyboard id]"
			end

			if style == 0 then
				glyph.type = gGFConstant.GuideGlyphType.Text
				glyph.text = keyNameText
			else
				glyph.type = gGFConstant.GuideGlyphType.KeyboardIcon
				glyph.keyboardIcon = {
					text = keyNameText
				}
			end

			return glyph
		end
	}
}
local alias2Type = {}

for k, v in pairs(def.metas) do
	for _, key in ipairs(v.keyName or {}) do
		alias2Type[string.lower(key)] = k
	end

	alias2Type[string.lower(k)] = k
end

function def.GenGlyph(type, args)
	local key = alias2Type[type]

	if not key then
		return "[ERROR: invalid placeholder]"
	end

	return def.metas[key].genToken(args)
end

function def.GenTextGlyph(text)
	local glyph = {
		type = gGFConstant.GuideGlyphType.Text,
		text = text
	}

	return glyph
end

return def
