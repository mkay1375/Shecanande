@echo off
setlocal enabledelayedexpansion

:: Get an interface with internet connection
for /F "tokens=* USEBACKQ" %%F IN (`wmic nic where "NetConnectionStatus=2 and AdapterTypeId=0" get  NetConnectionID /format:list ^| findstr "NetConnectionID"`) do (
  set interfaceName=%%F
)

if "%interfaceName%"=="" (
  echo No interface with active internet connection found^!
  pause
  exit
)

:: Remove 'NetConnectionID='
set interfaceName=%interfaceName:~16%

:: Check if dns is set on connection
set shecanSet=1
for /F "tokens=* USEBACKQ" %%F IN (`netsh interface ip show dnsserver name^=%interfaceName% ^| findstr "DHCP"`) do (
  set shecanSet=0
)

if "%shecanSet%"=="0" (
  call :setDns
  goto :eof
) else (
  call :unsetDns
  goto :eof
)

:setDns
echo Setting Shecan DNS...
wmic nicconfig where (IPEnabled=TRUE) call SetDNSServerSearchOrder ("178.22.122.100","185.51.200.2")
color 2
echo Shecan DNS Set^!
goto :eof

:unsetDns
echo Removing Shecan DNS...
wmic nicconfig where (IPEnabled=TRUE) call SetDNSServerSearchOrder ()
color 4
echo DNS set back to DHCP.
goto :eof

endlocal
