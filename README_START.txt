นี่คือเวอร์ชั่นที่ยังไม่ได้รับคุณภาพของเกม Ananta GAY | Horoyoi san — client 4229938

启动：
  1. 安装 Node.js LTS 与 .NET 8 SDK。
  2. 用普通用户运行 START.cmd —— 需要管理员权限时服务端会自己申请。

runtime 保留的能力：
  - 进入世界；
  - 切换角色；
  - 切换角色时保存 / 恢复角色位置；
  - 武器 / 战斗；
  - 安全的 web / traversal 增益；
  - 常规 console / packet / proxy 日志。

FastPatch：
  - 把 development / confidential 签名替换为「นี่คือเวอร์ชั่นที่ยังไม่ได้รับคุณภาพของเกม Ananta GAY | Horoyoi san」；
  - 隐藏版本不匹配提示；
  - 不替换 gameplay Lua。

控制台：
  - bootstrap / build / config 检查写入 logs，不在启动时刷屏；
  - [READY] 之后的 runtime 日志照常显示。

横幅文案来源：
  控制台 [READY] 横幅与客户端 UID 标签**共用同一处配置** ——
  config/private-server.json 的 ui.uidLabel.text。以后改文案只改这一处。

回滚 hosts / certificate：
  Ananta.Proxy\REMOVE_PROXY_HOSTS_AS_ADMIN.ps1
