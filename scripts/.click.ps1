param(
    [int]$X,
    [int]$Y,
    [string]$Title = "Project Tracker Desktop"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Clicker {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
    public struct RECT { public int Left, Top, Right, Bottom; }

    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtra);
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const uint MOUSEEVENTF_ABSOLUTE = 0x8000;

    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
}
"@

$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*$Title*" } | Select-Object -First 1
if (-not $proc) { Write-Output "WINDOW_NOT_FOUND"; exit 1 }

$null = [Clicker]::SetForegroundWindow($proc.MainWindowHandle)
Start-Sleep -Milliseconds 300

$rect = New-Object Clicker+RECT
$null = [Clicker]::GetWindowRect($proc.MainWindowHandle, [ref]$rect)

$screenX = $rect.Left + $X
$screenY = $rect.Top + $Y

# Normalize to absolute coords (0..65535)
$vs = [Clicker]::GetSystemMetrics(0)  # SM_CXSCREEN
$hs = [Clicker]::GetSystemMetrics(1)  # SM_CYSCREEN
$ax = [int](($screenX * 65535) / ($vs - 1))
$ay = [int](($screenY * 65535) / ($hs - 1))

[Clicker]::mouse_event([Clicker]::MOUSEEVENTF_MOVE -bor [Clicker]::MOUSEEVENTF_ABSOLUTE, $ax, $ay, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 100
[Clicker]::mouse_event([Clicker]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 60
[Clicker]::mouse_event([Clicker]::MOUSEEVENTF_LEFTUP, 0, 0, 0, [UIntPtr]::Zero)

Write-Output "CLICKED $screenX,$screenY"
