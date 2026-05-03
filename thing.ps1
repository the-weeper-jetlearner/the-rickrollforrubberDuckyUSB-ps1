# thing.ps1
$youtube = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
$bsod    = 'https://upload.wikimedia.org/wikipedia/commons/5/56/Bsodwindows10.png'
$endTime = (Get-Date).AddMinutes(5)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr h, IntPtr i, int x, int y, int c, int d, uint f);
    public static readonly IntPtr T = new IntPtr(-1);
}
"@

# Bypasses the "User Gesture" and "Visibility" requirement for autoplay
function Start-Prank {
    Start-Process chrome "--new-window --start-fullscreen --autoplay-policy=no-user-gesture-required --no-first-run $youtube"
    Start-Process chrome "--new-window --start-fullscreen --no-first-run $bsod"
}

Start-Prank
$wshell = New-Object -ComObject WScript.Shell

while ((Get-Date) -lt $endTime) {
    # FAST VOLUME BURST
    for ($i=0; $i -lt 15; $i++) { $wshell.SendKeys([char]175) }

    # Check for visible window titles
    $chrome = Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -ne "" }
    $hasYT = $chrome | Where-Object { $_.MainWindowTitle -match "YouTube" }
    $hasBS = $chrome | Where-Object { $_.MainWindowTitle -match "Bsod" }

    # Respawn if closed
    if (-not $hasYT -or -not $hasBS) {
        Start-Prank
        Start-Sleep -Seconds 2
    }

    # Pin BSOD to Top
    foreach ($p in $chrome) {
        if ($p.MainWindowTitle -match "Bsod") {
            [Win]::SetWindowPos($p.MainWindowHandle, [Win]::T, 0, 0, 0, 0, 0x0001 + 0x0002)
        }
    }
    
    Start-Sleep -Milliseconds 50
}

# Cleanup
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
