-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ACDOfficialMainPageStore.lua
-- Decompiled from: 01590_ACDOfficialMainPageStore.lua_bc677446c6b9.luajit

local ACDMainConfig = LTConfig.WebpageACDMainConfig
local ACDMainSectionType = LTConfig.WebpageACDMainConfig.TypeType
local ACDMainSectionSubTypeType = LTConfig.WebpageACDMainConfig.SubTypeType
local ResourceConfig = LTConfig.WebpageResourceConfig
local WebpageConfig = LTConfig.WebpageConfig
C_ACDOfficialMainPageStore = DefClass("C_ACDOfficialMainPageStore", C_ACDOfficialMainPageStore, C_StoreGroup)
GroupName2Class.ACDOfficialMainPageStore = C_ACDOfficialMainPageStore
local M = C_ACDOfficialMainPageStore
M.submitBtnCtl = {
	["\\x98\\xa4\\xa6c*\\xfb7"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
M.inputFieldCtl = {
	["kNkab,"] = 2,
	["\\x8f\\xb8\\xaah2\\xfb7"] = 4,
	["\\xe9\\xc9\r!\\xf5"] = 1,
	["k\\xa1\\xa1\\xba\\xa5"] = 3,
	["2G\\x83\\x83\\x82M"] = 0
}

M.ctor = function(self)
	self.mgr = gWebManager
end

M.OnAwake = function(self)
	self.bindData.joinUsSubmitBtn.luaClick = self.CreateAction(self, self.OnClickJoinUsSubmitBtn)
	self.bindData.joinUsInputFieldName.luaValueChanged = self.CreateAction(self, self.OnJoinUsInputFieldNameInputValueChanged)
	self.bindData.joinUsInputFieldAccount.luaValueChanged = self.CreateAction(self, self.OnJoinUsInputFieldAccountInputValueChanged)
	self.sectionBindings = {
		[ACDMainSectionType.suggestion] = {
			[ACDMainSectionSubTypeType.Default] = {
				{
					title = self.bindData.bannerTitle,
					desc = self.bindData.bannerDesc,
					clickObj = self.bindData.section1
				}
			}
		},
		[ACDMainSectionType.notification] = {
			[ACDMainSectionSubTypeType.TopBig] = {
				{
					title = self.bindData.notificationImageTag,
					clickObj = self.bindData.section2
				}
			},
			[ACDMainSectionSubTypeType.Left] = {
				{
					title = self.bindData.notificationLeftTitle,
					desc = self.bindData.notificationLeftDesc,
					clickObj = self.bindData.notificationLeftClickObj
				}
			},
			[ACDMainSectionSubTypeType.Right] = {
				{
					title = self.bindData.notificationRight1Title,
					desc = self.bindData.notificationRight1Desc,
					clickObj = self.bindData.notificationRight1ClickObj
				},
				{
					title = self.bindData.notificationRight2Title,
					desc = self.bindData.notificationRight2Desc,
					clickObj = self.bindData.notificationRight2ClickObj
				},
				{
					title = self.bindData.notificationRight3Title,
					desc = self.bindData.notificationRight3Desc,
					clickObj = self.bindData.notificationRight3ClickObj
				}
			}
		},
		[ACDMainSectionType.about] = {
			[ACDMainSectionSubTypeType.Default] = {
				{
					title = self.bindData.aboutUsTitle,
					desc = self.bindData.aboutUsDesc
				}
			}
		},
		[ACDMainSectionType.join] = {
			[ACDMainSectionSubTypeType.Default] = {
				{
					title = self.bindData.joinUsTitle,
					desc = self.bindData.joinUsDesc
				}
			}
		}
	}
end

M.OnShow = function(self, panelId, data)
end

M.GetSections = function(self)
	return self.sectionPositions
end

M.GetPageSizeY = function(self)
	return self.bindData.root.transform.rect.height
end

M.RefreshPage = function(self, _)
	local prevSection, prevSubType = nil
	local entryIdx = 1

	for i = 0, ACDMainConfig.count - 1 do
		local page = ACDMainConfig.LoadAt(i)
		local section = self.sectionBindings[page.Type]

		if section and section[page.SubType] then
			local entries = section[page.SubType]
			local resourceId = page.SubResources[1]

			if resourceId then
				if prevSection ~= page.Type and prevSubType ~= page.SubType then
					entryIdx = entryIdx + 1
				else
					entryIdx = 1
				end

				self.PopulateResource(self, resourceId, entries, page, entryIdx)

				prevSection = page.Type
				prevSubType = page.SubType
			end
		end
	end

	local section3pos = math.abs(self.bindData.section3.transform.localPosition.y)
	self.sectionPositions = {
		{
			name = self.bindData.section1text.text,
			pos = math.abs(self.bindData.section1.transform.localPosition.y)
		},
		{
			name = self.bindData.section2text.text,
			pos = math.abs(self.bindData.section2.transform.localPosition.y)
		},
		{
			name = self.bindData.section3text.text,
			pos = section3pos
		},
		{
			name = self.bindData.section4text.text,
			pos = section3pos + math.abs(self.bindData.section4.transform.localPosition.y)
		}
	}

	self.RefreshSubmitBtnState(self)
end

M.PopulateResource = function(self, resourceId, entires, page, idx)
	local resource = ResourceConfig.GetConfig(resourceId)

	if idx <= #entires then
		return
	end

	local entry = entires[idx]

	if entry.title then
		entry.title.text = resource.Name
	end

	if entry.desc then
		entry.desc.text = resource.Desc
	end

	if entry.clickObj and resource.Url == 0 then
		local linkTargetWebPage = WebpageConfig.GetConfig(resource.Url)

		if linkTargetWebPage then
			entry.clickObj.clickUrlOverride = linkTargetWebPage.Url
		end
	end

	if resource.ImageId then
		self.ApplyImage(self, page.Type, page.SubType, idx, resource.ImageId)
	end
end

M.ApplyImage = function(self, type, subtype, pageId, imageId)
	if type ~= ACDMainSectionType.suggestion and subtype ~= ACDMainSectionSubTypeType.Default then
		self.bindData:Commit("bannerImage", imageId, COMMIT_FORCE)
	elseif type ~= ACDMainSectionType.notification then
		if subtype ~= ACDMainSectionSubTypeType.TopBig then
			self.bindData:Commit("notificationBigImage", imageId, COMMIT_FORCE)
		elseif subtype ~= ACDMainSectionSubTypeType.Left then
			self.bindData:Commit("notificationLeftImage", imageId, COMMIT_FORCE)
		elseif subtype ~= ACDMainSectionSubTypeType.Right and pageId ~= 1 then
			self.bindData:Commit("notificationRight1Image", imageId, COMMIT_FORCE)
		elseif subtype ~= ACDMainSectionSubTypeType.Right and pageId ~= 2 then
			self.bindData:Commit("notificationRight2Image", imageId, COMMIT_FORCE)
		elseif subtype ~= ACDMainSectionSubTypeType.Right and pageId ~= 3 then
			self.bindData:Commit("notificationRight3Image", imageId, COMMIT_FORCE)
		end
	elseif type ~= ACDMainSectionType.about then
		self.bindData:Commit("aboutUsImage", imageId, COMMIT_FORCE)
	end
end

M.OnClickJoinUsSubmitBtn = function(self)
	self.bindData.joinUsInputFieldName.interactable = false
	self.bindData.joinUsInputFieldAccount.interactable = false
	self.bindData.joinUsSubmitBtnCtl = self.submitBtnCtl.Submited
end

M.OnJoinUsInputFieldNameInputValueChanged = function(self, text)
	self.bindData.joinUsInputFieldName.text = text

	self.RefreshSubmitBtnState(self)
end

M.OnJoinUsInputFieldAccountInputValueChanged = function(self, text)
	self.bindData.joinUsInputFieldAccount.text = text

	self.RefreshSubmitBtnState(self)
end

M.RefreshSubmitBtnState = function(self)
	if string.is_null_or_empty(self.bindData.joinUsInputFieldName.text) or string.is_null_or_empty(self.bindData.joinUsInputFieldAccount.text) then
		self.bindData.joinUsSubmitBtn.interactable = false
	else
		self.bindData.joinUsSubmitBtn.interactable = true
	end
end
