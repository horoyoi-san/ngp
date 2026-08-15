local ProfileManager = LX6.Engine.ProfileManager
local NoteInfo_Default_Bgm = require("LX6/Manager/GamePlay/LiveHouse/NoteInfo_Default_Bgm")
local M = {
	hasLoadDefault = false,
	hasLoad = false,
	MusicStringCutStr = "#",
	EditNoteList = {},
	RecordNoteList = {},
	DeleteNoteList = {},
	AllMusicNoteList = {},
	DefaultMusicNoteList = {},
	OnInit = function (self)
		return
	end
}

function M:AddEditNote(liveHouseMusicId, noteInfo)
	print("AddEditNote", noteInfo.gridId, noteInfo.track, noteInfo.templateIndex, noteInfo.length)

	local view = {
		gridId = noteInfo.gridId,
		track = noteInfo.track,
		pointType = noteInfo.pointType or noteInfo.templateIndex,
		length = noteInfo.length
	}

	if self.EditNoteList[view.track] == nil then
		self.EditNoteList[view.track] = {}
	end

	self.EditNoteList[view.track][view.gridId] = view

	table.insert(self.RecordNoteList, view)
end

function M:LoadDefaultGamePlayNoteList()
	if self.hasLoadDefault then
		return
	end

	self.DefaultMusicNoteList = {}

	for i = 1, #NoteInfo_Default_Bgm do
		local musicNoteList = string.split(NoteInfo_Default_Bgm[i], self.MusicStringCutStr)
		local noteList = {}

		for i = 1, #musicNoteList do
			local array = string.split(musicNoteList[i], "|")

			for i = 2, #array do
				local note = string.split(array[i], ",")

				if #note == 4 then
					local view = {
						gridId = tonumber(note[1]),
						track = tonumber(note[2]),
						pointType = tonumber(note[3]),
						length = tonumber(note[4])
					}

					table.insert(noteList, view)
				end
			end

			local id = tonumber(array[1])

			if id then
				self.DefaultMusicNoteList[id] = noteList
			end
		end
	end

	self.hasLoadDefault = true
end

function M:LoadGamePlayProperty()
	if self.hasLoad then
		return
	end

	self.AllMusicNoteList = {}

	ProfileManager.LoadGamePlayProperty()

	local noteList = {}
	local musicNoteList = string.split(ProfileManager.gamePlayProfile.LivehouseNoteList, self.MusicStringCutStr)

	for i = 1, #musicNoteList do
		local array = string.split(musicNoteList[i], "|")

		for i = 2, #array do
			local note = string.split(array[i], ",")

			if #note == 4 then
				local view = {
					gridId = tonumber(note[1]),
					track = tonumber(note[2]),
					pointType = tonumber(note[3]),
					length = tonumber(note[4])
				}

				table.insert(noteList, view)
			end
		end

		local id = tonumber(array[1])

		if id then
			self.AllMusicNoteList[id] = noteList
		end
	end

	if table.isNilOrEmpty(noteList) then
		print("没读取到note信息，本地没有数据")
	end

	print_notice("=-----------------读取的音符信息：" .. #noteList)

	self.hasLoad = true
end

function M:SaveGamePlayProperty(livehouseMusicId)
	local newStr = ""
	local musicNoteList = string.split(ProfileManager.gamePlayProfile.LivehouseNoteList, self.MusicStringCutStr)
	local hasSaveNote = false

	for i = 1, #musicNoteList do
		local array = string.split(musicNoteList[i], "|")
		local id = tonumber(array[1])
		local muscicStr = livehouseMusicId

		if id == nil or id == livehouseMusicId then
			hasSaveNote = true

			for i = 1, #self.RecordNoteList do
				muscicStr = muscicStr .. "|" .. self.RecordNoteList[i].gridId .. "," .. self.RecordNoteList[i].track .. "," .. self.RecordNoteList[i].pointType .. "," .. self.RecordNoteList[i].length
			end

			newStr = newStr .. muscicStr .. self.MusicStringCutStr
		else
			newStr = newStr .. musicNoteList[i] .. self.MusicStringCutStr
		end
	end

	if not hasSaveNote then
		local muscicStr = livehouseMusicId

		for i = 1, #self.RecordNoteList do
			muscicStr = muscicStr .. "|" .. self.RecordNoteList[i].gridId .. "," .. self.RecordNoteList[i].track .. "," .. self.RecordNoteList[i].pointType .. "," .. self.RecordNoteList[i].length
		end

		newStr = newStr .. muscicStr .. self.MusicStringCutStr
	end

	ProfileManager.gamePlayProfile.LivehouseNoteList = newStr
	self.AllMusicNoteList[livehouseMusicId] = self.RecordNoteList

	print_notice("=-----------------保存的音符信息：")
	print_notice(self.RecordNoteList)
	ProfileManager.SaveGamePlayProperty()
end

gMusicGameEditManager = M
