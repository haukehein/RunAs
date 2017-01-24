@echo off & if [%1]==[] goto:EOF

  net session >nul 2>nul && ( %* ) || ( call "%~dp0admindo.cmd" %* )
  
  setlocal enabledelayedexpansion
  set sleep_seconds=1
:WaitProcess.Again
  rem  Sleep some seconds.
  ( timeout /T %sleep_seconds% /NOBREAK || ping 127.0.0.1 -n %sleep_seconds% || ping ::1 -n %sleep_seconds% ) >nul 2>nul
  rem
  for /F %%x in ('tasklist /NH /FI "IMAGENAME eq %~nx1"')  do if /I "%%x"=="%~nx1" goto :WaitProcess.Again
  rem
  endlocal
