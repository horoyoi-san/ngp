using System;
using System.Collections.Generic;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Request Args ──────────────────────────────────────────────

    public class AskAddBuildHouseIndoorArg : SerializedClass
    {
        public uint houseid;
        public uint floor;
        public AddPlacedFurnitureInfo addplacedfurnitureinfo;
        public AskAddBuildHouseIndoorArg() { onlyFields = true; }
    }

    public class AskChangeBuildHouseIndoorArg : SerializedClass
    {
        public uint houseid;
        public uint floor;
        public ChangePlacedFurnitureInfo changeplacedfurnitureinfo;
        public AskChangeBuildHouseIndoorArg() { onlyFields = true; }
    }

    public class AskRemoveBuildHouseIndoorArg : SerializedClass
    {
        public uint houseid;
        public uint floor;
        public List<ulong> removeplacedinstanceidlist;
        public AskRemoveBuildHouseIndoorArg() { onlyFields = true; }
    }

    public class AskHouseCancelParkingArg : SerializedClass
    {
        public List<uint> vehicleidlist;
        public AskHouseCancelParkingArg() { onlyFields = true; }
    }

    public class AskHouseParkingArg : SerializedClass
    {
        public List<HouseParkingInfo> parkinginfolist;
        public AskHouseParkingArg() { onlyFields = true; }
    }

    public class AskHouseMoveParkingSpaceArg : SerializedClass
    {
        public List<HouseMoveParkingSpaceInfo> moveparkingspaceinfolist;
        public AskHouseMoveParkingSpaceArg() { onlyFields = true; }
    }

    // ── Sync Notify Args ──────────────────────────────────────────

    public class SyncAddHouseArgs : SerializedClass
    {
        public HouseInfo houseinfo;
        public SyncAddHouseArgs() { onlyFields = true; }
    }

    public class SyncRemoveHouseArgs : SerializedClass
    {
        public uint houseid;
        public SyncRemoveHouseArgs() { onlyFields = true; }
    }

    public class SyncFurnitureInfoArgs : SerializedClass
    {
        public uint furnitureid;
        public uint count;
        public uint placedcount;
        public SyncFurnitureInfoArgs() { onlyFields = true; }
    }

    public class SyncHouseCancelParkingArgs : SerializedClass
    {
        public List<uint> vehicleidlist;
        public SyncHouseCancelParkingArgs() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class HousingHandlers
    {
        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        private static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage notify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcMethodId = (int)methodId,
            };
            notify.SetArgs(methodId, args);
            conn.SendPacket(notify);
        }

        /// <summary>
        /// Get or create a HouseInfo for the given houseId on the connection.
        /// </summary>
        private static HouseInfo GetOrCreateHouse(Connection conn, uint houseId)
        {
            if (!conn.OwnedHouses.TryGetValue(houseId, out var house))
            {
                house = new HouseInfo()
                {
                    HouseId = houseId,
                    ParkingSpaceVehicleIdDict = new(),
                    FloorBuildInfoDict = new(),
                    CurPlacedFurnitureInstanceId = 1000000 // start IDs high to avoid conflicts
                };
                conn.OwnedHouses[houseId] = house;
            }
            return house;
        }

        /// <summary>
        /// Get or create IndoorBuildInfo for a floor.
        /// </summary>
        private static IndoorBuildInfo GetOrCreateFloor(HouseInfo house, uint floor)
        {
            if (!house.FloorBuildInfoDict.TryGetValue(floor, out var floorInfo))
            {
                floorInfo = new IndoorBuildInfo()
                {
                    Root = new PlacedFurnitureInfo()
                    {
                        FurnitureId = 0,
                        Position = new UXVector3(),
                        Rotation = new UXVector3(),
                        GadgetInstanceId = 0,
                        PlacedInstanceId = 0,
                        ChildrenDict = new()
                    }
                };
                house.FloorBuildInfoDict[floor] = floorInfo;
            }
            return floorInfo;
        }

        /// <summary>
        /// AskAddBuildHouseIndoor:
        /// Add a new piece of furniture to a house floor.
        /// Returns the newly created PlacedFurnitureInfo.
        /// </summary>
        [Handler(MethodId.AskAddBuildHouseIndoor)]
        public static void AskAddBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAddBuildHouseIndoorArg>();
            uint houseId = args.houseid;
            uint floor = args.floor;
            var addInfo = args.addplacedfurnitureinfo;

            Console.WriteLine($"[House] AskAddBuildHouseIndoor house={houseId} floor={floor} furniture={addInfo?.FurnitureId}");

            var house = GetOrCreateHouse(conn, houseId);
            var floorInfo = GetOrCreateFloor(house, floor);

            // Generate a new placed instance ID
            house.CurPlacedFurnitureInstanceId++;
            ulong newInstanceId = house.CurPlacedFurnitureInstanceId;

            var newPlaced = new PlacedFurnitureInfo()
            {
                FurnitureId = addInfo?.FurnitureId ?? 0,
                Position = addInfo?.Position ?? new UXVector3(),
                Rotation = addInfo?.Rotation ?? new UXVector3(),
                GadgetInstanceId = 0,
                PlacedInstanceId = newInstanceId,
                ChildrenDict = new()
            };

            // Add to parent's children (or to root if parent is 0)
            ulong parentId = addInfo?.ParentPlacedInstanceId ?? 0;
            var parent = FindFurnitureById(floorInfo.Root, parentId);
            if (parent != null)
            {
                if (parent.ChildrenDict == null)
                    parent.ChildrenDict = new();
                parent.ChildrenDict[newInstanceId] = newPlaced;
            }
            else
            {
                // Fallback: add to root
                if (floorInfo.Root.ChildrenDict == null)
                    floorInfo.Root.ChildrenDict = new();
                floorInfo.Root.ChildrenDict[newInstanceId] = newPlaced;
            }

            // Send return with the new PlacedFurnitureInfo
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAddBuildHouseIndoor,
            };
            rsp.SetArgs(MethodId.AskAddBuildHouseIndoor, newPlaced);
            conn.SendPacket(rsp);
        }

        /// <summary>
        /// Recursive search for a PlacedFurnitureInfo by its PlacedInstanceId.
        /// </summary>
        private static PlacedFurnitureInfo? FindFurnitureById(PlacedFurnitureInfo? node, ulong targetId)
        {
            if (node == null) return null;
            if (node.PlacedInstanceId == targetId) return node;
            if (node.ChildrenDict != null)
            {
                foreach (var child in node.ChildrenDict.Values)
                {
                    var found = FindFurnitureById(child, targetId);
                    if (found != null) return found;
                }
            }
            return null;
        }

        /// <summary>
        /// Remove a furniture item by PlacedInstanceId from the tree.
        /// </summary>
        private static bool RemoveFurnitureById(PlacedFurnitureInfo? node, ulong targetId)
        {
            if (node?.ChildrenDict == null) return false;
            if (node.ChildrenDict.Remove(targetId)) return true;
            foreach (var child in node.ChildrenDict.Values)
            {
                if (RemoveFurnitureById(child, targetId)) return true;
            }
            return false;
        }

        /// <summary>
        /// AskChangeBuildHouseIndoor:
        /// Change position/rotation/parent of an existing furniture piece.
        /// </summary>
        [Handler(MethodId.AskChangeBuildHouseIndoor)]
        public static void AskChangeBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChangeBuildHouseIndoorArg>();
            uint houseId = args.houseid;
            uint floor = args.floor;
            var changeInfo = args.changeplacedfurnitureinfo;

            Console.WriteLine($"[House] AskChangeBuildHouseIndoor house={houseId} floor={floor} instance={changeInfo?.PlacedInstanceId}");

            if (conn.OwnedHouses.TryGetValue(houseId, out var house)
                && house.FloorBuildInfoDict.TryGetValue(floor, out var floorInfo))
            {
                var existing = FindFurnitureById(floorInfo.Root, changeInfo?.PlacedInstanceId ?? 0);
                if (existing != null && changeInfo != null)
                {
                    existing.Position = changeInfo.Position;
                    existing.Rotation = changeInfo.Rotation;

                    // Handle parent change if requested
                    if (changeInfo.IsChangeParentNode)
                    {
                        // Remove from old parent
                        RemoveFurnitureById(floorInfo.Root, existing.PlacedInstanceId);

                        // Add to new parent
                        var newParent = FindFurnitureById(floorInfo.Root, changeInfo.ParentPlacedInstanceId);
                        if (newParent != null)
                        {
                            if (newParent.ChildrenDict == null)
                                newParent.ChildrenDict = new();
                            newParent.ChildrenDict[existing.PlacedInstanceId] = existing;
                        }
                        else
                        {
                            if (floorInfo.Root.ChildrenDict == null)
                                floorInfo.Root.ChildrenDict = new();
                            floorInfo.Root.ChildrenDict[existing.PlacedInstanceId] = existing;
                        }
                    }
                }
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeBuildHouseIndoor);
        }

        /// <summary>
        /// AskRemoveBuildHouseIndoor:
        /// Remove one or more furniture pieces by their PlacedInstanceIds.
        /// </summary>
        [Handler(MethodId.AskRemoveBuildHouseIndoor)]
        public static void AskRemoveBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskRemoveBuildHouseIndoorArg>();
            uint houseId = args.houseid;
            uint floor = args.floor;
            var removeList = args.removeplacedinstanceidlist ?? new();

            Console.WriteLine($"[House] AskRemoveBuildHouseIndoor house={houseId} floor={floor} count={removeList.Count}");

            if (conn.OwnedHouses.TryGetValue(houseId, out var house)
                && house.FloorBuildInfoDict.TryGetValue(floor, out var floorInfo))
            {
                foreach (ulong instanceId in removeList)
                {
                    RemoveFurnitureById(floorInfo.Root, instanceId);
                }
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveBuildHouseIndoor);
        }

        /// <summary>
        /// AskHouseParking:
        /// Park vehicles in house garage parking spaces.
        /// </summary>
        [Handler(MethodId.AskHouseParking)]
        public static void AskHouseParkingHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHouseParkingArg>();
            var parkingList = args.parkinginfolist ?? new();

            Console.WriteLine($"[House] AskHouseParking count={parkingList.Count}");

            var addList = new List<SyncHouseParking.HouseVehicleParkingInfo>();

            foreach (var parking in parkingList)
            {
                var house = GetOrCreateHouse(conn, parking.HouseId);
                if (house.ParkingSpaceVehicleIdDict == null)
                    house.ParkingSpaceVehicleIdDict = new();

                // Auto-assign next available parking space index
                int nextSlot = 0;
                while (house.ParkingSpaceVehicleIdDict.ContainsKey(nextSlot))
                    nextSlot++;
                house.ParkingSpaceVehicleIdDict[nextSlot] = parking.VehicleId;

                addList.Add(new SyncHouseParking.HouseVehicleParkingInfo()
                {
                    HouseId = parking.HouseId,
                    VehicleId = parking.VehicleId,
                    ParkingSpaceIndex = nextSlot
                });
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskHouseParking);

            if (addList.Count > 0)
            {
                SendNotify(conn, MethodId.SyncHouseParking, new SyncHouseParking()
                {
                    cancelInfoList = new(),
                    addInfoList = addList
                });
            }
        }

        /// <summary>
        /// AskHouseMoveParkingSpace:
        /// Move vehicles between parking spaces.
        /// </summary>
        [Handler(MethodId.AskHouseMoveParkingSpace)]
        public static void AskHouseMoveParkingSpaceHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHouseMoveParkingSpaceArg>();
            var moveList = args.moveparkingspaceinfolist ?? new();

            Console.WriteLine($"[House] AskHouseMoveParkingSpace count={moveList.Count}");

            var cancelList = new List<SyncHouseParking.HouseVehicleParkingInfo>();
            var addList = new List<SyncHouseParking.HouseVehicleParkingInfo>();

            foreach (var move in moveList)
            {
                if (conn.OwnedHouses.TryGetValue(move.HouseId, out var house))
                {
                    if (house.ParkingSpaceVehicleIdDict == null)
                        house.ParkingSpaceVehicleIdDict = new();

                    house.ParkingSpaceVehicleIdDict[move.ParkingSpaceIndex] = move.VehicleId;
                }

                addList.Add(new SyncHouseParking.HouseVehicleParkingInfo()
                {
                    HouseId = move.HouseId,
                    VehicleId = move.VehicleId,
                    ParkingSpaceIndex = move.ParkingSpaceIndex
                });
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskHouseMoveParkingSpace);
        }

        /// <summary>
        /// AskHouseCancelParking:
        /// Remove vehicles from parking spaces.
        /// </summary>
        [Handler(MethodId.AskHouseCancelParking)]
        public static void AskHouseCancelParkingHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHouseCancelParkingArg>();
            var vehicleIds = args.vehicleidlist ?? new();

            Console.WriteLine($"[House] AskHouseCancelParking vehicles={vehicleIds.Count}");

            var cancelList = new List<SyncHouseParking.HouseVehicleParkingInfo>();

            foreach (var house in conn.OwnedHouses.Values)
            {
                if (house.ParkingSpaceVehicleIdDict == null) continue;

                var toRemove = house.ParkingSpaceVehicleIdDict
                    .Where(kvp => vehicleIds.Contains(kvp.Value))
                    .ToList();

                foreach (var kvp in toRemove)
                {
                    house.ParkingSpaceVehicleIdDict.Remove(kvp.Key);
                    cancelList.Add(new SyncHouseParking.HouseVehicleParkingInfo()
                    {
                        HouseId = house.HouseId,
                        VehicleId = kvp.Value,
                        ParkingSpaceIndex = kvp.Key
                    });
                }
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskHouseCancelParking);

            if (cancelList.Count > 0)
            {
                SendNotify(conn, MethodId.SyncHouseParking, new SyncHouseParking()
                {
                    cancelInfoList = cancelList,
                    addInfoList = new()
                });
            }
        }

        /// <summary>
        /// AskTeleportToHouseGarage:
        /// Teleport player to a house garage. For private server, just acknowledge.
        /// </summary>
        [Handler(MethodId.AskTeleportToHouseGarage)]
        public static void AskTeleportToHouseGarageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[House] AskTeleportToHouseGarage");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTeleportToHouseGarage);
        }

        /// <summary>
        /// AskTeleportFromHouseGarage:
        /// Teleport player out of a house garage. For private server, just acknowledge.
        /// </summary>
        [Handler(MethodId.AskTeleportFromHouseGarage)]
        public static void AskTeleportFromHouseGarageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[House] AskTeleportFromHouseGarage");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTeleportFromHouseGarage);
        }
    }
}
