-- Original chunk: @Lua\LuaFiles\LX6\Utils\FakePhoneUtils.lua
-- Decompiled from: 02178_FakePhoneUtils.lua_a34a3f82eb4f.luajit

local M = {
	OpenFakePhone = function (self, data)
		if not data then
			data = {}
		elseif type(data) == "table" then
			data = data.ToTable(data)
		end

		data.mainHomeType = gClientConst.MainHomeType.FakePhone

		if not gNpcChatNpcsPhoneManager:CheckShowChatPanel(data) then
			local mainPhonePanelId = gClientUtils.GetMainPhonePanelId()

			gPanelManager:CheckShow(mainPhonePanelId, data)
		end
	end
}

M.GetAlbumViewDataList = function(albumGroupId)
	local albumTypes = {}
	local count = LTConfig.NPCChatAlbumConfig.count

	for i = 0, count - 1 do
		local albumCfg = LTConfig.NPCChatAlbumConfig.LoadAt(i)

		if albumCfg.AlbumGroupId ~= albumGroupId then
			albumTypes[albumCfg.Type] = true
		end
	end

	local albumTypeList = table.keys(albumTypes)

	table.sort(albumTypeList)

	local viewDataList = {}

	for _, albumType in ipairs(albumTypeList) do
		table.insert(viewDataList, {
			tIndex = gClientConst.FakePhoneTemplateType.TitleTIndex,
			albumType = albumType
		})

		local albumIdList = M.GetAlbumIdList(albumGroupId, albumType)

		for _, albumId in ipairs(albumIdList) do
			table.insert(viewDataList, {
				tIndex = gClientConst.FakePhoneTemplateType.AlbumItemTIndex,
				albumId = albumId
			})
		end
	end

	return viewDataList
end

M.GetAlbumIdList = function(albumGroupId, albumType)
	local albumIdList = {}
	local count = LTConfig.NPCChatAlbumConfig.count

	for i = 0, count - 1 do
		local albumCfg = LTConfig.NPCChatAlbumConfig.LoadAt(i)

		if albumCfg.AlbumGroupId ~= albumGroupId and albumCfg.Type ~= albumType then
			table.insert(albumIdList, albumCfg.Id)
		end
	end

	table.sort(albumIdList)

	return albumIdList
end

gFakePhoneUtils = M
