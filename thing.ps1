# URLs
$youtube = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
$bsod    = 'https://upload.wikimedia.org/wikipedia/commons/5/56/Bsodwindows10.png'

# Launch YouTube fullscreen
$yt = Start-Process chrome "--new-window --start-fullscreen $youtube" -PassThru

# Launch BSOD fullscreen
$bs = Start-Process chrome "--new-window --start-fullscreen $bsod" -PassThru

# Allow Chrome to create windows
Start-Sleep -Seconds 2

# Add Win32 API for always-on-top
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd, IntPtr hWndInsertAfter,
        int X, int Y, int cx, int cy, uint uFlags);

    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    public const uint SWP_NOMOVE = 0x0002;
    public const uint SWP_NOSIZE = 0x0001;
}
"@

# Main loop
while (-not $yt.HasExited) {

    # Keep BSOD window always on top
    if ($bs.MainWindowHandle -ne 0) {
        [Win]::SetWindowPos(
            $bs.MainWindowHandle,
            [Win]::HWND_TOPMOST,
            0, 0, 0, 0,
            [Win]::SWP_NOMOVE + [Win]::SWP_NOSIZE
        )
    }

    Start-Sleep -Seconds 1
}

# When YouTube closes, script ends automatically
