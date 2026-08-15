local PoliceGameplayActions = {
	VMSignalType = {
		SwitchCamera1 = 11,
		FineResult = 14,
		SwitchCamera2 = 12,
		EscortToExamAnimEnd = 19,
		ReleaseAnimFinish = 6,
		SearchCarResult = 10,
		FineChoice = 5,
		CheckCarActionEnd = 18,
		OpenFineVehicle = 16,
		BreathCheckResult = 1,
		FineVehicle = 17,
		DrugTestResult = 2,
		SwitchCamera3 = 15,
		CommandFinish = 13,
		SearchBodyResult = 3,
		IdentityCheckResult = 4,
		ArrestAnimFinish = 7,
		ShowExamine = 0
	},
	SignalTypeToAction = {}
}

function PoliceGameplayActions:HandleEventFromCs(signal)
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		return
	end

	if gPoliceJobManager.isDebug then
		local _, signalName = table.find(self.VMSignalType, signal)

		print_notice("#PoliceExamineManager NoCreateIssue 警察盘问 收到信号 " .. tostring(signal) .. " " .. tostring(signalName))
	end

	local action = self.SignalTypeToAction[signal]

	if action then
		action()
	else
		print_error_without_stack("PoliceJobManager:ReceiveSignal ", signal, " action not found")
	end
end

return PoliceGameplayActions
