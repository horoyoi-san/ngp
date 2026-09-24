using Ananta.Server.Configuration;

namespace Ananta.Server.Protocol.Client4229938;

internal static class TruckOrderCodec4229938
{
    
    internal const uint TemplateMethodId = 63110537u;

    
    internal const uint OrderViewMethodId = 63386469u;

    

    private const int OffStartWpId = 3;
    private const int OffStartConfigId = 7;
    private const int OffStartPos = 11;          
    private const int OffStartRot = 23;          
    private const int OffEndWpId = 53;
    private const int OffEndConfigId = 57;
    private const int OffEndPos = 61;            
    private const int OffEndRot = 73;            
    private const int OffCargoId = 102;
    private const int OffNpcId = 107;
    private const int OffConsigneeId = 111;
    private const int OffRudeId = 115;
    private const int OffCharacterId = 119;
    private const int OffIsEmergency = 123;
    private const int OffLimitAccept = 124;
    private const int OffLimitFinish = 128;
    private const int OffEstimatedFinish = 132;
    private const int OffCargoListMarker = 136;
    private const int OffCargoListCount = 137;
    private const int OffBasePointReward = 141;
    private const int OffDropCoefficient = 145;
    private const int OffDropMoney = 149;
    private const int OffSpecialOrderId = 153;
    private const int OffSpecialPointReward = 157;
    private const int OffAddDropCoefficient = 161;
    private const int OffActivityIndex = 165;
    private const int OffIsHighValue = 169;
    private const int OffRandomOrderId = 170;
    private const int OffIsDailyOrder = 174;
    private const int OffOrderType = 175;
    private const int OffUniqueId = 179;
    private const int OffOrderInfoStartTime = 183;
    private const int OffAcceptMarker = 187;   
    private const int OffAcceptedEventId = 188;
    private const int OffAcceptTime = 192;
    
    private const int OffAcceptInfoEnd = 196;

    
    internal static readonly int[] ExpectedMarkerOffsets =
        [0, 1, 2, 43, 52, 93, 106, 136, 187, 196, 228, 233];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static readonly int[] ExpectedMarkerOffsetsUnaccepted =
        [0, 1, 2, 43, 52, 93, 106, 136, 188, 220, 225];

