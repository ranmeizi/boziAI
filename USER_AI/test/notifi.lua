os.execute([[
  powershell -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $notify = New-Object System.Windows.Forms.NotifyIcon
  $notify.Icon = [System.Drawing.SystemIcons]::Information
  $notify.Visible = $true
  $notify.ShowBalloonTip(3000, '提醒', '这是备用通知', [System.Windows.Forms.ToolTipIcon]::Info)"
]])