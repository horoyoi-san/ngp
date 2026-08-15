C_TaskChapterTipsStore = DefClass("C_TaskChapterTipsStore", C_TaskChapterTipsStore, C_StoreGroup)
GroupName2Class.TaskChapterTipsStore = C_TaskChapterTipsStore
local M = C_TaskChapterTipsStore
local TaskEventConfig = LTConfig.TaskEventConfig
local TaskChapterConfig = LTConfig.TaskChapterConfig

function M:Show(pData, widget)
	local data = pData.Param

	if not data.eventId then
		return
	end

	local cfg = TaskEventConfig.GetConfig(data.eventId)

	if not cfg then
		return
	end

	local eventName = cfg.EventName
	local eventChapter = cfg.Chapter
	local chapterConfig = TaskChapterConfig.GetConfig(eventChapter)
	local chapter = nil

	if chapterConfig then
		chapter = chapterConfig.ChapterName
	end

	local store = self:GetStoreByWidget(widget)
	store.eventName = eventName

	if eventChapter and eventChapter ~= 0 then
		store.showChapter = 0
		store.Chapter = chapter
	else
		store.showChapter = 1
	end

	local isStart = data.isStart or false

	if isStart then
		store.type = 0
	else
		store.type = 1
	end
end