    private static readonly Lazy<byte[]> TemplateLazy = new(() =>
    {
        if (!DefaultReturnCatalog4229938.TryGet(TemplateMethodId, out var body, out var shape)
            || body.Length == 0)
        {
            throw new InvalidOperationException(
                $"DefaultReturnCatalog4229938 里没有 {TemplateMethodId}（AskAcceptTruckJobOrder）的中性包，"
                + "无法生成货运订单。");
        }

        
        
        if (!FindMarkerOffsets(body).SequenceEqual(ExpectedMarkerOffsets))
        {
            throw new InvalidOperationException(
                $"TruckJobOrderWrap 中性包结构变了（长度 {body.Length}，期望 259；"
                + $"标记偏移 {string.Join(",", FindMarkerOffsets(body))}），"
                + "请重新核对 TruckOrderCodec4229938 的偏移表。shape=" + shape);
        }

        return body;
    });

    
    internal static int TemplateLength => TemplateLazy.Value.Length;

    
    
    
    internal static byte[] BuildOrder(
        uint orderId,
        float startX, float startY, float startZ,
        float endX, float endY, float endZ,
        uint cargoId,
        uint npcId,
        uint consigneeId,
        uint rudeId,
        uint characterId,
        int limitAcceptSeconds,
        int limitFinishSeconds,
        int estimatedFinishSeconds,
        int basePointReward,
        float dropCoefficient,
        int dropMoney,
        bool isEmergency = false,
        bool isDailyOrder = true,
        uint orderType = 1,
        uint specialOrderId = 0,
        int specialPointReward = 0,
        float addDropCoefficient = 0f,
        uint activityIndex = 0,
        bool isHighValue = false,
        uint? orderInfoStartTime = null,
        bool accepted = false,
        uint acceptEventId = 0,
        uint acceptTime = 0)
    {
        var template = TemplateLazy.Value;

        
        byte[] buf;
        if (accepted)
        {
            buf = (byte[])template.Clone();
        }
        else
        {
            var ms = new MemoryStream(template.Length);
            ms.Write(template, 0, OffAcceptMarker);              
            ms.WriteByte(0x00);                                  
            ms.Write(template, OffAcceptInfoEnd,
                template.Length - OffAcceptInfoEnd);             
            buf = ms.ToArray();
        }

        
        WriteI32(buf, OffStartWpId, 0);
        WriteU32(buf, OffStartConfigId, 0);
        WriteVec3(buf, OffStartPos, startX, startY, startZ);
        WriteI32(buf, OffEndWpId, 1);
        WriteU32(buf, OffEndConfigId, 0);
        WriteVec3(buf, OffEndPos, endX, endY, endZ);

        WriteU32(buf, OffCargoId, cargoId);
        WriteU32(buf, OffNpcId, npcId);
        WriteU32(buf, OffConsigneeId, consigneeId);
        WriteU32(buf, OffRudeId, rudeId);
        WriteU32(buf, OffCharacterId, characterId);

        buf[OffIsEmergency] = isEmergency ? (byte)1 : (byte)0;
        WriteI32(buf, OffLimitAccept, limitAcceptSeconds);
        WriteI32(buf, OffLimitFinish, limitFinishSeconds);
        WriteI32(buf, OffEstimatedFinish, estimatedFinishSeconds);

        
        buf[OffCargoListMarker] = 0xFF;
        WriteI32(buf, OffCargoListCount, 0);

        WriteI32(buf, OffBasePointReward, basePointReward);
        WriteF32(buf, OffDropCoefficient, dropCoefficient);
        WriteI32(buf, OffDropMoney, dropMoney);
        WriteU32(buf, OffSpecialOrderId, specialOrderId);
        WriteI32(buf, OffSpecialPointReward, specialPointReward);
        WriteF32(buf, OffAddDropCoefficient, addDropCoefficient);
        WriteU32(buf, OffActivityIndex, activityIndex);
        buf[OffIsHighValue] = isHighValue ? (byte)1 : (byte)0;
        WriteU32(buf, OffRandomOrderId, orderId);
        buf[OffIsDailyOrder] = isDailyOrder ? (byte)1 : (byte)0;
        WriteU32(buf, OffOrderType, orderType);

        WriteU32(buf, OffUniqueId, orderId);

        
        
        
        
        
        
        
        
        WriteI32(buf, OffOrderInfoStartTime, (int)(orderInfoStartTime ?? NowUnix()));

        if (accepted)
        {
            buf[OffAcceptMarker] = 0xFF;
            WriteU32(buf, OffAcceptedEventId, acceptEventId == 0 ? orderId : acceptEventId);
            WriteU32(buf, OffAcceptTime, acceptTime == 0 ? NowUnix() : acceptTime);
        }
        else
        {
            buf[OffAcceptMarker] = 0x00;   
        }

        return buf;
    }

    
    internal static uint NowUnix()
        => (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();

    
    
    
    
    
    
    internal static byte[] MarkAccepted(byte[] order, uint eventId, uint acceptTime)
    {
        if (order.Length <= OffAcceptMarker)
            throw new ArgumentException("订单字节太短，不是本编解码器产出的", nameof(order));

        var ms = new MemoryStream(order.Length + 9);
        ms.Write(order, 0, OffAcceptMarker);        
        ms.WriteByte(0xFF);
        ms.Write(BitConverter.GetBytes(eventId == 0 ? 0u : eventId));
        ms.Write(BitConverter.GetBytes(acceptTime));
        ms.Write(order, OffAcceptMarker + 1,
            order.Length - OffAcceptMarker - 1);    
        return ms.ToArray();
    }

    
    
    
    
    
    
    
    
    
    
    
    
    internal static byte[] BuildOrderViewBytes(
        IReadOnlyList<byte[]> orders,
        int rewardPointSum,
        float customerSatisfactionAverage,
        uint currentOrderId,
        bool truckGuideClicked,
        bool autoAccept,
        uint defaultVehicleId,
        int totalIncome)
    {
        var ms = new MemoryStream();
        ms.WriteByte(0xFF);                       
        ms.WriteByte(0xFF);                       
        ms.WriteByte((byte)(orders.Count + 1));   
        foreach (var order in orders)
            ms.Write(order);

        WriteI32(ms, rewardPointSum);
        WriteF32(ms, customerSatisfactionAverage);
        WriteU32(ms, currentOrderId);
        ms.WriteByte(truckGuideClicked ? (byte)1 : (byte)0);
        ms.WriteByte(0xFF);                       
        ms.WriteByte(0x01);                       
        ms.WriteByte(autoAccept ? (byte)1 : (byte)0);
        WriteU32(ms, defaultVehicleId);
        WriteI32(ms, totalIncome);
        return ms.ToArray();
    }

    
    internal static byte[] BuildEmptyOrderViewBytes()
        => BuildOrderViewBytes([], 0, 100f, 0, false, false, 0, 0);

    
    
    
    
    internal static byte[] BuildOrderListBytes(IReadOnlyList<byte[]> orders)
    {
        var ms = new MemoryStream();
        ms.WriteByte(0xFF);
        ms.WriteByte((byte)(orders.Count + 1));
        foreach (var order in orders)
            ms.Write(order);
        return ms.ToArray();
    }

    
    internal static bool MarkerOffsetsMatch(byte[] body)
    {
        var got = FindMarkerOffsets(body);
        return got.SequenceEqual(ExpectedMarkerOffsets)
            || got.SequenceEqual(ExpectedMarkerOffsetsUnaccepted);
    }

    internal static int[] FindMarkerOffsets(byte[] body)
    {
        var list = new List<int>();
        for (var i = 0; i < body.Length; i++)
            if (body[i] == 0xFF)
                list.Add(i);
        return [.. list];
    }

    

    
    internal static uint ReadU32(byte[] buf, int off)
        => off >= 0 && off + 4 <= buf.Length ? BitConverter.ToUInt32(buf, off) : 0u;

    
    internal static int ReadI32(byte[] buf, int off)
        => off >= 0 && off + 4 <= buf.Length ? BitConverter.ToInt32(buf, off) : 0;

    private static void WriteU32(byte[] buf, int off, uint value)
        => BitConverter.TryWriteBytes(buf.AsSpan(off, 4), value);

    private static void WriteI32(byte[] buf, int off, int value)
        => BitConverter.TryWriteBytes(buf.AsSpan(off, 4), value);

    private static void WriteF32(byte[] buf, int off, float value)
        => BitConverter.TryWriteBytes(buf.AsSpan(off, 4), value);

    private static void WriteVec3(byte[] buf, int off, float x, float y, float z)
    {
        WriteF32(buf, off, x);
        WriteF32(buf, off + 4, y);
        WriteF32(buf, off + 8, z);
    }

    private static void WriteI32(Stream s, int value)
        => s.Write(BitConverter.GetBytes(value));

    private static void WriteU32(Stream s, uint value)
        => s.Write(BitConverter.GetBytes(value));

    private static void WriteF32(Stream s, float value)
        => s.Write(BitConverter.GetBytes(value));
}
