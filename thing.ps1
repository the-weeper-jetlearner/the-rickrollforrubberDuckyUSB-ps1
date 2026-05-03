# thing.ps1
$youtube = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
$bsod    = 'https://upload.wikimedia.org/wikipedia/commons/5/56/Bsodwindows10.png'
$endTime = (Get-Date).AddMinutes(5)

# Win32 API to keep BSOD on top
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr h, IntPtr i, int x, int y, int c, int d, uint f);
    public static readonly IntPtr T = new IntPtr(-1);
}
"@

# Helper to force-launch Chrome with Autoplay allowed
function Start-Prank {
    # --autoplay-policy=no-user-gesture-required forces sound immediately
    Start-Process chrome "--new-window --start-fullscreen --autoplay-policy=no-user-gesture-required $youtube"
    Start-Process chrome "--new-window --start-fullscreen $bsod"
}

Start-Prank

# Watchdog Loop: Runs independently of Chrome
while ((Get-Date) -lt $endTime) {
    # 1. Constant Volume Lock
    (New-Object -ComObject WScript.Shell).SendKeys([char]175)

    # 2. Re-open if they close the whole app or just the tabs
    $chrome = Get-Process chrome -ErrorAction SilentlyContinue
    $hasYT = $chrome | Where-Object { $_.MainWindowTitle -match "YouTube" }
    $hasBS = $chrome | Where-Object { $_.MainWindowTitle -match "Bsod" }

    if (-not $hasYT -or -not $hasBS) {
        Start-Prank
        Start-Sleep -Seconds 2
    }

    # 3. Force BSOD to stay on top
    $chrome | ForEach-Object {
        if ($_.MainWindowTitle -match "Bsod") {
            [Win]::SetWindowPos($_.MainWindowHandle, [Win]::T, 0, 0, 0, 0, 0x0001 + 0x0002)
        }
    }
    Start-Sleep -Seconds 1
}

# Auto-cleanup after 5 minutes
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
