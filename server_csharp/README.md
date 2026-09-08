# Ananta Private Server (.NET 9 C#)

เซิร์ฟเวอร์จำลองภาษา **C# (.NET 9)** พัฒนาให้ตรงกับโครงสร้างภายในของเอนจิน Unity ของเกม Project Mugen / Ananta

---

## 🚀 วิธีเปิดเซิร์ฟเวอร์
1. ดับเบิลคลิกที่:
   ```
   start_server.bat
   ```
   *(หรือเปิด Terminal แล้วพิมพ์ `dotnet run`)*

2. ตรวจสอบสถานะผ่านเบราว์เซอร์ที่:
   👉 **[http://127.0.0.1:8080](http://127.0.0.1:8080)**

---

## 🛠️ การคอมไพล์เป็นไฟล์ .exe สำหรับแจกจ่าย (Standalone Release)
หากต้องการคอมไพล์ออกมาเป็นไฟล์ `.exe` เดี่ยวๆ ที่เครื่องอื่นเปิดได้โดยไม่ต้องติดตั้ง .NET SDK:
```powershell
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```
ไฟล์ `.exe` จะถูกสร้างในโฟลเดอร์ `bin\Release\net9.0\win-x64\publish\`
