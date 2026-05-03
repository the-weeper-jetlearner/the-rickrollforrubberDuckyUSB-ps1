# --- 1. CONFIGURATION (Double check these names match exactly below) ---
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$tmpPath = "$env:USERPROFILE\Music\tmp"

# --- 2. PREP ---
if (!(Test-Path $tmpPath)) { New-Item -ItemType Directory -Path $tmpPath -Force }
$mp3File = "$tmpPath\rick.mp3"
$imgFile = "$tmpPath\bsod.png"

# --- 3. DOWNLOAD WITH VISUAL PROGRESS ---
Write-Host "Downloading payloads... Please wait." -ForegroundColor Cyan
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3File -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $imgFile -UseBasicParsing

# --- 4. SAFETY CHECK: Don't start until files exist ---
while (!(Test-Path $imgFile) -or !(Test-Path $mp3File)) { Start-Sleep -Milliseconds 500 }

# --- 5. AUDIO & IMAGE SETUP ---
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3File)

$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
# Load image only AFTER download is confirmed
$form.BackgroundImage = [System.Drawing.Image]::FromFile($imgFile)
$form.BackgroundImageLayout = "Stretch"

# --- 6. EXECUTION ---
$form.Show()
$player.Play()
$ws = New-Object -ComObject WScript.Shell

try {
    while ($true) {
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        $form.Activate()
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero
            $player.Play()
        }
        Start-Sleep -Milliseconds 250
    }
}
finally {
    $player.Stop(); $player.Close(); $form.Close()
    Remove-Item -Recurse -Force $tmpPath
}
