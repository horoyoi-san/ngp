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
            public string DeviceModel;
    
            public string OsName;
       
            public string OsVersion;
  
            public string Udid;

            public string AppVersion;
            public int DeviceHeight;
            public int DeviceWidth;

            public string Network;

            public string Ipv6;
    
            public string AppChannel;
       
            public string Transid;
   
            public string UnisdkDeviceId;
            public bool IsEmulator;
            public bool IsRoot;

            public string Imei;

            public string Location;
  
            public string CountryCode;
 
            public string LocalIp;

            public string OldAccountId;
 
            public string MacAddr;
      
            public string GpuName;
      
            public string CpuName;

            public string HardDriveSn;
            public long TotalMemory;
            public int ResolutionHeight;
            public int ResolutionWidth;
            public int FullScreen;
            public int DeviceLevel;
            public int DisplayLevel;

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
