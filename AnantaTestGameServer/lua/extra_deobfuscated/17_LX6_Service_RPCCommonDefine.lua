return {
	UxRpcPacketMode = {
		Return = 2,
		Notify = 3,
		Invoke = 1
	},
	ProtocolIndex = {
		Mid = 1,
		Mode = 0
	},
	UXRPCTaskError = {
		Disconnect = 3,
		Unshaked = 9,
		RPCProcessorInnerException = 8,
		ServerInnerException = 4,
		SendMessageTooFast = 6,
		TimeOut = 1,
		ServerInnerError = 2,
		OK = 0,
		NullRpcInvoke = 7,
		PeerTimeOut = 5
	}
}
