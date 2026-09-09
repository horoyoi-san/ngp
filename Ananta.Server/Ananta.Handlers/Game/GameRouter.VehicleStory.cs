using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// S011 vehicle boarding story channel. The client only offers the F-enter prompt and
/// drives the enter/exit animation phases once the S011 root node exists; without it,
/// pressing F near a spawned vehicle sends nothing (observed live). Ported from the
/// proven sibling build, with 4229938 framing (StoryboardGuid) applied.
/// Flow: root bootstrap (once per load) → client S011PlayerNetEnterVehicleRequest →
/// enter child + controller + status 2 → phase 2 (status 3) → phase 3 (status 4,
/// seated) → exit request → exit child + status 5 → phase 1 (status 0, done).
/// </summary>
internal sealed partial class GameRouter
{
    private const uint VehicleStoryRootNid = 1;
    private const uint VehicleStoryEnterNid = 2;
    private const uint VehicleStoryExitNid = 3;

    internal static async Task EnsureVehicleStoryRoot(RpcContext ctx)
    {
        if (!Configuration.PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        var runtime = GetVehicleRuntime(ctx);
        long confirm;
        lock (runtime.SyncRoot)
        {
            if (runtime.StoryRootSent)
                return;
            runtime.StoryRootSent = true;
            runtime.StoryBoardingUnitId = GetStateIfExists(ctx.Session)?.ActiveSpiritUnitId
                ?? Profile.InitialUnitId;
            confirm = runtime.StorySeenAnyRpc ? Math.Max(0, runtime.StoryHighestConfirmedRpcId) : -1;
        }
        await ctx.NotifyAsync(MethodId.SyncStoryCoreServerInfo,
            StoryS011Codec4229938.BuildRootBootstrap(VehicleStoryRootNid, confirm));
        ctx.Session.Log.Info($"[VEHICLE-STORY] S011 root ready nid={VehicleStoryRootNid} confirm={confirm}");
    }

    [Handler(MethodId.SyncStoryCoreClientInfo, HandlerPacketKind.Notify)]
    private async Task SyncStoryCoreClientInfo(Connection conn, UxRpcMessage msg)
    {
        await EnsureVehicleStoryRoot(msg.Context);
        var runtime = GetVehicleRuntime(msg.Context);
        lock (runtime.SyncRoot)
            runtime.StoryBoardingUnitId = GetWorldState(msg.Context).ActiveSpiritUnitId;

        var commands = StoryVehicleCodec4229938.Parse(msg.Body, out var full);
        if (!full)
            conn.Log.Warn($"[VEHICLE-STORY] partial parse commands={commands.Count} bytes={msg.Body.Length}");
        foreach (var summary in commands)
        {
            // Non-heartbeat story traffic is rare; log it so new flows are visible.
            if (summary.Name != "Rpc3" || summary.RpcId < 0)
                conn.Log.Info($"[VEHICLE-STORY] cmd mark={summary.TypeMark} nid={summary.Nid} name={summary.Name} rpc={summary.RpcId} payload={summary.PayloadKind} vehicle={summary.PayloadVehicleId} seats=[{(summary.PayloadSeatIndices is null ? "" : string.Join(",", summary.PayloadSeatIndices))}] bool={summary.PayloadBool} int={summary.PayloadInt}");
        }

        foreach (var cmd in commands)
        {
            var duplicateCommitted = false;
            long duplicateConfirm = -1;
            if (cmd.HasRpcId && cmd.RpcId >= 0)
            {
                lock (runtime.SyncRoot)
                {
                    runtime.StorySeenAnyRpc = true;
                    if (cmd.RpcId <= runtime.StoryHighestConfirmedRpcId)
                    {
                        duplicateCommitted = true;
                        duplicateConfirm = runtime.StoryHighestConfirmedRpcId;
                    }
                    else
                    {
                        runtime.StoryPendingRpcIds.Add(cmd.RpcId);
                    }
                }
            }

            if (duplicateCommitted)
            {
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildConfirmRpc(duplicateConfirm));
                continue;
            }

            if (cmd.TypeMark is 3 or 6)
            {
                await ConfirmVehicleStoryRpc(conn, runtime, cmd.HasRpcId ? cmd.RpcId : null);
                continue;
            }

            if (cmd.Name == "S011PlayerNetEnterVehicleRequest" && cmd.PayloadKind == "S011EnterVehicleRequest")
                await BeginVehicleEnter(conn, runtime, cmd);
            else if (cmd.Name == "S011PlayerNetExitVehicleRequest" && cmd.PayloadKind == "Bool")
                await BeginVehicleExit(conn, runtime, cmd.PayloadBool ?? true);
            else if (cmd.Nid == VehicleStoryEnterNid && cmd.Name == "MsgrChangePhaseRequest" && cmd.PayloadKind is "Byte" or "Int")
                await AdvanceVehicleEnter(conn, runtime, (int)(cmd.PayloadInt ?? 0));
            else if (cmd.Nid == VehicleStoryExitNid && cmd.Name == "MsgrChangePhaseRequest" && cmd.PayloadKind is "Byte" or "Int")
                await AdvanceVehicleExit(conn, runtime, (int)(cmd.PayloadInt ?? 0));

            await ConfirmVehicleStoryRpc(conn, runtime, cmd.HasRpcId ? cmd.RpcId : null);
        }
    }

