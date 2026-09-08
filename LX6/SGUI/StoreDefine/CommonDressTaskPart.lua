-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonDressTaskPart.lua
-- Decompiled from: 01521_CommonDressTaskPart.lua_7fb6953f0140.luajit

local FashionTagConfig = LTConfig.FashionTagConfig
C_CommonDressTaskPart = DefClass("C_CommonDressTaskPart", C_CommonDressTaskPart, C_StoreGroup)
GroupName2Class.CommonDressTaskPart = C_CommonDressTaskPart
local M = C_CommonDressTaskPart

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.tagList = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showRecommendTagCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.showTaskIconCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showRecommendTagCtrlEnum = nil
	self.showTaskIconCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnStart = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTagListItem)
	self.bindData.tagList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTagList)
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
	local data = self.tagList and self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store and data then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
end

M.OnSimpleClickTagList = function(self, btn, index)
end

M.SetShowRecommend = function(self, enable)
	self.bindData.showRecommendTagCtrl = enable and self.showRecommendTagCtrlEnum.show or self.showRecommendTagCtrlEnum.hide
end

M.SetTaskData = function(self, taskDes, taskIconId)
	self.bindData.taskDesText.text = taskDes

	if taskIconId then
		self.bindData.taskIconId = taskIconId
		self.bindData.showTaskIconCtrl = self.showTaskIconCtrlEnum.show
	else
		self.bindData.showTaskIconCtrl = self.showTaskIconCtrlEnum.hide
	end
end

M.SetTagIdList = function(self, tagIdList)
	self.tagList = {}

	if tagIdList then
		for i = 1, #tagIdList do
			local tagCfg = FashionTagConfig.GetConfig(tagIdList[i])

			if tagCfg then
				table.insert(self.tagList, {
					title = tagCfg.Name,
					color = tagCfg.BackgroundColor
				})
			end
		end
	end

	self.bindData.tagList:SetSimpleList(#self.tagList)
end
