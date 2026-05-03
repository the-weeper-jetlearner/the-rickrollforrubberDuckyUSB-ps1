# 1. URLS
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$workDir = "$env:USERPROFILE\Music\tmp"

# 2. DOWNLOAD & PREP
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force }
$mp3 = "$workDir\rick.mp3"; $png = "$workDir\bsod.png"
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $png -UseBasicParsing

while (!(Test-Path $png) -or !(Test-Path $mp3)) { Start-Sleep -s 1 }
Unblock-File -Path $mp3; Unblock-File -Path $png

# 3. LOAD ENGINES
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

# 4. SETUP AUDIO
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3)

# 5. SETUP MULTI-SCREEN FORMS WITH KILL SWITCH
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
    
    # --- KILL SWITCH LOGIC (Ctrl+Shift+F4) ---
    $f.KeyPreview = $true
    $f.Add_KeyDown({
        if ($_.Control -and $_.Shift -and $_.KeyCode -eq "F4") {
            $global:running = $false
        }
    })
    
    $f.Show()
    $forms.Add($f)
}

# 6. RUN LOOP
$player.Play()
$ws = New-Object -ComObject WScript.Shell

try {
    while ($global:running) {
        # Force Volume
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        
        # Keep all screens topmost and process window events
        foreach ($f in $forms) { 
            $f.Activate()
            [Windows.Forms.Application]::DoEvents() 
        }
        
        # Loop Audio
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero; $player.Play()
        }
        Start-Sleep -Milliseconds 200
    }
}
finally {
    # Cleanup runs when $global:running becomes false
    foreach ($f in $forms) { $f.Close() }
    $player.Stop(); $player.Close()
    Remove-Item -Recurse -Force $workDir
    Stop-Process -Id $PID # Kill the hidden PowerShell terminal
}
