$ErrorActionPreference = 'Stop'

$intervalSeconds = 300

while ($true) {
   $sampleTime = Get-Date
   $os = Get-CimInstance -ClassName Win32_OperatingSystem
   $processors = Get-CimInstance -ClassName Win32_Processor
   $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType = 3'

   $totalMemoryKB = [double]$os.TotalVisibleMemorySize
   $freeMemoryKB = [double]$os.FreePhysicalMemory
   $usedMemoryKB = $totalMemoryKB - $freeMemoryKB
   $memoryUsedPercent = ($usedMemoryKB / $totalMemoryKB) * 100
   $uptime = $sampleTime - $os.LastBootUpTime
   $cpuUsedPercent = ($processors | Measure-Object -Property LoadPercentage -Average).Average

   $logPath = Join-Path $PSScriptRoot (
       'system_monitor_{0}.log' -f $sampleTime.ToString('yyyyMMdd_HH')
   )

   $report = @(
       "===== $($sampleTime.ToString('yyyy-MM-dd HH:mm:ss')) ====="
       ('Memory: {0:N2} GB used / {1:N2} GB total ({2:N1}%)' -f `
           ($usedMemoryKB / 1MB), ($totalMemoryKB / 1MB), $memoryUsedPercent)
       ('Uptime: {0} days, {1} hours, {2} minutes' -f `
           [math]::Floor($uptime.TotalDays), $uptime.Hours, $uptime.Minutes)
       ('CPU usage: {0:N1}%' -f $cpuUsedPercent)
       'Disk usage:'
   )

   foreach ($disk in $disks) {
       $usedPercent = (($disk.Size - $disk.FreeSpace) / [double]$disk.Size) * 100
       $report += ('  {0} {1:N1}% used ({2:N1} GB free of {3:N1} GB)' -f `
           $disk.DeviceID, $usedPercent, ($disk.FreeSpace / 1GB), ($disk.Size / 1GB))
   }

   Add-Content -Path $logPath -Value ($report -join [Environment]::NewLine) -Encoding UTF8
   Start-Sleep -Seconds $intervalSeconds
}
