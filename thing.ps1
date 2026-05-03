# --- CONFIGURATION ---
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$duration = 300 

# --- PREP ENVIRONMENT ---
$tmp = "$env:TEMP\sys_cache_001"
if (!(Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force }
$mp3Path = "$tmp\v.mp3"; $pngPath = "$tmp\i.png"

# Download silently
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3Path -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $pngPath -UseBasicParsing

# Load Windows Components
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Windows.Forms

# --- AUDIO PLAYER SETUP ---
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3Path)
$player.Volume = 1.0

# WAIT FOR AUDIO TO LOAD (CRITICAL)
# This prevents the "silent" bug
while ($player.NaturalDuration.HasTimeSpan -eq $false) { Start-Sleep -Milliseconds 100 }

# --- IMAGE WINDOW SETUP ---
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$img = [System.Drawing.Image]::FromFile($pngPath)
$form.BackgroundImage = $img
$form.BackgroundImageLayout = "Stretch"

# --- EXECUTION ---
$form.Show()
$player.Play() # Starts audio immediately now that it's loaded
$ws = New-Object -ComObject WScript.Shell
$start = Get-Date

while ((Get-Date) -lt $start.AddSeconds($duration)) {
    # Bruteforce volume
    for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
    
    # Keep focused and topmost
    $form.Activate()
    
    # Infinite audio loop
    if ($player.Position -ge $player.NaturalDuration.TimeSpan) { 
        $player.Position = [TimeSpan]::Zero; $player.Play() 
    }
    
    Start-Sleep -Milliseconds 200
}

# --- CLEANUP ---
$player.Stop(); $player.Close(); $form.Close(); $img.Dispose(); Remove-Item -Recurse -Force $tmp
