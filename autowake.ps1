#$shell = New-Object -com "Wscript.Shell"
$shell = New-Object -ComObject Wscript.Shell
$key = "{NUMLOCK}"  # NUMLOCK
#$key = " "  # 空格
#$key = "^"  # CTRL
#$key = "{TAB}"  # TAB

while($True){
    $shell.sendkeys($key)
    $time = Get-Date
    Write-Output "$time Run sendkeys : $key"
    Start-Sleep -Sconds 50
}
