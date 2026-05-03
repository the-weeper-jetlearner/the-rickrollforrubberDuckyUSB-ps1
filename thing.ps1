# --- CONFIGURATION ---
$url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$png = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$tmp = "$env:USERPROFILE\Music\tmp"

# 1. Create folder and download
if (!(Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force }
$mp3 = "$tmp\rick.mp3"
$img = "$tmp\bsod.png"

Write-Host "Downloading payloads..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $png -OutFile $img -UseBasicParsing

# 2. Setup Audio (Linked to this session)
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = $mp3
$player.settings.volume = 100

# 3. Setup Fullscreen Image
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackgroundImage = [System.Drawing.Image]::FromFile($img)
$form.BackgroundImageLayout = "Stretch"

# 4. START PRANK
$form.Show()
$player.controls.play()
$ws = New-Object -ComObject WScript.Shell

Write-Host "PRANK ACTIVE. Close this window to stop." -ForegroundColor Yellow

# Watchdog Loop
try {
    while ($true) {
        # Force Volume
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        
        # Keep Image on top
        $form.Activate()
        
        # Loop Audio
        if ($player.playState -eq 1) { $player.controls.play() }
        
        Start-Sleep -Milliseconds 250
    }
}
finally {
    # This block runs when the window is closed or script is stopped
    $player.controls.stop()
    $form.Close()
    Remove-Item -Recurse -Force $tmp
}
