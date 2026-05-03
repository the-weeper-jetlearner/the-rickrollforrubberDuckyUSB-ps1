# URLs - Using the RAW GitHub link for the image
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"

# Setup Temp Folder
$tmp = "$env:TEMP\sys_cache"
if (!(Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force }
$mp3Path = "$tmp\a.mp3"
$pngPath = "$tmp\i.png"

# Download assets
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3Path -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $pngPath -UseBasicParsing

# Load Windows Components
Add-Type -AssemblyName System.Windows.Forms

# AUDIO: Play MP3 in background via native Media Player engine
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = $mp3Path
$player.settings.volume = 100
$player.controls.play()

# IMAGE: Create a dedicated fullscreen window (Bypasses Browsers)
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$img = [System.Drawing.Image]::FromFile($pngPath)
$form.BackgroundImage = $img
$form.BackgroundImageLayout = "Stretch"

# Execute
$form.Show()
$ws = New-Object -ComObject WScript.Shell
$start = Get-Date

# Watchdog Loop (Runs for 5 minutes)
while ((Get-Date) -lt $start.AddMinutes(5)) {
    # Force volume to 100%
    for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
    
    # Keep the image window focused
    $form.Activate()
    
    # Loop audio if it stops
    if ($player.playState -eq 1) { $player.controls.play() }
    
    Start-Sleep -Milliseconds 250
}

# Cleanup
$player.controls.stop(); $form.Close(); $img.Dispose(); Remove-Item -Recurse -Force $tmp
