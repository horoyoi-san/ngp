-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatSettingPanelStore.lua
-- Decompiled from: 01908_ChatSettingPanelStore.lua_a669be8e496e.luajit

C_ChatSettingPanelStore = DefClass("C_ChatSettingPanelStore", C_ChatSettingPanelStore, C_AppFragmentStore)
GroupName2Class.ChatSettingPanelStore = C_ChatSettingPanelStore
local M = C_ChatSettingPanelStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnClickItem)
end

M.OnShow = function(self, _, data)
	self.btnListData = self:GetBtnList()

	self.bindData.list:SetSimpleList(#self.btnListData)
end

M.OnDestroy = function(self)
	self.btnListData = nil
end

M.GetBtnList = function(self)
	local list = {}
	local rejectAllApply = {
		["a\\x9f\\x8a\\x86Y"] = 1,
		text = LTConfig.TextScriptTextConfig.GetConfig(89901131).Text,
		onRender = function (btn, store)
			slot3 = gFriendManager
			store.toggleBtn.isSelected = slot3:IsRejectAllFriendApply()

			store.toggleBtn.luaClick = function()
				local new = not store.toggleBtn.isSelected
				slot1 = gFriendManager

				slot1:SetRejectAllFriendApply(new, function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						store.toggleBtn.isSelected = gFriendManager:IsRejectAllFriendApply()
					end
				end)
			end
		end,
		onClick = function (btn, store)
			store.toggleBtn.luaClick()
		end
	}

	table.insert(list, rejectAllApply)

	local blackList = {
		["a\\x9f\\x8a\\x86Y"] = 0,
		onClick = function (btn, store)
			self.activity:ShowFragment(gChatConst.TabShowType.BlackList)
		end
	}

	table.insert(list, blackList)

	return list
end

M.OnRenderItem = function(self, btn, csIndex)
	local data = self.btnListData[csIndex + 1]
	local store = self.GetStoreByWidget(self, btn)
	store.text = data.text

	if data.onRender then
		data.onRender(btn, store)
	end
end

M.OnClickItem = function(self, btn, csIndex)
	local data = self.btnListData[csIndex + 1]
	local store = self.GetStoreByWidget(self, btn)

	if data.onClick then
		data.onClick(btn, store)
	end
end
