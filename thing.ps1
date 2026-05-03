# 1. URLS (MUST BE AT THE TOP)
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$workDir = "$env:USERPROFILE\Music\tmp"

# 2. CREATE DIRECTORY
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force }
$mp3 = "$workDir\rick.mp3"; $png = "$workDir\bsod.png"

# 3. DOWNLOAD & UNBLOCK
Write-Host "Fetching assets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $png -UseBasicParsing

# Wait until files are actually on the disk
while (!(Test-Path $png) -or !(Test-Path $mp3)) { Start-Sleep -s 1 }

# Unblock files so Windows allows them to play
Unblock-File -Path $mp3; Unblock-File -Path $png

# 4. LOAD ENGINES
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

# 5. SETUP AUDIO & IMAGE
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3)

$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackgroundImage = [System.Drawing.Image]::FromFile($png)
$form.BackgroundImageLayout = "Stretch"

# 6. RUN
$form.Show()
$player.Play()
$ws = New-Object -ComObject WScript.Shell

try {
    while ($true) {
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        $form.Activate()
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero; $player.Play()
        }
        Start-Sleep -Milliseconds 250
    }
}
finally {
    $player.Stop(); $player.Close(); $form.Close()
    Remove-Item -Recurse -Force $workDir
}
