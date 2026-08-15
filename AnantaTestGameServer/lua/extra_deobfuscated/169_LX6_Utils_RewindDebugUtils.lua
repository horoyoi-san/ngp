local M = {
	isRecording = false
}

function M:SetRecording(value)
	self.isRecording = value

	print("gRewindDebugUtils.SetRecording", value)
end

gRewindDebugUtils = M
