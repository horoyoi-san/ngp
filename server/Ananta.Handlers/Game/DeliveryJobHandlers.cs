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

    public class AskAcceptTruckJobOrderArg : SerializedClass
    {
        public uint orderid;
        public AskAcceptTruckJobOrderArg() { onlyFields = true; }
    }

    public class AskObsoleteTruckJobOrderArg : SerializedClass
    {
        public uint orderid;
        public AskObsoleteTruckJobOrderArg() { onlyFields = true; }
    }

    public class AskPreSettleTruckOrderArg : SerializedClass
    {
        public uint orderid;
        public List<float> cargointegritylist;
        public AskPreSettleTruckOrderArg() { onlyFields = true; }
    }

    public class AskSettleTruckOrderArg : SerializedClass
    {
        public uint orderid;
        public AskSettleTruckOrderArg() { onlyFields = true; }
    }

    public class AskAutoAcceptTruckJobOrderArg : SerializedClass
    {
        public bool desiredauto;
        public AskAutoAcceptTruckJobOrderArg() { onlyFields = true; }
    }

    public class AskSetTruckJobDefaultVehicleIdArg : SerializedClass
    {
        public uint vehicleid;
        public AskSetTruckJobDefaultVehicleIdArg() { onlyFields = true; }
    }

    public class AskQueryTruckPosInfoArg : SerializedClass
    {
        public List<uint> pickupids;
        public List<uint> deliveryids;
        public AskQueryTruckPosInfoArg() { onlyFields = true; }
    }

    public class AskResetTruckOrderGoodsArg : SerializedClass
    {
        public uint orderid;
        public AskResetTruckOrderGoodsArg() { onlyFields = true; }
    }

    public class AskStartTruckOrderGuideArg : SerializedClass
    {
        // No args
        public AskStartTruckOrderGuideArg() { onlyFields = true; }
    }

    public class AskDoTruckNpcActionArg : SerializedClass
    {
        public uint orderid;
        public uint actionid;
        public AskDoTruckNpcActionArg() { onlyFields = true; }
    }

    // ── Sync Notify Args ──────────────────────────────────────────

    public class SyncTruckOrderWrapArgs : SerializedClass
    {
        public TruckOrderWrap order;
        public SyncTruckOrderWrapArgs() { onlyFields = true; }
    }

    public class SyncCurrentTruckOrderArgs : SerializedClass
    {
        public uint id;
        public SyncCurrentTruckOrderArgs() { onlyFields = true; }
    }

    public class SyncAcceptTruckJobOrderArgs : SerializedClass
    {
        public uint id;
        public TruckOrderWrap orderinfo;
        public ulong deliveryagentid;
        public SyncAcceptTruckJobOrderArgs() { onlyFields = true; }
    }

    // ── Helpers ────────────────────────────────────────────────────

    public static class TruckOrderGenerator
    {
        private static uint _nextOrderId = 1001;
        private static readonly Random Rng = new Random();

        private static TruckWayPointInfo MakeWaypoint(int wpId, float x, float y, float z)
        {
            return new TruckWayPointInfo()
            {
                WpId = wpId,
                ConfigId = 0,
                Pos = new UXVector3 { X = x, Y = y, Z = z },
                Rot = new UXVector3(),
                GadgetUId = 0
            };
        }

        public static TruckOrderWrap GenerateOrder()
        {
            uint orderId = _nextOrderId++;
            float startX = (float)(Rng.NextDouble() * 200 - 100);
            float startZ = (float)(Rng.NextDouble() * 200 - 100);
            float endX = startX + (float)(Rng.NextDouble() * 80 - 40);
            float endZ = startZ + (float)(Rng.NextDouble() * 80 - 40);

            return new TruckOrderWrap()
            {
                OrderInfo = new TruckOrderInfo()
                {
                    StartPos = MakeWaypoint(0, startX, 0, startZ),
                    EndPos = MakeWaypoint(1, endX, 0, endZ),
                    CargoId = (uint)Rng.Next(1000, 2000),
                    DeliveryNpc = new TruckDeliveryNpcInfo()
                    {
                        NpcId = (uint)Rng.Next(40968601, 40968700),
                        ConsigneeId = (uint)Rng.Next(40968700, 40968778),
                        RudeId = 0,
                        CharacterId = 0
                    },
                    IsEmergency = Rng.NextDouble() < 0.2,
                    LimitAcceptSeconds = 300,
                    LimitFinishSeconds = 600,
                    EstimatedFinishSeconds = 300,
                    CargoInfoList = new List<TruckCargoInfo>()
                    {
                        new TruckCargoInfo()
                        {
                            CargoId = (uint)Rng.Next(1000, 2000),
                            StartPos = MakeWaypoint(0, startX, 0, startZ),
                            Integrity = 100,
                            IsCargoNear = false,
                            UniqueId = (ulong)Rng.Next(9000000, 9999999)
                        }
                    },
                    BasePointReward = Rng.Next(10, 50),
                    DropCoefficient = 1.0f,
                    DropMoney = Rng.Next(100, 500),
                    SpecialOrderId = 0,
                    SpecialPointReward = 0,
                    AddDropCoefficient = 0,
                    ActivityIndex = 0,
                    IsHighValue = false,
                    RandomOrderId = orderId,
                    IsDailyOrder = true,
                    OrderType = 0
                },
                UniqueId = orderId,
                OrderInfoStartTime = 0,
                AcceptInfo = new TruckAcceptInfo(),
                ResultInfo = new TruckResultInfo()
                {
                    AddBuffList = new(),
                    RemoveBuffList = new()
                },
                CargoPickedUp = false,
                CargoIntegrity = 100.0f
            };
        }

        public static ClientTruckOrderView GenerateInitialView()
        {
            return new ClientTruckOrderView()
            {
                Orders = new List<TruckOrderWrap>()
                {
                    GenerateOrder(),
                    GenerateOrder(),
                    GenerateOrder()
                },
                RewardPointSum = 0,
                CustomerSatisfactionAverage = 100.0f,
                CurrentOrderId = 0,
                TruckGuideClicked = true,
                EventIdToAgent = new(),
                AutoAccept = false,
                DefaultVehicleId = 0,
                TotalIncome = 0
            };
        }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class DeliveryJobHandlers
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

        private static ClientTruckOrderView GetOrCreateTruckState(Connection conn)
        {
            if (conn.TruckJobState == null)
                conn.TruckJobState = TruckOrderGenerator.GenerateInitialView();
            return conn.TruckJobState;
        }

        [Handler(MethodId.AskGetTruckJobOrders)]
        public static void AskGetTruckJobOrdersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskGetTruckJobOrders");
            var state = GetOrCreateTruckState(conn);

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetTruckJobOrders,
            };
            rsp.SetArgs(MethodId.AskGetTruckJobOrders, state);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskAcceptTruckJobOrder)]
        public static void AskAcceptTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAcceptTruckJobOrderArg>();
            uint orderId = args.orderid;
            Console.WriteLine($"[Truck] AskAcceptTruckJobOrder order={orderId}");

            var state = GetOrCreateTruckState(conn);
            var order = state.Orders?.FirstOrDefault(o => o.UniqueId == orderId);
            if (order != null)
            {
                order.AcceptInfo = new TruckAcceptInfo()
                {
                    AcceptedEventId = orderId,
                    AcceptTime = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds())
                };
                state.CurrentOrderId = orderId;

                SendNotify(conn, MethodId.SyncAcceptTruckJobOrder, new SyncAcceptTruckJobOrderArgs()
                {
                    id = orderId,
                    orderinfo = order,
                    deliveryagentid = 0
                });

                SendNotify(conn, MethodId.SyncCurrentTruckOrder, new SyncCurrentTruckOrderArgs()
                {
                    id = orderId
                });
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskAcceptTruckJobOrder);
        }

        [Handler(MethodId.AskPreSettleTruckOrder)]
        public static void AskPreSettleTruckOrderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPreSettleTruckOrderArg>();
            uint orderId = args.orderid;
            Console.WriteLine($"[Truck] AskPreSettleTruckOrder order={orderId}");

            var state = GetOrCreateTruckState(conn);
            var order = state.Orders?.FirstOrDefault(o => o.UniqueId == orderId);

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPreSettleTruckOrder,
            };

            if (order != null)
            {
                // Return the order wrap as settlement preview
                rsp.SetArgs(MethodId.AskPreSettleTruckOrder, order);
            }
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSettleTruckOrder)]
        public static void AskSettleTruckOrderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSettleTruckOrderArg>();
            uint orderId = args.orderid;
            Console.WriteLine($"[Truck] AskSettleTruckOrder order={orderId}");

            var state = GetOrCreateTruckState(conn);
            var order = state.Orders?.FirstOrDefault(o => o.UniqueId == orderId);
            if (order != null)
            {
                // Fill result info with success values
                order.ResultInfo = new TruckResultInfo()
                {
                    FinishTime = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds()),
                    CargoIntegrity = 100,
                    DropId = 0,
                    DropCoefficient = 1.0f,
                    RewardPoint = order.OrderInfo?.BasePointReward ?? 10,
                    Evaluation = 3, // 3-star
                    CustomerSatisfaction = 100.0f,
                    DropMoney = order.OrderInfo?.DropMoney ?? 100,
                    Dropped = true,
                    IsCargoNear = false,
                    AddBuffList = new(),
                    RemoveBuffList = new(),
                    OrderDeliverUpSetId = 0,
                    DeliverUpset = 0
                };

                // Update totals
                state.RewardPointSum += order.ResultInfo.RewardPoint;
                state.TotalIncome += order.ResultInfo.DropMoney;
                state.CurrentOrderId = 0;

                // Remove completed order and generate a new one
                state.Orders.Remove(order);
                state.Orders.Add(TruckOrderGenerator.GenerateOrder());

                // Send updated order as notify
                SendNotify(conn, MethodId.SyncTruckOrderWrap, new SyncTruckOrderWrapArgs()
                {
                    order = order
                });
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskSettleTruckOrder);
        }

        [Handler(MethodId.AskAutoAcceptTruckJobOrder)]
        public static void AskAutoAcceptTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAutoAcceptTruckJobOrderArg>();
            Console.WriteLine($"[Truck] AskAutoAcceptTruckJobOrder auto={args.desiredauto}");

            var state = GetOrCreateTruckState(conn);
            state.AutoAccept = args.desiredauto;

            SendEmptySuccessReturn(conn, msg, MethodId.AskAutoAcceptTruckJobOrder);
        }

        [Handler(MethodId.AskSetTruckJobDefaultVehicleId)]
        public static void AskSetTruckJobDefaultVehicleIdHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSetTruckJobDefaultVehicleIdArg>();
            Console.WriteLine($"[Truck] AskSetTruckJobDefaultVehicleId vehicle={args.vehicleid}");

            var state = GetOrCreateTruckState(conn);
            state.DefaultVehicleId = args.vehicleid;

            SendEmptySuccessReturn(conn, msg, MethodId.AskSetTruckJobDefaultVehicleId);
        }

        [Handler(MethodId.AskQueryTruckPosInfo)]
        public static void AskQueryTruckPosInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskQueryTruckPosInfo");
            // Return empty - no active trucks on private server
            SendEmptySuccessReturn(conn, msg, MethodId.AskQueryTruckPosInfo);
        }

        [Handler(MethodId.AskRefreshTruckOrder)]
        public static void AskRefreshTruckOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskRefreshTruckOrder");
            var state = GetOrCreateTruckState(conn);
            // Replace all unaccepted orders with new ones
            if (state.Orders != null)
            {
                var unaccepted = state.Orders.Where(o => o.AcceptInfo?.AcceptTime == 0).ToList();
                foreach (var o in unaccepted)
                    state.Orders.Remove(o);
                while (state.Orders.Count < 3)
                    state.Orders.Add(TruckOrderGenerator.GenerateOrder());
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskRefreshTruckOrder);
        }

        [Handler(MethodId.AskResetTruckOrderGoods)]
        public static void AskResetTruckOrderGoodsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskResetTruckOrderGoods");
            SendEmptySuccessReturn(conn, msg, MethodId.AskResetTruckOrderGoods);
        }

        [Handler(MethodId.AskObsoleteTruckJobOrder)]
        public static void AskObsoleteTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskObsoleteTruckJobOrderArg>();
            Console.WriteLine($"[Truck] AskObsoleteTruckJobOrder order={args.orderid}");
            var state = GetOrCreateTruckState(conn);
            state.Orders?.RemoveAll(o => o.UniqueId == args.orderid);
            SendEmptySuccessReturn(conn, msg, MethodId.AskObsoleteTruckJobOrder);
        }

        [Handler(MethodId.AskDoTruckNpcAction)]
        public static void AskDoTruckNpcActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskDoTruckNpcAction");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoTruckNpcAction);
        }

        [Handler(MethodId.AskGetTruckSatisfactionAverage)]
        public static void AskGetTruckSatisfactionAverageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskGetTruckSatisfactionAverage");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetTruckSatisfactionAverage);
        }

        [Handler(MethodId.AskStartTruckOrderGuide)]
        public static void AskStartTruckOrderGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Truck] AskStartTruckOrderGuide");
            var state = GetOrCreateTruckState(conn);
            state.TruckGuideClicked = true;
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartTruckOrderGuide);
        }
    }
}
