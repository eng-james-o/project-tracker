param(
    [string]$Out = "C:\Users\PC\AppData\Local\Temp\pt_shot.png",
    [string]$Title = "Project Tracker Desktop",
    [int]$WaitMs = 8000
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$deadline = (Get-Date).AddMilliseconds($WaitMs)
$proc = $null
while ((Get-Date) -lt $deadline) {
    $proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*$Title*" } | Select-Object -First 1
    if ($proc) { break }
    Start-Sleep -Milliseconds 250
}

if (-not $proc) {
    Write-Output "WINDOW_NOT_FOUND"
    exit 1
}

# Bring window to front
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

$null = [Win]::ShowWindow($proc.MainWindowHandle, 9)  # SW_RESTORE
$null = [Win]::SetForegroundWindow($proc.MainWindowHandle)
Start-Sleep -Milliseconds 700

$rect = New-Object Win+RECT
$null = [Win]::GetWindowRect($proc.MainWindowHandle, [ref]$rect)
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmp.Size)
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Output "SAVED $Out ${w}x${h}"
