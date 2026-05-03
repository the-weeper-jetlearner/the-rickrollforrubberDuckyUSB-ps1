# --- CONFIGURATION ---
$url = "https://qoret.com/dl/uploads/2019/07/Rick_Astley_-_Never_Gonna_Give_You_Up_Qoret.com.mp3"
$png = "https://raw.githubusercontent.com/the-weeper-jetlearner/the-rickrollforrubberDuckyUSB-ps1/refs/heads/main/bsod.png"
$tmp = "$env:TEMP\prank_data"

# 1. Setup local folder
if (!(Test-Path $tmp)) { New-Item -ItemType Directory -Path $tmp -Force }
$mp3 = "$tmp\v.mp3"
$img = "$tmp\i.png"

# 2. Download silently
Invoke-WebRequest -Uri $mp3Url -OutFile $mp3 -UseBasicParsing
Invoke-WebRequest -Uri $pngUrl -OutFile $img -UseBasicParsing

# 3. Open Fullscreen Image (Standard Form)
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.BackgroundImage = [System.Drawing.Image]::FromFile($img)
$form.BackgroundImageLayout = "Stretch"
$form.Show()

# 4. Play Audio via native wmplayer (Bypasses COM issues)
# This process is linked to the PowerShell window
$playerProcess = Start-Process wmplayer.exe -ArgumentList "`"$mp3`"" -WindowStyle Hidden -PassThru

# 5. WATCHDOG LOOP
$ws = New-Object -ComObject WScript.Shell
try {
    while ($true) {
        # Force volume up
        for ($i=0; $i -lt 5; $i++) { $ws.SendKeys([char]175) }
        
        # Keep BSOD on top
        $form.Activate()
        
        # If wmplayer crashes or stops, restart it
        if ($playerProcess.HasExited) {
            $playerProcess = Start-Process wmplayer.exe -ArgumentList "`"$mp3`"" -WindowStyle Hidden -PassThru
        }
        
        Start-Sleep -Seconds 1
    }
}
finally {
    # If terminal is closed or script stops, cleanup
    if ($playerProcess) { Stop-Process -Id $playerProcess.Id -Force -ErrorAction SilentlyContinue }
    $form.Close()
    Remove-Item -Recurse -Force $tmp
}
