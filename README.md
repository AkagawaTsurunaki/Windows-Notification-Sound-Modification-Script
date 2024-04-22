# Windows 系统声音修改脚本

> Windows sound modification script.

## 用法

1. 在 Windows 系统中，右键“一键设置 Windows 提示音.ps1”。
2. 输入提示音文件夹所在的路径，回车。注意：这个文件夹里面应该直接就是以 `.wav` 为后缀的音频文件。
3. 看到 `提示音设置完毕！请按任意键退出脚本。` 字样且没有红色报错文字字样，就证明提示音已经设置成功了。
4. 最后重启计算机后，可以通过“控制面板——更改系统声音”查看已经加载的提示音包。

## 工作原理

此脚本用于将提示音自动注册到注册表中。具体地说，它会过滤出指定文件夹中的以 `.wav` 为后缀的文件，然后按照一定的映射规则将文件名对应的 Windows AppEvent 提示音的注册表项 `HKCU:\AppEvents\Schemes\Apps\.Default` 进行修改。

例如，如果脚本发现了 `电池严重短缺警报.wav` 音频文件，那么就会尝试修改注册表中 `HKCU:\AppEvents\Schemes\Apps\.Default\CriticalBatteryAlarm\$提示音包名` 项，将其设置为该音频文件的绝对路径。其中，`$提示音包名` 是您输入的文件夹的名称。

具体的映射规则表如下：

| 文件名               | 注册表项               |
| -------------------- | ---------------------- |
| 默认响声             | .Default               |
| AppGPFault           | AppGPFault             |
| CCSelect             | CCSelect               |
| ChangeTheme          | ChangeTheme            |
| Close                | Close                  |
| 电池严重短缺警报     | CriticalBatteryAlarm   |
| 设备连接             | DeviceConnect          |
| 设备中断连接         | DeviceDisconnect       |
| 设备未能连接         | DeviceFail             |
| 新传真通知           | FaxBeep                |
| 电池不足警报         | LowBatteryAlarm        |
| 桌面邮件通知         | MailBeep               |
| Maximize             | Maximize               |
| MenuCommand          | MenuCommand            |
| MenuPopup            | MenuPopup              |
| 消息闪屏振动         | MessageNudge           |
| Minimize             | Minimize               |
| 通知                 | Notification.Default   |
| 即时消息通知         | Notification.IM        |
| 新邮件通知           | Notification.Mail      |
| NFP 完成             | Notification.Proximity |
| 日历提醒             | Notification.Reminder  |
| 新短信通知           | Notification.SMS       |
| Open                 | Open                   |
| PrintComplete        | PrintComplete          |
| NFP 连接             | ProximityConnection    |
| RestoreDown          | RestoreDown            |
| RestoreUp            | RestoreUp              |
| ShowBand             | ShowBand               |
| 星号                 | SystemAsterisk         |
| 感叹号               | SystemExclamation      |
| SystemExit           | SystemExit             |
| 关键性停止           | SystemHand             |
| 系统通知             | SystemNotification     |
| SystemQuestion       | SystemQuestion         |
| WindowsLogoff        | WindowsLogoff          |
| WindowsLogon         | WindowsLogon           |
| Windows 用户账户控制 | WindowsUAC             |
| WindowsUnlock        | WindowsUnlock          |

## 问题

### 无法加载文件，因为在此系统上禁止运行脚本

此 Power Shell 脚本将会修改您的计算机中的注册表，因此可能会被拒绝执行。如果出现了“无法加载文件，因为在此系统上禁止运行脚本”字样，请依照以下方法授予权限。

通过管理员权限运行 Power Shell，然后在窗口中输入命令

```powershell
set-ExecutionPolicy RemoteSigned
```

最后选择“是”即可更改策略，从而再次运行脚本即可。

如果您对这些权限存有疑惑或安全隐患等，可以查看源代码。同时关于更多有关的安全策略的信息，请参阅[这里](https:\go.microsoft.com\fwlink\?LinkID=135170)。

### 设置后可以移动提示音文件夹吗？

注册表中的值不会自动随着您移动文件夹而修改，因此如果您出于某些原因移动了提示音所在的文件夹，请：

1. 通过“控制面板——更改系统声音”删除旧的声音方案。
2. 重新运行脚本。
3. 输入新的提示音所在的文件夹。

### 脚本代码乱码

脚本因为包含中文字符，因此请使用 `GBK` 编码打开脚本文件，使用 `UTF-8` 编码打开将会产生乱码。
