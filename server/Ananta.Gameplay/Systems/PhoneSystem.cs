using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;

namespace AnantaTestGameServer
{
    public static class PhoneSystem
    {
        public static PhoneInfos GetOrCreatePhoneInfos(Connection conn, uint spiritId)
        {
            if (!conn.PhoneData.SpiritPhoneInfos.ContainsKey(spiritId))
            {
                conn.PhoneData.SpiritPhoneInfos[spiritId] = new PhoneInfos
                {
                    ContactList = new List<PhoneContact>(),
                    ContactGroupList = new List<PhoneContactGroup>(),
                    CallRecordList = new List<PhoneContactCallRecord>(),
                    ContactOutgoingCallTimesDict = new Dictionary<string, uint>(),
                };
            }
            return conn.PhoneData.SpiritPhoneInfos[spiritId];
        }

        public static void AddContact(Connection conn, uint spiritId, string remark, string phoneNumber)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            if (info.ContactList.Any(c => c.PhoneNumber == phoneNumber))
                return;
            info.ContactList.Add(new PhoneContact { Remark = remark, PhoneNumber = phoneNumber });
        }

        public static bool RemoveContact(Connection conn, uint spiritId, string phoneNumber)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            int removed = info.ContactList.RemoveAll(c => c.PhoneNumber == phoneNumber);
            foreach (var group in info.ContactGroupList)
                group.PhoneNumberList.RemoveAll(p => p == phoneNumber);
            return removed > 0;
        }

        public static bool EditContact(Connection conn, uint spiritId, string oldPhoneNumber, string newRemark, string newPhoneNumber)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            var contact = info.ContactList.FirstOrDefault(c => c.PhoneNumber == oldPhoneNumber);
            if (contact == null) return false;
            contact.Remark = newRemark;
            contact.PhoneNumber = newPhoneNumber;
            return true;
        }

        public static void AddContactGroup(Connection conn, uint spiritId, string groupName)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            if (info.ContactGroupList.Any(g => g.Name == groupName))
                return;
            info.ContactGroupList.Add(new PhoneContactGroup { Name = groupName, PhoneNumberList = new List<string>() });
        }

        public static bool RemoveContactGroup(Connection conn, uint spiritId, string groupName)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            return info.ContactGroupList.RemoveAll(g => g.Name == groupName) > 0;
        }

        public static bool EditContactGroup(Connection conn, uint spiritId, string oldName, string newName)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            var group = info.ContactGroupList.FirstOrDefault(g => g.Name == oldName);
            if (group == null) return false;
            group.Name = newName;
            return true;
        }

        public static bool AddContactToGroup(Connection conn, uint spiritId, string groupName, string phoneNumber)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            var group = info.ContactGroupList.FirstOrDefault(g => g.Name == groupName);
            if (group == null) return false;
            if (!group.PhoneNumberList.Contains(phoneNumber))
                group.PhoneNumberList.Add(phoneNumber);
            return true;
        }

        public static void AddCallRecord(Connection conn, uint spiritId, string phoneNumber, PhoneContactCallRecord.PhoneContactCallType callType)
        {
            var info = GetOrCreatePhoneInfos(conn, spiritId);
            uint now = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            info.CallRecordList.Add(new PhoneContactCallRecord
            {
                CallTime = now,
                CallType = callType,
                PhoneNumber = phoneNumber,
            });
            if (callType == PhoneContactCallRecord.PhoneContactCallType.Outgoing)
            {
                if (!info.ContactOutgoingCallTimesDict.ContainsKey(phoneNumber))
                    info.ContactOutgoingCallTimesDict[phoneNumber] = 0;
                info.ContactOutgoingCallTimesDict[phoneNumber]++;
            }
        }

        public static void AddAppDownload(Connection conn, uint appId)
        {
            if (!conn.PhoneData.DownLoadAppIds.Contains(appId))
                conn.PhoneData.DownLoadAppIds.Add(appId);
        }

        public static bool HasAppDownloaded(Connection conn, uint appId)
        {
            return conn.PhoneData.DownLoadAppIds.Contains(appId);
        }

        public static void InitDefaultPhoneData(Connection conn)
        {
            conn.PhoneData = new PlayerPhoneInfo
            {
                DownLoadAppIds = new List<uint> { 1, 2, 3 },
                SpiritPhoneInfos = new Dictionary<uint, PhoneInfos>(),
            };

            uint[] spiritIds = { conn.currentSpirit, 15020992 };

            foreach (var sid in spiritIds.Distinct())
            {
                var info = new PhoneInfos
                {
                    ContactList = new List<PhoneContact>(),
                    ContactGroupList = new List<PhoneContactGroup>(),
                    CallRecordList = new List<PhoneContactCallRecord>(),
                    ContactOutgoingCallTimesDict = new Dictionary<string, uint>(),
                };

                info.ContactGroupList.Add(new PhoneContactGroup
                {
                    Name = "常用",
                    PhoneNumberList = new List<string>(),
                });

                info.ContactGroupList.Add(new PhoneContactGroup
                {
                    Name = "服务",
                    PhoneNumberList = new List<string> { "10000", "10001" },
                });

                info.ContactList.Add(new PhoneContact { Remark = "云锋", PhoneNumber = "10001" });
                info.ContactList.Add(new PhoneContact { Remark = "铁山", PhoneNumber = "10002" });
                info.ContactList.Add(new PhoneContact { Remark = "黑金节奏手", PhoneNumber = "10003" });
                info.ContactList.Add(new PhoneContact { Remark = "车辆服务", PhoneNumber = "10004" });
                info.ContactList.Add(new PhoneContact { Remark = "信息中心", PhoneNumber = "10000" });

                uint now = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();
                info.CallRecordList.Add(new PhoneContactCallRecord
                {
                    CallTime = now - 3600,
                    CallType = PhoneContactCallRecord.PhoneContactCallType.Incoming,
                    PhoneNumber = "10001",
                });
                info.CallRecordList.Add(new PhoneContactCallRecord
                {
                    CallTime = now - 7200,
                    CallType = PhoneContactCallRecord.PhoneContactCallType.Outgoing,
                    PhoneNumber = "10002",
                });

                conn.PhoneData.SpiritPhoneInfos[sid] = info;
            }
        }
    }

    public class PhoneSpiritIdArgs : SerializedClass
    {
        public uint spiritId;
        public PhoneSpiritIdArgs() { onlyFields = true; }
    }

    public class PhoneContactArgs : SerializedClass
    {
        public uint spiritId;
        public string phoneNumber;
        public PhoneContactArgs() { onlyFields = true; }
    }

    public class PhoneContactRemarkArgs : SerializedClass
    {
        public uint spiritId;
        public string phoneNumber;
        public string remark;
        public PhoneContactRemarkArgs() { onlyFields = true; }
    }

    public class PhoneEditContactArgs : SerializedClass
    {
        public uint spiritId;
        public string oldPhoneNumber;
        public string newRemark;
        public string newPhoneNumber;
        public PhoneEditContactArgs() { onlyFields = true; }
    }

    public class PhoneGroupArgs : SerializedClass
    {
        public uint spiritId;
        public string groupName;
        public PhoneGroupArgs() { onlyFields = true; }
    }

    public class PhoneEditGroupArgs : SerializedClass
    {
        public uint spiritId;
        public string oldName;
        public string newName;
        public PhoneEditGroupArgs() { onlyFields = true; }
    }

    public class PhoneContactGroupArgs : SerializedClass
    {
        public uint spiritId;
        public string groupName;
        public string phoneNumber;
        public PhoneContactGroupArgs() { onlyFields = true; }
    }

    public class PhoneAppDownloadArgs : SerializedClass
    {
        public uint appId;
        public PhoneAppDownloadArgs() { onlyFields = true; }
    }

    public class PhoneContactOptionActionArgs : SerializedClass
    {
        public uint spiritId;
        public string phoneNumber;
        public uint optionId;
        public PhoneContactOptionActionArgs() { onlyFields = true; }
    }

    public class PhoneUnlockContactOptionsArgs : SerializedClass
    {
        public uint spiritId;
        public string phoneNumber;
        public List<uint> optionIds;
        public PhoneUnlockContactOptionsArgs() { onlyFields = true; }
    }

    public class AddSpiritPhoneInfosArgs : SerializedClass
    {
        public uint spiritId;
        public PhoneInfos phoneInfos;
        public AddSpiritPhoneInfosArgs() { onlyFields = true; }
    }
}
