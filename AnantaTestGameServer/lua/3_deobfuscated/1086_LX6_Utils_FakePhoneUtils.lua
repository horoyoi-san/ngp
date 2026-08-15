local M = {
	OpenFakePhone = function (self, data)
		if not data then
			data = {}
		elseif type(data) ~= "table" then
			data = data:ToTable()
		end

		data.mainHomeType = gClientConst.MainHomeType.FakePhone

		if not gNpcChatNpcsPhoneManager:CheckShowChatPanel(data) then
			local mainPhonePanelId = gClientUtils.GetMainPhonePanelId()

			gPanelManager:CheckShow(mainPhonePanelId, data)
		end
	end
}

function M.GetAlbumViewDataList(albumGroupId)
	local albumTypes = {}
	local count = LTConfig.NPCChatAlbumConfig.count

	for i = 0, count - 1 do
		local albumCfg = LTConfig.NPCChatAlbumConfig.LoadAt(i)

		if albumCfg.AlbumGroupId == albumGroupId then
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

function M.GetAlbumIdList(albumGroupId, albumType)
	local albumIdList = {}
	local count = LTConfig.NPCChatAlbumConfig.count

	for i = 0, count - 1 do
		local albumCfg = LTConfig.NPCChatAlbumConfig.LoadAt(i)

		if albumCfg.AlbumGroupId == albumGroupId and albumCfg.Type == albumType then
			table.insert(albumIdList, albumCfg.Id)
		end
	end

	table.sort(albumIdList)

	return albumIdList
end

gFakePhoneUtils = M