    private async Task BeginVehicleEnter(Connection conn, VehicleRuntimeState runtime, StoryClientCommand4229938 cmd)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (runtime.SyncRoot)
        {
            vehicleId = cmd.PayloadVehicleId ?? 0;
            seat = cmd.PayloadSeatIndices is { Count: > 0 } ? cmd.PayloadSeatIndices[0] : (byte)0;
            unitId = runtime.StoryBoardingUnitId != 0 ? runtime.StoryBoardingUnitId : Profile.InitialUnitId;
            if (vehicleId == 0 || runtime.CurrentVehicleId != 0
                || runtime.StoryEnterVehicleId != 0 || runtime.StoryExitInProgress
                || !runtime.Vehicles.TryGetValue(vehicleId, out var vehicle) || !vehicle.Interactable || seat >= vehicle.SeatCount
                || vehicle.SeatReservations.ContainsKey(seat) || vehicle.SeatOccupants.ContainsKey(seat))
            {
                conn.Log.Warn($"[VEHICLE-STORY] enter rejected vehicle={vehicleId} seat={seat}");
                return;
            }
            vehicle.SeatReservations[seat] = Profile.PlayerPid;
            runtime.StoryEnterVehicleId = vehicleId;
            runtime.StoryEnterSeat = seat;
            vehicle.ControllerPid = Profile.PlayerPid;
        }

        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildEnterChildBootstrap(VehicleStoryEnterNid, vehicleId, seat));
        await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new GameMethods.SyncChangeVehicleController4229938
            { vehicleInstanceId = vehicleId, controllerPid = Profile.PlayerPid });
        await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 2);
        conn.Log.Info($"[VEHICLE-STORY] enter begin vehicle={vehicleId} seat={seat} unit={unitId} status=2");
    }

    private async Task AdvanceVehicleEnter(Connection conn, VehicleRuntimeState runtime, int phase)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (runtime.SyncRoot)
        {
            vehicleId = runtime.StoryEnterVehicleId;
            seat = runtime.StoryEnterSeat;
            unitId = runtime.StoryBoardingUnitId != 0 ? runtime.StoryBoardingUnitId : Profile.InitialUnitId;
        }
        if (vehicleId == 0)
            return;
        switch (phase)
        {
            case 0:
            case 1:
                return;
            case 2:
            {
                var committed = false;
                lock (runtime.SyncRoot)
                {
                    if (runtime.Vehicles.TryGetValue(vehicleId, out var vehicle)
                        && vehicle.SeatReservations.TryGetValue(seat, out var owner) && owner == Profile.PlayerPid
                        && !vehicle.SeatOccupants.ContainsKey(seat))
                    {
                        vehicle.SeatReservations.Remove(seat);
                        vehicle.SeatOccupants[seat] = Profile.PlayerPid;
                        committed = true;
                    }
                }
                if (!committed)
                {
                    conn.Log.Warn($"[VEHICLE-STORY] enter phase=2 commit failed vehicle={vehicleId} seat={seat}");
                    return;
                }
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 3);
                conn.Log.Info($"[VEHICLE-STORY] enter phase=2 vehicle={vehicleId} seat={seat} status=3");
                return;
            }
            case 3:
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 4);
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
                lock (runtime.SyncRoot)
                {
                    runtime.CurrentVehicleId = vehicleId;
                    runtime.CurrentVehicleSeat = seat;
                    runtime.StoryEnterVehicleId = 0;
                    if (runtime.Vehicles.TryGetValue(vehicleId, out var v))
                        v.ControllerPid = Profile.PlayerPid;
                }
                conn.Log.Info($"[VEHICLE-STORY] enter complete vehicle={vehicleId} seat={seat} status=4");
                return;
            case 4:
                await SendVehicleBoardingStatus(conn, unitId, vehicleId, 0, 0);
                await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new GameMethods.SyncChangeVehicleController4229938
                    { vehicleInstanceId = vehicleId, controllerPid = 0 });
                await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
                lock (runtime.SyncRoot)
                {
                    runtime.StoryEnterVehicleId = 0;
                    if (runtime.Vehicles.TryGetValue(vehicleId, out var v))
                    {
                        if (v.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy == Profile.PlayerPid)
                            v.SeatReservations.Remove(seat);
                        if (v.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy == Profile.PlayerPid)
                            v.SeatOccupants.Remove(seat);
                        v.ControllerPid = 0;
                    }
                }
                conn.Log.Info($"[VEHICLE-STORY] enter cancelled vehicle={vehicleId}");
                return;
        }
    }

    private async Task BeginVehicleExit(Connection conn, VehicleRuntimeState runtime, bool stopBeforeLeave)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (runtime.SyncRoot)
        {
            vehicleId = runtime.CurrentVehicleId;
            seat = (byte)Math.Max(0, runtime.CurrentVehicleSeat);
            unitId = runtime.StoryBoardingUnitId != 0 ? runtime.StoryBoardingUnitId : Profile.InitialUnitId;
            if (vehicleId == 0 || runtime.StoryExitInProgress)
                return;
            runtime.StoryExitInProgress = true;
        }
        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildExitChildBootstrap(VehicleStoryExitNid, vehicleId, seat, stopBeforeLeave));
        await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 5);
        conn.Log.Info($"[VEHICLE-STORY] exit begin vehicle={vehicleId} seat={seat} status=5");
    }

    private async Task AdvanceVehicleExit(Connection conn, VehicleRuntimeState runtime, int phase)
    {
        ulong vehicleId;
        byte seat;
        ulong unitId;
        lock (runtime.SyncRoot)
        {
            vehicleId = runtime.CurrentVehicleId;
            seat = (byte)Math.Max(0, runtime.CurrentVehicleSeat);
            unitId = runtime.StoryBoardingUnitId != 0 ? runtime.StoryBoardingUnitId : Profile.InitialUnitId;
        }
        if (vehicleId == 0)
            return;
        if (phase == 0)
            return;
        if (phase == 1)
        {
            await SendVehicleBoardingStatus(conn, unitId, vehicleId, 0, 0);
            await conn.NotifyAsync(MethodId.SyncChangeVehicleController, new GameMethods.SyncChangeVehicleController4229938
                { vehicleInstanceId = vehicleId, controllerPid = 0 });
            await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (runtime.SyncRoot)
            {
                runtime.CurrentVehicleId = 0;
                runtime.CurrentVehicleSeat = -1;
                runtime.StoryExitInProgress = false;
                if (runtime.Vehicles.TryGetValue(vehicleId, out var v))
                {
                    if (v.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy == Profile.PlayerPid)
                        v.SeatOccupants.Remove(seat);
                    if (v.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy == Profile.PlayerPid)
                        v.SeatReservations.Remove(seat);
                    v.ControllerPid = 0;
                    v.Interactable = true;
                }
            }
            conn.Log.Info($"[VEHICLE-STORY] exit complete vehicle={vehicleId} status=0");
        }
        else if (phase == 2)
        {
            await SendVehicleBoardingStatus(conn, unitId, vehicleId, seat, 4);
            await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (runtime.SyncRoot)
                runtime.StoryExitInProgress = false;
            conn.Log.Info($"[VEHICLE-STORY] exit cancelled vehicle={vehicleId} status=4");
        }
    }

    [Handler(MethodId.AskClaimVehicleSeat)]
    private async Task AskClaimVehicleSeatStory(Connection conn, UxRpcMessage msg)
    {
        if (!msg.TryGetArgs<GameMethods.AskClaimVehicleSeatArgs4229938>(out var args) || args is null)
        {
            conn.Log.Warn($"[VEHICLE] AskClaimVehicleSeat undecodable bytes={msg.Body.Length}");
            await conn.ReturnEmptyOkAsync(msg);
            return;
        }
        var runtime = GetVehicleRuntime(msg.Context);
        byte selected = 0;
        var valid = false;
        lock (runtime.SyncRoot)
        {
            if (runtime.StoryEnterVehicleId == args.vehicleEntityId
                && runtime.Vehicles.TryGetValue(args.vehicleEntityId, out var vehicle))
            {
                foreach (var seat in args.seatIndices)
                {
                    var reservedByOther = vehicle.SeatReservations.TryGetValue(seat, out var reservedBy) && reservedBy != Profile.PlayerPid;
                    var occupiedByOther = vehicle.SeatOccupants.TryGetValue(seat, out var occupiedBy) && occupiedBy != Profile.PlayerPid;
                    if (seat < vehicle.SeatCount && !reservedByOther && !occupiedByOther)
                    {
                        selected = seat;
                        valid = true;
                        break;
                    }
                }
                if (valid)
                {
                    var oldSeat = runtime.StoryEnterSeat;
                    if (vehicle.SeatReservations.TryGetValue(oldSeat, out var oldOwner) && oldOwner == Profile.PlayerPid)
                        vehicle.SeatReservations.Remove(oldSeat);
                    vehicle.SeatReservations[selected] = Profile.PlayerPid;
                    runtime.StoryEnterSeat = selected;
                }
            }
        }
        if (!valid)
        {
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }
        await conn.ReturnAsync(msg, selected);
        conn.Log.Info($"[VEHICLE-STORY] seat claim vehicle={args.vehicleEntityId} seat={selected}");
    }

    private Task SendVehicleBoardingStatus(Connection conn, ulong unitId, ulong vehicleId, byte seat, byte status)
        => conn.NotifyAsync(MethodId.SyncUnitVehicleStatus, new GameMethods.NewClientBoardingInfo4229938
        {
            EntityId = unitId,
            Status = status,
            VehicleUId = vehicleId,
            SeatIndex = seat,
            ExtInfo = null,
        });

    /// <summary>
    /// Server-forced enter (admin button path): seats the player without any client
    /// F-press. Mirrors the enter-complete leg — move-to-seat, controller, boarding
    /// status seated, start/state-change/finish drive-state notifies — plus an S011
    /// enter child so the story side agrees, deleted right after like a phase-3 commit.
    /// </summary>
    internal static async Task<(bool Ok, string Message)> ForceEnterVehicleAsync(TcpSession session)
    {
        var runtime = GetVehicleRuntimeState(session);
        var state = GetStateIfExists(session);
        ulong unitId = state?.ActiveSpiritUnitId ?? Profile.InitialUnitId;
        ulong pid = Profile.PlayerPid;
        ulong vehicleId;
        byte seat = 0;
        lock (runtime.SyncRoot)
        {
            vehicleId = runtime.SummonedEntity;
            if (vehicleId == 0 || !runtime.Vehicles.TryGetValue(vehicleId, out var vehicle))
                return (false, "no spawned vehicle (spawn one first)");
            if (runtime.CurrentVehicleId != 0)
                return (false, $"already in vehicle {runtime.CurrentVehicleId} (exit first)");
            if (!vehicle.Interactable || vehicle.SeatOccupants.ContainsKey(seat))
                return (false, "vehicle is not enterable right now");
            vehicle.SeatReservations.Remove(seat);
            vehicle.SeatOccupants[seat] = pid;
            vehicle.ControllerPid = pid;
            runtime.CurrentVehicleId = vehicleId;
            runtime.CurrentVehicleSeat = seat;
            runtime.StoryEnterVehicleId = 0;
        }
        var drive = new GameMethods.PlayerVehicleDriveStateInfo4229938
        {
            Pid = pid, EnterOrLeave = true, VehicleEntityId = vehicleId, SeatIndex = seat,
            IfForce = true, OpenDoorTypeId = 0, OpenDoorActionSpeed = 0, OpenDoorActionClipLength = 0,
        };
        try
        {
            var ct = CancellationToken.None;
            await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
                new GameMethods.SyncChangeVehicleInteractable4229938 { vehicleInstanceId = vehicleId, interactable = false }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerMoveToDriveSeat, UxSerializer.Serialize(
                new GameMethods.SyncPlayerMoveToDriveSeat4229938 { pid = pid, vehicleEntityId = vehicleId }), ct);
            await session.NotifyAsync(MethodId.SyncUnitVehicleStatus, UxSerializer.Serialize(
                new GameMethods.NewClientBoardingInfo4229938 { EntityId = unitId, Status = 4, VehicleUId = vehicleId, SeatIndex = seat, ExtInfo = null }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerStartEnterOrExitVehicl, UxSerializer.Serialize(drive), ct);
            await session.NotifyAsync(MethodId.SyncPlayerVehicleStateChange, UxSerializer.Serialize(drive), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleController, UxSerializer.Serialize(
                new GameMethods.SyncChangeVehicleController4229938 { vehicleInstanceId = vehicleId, controllerPid = pid }), ct);
            await session.NotifyAsync(MethodId.SyncPlayerFinishEnterOrExitVehic, UxSerializer.Serialize(drive), ct);
            await SendStoryAsync(session, StoryS011Codec4229938.BuildEnterChildBootstrap(VehicleStoryEnterNid, vehicleId, seat));
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
            session.Log.Info($"[VEHICLE-STORY] force enter vehicle={vehicleId} seat={seat} unit={unitId} status=4");
            return (true, $"seated in vehicle {vehicleId} (seat 0) — drive with normal keys, exit with the Exit button or F");
        }
        catch (Exception ex)
        {
            return (false, $"enter failed: {ex.Message}");
        }
    }

    /// <summary>Server-forced exit (admin button path).</summary>
    internal static async Task<(bool Ok, string Message)> ForceExitVehicleAsync(TcpSession session)
    {
        var runtime = GetVehicleRuntimeState(session);
        var state = GetStateIfExists(session);
        ulong unitId = state?.ActiveSpiritUnitId ?? Profile.InitialUnitId;
        ulong vehicleId;
        lock (runtime.SyncRoot)
        {
            vehicleId = runtime.CurrentVehicleId;
            if (vehicleId == 0)
                return (false, "not in a vehicle");
        }
        try
        {
            var ct = CancellationToken.None;
            await session.NotifyAsync(MethodId.SyncPlayerExitVehicle, UxSerializer.Serialize(
                new GameMethods.SyncPlayerExitVehicle4229938 { vehicleEntityId = vehicleId, force = true, stopBeforeLeave = true }), ct);
            await session.NotifyAsync(MethodId.SyncUnitVehicleStatus, UxSerializer.Serialize(
                new GameMethods.NewClientBoardingInfo4229938 { EntityId = unitId, Status = 0, VehicleUId = vehicleId, SeatIndex = 0, ExtInfo = null }), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleController, UxSerializer.Serialize(
                new GameMethods.SyncChangeVehicleController4229938 { vehicleInstanceId = vehicleId, controllerPid = 0 }), ct);
            await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
                new GameMethods.SyncChangeVehicleInteractable4229938 { vehicleInstanceId = vehicleId, interactable = true }), ct);
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            lock (runtime.SyncRoot)
            {
                runtime.CurrentVehicleId = 0;
                runtime.CurrentVehicleSeat = -1;
                runtime.StoryEnterVehicleId = 0;
                runtime.StoryExitInProgress = false;
                if (runtime.Vehicles.TryGetValue(vehicleId, out var v))
                {
                    v.SeatOccupants.Clear();
                    v.SeatReservations.Clear();
                    v.ControllerPid = 0;
                    v.Interactable = true;
                }
            }
            session.Log.Info($"[VEHICLE-STORY] force exit vehicle={vehicleId}");
            return (true, $"exited vehicle {vehicleId}");
        }
        catch (Exception ex)
        {
            return (false, $"exit failed: {ex.Message}");
        }
    }

    /// <summary>Best-effort eject before scene switches: client state must not keep a stale seat.</summary>
    internal static async Task ForceLeaveVehicleAsync(TcpSession session)    {
        try
        {
            var runtime = GetVehicleRuntimeState(session);
            ulong vehicleId;
            lock (runtime.SyncRoot)
            {
                vehicleId = runtime.CurrentVehicleId != 0 ? runtime.CurrentVehicleId : runtime.StoryEnterVehicleId;
                if (vehicleId == 0)
                    return;
            }
            var state = GetStateIfExists(session);
            ulong unitId = state?.ActiveSpiritUnitId ?? Profile.InitialUnitId;
            await session.NotifyAsync(MethodId.SyncUnitVehicleStatus, UxSerializer.Serialize(
                new GameMethods.NewClientBoardingInfo4229938 { EntityId = unitId, Status = 0, VehicleUId = vehicleId, SeatIndex = 0, ExtInfo = null }),
                CancellationToken.None);
            await session.NotifyAsync(MethodId.SyncChangeVehicleController, UxSerializer.Serialize(
                new GameMethods.SyncChangeVehicleController4229938 { vehicleInstanceId = vehicleId, controllerPid = 0 }),
                CancellationToken.None);
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryEnterNid));
            await SendStoryAsync(session, StoryS011Codec4229938.BuildDeleteNode(VehicleStoryExitNid));
            runtime.Clear();
            session.Log.Info($"[VEHICLE-STORY] force leave before scene switch vehicle={vehicleId}");
        }
        catch (Exception ex)
        {
            session.Log.Warn($"[VEHICLE-STORY] force leave failed: {ex.Message}");
        }
    }

    private async Task ConfirmVehicleStoryRpc(Connection conn, VehicleRuntimeState runtime, long? commitRpcId)
    {
        long highest;
        lock (runtime.SyncRoot)
        {
            if (commitRpcId is long id && id >= 0)
                runtime.StoryCommittedRpcIds.Add(id);
            highest = runtime.StoryHighestConfirmedRpcId;
            while (runtime.StoryPendingRpcIds.Count > 0)
            {
                var next = highest + 1;
                if (next >= 0 && runtime.StoryCommittedRpcIds.Contains(next))
                {
                    highest = next;
                    runtime.StoryPendingRpcIds.Remove(next);
                    runtime.StoryCommittedRpcIds.Remove(next);
                }
                else break;
            }
            if (highest <= runtime.StoryHighestConfirmedRpcId)
                return;
            runtime.StoryHighestConfirmedRpcId = highest;
        }
        await SendStoryAsync(conn.Session, StoryS011Codec4229938.BuildConfirmRpc(highest));
    }

    private static Task SendStoryAsync(TcpSession session, byte[] payload)
        => session.NotifyAsync(MethodId.SyncStoryCoreServerInfo, payload, CancellationToken.None);
}
