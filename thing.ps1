# URLs
$youtube = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
$bsod    = 'https://upload.wikimedia.org/wikipedia/commons/5/56/Bsodwindows10.png'

# Timer: The prank will automatically stop and clean up after 5 minutes
$endTime = (Get-Date).AddMinutes(5)

# Add Win32 API for always-on-top (HWND_TOPMOST)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr h, IntPtr i, int x, int y, int c, int d, uint f);
    public static readonly IntPtr T = new IntPtr(-1);
}
"@

# Helper to launch Chrome with Autoplay allowed
function Start-Prank {
    Start-Process chrome "--new-window --start-fullscreen --autoplay-policy=no-user-gesture-required $youtube"
    Start-Process chrome "--new-window --start-fullscreen $bsod"
}

# Initial Launch
Start-Prank

# Main Watchdog Loop
while ((Get-Date) -lt $endTime) {
    
    # 1. Force Max Volume
    (New-Object -ComObject WScript.Shell).SendKeys([char]175)

    # 2. Watchdog: If they close Chrome, re-open it immediately
    if (-not (Get-Process chrome -ErrorAction SilentlyContinue)) {
        Start-Prank
        Start-Sleep -Seconds 2
    }

    # 3. Find the BSOD window and pin it to the very top
    $chromeProcs = Get-Process chrome -ErrorAction SilentlyContinue
    foreach ($p in $chromeProcs) {
        if ($p.MainWindowTitle -match "Bsod") {
            [Win]::SetWindowPos($p.MainWindowHandle, [Win]::T, 0, 0, 0, 0, 0x0001 + 0x0002)
        }
    }

    Start-Sleep -Seconds 1
}

# Cleanup: Close Chrome when the 5 minutes are up
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
