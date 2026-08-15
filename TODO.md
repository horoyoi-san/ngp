TODO
- [x] (A+B) Fix TCP framing validation in Connection.ProcessPackets(): require Buffer.Count >= 5 + length, validate length range.
- [x] (A+B) Add bounds checks in UxRpcMessage.Parse() to avoid out-of-range reads for Invoke/Return/Notify; on invalid payload set safe defaults.

- [x] Rebuild and run server.
- [x] Test handshake/login path and verify no cascading invalid RPC/Unity curl errors.

- [ ] Add targeted RPC payload URL extraction logging when payload contains http/https (scope C).
- [ ] Run server with Unity client; reproduce curl error; locate which RPC methodId/method caused the first [RPC_URL] hit.








