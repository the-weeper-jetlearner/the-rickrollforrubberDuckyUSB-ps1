# --- CONFIGURATION ---
$url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$png = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$tmpPath = "$env:USERPROFILE\Music\tmp"

# 1. Create folder and download assets
if (!(Test-Path $tmpPath)) { New-Item -ItemType Directory -Path $tmpPath -Force }
$mp3File = "$tmpPath\rick.mp3"
$imgFile = "$tmpPath\bsod.png"

Write-Host "Downloading assets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3File -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $imgFile -UseBasicParsing

# 2. Setup Modern Audio Engine (Terminal-Linked)
Add-Type -AssemblyName PresentationCore
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3File)

# 3. Setup Fullscreen BSOD Image
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackgroundImage = [System.Drawing.Image]::FromFile($imgFile)
$form.BackgroundImageLayout = "Stretch"

# 4. Start Prank
$form.Show()
$player.Play()
$ws = New-Object -ComObject WScript.Shell

Write-Host "PRANK ACTIVE. Closing this window stops the music and image." -ForegroundColor Yellow

# Watchdog Loop
try {
    while ($true) {
        # Force System Volume to Max
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        
        # Keep BSOD on top
        $form.Activate()
        
        # Infinite Audio Loop
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero
            $player.Play()
        }
        
        Start-Sleep -Milliseconds 250
    }
}
finally {
    # This block triggers if the terminal is closed or script is stopped
    $player.Stop()
    $player.Close()
    $form.Close()
    Remove-Item -Recurse -Force $tmpPath
}
