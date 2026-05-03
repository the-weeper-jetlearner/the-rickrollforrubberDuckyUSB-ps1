# --- 1. CONFIGURATION ---
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://github.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/blob/main/bsod.png"
$duration = 300 # Duration in seconds (5 minutes)

# --- 2. DOWNLOAD ASSETS ---
$tmp = "$env:TEMP\sys_data"
if (!(Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force }
$mp3Path = "$tmp\v.mp3"
$pngPath = "$tmp\i.png"
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3Path -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $pngPath -UseBasicParsing

# --- 3. THE "NO-TAB" AUDIO PLAYER ---
# Uses the native Windows Media Player COM object (runs in background)
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = $mp3Path
$player.settings.volume = 100
$player.controls.play()

# --- 4. THE FULLSCREEN BSOD ---
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$img = [System.Drawing.Image]::FromFile($pngPath)
$form.BackgroundImage = $img
$form.BackgroundImageLayout = "Stretch"
$form.Show()

# --- 5. WATCHDOG LOOP ---
$ws = New-Object -ComObject WScript.Shell
$start = Get-Date
while ((Get-Date) -lt $start.AddSeconds($duration)) {
    # Force volume up in a loop
    for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
    
    # Keep the image window on top of everything
    $form.Activate()
    
    # Loop audio if it ends
    if ($player.playState -eq 1) { $player.controls.play() }
    
    Start-Sleep -Milliseconds 250
}

# --- 6. CLEANUP ---
$player.controls.stop()
$form.Close()
$img.Dispose()
Remove-Item -Recurse -Force $tmp
