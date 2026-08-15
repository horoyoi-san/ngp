local M = {
	sortOrFilter = {
		Sort = 2,
		Filter = 1
	},
	UIFilterMode = {
		Compound = 7,
		LifeSkill = 4,
		Disassemble = 8,
		Card = 2,
		SendGift = 10,
		Train = 1
	},
	SortType = {
		Score = 5,
		Quality = 1,
		Cost = 2,
		StarLevel = 3,
		WordsCount = 7,
		ProficiencyLevel = 4,
		PossessTime = 6
	},
	SortTypeStr = {
		LTConfig.TextScriptTextConfig.GetConfig(89900781).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900782).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900783).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900784).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900785).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900786).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900787).Text
	},
	SortTypeShortStr = {
		LTConfig.TextScriptTextConfig.GetConfig(89900788).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900789).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900790).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900791).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900792).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900793).Text,
		LTConfig.TextScriptTextConfig.GetConfig(89900794).Text
	},
	YuanZhenType = {
		Aver = 5,
		Att = 2,
		HP = 1,
		LDef = 4,
		PDef = 3
	},
	LifeSkillType = {
		Dex = 2,
		Str = 1,
		Int = 3
	},
	KindType = {
		Ling = 2,
		Skill = 3,
		All = 1
	},
	MultiType = {
		All = 1,
		SingleScore = 2,
		SingleQianli = 3
	},
	FilterTypeOrder = {
		Quality = {
			index = 1,
			height = 100,
			posName = "QualityPos",
			visibleName = "QualityVisible"
		},
		StarLevel = {
			index = 2,
			height = 100,
			posName = "StarLevelPos",
			visibleName = "StarLevelVisible"
		},
		Job = {
			index = 3,
			height = 200,
			posName = "JobPos",
			visibleName = "JobVisible"
		},
		Cost = {
			index = 4,
			height = 100,
			posName = "CostPos",
			visibleName = "CostVisible"
		},
		YuanZhen = {
			index = 5,
			height = 200,
			posName = "YuanZhenPos",
			visibleName = "YuanZhenVisible"
		},
		Lock = {
			index = 6,
			height = 100,
			posName = "LockPos",
			visibleName = "LockVisible"
		},
		Bind = {
			index = 7,
			height = 100,
			posName = "BindPos",
			visibleName = "BindVisible"
		}
	},
	OnInit = function (self)
		return
	end,
	GetAttriBaseValue = function (self, viewData, index, defaultValue)
		return viewData and viewData.SpiritAttrsBase and viewData.SpiritAttrsBase[index + 1] or defaultValue
	end,
	GetAttriExtraValue = function (self, viewData, index, defaultValue)
		return viewData and viewData.SpiritAttrsBase and viewData.SpiritAttrsExtra[index + 1] or defaultValue
	end
}

function M:GetAttriFinalValue(viewData, index, defaultValue)
	return self:GetAttriBaseValue(viewData, index) + self:GetAttriExtraValue(viewData, index)
end

gLingUtils = M
