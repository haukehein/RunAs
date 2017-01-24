@echo off & if [%1]==[] goto:EOF

  setlocal
  if "%_bitness_%"=="" reg query "HKLM\Hardware\Description\System\CentralProcessor\0" 2>NUL | find /i "x86" >NUL 2>NUL && set "_bitness_=32" || set "_bitness_=64"
  set "SYSTEMSYSTEM=%SYSTEMROOT%\System32"
  if "%_bitness_%"=="64" set "SYSTEMSYSTEM=%SYSTEMROOT%\SysWOW64"
  "%SYSTEMSYSTEM%reg.exe" add HKCU\Software\Sysinternals\PsExec /f /v EulaAccepted /t REG_DWORD /d 1 >nul 2>&1
  set "psexec=%~dp0..\pstools\psexec%_bitness_%.exe"
  if exist "%SYSTEMSYSTEM%\psexec.exe" set "psexec=%SYSTEMSYSTEM%\psexec.exe"
  call "%~dp0runas_admin.cmd" "%psexec%" -i -s -d %*
  rem call "%~dp0runas_admin.cmd" "%psexec%" -i -s %*
  endlocal

  setlocal enabledelayedexpansion
  set sleep_seconds=1
:WaitProcess.Again
  rem  Sleep some seconds.
  ( timeout /T %sleep_seconds% /NOBREAK || ping 127.0.0.1 -n %sleep_seconds% || ping ::1 -n %sleep_seconds% ) >nul 2>nul
  rem
  for /F %%x in ('tasklist /NH /FI "IMAGENAME eq %~nx1"')  do if /I "%%x"=="%~nx1" goto :WaitProcess.Again
  rem
  endlocal
