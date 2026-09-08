-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonPersonalResultPanelStore.lua
-- Decompiled from: 01532_CommonPersonalResultPanelStore.lua_b62fecb3da0b.luajit

C_CommonPersonalResultPanelStore = DefClass("C_CommonPersonalResultPanelStore", C_CommonPersonalResultPanelStore, C_StoreGroup)
GroupName2Class.CommonPersonalResultPanelStore = C_CommonPersonalResultPanelStore
local M = C_CommonPersonalResultPanelStore
local TEMPLATE_INDEX = {
	["NEo"] = 0,
	["y\\x87\\x96\\x83\\x93"] = 1,
	[".m\\xa6\\xaf\\xb1e"] = 2
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.listData = {}
	self.rewardItemList = {}
	self.closeCallback = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.titleTypeCtrlEnum = {
		["##\\xf0|\\x8a\\xee\\xba+\\xe3\\xf4\\xe3u\\xef"] = 1,
		["~\\xad\\xad\\xbd\\xb3"] = 0,
		["zWϺ\\x81;\\xbb\\xdb\\xed"] = 2
	}
	self.title2ResultCtrlEnum = {
		["8M\\x97\\x8b\\x82U"] = 1,
		["\\xef\\xd2\t6\\xe8"] = 0
	}
	self.titleType3AppraiseCtrlEnum = {
		["\\xfe"] = 2,
		["\\xec"] = 3,
		["3:"] = 1,
		["\\xbd[U"] = 0,
		["\\xef"] = 4
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.titleTypeCtrlEnum = nil
	self.title2ResultCtrlEnum = nil
	self.titleType3AppraiseCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.closeCallback = data.callback

	if data.showCallback then
		if type(data.showCallback) ~= "function" then
			data.showCallback()
		elseif type(data.showCallback) ~= "userdata" then
			data.showCallback:DynamicInvoke()
		end
	end

	self.bindData.titleTypeCtrl = data.titleTypeCtrl or self.titleTypeCtrlEnum.VictoryOrdefeat
	self.bindData.title2ResultCtrl = data.isSuccess and 0 or 1
	self.bindData.titleType3AppraiseCtrl = data.titleType3AppraiseCtrl or 0

	self:BuildListData(data)
	self.bindData.list:SetSimpleList(#self.listData)

	if data.isSuccess then
		gCS.LuaUtils.PlayAnimation(self.bindData.panelAnimation)
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_vx_CommonOnlineTeam_openFailed")
	end
end

M.OnClose = function(self)
	if self.closeCallback then
		local callback = self.closeCallback
		slot2 = gBlackScreenManager

		slot2:AutoTransition(gBlackScreenId.PERSONAL_RESULT_TRANSITION, nil, false, false, 0, 0.5, 0.5, function ()
			if type(callback) ~= "function" then
				callback()
			elseif type(callback) ~= "userdata" then
				callback:DynamicInvoke()
			end
		end)
	end

	self.listData = {}
	self.rewardItemList = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, "OnClickNextBtn")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
end

M.OnClickNextBtn = function(self)
	gPanelManager:Close(gPanelId.COMMON_PERSONAL_RESULT_PANEL)
end

M.BuildListData = function(self, data)
	self.listData = {}

	if data.score then
		table.insert(self.listData, {
			tIndex = TEMPLATE_INDEX.TITLE,
			title = data.scoreTitle or LTConfig.TextScriptTextConfig.GetConfig(89901447).Text
		})
		table.insert(self.listData, {
			tIndex = TEMPLATE_INDEX.TEXT,
			content = tostring(data.score)
		})
	end

	if not table.isNilOrEmpty(data.award) then
		table.insert(self.listData, {
			tIndex = TEMPLATE_INDEX.TITLE,
			title = data.rewardTitle or LTConfig.TextScriptTextConfig.GetConfig(89900929).Text
		})

		self.rewardItemList = {}

		for i = 1, #data.award do
			table.insert(self.rewardItemList, data.award[i])
		end

		table.insert(self.listData, {
			tIndex = TEMPLATE_INDEX.REWARD
		})
	end

	if data.rank then
		table.insert(self.listData, {
			tIndex = TEMPLATE_INDEX.TITLE,
			title = data.scoreTitle or LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.RankScore).Text
		})
		table.insert(self.listData, {
			["@R\\xc1\\xaa\\xa5\\xbc*\\xdc\\xe5"] = true,
			tIndex = TEMPLATE_INDEX.TEXT,
			content = tostring(data.rank.currentScore),
			addText = data.rank.delta > 0 and "+" .. tostring(data.rank.delta) or tostring(data.rank.delta)
		})
	end
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= TEMPLATE_INDEX.TITLE then
		store.title = data.title
	elseif data.tIndex ~= TEMPLATE_INDEX.TEXT then
		store.title = data.content

		if data.showAddNum then
			store.showAddNumCtrl = 1
			store.addText = data.addText
		end
	elseif data.tIndex ~= TEMPLATE_INDEX.REWARD then
		store.list.luaSimpleRenderItem = function(rewardBtn, rewardIndex)
			local award = self.rewardItemList[rewardIndex + 1]

			gCommonItemManager:OnCommonItemRender(rewardBtn, rewardIndex, gCommonItemManager:GetFakeItemRenderData(award))

			if rewardIndex ~= 0 then
				SGUI.UNavigationMgr.Inst.gameBarsNeedRefresh = true
			end
		end

		store.list:SetSimpleList(#self.rewardItemList)
	end
end

M.OnGetListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.OnSimpleClickList = function(self, btn, index)
end
