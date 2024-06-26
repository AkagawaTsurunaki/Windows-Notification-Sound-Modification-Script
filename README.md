# Windows 提示音修改脚本

> 仓库： [AkagawaTsurunaki/Windows-Notification-Sound-Modification-Script (github.com)](https://github.com/AkagawaTsurunaki/Windows-Notification-Sound-Modification-Script)
> 
> Github：[AkagawaTsurunaki](https://github.com/AkagawaTsurunaki)
>
> Bilibili：[赤川鶴鳴_Channel](https://space.bilibili.com/1076299680)

本 PowerShell 脚本可以按照一定的映射规则将一个文件夹内的提示音文件自动注册至 Windows 系统的声音方案中。

## 脚本使用方法

如果您具有一定的计算机基础，了解了命令行等知识，可以尝试使用此脚本快速设置提示音。

### 解压并移动提示音包

这里所说的提示音包其实就是存放着以 `.wav` 为后缀的音频文件的文件夹。例如您的一个名为 TendouArisu 语音包，里面装着若干个提示音。那么请将这个语音包复制（或剪切）到 `C:\Windows\Media\` 下（推荐），最后的目录结构如下图所示

```
- C
  └─Windows
    └─Media
      └─TendouArisu
        ├─NFP 连接.wav
        ├─NFP 完成.wav
        └─...
```

如果您下载的文件是 `.zip` 结尾的，那么请先解压。

### 检查您的 Windows Powershell

为了确保您能运行此脚本，先在搜索栏输入“Windows PowerShell”，如果您可以找到 Windows PowerShell 这个应用程序，说明您的系统已经安装了 Windows PowerShell。

自 Windows 7 开始，Windows PowerShell 已经内置到您的计算机中。请注意，**Powershell 和 Windows Powershell 并不是一个东西**，我们需要的是 Windows PowerShell。

如果您的系统没有安装 Windows PowerShell，请自行下载安装。

### 更改 Windows  PowerShell 执行策略

在搜索栏输入“Windows PowerShell”，以**管理员权限**运行 Windows PowerShell，在弹出的窗口内输入命令

```powershell
set-ExecutionPolicy RemoteSigned
```

按下 `Enter` 键后，会显示如下字样

```
执行策略更改
执行策略可帮助你防止执行不信任的脚本。更改执行策略可能会产生安全风险...
是否要更改执行策略?
[Y] 是(Y) [A] 全是(A) [N] 否(N) [L] 全否(L) [S]暂停(S) [?]帮助(默认值为“N”):
```

此时，请输入“A”，按下 `Enter` 键后可以关闭此窗口。

如果没有显示此字样，可能是因为您的 PowerShell 并没有自动将结果返回，但实际上已经设置完成。

**注意：**

1. 必须以**管理员权限**运行，否则无法修改 Windows PowerShell 的执行策略。
2. **必须使用 Windows PowerShell** 而不是 PowerShell。

### 运行脚本

在 Windows 系统中，右键“Windows-Notification-Sound-Modification-Script.ps1”，选择“**使用 PowerShell 运行**”。

这会弹出一个窗口，显示如下字样

```
Please enter the path of the folder that stores tones:
```

这是在提示您输入提示音所在的文件夹路径。这个文件夹里面应该直接就是以 `.wav` 为后缀的音频文件，且文件夹的名称**必须是英文**。

**输入提示音文件夹所在的路径**，按下 `Enter` 键。看到类似 `Notification sound package $tonePackageName has been registered in your system successfully` 字样且没有红色报错文字字样，就证明提示音已经设置成功了。

随后**重启计算机**使系统提示音刷新，不重启会出现提示音无法播放的问题。

最后，可以通过“控制面板——更改系统声音——声音方案”**选择已经加载的提示音包**，并点击“应用”使其生效。

## 问题

### 无法加载文件，因为在此系统上禁止运行脚本

此 PowerShell 脚本将会修改您的计算机中的注册表，因此可能会被拒绝执行。如果出现了“无法加载文件，因为在此系统上禁止运行脚本”字样，请依照以下方法授予权限。

通过管理员权限运行 Windows PowerShell，然后在窗口中输入命令

```powershell
set-ExecutionPolicy RemoteSigned
```

最后输入“A”即可更改策略，从而再次运行脚本即可。

如果您对这些权限存有疑惑或安全隐患等，可以查看源代码。同时关于更多有关的安全策略的信息，请参阅[这里](https:\go.microsoft.com\fwlink\?LinkID=135170)。

### 运行脚本时出现错误

```
Line |
11   |            throw [System.I0.FileNotFoundException] "$eventLabelsJsonFile ...
	 |            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	 | .\EventLabels.json not found.
```

您必须在脚本所在的文件夹启动脚本，在其他路径打开脚本会导致相对路径出错。请找到 `Windows-Notification-Sound-Modification-Script.ps1` 并右键“**使用 PowerShell 运行**”。

### 设置后可以移动提示音文件夹吗？

注册表中的值不会自动随着您移动文件夹而修改，因此如果您出于某些原因移动了提示音所在的文件夹，请：

1. 通过“控制面板——更改系统声音”删除旧的声音方案。
2. 重新运行脚本。
3. 输入新的提示音所在的文件夹。

### 为什么要将提示音放在 C 盘？

理论上您可以将提示音包放置在您的电脑的任何位置上。但是，由于 Windows 特殊的提示音加载机制，导致存放在**非系统盘的提示音在读取有一定几率失效**。所以推荐放在 `C:\Windows\Media` 目录下。

### 右键打开脚本弹出的是记事本

这可能是由于您没有解压，您必须先把压缩包解压到某个位置才能使用脚本。

## 工作原理

此脚本用于将提示音自动注册到注册表中。

它会过滤出指定文件夹中的以 `.wav` 为后缀的文件，然后按照一定的映射规则将文件名对应的 Windows AppEvent 提示音的注册表项 `HKCU:\AppEvents\Schemes\Apps\$App\$ID\$PackageName` 下的子项进行修改。

具体地说，在 `EventLabels.json` 存储了一种模式，它指导着 PowerShell 脚本如何将对应的注册表项设置为提示音的绝对路径。因此，**除非您知道您在做什么，否则不要更改 `EventLabels.json` 文件**。以下是 `EventLabels.json` 文件的树状结构：

```
└─  (array)
   └─  (object)
      ├─ "App" (string)
      └─ "EventLabels" (array)
         └─  (object)
            ├─ "ID" (string)
            ├─ "EN" (string)
            └─ "ZH" (string)
```

例如，如果 PowerShell 脚本发现了 `电池严重短缺警报.wav` 音频文件，提示音所在的文件夹名（提示音包名）为 `AkagawaTsurunaki`，那么它将会：

1. 找到 `电池严重短缺警报` 对应的 `App` 字段值为 `.Default`。
2. 找到 `电池严重短缺警报` 对应的 `ID` 字段值为 `CriticalBatteryAlarm`。
3. 尝试修改注册表中 `HKCU:\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\Akaga0` 项。注意，注册表只会存储提示音包名的前5个字符和1个自增的数字。
4. 注册表 `HKCU:\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\Akaga0` 项的 `(Default)` 键值将被设置为 `电池严重短缺警报.wav` 的绝对路径。

PowerShell 会对每一个提示音音频文件（以 `.wav` 为后缀）进行遍历，并尝试设置。如果提示音文件名不在 `EventLabels.json` 中存在映射，那么将不会被设置。

具体的映射规则表请见下表：

| App      | ID                           | EN                            | ZH                   |
| -------- | ---------------------------- | ----------------------------- | -------------------- |
| .Default | .Default                     | Default Beep                  | 默认响声             |
| .Default | AppGPFault                   | Program Error                 | 程序出错             |
| .Default | CCSelect                     | Select                        | 选择                 |
| .Default | ChangeTheme                  | Change Theme                  | Windows 更改主题     |
| .Default | Close                        | Close Program                 | 关闭程序             |
| .Default | CriticalBatteryAlarm         | Critical Battery Alarm        | 电池严重短缺警报     |
| .Default | DeviceConnect                | Device Connect                | 设备连接             |
| .Default | DeviceDisconnect             | Device Disconnect             | 设备中断连接         |
| .Default | DeviceFail                   | Device Failed to Connect      | 设备未能连接         |
| .Default | FaxBeep                      | New Fax Notification          | 新传真通知           |
| .Default | LowBatteryAlarm              | Low Battery Alarm             | 电池不足警报         |
| .Default | MailBeep                     | Desktop Mail Notification     | 桌面邮件通知         |
| .Default | Maximize                     | Maximize                      | 最大化               |
| .Default | MenuCommand                  | Menu Command                  | 菜单命令             |
| .Default | MenuPopup                    | Menu Pop-up                   | 弹出菜单             |
| .Default | MessageNudge                 | Message Nudge                 | 消息闪屏振动         |
| .Default | Minimize                     | Minimize                      | 最小化               |
| .Default | Notification.Default         | Notification                  | 通知                 |
| .Default | Notification.IM              | Instant Message Notification  | 即时消息通知         |
| .Default | Notification.Looping.Alarm   | Alarm 1                       | 警报 1               |
| .Default | Notification.Looping.Alarm10 | Alarm 10                      | 警报 10              |
| .Default | Notification.Looping.Alarm2  | Alarm 2                       | 警报 2               |
| .Default | Notification.Looping.Alarm3  | Alarm 3                       | 警报 3               |
| .Default | Notification.Looping.Alarm4  | Alarm 4                       | 警报 4               |
| .Default | Notification.Looping.Alarm5  | Alarm 5                       | 警报 5               |
| .Default | Notification.Looping.Alarm6  | Alarm 6                       | 警报 6               |
| .Default | Notification.Looping.Alarm7  | Alarm 7                       | 警报 7               |
| .Default | Notification.Looping.Alarm8  | Alarm 8                       | 警报 8               |
| .Default | Notification.Looping.Alarm9  | Alarm 9                       | 警报 9               |
| .Default | Notification.Looping.Call    | Incoming Call Notification 1  | 来电通知 1           |
| .Default | Notification.Looping.Call10  | Incoming Call Notification 10 | 来电通知 10          |
| .Default | Notification.Looping.Call2   | Incoming Call Notification 2  | 来电通知 2           |
| .Default | Notification.Looping.Call3   | Incoming Call Notification 3  | 来电通知 3           |
| .Default | Notification.Looping.Call4   | Incoming Call Notification 4  | 来电通知 4           |
| .Default | Notification.Looping.Call5   | Incoming Call Notification 5  | 来电通知 5           |
| .Default | Notification.Looping.Call6   | Incoming Call Notification 6  | 来电通知 6           |
| .Default | Notification.Looping.Call7   | Incoming Call Notification 7  | 来电通知 7           |
| .Default | Notification.Looping.Call8   | Incoming Call Notification 8  | 来电通知 8           |
| .Default | Notification.Looping.Call9   | Incoming Call Notification 9  | 来电通知 9           |
| .Default | Notification.Mail            | New Mail Notification         | 新邮件通知           |
| .Default | Notification.Proximity       | NFP Completion                | NFP 完成             |
| .Default | Notification.Reminder        | Calendar Reminder             | 日历提醒             |
| .Default | Notification.SMS             | New Text Message Notification | 新短信通知           |
| .Default | Open                         | Open Program                  | 打开程序             |
| .Default | PrintComplete                | Print Complete                | 打印结束             |
| .Default | ProximityConnection          | NFP Connection                | NFP 连接             |
| .Default | RestoreDown                  | Restore Down                  | 向下还原             |
| .Default | RestoreUp                    | Restore Up                    | 向上还原             |
| .Default | ShowBand                     | Show Toolbar Band             | 显示工具栏区         |
| .Default | SystemAsterisk               | Asterisk                      | 星号                 |
| .Default | SystemExclamation            | Exclamation                   | 感叹号               |
| .Default | SystemExit                   | Exit Windows                  | Windows 退出         |
| .Default | SystemHand                   | Critical Stop                 | 关键性停止           |
| .Default | SystemNotification           | System Notification           | 系统通知             |
| .Default | SystemQuestion               | Question                      | 问题                 |
| .Default | WindowsLogoff                | Windows Logoff                | Windows 注销         |
| .Default | WindowsLogon                 | Windows Logon                 | Windows 登录         |
| .Default | WindowsUAC                   | Windows User Account Control  | Windows 用户账户控制 |
| .Default | WindowsUnlock                | Windows Unlock                | Windows 解锁         |
| Explorer | ActivatingDocument           | Complete Navigation           | 完成导航             |
| Explorer | BlockedPopup                 | Blocked Pop-up Window         | 阻止的弹出窗口       |
| Explorer | EmptyRecycleBin              | Empty Recycle Bin             | 清空回收站           |
| Explorer | FeedDiscovered               | Feed Discovered               | 已发现源             |
| Explorer | MoveMenuItem                 | Move Menu Item                | 移动菜单项           |
| Explorer | Navigating                   | Start Navigation              | 启动导航             |
| Explorer | SecurityBand                 | Information Bar               | 通知栏               |
| sapisvr  | DisNumbersSound              | Disambiguation Numbers        | 消除歧义号码         |
| sapisvr  | HubOffSound                  | Off                           | 关闭                 |
| sapisvr  | HubOnSound                   | On                            | 启用                 |
| sapisvr  | HubSleepSound                | Sleep                         | 睡眠                 |
| sapisvr  | MisrecoSound                 | Misrecognition                | 误识别               |
| sapisvr  | PanelSound                   | Disambiguation Panel          | 消除歧义面板         |
