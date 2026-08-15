using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsRequestCreateRoleEx : SerializedClass
    {
        public CreateRoleInitInfo RoleInfo=new();
        public ClientDeviceInfo deviceInfo = new();
        public class ClientDeviceInfo : SerializedClass
        {
            // Fields
            public string DeviceModel; // 0x10
    
            public string OsName; // 0x18
       
            public string OsVersion; // 0x20
  
            public string Udid; // 0x28

            public string AppVersion; // 0x30
            public int DeviceHeight; // 0x38
            public int DeviceWidth; // 0x3C

            public string Network; // 0x40

            public string Ipv6; // 0x48
    
            public string AppChannel; // 0x50
       
            public string Transid; // 0x58
   
            public string UnisdkDeviceId; // 0x60
            public bool IsEmulator; // 0x68
            public bool IsRoot; // 0x69

            public string Imei; // 0x70

            public string Location; // 0x78
  
            public string CountryCode; // 0x80
 
            public string LocalIp; // 0x88

            public string OldAccountId; // 0x90
 
            public string MacAddr; // 0x98
      
            public string GpuName; // 0xA0
      
            public string CpuName; // 0xA8

            public string HardDriveSn; // 0xB0
            public long TotalMemory; // 0xB8
            public int ResolutionHeight; // 0xC0
            public int ResolutionWidth; // 0xC4
            public int FullScreen; // 0xC8
            public int DeviceLevel; // 0xCC
            public int DisplayLevel; // 0xD0

            public string Joystick;
            public int characterQualityLevel;
            public int vehicleQualityLevel; 
        }
        public enum SexType // TypeDefIndex: 14812
        {
            Unknown = 0,
            Male = 1,
            Female = 2
        }
        public class CreateRoleInitInfo : SerializedClass
        {
            // Fields
            public SexType Sex=SexType.Male; 
            public string Name="SuikoAkari"; 
            public byte[] Config; 

        }
    }
}
